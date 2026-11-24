xfrf_sim_settings <- function() {
  list(
    design = expand.grid(n = c(100, 250, 500), model = c("linear", "nonlinear", "smooth"),
                         stringsAsFactors = FALSE)[, c("model", "n")],
    n_rep = 100, n_test = 1000, j = 101, sigma_y = 0.2, snr = 4, seed = 2026,
    xfrf = list(n_trees = 500, mtry = NULL, min_leaf = 5, max_depth = 20,
                n_thresholds = 20, ridge = 1e-8),
    cal_share = 0.3, alpha = c(0.05, 0.10)
  )
}