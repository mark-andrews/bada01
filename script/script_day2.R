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


# Changing defaults -------------------------------------------------------

M2 <- brm(y ~ x_1 + x_2,
          data = data_df1,
          iter = 2500,
          warmup = 500,
          chains = 4,
          #cores = 4,
          seed = 10101,
          prior = set_prior('normal(0, 100)')
)
          
fixef(M_bayes)    # flat priors
fixef(M2)
prior_summary(M2)


# Coin model --------------------------------------------------------------

M3 <- brm(m | trials(n) ~ 1,
          data = data.frame(m = 139, n = 250),
          family = binomial(link = 'identity'),
          prior = set_prior('beta(1,1)', class = 'Intercept'))



# Real data ---------------------------------------------------------------

weight_df <- read_csv("https://raw.githubusercontent.com/mark-andrews/bada01/main/data/weight.csv")

weight_df_male <- filter(weight_df, gender == 'male')

M4 <- lm(weight ~ height + age, data = weight_df_male)
summary(M4)

M5 <- brm(weight ~ height + age, data = weight_df_male)
M5

bayes_R2(M5)

prior_summary(M5)

new_prior <- c(
  set_prior('normal(0, 10)', class = 'b', coef = 'age'),
  set_prior('normal(0, 10)', class = 'b', coef = 'height'),
  set_prior('normal(0, 100)', class = 'Intercept'),
  set_prior('student_t(1, 0, 30)', class = 'sigma')
)
  
M6 <- brm(weight ~ height + age, 
          prior = new_prior,
          data = weight_df_male)


fixef(M6)
fixef(M5)



# Model comparison --------------------------------------------------------

M7 <- brm(weight ~ height, data = weight_df_male)
loo(M7)
loo(M5)
loo(M7, M5)

waic(M7)
waic(M5)
waic(M5, M7)

# Extending linear models -------------------------------------------------

set.seed(10101)
n <- 250
data_df2 <- tibble(A = rnorm(n, mean = 1, sd = 1),
                   B = rnorm(n, mean = 0.25, sd = 2)
) %>% pivot_longer(cols = everything(), names_to = 'x', values_to = 'y')


ggplot(data_df2, aes(x = x, y = y)) + geom_boxplot()


M8 <- brm(y ~ x, data = data_df2)
M8

M9 <- brm(
  bf(y ~ x, sigma ~ x),
  data = data_df2
)

M9



# Outliers ----------------------------------------------------------------

set.seed(10101)
n <- 25
data_df3 <- tibble(x = rnorm(n),
                   y = 5 + 0.5 * x + rnorm(n, sd = 0.1))


data_df4 <- data_df3
data_df4[12,2] <- 7.5

ggplot(data_df3,
       aes(x = x, y = y)
) + geom_point()

ggplot(data_df4,
       aes(x = x, y = y)
) + geom_point()


