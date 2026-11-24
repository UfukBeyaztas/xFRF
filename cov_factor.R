cov_factor <- function(K) {
  e <- eigen(K, symmetric = TRUE)
  e$vectors %*% diag(sqrt(pmax(e$values, 0)), nrow = length(e$values))
}