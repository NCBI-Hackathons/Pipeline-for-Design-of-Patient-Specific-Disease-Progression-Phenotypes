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

**Google Slides Presentation:** https://docs.google.com/presentation/d/1rgI67trHcSXJcJbRBbchXeuBXlhqQlZ6WP7-EDR2Whc/edit?usp=sharing


## Proposed Workflow
![Workflow](https://lh3.googleusercontent.com/V5h84_WXJe8B_hYPm973EExppo9l9d8DijUXUWqS9KpesxVg77JoxQVYwOvY8He-J04qSuVssaA "Workflow")


**Dataset Breakdown:**
-   441 PPMI samples: clinical/phenotype + genotype data (to be used in Goal 1+2)
-   ABC Health data: clinical/phenotype + genotype (to be used in Goal 3+2)

## Requirements

### Environment Requirements 
...

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
