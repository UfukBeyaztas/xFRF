xfrf_cv <- function(design, n_fold = 5, loo = FALSE, folds = NULL, ...) {
  if (!inherits(design, "xfrf_design")) stop("design must be the output of xfrf_design().")
  n <- design$n
  if (is.null(folds)) {
    if (loo) n_fold <- n
    folds <- make_folds(n, n_fold = n_fold)
  }
  w <- trapz_weights(design$y_grid)
  fold_error <- numeric(length(folds))
  for (i in seq_along(folds)) {
    test <- folds[[i]]
    train <- setdiff(seq_len(n), test)
    fit <- forest_train(design$X[train, , drop = FALSE], design$Y[train, , drop = FALSE],
                        y_grid = design$y_grid, ...)
    pred <- forest_predict(fit, design$X[test, , drop = FALSE])
    fold_error[i] <- mean(row_ise(design$Y[test, , drop = FALSE], pred, w))
  }
  list(fold_error = fold_error, cv_error = mean(fold_error), folds = folds)
}
