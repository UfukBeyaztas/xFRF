xfrf_importance <- function(object, n_perm = 1) {
  if (!inherits(object, "xfrf")) stop("object must be the output of xfrf_fit().")
  d <- object$design
  grouped <- grouped_importance(object$forest, d$X, d$Y, d$groups)
  coordinate <- coordinate_importance(object$forest, d$X, d$Y, n_perm = n_perm)
  additive <- t(sapply(d$groups, function(cols) colSums(coordinate[cols, , drop = FALSE])))
  if (ncol(coordinate) == 1) additive <- t(additive)
  rownames(additive) <- names(d$groups)
  sf <- importance_surface(coordinate, d)
  list(grouped = grouped, additive = additive, coordinate = coordinate,
       surface = sf$surface, s = sf$s, t = sf$t)
}