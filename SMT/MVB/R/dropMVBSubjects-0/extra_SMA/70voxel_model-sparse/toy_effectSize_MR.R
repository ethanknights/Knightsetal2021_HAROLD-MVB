###Approach 1
Zscore everything (behavour + age + Brain, i.e. IV + DV. Then estiamte is GENERALLY < 1. Which will be a 'standardised regression coefficients)
 repeat rlm
Then square the estimate


###Approach 2 (Not good idea: https://stackoverflow.com/questions/60073531/is-it-appropriate-to-calculate-r-squared-of-robust-regression-using-rlm
# df1 = 1 #1 regressor
# df2 = 589 #lm_model2$df.residual
# F = 51.798
# R2=df1*F/(df2+df1*F);



###Bad Approach Use lm and this will give r2 (but only for FULL model)
