%%%%%%%% Exploratory analysis of subject-wise sample entropy summary features %%%%%%%%
%
% This script performs exploratory analysis of subject-wise sample entropy
% estimates derived from MEG scout/source-localised time-series data.
%
% Input:
%   1. Subject-wise sample entropy matrix
%      - 114 ROIs x n subjects
%      - column names = subject IDs
%      - generated from 540 s / 9 minutes of MEG data, selected after
%        duration-stability analysis
%
%   2. Resection table
%      - 114 ROIs x n subjects logical matrix
%      - 1 = resected region, 0 = non-resected region
%
%   3. Lateralisation table
%      - n subjects x 3 table
%      - column 1 = subject ID
%      - column 2 = ipsilateral hemisphere ('L' or 'R')
%      - column 3 = contralateral hemisphere ('L' or 'R')
%
% Output:
%   1. Tables summarising subject-wise sample entropy features-
%      mean, minimum, range and standard deviation.
%   2. Exploratory comparisons of entropy by resection status, hemisphere
%      and lobe.
%
% These outputs are used for downstream statistical modelling of associations
% between clinical variables and sample entropy.


%% Import raw sample data set and relevant input data 
sampen_raw = readtable('/Path/to/SampEn_540.csv', "ReadVariableNames", true, "ReadRowNames", true); 
resections = readtable ('/Path/to/resection_table.csv', "ReadVariableNames", true, "ReadRowNames", true); 
lateralization= readtable ('/Path/to/surgical_lateral.xlsx', "UseExcel", false); 

subject_list = sampen_raw.Properties.VariableNames; 
nsubjects= numel(subject_list); 

%% 0- Compute Mean and sd of sampen_raw 540 

sampen_raw_array= table2array(sampen_raw); 
% mean value of sampen_raw = 0.8375
mean_sampen_raw_acrossRoi = mean(sampen_raw_array,2); 
mean_sampen_raw_acrossSubj = mean(sampen_raw_array,1); 
std(mean_sampen_raw_acrossRoi) % sd = 0.036
std(mean_sampen_raw_acrossSubj) %sd= 0.1176
% there was greater deviation across subjects and not ROIs
hist(mean_sampen_raw_acrossRoi)
hist(mean_sampen_raw_acrossSubj)% the mean value is least represented in the distribution
%sample entropy varied more between subjects than between ROIs


%% I- Raw sampen in resected vs non-resected regions
% create a table of resected and non-resected sampen raw

sampen_raw_resected = table2array(sampen_raw)*nan; 
sampen_raw_nonresected = table2array(sampen_raw); 

for subject = 1:length(subject_list)
    
    % find the current subject
    current_subject = subject_list{1, subject}; 
    
    % find the index of the resected regions of the current subject
    resected_index=find(resections.(current_subject)==1);
    
    sampen_raw_resected(resected_index,subject) = sampen_raw_array(resected_index, subject); 
    sampen_raw_nonresected(resected_index,subject)= NaN; 
end 

mean_sampen_resected = mean(sampen_raw_resected, 1, "omitnan"); 
mean_sampen_nonresected = mean(sampen_raw_nonresected,1, "omitnan");

% test for difference 
[h,p,ci,stats] = ttest2(mean_sampen_resected, mean_sampen_nonresected)
% p = 0.646, tstat = -0.461
% no sig difference between resected and non-resected regions 

signrank(mean_sampen_resected, mean_sampen_nonresected)
% p= 0.3126 

% save the resected and non-resected tables 
sampen_raw_resected = array2table(sampen_raw_resected); 
sampen_raw_nonresected = array2table(sampen_raw_nonresected); 

% add variable names
sampen_raw_resected.Properties.VariableNames = subject_list; 
sampen_raw_nonresected.Properties.VariableNames = subject_list; 

%add roi labels
sampen_raw_resected.Properties.RowNames = sampen_raw.Properties.RowNames; 
sampen_raw_nonresected.Properties.RowNames = sampen_raw.Properties.RowNames; 

writetable (sampen_raw_resected, '/Path/to/sampen_raw_resected.csv', "WriteRowNames", true, "WriteVariableNames", true); 
writetable (sampen_raw_nonresected, '/Path/to/sampen_raw_nonresected.csv', "WriteRowNames", true);   

