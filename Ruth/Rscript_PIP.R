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
             args[3] = PhenotypOfInterest
             args[4] = TimeSeriesColumn
             args[5] = SampleIDcolumn
             args[6] = OutputFileName")
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

pheno <- args[3]
pheno_scaled <- paste(pheno,"scaledFINAL",sep="_")
tbl_scaled[[pheno_scaled]] <- scale(tbl_scaled[[pheno]], center = F)

x <- 1:length(covs$V1)
covariates <- paste0("tbl_scaled[[",covs$V1[x], "_scaled]]",collapse = " + ")

TimeSeriesColumn <- args[4]
TimeSeriesColumn_scaled <- paste(args[4],"scaled",sep="_")
tbl_scaled[[TimeSeriesColumn_scaled]] <-scale(tbl_scaled[[TimeSeriesColumn]], center = F)

## this is not working ....
slope <- substitute(lmer(tbl_scaled[[pheno_scaled]] ~ covariates + (tbl_scaled[[TimeSeriesColumn_scaled]]|ID), tbl_scaled, REML = T))
