xfrf_design <- function(X_funcs = NULL, X_scalars = NULL, y_func = NULL,
                        basis = NULL, y_grid = NULL, ridge = 1e-8) {
  X_scalars <- as_curve_matrix(X_scalars, "X_scalars")
  y_func <- as_curve_matrix(y_func, "y_func")
  if (is.null(X_funcs)) {
    X_funcs <- list()
  } else if (is.matrix(X_funcs) || is.data.frame(X_funcs)) {
    X_funcs <- list(as.matrix(X_funcs))
  } else {
    X_funcs <- lapply(X_funcs, as_curve_matrix)
  }
  check_rows(y_func, X_scalars)
  for (Xk in X_funcs) check_rows(Xk, X_scalars, y_func)
  if (is.null(y_func) && is.null(X_scalars) && !length(X_funcs)) {
    stop("At least one of X_funcs, X_scalars and y_func must be given.")
  }
  if (!is.null(y_func) && is.null(y_grid)) {
    y_grid <- seq(0, 1, length.out = ncol(y_func))
  }
  
  X <- NULL
  groups <- list()
  type <- character(0)
  basis_info <- list()
  
  if (!is.null(X_scalars)) {
    if (is.null(colnames(X_scalars))) {
      colnames(X_scalars) <- paste0("scalar", seq_len(ncol(X_scalars)))
    }
    X <- X_scalars
    for (j in seq_len(ncol(X_scalars))) {
      groups[[colnames(X_scalars)[j]]] <- j
      type[colnames(X_scalars)[j]] <- "scalar"
    }
  }
  last_col <- if (is.null(X)) 0 else ncol(X)
  
  f_names <- names(X_funcs)
  if (is.null(f_names) || any(f_names == "")) {
    f_names <- paste0("func", seq_along(X_funcs))
  }
  if (length(X_funcs) && !is.null(basis) && length(basis) != length(X_funcs)) {
    stop("basis must have one element per functional predictor.")
  }
  
  for (k in seq_along(X_funcs)) {
    Xk <- X_funcs[[k]]
    spec <- if (is.null(basis)) list() else basis[[k]]
    argvals <- if (is.null(spec$argvals)) seq(0, 1, length.out = ncol(Xk)) else spec$argvals
    nbasis <- if (is.null(spec$nbasis)) min(10, max(4, round(length(argvals) / 10))) else spec$nbasis
    degree <- if (is.null(spec$degree)) 3 else spec$degree
    
    bas <- bspline_basis(argvals, nbasis = nbasis, degree = degree)
    w <- trapz_weights(argvals)
    coef_k <- spline_coef(Xk, bas$B, w, ridge = ridge)
    colnames(coef_k) <- paste0(f_names[k], "_b", seq_len(ncol(coef_k)))
    X <- if (is.null(X)) coef_k else cbind(X, coef_k)
    
    cols <- (last_col + 1):(last_col + ncol(coef_k))
    groups[[f_names[k]]] <- cols
    type[f_names[k]] <- "functional"
    bas$w <- w
    bas$cols <- cols
    basis_info[[f_names[k]]] <- bas
    last_col <- max(cols)
  }
  
  X <- as.matrix(X)
  storage.mode(X) <- "double"
  out <- list(X = X, Y = y_func, y_grid = y_grid, basis = basis_info,
              groups = groups, type = type, feature_names = colnames(X),
              ridge = ridge, n = nrow(X))
  class(out) <- "xfrf_design"
  out
}
