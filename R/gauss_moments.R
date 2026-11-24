gauss_moments <- function(f) {
  m1 <- integrate(function(u) f(u) * dnorm(u), -Inf, Inf, rel.tol = 1e-10)$value
  m2 <- integrate(function(u) f(u)^2 * dnorm(u), -Inf, Inf, rel.tol = 1e-10)$value
  c(mean = m1, sd = sqrt(m2 - m1^2))
}
