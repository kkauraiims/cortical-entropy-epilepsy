########### Build backward regression model of mean SampEn and age of epilepsy onset #########
# This script models the association between subject-level mean sample entropy
# and clinical variables in an epilepsy patient cohort.
#
# The script uses backward stepwise regression as the final model-selection
# approach after exploratory analysis.
#
# Inputs:
#   1. ROI-level sample entropy table generated from the entropy pipeline
#   2. Clinical metadata for the corresponding patients
#
# Output:
#   1. Final model summary
#   2. Model diagnostic plots
#   3. Analysis-ready table containing mean SampEn and clinical predictors
#

# Load the necessary packages
library(ggcorrplot)
library(dplyr)


# Load and format the input file - sampenr_540_reordered
sampenr =read.csv("/Path/to/sampEn_540.csv")
rownames(sampenr)<- sampenr$Row
sampenr <- sampenr[,-1]

# Load the clinical metadata file
load ("/Path/to/metadata.Rda")

# Find the mean across Subjects for all ROIs 
mean_sampenr_subjects <- colMeans(sampenr)
mean_sampenr_subjects <- data.frame(mean_sampenr_subjects)
colnames(mean_sampenr_subjects)<- c('vals')

# Preliminary exploratory correlations were assessed separately.

# make a new data frame for clinical comparison
mean_sampenr_subjects <- data.frame(metadata$SubjectID, mean_sampenr_subjects)
colnames(mean_sampenr_subjects) <- c('subj', 'mean_sampenr')
df_sampenr_clinical <- mean_sampenr_subjects%>%left_join(metadata,by=c('subj'='SubjectID'))


## Build a regression model for the 3 age related variables
# plot them to check for normality

# build a data frame for this model 
age_sampenr <- data.frame(mean_sampenr_subjects$subj, mean_sampenr_subjects$mean_sampenr, 
                          metadata$`Age at Seizure onset (years)`, metadata$AgeAtScan, metadata$Duration)
colnames(age_sampenr) <- c('subject', 'mean_sampenr', 'age_onset', 'age_atScan', 'duration')
# duation is simply a function of (age at scan)- (age of onset) so collinear with both, should be ignored, or reviewed separately
# do a quick data exploration to see if the GLM is a good idea at all

# check for multicollinearity 
reduced_data <- subset(age_sampenr, select = -mean_sampenr)
reduced_data <- subset(reduced_data, select = -subject)
# Compute correlation at 2 decimal places
corr_matrix = round(cor(reduced_data), 2)

# Compute and show the  result
ggcorrplot(corr_matrix, hc.order = TRUE, type = "lower",
           lab = TRUE)

df_sampenr_model <- age_sampenr
df_sampenr_model$sf <- metadata$`SzFq/week`

df_sampenr_model$sec_gen <- metadata$Sec_gen
df_sampenr_model$hemisphere <- metadata$`Side of resection (L,R)`
# recode the sec_gen variable
df_sampenr_model<- df_sampenr_model %>% 
  mutate(sec_gen= recode(sec_gen, y= 1, n=0))
# recode the side of resectin variable
df_sampenr_model<- df_sampenr_model %>% 
  mutate(hemisphere= recode(hemisphere, 'L'= 0, 'R'=1))

# add the lobes of resection as dummy variables 
df_sampenr_model$isFrontal_res <- metadata$`Lobe of resection (T,F,P,O,I)`
df_sampenr_model<- df_sampenr_model %>% 
  mutate(isFrontal_res= recode(isFrontal_res, 'F'= 1, 'T,F,I'=1, 'T'=0, 'T,F'=1, 'T,F,0'=1, 'F, P'=1, 'T,0'=0, 'P'=0, 'F, T'=1))

df_sampenr_model$isTemporal_res <- metadata$`Lobe of resection (T,F,P,O,I)`
df_sampenr_model<- df_sampenr_model %>% 
  mutate(isTemporal_res= recode(isTemporal_res, 'F'= 0, 'T,F,I'=1, 'T'=1, 'T,F'=1, 'T,F,0'=1, 'F, P'=0, 'T,0'=1, 'P'=0, 'F, T'=1))

df_sampenr_model$isParietal_res <- metadata$`Lobe of resection (T,F,P,O,I)`
df_sampenr_model<- df_sampenr_model %>% 
  mutate(isParietal_res= recode(isParietal_res, 'F'= 0, 'T,F,I'=0, 'T'=0, 'T,F'=0, 'T,F,0'=0, 'F, P'=1, 'T,0'=0, 'P'=1, 'F, T'=0))

df_sampenr_model$isFrontotemporal_res <- metadata$`Lobe of resection (T,F,P,O,I)`
df_sampenr_model<- df_sampenr_model %>% 
  mutate(isFrontotemporal_res= recode(isFrontotemporal_res, 'F'= 0, 'T,F,I'=1, 'T'=0, 'T,F'=1, 'T,F,0'=1, 'F, P'=0, 'T,0'=0, 'P'=0, 'F, T'=1))

df_sampenr_model$isOccipital_res <- metadata$`Lobe of resection (T,F,P,O,I)`
df_sampenr_model<- df_sampenr_model %>% 
  mutate(isOccipital_res= recode(isOccipital_res, 'F'= 0, 'T,F,I'=0, 'T'=0, 'T,F'=0, 'T,F,0'=1, 'F, P'=0, 'T,0'=1, 'P'=0, 'F, T'=0))

# break down isParietal into parietal and fronto-parietal

df_sampenr_model$isParietalonly_res <- metadata$`Lobe of resection (T,F,P,O,I)`
df_sampenr_model<- df_sampenr_model %>% 
  mutate(isParietalonly_res= recode(isParietalonly_res, 'F'= 0, 'T,F,I'=0, 'T'=0, 'T,F'=0, 'T,F,0'=0, 'F, P'=0, 'T,0'=0, 'P'=1, 'F, T'=0))

df_sampenr_model$isFrontoParietal_res <- metadata$`Lobe of resection (T,F,P,O,I)`
df_sampenr_model<- df_sampenr_model %>% 
  mutate(isFrontoParietal_res= recode(isFrontoParietal_res, 'F'= 0, 'T,F,I'=0, 'T'=0, 'T,F'=0, 'T,F,0'=0, 'F, P'=1, 'T,0'=0, 'P'=0, 'F, T'=0))


# Exploratory correlations were performed during analysis development.
# The final modelling workflow below uses backward stepwise regression
# to identify clinical predictors of mean sample entropy.
 
df_sampenr_stepmodel = df_sampenr_model[,-1]

# Fit full model and run backward stepwise regression
full_model <- lm(mean_sampenr ~ ., data = df_sampenr_stepmodel)
back_model <- step(full_model, direction = "backward")
summary(back_model)

# Export final model summary
library(stargazer)
stargazer(
  back_model,
  type = "text",
  title = "Backward stepwise regression model",
  dep.var.labels = "Mean sample entropy",
  t.auto = TRUE,
  out = "table.txt"
)

library(jtools)
summ(back_model)

# Check residuals of final backward stepwise model
model_residuals <- residuals(back_model)

hist(model_residuals, main = "Residuals of final backward stepwise model")
qqnorm(model_residuals)
qqline(model_residuals)