%% II- Compare sampen raw in right vs left regions of the brain 

mean_sampen_raw_left = mean(table2array(sampen_raw(1:57,:)),2);
mean_sampen_raw_right = mean(table2array(sampen_raw(58:114,:)),2);

[h,p,ci,stats] = ttest2(mean_sampen_raw_left, mean_sampen_raw_right); 
% result- p= 0.1, tstat = 1.62, do further analysis 

%test the data for normality 
kstest(mean_sampen_raw_left) %result =1 - distribution is not normal
kstest(mean_sampen_raw_right) %result =1 - distribution is not normal

ranksum(mean_sampen_raw_left, mean_sampen_raw_right)
% result, p= 0.12

% rank-sum wilcox test assumes independence of data
signrank(mean_sampen_raw_left, mean_sampen_raw_right)
% result, p= 0.0027 - woah! let's plot
figure
boxplot([mean_sampen_raw_left,mean_sampen_raw_right],'Notch','on','Labels',{'left','right'})
title('Left vs Right sampen raw')
% the left is slightly higher in entropy as compared to the right, but the
% difference is miniscule

mean(mean_sampen_raw_left)
mean(mean_sampen_raw_right)
% mean entropy on left = 0.843, right = 0.832, difference not statistically
% significant

% however, the above comparison in II is limited in absence of controls or normalization

%% II- Compare the raw sampen in different lobes of the brain from the means of contralateral hemispeheres
% load the raw_sampen contralateral 
sampen_raw_contraL = readtable ('/Path/to/sampen_contraL_raw.csv', "ReadRowNames", true);
% load a sample scout series
scout_series = load ('/Path/to/A1_ss_114.mat'); 
% load and format the atlas 
atlas = struct2table(scout_series.Atlas.Scouts); 
cols2del = [1 2 3 5 7];
atlas(:, cols2del) =[]; 

% use the transformation index to transform this table to cnnp parc
atlas.Properties.RowNames = atlas.(1); %convert the first column into row names
atlas.(1) = []; 
% create a transformation matrix to shift vars
oldvariables = atlas.Properties.RowNames; 
newvariables = sampen_raw.Properties.RowNames; 
[~,LOCB] = ismember(newvariables,oldvariables);
atlas_cnnp = atlas(LOCB,:); 

% add a new column to the atlas with just names of the hemisphere and lobes
atlas_cnnp_array = table2cell(atlas_cnnp); 

% add the hemisphere to the cnnp atlas 
for roi = 1:height(atlas_cnnp)
    region = atlas_cnnp{roi,1};
    region = region{1,1}; 
    hemisphere = extract(region,1);
    hemisphere = hemisphere {1,1};
    atlas_cnnp_array{roi,2}= hemisphere; 
end 

% add the lobe(s) to the cnnp atlas
for roi =1:height(atlas_cnnp)
    region = atlas_cnnp{roi, 1}; 
    region = region{1,1}; 
    lobe = extract(region, strlength(region));
    lobe = lobe{1,1};
    atlas_cnnp_array{roi,3}= lobe; 
end
      

% save the cnnp atlas in input data 
varnames = ["Region", "Hemisphere", "Lobe"]; 
rownames = atlas_cnnp.Properties.RowNames; 
atlas_cnnp = array2table(atlas_cnnp_array); 
atlas_cnnp.Properties.RowNames = rownames; 
atlas_cnnp.Properties.VariableNames= varnames; 
writetable(atlas_cnnp, '/Path/to/cnnpAtlas_regions.csv', "WriteRowNames", true); 

