#!/usr/bin/env Rscript

# read command line
args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 3) {
  stop("USAGE: Rscript patient_slopes.R inputPhenotypeFile CovariateList OutputFileName
       where args[1] = inputPhenotypeFile
             args[2] = CovariateList
             args[3] = OutputFileName")
}

# load required packages
if (!require(tidyverse)) install.packages('tidyverse')
if (!require(data.table)) install.packages('data.table')
if (!require(dplyr)) install.packages('dplyr')
if (!require(ggplot2)) install.packages('ggplot2')
if (!require(lme4)) install.packages('lme4')
if (!require(RNOmni)) install.packages('RNOmni')
if (!require(lmerTest)) install.packages('lmerTest')

# Create output directory where result with be written to
system("mkdir output")

# Read in input files
tbl <- fread(args[1],header=T)
covs <- fread(args[2],header=F)

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

raneffect_pheno[[as.data.frame(ranef(pheno_slope))[1,1]]]
dim(as.data.frame(ranef(pheno_slope)))[1]

# Visualise patient-specific slopes with density plot
slope_density_plot <- ggplot(raneffect_pheno, aes(x=raneffect_pheno[[colnames(raneffect_pheno)[1]]])) +
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

