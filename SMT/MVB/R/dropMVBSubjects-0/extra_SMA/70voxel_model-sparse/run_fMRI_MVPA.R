#=========================================================================#
#============================== MVPA ANALYSIS ============================#
#=========================================================================#
library(ggplot2)
library(MASS)
library(BayesFactor)
library(sfsmisc)

rm(list = ls()) # clears environment
cat("\f") # clears console
dev.off() # clears graphics device
graphics.off() #clear plots


#---- Setup ----#
# wd <- "/imaging/ek03/MVB/FreeSelection/MVB/R"
wd = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(wd)

rawDir = "csv"
outImageDir = 'images'
dir.create(outImageDir)



rawD <- read.csv(sprintf("%s/data.csv",rawDir), header=TRUE,sep=",")
df = rawD

#---- Transform some stuff ----#
#decAcc to percentage
df$L_mvpa_80 = df$L_mvpa_80*100
df$R_mvpa_80 = df$R_mvpa_80*100
df$Bi_mvpa_160 = df$Bi_mvpa_160*100
df$L_mvpa_160 = df$L_mvpa_160*100
df$Bi_mvpa_80 = df$Bi_mvpa_80*100

#Age quadratic expansion
df$age0z2 <- poly(df$age0z,2) #1st linear, 2nd quad


#------------------------ DECODING ACCURACY VS CHANCE ------------------------#

#---80 Voxels---#
#-- LH vs chance --#
ggdensity(df$L_mvpa_80, xlab = "Decoding Accuracy (%)")
ggqqplot(df$L_mvpa_80)
t.test(df$L_mvpa_80, alternative = "greater", mu = 0.25)
#non-parametic
# shapiro.test(df$L_mvpa_80)
# wilcox.test(df$L_mvpa_80, alternative = "greater", mu = 0.25)

#-- RH vs chance --#
ggdensity(df$R_mvpa_80, xlab = "Decoding Accuracy (%)")
ggqqplot(df$R_mvpa_80)
t.test(df$R_mvpa_80, alternative = "greater", mu = 0.25)
#non-parametic
# shapiro.test(df$R_mvpa_80)
# wilcox.test(df$R_mvpa_80, alternative = "greater", mu = 0.25)

#-- Bilateral vs chance --#
ggdensity(df$Bi_mvpa_160, xlab = "Decoding Accuracy (%)")
ggqqplot(df$Bi_mvpa_160)
t.test(df$Bi_mvpa_160, alternative = "greater", mu = 0.25)
#non-parametic
# shapiro.test(df$Bi_mvpa_160)
# wilcox.test(df$Bi_mvpa_160, alternative = "greater", mu = 0.25)


#---CONTROLSs---#
#-- ENLARGE LH vs chance --#
ggdensity(df$L_mvpa_160, xlab = "Decoding Accuracy (%)")
ggqqplot(df$L_mvpa_160)
t.test(df$L_mvpa_160, alternative = "greater", mu = 0.25)
#non-parametic
# shapiro.test(df$L_mvpa_160)
# wilcox.test(df$L_mvpa_160, alternative = "greater", mu = 0.25)

#-- Bilateral vs chance --#
ggdensity(df$Bi_mvpa_80, xlab = "Decoding Accuracy (%)")
ggqqplot(df$Bi_mvpa_80)
t.test(df$Bi_mvpa_80, alternative = "greater", mu = 0.25)
#non-parametic
# shapiro.test(df$Bi_mvpa_80)
# wilcox.test(df$Bi_mvpa_80, alternative = "greater", mu = 0.25)

# #-- RH vs chance --#
# ggdensity(df$R_mvpa_160, xlab = "Decoding Accuracy (%)")
# ggqqplot(df$R_mvpa_160)
# t.test(df$R_mvpa_160, alternative = "greater", mu = 0.25)
# #non-parametic
# # shapiro.test(df$R_mvpa_160)
# # wilcox.test(df$R_mvpa_160, alternative = "greater", mu = 0.25)



#--------- PLOT decAcc vs, Chance ---------#
se <- function(x) sqrt(var(x)/length(x))*2 #2 SE +/-


