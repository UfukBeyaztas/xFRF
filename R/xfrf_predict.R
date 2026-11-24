xfrf_predict <- function(object, X_funcs = NULL, X_scalars = NULL, argvals = NULL,
                         band_level = NULL) {
  if (!inherits(object, "xfrf")) stop("object must be the output of xfrf_fit().")
  X_new <- xfrf_design_new(object$design, X_funcs = X_funcs, X_scalars = X_scalars,
                           argvals = argvals)
  forest_predict(object$forest, X_new, band_level = band_level)
}
