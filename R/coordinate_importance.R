coordinate_importance <- function(forest, X, y, n_perm = 1) {
  X <- as.matrix(X)
  y <- as_curve_matrix(y, "y")
  p <- ncol(X)
  m <- ncol(y)
  VI <- matrix(0, nrow = p, ncol = m)
  rownames(VI) <- colnames(X)
  
  for (b in seq_len(forest$n_trees)) {
    tree <- forest$trees[[b]]
    oob <- setdiff(seq_len(nrow(X)), unique(forest$inbag[[b]]))
    if (!length(oob)) next
    X_oob <- X[oob, , drop = FALSE]
    y_oob <- y[oob, , drop = FALSE]
    err0 <- colMeans((y_oob - tree_predict(tree, X_oob))^2)
    
    for (j in seq_len(p)) {
      delta <- rep(0, m)
      for (r in seq_len(n_perm)) {
        X_perm <- X_oob
        sh <- sample.int(nrow(X_perm))
        X_perm[, j] <- X_perm[sh, j]
        errp <- colMeans((y_oob - tree_predict(tree, X_perm))^2)
        delta <- delta + (errp - err0)
      }
      VI[j, ] <- VI[j, ] + delta / n_perm
    }
  }
  VI / forest$n_trees
}
