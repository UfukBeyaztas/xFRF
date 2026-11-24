bspline_basis <- function(argvals, nbasis = 10, degree = 3) {
  argvals <- as.numeric(argvals)
  B <- bs(argvals, df = nbasis, degree = degree, intercept = TRUE)
  list(
    B = matrix(B, nrow = length(argvals)),
    argvals = argvals,
    degree = attr(B, "degree"),
    knots = attr(B, "knots"),
    boundary = attr(B, "Boundary.knots")
  )
}