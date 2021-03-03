#=========================================================================#
#============================== MVPA ANALYSIS ============================#
#=========================================================================#

#---- Transform some stuff ----#
#decAcc to percentage
df$MVPA_L_4way = df$MVPA_L_4way*100
df$MVPA_R_4way = df$MVPA_R_4way*100
df$MVPA_Bi_4way = df$MVPA_Bi_4way*100

#------------------------ DECODING ACCURACY VS CHANCE ------------------------#
#-- LH vs chance --#
ggdensity(df$MVPA_L_4way, xlab = "Decoding Accuracy (%)")
ggqqplot(df$MVPA_L_4way)
t.test(df$MVPA_L_4way, alternative = "greater", mu = 0.25)
#non-parametic
# shapiro.test(df$MVPA_L_4way)
# wilcox.test(df$MVPA_L_4way, alternative = "greater", mu = 0.25)

#-- RH vs chance --#
ggdensity(df$MVPA_R_4way, xlab = "Decoding Accuracy (%)")
ggqqplot(df$MVPA_R_4way)
t.test(df$MVPA_R_4way, alternative = "greater", mu = 0.25)
#non-parametic
# shapiro.test(df$MVPA_R_4way)
# wilcox.test(df$MVPA_R_4way, alternative = "greater", mu = 0.25)

#-- Bilateral vs chance --#
ggdensity(df$MVPA_Bi_4way, xlab = "Decoding Accuracy (%)")
ggqqplot(df$MVPA_Bi_4way)
t.test(df$MVPA_Bi_4way, alternative = "greater", mu = 0.25)
#non-parametic
# shapiro.test(df$MVPA_Bi_4way)
# wilcox.test(df$MVPA_Bi_4way, alternative = "greater", mu = 0.25)



#--------- PLOT decAcc vs, Chance ---------#
se <- function(x) sqrt(var(x)/length(x))*2 #2 SE +/-

df2 <- data.frame(
  decAccMean = c(mean(df$MVPA_L_4way),mean(df$MVPA_R_4way),mean(df$MVPA_Bi_4way)),
  decAccSE = c(se(df$MVPA_L_4way),se(df$MVPA_R_4way),se(df$MVPA_Bi_4way)),
  ROI = c('L_80','R_80','Bi_160'),
  ROIorder = factor(c(1,2,3))
)

#-- Bar graph (mean decAcc (balanced) with error bars (SE +/-2) --#
p <- ggplot(df2) +
  geom_bar(aes(x=ROIorder, y=decAccMean, fill = ROIorder),
           stat="identity", colour = 'black', alpha=1, size = 1, width = 0.8) +
  scale_fill_manual(values = c("white", "white", "white","grey","grey")) +

  geom_errorbar(aes(x=ROIorder, ymin = decAccMean - decAccSE, ymax = decAccMean + decAccSE), 
                width=0.3, colour="black", alpha=0.7, size=0.7) + 
  scale_x_discrete(labels = df2$ROI) +
  geom_hline(yintercept = 25, linetype = "longdash", color = 'black', size = 0.5) + #chance
  theme_bw() + 
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.line = 
          element_line(colour = "black",size = 1), 
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=12)) +
  coord_cartesian(xlim = c(-0.05,4) , ylim = c(0,35), expand = FALSE)
print(p)

ggsave(file.path(outImageDir,'decAcc_chance.png'), plot = p,
       width = 13, height = 8, units = "cm", dpi = 600) #Awful resolution if png()?



#---------- decAcc correlate with age? ---------#
#---LH---#
rlm_model <- rlm(MVPA_L_4way ~ age0z2, 
                data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect? 
# f.robftest(rlm_model, var="age0z21") #linear
# f.robftest(rlm_model, var="age0z22") #quadratic
f.robftest(rlm_model)

rm(p)
png(file.path(outImageDir,'decAcc_Age_LH.png'), width = 500, height = 500)

p <- ggplot(df, aes(x = age, y = MVPA_L_4way))
p <- p + geom_point(shape = 21, size = 3, colour = "indianred2", fill = "lightpink", stroke = 2)
p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
p <- p + geom_hline(yintercept = 25, linetype = "longdash", color = 'black', size = 0.5) #chance
#formatting
p <- p + 
  ylim(0,60) +
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
print(p)

dev.off()


#---RH---#
rlm_model <- rlm(MVPA_R_4way ~ age0z2, 
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect? 
# f.robftest(rlm_model, var="age0z21") #linear
# f.robftest(rlm_model, var="age0z22") #quadratic
f.robftest(rlm_model)

#Plot
rm(p)
png(file.path(outImageDir,'decAcc_Age_RH.png'), width = 500, height = 500)

p <- ggplot(df, aes(x = age, y = MVPA_R_4way))
p <- p + geom_point(shape = 21, size = 3, colour = "indianred2", fill = "lightpink", stroke = 2)
p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
p <- p + geom_hline(yintercept = 25, linetype = "longdash", color = 'black', size = 0.5) #chance
#formatting
p <- p + 
  ylim(0,60) +
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
print(p)

dev.off()


#---------- decAcc Boost correlate with age? --------#
df$MVPA_boost = df$MVPA_Bi_4way - df$MVPA_L_4way

rlm_model <- rlm(MVPA_boost ~ age0z2, 
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect? 
# f.robftest(rlm_model, var="age0z21") #linear
# f.robftest(rlm_model, var="age0z22") #quadratic
f.robftest(rlm_model)

#--- BF METHOD 2 - BayesFactor package ---#
summary(rlm_model) #reminder!!

bf10 <-           lmBF(MVPA_boost ~ age0z, data = df)
bf01 = 1/bf10; bf01


#Plot
rm(p)
png(file.path(outImageDir,'decAccBoost.png'), width = 500, height = 500)

p <- ggplot(df, aes(x = age, y = MVPA_boost))
p <- p + geom_point(shape = 21, size = 3, colour = "indianred2", fill = "lightpink", stroke = 2)
p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
#formatting
p <- p + 
  ylim(-25,25) +
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
print(p)

dev.off()

