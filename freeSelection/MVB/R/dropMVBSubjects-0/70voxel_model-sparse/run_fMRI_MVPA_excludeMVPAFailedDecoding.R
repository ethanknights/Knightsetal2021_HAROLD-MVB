#=========================================================================#
#============================== MVPA ANALYSIS ============================#
#=========================================================================#

# This script reates a subset of subjects whose accuracy > 25 for consistency with MVB model comparison
#---- Transform some stuff ----#
#decAcc to percentage
df$MVPA_L_4way = df$MVPA_L_4way*100
df$MVPA_R_4way = df$MVPA_R_4way*100
df$MVPA_Bi_4way = df$MVPA_Bi_4way*100

df_subset <- df[which(df$MVPA_Bi_4way >= 25), ]

#---------- decAcc Boost correlate with age? --------#
df_subset$MVPA_boost = df_subset$MVPA_Bi_4way - df_subset$MVPA_L_4way

rlm_model <- rlm(MVPA_boost ~ age0z2, 
                 data = df_subset, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("age0z21","age0z22")) #age effect? 
# f.robftest(rlm_model, var="age0z21") #linear
# f.robftest(rlm_model, var="age0z22") #quadratic
f.robftest(rlm_model)

#--- BF METHOD 2 - BayesFactor package ---#
summary(rlm_model) #reminder!!

bf10 <-           lmBF(MVPA_boost ~ age0z, data = df_subset)
bf01 = 1/bf10; bf01


#Plot
rm(p)
png(file.path(outImageDir,'decAccBoost_excludeMVPA.png'), width = 500, height = 500)

p <- ggplot(df_subset, aes(x = age, y = MVPA_boost))
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

