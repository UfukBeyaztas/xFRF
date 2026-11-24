spline_coef <- function(X, B, w, ridge = 1e-8) {
  BW <- sweep(B, 1, w, "*")
  XW <- sweep(t(X), 1, w, "*")
  lhs <- crossprod(B, BW) + ridge * diag(ncol(B))
  t(solve(lhs, crossprod(B, XW)))
}