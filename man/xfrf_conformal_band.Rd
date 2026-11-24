\name{xfrf_conformal_band}
\alias{xfrf_conformal_band}
\title{Calibrated Prediction Band for New Subjects}
\description{
Evaluates a split-conformal simultaneous band at new inputs.
}
\usage{
xfrf_conformal_band(object, X_funcs = NULL, X_scalars = NULL, argvals = NULL,
                    alpha = object$alpha[1], modulation = c("constant", "sd"))
}
\arguments{
\item{object}{an object returned by \code{xfrf_conformal}.}
\item{X_funcs}{a list of matrices of recorded predictor curves of the new
subjects.}
\item{X_scalars}{a matrix of their scalar covariates.}
\item{argvals}{optional recording grids of the new curves.}
\item{alpha}{one of the calibrated miscoverage levels.}
\item{modulation}{\code{"constant"} for a band of constant width or
\code{"sd"} for the residual standard deviation modulation.}
}
\details{
The band is the prediction of the proper-training forest plus and minus the
calibrated cutoff times the modulation curve, at every recorded response
time.
}
\value{
A list with the predicted curves \code{pred} and the band limits
\code{lower} and \code{upper}, one row per subject.
}
\examples{
\dontrun{
dat <- xfrf_sim_data("smooth", n = 500, replication = 1)
tr <- dat$train
te <- dat$test
set.seed(dat$seeds["band"])
cf <- xfrf_conformal(tr$x, tr$x.scl, tr$y, cal = dat$cal,
                     y_grid = tr$meta$sy, n_trees = 500)
for (mod in c("constant", "sd")) {
  band <- xfrf_conformal_band(cf, te$x, te$x.scl, alpha = 0.05, modulation = mod)
  cover <- mean(apply(te$y >= band$lower & te$y <= band$upper, 1, all))
  width <- mean(rowSums(sweep(band$upper - band$lower, 2, cf$fit$forest$w, "*")))
  print(c(coverage = cover, width = width))
}
}
}
