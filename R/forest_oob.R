forest_oob <- function(forest, X) {
  X <- as.matrix(X)
  n <- nrow(X)
  acc <- matrix(0, n, length(forest$y_grid))
  cnt <- numeric(n)
  for (b in seq_len(forest$n_trees)) {
    oob <- setdiff(seq_len(n), unique(forest$inbag[[b]]))
    if (!length(oob)) next
    acc[oob, ] <- acc[oob, ] + tree_predict(forest$trees[[b]], X[oob, , drop = FALSE])
    cnt[oob] <- cnt[oob] + 1
  }
  out <- acc / pmax(cnt, 1)
  out[cnt == 0, ] <- NA
  out
}
