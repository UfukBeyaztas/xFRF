xfrf_plot_oob <- function(object) {
  if (!inherits(object, "xfrf")) stop("object must be the output of xfrf_fit().")
  e <- object$forest$oob_error
  plot(seq_along(e), e, type = "l", lwd = 2, xlab = "Number of trees",
       ylab = "Out-of-bag integrated squared error", main = "")
  invisible(NULL)
}
