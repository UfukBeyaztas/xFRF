trapz_weights <- function(grid) {
  grid <- as.numeric(grid)
  m <- length(grid)
  if (m < 2) return(1)
  h <- diff(grid)
  w <- numeric(m)
  w[1] <- h[1] / 2
  w[m] <- h[m - 1] / 2
  if (m > 2) {
    w[2:(m - 1)] <- (h[1:(m - 2)] + h[2:(m - 1)]) / 2
  }
  w
}