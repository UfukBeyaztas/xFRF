forest_predict <- function(forest, X, band_level = NULL) {
  X <- as.matrix(X)
  B <- forest$n_trees
  if (is.null(band_level)) {
    acc <- tree_predict(forest$trees[[1]], X)
    if (B > 1) {
      for (b in 2:B) acc <- acc + tree_predict(forest$trees[[b]], X)
    }
    return(acc / B)
  }
  
  m <- length(forest$y_grid)
  all_pred <- array(NA_real_, dim = c(nrow(X), m, B))
  for (b in seq_len(B)) all_pred[, , b] <- tree_predict(forest$trees[[b]], X)
  pred <- matrix(apply(all_pred, c(1, 2), mean), nrow = nrow(X), ncol = m)
  
  alpha <- 1 - band_level
  lower <- upper <- matrix(NA_real_, nrow = nrow(X), ncol = m)
  for (i in seq_len(nrow(X))) {
    Pi <- as.matrix(all_pred[i, , ])
    lower[i, ] <- apply(Pi, 1, quantile, probs = alpha / 2, names = FALSE)
    upper[i, ] <- apply(Pi, 1, quantile, probs = 1 - alpha / 2, names = FALSE)
  }
  list(pred = pred, lower = lower, upper = upper, tree_pred = all_pred)
}