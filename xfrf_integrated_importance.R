xfrf_integrated_importance <- function(importance, object, type = c("grouped", "additive")) {
  type <- match.arg(type)
  drop(importance[[type]] %*% object$forest$w)
}