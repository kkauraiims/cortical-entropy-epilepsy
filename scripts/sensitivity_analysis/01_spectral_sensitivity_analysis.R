## this script tests if the relationship between age of seizure onset and cortical entropy is confounded by 
# spectral characteristics, specifically: 
# 1. broadband spectral power 
# 2. relative band power- delta, theta, alpha, beta
# 3. mean signal variance 

########################### Load and prepare the input data ##################################
# data for mean entropy of the whole cortex is contained in df_sampenr_model 
# import the entropy_spectral.csv created in sql 
# create a new data frame df_sampenr_spectral_model 

library(dplyr)
library(broom)

entropy_spectral <- read.csv('/Users/neelbazro/Desktop/Complexity_paper/sql_spectral_analysis /entropy_spectral.csv')

df_sampenr_spectral <-df_sampenr_model[,c("subject", "mean_sampenr", "age_onset")]
df_sampenr_spectral <- df_sampenr_spectral %>% left_join(entropy_spectral, by= "subject") #add the spectral data

######################### Test association: entropy~ relative_spectral_pow + age_onset ####################################
## In literature: 
# relative delta : -ve association with entropy 
# relative beta: +ve association with entropy
# fast/slow ratio: +ve association with entropy
# as a rule of thumb more the slow activity, lower is the entropy
# in normal populations: the rule of thumb above holds 

m_rel <- lm(mean_sampenr~ delta_rel+theta_rel+ alpha_rel+ beta_rel, data=df_sampenr_spectral)
summary(m_rel)

m_rel_age <- lm(mean_sampenr ~ delta_rel + theta_rel + alpha_rel + beta_rel + age_onset,data = df_sampenr_spectral)
summary(m_rel_age)
# use anove to test if addition of the age of onset improves the sampenr~spectral_pow model 
anova(m_rel, m_rel_age)
#rss (unexplained variability): 
# sum of sq (how much unexplained variability falls when age_onset added): 
# F(size of improvement rel to unexplained noise): 
# Pr(>F) (improvement stat. sig?): 

######################### Test association: entropy~ absolute_broadband_pow + age_onset ####################################

m_bb <- lm(mean_sampenr ~ broadband_power,data = df_sampenr_spectral)
summary(m_bb)

m_bb_age <- lm(mean_sampenr ~ broadband_power + age_onset,data = df_sampenr_spectral)
summary(m_bb_age)

anova(m_bb, m_bb_age)

######################### Test association: entropy~ mean_signal_variance + age_onset ####################################

m_var <- lm(mean_sampenr ~ sig_variance,data = df_sampenr_spectral)
summary(m_var)

m_var_age <- lm(mean_sampenr ~ sig_variance + age_onset,data = df_sampenr_spectral)
summary(m_var_age)

anova(m_var, m_var_age)
