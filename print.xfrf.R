print.xfrf <- function(x, ...) {
  d <- x$design
  cat("Explainable functional random forest\n")
  cat("  subjects:", d$n, "  response grid points:", length(d$y_grid), "\n")
  cat("  functional predictors:", sum(d$type == "functional"),
      "  scalar covariates:", sum(d$type == "scalar"),
      "  features:", ncol(d$X), "\n")
  cat("  trees:", x$forest$n_trees, "  mtry:", x$forest$mtry,
      "  minimum child size:", x$forest$min_leaf,
      "  maximum depth:", x$forest$max_depth, "\n")
  last <- tail(x$forest$oob_error[!is.na(x$forest$oob_error)], 1)
  if (length(last)) cat("  out-of-bag integrated squared error:", format(last, digits = 4), "\n")
  invisible(x)
}