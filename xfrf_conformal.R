xfrf_conformal <- function(X_funcs = NULL, X_scalars = NULL, y_func, cal, alpha = c(0.05, 0.10),
                           id = NULL, rel_floor = 1e-8, abs_floor = 0, ...) {
  y_func <- as_curve_matrix(y_func, "y_func")
  n <- nrow(y_func)
  if (is.matrix(X_funcs) || is.data.frame(X_funcs)) X_funcs <- list(as.matrix(X_funcs))
  X_scalars <- as_curve_matrix(X_scalars, "X_scalars")
  if (any(cal < 1 | cal > n)) stop("cal must contain row indices of the data.")
  train <- setdiff(seq_len(n), cal)
  if (!is.null(id) && length(intersect(id[train], id[cal]))) {
    stop("A record must not appear in both the proper training and the calibration set.")
  }
  
  rows <- function(idx) {
    list(f = if (is.null(X_funcs)) NULL else lapply(X_funcs, function(a) a[idx, , drop = FALSE]),
         s = if (is.null(X_scalars)) NULL else X_scalars[idx, , drop = FALSE])
  }
  tr <- rows(train)
  ca <- rows(cal)
  fit <- xfrf_fit(X_funcs = tr$f, X_scalars = tr$s, y_func = y_func[train, , drop = FALSE], ...)
  pred_cal <- xfrf_predict(fit, X_funcs = ca$f, X_scalars = ca$s)
  
  res_oob <- y_func[train, , drop = FALSE] - xfrf_oob(fit)
  v <- apply(res_oob, 2, sd, na.rm = TRUE)
  u <- list(constant = rep(1, ncol(y_func)),
            sd = pmax(v, rel_floor * max(v), abs_floor))
  
  absres <- abs(y_func[cal, , drop = FALSE] - pred_cal)
  record <- if (is.null(id)) seq_along(cal) else id[cal]
  q <- matrix(NA_real_, length(alpha), 2, dimnames = list(format(alpha), names(u)))
  scores <- list()
  for (type in names(u)) {
    per_curve <- apply(sweep(absres, 2, u[[type]], "/"), 1, max)
    s <- sort(tapply(per_curve, record, max))
    scores[[type]] <- s
    n_cal <- length(s)
    for (a in seq_along(alpha)) {
      k <- ceiling((1 - alpha[a]) * (n_cal + 1) - 1e-10)
      q[a, type] <- if (k > n_cal) Inf else s[k]
    }
  }
  
  out <- list(fit = fit, alpha = alpha, u = u, q = q, scores = scores,
              n_cal = length(scores$constant), train = train, cal = cal)
  class(out) <- "xfrf_conformal"
  out
}