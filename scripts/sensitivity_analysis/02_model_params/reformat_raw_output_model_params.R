###### For each of the model params: 
## 1. Extract the column means 
## 2. convert this into a 2x32 table 
## 3. Join each df such that we get a 32x9 array of values 

### input = 114 x 32 array, where each row is roi and each col is subject

subject_ids <- colnames (sampenr_m2_r15[,-1])

# sampenr_m2_r15
mean_sampen_m2_r15 <- colMeans(sampenr_m2_r15[,-1, drop= FALSE])
identical(subject_ids, names(mean_sampen_m2_r15))

df_m2_r15 <- data.frame (subject_ids, mean_sampen_m2_r15= unname(mean_sampen_m2_r15))

# sampenr_m2_r2
mean_sampen_m2_r2<- colMeans(sampenr_m2_r2[,-1, drop= FALSE])
identical(subject_ids, names(mean_sampen_m2_r2))

df_m2_r2 <- data.frame (subject_ids, mean_sampen_m2_r2= unname(mean_sampen_m2_r2))

# sampenr_m2_r25
mean_sampen_m2_r25<- colMeans(sampenr_m2_r25[,-1, drop= FALSE])
identical(subject_ids, names(mean_sampen_m2_r25))

df_m2_r25 <- data.frame (subject_ids, mean_sampen_m2_r25= unname(mean_sampen_m2_r25))

##############################################################################

# sampenr_m3_r15
mean_sampen_m3_r15 <- colMeans(sampenr_m3_r15[,-1, drop= FALSE])
identical(subject_ids, names(mean_sampen_m3_r15))

df_m3_r15 <- data.frame (subject_ids, mean_sampen_m3_r15= unname(mean_sampen_m3_r15))

# sampenr_m3_r2
mean_sampen_m3_r2<- colMeans(sampenr_m3_r2[,-1, drop= FALSE])
identical(subject_ids, names(mean_sampen_m3_r2))

df_m3_r2 <- data.frame (subject_ids, mean_sampen_m3_r2= unname(mean_sampen_m3_r2))

# sampenr_m2_r25
mean_sampen_m3_r25<- colMeans(sampenr_m3_r25[,-1, drop= FALSE])
identical(subject_ids, names(mean_sampen_m3_r25))

df_m3_r25 <- data.frame (subject_ids, mean_sampen_m3_r25= unname(mean_sampen_m3_r25))

##############################################################################

# sampenr_m4_r15
mean_sampen_m4_r15 <- colMeans(sampenr_m4_r15[,-1, drop= FALSE])
identical(subject_ids, names(mean_sampen_m4_r15))

df_m4_r15 <- data.frame (subject_ids, mean_sampen_m4_r15= unname(mean_sampen_m4_r15))

# sampenr_m4_r2
mean_sampen_m4_r2<- colMeans(sampenr_m4_r2[,-1, drop= FALSE])
identical(subject_ids, names(mean_sampen_m4_r2))

df_m4_r2 <- data.frame (subject_ids, mean_sampen_m4_r2= unname(mean_sampen_m4_r2))

# sampenr_m4_r25
mean_sampen_m4_r25<- colMeans(sampenr_m4_r25[,-1, drop= FALSE])
identical(subject_ids, names(mean_sampen_m4_r25))

df_m4_r25 <- data.frame (subject_ids, mean_sampen_m4_r25= unname(mean_sampen_m4_r25))


###################################################################################
##### Collapse into a single table 

library(dplyr)

sampen_all <-df_m2_r15 %>% 
  left_join(df_m2_r2, by= "subject_ids") %>%
  left_join(df_m2_r25, by= "subject_ids") %>%
  left_join(df_m3_r15, by= "subject_ids") %>%
  left_join(df_m3_r2, by= "subject_ids") %>% 
  left_join(df_m3_r25, b= "subject_ids") %>%
  left_join(df_m4_r15, by= "subject_ids") %>%
  left_join(df_m4_r2, by= "subject_ids") %>%
  left_join(df_m4_r25, by= "subject_ids")

write.csv(sampen_all, 
          "sampen_all_model_params_240.csv",
          row.names= FALSE)
getwd()


