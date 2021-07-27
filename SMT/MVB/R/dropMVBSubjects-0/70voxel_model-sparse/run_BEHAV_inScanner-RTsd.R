#======================= BEHAVIOUR IN-SCANNER ======================#
#----- RT VARIABILITY -----%
rlm_model <- rlm(inScanner_RTsd ~ age0z2, 
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect?
f.robftest(rlm_model, var="age0z21") #linear
f.robftest(rlm_model, var="age0z22") #quadratic

#Plot
p <- ggplot(df, aes(x = age, y = inScanner_RTsd))
p <- p + geom_point(shape = 21, size = 3, colour = "black", fill = "white", stroke = 2)
p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
#formatting
p <- p + 
  ylim(0,400) +
  scale_x_continuous(breaks = round(seq(20, max(80), by = 20),1),
                     limits = c(15,90)) +
  theme_bw() + 
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.line = 
          element_line(colour = "black",size = 1.5), 
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24))
ggsave(file.path(outImageDir,"RTsd~Age_InScanner.png"),
       width = 25, height = 25, units = 'cm', dpi = 300); p


#----------------------- RT ~ AGE + RH ACTIVATION ----------------------#
#------ Full Multiple Regression -------#
rlm_model <- rlm(inScanner_RTsd ~ univariateMean_R_0z * age0z2,
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("univariateMean_R_0z:age0z21","univariateMean_R_0z:age0z22")) #age effect?
# f.robftest(rlm_model, var="univariateMean_R_0z:age0z21")
# f.robftest(rlm_model, var="univariateMean_R_0z:age0z22")
#Other coefficients
f.robftest(rlm_model)
f.robftest(rlm_model, var="univariateMean_R_0z")
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect?
f.robftest(rlm_model, var="age0z21")
f.robftest(rlm_model, var="age0z22")

#-------------- Get bayes factors --------------#
summary(rlm_model) #reminder!!

full <-           lmBF(inScanner_RTsd ~ univariateMean_R_0z * age0z, data = df)
noInteraction <-  lmBF(inScanner_RTsd ~ univariateMean_R_0z + age0z, data = df)
bf10 = full / noInteraction #less than 1 favours models of 
bf01 = 1/bf10; bf01
# onlyActivation  <- lmBF(inScanner_RTsd ~ univariateMean_R_0z, data=df); onlyActivation
# onlyAge         <- lmBF(inScanner_RTsd ~ age0z2, data=df); onlyAge

#------ Effect Sizes ------#
#Repeat rlm after standardising all variables
rlm_model <- rlm(scale(inScanner_RTsd) ~ scale(univariateMean_R_0z) * age0z2,
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
#Effect Sizes: report linear and quadratic (regression coefficient) from rml - Linear and quad column
fprintf("Linear Age rlm beta = %f\n",signif(rlm_model$coefficients[3],3))
fprintf("Quadratic Age rlm beta = %f\n",signif(rlm_model$coefficients[4],3))
fprintf("Ipsilateral rlm beta = %f\n",signif(rlm_model$coefficients[2],3))
#Effect Sizes: Full Behavioural Model R2 from fes (squared i.e. r2) - Effect column #IF t stat, before fes, square the t stat that is equivalent to f value (if there's only 1 predictor))
f = f.robftest(rlm_model)
f2 = fes(f$statistic, 5, 580, level = 95, cer = 0.2, dig = 2, verbose = TRUE, id=NULL, data=NULL)
R2 = (f2$r ^ 2) * 100 #R2 as percentage
fprintf("FullModel (F) rlm R2 (as percentage) = %f\n",signif(R2,3))
#Effect Sizes: Age Effects: from fes (squared i.e. r2) - Effect column #IF t stat, before fes, square the t stat that is equivalent to f value (if there's only 1 predictor))
f = f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect?
f2 = fes(f$statistic, 2, 580, level = 95, cer = 0.2, dig = 2, verbose = TRUE, id=NULL, data=NULL)
R2 = (f2$r ^ 2) * 100 #R2 as percentage
fprintf("AgeEffect (F) rlm R2 (as percentage) = %f\n",signif(R2,3))
#Effect Sizes: Age * Ipsilateral interaction: from fes (squared i.e. r2) - Effect column #IF t stat, before fes, square the t stat that is equivalent to f value (if there's only 1 predictor))
f = f.robftest(rlm_model, var=c("scale(univariateMean_R_0z):age0z21","scale(univariateMean_R_0z):age0z22")) #age effect?
f2 = fes(f$statistic, 2, 580, level = 95, cer = 0.2, dig = 2, verbose = TRUE, id=NULL, data=NULL)
R2 = (f2$r ^ 2) * 100 #R2 as percentage
fprintf("Age*Ipsilateral Interaction (F) rlm R2 (as percentage) = %f\n",signif(R2,3))

#------ Plot (not standardised for interpretability) ------#
rlm_model <- rlm(inScanner_RTsd ~ univariateMean_R * age,
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("univariateMean_R:age")) 

p = plot_model(rlm_model, type = "pred", terms = c("univariateMean_R", "age [43, 64, 88]")) # vTert
#formatting
p <- p + 
  # ylim(0,150) +
  # xlim(-0.05,0.05) +
  # scale_x_continuous(breaks = round(seq(20, max(80), by = 20),1),
  #                    limits = c(15,90)) +
  theme_bw() + 
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.line = 
          element_line(colour = "black",size = 1.5), 
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24)) +
  coord_cartesian(xlim = c(-1,1) , ylim = c(0,350), expand = TRUE)
ggsave(file.path(outImageDir,"RTsd~RHBYAge_inScanner.png"),
       width = 25, height = 25, units = 'cm', dpi = 300); p