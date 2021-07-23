#======================= Univariate Mean Activation ======================#
#-------------- LH --------------#
rlm_model <- rlm(univariateMean_L ~ age0z2, 
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect?
f.robftest(rlm_model, var="age0z21") #linear
f.robftest(rlm_model, var="age0z22") #quadratic

p <- ggplot(df, aes(x = age, y = univariateMean_L)) +
  geom_point(shape = 21, size = 3, colour = "indianred2", fill = "lightpink", stroke = 2)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
#formatting
p <- p + 
  ylim(-1,2.002) +
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

p <- ggplot(df, aes(x = age, y = univariateMean_R)) +
  geom_point(shape = 21, size = 3, colour = "indianred2", fill = "lightpink", stroke = 2)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
#formatting
p <- p + 
  ylim(-1,2.002) +
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