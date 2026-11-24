forest_train <- function(X, y, y_grid = NULL, n_trees = 200, mtry = NULL,
                         min_leaf = 5, max_depth = 20, n_thresholds = 20) {
  X <- as.matrix(X)
  y <- as_curve_matrix(y, "y")
  n <- nrow(X)
  p <- ncol(X)
  m <- ncol(y)
  if (is.null(y_grid)) y_grid <- seq(0, 1, length.out = m)
  w <- trapz_weights(y_grid)
  if (is.null(mtry)) mtry <- max(1, floor(p / 3))
  
  forest <- list(trees = vector("list", n_trees), inbag = vector("list", n_trees),
                 n_trees = n_trees, mtry = mtry, min_leaf = min_leaf,
                 max_depth = max_depth, n_thresholds = n_thresholds,
                 y_grid = y_grid, w = w, feature_names = colnames(X))
  
  oob_sum <- matrix(0, nrow = n, ncol = m)
  oob_count <- numeric(n)
  oob_error <- rep(NA_real_, n_trees)
  
  for (b in seq_len(n_trees)) {
    idx <- sample.int(n, size = n, replace = TRUE)
    forest$inbag[[b]] <- idx
    forest$trees[[b]] <- grow_tree(X[idx, , drop = FALSE], y[idx, , drop = FALSE],
                                   mtry = mtry, min_leaf = min_leaf,
                                   max_depth = max_depth, depth = 0, w = w,
                                   n_thresholds = n_thresholds)
    oob <- setdiff(seq_len(n), unique(idx))
    if (length(oob)) {
      oob_sum[oob, ] <- oob_sum[oob, ] + tree_predict(forest$trees[[b]], X[oob, , drop = FALSE])
      oob_count[oob] <- oob_count[oob] + 1
    }
    seen <- which(oob_count > 0)
    if (length(seen)) {
      pred <- oob_sum[seen, , drop = FALSE] / oob_count[seen]
      oob_error[b] <- mean(row_ise(y[seen, , drop = FALSE], pred, w))
    }
  }
  
  forest$oob_error <- oob_error
  class(forest) <- "xfrf_forest"
  forest
}