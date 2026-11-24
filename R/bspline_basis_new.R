bspline_basis_new <- function(argvals, basis) {
  B <- bs(argvals, degree = basis$degree, knots = basis$knots,
          Boundary.knots = basis$boundary, intercept = TRUE)
  matrix(B, nrow = length(argvals))
}
