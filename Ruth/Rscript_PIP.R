#!/usr/bin/env Rscript
# setwd("~/Desktop/Hackathon/")

require("data.table")
install.packages("lme4")
install.packages("RNOmni")
library(lme4)
library(RNOmni)


# read command line
args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 3) {
  stop("USAGE: Rscript patient_slopes.R inputPhenotypeFile CovariateList OutputFileName
       where args[1] = inputPhenotypeFile
             args[2] = CovariateList
             args[3] = OutputFileName")
}

# Read in input files
tbl <- fread(args[1],header=T)
covs <- fread(args[2],header=F)

# The downstream function when building the model to get the slope require the quantitative covariates to be scaled
### Automatically scale all provided covariates
tbl_scaled <- tbl
for (i in 1:length(covs$V1)) {
  name <- covs$V1[i]
  varname <- paste(covs$V1[i],"scaled",sep="_")
  tbl_scaled[[varname]] <-scale(tbl_scaled[[name]], center = F)
}

# Model 
### to do - automatically put in correct phenotype of choice and covariates
### to do - stepwise selection of covariates for best model

colnames(tbl_scaled)[1] <- "ID"
colnames(tbl_scaled)[2] <- "TimeFromBaseline"
colnames(tbl_scaled)[3] <- "Phenotype"

tbl_scaled$TimeFromBaseline_scaled <- scale(tbl_scaled$TimeFromBaseline, center = F)
tbl_scaled$Phenotype_scaled <- scale(tbl_scaled$Phenotype, center = F)

x <- 1:length(covs$V1)
covariates <- paste0(covs$V1[x], "_scaled",collapse = " + ")

## calculate slope
pheno_slope <- lmer(as.formula(paste("Phenotype_scaled ~ ", paste(covariates, sep=""), "+ (TimeFromBaseline_scaled|ID)")), tbl_scaled, REML = T)
summary(pheno_slope)


