#======================= Boost Analysis ======================#

#first drop subjects who failed decoding
df_subset <- df[which(df$idx_couldNotDecode==0), ]

unique(df_subset$ordy)

# #---------- Version if only 2 levels in ordy (e.g. Boost, Reduction; no equivalent) -------#
# #-- First just do linear age (no quadratic) (as ordinal data) --#
# model <- glm(formula = ordy  ~ age0z, 
#              family = binomial(logit), data = df_subset)
# summary(model)
# #Get Odds ratio
# exp(coef(model))
# ci<-confint(model)
# OR <- exp(cbind(OR = coef(model), ci)); OR
# source("getBF_MVB_linear.R") #get BF01 for Boost ~ Age > 0 
# 
# #-- For completion add quadratic term  --#
# model <- glm(formula = ordy  ~ age0z2, 
#              family = binomial(logit), data = df_subset)
# summary(model)
# wald.test(model, terms = c(2,3)) #age effect?
# source("getBF_MVB_linearANDQuadratic.R")  #this might not be accurate, as need to mdoel the quadratic term too


# #Plot - geom_density
# ggplot(df_subset, aes(age, fill = fct_rev(ordy))) + 
#   geom_density(position='fill', alpha = 0.75,color="white", kernel = 'cosine') +
#   theme_bw() + 
#   theme(panel.border = element_blank(),
#         panel.grid.major = element_blank(),
#         legend.position = "none",
#         panel.grid.minor = element_blank(),
#         # axis.line.x = 
#         #   element_line(colour = "black",size = 0), 
#         axis.title.y = element_blank(), 
#         axis.text.y = element_blank(), 
#         axis.ticks.y = element_blank(),
#         axis.ticks.x = element_line(colour = "black",
#                                     size = 1),
#         text = element_text(size=24)) +
#   #Set Colours
#   scale_fill_manual( values = c("limegreen","lightgray")) + 
#   #Remove space around axis
#   coord_cartesian(xlim = c(20,80) , ylim = c(0,1), expand = TRUE)
# ggsave(file.path(outImageDir,'Boost_geom_density.png'),
#        width = 25, height = 25, units = 'cm', dpi = 300)
# 
# 
# #Plot - stacked bar chart
# ageGroups = cut(df_subset$age, breaks = c(17,28,38,48,58,68,78,88), right = TRUE)
# ggplot(df_subset, aes(x = ageGroups, fill=fct_rev(ordy))) +
#   geom_bar(alpha = 0.75) +
#   theme_bw() + 
#   theme(panel.border = element_blank(),
#         panel.grid.major = element_blank(),
#         legend.position = "none",
#         panel.grid.minor = element_blank(),
#         # axis.line = 
#         #   element_line(colour = "black",size = 1), 
#         axis.ticks = element_line(colour = "black",
#                                   size = 1.5),
#         text = element_text(size=24)) +
#   scale_fill_manual( values = c("limegreen","lightgray")) + 
#   coord_cartesian(xlim = c(0,8) , ylim = c(0,100), expand = FALSE)
# ggsave(file.path(outImageDir,'Boost_stackedBar.png'),
#        width = 25, height = 25, units = 'cm', dpi = 300)



#---- Logistical Regression (ideal way with 3 factors like Morcom & Henson 2018) ----#
m<-polr(ordy ~ age0z, data=df_subset, Hess=TRUE) #linear version
m<-polr(ordy ~ age0z2, data=df_subset, Hess=TRUE) #quadratci version
summary(m)
dropterm(m, test = "Chi") #p value for general effect of age? #Chapter 11.3 here is helpful: https://books.google.co.uk/books?id=1h-9DgAAQBAJ&pg=PT355&lpg=PT355&dq=dropterm+chi+square+test&source=bl&ots=F3duGqHcIE&sig=ACfU3U1wVr7Q586HLN28cNT0Zj5YIT5OxA&hl=en&sa=X&ved=2ahUKEwjb6ciBxtXtAhUNY8AKHciqCycQ6AEwDnoECB8QAg#v=onepage&q=dropterm%20chi%20square%20test&f=false

#get p value per coefficient. https://stats.idre.ucla.edu/r/dae/ordinal-logistic-regression/
(ctable <- coef(summary(m))) ## store table
p <- pnorm(abs(ctable[, "t value"]), lower.tail = FALSE) * 2 ## calculate and store p values
(ctable <- cbind(ctable, "p value" = p)) ## combined table

# #get odds ratio
# exp(coef(m))
# ci<-confint(m)
# exp(cbind(OR = coef(m), ci))
# 
# #Because the odd ratio above was not sensible, lets get this by repeating with just the sig predictor
# m <- polr(ordy ~ age0z^2, data=df_subset, Hess=TRUE) #could we use this to get sensible odds ratio ... ??
# exp(coef(m))
# ci<-confint(m)
# exp(cbind(OR = coef(m), ci))


#Plot - geom_density
ggplot(df_subset, aes(age, fill = fct_rev(ordy))) +
  geom_density(position='fill', alpha = 0.75,color="white", kernel = 'cosine') +
  theme_bw() +
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1.5),
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        # axis.line.x =
        #   element_line(colour = "black",size = 0),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.ticks.x = element_line(colour = "black",
                                    size = 1.5),
        text = element_text(size=24)) +
  #Set Colours
  scale_fill_manual( values = c("limegreen","lightgray","red")) +
  #Remove space around axis
  coord_cartesian(xlim = c(20,80) , ylim = c(0,1), expand = FALSE)
ggsave(file.path(outImageDir,'Boost_geom_density.png'),
       width = 25, height = 25, units = 'cm', dpi = 300)


#Plot - stacked bar chart
ageGroups = cut(df_subset$age, breaks = c(17,28,38,48,58,68,78,88), right = TRUE)
ggplot(df_subset, aes(x = ageGroups, fill=fct_rev(ordy))) +
  geom_bar(alpha = 0.75) +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.line =
          element_line(colour = "black",size = 1),
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24)) +
  scale_fill_manual( values = c("limegreen","lightgray","red")) +
  coord_cartesian(xlim = c(0,8) , ylim = c(0,100), expand = FALSE)
ggsave(file.path(outImageDir,'Boost_stackedBar.png'),
       width = 25, height = 25, units = 'cm', dpi = 300)
