# **Pipeline for Design of Patient-Specific Disease Progression Phenotypes**

- **Project:** Women-Led Hackathon 
	- **Author(s):** Hampton Leonard, Ruth Chia, Sara Bandres-Ciga, Monica Diez-Fairen, and Mary B. Makarious 
	- **PI:** --
	- **Date Written:** 08.05.2019
	- **Date Last Updated:** 10.05.2019
	- **Collaborators:** Hirotaka Iwaki

## Description + Objective
**Motivation:**
Most models do not take in longitudinal data in a straightforward manner - many will require tweaking in the actual code. To the best of our knowledge there isn’t a model or code that will create a proxy/snapshot of patient-specific derived phenotype from longitudinal data that can be easily plugged in to different types of association analyses. The overall contribution of genetic factors to the severity and progression of diseases has not been well studied. This would be helpful to stratify etiological subtypes of disease and provide new insights for future clinical trials.

**Overview:** 
We will be taking in deeply phenotyped information with more than two longitudinal time points in conjunction with genotypic information. Each time point is a check up. First, using linear mixed modelling (LMM), we will be able to input multiple time points per patient, and be able to develop a single representation of the disease progression that is patient-specific. The pipeline will be generalizable: Will take in a dataset, preprocess it, scale it accordingly, determine the number of covariates, plot AUC, and output a desired outcome that is clinically relevant to your data. The intention is to apply this approach to a wide range of diseases, and eventually compare different modeling techniques to get the best outcome. This project aims to make it easier to find traits significantly associated with progression in a disease-specific manner while giving patients a personalized snapshot of how they will progress based on how they have been progressing thus far to use for downstream analyses such as GWAS and different ML projects.

**Objectives:** 
-   To take in multiple different time points associated with a disease
-   Preprocess, clean, scale, and generate principle components for given covariates
-   Output a single representation associated with disease progression

**Goals:**
1.  Pipeline to model progression phenotypes  
2.  Testing phenotypes
	- To test the association between genetic variants and the phenotype-derived feature of disease on a genome-wide scale
3. Testing in different diseases to validate pipeline
4. Apply different models to compare performance of phenotype derivation as proxy for longitudinal clinical data

## Roles + Daily Updates 

**Roles:** 
- Lead: Hampton Leonard
- Sys Admin(s): Mary M. and Monica D. 
- Writer(s): Ruth C., Sara BC, Mary M.

**Google Slides Presentation:** [Google Slides Link](https://docs.google.com/presentation/d/1rgI67trHcSXJcJbRBbchXeuBXlhqQlZ6WP7-EDR2Whc/edit#slide=id.g59d5fa847a_0_0)


## Proposed Workflow
![Workflow](https://github.com/NCBI-Hackathons/Pipeline-for-Design-of-Patient-Specific-Disease-Progression-Phenotypes/blob/master/Images/Workflow.png "Workflow")


**Dataset Breakdown:**
-   441 PPMI samples: clinical/phenotype + genotype data (to be used in Goal 1+2)
-   ABC Health data: clinical/phenotype + genotype (to be used in Goal 3+2)

## Requirements

### Environment Requirements 
	```bash
	sessionInfo()

	R version 3.5.2 (2018-12-20)
	Platform: x86_64-apple-darwin15.6.0 (64-bit)
	Running under: macOS Mojave 10.14.4

	Matrix products: default
	BLAS: /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib
	LAPACK: /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libRlapack.dylib

	locale:
	[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

	attached base packages:
	[1] stats     graphics  grDevices utils     datasets  methods   base     

	other attached packages:
 	[1] hydroGOF_0.3-10   zoo_1.8-5         rlist_0.4.6.1     knitr_1.21        lmerTest_3.1-0    data.table_1.12.0 RNOmni_0.7.1      lme4_1.1-21       Matrix_1.2-15    
	[10] forcats_0.4.0     stringr_1.4.0     dplyr_0.8.0.1     purrr_0.3.0       readr_1.3.1       tidyr_0.8.2       tibble_2.0.1      ggplot2_3.1.0     tidyverse_1.2.1  

	loaded via a namespace (and not attached):
 	[1] Rcpp_1.0.0         lubridate_1.7.4    lattice_0.20-38    FNN_1.1.3          class_7.3-15       assertthat_0.2.0   gstat_2.0-1        R6_2.4.0           cellranger_1.1.0  
	[10] plyr_1.8.4         backports_1.1.3    e1071_1.7-1        highr_0.7          httr_1.4.0         pillar_1.3.1       rlang_0.3.1        lazyeval_0.2.1     readxl_1.3.0      
	[19] rstudioapi_0.9.0   minqa_1.2.4        nloptr_1.2.1       labeling_0.3       splines_3.5.2      foreign_0.8-71     automap_1.0-14     munsell_0.5.0      broom_0.5.1       
	[28] compiler_3.5.2     numDeriv_2016.8-1  modelr_0.1.4       xfun_0.4           pkgconfig_2.0.2    hydroTSM_0.5-1     tidyselect_0.2.5   intervals_0.15.1   reshape_0.8.8     
	[37] spacetime_1.2-2    crayon_1.3.4       withr_2.1.2        MASS_7.3-51.1      grid_3.5.2         nlme_3.1-137       jsonlite_1.6       gtable_0.2.0       magrittr_1.5      
	[46] scales_1.0.0       cli_1.0.1          stringi_1.3.1      sp_1.3-1           xml2_1.2.0         xts_0.11-2         generics_0.0.2     boot_1.3-20        tools_3.5.2       
	[55] glue_1.3.0         hms_0.4.2          colorspace_1.4-0   BiocManager_1.30.4 maptools_0.9-5     rvest_0.3.2        haven_2.1.0       

	```

### Data Input Requirements
1.  Deep longitudinal phenotype data
	- Give info for the accepted format/data structure (this includes PCs if available)
	- Avoid missing data in the input file 
		- Formatting should match the example below:
	```bash
	# Format
	ID 	TIME_SERIES	PHENOTYPE_OF_INTEREST	COV1 COV2	COV3 etc..
	
	# PPMI Example
	ID	TSTART	UPDRS3	FEMALE  YEARSEDUC  AAO  DOPA  AGONIST 
	100	61	12	0	16	63	0	0
	```	

2.  Covariate file list
	- Format required: one covariate name per line in a .txt file (this is case sensitive!)
		 - Formatting should match the example below:
	```bash
	# Format
	COV1
	COV2
	COV3
	PC1
	PC2
	PC3
	
	# PPMI Example
	DOPA
	AGONIST
	FEMALE
	```	

	
### Data Format
1. Phenotype file
2. Covariate list
	- Text file with one covariate per row for every covariate you want to include in the modeling
	





## Output
### Data Output