% manually change the lobe of 'C' indices- only 2 C indices (paracentral
% remaining
%pari_idx = [42 43 78 102];
%front_idx = [23 44 45 46 80 103 104];
atlas_cnnp_array{21,3}= 'P'; 
atlas_cnnp_array{42,3}= 'P'; 
atlas_cnnp_array{43,3}= 'P'; 
atlas_cnnp_array{78,3}= 'P'; 
atlas_cnnp_array{102,3}= 'P'; 
atlas_cnnp_array{23,3}= 'F'; 
atlas_cnnp_array{44,3}= 'F'; 
atlas_cnnp_array{45,3}= 'F'; 
atlas_cnnp_array{46,3}= 'F'; 
atlas_cnnp_array{80,3}= 'F'; 
atlas_cnnp_array{103,3}= 'F'; 
atlas_cnnp_array{104,3}= 'F'; 

% save the cnnp atlas in input data 
varnames = ["Region", "Hemisphere", "Lobe"]; 
rownames = atlas_cnnp.Properties.RowNames; 
atlas_cnnp = array2table(atlas_cnnp_array); 
atlas_cnnp.Properties.RowNames = rownames; 
atlas_cnnp.Properties.VariableNames= varnames; 
writetable(atlas_cnnp, '/Path/to/cnnpAtlas_regions_Edit.csv', "WriteRowNames", true); 

% let's compare this with raw contraL distribution 
mean_sampen_raw_contraL_acrossSubj = mean(table2array(sampen_raw_contraL),1, "omitnan"); 
mean_sampen_raw_contraL_acrossRoi = mean(table2array(sampen_raw_contraL),2, "omitnan");

hist(mean_sampen_raw_contraL_acrossSubj)
hist(mean_sampen_raw_contraL_acrossRoi)

%extract the indices of frontal, temporal, parietal and occipital lobes
frontal_idx = find(strcmp(atlas_cnnp.(3), 'F')); % n=37
temporal_idx = find(strcmp(atlas_cnnp.(3), 'T')); % n=30
parietal_idx = find(strcmp(atlas_cnnp.(3), 'P')); % n=24
occipital_idx = find(strcmp(atlas_cnnp.(3), 'O')); % n=13
central_idx = find(strcmp(atlas_cnnp.(3), 'C')); % n= 2

% find the mean of these regions in contraL hemispheres
mean_sampen_raw_contraL = mean(table2array(sampen_raw_contraL), 2, "omitnan"); 
mean_sampen_raw_frontal = mean_sampen_raw_contraL(frontal_idx,1); 
mean_sampen_raw_temporal = mean_sampen_raw_contraL(temporal_idx,1); 
mean_sampen_raw_parietal = mean_sampen_raw_contraL(parietal_idx,1); 
mean_sampen_raw_occipital = mean_sampen_raw_contraL(occipital_idx,1); 
mean_sampen_raw_central = mean_sampen_raw_contraL(central_idx,1); 

% test these values for normality
kstest(mean_sampen_raw_frontal) % 1= not normal
kstest(mean_sampen_raw_temporal) % 1= not normal
kstest(mean_sampen_raw_parietal) % 1= not normal
kstest(mean_sampen_raw_occipital) % 1= not normal
kstest(mean_sampen_raw_central) % 1= not normal

ranksum(mean_sampen_raw_frontal, mean_sampen_raw_temporal) %p= 6e-04
ranksum(mean_sampen_raw_frontal, mean_sampen_raw_parietal)% p=0.0035
ranksum(mean_sampen_raw_frontal, mean_sampen_raw_occipital)% p=0.1156
ranksum(mean_sampen_raw_frontal, mean_sampen_raw_central) %p=0.5880
ranksum(mean_sampen_raw_temporal, mean_sampen_raw_parietal) % p=0.5048
ranksum(mean_sampen_raw_temporal, mean_sampen_raw_occipital)% p=0.0743
ranksum(mean_sampen_raw_temporal, mean_sampen_raw_central)% p= 0.013
ranksum(mean_sampen_raw_parietal, mean_sampen_raw_occipital)% p= 0.2343
ranksum(mean_sampen_raw_parietal, mean_sampen_raw_central)% p= 0.0432
ranksum(mean_sampen_raw_occipital, mean_sampen_raw_central)% p= 0.344

%% Make tables for R analysis
mean_sampenr_acrossRoi= array2table(mean_sampen_raw_acrossRoi); 
mean_sampenr_acrossSubj= array2table(mean_sampen_raw_acrossSubj);
mean_sampenr_acrossRoi.Properties.RowNames = sampen_raw.Properties.RowNames; 
mean_sampenr_acrossSubj.Properties.VariableNames = sampen_raw.Properties.VariableNames; 
writetable(mean_sampenr_acrossRoi, '/Path/to/mean_sampenr_acrossRoi.csv', "WriteRowNames", true); 
writetable(mean_sampenr_acrossSubj, '/Path/to/mean_sampenr_acrossSubj.csv'); 

%% Find if the minima of sampenr in each subject is in the resected volume or the resected lobe
% Make a table of the minima for each subject
sampenr_minima = cell(nsubjects,7); 
subject_list = subject_list'; 
sampenr_minima(:,1) = subject_list(:,1); 

for subject = 1: length (subject_list)
    % find the current subject
    current_subject = subject_list{subject,1}; 
    
    % find the minima of the current subject
    minima = min(sampen_raw.(current_subject), [],1);
    sampenr_minima{subject,2}= minima; % enter the value into the minima table
    
    % find the idx of the minima
    minima_index=find(sampen_raw.(current_subject)==minima);
    sampenr_minima{subject,3}= minima_index;
    
    % find if the minima is part of the resected index 
    resected_idx = find(resections.(current_subject)==1);
    
    if ismember(minima_index,resected_idx)==1
       sampenr_minima{subject,4}= 1;
    elseif ismember(minima_index,resected_idx)==0
        sampenr_minima{subject,4}= 0;
    end
    
    % find if the minima is part of the resected lobe
    % find the lobe of resected indices
    resected_lobe = atlas_cnnp{resected_idx,3};
    % find the lobe of minima
    minima_lobe = atlas_cnnp{minima_index, 3}; 
    minima_lobe = minima_lobe{1,1}; 
    
    if ismember(minima_lobe, resected_lobe)==1
        sampenr_minima{subject,5}=1; 
    elseif ismember(minima_lobe, resected_lobe)==0
        sampenr_minima{subject,5}=0; 
    end
    
    % % find if the minima is in the frontal or temporal lobe
    if minima_lobe == 'T'
        sampenr_minima{subject,6}=1;
    elseif minima_lobe == 'F'
        sampenr_minima{subject,6}=2;
    else sampenr_minima{subject,6}=0;
    end
    
    % find if the minima is in the ipsiL or the contraL
    lateraln = lateralization{subject,2}; 
    lateraln = lateraln{1,1}; 
    
    minima_lateraln = atlas_cnnp{minima_index, 2}; 
    minima_lateraln = minima_lateraln{1,1}; 
    
    if minima_lateraln == lateraln
        sampenr_minima{subject,7} = 1; 
    elseif minima_lateraln ~= lateraln
        sampenr_minima{subject,7} = 0; 
    end  
end


% find the most common regions of minima, check if they are in a particular region
rois = atlas_cnnp.Properties.RowNames; 

for subject = 1: length (subject_list)
    % find the minima of the current subject
    
    % find the index of the minima
    minima_index = sampenr_minima{subject,3}; 
    
    % find the regions of the minima
    minima_roi = rois{minima_index, 1}; 
    minima_region = atlas_cnnp{minima_index,1};
    minima_region = minima_region{1,1}; 
    
    sampenr_minima{subject,8} = minima_roi; 
    sampenr_minima{subject,9} = minima_region; 
    
end

% as a last step check if the range/ variability is related 

for subject = 1: length(subject_list)
    % find the current subject
    current_subject = subject_list{subject,1};
    
    % calculate the range and std
    subj_range = (max(sampen_raw.(current_subject), [],1)-min(sampen_raw.(current_subject), [],1)); 
    subj_std = std(sampen_raw.(current_subject)); 
    
    % add the range and std to sampenr_minima
    sampenr_minima{subject,10} = subj_range; 
    sampenr_minima{subject,11} = subj_std; 
    
end

sampenr_stats = cell2table(sampenr_minima); 
varnames = {'subj', 'minima', 'minima_index', 'minima_inResVol', 'minima_inResLobe', ...
     'minima_inFT', 'minima_inIpsiL', 'minima_roi', 'minima_region', 'sampenr_range', 'sampenr_std'}; 
 
sampenr_stats.Properties.VariableNames = varnames; 
writetable(sampenr_stats, '/Path/to/sampenr_stats.csv');
    
