### hackathon

library(lme4)
library(lmerTest)
library(dplyr)
library(hydroGOF)
library(rlist)
library(knitr)

getwd()
db <- available.packages()
deps <- tools::package_dependencies("rlist", db)$rlist
install.packages(deps)

# remove anyone that has less than 3? time

tbl <- read.table("~/Documents/ppmi_hackathon_data.txt", header = T)

# probably need to scale everything
### to do - automatically scale all provided covariates

tbl_scaled <- tbl

tbl_scaled$TSTART <- scale(tbl_scaled$TSTART, center = F)
tbl_scaled$YEARSEDUC <- scale(tbl_scaled$YEARSEDUC, center = F)
tbl_scaled$AAO <- scale(tbl_scaled$AAO, center = F)


# put in model
### to do - automatically put in correct phenotype of choice and covariates
### to do - stepwise selection of covariates for best model

updrs3_slope <- lmer(UPDRS3_scaled ~  AGONIST + DOPA + FEMALE + YEARSEDUC + AAO + (TSTART|ID), tbl_scaled, REML = T)


summary(updrs3_slope)



# Experimental
## TODO: Try to get the stepwise function working on the model
# Backwards elimination of random and fixed effects of the model 
# Backward elimination using terms with default alpha-levels:

(step_res <- step(updrs3_slope, reduce.random = FALSE))
back_elim_updrs3_model <- get_model(step_res)
anova(back_elim_updrs3_model)


# get parameters from selection for 70/30 split below
coefs <- as.data.frame(summary(back_elim_updrs3_model)$coefficients)
coefs <- coefs[2:nrow(coefs),]
covariates_back <- rownames(coefs)
covariates_back <- list.append(covariates_back, "(TSTART|ID)")

# get covariance matrices

full_cov <- as.matrix(summary(updrs3_slope)$vcov)
full_cov <- as.data.frame(full_cov)

back_cov <- as.matrix(summary(back_elim_updrs3_model)$vcov)
back_cov <- as.data.frame(back_cov)

##### test and training set RMSE
### RMSE for full model provided by user and for stepwise model

# get unique patient IDs

ID_list <- unique(tbl$ID)

train_list <- sample(ID_list, round(0.7 * (length(ID_list))), replace = F)

test_list <- setdiff(ID_list, train_list)

# make datasets 

train_set <- tbl_scaled[tbl_scaled$ID %in% train_list,]

test_set <- tbl_scaled[tbl_scaled$ID %in% test_list,]


# full model provided by user

model_test_full <- lmer(UPDRS3_scaled ~  AGONIST + DOPA + FEMALE + YEARSEDUC + AAO + (TSTART|ID), train_set, REML = T)

predicted_full <- predict(model_test_full, test_set, allow.new.levels=TRUE)

RMSE <- rmse(predicted_full, test_set[["UPDRS3_scaled"]])

# backward selection model


model_test_back <- lmer(as.formula(paste("UPDRS3_scaled~", paste(covariates_back, collapse="+"))), train_set, REML = T)

predicted_back <- predict(model_test_back, test_set, allow.new.levels=TRUE)


RMSE_back <- rmse(predicted_back, test_set[["UPDRS3_scaled"]])



### make error table

testing_error <- data.frame("RMSE_full_model" = numeric(1), "RMSE_selected_model" = numeric(1))
testing_error$RMSE_full_model <- RMSE
testing_error$RMSE_selected_model <- RMSE_back

#### error codes and fixes





fm1.all <- allFit(updrs3_slope)
ss <- summary(fm1.all)
ss$ fixef               ## fixed effects
ss$ llik                ## log-likelihoods
ss$ sdcor               ## SDs and correlations
ss$ theta               ## Cholesky factors
ss$ which.OK  




# get specific slopes

raneffect_updrs3 <- as.data.frame(ranef(updrs3_slope)$ID)

raneffect_updrs3$`(Intercept)` <- NULL

raneffect_updrs3$ID <- rownames(raneffect_updrs3)

plot(density(raneffect_updrs3$TSTART))

### should we normalize?

### to do - output metrics of model fit, maybe AUC plots etc

# output patient slopes
## to do - make output go to location specified by user

write.table(raneffect_updrs3, "patient_slopes.txt",  sep = "\t", append = F, row.names = F, quote = F, col.names = T)

### to do - make error message output if model fails to converge 

## make 2 separate outputs - correlaton matrix for full and back model
full_cov_kable <- kable(full_cov)
write(full_cov_kable, "full_model_cov.txt")


back_cov_kable <- kable(back_cov)
write(back_cov_kable, "back_model_cov.txt")

## - rmse for full and back model

error_kable <- kable(testing_error)
write(error_kable, "back_model_cov.txt")



