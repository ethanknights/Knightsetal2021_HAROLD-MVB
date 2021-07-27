#PURPOSE:
#
#Load Data for the Free Selection Task
#
#Then use 'df' in the other short scripts  for:
#- unviariate mean 
#- MVB spread
#- MVB boost (ordinal category codes)
#- MVB multivariate mapping (real vs. shuffled onsets)
#- MVPA between-finger

library(ggplot2)
library(Hmisc)
library(MASS)
library(reshape2)
library(sfsmisc)
library(sjPlot)
library(BayesFactor)
library(sjmisc)
library(dplyr)
library(tidyverse)
library(broom)
library(Rcpp)
library(stringi)
library(foreign)
library(mdscore)
library(compute.es)
library(pracma)

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


#---- Load Data ----#
rawD <- read.csv(file.path(rawDir,'data.csv'), header=TRUE,sep=",")
df = rawD

#---- Transform some stuff ----#
#Age quadratic expansion
df$age0z2 <- poly(df$age0z,2) #1st linear, 2nd quad
#make variablers factors
df$ordy <- as.factor(df$ordy) #Check it worked: sapply(df, class)
#rescale out of scanner RT
df$outScanner_RTmean <- df$outScanner_RTmean * 1000
df$outScanner_RTsd <- df$outScanner_RTsd * 1000
df$inScanner_RTmean <- df$inScanner_RTmean * 1000
df$inScanner_RTsd <- df$inScanner_RTsd * 1000

#---- assign subs a tertile age group in df$tert ----#
#https://stackoverflow.com/questions/62574146/how-to-create-tertile-in-r

# Find tertiles
vTert = quantile(df$age, c(0:3/3)) #rememebr this is useful for plot_model

df$ageTert = with(df, 
                  cut(age, 
                      vTert, 
                      include.lowest = T, 
                      labels = c("YA", "ML", "OA")))

#---- Run Analyses (manually) ----#
# run_fMRI_univariate.R
# run_fMRI_spread.R
# run_fMRI_MVB.R
# run_BEHAV.R
# run_fMRI_MVPA.R #for decoding accuracy vs. chance, and predicted by age.
# run_fMRI_MVPA_excludeMVPAFailedDecoding.R #for decoding accuracy boost ~ Age