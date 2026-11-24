importance_surface <- function(VI, design) {
  f_names <- names(design$type)[design$type == "functional"]
  surf <- list()
  s <- list()
  for (g in f_names) {
    bas <- design$basis[[g]]
    surf[[g]] <- bas$B %*% VI[bas$cols, , drop = FALSE]
    s[[g]] <- bas$argvals
  }
  list(surface = surf, s = s, t = design$y_grid)
}
