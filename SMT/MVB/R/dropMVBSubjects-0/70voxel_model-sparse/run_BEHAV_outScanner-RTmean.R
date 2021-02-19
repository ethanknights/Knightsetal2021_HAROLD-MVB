#======================= BEHAVIOUR OUT-SCANNER ======================#
#----- RT MEAN -----%
rlm_model <- rlm(outScanner_RTmean ~ age0z2, 
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect?
f.robftest(rlm_model, var="age0z21") #linear
f.robftest(rlm_model, var="age0z22") #quadratic

#Plot
p <- ggplot(df, aes(x = age, y = outScanner_RTmean))
p <- p + geom_point(shape = 21, size = 3, colour = "black", fill = "white", stroke = 2)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
#formatting
p <- p + 
  ylim(0,1000) +
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
ggsave(file.path(outImageDir,"RTmean~Age_outScanner.png"),
       width = 25, height = 25, units = 'cm', dpi = 300); p


#----------------------- RT ~ AGE + RH ACTIVATION ----------------------#
#------ Full Multiple Regression -------#
rlm_model <- rlm(outScanner_RTmean ~ univariateMean_R_0z * age0z2,
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

full <-           lmBF(outScanner_RTmean ~ univariateMean_R_0z * age0z, data = df)
noInteraction <-  lmBF(outScanner_RTmean ~ univariateMean_R_0z + age0z, data = df)
bf10 = full / noInteraction #less than 1 favours models of
bf01 = 1/bf10; bf01
# onlyActivation  <- lmBF(outScanner_RTmean ~ univariateMean_R_0z, data=df); onlyActivation
# onlyAge         <- lmBF(outScanner_RTmean ~ age0z2, data=df); onlyAge


#Plot (not standardised for interpretability)
rlm_model <- rlm(outScanner_RTmean ~ univariateMean_R * age,
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
  coord_cartesian(xlim = c(-0.1,0.1) , ylim = c(0,1000), expand = TRUE)
ggsave(file.path(outImageDir,"RTmean~RHBYAge_outScanner.png"),
       width = 25, height = 25, units = 'cm', dpi = 300); p







