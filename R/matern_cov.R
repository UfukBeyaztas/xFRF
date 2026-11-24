matern_cov <- function(grid, range, nu = 2.5) {
  d <- abs(outer(grid, grid, "-")) / range
  if (nu == 1.5) return((1 + sqrt(3) * d) * exp(-sqrt(3) * d))
  if (nu == 2.5) return((1 + sqrt(5) * d + 5 * d^2 / 3) * exp(-sqrt(5) * d))
  stop("nu must be 1.5 or 2.5.")
}
