xfrf_oob <- function(object) {
  if (!inherits(object, "xfrf")) stop("object must be the output of xfrf_fit().")
  forest_oob(object$forest, object$design$X)
}
