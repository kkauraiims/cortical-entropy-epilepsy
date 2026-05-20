########### Statistical association between sample entropy and clinical variables ##############
# This script tests associations between cortical sample entropy metrics
# and clinical variables in the same epilepsy patient cohort.
#
# Inputs:
#   1. Sample entropy summary metrics exported from:
#      03_explore_subjectwise_sampen_features.m
#   2. Clinical metadata for the corresponding patients
#
# Objective:
#   To test whether inter-individual variation in cortical sample entropy
#   is associated with clinical variables such as age of epilepsy onset,
#   epilepsy duration, seizure-related variables, or other available
#   clinical measures.
#
# Output:
#   Summary statistics and figures showing associations between sample
#   entropy mean and range, and age of epilepsy onset.

## Load the necessary packages 
library('dplyr')
library("ggplot2")
library("ggpubr")

# Load the clinical metadata 
metadata<- read.csv('Path/to/metadata')

# load and reformat the sampenr_table 
sampenr <- read.csv('/Path/to/sampEn_540.csv')
rownames(sampenr) <- sampenr[,1]
sampenr <- sampenr[,-1]

# load the sampenr stats (summary sample entropy features)
sampenr_stats <- read.csv('/Path/to/sampenr_stats.csv')
means_sampenr <- colMeans (sampenr)
means_sampenr <- data.frame (sampenr_stats$subj, means_sampenr)
colnames(means_sampenr) <- c('subj', 'means_sampenr')

# create combined summary tables 
sampenr_stats = sampenr_stats%>%left_join(means_sampenr, by = c('subj'))
df_sampenr_clinical = sampenr_stats%>%left_join(metadata,by=c('subj'='SubjectID'))

####### run some preliminary stats for std and range ######
cor.test(df_sampenr_clinical$sampenr_range, df_sampenr_clinical$`Age at Seizure onset (years)`, method = "spearman")
# rho = -0.5, p =0.0035
plot(df_sampenr_clinical$`Age at Seizure onset (years)`, df_sampenr_clinical$sampenr_range,pch = 19, col = "lightblue")
abline(lm(df_sampenr_clinical$sampenr_range~ df_sampenr_clinical$`Age at Seizure onset (years)`),  col = "red", lwd = 3)

cor.test(df_sampenr_clinical$sampenr_range, df_sampenr_clinical$Duration, method = "spearman") 
# rho = 0.07, p =0.67

cor.test(df_sampenr_clinical$sampenr_range, df_sampenr_clinical$`SzFq/week`, method = "spearman") 
# rho = -0.03, p =0.863

wilcox.test(df_sampenr_clinical%>%filter(Sec_gen=='y')%>%select(sampenr_range)%>%pull(),
            df_sampenr_clinical%>%filter(Sec_gen=='n')%>%select(sampenr_range)%>%pull(),alternative = 'greater')
# p =0.57

wilcox.test(
  df_sampenr_clinical %>% filter(minima_inResLobe == 1) %>% select(sampenr_range) %>% pull(),
  df_sampenr_clinical %>% filter(minima_inResLobe == 0) %>% select(sampenr_range) %>% pull(),
  alternative = "two.sided"
)
# p =0.57
wilcox.test(
  df_sampenr_clinical %>% filter(minima_inResLobe == 1) %>% select(`Age at Seizure onset (years)`) %>% pull(),
  df_sampenr_clinical %>% filter(minima_inResLobe == 0) %>% select(`Age at Seizure onset (years)`) %>% pull(),
  alternative = "two.sided"
)
# p= 0.8

## violin plot for means across subject and roi
sampenr_means_acrossSubj <- colMeans(sampenr)
sd_subj <- data.frame(sapply(sampenr,sd))
colnames(sd_subj) <- c('sd')
sd_subj$iqr <- sapply(sampenr,IQR)


sd_roi <- data.frame(apply(sampenr,1,sd))
sd_roi$iqr <- apply(sampenr,1,IQR)
colnames(sd_roi) <- c('sd')

