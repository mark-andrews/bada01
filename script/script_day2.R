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

M10 <- lm(y ~ x, data = data_df3)
M11 <- lm(y ~ x, data = data_df4)


coef(M10)
confint(M10)
coef(M11)
confint(M11)


M12 <- brm(y ~ x, data = data_df4)
M13 <- brm(y ~ x, data = data_df3)
fixef(M12)
fixef(M13)
mcmc_plot(M13, type = 'areas')
mcmc_plot(M12, type = 'areas')

M14 <- brm(y ~ x, 
           data = data_df4, 
           family = student())
          
mcmc_plot(M14, type = 'areas')

loo(M12, M14)
waic(M12, M14)


# logistic ----------------------------------------------------------------


weight_df_male <- mutate(weight_df_male, dweight = weight > 80)

M15 <- brm(dweight ~ height, 
           family = bernoulli(),
           data = weight_df_male)


new_prior <- c(
  set_prior('normal(0, 10)', class = 'b', coef = 'height'),
  set_prior('normal(0, 10)', class = 'Intercept')
)

M16 <- brm(dweight ~ height, 
           family = bernoulli(),
           prior = new_prior,
           data = weight_df_male)

head(predict(M16))


# Count models ------------------------------------------------------------

biochem_df <- read_csv("https://raw.githubusercontent.com/mark-andrews/bada01/main/data/biochemist.csv")
biochem_df


M17 <- brm(publications ~ prestige,
           data = biochem_df,
           family = poisson())


M18 <- glm(publications ~ prestige,
           data = biochem_df,
           family = poisson())

prior_summary(M17)


# Negative binomial -------------------------------------------------------

M19 <- brm(publications ~ prestige,
           data = biochem_df,
           family = negbinomial()
)

loo(M17)
loo(M19)
loo(M17, M19)

predict(M19, newdata = tibble(prestige = seq(5)))

predict(M19, newdata = tibble(prestige = seq(5))) %>% 
  as_tibble(rownames = 'prestige') %>% 
  ggplot(aes(y = Estimate, x = prestige)) + geom_col()

posterior_linpred(M19, 
                  newdata = tibble(prestige = seq(5)),
                  transform = T) %>% 
  apply(2, quantile)



# Zero inflated models ----------------------------------------------------


smoking_df <- read_csv("https://raw.githubusercontent.com/mark-andrews/bada01/main/data/smoking.csv")

smoking_df

# zip 
M20 <- brm(cigs ~ educ,
           data = smoking_df,
           family = zero_inflated_poisson())

# vanilla poisson
M21 <- brm(cigs ~ educ,
           data = smoking_df,
           family = poisson())

# zinb
M22 <- brm(cigs ~ educ,
           data = smoking_df,
           family = zero_inflated_negbinomial())

# vanilla neg bin
M23 <- brm(cigs ~ educ,
           data = smoking_df,
           family = negbinomial())

# zip ++ 
M24 <- brm(bf(cigs ~ educ, 
              zi ~ educ),
           data = smoking_df,
           family = zero_inflated_poisson())


# zinb ++ 
M25 <- brm(bf(cigs ~ educ,
              zi ~ educ),
           data = smoking_df,
           family = zero_inflated_negbinomial())

waic(M20, M21, M22, M23, M24, M25)
loo(M20, M21, M22, M23, M24, M25)


# Linear mixed effect; aka multilevel linear ------------------------------

library(lme4)

ggplot(sleepstudy,
       aes(x = Days, y = Reaction, colour = Subject) 
) + geom_point() + stat_smooth(method = 'lm', se = F) +
  facet_wrap(~Subject)


M26 <- lmer(Reaction ~ Days + (Days|Subject), 
            data = sleepstudy)

summary(M26)

M27 <- brm(Reaction ~ Days + (Days|Subject), 
           data = sleepstudy)

prior_summary(M27)
