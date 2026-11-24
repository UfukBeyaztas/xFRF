grouped_importance <- function(forest, X, y, groups) {
  X <- as.matrix(X)
  y <- as_curve_matrix(y, "y")
  VI <- matrix(0, length(groups), ncol(y), dimnames = list(names(groups), NULL))
  n_used <- 0
  for (b in seq_len(forest$n_trees)) {
    oob <- setdiff(seq_len(nrow(X)), unique(forest$inbag[[b]]))
    if (!length(oob)) next
    n_used <- n_used + 1
    X_oob <- X[oob, , drop = FALSE]
    y_oob <- y[oob, , drop = FALSE]
    err0 <- colMeans((y_oob - tree_predict(forest$trees[[b]], X_oob))^2)
    sh <- sample.int(length(oob))
    for (g in seq_along(groups)) {
      cols <- groups[[g]]
      X_perm <- X_oob
      X_perm[, cols] <- X_oob[sh, cols, drop = FALSE]
      errp <- colMeans((y_oob - tree_predict(forest$trees[[b]], X_perm))^2)
      VI[g, ] <- VI[g, ] + errp - err0
    }
  }
  if (n_used == 0) {
    warning("No tree has a nonempty out-of-bag set; the grouped importance is undefined.")
    VI[] <- NA
    return(VI)
  }
  VI / n_used
}
