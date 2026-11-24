best_split <- function(X, y, features, min_leaf = 1, w = NULL, n_thresholds = 20,
                       tol_abs = 1e-12, tol_rel = 1e-10) {
  n_node <- nrow(y)
  if (is.null(w)) w <- rep(1 / ncol(y), ncol(y))
  no_split <- list(feature = NULL, threshold = NULL, gain = 0)
  
  if (node_sse(y, w) <= tol_abs) return(no_split)
  
  y_tot <- colSums(y)
  best_feature <- NULL
  best_threshold <- NULL
  best_gain <- -Inf
  
  for (f in features) {
    x <- X[, f]
    ux <- sort(unique(x))
    if (length(ux) < 2) next
    
    thresholds <- (ux[-1] + ux[-length(ux)]) / 2
    if (length(thresholds) > n_thresholds) {
      keep <- unique(round(seq(1, length(thresholds), length.out = n_thresholds)))
      thresholds <- thresholds[keep]
    }
    
    left <- outer(thresholds, x, ">")
    n_left <- rowSums(left)
    n_right <- n_node - n_left
    ok <- n_left >= min_leaf & n_right >= min_leaf
    if (!any(ok)) next
    
    left <- left[ok, , drop = FALSE]
    thresholds <- thresholds[ok]
    n_left <- n_left[ok]
    n_right <- n_right[ok]
    
    sum_left <- left %*% y
    mean_left <- sum_left / n_left
    mean_right <- sweep(-sum_left, 2, y_tot, "+") / n_right
    gain <- (n_left * n_right / n_node) * drop(((mean_left - mean_right)^2) %*% w)
    
    kk <- which.max(gain)
    if (is.null(best_feature) || gain[kk] > best_gain + tol_rel * abs(best_gain)) {
      best_gain <- gain[kk]
      best_feature <- f
      best_threshold <- thresholds[kk]
    }
  }
  
  if (is.null(best_feature) || best_gain <= tol_abs) return(no_split)
  list(feature = best_feature, threshold = best_threshold, gain = best_gain)
}
