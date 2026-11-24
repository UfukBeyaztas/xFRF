xfrf_sim_data <- function(model = c("linear", "nonlinear", "smooth"), n = 100, replication = 1,
                          seed = 2026, n_test = 1000) {
  model <- match.arg(model)
  model_id <- match(model, c("linear", "nonlinear", "smooth"))
  n_id <- match(n, c(100, 250, 500))
  if (is.na(n_id)) stop("n must be 100, 250 or 500.")
  if (replication < 1 || replication > 9999) stop("replication must be between 1 and 9999.")
  
  seed_test <- seed + 1e8 * model_id + replication
  seed_base <- seed + 1e8 * model_id + 1e6 * n_id + replication
  
  set.seed(seed_test)
  test <- xfrf_dgp(n_test, model = model)
  set.seed(seed_base)
  train <- xfrf_dgp(n, model = model)
  set.seed(seed_base + 5e5)
  cal <- sort(sample.int(n, floor(0.3 * n)))
  
  list(train = train, test = test, cal = cal,
       seeds = c(test = seed_test, train = seed_base, split = seed_base + 5e5,
                 fit = seed_base + 6e4, band = seed_base + 16e4))
}