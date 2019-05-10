#!/usr/bin/env Rscript

# read command line
args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {
  stop("USAGE: Rscript patient_slopes.R inputPhenotypeFile CovariateList
       where args[1] = inputPhenotypeFile
       args[2] = CovariateList")
}

# load required packages
if (!require(tidyverse)) install.packages('tidyverse')
if (!require(data.table)) install.packages('data.table')
if (!require(dplyr)) install.packages('dplyr')
if (!require(ggplot2)) install.packages('ggplot2')
if (!require(lme4)) install.packages('lme4')
if (!require(RNOmni)) install.packages('RNOmni')
if (!require(lmerTest)) install.packages('lmerTest')
if (!require(hydroGOF)) install.packages('hydroGOF')
if (!require(rlist)) install.packages('rlist')
if (!require(knitr)) install.packages('knitr')


# Create output directory where result with be written to
system("mkdir output")

# Read in input files
tbl <- fread(args[1],header=T)
covs <- fread(args[2],header=F, stringsAsFactor = F)

# Create user defined variable names from input phenotype data
user_input_ID <- colnames(tbl)[1]
user_input_Time <- colnames(tbl)[2]
user_input_PHENO <- colnames(tbl)[3]

# The downstream function when building the model to get the slope require the quantitative covariates to be scaled
### Automatically scale all provided covariates
tbl_scaled <- tbl
for (i in 1:length(covs$V1)) {
  name <- covs$V1[i]
  varname <- paste(covs$V1[i],"scaled",sep="_")
  tbl_scaled[[varname]] <-scale(tbl_scaled[[name]], center = F)
}

# Modelling with lmer to get patient-specific slopes with user-defined covs or using unbiased step-based selection
### User defined covariates: Automatically put in correct phenotype of choice and covariates
tbl_scaled[[paste(colnames(tbl_scaled)[2],"_scaledFINAL",sep="")]] <- scale(tbl_scaled[[colnames(tbl_scaled)[2]]], center = F)
tbl_scaled[[paste(colnames(tbl_scaled)[3],"_scaledFINAL",sep="")]] <- scale(tbl_scaled[[colnames(tbl_scaled)[3]]], center = F)

x <- 1:length(covs$V1)
covariates <- paste0(covs$V1[x], "_scaled",collapse = " + ")

pheno_slope <- lmer(as.formula(paste(paste(user_input_PHENO,"_scaledFINAL ~ ",sep=""), paste(covariates, sep=""), "+", paste("(",user_input_Time,"_scaledFINAL|",user_input_ID, ")",sep=""))), tbl_scaled, REML = T)
summary(pheno_slope)

## get patient-specific slopes
raneffect_pheno <- as.data.frame(ranef(pheno_slope)[[as.data.frame(ranef(pheno_slope))[1,1]]])
raneffect_pheno$`(Intercept)` <- NULL
raneffect_pheno[[as.data.frame(ranef(pheno_slope))[1,1]]] <- rownames(raneffect_pheno)

# normalization of the time data
raneffect_pheno[[paste(user_input_Time,"_scaledFINAL_NORMALIZED",sep="")]] = rankNorm(raneffect_pheno[[paste(user_input_Time,"_scaledFINAL",sep="")]])
raneffect_pheno <- raneffect_pheno[,c(2,1,3)]

# Visualise patient-specific slopes with density plot
slope_density_plot <- ggplot(raneffect_pheno, aes(x=raneffect_pheno[[colnames(raneffect_pheno)[3]]])) +
  geom_density(color="darkblue", fill="lightblue", alpha=0.4) + 
  theme_bw() +
  ggtitle(paste("Phenotype: ",user_input_PHENO,"\nDensity of Patient Slopes",sep="")) + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  labs(x = paste("Slopes of Patients\nCovariates Used:\n ",paste0(covs$V1[x], "_scaled",collapse = "\n"),sep=""),
       y = "Density") 
## Save the density plot 
ggsave(paste("output/",user_input_PHENO,"_Density_PatientSlopes.png",sep=""), slope_density_plot, width = 3, height = 4.5, units = "in")
# output patient slopes
## Write out table of patient specific slopes 
write.table(raneffect_pheno, paste("output/",user_input_PHENO,"_patient_slopes.txt",sep=""),  sep = "\t", append = F, row.names = F, quote = F, col.names = T)

### Unbiased covariate selection: Stepwise selection of covariates for best model
# Backwards elimination of random and fixed effects of the model 
# Backward elimination using terms with default alpha-levels:
# Keep random effects
# Note: User should not put in more than one random effect 
(step_res <- step(pheno_slope, reduce.random = FALSE))
back_elim_pheno_model <- get_model(step_res)
anova(back_elim_pheno_model)
# Print out summary stats
summary(back_elim_pheno_model)

# get parameters from selection for 70/30 split below
coefs <- as.data.frame(summary(back_elim_pheno_model)$coefficients)
coefs <- coefs[2:nrow(coefs),]
covariates_back <- rownames(coefs)
covariates_back <- list.append(covariates_back, paste("(",user_input_Time,"_scaledFINAL|",user_input_ID, ")",sep=""))

# get covariance matrices
full_cov <- as.matrix(summary(pheno_slope)$vcov)
full_cov <- as.data.frame(full_cov)

back_cov <- as.matrix(summary(back_elim_pheno_model)$vcov)
back_cov <- as.data.frame(back_cov)

##### test and training set RMSE
### RMSE for full model provided by user and for stepwise model

# get unique patient IDs
ID_list <- unique(tbl[[colnames(tbl)[1]]])
train_list <- sample(ID_list, round(0.7 * (length(ID_list))), replace = F)
test_list <- setdiff(ID_list, train_list)

# make datasets 
train_set <- tbl_scaled[tbl_scaled[[colnames(tbl)[1]]] %in% train_list,]
test_set <- tbl_scaled[tbl_scaled[[colnames(tbl)[1]]] %in% test_list,]

# full model provided by user
model_test_full <- lmer(as.formula(paste(paste(user_input_PHENO,"_scaledFINAL ~ ",sep=""), paste(covariates, sep=""), "+", paste("(",user_input_Time,"_scaledFINAL|",user_input_ID, ")",sep=""))), tbl_scaled, REML = T)
predicted_full <- predict(model_test_full, test_set, allow.new.levels=TRUE)
RMSE <- rmse(predicted_full, test_set[[paste(user_input_PHENO,"_scaledFINAL",sep="")]])

# backward selection model
model_test_back <- lmer(as.formula(paste(paste(user_input_PHENO,"_scaledFINAL ~ ",sep=""), paste(covariates_back, collapse="+"))), train_set, REML = T)
predicted_back <- predict(model_test_back, test_set, allow.new.levels=TRUE)
RMSE_back <- rmse(predicted_back, test_set[[paste(user_input_PHENO,"_scaledFINAL",sep="")]])

### make error table
testing_error <- data.frame("RMSE_full_model" = numeric(1), "RMSE_selected_model" = numeric(1))
testing_error$RMSE_full_model <- RMSE
testing_error$RMSE_selected_model <- RMSE_back



### to do - make error message output if model fails to converge 

## make 2 separate outputs - correlaton matrix for full and back model
full_cov_kable <- kable(full_cov)
write(full_cov_kable, paste("output/",user_input_PHENO,"_full_model_cov.txt",sep=""))

back_cov_kable <- kable(back_cov)
write(back_cov_kable, paste("output/",user_input_PHENO,"_back_model_cov.txt",sep=""))

## - rmse for full and back model
error_kable <- kable(testing_error)
write(error_kable, paste("output/",user_input_PHENO,"_error_back_model_cov.txt",sep=""))
