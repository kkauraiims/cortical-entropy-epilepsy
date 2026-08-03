########### Sensitiviy analysis_ model Params ##############
## Input: A) 32 x 10 table, where: 
## col 1= subject_ids; col2:10 = 9 SE for 9 model params 
## B) age of seizure onset for 32 subjects

## Output = mean_sampen ~ lm(age_of_onset) for each model param

library(dplyr)

sampen_model_params <- sampen_model_params %>%
  inner_join(
    df_sampenr_model %>% select(subject, age_onset),
    by = c("subject_ids" = "subject")
  )

#model_m3_r2 <- lm(mean_sampen_m3_r2~age_onset, data= sampen_model_params)
#summary(model_m3_r2)

se_param_outputs <- grep(
  "^mean_sampen_", 
  names(sampen_model_params), 
  value= TRUE
)

se_param_outputs

models <- lapply(se_param_outputs, function(outcome) {
  formula_i <- reformulate(
    termlabels= "age_onset", 
    response= outcome)
  
  lm(formula_i, data=sampen_model_params)
  } )

names(models) <- se_param_outputs

#################################################################
## Extract the regression results

regression_results <- lapply(names(models), function(outcome) {
  
  fit <- models[[outcome]]
  
  coefficient_table <- summary(fit)$coefficients
  confidence_interval <- confint(fit, "age_onset", level = 0.95)
  
  data.frame(
    parameter = outcome,
    
    beta = coefficient_table[
      "age_onset", "Estimate"
    ],
    
    standard_error = coefficient_table[
      "age_onset", "Std. Error"
    ],
    
    ci_lower = confidence_interval[1],
    ci_upper = confidence_interval[2],
    
    p_value = coefficient_table[
      "age_onset", "Pr(>|t|)"
    ],
    
    n = nobs(fit),
    r_squared = summary(fit)$r.squared
  )
}) %>%
  bind_rows()

regression_results

##########################################################################
#### Create a print ready table 
write.csv(regression_results, "regression_results.csv", row.names=FALSE)
