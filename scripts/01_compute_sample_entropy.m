%% Calculate multiscale sample entropy for neural time-series data
% This script computes multiscale sample entropy (MSE) from source-localised MEG data of epilepsy patients
% The input data is Brainstorm scout series structure, exported as '.mat' files 
% The code can compute sample entropy for similar neural time-series data from modalities such as MEG, EEG or LFP signals.
%
% The sample entropy function used in this workflow was obtained from:
% Brian Lord (2024). SampEn.
% MATLAB Central File Exchange:
% https://www.mathworks.com/matlabcentral/fileexchange/124326-sampen
%
% Parameters:
%   data : neural time-series data
%   r    : tolerance threshold, defined as a proportion of the signal standard
%          deviation used to identify matching patterns; default = 0.2
%   dim  : embedding dimension, corresponding to the length of the comparison
%          window; default = 3
%
% Authors: KK, CW
% Date: Jan 2024
% Notes: Ensure that the code by Brian Lord (SampEn) has been downloaded and added to the MATLAB path. 
% This script asssumes that the input time-series data is in '.mat' format, please modify as needed. 

%% Clear all previous processes
clearvars
clc


% addpath to the SampEn scripts
addpath '/path/to/SampEn/'; 

% specify directory containing the input time-series data
data_dir = '/path/to/input/files';
output_dir= '/path/to/output/directory';
cd (data_dir)
data_files = dir ('*.mat'); % <- edit as needed

% specify the number of regions of interest (ROIs)/ channels for which entropy would be computed
% For this project number of ROIs= 114
nroi= 114; 

% specify the number of seconds for which entropy would be computed
% in this script we compute entropy for 360s (6 minutes of data) 
nsecs= 360; %duration in seconds 
fs= 500; % sampling rate of the data 
nsamples= nsecs*fs; 

%% create a master table for storing SampEn from all subjects from all ROIs
% one data file contains data of only one subject
patient_scout_sampen = cell(nroi+1,length(data_files)); % leaving top row for subject_ids


for subj = 1:length(data_files) % for each subject
    file_name = getfield(data_files,{subj},'name'); % get the file name
    scout_series_file = load (file_name); % and load the structure file containing 114 scout series
    
    for roi = 1:nroi % for each of the 114 scout series/ regions of interest 
        scout_series = scout_series_file.Value(roi,[1:nsamples]); % load each time series, take data of first 6 minutes
        sampen_scout = SampEn(scout_series, 0.2, 3); % r=0.2, dim =3
        patient_scout_sampen{roi, subj} = sampen_scout; 
        clear scout_series % to save memory
    end
    subject_id = extractBefore (file_name, "_ss"); % exctract the subject ID from the structure
    patient_scout_sampen{nroi+1, subj} = subject_id; % and add it to the end of the patient column
    clear scout_series_file % save memory
    fprintf('Subject %d complete\n', subj);
end

%% add roi labels, convert to table and save file
% extract Atlas labels
load (data_files(1).name); 
scout_atlas = getfield (Atlas, 'Scouts'); % extract the scouts field from the atlas structure
scout_atlas_struct = struct2table (scout_atlas); % convert the scout structure to table 
scout_atlas_list = scout_atlas_struct.(4);% extract the lables from the scout struct as a list % <-edit as needed

% Save the SampEn values cell as a table
subj_names = patient_scout_sampen(nroi+1,:);
patient_scout_sampen_table = cell2table (patient_scout_sampen);
patient_scout_sampen_table(nroi+1,:) = []; %remove last row from table
patient_scout_sampen_table.Properties.VariableNames = subj_names;
patient_scout_sampen_table.Properties.RowNames = scout_atlas_list;

% save the table as a csv file
fname= strcat(output_dir, '/SampEn_raw_', num2str(nsecs)); 
writetable (patient_scout_sampen_table, fname, "WriteVariableNames",1, "WriteRowNames", 1);
