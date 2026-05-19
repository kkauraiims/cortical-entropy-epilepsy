########## Plot mean SampEn across signal durations ##########

# This script plots mean sample entropy computed across different
# durations of MEG scout/source-localised time-series data.
#
# Durations tested: 30 s to 540 s.
#
# Objective:
# To assess whether mean sample entropy stabilises after a certain duration
# of signal- to estimate the minimum data length required for
# stable entropy estimation.

#Load the necessary packages 
library(readxl)
library(ggplot2)
library(RColorBrewer)

######################## Compute the averages ######################
# Input data files 
sampEn_raw_30 <- read.csv ("/Path/to/SampEn_raw_30.csv")
sampEn_raw_60 <- read.csv ("/Path/to/SampEn_raw_60.csv")
sampEn_raw_120 <- read.csv ("/Path/to/SampEn_raw_120.csv")
sampEn_raw_180 <- read.csv ("/Path/to/SampEn_raw_180.csv")
sampEn_raw_240 <- read.csv ("/Path/to/SampEn_raw_240.csv")
sampEn_raw_300 <- read.csv ("/Path/to/SampEn_raw_300.csv")
sampEn_raw_360 <- read.csv ("/Path/to/SampEn_raw_360.csv")
sampEn_raw_420 <- read.csv ("/Path/to/SampEn_raw_420.csv")
sampEn_raw_480 <- read.csv ("/Path/to/SampEn_raw_480.csv")
sampEn_raw_540 <- read.csv ("/Path/to/SampEn_raw_540.csv")

# find average entropy for each duration
mean_sampen_raw_30 = colMeans(sampEn_raw_30[2:33])
sd_sampen_raw_30= sd(mean_sampen_raw_30)
mean_sampen_raw_30 = mean(mean_sampen_raw_30)

mean_sampen_raw_60 = colMeans(sampEn_raw_60[2:33])
sd_sampen_raw_60= sd(mean_sampen_raw_60)
mean_sampen_raw_60 = mean(mean_sampen_raw_60)

mean_sampen_raw_120 = colMeans(sampEn_raw_120[2:33])
sd_sampen_raw_120= sd(mean_sampen_raw_120)
mean_sampen_raw_120 = mean(mean_sampen_raw_120)

mean_sampen_raw_180 = colMeans(sampEn_raw_180[2:33])
sd_sampen_raw_180= sd(mean_sampen_raw_180)
mean_sampen_raw_180 = mean(mean_sampen_raw_180)

mean_sampen_raw_240 = colMeans(sampEn_raw_240[2:33])
sd_sampen_raw_240= sd(mean_sampen_raw_240)
mean_sampen_raw_240 = mean(mean_sampen_raw_240)

mean_sampen_raw_300 = colMeans(sampEn_raw_300[2:33])
sd_sampen_raw_300= sd(mean_sampen_raw_300)
mean_sampen_raw_300 = mean(mean_sampen_raw_300)

mean_sampen_raw_360 = colMeans(sampEn_raw_360[2:33])
sd_sampen_raw_360= sd(mean_sampen_raw_360)
mean_sampen_raw_360 = mean(mean_sampen_raw_360)

mean_sampen_raw_420 = colMeans(sampEn_raw_420[2:33])
sd_sampen_raw_420= sd(mean_sampen_raw_420)
mean_sampen_raw_420 = mean(mean_sampen_raw_420)

mean_sampen_raw_480 = colMeans(sampEn_raw_480[2:33])
sd_sampen_raw_480= sd(mean_sampen_raw_480)
mean_sampen_raw_480 = mean(mean_sampen_raw_480)

mean_sampen_raw_540 = colMeans(sampEn_raw_540[2:33])
sd_sampen_raw_540= sd(mean_sampen_raw_540)
mean_sampen_raw_540 = mean(mean_sampen_raw_540)

# create a data frame for mean sample entropy/time duration 
df_mean_sampen_raw <- data.frame(
  mean_sampen = c(mean_sampen_raw_30, mean_sampen_raw_60, mean_sampen_raw_120, mean_sampen_raw_180, mean_sampen_raw_240, mean_sampen_raw_300, mean_sampen_raw_360, mean_sampen_raw_420, mean_sampen_raw_480, mean_sampen_raw_540),
  mean_sd=c(sd_sampen_raw_30, sd_sampen_raw_60, sd_sampen_raw_120, sd_sampen_raw_180, sd_sampen_raw_240, sd_sampen_raw_300, sd_sampen_raw_360, sd_sampen_raw_420, sd_sampen_raw_480, sd_sampen_raw_540),
  duration = c(30, 60, 120, 180, 240, 300, 360, 420, 480, 540)
)

########### make a line plot of sample entropy and duration ######################
p<-ggplot(df_mean_sampen_raw, aes(x=duration, y =mean_sampen))+
  geom_line()+
  geom_point()+
  labs(x="Duration of MEG recording (s)", y = "Mean sample entropy", title = "Mean sample entropy vs duration of MEG recording")+
  theme(panel.background = element_blank(),plot.title=element_text(face="bold"), panel.grid = element_line(color = "Snow2"), axis.line=element_line(colour="black"))

################## Publish a plot and save it #####################################
# save the mean sampen table so that we don't have to make it again 
write.csv(df_mean_sampen_raw, file = "/Path/to/output/dir/df_means_sampen_raw.csv", row.names=FALSE)

# change the color of the plot line
ggsave(filename= "/Path/to/output/dir/eFigure1_Sep2025.tiff", plot= p, width = 17, height = 10, dpi = 300, units = "cm")
