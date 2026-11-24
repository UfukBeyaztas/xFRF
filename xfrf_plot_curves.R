xfrf_plot_curves <- function(importance, predictors = NULL, type = c("grouped", "additive")) {
  type <- match.arg(type)
  VI <- importance[[type]]
  pick <- if (is.null(predictors)) rownames(VI) else
    if (is.numeric(predictors)) rownames(VI)[predictors] else predictors
  pick <- intersect(pick, rownames(VI))
  if (!length(pick)) stop("No predictor selected.")
  old <- par(no.readonly = TRUE)
  on.exit(par(old), add = TRUE)
  if (length(pick) > 1) {
    nr <- ceiling(sqrt(length(pick)))
    par(mfrow = c(nr, ceiling(length(pick) / nr)))
  }
  for (g in pick) {
    plot(importance$t, VI[g, ], type = "l", lwd = 2, xlab = "t",
         ylab = "Importance", main = g)
    abline(h = 0, lty = 2, col = "grey60")
  }
  invisible(NULL)
}