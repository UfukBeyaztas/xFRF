xfrf_dgp <- function(n, model = c("linear", "nonlinear", "smooth"), j = 101,
                     n_func = 5, n_scl = 5, sigma_y = 0.2, snr = 4, shares = NULL,
                     nl_delta = 0.1, x_level_sd = c(1, 0.5, 0.5, 1, 0.5),
                     x_gp_sd = c(0.3, 1, 1, 0.3, 1), x_range = 0.3,
                     x_centers = c(0.5, 0.2, 0.8), x_widths = c(Inf, 0.06, 0.06),
                     x_noise_sd = 0.1, noise_range = 0.1,
                     mu_y = function(t) 1.5 * sin(pi * t) + 0.5 * t, jy = j) {
  model <- match.arg(model)
  if (n_func < 3 || n_scl < 3) stop("n_func and n_scl must be at least 3.")
  n_comp <- if (model == "nonlinear") 5 else 6
  if (is.null(shares)) {
    shares <- switch(model,
                     linear = c(0.22, 0.18, 0.15, 0.18, 0.15, 0.12),
                     nonlinear = c(0.20, 0.20, 0.25, 0.15, 0.20),
                     smooth = rep(1 / 6, 6))
  }
  if (length(shares) != n_comp || any(shares < 0) || sum(shares) <= 0) {
    stop("shares must contain ", n_comp, " nonnegative values for this model.")
  }
  if (sigma_y <= 0 || snr <= 0 || nl_delta <= 0 || x_range <= 0) {
    stop("sigma_y, snr, nl_delta and x_range must be positive.")
  }
  x_level_sd <- rep_len(x_level_sd, n_func)
  x_gp_sd <- rep_len(x_gp_sd, n_func)
  if (any(x_level_sd < 0) || any(x_gp_sd < 0) || any(x_level_sd + x_gp_sd == 0)) {
    stop("x_level_sd and x_gp_sd must be nonnegative and not both zero.")
  }
  if (length(x_centers) != 3 || length(x_widths) != 3 || any(x_widths <= 0)) {
    stop("x_centers and x_widths must have three elements, with positive widths.")
  }
  
  sx <- seq(0, 1, length.out = j)
  sy <- seq(0, 1, length.out = jy)
  ws <- trapz_weights(sx)
  wt <- trapz_weights(sy)
  
  Kx <- matern_cov(sx, x_range, nu = 2.5)
  Rx <- cov_factor(Kx)
  latent <- lapply(seq_len(n_func), function(p) {
    x_level_sd[p] * rnorm(n) + x_gp_sd[p] * gauss_curves(n, Rx)
  })
  mu_x <- lapply(seq_len(n_func), function(p) 0.5 * sin(2 * pi * (sx + (p - 1) / n_func)))
  x <- lapply(seq_len(n_func), function(p) {
    sweep(latent[[p]], 2, mu_x[[p]], "+") + matrix(rnorm(n * j, sd = x_noise_sd), n, j)
  })
  names(x) <- paste0("func", seq_len(n_func))
  
  # Standardized window averages of the three active latent curves.
  a <- lapply(1:3, function(p) gauss_window(sx, x_centers[p], x_widths[p], ws))
  sd_u <- sapply(1:3, function(p) {
    v <- ws * a[[p]]
    sqrt(x_level_sd[p]^2 * sum(v)^2 + x_gp_sd[p]^2 * drop(crossprod(v, Kx %*% v)))
  })
  U <- sapply(1:3, function(p) drop(latent[[p]] %*% (ws * a[[p]])) / sd_u[p])
  U <- matrix(U, nrow = n, ncol = 3, dimnames = list(NULL, c("u1", "u2", "u3")))
  
  # Independent standard normal scalar covariates.
  Z <- matrix(rnorm(n * n_scl), n, n_scl)
  colnames(Z) <- paste0("scalar", seq_len(n_scl))
  
  psi_all <- rbind(
    exp(-(sy - 0.20)^2 / (2 * 0.10^2)),
    exp(-(sy - 0.75)^2 / (2 * 0.10^2)),
    sin(pi * sy),
    plogis((sy - 0.5) / 0.1),
    exp(-3 * sy),
    cos(2 * pi * sy)
  )
  tau <- function(u) tanh(u / nl_delta)
  softplus <- function(u) pmax(u, 0) + log1p(exp(-abs(u)))
  bump <- function(u) exp(-u^2 / 2)
  sin_half <- function(z) sin(pi * z / 2)
  
  if (model == "linear") {
    comp_names <- c("func1", "func2", "func3", "scalar1", "scalar2", "scalar3")
    psi <- psi_all
    H <- cbind(U, Z[, 1:3])
  } else if (model == "nonlinear") {
    m_tau <- gauss_moments(tau)
    comp_names <- c("X1", "X1:Z1", "X2/X3:Z1", "Z2", "X1:Z3")
    psi <- psi_all[1:5, ]
    H <- cbind(
      tau(U[, 1]) / m_tau["sd"],
      tau(U[, 1]) * sign(Z[, 1]) / m_tau["sd"],
      ifelse(Z[, 1] > 0, tau(U[, 2]), tau(U[, 3])) / m_tau["sd"],
      sign(Z[, 2]),
      tau(U[, 1]) * sign(Z[, 3]) / m_tau["sd"]
    )
  } else {
    m1 <- gauss_moments(tanh)
    m2 <- gauss_moments(softplus)
    m3 <- gauss_moments(bump)
    m6 <- gauss_moments(sin_half)
    comp_names <- c("X1", "X2", "X3", "Z1", "Z2", "Z3")
    psi <- psi_all
    H <- cbind(
      (tanh(U[, 1]) - m1["mean"]) / m1["sd"],
      (softplus(U[, 2]) - m2["mean"]) / m2["sd"],
      (bump(U[, 3]) - m3["mean"]) / m3["sd"],
      Z[, 1],
      (Z[, 2]^2 - 1) / sqrt(2),
      (sin_half(Z[, 3]) - m6["mean"]) / m6["sd"]
    )
  }
  rownames(psi) <- comp_names
  colnames(H) <- comp_names
  
  shares <- shares / sum(shares)
  c0 <- sqrt(shares) * sigma_y / sqrt(drop(psi^2 %*% wt))
  V <- sum(outer(c0, c0) * diag(n_comp) * (psi %*% (t(psi) * wt)))
  Psi <- (c0 * sigma_y / sqrt(V)) * psi
  
  mu_vec <- mu_y(sy)
  yt <- sweep(H %*% Psi, 2, mu_vec, "+")
  
  sigma_eps <- sigma_y / sqrt(snr)
  Re <- cov_factor(matern_cov(sy, noise_range, nu = 1.5))
  y <- yt + sigma_eps * gauss_curves(n, Re)
  
  pred_names <- c(names(x), colnames(Z))
  vi_true <- matrix(0, length(pred_names), jy, dimnames = list(pred_names, NULL))
  if (model == "nonlinear") {
    vi_true["func1", ] <- 2 * (Psi["X1", ]^2 + Psi["X1:Z1", ]^2 + Psi["X1:Z3", ]^2)
    vi_true["func2", ] <- Psi["X2/X3:Z1", ]^2
    vi_true["func3", ] <- Psi["X2/X3:Z1", ]^2
    vi_true["scalar1", ] <- 2 * Psi["X1:Z1", ]^2 + Psi["X2/X3:Z1", ]^2
    vi_true["scalar2", ] <- 2 * Psi["Z2", ]^2
    vi_true["scalar3", ] <- 2 * Psi["X1:Z3", ]^2
  } else {
    vi_true[c("func1", "func2", "func3", "scalar1", "scalar2", "scalar3"), ] <- 2 * Psi^2
  }
  
  s_relevance <- matrix(0, n_func, j, dimnames = list(names(x), NULL))
  for (p in 1:3) s_relevance[p, ] <- a[[p]]
  
  beta_func <- beta_scalar <- NULL
  if (model == "linear") {
    beta_func <- lapply(seq_len(n_func), function(p) {
      if (p <= 3) outer(a[[p]] / sd_u[p], Psi[p, ]) else matrix(0, j, jy)
    })
    names(beta_func) <- names(x)
    beta_scalar <- lapply(seq_len(n_scl), function(l) if (l <= 3) Psi[3 + l, ] else rep(0, jy))
    names(beta_scalar) <- colnames(Z)
  }
  
  list(
    y = y, yt = yt, x = x, x.scl = Z,
    meta = list(
      sx = sx, sy = sy, model = model, vi_true = vi_true, s_relevance = s_relevance,
      x_centers = setNames(x_centers, paste0("func", 1:3)),
      x_widths = setNames(x_widths, paste0("func", 1:3)),
      beta_func = beta_func, beta_scalar = beta_scalar,
      active_func = paste0("func", 1:3), active_scalar = paste0("scalar", 1:3),
      inactive_func = if (n_func > 3) paste0("func", 4:n_func) else character(0),
      inactive_scalar = if (n_scl > 3) paste0("scalar", 4:n_scl) else character(0),
      profiles = psi, component_curves = Psi, scores = H, u = U, mu_y = mu_vec,
      mu_x = mu_x, sigma_y = sigma_y, sigma_eps = sigma_eps, snr = sigma_y^2 / sigma_eps^2,
      shares = shares, nl_delta = nl_delta, x_level_sd = x_level_sd, x_gp_sd = x_gp_sd,
      x_range = x_range, x_noise_sd = x_noise_sd, noise_range = noise_range
    )
  )
}