mean(sd_subj$iqr)
mean(sd_roi$iqr)


## make a correlation plot for age of onset
data <- data.frame (sampenr_stats$means_sampenr, df_sampenr_clinical$`Age at Seizure onset (years)`, df_sampenr_clinical$AgeAtScan, df_sampenr_clinical$Duration)
colnames (data) <- c('mean_sampenr', 'age_onset', 'age_scan', 'duration')

colMax <- function(data) sapply(data, max, na.rm = TRUE)
col_max_values <- colMax(sampenr)
colMin <- function(data) sapply(data, min, na.rm = TRUE)
col_min_values <- colMin(sampenr)
range <- (col_max_values)-(col_min_values)
data$range <- range

# do a test for normality of the vars in data 
shapiro.test(data$mean_sampenr) #not normal, but close to it p =0.03
shapiro.test(data$age_onset) #definitely not normal
shapiro.test(data$age_scan) #normal
shapiro.test(data$range) # normal
shapiro.test(data$duration)# not normal, p =0.006

plot(data$age_onset, data$mean_sampenr, pch = 19, col = "lightblue")
abline(lm(data$mean_sampenr~ data$age_onset), col = "red", lwd = 3)

ggscatter(data, x = "age_onset", y = "mean_sampenr", 
          add = "reg.line", conf.int = TRUE, add.params = list (color= "red", fill = "lightblue"), 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Age of seizure onset (years)", ylab = "Mean sample entropy")

# make a correlation plot for range and age of onset
ggscatter(data, x = "age_onset", y = "range", 
          add = "reg.line", conf.int = TRUE, add.params = list (color= "red", fill = "lightblue"), 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Age of seizure onset (years)", ylab = "Range of sample entropy")


# make a new data frame for age at scan and age at onset togther
ggscatter(data, x = "age_onset", y = "mean_sampenr", cor.method = "pearson" )
ggplot(data, aes(age_onset,mean_sampenr, size = age_scan)) +geom_point()
ggplot(data, aes(age_onset,mean_sampenr, color = age_scan)) +geom_point()


##### final plots Figure 1: Sep 2025 ######
p1<- ggscatter(data, x = "age_onset", y = "mean_sampenr", add= "reg.line",
               conf.int = TRUE, add.params = list (color= "Maroon 4", fill = "lightblue"), 
               cor.coef = TRUE, cor.method = "spearman",
               xlab = "Age of seizure onset (years)", ylab = "Mean sample entropy") +  theme(
                 axis.title.x = element_text(size = 13, face="bold"),
                 axis.title.y = element_text(size = 13, face="bold"), 
               )

# change the color of the plot line
ggsave(filename= "/Path/to/Figure1a_Sep2025.tiff", plot= p1, width = 20, height = 12, dpi = 300, units = "cm")

p2<- ggscatter(data, x = "age_onset", y = "range", 
               add = "reg.line", conf.int = TRUE, add.params = list (color= "Maroon 4", fill = "lightblue"), 
               cor.coef = TRUE, cor.method = "spearman",
               xlab = "Age of seizure onset (years)", ylab = "Range of sample entropy") +  theme(
                 axis.title.x = element_text(size = 13, face="bold"),
                 axis.title.y = element_text(size = 13, face="bold"), 
               )
ggsave(filename= "/Path/to/Figure1b_Sep2025.tiff", plot= p2, width = 17, height = 10, dpi = 300, units = "cm")

# eFig 2
p3 <- ggscatter(data, x = "duration", y = "mean_sampenr", 
                add = "reg.line",add.params = list (color= "Maroon 4", fill = "lightblue"), 
                cor.coef = TRUE, cor.method = "spearman",
                xlab = "Duration of epilepsy (years)", ylab = "Mean sample entropy") +  theme(
                  axis.title.x = element_text(size = 13, face="bold"),
                  axis.title.y = element_text(size = 13, face="bold"), 
                )

ggsave(filename= "/Path/to/eFigure2_Sep2025.tiff", plot= p3, width = 17, height = 10, dpi = 300, units = "cm")
