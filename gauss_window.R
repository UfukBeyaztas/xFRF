gauss_window <- function(s, centre, width, ws) {
  a <- if (is.infinite(width)) rep(1, length(s)) else dnorm(s, centre, width)
  a / sum(ws * a)
}