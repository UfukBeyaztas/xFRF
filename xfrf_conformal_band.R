xfrf_conformal_band <- function(object, X_funcs = NULL, X_scalars = NULL, argvals = NULL,
                                alpha = object$alpha[1], modulation = c("constant", "sd")) {
  if (!inherits(object, "xfrf_conformal")) {
    stop("object must be the output of xfrf_conformal().")
  }
  modulation <- match.arg(modulation)
  a <- match(format(alpha), rownames(object$q))
  if (is.na(a)) stop("alpha must be one of the calibrated levels.")
  pred <- xfrf_predict(object$fit, X_funcs = X_funcs, X_scalars = X_scalars, argvals = argvals)
  half <- matrix(object$q[a, modulation] * object$u[[modulation]], nrow(pred), ncol(pred),
                 byrow = TRUE)
  list(pred = pred, lower = pred - half, upper = pred + half)
}