df2 <- data.frame(
  decAccMean = c(mean(df$L_mvpa_80),mean(df$R_mvpa_80),mean(df$Bi_mvpa_160),
                 mean(df$L_mvpa_160),mean(df$Bi_mvpa_80)),
  decAccSE = c(se(df$L_mvpa_80),se(df$R_mvpa_80),se(df$Bi_mvpa_160),
               se(df$L_mvpa_160),se(df$Bi_mvpa_80)),
  ROI = c('L_80','R_80','Bi_160','L_160','Bi_80'),
  ROIorder = factor(c(1,2,3,4,5))
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
  coord_cartesian(xlim = c(-0.05,6) , ylim = c(0,35), expand = FALSE)
print(p)

ggsave(file.path(outImageDir,'decAcc_chance.png'), plot = p,
       width = 13, height = 8, units = "cm", dpi = 600) #Awful resolution if png()?



#---------- decAcc correlate with age? ---------#
#---LH---#
rlm_model <- rlm(L_mvpa_80 ~ age0z2, 
                data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect? 
# f.robftest(rlm_model, var="age0z21") #linear
# f.robftest(rlm_model, var="age0z22") #quadratic
f.robftest(rlm_model)


#--- BF METHOD 1 - Dienes/Christie - code by John Christie for Dienes calculator ---#
source("bayesFactorCalc2.R")  #download from: http://www.lifesci.sussex.ac.uk/home/Zoltan_Dienes/inference/bayesFactorCalc2.R
coeffVals = data.frame(as.list(rlm_model$coefficients))
coeffSE = data.frame(as.list(coef(summary(rlm_model))[, "Std. Error"]))

#bf01 for null : age linear
obtained = coeffVals$age0z21
sd = coeffSE$age0z21
BF_output <- Bf(sd, obtained, uniform = FALSE, lower=0, upper=1, meanoftheory=0, sdtheory=1, tails=1)
print(1 / BF_output$BayesFactor) #bf01

#bf01 for null : RH * age quadratic
obtained = coeffVals$age0z22
sd = coeffSE$age0z22
BF_output <- Bf(sd, obtained, uniform = FALSE, lower=0, upper=1, meanoftheory=0, sdtheory=1, tails=1)
print(1 / BF_output$BayesFactor) #bf01


#Plot
rm(p)
png(file.path(outImageDir,'decAcc_Age_LH.png'), width = 500, height = 500)

p <- ggplot(df, aes(x = age, y = L_mvpa_80))
p <- p + geom_point(shape = 21, size = 3, colour = "indianred2", fill = "lightpink", stroke = 2)
p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
p <- p + geom_hline(yintercept = 25, linetype = "longdash", color = 'black', size = 0.5) #chance
#formatting
p <- p + 
  ylim(0,50) +
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
rlm_model <- rlm(R_mvpa_80 ~ age0z2, 
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect? 
# f.robftest(rlm_model, var="age0z21") #linear
# f.robftest(rlm_model, var="age0z22") #quadratic
f.robftest(rlm_model)


#--- BF METHOD 1 - Dienes/Christie - code by John Christie for Dienes calculator ---#
source("bayesFactorCalc2.R")  #download from: http://www.lifesci.sussex.ac.uk/home/Zoltan_Dienes/inference/bayesFactorCalc2.R
coeffVals = data.frame(as.list(rlm_model$coefficients))
coeffSE = data.frame(as.list(coef(summary(rlm_model))[, "Std. Error"]))

#bf01 for null : age linear
obtained = coeffVals$age0z21
sd = coeffSE$age0z21
BF_output <- Bf(sd, obtained, uniform = FALSE, lower=0, upper=1, meanoftheory=0, sdtheory=1, tails=1)
print(1 / BF_output$BayesFactor) #bf01

#bf01 for null : RH * age quadratic
obtained = coeffVals$age0z22
sd = coeffSE$age0z22
BF_output <- Bf(sd, obtained, uniform = FALSE, lower=0, upper=1, meanoftheory=0, sdtheory=1, tails=1)
print(1 / BF_output$BayesFactor) #bf01


#Plot
rm(p)
png(file.path(outImageDir,'decAcc_Age_RH.png'), width = 500, height = 500)

p <- ggplot(df, aes(x = age, y = R_mvpa_80))
p <- p + geom_point(shape = 21, size = 3, colour = "indianred2", fill = "lightpink", stroke = 2)
p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
p <- p + geom_hline(yintercept = 25, linetype = "longdash", color = 'black', size = 0.5) #chance
#formatting
p <- p + 
  ylim(0,50) +
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
df$boost = df$Bi_mvpa_160 - df$L_mvpa_80

rlm_model <- rlm(boost ~ age0z2, 
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect? 
# f.robftest(rlm_model, var="age0z21") #linear
# f.robftest(rlm_model, var="age0z22") #quadratic
f.robftest(rlm_model)

#--- BF METHOD 1 - Dienes/Christie - code by John Christie for Dienes calculator ---#
source("bayesFactorCalc2.R")  #download from: http://www.lifesci.sussex.ac.uk/home/Zoltan_Dienes/inference/bayesFactorCalc2.R
coeffVals = data.frame(as.list(rlm_model$coefficients))
coeffSE = data.frame(as.list(coef(summary(rlm_model))[, "Std. Error"]))

#bf01 for null : age linear
obtained = coeffVals$age0z21
sd = coeffSE$age0z21
BF_output <- Bf(sd, obtained, uniform = FALSE, lower=0, upper=1, meanoftheory=0, sdtheory=1, tails=1)
print(1 / BF_output$BayesFactor) #bf01

#bf01 for null : RH * age quadratic
obtained = coeffVals$age0z22
sd = coeffSE$age0z22
BF_output <- Bf(sd, obtained, uniform = FALSE, lower=0, upper=1, meanoftheory=0, sdtheory=1, tails=1)
print(1 / BF_output$BayesFactor) #bf01


#Plot
rm(p)
png(file.path(outImageDir,'decAccBoost.png'), width = 500, height = 500)

p <- ggplot(df, aes(x = age, y = boost))
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



#---------- CONTROL: ENLARGE CONTRALATERAL: decAcc Boost correlate with age? --------#
df$boost = df$Bi_mvpa_160 - df$L_mvpa_160

rlm_model <- rlm(boost ~ age0z2, 
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect? 
# f.robftest(rlm_model, var="age0z21") #linear
# f.robftest(rlm_model, var="age0z22") #quadratic
f.robftest(rlm_model)

#--- BF METHOD 1 - Dienes/Christie - code by John Christie for Dienes calculator ---#
source("bayesFactorCalc2.R")  #download from: http://www.lifesci.sussex.ac.uk/home/Zoltan_Dienes/inference/bayesFactorCalc2.R
coeffVals = data.frame(as.list(rlm_model$coefficients))
coeffSE = data.frame(as.list(coef(summary(rlm_model))[, "Std. Error"]))

#bf01 for null : age linear
obtained = coeffVals$age0z21
sd = coeffSE$age0z21
BF_output <- Bf(sd, obtained, uniform = FALSE, lower=0, upper=1, meanoftheory=0, sdtheory=1, tails=1)
print(1 / BF_output$BayesFactor) #bf01

#bf01 for null : RH * age quadratic
obtained = coeffVals$age0z22
sd = coeffSE$age0z22
BF_output <- Bf(sd, obtained, uniform = FALSE, lower=0, upper=1, meanoftheory=0, sdtheory=1, tails=1)
print(1 / BF_output$BayesFactor) #bf01


#Plot
rm(p)
png(file.path(outImageDir,'decAccBoost_enlargeContralateral.png'), width = 500, height = 500)

p <- ggplot(df, aes(x = age, y = boost))
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


#---------- CONTROL: CONSTRICT BILATERAL: decAcc Boost correlate with age? --------#
df$boost = df$Bi_mvpa_80 - df$L_mvpa_80

rlm_model <- rlm(boost ~ age0z2, 
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect? 
# f.robftest(rlm_model, var="age0z21") #linear
# f.robftest(rlm_model, var="age0z22") #quadratic
f.robftest(rlm_model)

#--- BF METHOD 1 - Dienes/Christie - code by John Christie for Dienes calculator ---#
source("bayesFactorCalc2.R")  #download from: http://www.lifesci.sussex.ac.uk/home/Zoltan_Dienes/inference/bayesFactorCalc2.R
coeffVals = data.frame(as.list(rlm_model$coefficients))
coeffSE = data.frame(as.list(coef(summary(rlm_model))[, "Std. Error"]))

#bf01 for null : age linear
obtained = coeffVals$age0z21
sd = coeffSE$age0z21
BF_output <- Bf(sd, obtained, uniform = FALSE, lower=0, upper=1, meanoftheory=0, sdtheory=1, tails=1)
print(1 / BF_output$BayesFactor) #bf01

#bf01 for null : RH * age quadratic
obtained = coeffVals$age0z22
sd = coeffSE$age0z22
BF_output <- Bf(sd, obtained, uniform = FALSE, lower=0, upper=1, meanoftheory=0, sdtheory=1, tails=1)
print(1 / BF_output$BayesFactor) #bf01


#Plot
rm(p)
png(file.path(outImageDir,'decAccBoost_ConstrictBilateral.png'), width = 500, height = 500)

p <- ggplot(df, aes(x = age, y = boost))
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









# #------------------- DECODING ACCURACY Bilateral vs LH (NO AGE) -------------------#
# #LH vs. Bilateral (i.e. Boost analysis without age)
# t.test(df$L_mvpa_80,df$Bi_mvpa_160, alternative = "two.sided")
# 
# #Plot #STRIP CHART
# #convert to long for a strip chart
# df$ID <- 1:nrow(df) #give sub ID's
# long_df <- df %>% gather(ROI, decAcc, L_mvpa_80, Bi_mvpa_160)
# #check we get same results as ttest above
# aggregate(x = long_df$decAcc,                # Specify data column
#           by = list(long_df$ROI),              # Specify group indicator
#           FUN = mean)    
# t.test(decAcc ~ ROI, long_df)
# #now plot
# rm(p)
# png(file.path(outImageDir,'decAcc_Boost_LH-Bi_NoAge.png'), width = 500, height = 500)
# 
# p <- ggplot(long_df, aes(y = decAcc, x = ROI))
# p <- p + geom_point(shape = 21, size = 3, colour = "indianred2", fill = "lightpink", stroke = 2)
# p <- p + geom_hline(yintercept = 0.25, linetype = "longdash", color = 'black', size = 1.5)
# #formatting
# p <- p + geom_line(aes(group = ID), colour = "black", alpha = 0.5) +
#   theme_bw() + 
#   theme(panel.border = element_blank(),
#         panel.grid.major = element_blank(),
#         legend.position = "none",
#         panel.grid.minor = element_blank(),
#         axis.line = 
#           element_line(colour = "black",size = 1.5), 
#         axis.ticks = element_line(colour = "black",
#                                   size = 1.5),
#         text = element_text(size=24)) +
#   ylim(0,45)
# print(p)
# 
# dev.off()
# 

