make_folds <- function(n, n_fold = 5) {
  idx <- sample.int(n)
  split(idx, rep(seq_len(n_fold), length.out = n))
}
