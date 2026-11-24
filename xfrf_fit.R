xfrf_fit <- function(X_funcs = NULL, X_scalars = NULL, y_func, basis = NULL,
                     y_grid = NULL, n_trees = 200, mtry = NULL, min_leaf = 5,
                     max_depth = 20, n_thresholds = 20, ridge = 1e-8) {
  design <- xfrf_design(X_funcs = X_funcs, X_scalars = X_scalars, y_func = y_func,
                        basis = basis, y_grid = y_grid, ridge = ridge)
  forest <- forest_train(design$X, design$Y, y_grid = design$y_grid,
                         n_trees = n_trees, mtry = mtry, min_leaf = min_leaf,
                         max_depth = max_depth, n_thresholds = n_thresholds)
  out <- list(design = design, forest = forest, call = match.call())
  class(out) <- "xfrf"
  out
}