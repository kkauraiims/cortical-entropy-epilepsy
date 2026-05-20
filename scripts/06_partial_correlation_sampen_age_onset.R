####### Partial correlation between mean SampEn and age of epilepsy onset #######
####### adjusted for age at scan ###############################################
#
# Input: 
#      1. df_sampenr_model.csv (Metadata table containing clinical variables and mean SampEn)
#      (saved from 05_regression_model_sampen_age_epilepsy_onset.R)
# Output: 
#   1. Partial correlation statistics for mean SampEn and age of epilepsy onset,
#      adjusted for age at scan.
#   2. Residual-residual plot showing the age-adjusted association.

#### Load the necessary packages 
library('dplyr')
library("ggplot2")
library("ggpubr")
library("ppcor")

#### load the input data 
df_sampenr_model=read.csv("/Path/to/df_sampenr_model.csv")

#### first do a correlation (spearman) test between the age at scan and mean sampenr
# spearman because sampenr is not normally distributed
cor.test(df_sampenr_model$age_atScan, df_sampenr_model$mean_sampenr, method ="spearman")
#rho = 0.371, p= 0.036

#### perform a partial correlation between age of epilepsy onset & mean SampEn
# while controlling for age at scan
# x= age of seizure onset, y= mean_sampenr
# z= age at scan, the confounding variable
pcorr_ageScan_sampenr <- pcor.test(df_sampenr_model$age_onset, df_sampenr_model$mean_sampenr, df_sampenr_model$age_atScan, method= "spearman")
# estimate = 0.5, p=0.004 => the association is significant even after adjusting for age at scan

#### plot mean sampen and age of onset with the confounder removed 
# assume x is age of onset, y is sampenr
#lm(y~z), y is the dependent(sampenr), z is the confounder(age at scan)
model_sampenr_ageScan<-lm(formula = mean_sampenr~age_atScan, data=df_sampenr_model)
summary(model_sampenr_ageScan)
residuals_sampenr= model_sampenr_ageScan$residuals #extract residuals from the model

model_ageOnset_ageScan<-lm(formula = age_onset~age_atScan, data=df_sampenr_model)
summary(model_ageOnset_ageScan)
#R2=0.49, p=4.3e-06
residuals_ageOnset=model_ageOnset_ageScan$residuals #extract residuals from model

# make a new data frame containing residuals 
data<-data.frame(residuals_ageOnset, residuals_sampenr)
colnames(data)<-c('res_ageOnset', 'res_sampenr')

##### Perform a correlation test of the residuals of x and y
cor.test(data$res_ageOnset, data$res_sampenr, method="spearman")
#rho = 0.41, p=0.02

###### make a plot
p<- ggscatter(data, x = "res_ageOnset", y = "res_sampenr", add= "reg.line",
              conf.int = TRUE, add.params = list (color= "Maroon 4", fill = "lightblue"), 
              cor.coef = TRUE, cor.method = "spearman",
              xlab = "Residual of Age of Onset ~ (Age at Scan)", ylab = "Residual of Mean Sample Entropy ~ (Age at Scan)") +  theme(
                axis.title.x = element_text(size = 12, face="bold"),
                axis.title.y = element_text(size = 12, face="bold"), 
              )

ggsave(filename= "/Path/to/Figure1bb_Sep2025.tiff", plot= p, width = 20, height = 12, dpi = 300, units = "cm")
