# cortical-entropy-epilepsy
This project contains R and MATLAB scripts for computing multiscale sample entropy from source localized MEG time-series signal. 
The MEG data was obtained from patients with epilepsy who underwent surgical resection for removal of epileptogenic (seizure producing) zone, and had an Engel I outcome (complete seizure freedom) post-surgery. 

Written and maintained by [Kirandeep Kaur](https://github.com/kkauraiims) and Caroline Witton.

We are grateful to the CNNP Lab, Newcastle University, under whose aegis the resection masks and source-localised MEG data used in this 
project were developed.

## Manuscript & Citation
If you use these scripts please cite: 
```text
Kaur, K., O’Brien-Cairney, J., Singh, G., Upadhya, M., Chakraborty, A., Chandra, S. P., Prüss, H., Kornau, H.-C., Schmitz, D., Woodhall, G.,
Rosch, R., Angelova, M., Seri, S., Tripathi, M., Wright, S. K., & Witton, C. (2025). Entropy of the resting state cortex in epilepsy.
bioRxiv. https://doi.org/10.1101/2025.10.02.680016
```
## Workflow
1. Compute sample entropy from source-localised MEG scout/ROI time-series.
2. Assess stability of mean sample entropy estimates across recording durations (30s-600s).
3. Derive subject-wise entropy summary metrics.
4. Test exploratory associations between entropy metrics and clinical variables.
5. Build a backward stepwise regression model for clinical predictors of mean sample entropy.
6. Test the partial correlation between subject-level mean sample entropy and age of epilepsy onset, after adjusting for age at MEG scan.

The R scripts also contain the code used to generate the figures reported in the manuscript.






