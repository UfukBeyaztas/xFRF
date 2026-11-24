xfrf_design_new <- function(design, X_funcs = NULL, X_scalars = NULL, argvals = NULL) {
  if (!inherits(design, "xfrf_design")) stop("design must be the output of xfrf_design().")
  X_scalars <- as_curve_matrix(X_scalars, "X_scalars")
  if (is.null(X_funcs)) {
    X_funcs <- list()
  } else if (is.matrix(X_funcs) || is.data.frame(X_funcs)) {
    X_funcs <- list(as.matrix(X_funcs))
  } else {
    X_funcs <- lapply(X_funcs, as_curve_matrix)
  }
  for (Xk in X_funcs) check_rows(Xk, X_scalars)
  
  X_new <- NULL
  s_names <- names(design$type)[design$type == "scalar"]
  if (length(s_names)) {
    if (is.null(X_scalars)) stop("The scalar covariates are required.")
    if (ncol(X_scalars) != length(s_names)) {
      stop("The number of scalar covariates differs from the training data.")
    }
    colnames(X_scalars) <- s_names
    X_new <- X_scalars
  }
  
  f_names <- names(design$type)[design$type == "functional"]
  if (length(X_funcs) != length(f_names)) {
    stop("The number of functional predictors differs from the training data.")
  }
  for (k in seq_along(f_names)) {
    bas <- design$basis[[f_names[k]]]
    Xk <- X_funcs[[k]]
    grid <- if (!is.null(argvals)) argvals[[k]] else NULL
    if (is.null(grid)) {
      grid <- if (ncol(Xk) == length(bas$argvals)) bas$argvals else
        seq(min(bas$argvals), max(bas$argvals), length.out = ncol(Xk))
    }
    B_new <- bspline_basis_new(grid, bas)
    coef_k <- spline_coef(Xk, B_new, trapz_weights(grid), ridge = design$ridge)
    colnames(coef_k) <- design$feature_names[bas$cols]
    X_new <- if (is.null(X_new)) coef_k else cbind(X_new, coef_k)
  }
  
  X_new <- as.matrix(X_new)
  storage.mode(X_new) <- "double"
  X_new[, design$feature_names, drop = FALSE]
}