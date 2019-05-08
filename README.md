# **Pipeline for Design of Patient-Specific Disease Progression Phenotypes**

- **Project:** Women-Led Hackathon 
	- **Author(s):** Hampton Leonard, Ruth Chia, Sara Bandres-Ciga, Monica Diez-Fairen, and Mary B. Makarious 
	- **PI:** --
	- **Date Written:** 08.05.2019
	- **Date Last Updated:** dd.mm.yyyy
	- **Collaborators:** Hirotaka Iwaki

## Description + Objective
**Motivation:** 
Most models do not take in longitudinal data in a straightforward manner - many will require tweaking in the actual code. To the best of our knowledge there isn’t a model or code that will create a proxy/snapshot of patient specific derived phenotype from longitudinal data that can be easily plugged in to different types of association analyses.
The overall contribution of genetic factors to the severity and progression of diseases has not been well studied. This would be helpful to stratify etiological subtypes of disease and provide new insights for future clinical trials.
Association with disease progression (single representation multiple time points)
Easier to find traits significantly associated with progression
Snapshot of a person to use for downstream analyses such as GWAS and ML projects

**Overview:** 
Make phenotypes for progression 
Using LMM 
PD related 
Take commands, take arguments, results, plots AUC
Outliers 
different diseases/models
Cases that were misdiagnosed were removed 

**Objective:** 
Creating a mock dataset for testing purposes 

**Dataset Breakdown:**
- 441 PPMI patients 
- 

## Roles + Daily Updates 

**Presentation:** https://docs.google.com/presentation/d/1rgI67trHcSXJcJbRBbchXeuBXlhqQlZ6WP7-EDR2Whc/edit?usp=sharing

**Roles:** 
- Lead: Hampton Leonard
- Sys Admin(s): Mary M. and Monica D. 
- Writer(s): Ruth C. and Sara BC

**Goals:**
- Realistic Goal: Apply linear mixed model with deep phenotyped Parkinson's Disease data to model progression that is patient specific 
- Reach Goal: To apply pipeline to other diseases and compare other models to determine the best framework for creating patient-specific slopes

## Proposed Workflow
![Flowchart](https://lh3.googleusercontent.com/fzTpiZlDceGy1ybiHlHBu5ve-qSJ36SB1X4HRxjQIOMysDlzD7eTAI8z6NmEvXoOmJp7WCQwz20 "Flowchart")

## Files 
