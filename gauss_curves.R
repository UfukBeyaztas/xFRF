gauss_curves <- function(n, R) {
  matrix(rnorm(n * nrow(R)), nrow = n) %*% t(R)
}