#======================= BEHAVIOUR IN-SCANNER ======================#
#---- MR 1: RT ~ LH * RH ----#
rlm_model <- rlm(inScanner_RTmean ~ univariateMean_L_0z * univariateMean_R_0z,
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var="univariateMean_L_0z:univariateMean_R_0z")
f.robftest(rlm_model)
f.robftest(rlm_model, var="univariateMean_L_0z")
f.robftest(rlm_model, var="univariateMean_R_0z")
full <-           lmBF(inScanner_RTmean ~ univariateMean_L_0z * univariateMean_R_0z, data = df)
noInteraction <-  lmBF(inScanner_RTmean ~ univariateMean_L_0z + univariateMean_R_0z, data = df)
bf10 = full / noInteraction #less than 1 favours models of 
bf01 = 1/bf10; bf01
#Plot (not standardised for interpretability)
rlm_model <- rlm(inScanner_RTmean ~ univariateMean_L * univariateMean_R,
                 data = df, psi = psi.huber, k = 1.345)
p = plot_model(rlm_model, type = "pred", terms = c("univariateMean_R", "univariateMean_L")) # vTert


#---- MR 2: RT ~ LH * RH * age ----#
rlm_model <- rlm(inScanner_RTmean ~ univariateMean_L_0z * univariateMean_R_0z * age0z2,
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model)
f.robftest(rlm_model, var=c("univariateMean_R_0z:age0z21","univariateMean_R_0z:age0z22"))
full <-           lmBF(inScanner_RTmean ~ univariateMean_L_0z + univariateMean_R_0z * age0z, data = df)
noInteraction <-  lmBF(inScanner_RTmean ~ univariateMean_L_0z + univariateMean_R_0z + age0z, data = df)
bf10 = full / noInteraction #less than 1 favours models of 
bf01 = 1/bf10; bf01

