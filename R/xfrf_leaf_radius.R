xfrf_leaf_radius <- function(object, X_funcs = NULL, X_scalars = NULL, argvals = NULL,
                             predictor, E, r = NULL) {
  if (!inherits(object, "xfrf")) stop("object must be the output of xfrf_fit().")
  d <- object$design
  f_names <- names(d$type)[d$type == "functional"]
  if (is.numeric(predictor)) predictor <- f_names[predictor]
  if (!(predictor %in% f_names)) stop("predictor must be a functional predictor.")
  
  z <- xfrf_design_new(d, X_funcs = X_funcs, X_scalars = X_scalars, argvals = argvals)
  z <- z[1, ]
  
  if (is.matrix(X_funcs) || is.data.frame(X_funcs)) X_funcs <- list(X_funcs)
  k_pred <- match(predictor, f_names)
  bas <- d$basis[[predictor]]
  G <- ncol(as.matrix(X_funcs[[k_pred]]))
  grid <- if (!is.null(argvals) && !is.null(argvals[[k_pred]])) argvals[[k_pred]] else
    if (G == length(bas$argvals)) bas$argvals else
      seq(min(bas$argvals), max(bas$argvals), length.out = G)
  w <- trapz_weights(grid)
  A <- spline_encoder(bspline_basis_new(grid, bas), w, ridge = d$ridge)
  if (any(E < 1 | E > G)) stop("E must contain grid indices between 1 and ", G, ".")
  L <- if (length(E)) sqrt(colSums(t(A[, E, drop = FALSE]^2) / w[E])) else rep(0, nrow(A))
  cols <- bas$cols
  
  trees <- object$forest$trees
  B <- length(trees)
  radius <- rep(Inf, B)
  spread <- matrix(0, B, length(d$y_grid))
  for (b in seq_len(B)) {
    node <- trees[[b]]
    while (!is.null(node$feature)) {
      k <- match(node$feature, cols)
      if (!is.na(k) && L[k] > 0) {
        radius[b] <- min(radius[b], abs(z[node$feature] - node$threshold) / L[k])
      }
      node <- if (z[node$feature] < node$threshold) node$left else node$right
    }
    leaves <- tree_leaves(trees[[b]])
    spread[b, ] <- apply(abs(sweep(leaves, 2, node$prediction, "-")), 2, max)
  }
  
  bound <- NULL
  if (!is.null(r)) {
    bound <- t(sapply(r, function(rr) colSums(spread * (radius <= rr)) / B))
    if (length(d$y_grid) == 1) bound <- t(bound)
    rownames(bound) <- format(r)
  }
  list(radius = radius, min_radius = min(radius), spread = spread, bound = bound,
       encoder = A)
}
