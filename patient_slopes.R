### hackathon

library(lme4)


tbl <- read.table("ppmi_hackathon_data.txt", header = T)

# probably need to scale everything
### to do - automatically scale all provided covariates

tbl_scaled <- tbl

tbl_scaled$TSTART <- scale(tbl_scaled$TSTART, center = F)
tbl_scaled$YEARSEDUC <- scale(tbl_scaled$YEARSEDUC, center = F)
tbl_scaled$AAO <- scale(tbl_scaled$AAO, center = F)


# put in model
### to do - automatically put in correct phenotype of choice and covariates
### to do - stepwise selection of covariates for best model

updrs3_slope <- lmer(UPDRS3_scaled ~ FEMALE + YEARSEDUC + AAO + (TSTART|ID), tbl_scaled, REML = T)

summary(updrs3_slope)

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





