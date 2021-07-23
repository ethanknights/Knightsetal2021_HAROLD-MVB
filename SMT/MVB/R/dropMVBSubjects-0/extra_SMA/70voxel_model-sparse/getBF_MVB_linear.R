# Libraries
library(brms)
library(polspline)

# Set seed
set.seed(20210209)

# # Generating data
# numSub <- 200
# df     <- data.frame(sub  = rep(1:numSub),
#                      x    = rnorm(numSub))
# 
# df$s_x <- (df$x - mean(df$x))/(sd(df$x)/0.5)
# 
# # Generating the binary DV
# beta0  <- 0.3
# beta1  <- 1
# z      <- beta0 + beta1*df$s_x # Regression in log odds
# pr     <- 1/(1+exp(-z)) # Convert to probability.
# df$y   <- rbinom(numSub, 1, pr)

#EK
df2 <- data.frame(df$ordy, df$age0z) #rik suggests try just linear 
names(df2) <- c("y","s_x")


# Priors
priors_student_1  <- c(prior(student_t(7, 0, 10) , class = "Intercept"),
                       prior(student_t(7, 0, 1) , class = "b")) 

# Fit BRMS model
baseModel_student_1 <- brm(y ~ s_x,
                           data = df2,
                           prior = priors_student_1,
                           family = bernoulli(), #rik thoguht might be logit familiy
                           chains = 8,
                           save_all_pars = TRUE,
                           sample_prior = TRUE,
                           save_dso = TRUE, 
                           seed = 6353) 


# Extract posterior distribution to calculate BF
postDist_slope <- posterior_samples(baseModel_student_1)$b_s_x


# Get prior density
priorDensity <- dstudent_t(0, 7, 0, 1) # I calculate this instead of using the sampled prior dists

# Calculate BF manually
fit.posterior  <- logspline(postDist_slope)
posterior      <- dlogspline(0, fit.posterior) 
prior          <- priorDensity # Precalculated density
bf             <- prior/posterior # Getting savage dickey ratio

# Calculate OR (order-restricted aka two-tailed) BF manually 
areaPosterior <- sum(postDist_slope > 0)/length(postDist_slope)
posterior.OR  <- posterior/areaPosterior  # Divide by the cut-off area to ensure that dist sums to 1
prior.OR      <- prior/0.5 # Divide by 0.5 to ensure that the prior sums to 1
bf_OR         <- prior.OR/posterior.OR # Getting savage dickey ratio

# Print results
cat(paste("Two-tailed BF10 =", round(bf), "\nOne-tailed BF10 =", round(bf_OR)))


#EK: get BF01 (one-tailed for > 0)
bf01 <- 1 / bf_OR
bf01

