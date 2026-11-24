xfrf_plot_surface <- function(importance, predictors = NULL, n_col = 64) {
  surf <- importance$surface
  if (!length(surf)) stop("There are no functional predictors.")
  pick <- if (is.null(predictors)) names(surf) else
    if (is.numeric(predictors)) names(surf)[predictors] else predictors
  pick <- intersect(pick, names(surf))
  if (!length(pick)) stop("No functional predictor selected.")
  pal <- colorRampPalette(c("navy", "white", "firebrick3"))(n_col)
  old <- par(no.readonly = TRUE)
  on.exit(par(old), add = TRUE)
  if (length(pick) > 1) {
    nr <- ceiling(sqrt(length(pick)))
    par(mfrow = c(nr, ceiling(length(pick) / nr)))
  }
  for (g in pick) {
    S <- as.matrix(surf[[g]])
    image(importance$s[[g]], importance$t, S, col = pal, xlab = "s", ylab = "t",
          main = paste("Importance surface:", g))
    contour(importance$s[[g]], importance$t, S, add = TRUE, drawlabels = FALSE,
            col = "grey30")
  }
  invisible(NULL)
}