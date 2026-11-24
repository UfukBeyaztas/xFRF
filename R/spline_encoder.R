spline_encoder <- function(B, w, ridge = 1e-8) {
  BW <- sweep(B, 1, w, "*")
  solve(crossprod(B, BW) + ridge * diag(ncol(B)), t(BW))
}
