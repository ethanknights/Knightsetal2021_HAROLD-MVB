#======================= Univariate Mean Activation ======================#
#-------------- LH --------------#
rlm_model <- rlm(univariateMean_L ~ age0z2, 
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect? 
f.robftest(rlm_model, var="age0z21") #linear
f.robftest(rlm_model, var="age0z22") #quadratic

#Effect Sizes: report linear and quadratic (regression coefficient) from rml - Linear and quad column
fprintf("Linear Age rlm beta = %f\n",signif(rlm_model$coefficients[2],3))
fprintf("Quadratic Age rlm beta = %f\n",signif(rlm_model$coefficients[3],3))
#Effect Sizes: report linear & quadratic r value from fes (squared i.e. r2) - Effect column #IF t stat, before fes, square the t stat that is equivalent to f value (if there's only 1 predictor))
f = f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect?
f2 = fes(f$statistic, 2, 78, level = 95, cer = 0.2, dig = 2, verbose = TRUE, id=NULL, data=NULL)
R2 = (f2$r ^ 2) * 100 #R2 as percentage
fprintf("AgeEffect (F) rlm R2 (as percentage) = %f\n",signif(R2,3))

p <- ggplot(df, aes(x = age, y = univariateMean_L)) +
  geom_point(shape = 21, size = 3, colour = "indianred2", fill = "lightpink", stroke = 2)
p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
#formatting
p <- p + 
  ylim(-2,4.1) +
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
ggsave(file.path(outImageDir,'univariateMean_LH.png'),
       width = 25, height = 25, units = 'cm', dpi = 300); p



#-------------- RH --------------#
rlm_model <- rlm(univariateMean_R ~ age0z2, 
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect? 
f.robftest(rlm_model, var="age0z21") #linear
f.robftest(rlm_model, var="age0z22") #quadratic

#Effect Sizes: report linear and quadratic (regression coefficient) from rml - Linear and quad column
fprintf("Linear Age rlm beta = %f\n",signif(rlm_model$coefficients[2],3))
fprintf("Quadratic Age rlm beta = %f\n",signif(rlm_model$coefficients[3],3))
#Effect Sizes: report linear & quadratic r value from fes (squared i.e. r2) - Effect column #IF t stat, before fes, square the t stat that is equivalent to f value (if there's only 1 predictor))
f = f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect?
f2 = fes(f$statistic, 2, 78, level = 95, cer = 0.2, dig = 2, verbose = TRUE, id=NULL, data=NULL)
R2 = (f2$r ^ 2) * 100 #R2 as percentage
fprintf("AgeEffect (F) rlm R2 (as percentage) = %f\n",signif(R2,3))

p <- ggplot(df, aes(x = age, y = univariateMean_R)) +
  geom_point(shape = 21, size = 3, colour = "indianred2", fill = "lightpink", stroke = 2)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
#formatting
p <- p + 
  ylim(-2,4.1) +
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
ggsave(file.path(outImageDir,'univariateMean_RH.png'),
       width = 25, height = 25, units = 'cm', dpi = 300); p


