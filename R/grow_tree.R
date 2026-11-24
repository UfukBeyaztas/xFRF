grow_tree <- function(X, y, mtry, min_leaf = 1, max_depth = Inf, depth = 0,
                      w = NULL, n_thresholds = 20) {
  n <- nrow(y)
  if (is.null(w)) w <- rep(1 / ncol(y), ncol(y))
  mu <- colMeans(y)
  sse <- node_sse(y, w)
  
  if (n == 0) return(NULL)
  if (sse <= 1e-12) return(list(prediction = mu, n = n, depth = depth))
  if (n <= 2 * min_leaf) return(list(prediction = mu, n = n, depth = depth))
  if (depth >= max_depth) return(list(prediction = mu, n = n, depth = depth))
  
  p <- ncol(X)
  mtry <- min(max(1, mtry), p)
  candidates <- sample.int(p, size = mtry, replace = FALSE)
  split <- best_split(X, y, features = candidates, min_leaf = min_leaf, w = w,
                      n_thresholds = n_thresholds)
  if (is.null(split$feature)) return(list(prediction = mu, n = n, depth = depth))
  
  go_left <- X[, split$feature] < split$threshold
  left <- grow_tree(X[go_left, , drop = FALSE], y[go_left, , drop = FALSE],
                    mtry = mtry, min_leaf = min_leaf, max_depth = max_depth,
                    depth = depth + 1, w = w, n_thresholds = n_thresholds)
  right <- grow_tree(X[!go_left, , drop = FALSE], y[!go_left, , drop = FALSE],
                     mtry = mtry, min_leaf = min_leaf, max_depth = max_depth,
                     depth = depth + 1, w = w, n_thresholds = n_thresholds)
  
  list(feature = split$feature, threshold = split$threshold, prediction = mu,
       n = n, depth = depth, left = left, right = right)
}
