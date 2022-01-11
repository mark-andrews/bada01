library(priorexposure)
help(package = 'priorexposure')

bernoulli_likelihood(n = 25, m = 14)

beta_plot(alpha = 3, beta = 5)
beta_plot(alpha = 30, beta = 50)
beta_plot(alpha  = 10, beta= 50)
beta_plot(alpha = 1, beta = 5)
beta_plot(alpha = 20, beta  = 5)
beta_plot(alpha = 1, beta = 1)
beta_plot(alpha = 2, beta = 2)
beta_plot(alpha = 10, beta = 10)

bernoulli_posterior_plot(n = 250, m = 139, alpha = 2, beta = 2)
beta_plot(139 + 2, 250 - 139 + 2)
bernoulli_posterior_plot(n = 250, m = 139, alpha = 2, beta = 2, show_hpd = T)
bernoulli_posterior_summary(n = 250, m = 139, alpha = 2, beta = 2)
