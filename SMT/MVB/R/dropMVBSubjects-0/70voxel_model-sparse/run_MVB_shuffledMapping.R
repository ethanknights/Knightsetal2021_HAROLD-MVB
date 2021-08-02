#---------- MVB Mapping (Shuffled GroupFVals) ---------#
source("R_rainclouds.R")

extraData <- read.csv(file.path(rawDir,"extradata_ShuffledGroupFVals.csv"), header=TRUE,sep=",")
t = t.test(extraData$Log, alternative = 'greater', mu = 3)
group = rep(1,nrow(extraData))
extradf = cbind(extraData,group)

t$statistic/ sqrt(nrow(df)) #cohenD
#  ES.t.one( t = t$statistic, df = t$parameter, alternative = 'one.sided' )    #doublecheck cohenD

ggplot(extradf,aes(x=group,y=Log, fill = "indianred2")) +
  geom_flat_violin(position = position_nudge(x = .2, y = 0),adjust =2,alpha=.5,size=1.5) +
  geom_point(position = position_jitter(width = .15), shape = 21, size = 1, colour = "indianred2", fill = "lightpink", stroke = 2) +
  geom_hline(yintercept = 0, linetype = "dotted", color = 'black', size = 1.5) + #baseline (real vs shuffled)
  geom_hline(yintercept = 3, linetype = "longdash", color = 'black', size = 1.5) + #bayesian hypothesised mean test
  theme_bw() +
  theme(panel.border = element_blank(), panel.grid.major = element_blank(), legend.position = "none",panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black", size = 1.5), axis.ticks = element_line(colour = "black", size = 1.5), text = element_text(size=24),
        axis.text.x = element_blank(),axis.title.x = element_blank(),axis.ticks.x = element_blank(),axis.line.x = element_blank()) + # remove y axis
  scale_y_continuous(breaks = round(seq(-5, max(150), by = 30),1), expand = c(0.025,0.025), limits = c(-10,150))
ggsave(file.path(outImageDir,'shuffledMVB.png'),
       width = 15, height = 15, units = 'cm', dpi = 300)


#----- check relationship with age -----%
extradf$age0z = df$age0z
extradf$age0z2 = df$age0z2

#-- 1. does probablity of >3 change with age? --#
extradf$probGreater3 = as.factor(extradf$Log >= 3)

model <- glm(formula = probGreater3  ~ age0z, 
             family = binomial(logit), data = extradf)
summary(model)
#Get Odds ratio
exp(coef(model))
ci<-confint(model)
OR <- exp(cbind(OR = coef(model), ci)); OR

#Plot scatter
plot(extradf$age,extradf$probGreater3)
extradf$age
extradf$probGreater3

#Plot - geom_density
ggplot(extradf, aes(age, fill = probGreater3)) + 
  geom_density(position='fill', alpha = 0.75,color="white", kernel = 'cosine')

