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


bernoulli_posterior_summary(n = 250, m = 139, alpha = 2, beta = 2)
bernoulli_posterior_plot(n = 250, m = 130, alpha = 2, beta = 2, show_hpd = T)

n <- 250
m <- 139
alpha <- 2
beta <- 2
get_beta_hpd(m + alpha, n - m + beta)

n <- 25
m <- 14
alpha <- 2
beta <- 2
beta_plot(alpha, beta)
bernoulli_posterior_plot(n = n, m = m, alpha = alpha, beta = beta, show_hpd = T)
bernoulli_posterior_summary(n = n, m = m, alpha = alpha, beta = beta)

# now, change the prior
n <- 25
m <- 14
alpha <- 5
beta <- 5
beta_plot(alpha, beta)
bernoulli_posterior_plot(n = n, m = m, alpha = alpha, beta = beta, show_hpd = T)
bernoulli_posterior_summary(n = n, m = m, alpha = alpha, beta = beta)

# now, change the prior again
n <- 25
m <- 14
alpha <- 10
beta <- 10
beta_plot(alpha, beta)
bernoulli_posterior_plot(n = n, m = m, alpha = alpha, beta = beta, show_hpd = T)
bernoulli_posterior_summary(n = n, m = m, alpha = alpha, beta = beta)

# now return to n = 250, m = 139
n <- 250
m <- 139
alpha <- 1
beta <- 1
bernoulli_posterior_summary(n = n, m = m, alpha = alpha, beta = beta)
