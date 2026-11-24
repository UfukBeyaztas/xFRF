node_sse <- function(y, w) {
  mu <- colMeans(y)
  resid2 <- (y - matrix(mu, nrow(y), ncol(y), byrow = TRUE))^2
  sum(sweep(resid2, 2, w, "*"))
}