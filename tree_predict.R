tree_predict <- function(tree, X) {
  X <- as.matrix(X)
  first <- tree_predict_one(tree, X[1, ])
  out <- matrix(NA_real_, nrow = nrow(X), ncol = length(first))
  out[1, ] <- first
  if (nrow(X) > 1) {
    for (i in 2:nrow(X)) out[i, ] <- tree_predict_one(tree, X[i, ])
  }
  out
}