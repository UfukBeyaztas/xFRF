xfrf_tune <- function(design, grid, n_fold = 5, loo = FALSE, folds = NULL) {
  if (!is.data.frame(grid)) stop("grid must be a data frame.")
  miss <- setdiff(c("n_trees", "mtry", "min_leaf", "max_depth"), names(grid))
  if (length(miss)) stop("grid lacks the columns: ", paste(miss, collapse = ", "))
  if (is.null(folds)) {
    folds <- make_folds(design$n, n_fold = if (loo) design$n else n_fold)
  }
  grid$cv_error <- NA_real_
  for (r in seq_len(nrow(grid))) {
    grid$cv_error[r] <- xfrf_cv(design, folds = folds, n_trees = grid$n_trees[r],
                                mtry = grid$mtry[r], min_leaf = grid$min_leaf[r],
                                max_depth = grid$max_depth[r])$cv_error
  }
  list(results = grid, best = grid[which.min(grid$cv_error), , drop = FALSE], folds = folds)
}
