library(tidyverse)
library(brms)



# Generate simulated data -------------------------------------------------

set.seed(10101) # Omit or change this if you like

N <- 25

x_1 <- rnorm(N)
x_2 <- rnorm(N)

beta_0 <- 1.25
beta_1 <- 1.75
beta_2 <- 2.25

mu <- beta_0 + beta_1 * x_1 + beta_2 * x_2

y <- mu + rnorm(N, mean=0, sd=1.75)

data_df1 <- tibble(x_1, x_2, y)


# Classical linear regression ---------------------------------------------

M_lm <- lm(y ~ x_1 + x_2, data = data_df1)
coef(M_lm)
sigma(M_lm)
summary(M_lm)


# Bayesian linear regression using Stan via brms --------------------------

M_bayes <- brm(y ~ x_1 + x_2, data = data_df1)

M_bayes

plot(M_bayes)

mcmc_plot(M_bayes)
mcmc_plot(M_bayes, type = 'hist', binwidth = 0.05)
mcmc_plot(M_bayes, type = 'areas')
mcmc_plot(M_bayes, type = 'areas_ridges')

prior_summary(M_bayes)

get_prior(y ~ x_1 + x_2, data = data_df1)
