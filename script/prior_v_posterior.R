library(tidyverse)

library(tidyverse)
library(brms)

data_df <- tibble(x = rnorm(10))

M <- brm(x ~ 1, data = data_df)
mcmc_plot(M)

P <- brm(x ~ 1, data = data_df, sample_prior = 'only')
mcmc_plot(P)

Q <- brm(x ~ 1, data = data_df, sample_prior = 'yes')

# put prior and posterior sampels together
samples <- bind_rows(
  as_draws_matrix(P) %>% 
    as_tibble() %>% 
    select(-lp__) %>% 
    mutate(type = 'prior'),
  as_draws_matrix(M) %>% 
    as_tibble() %>% 
    select(-lp__) %>% 
    mutate(type = 'posterior')
) %>% pivot_longer(cols = -type, 
                   names_to = 'parameter', 
                   values_to = 'value') %>% 
  mutate(value = as.numeric(value))

ggplot(samples,
       aes(x = value, fill = type, colour = type)
) + geom_density(position = 'identity', alpha = 0.5) +
  facet_wrap(~parameter, scales = 'free') + 
  theme_minimal()
       