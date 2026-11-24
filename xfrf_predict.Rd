\name{xfrf_predict}
\alias{xfrf_predict}
\title{Predict Response Curves}
\description{
Predicts the response curves of new subjects on the response grid, with an
optional ensemble band from the tree predictions.
}
\usage{
xfrf_predict(object, X_funcs = NULL, X_scalars = NULL, argvals = NULL,
             band_level = NULL)
}
\arguments{
\item{object}{an object returned by \code{xfrf_fit}.}
\item{X_funcs}{a list of matrices of recorded predictor curves of the new
subjects.}
\item{X_scalars}{a matrix of their scalar covariates.}
\item{argvals}{optional recording grids of the new curves, as in
\code{xfrf_design_new}.}
\item{band_level}{\code{NULL}, or a number in (0, 1) for the ensemble band.}
}
\details{
With \code{band_level} equal to \eqn{1 - \alpha}{1 - alpha}, the ensemble
band at each response time is formed by the empirical \eqn{\alpha/2}{alpha/2}
and \eqn{1 - \alpha/2}{1 - alpha/2} quantiles of the predictions of the
\eqn{B} trees. It describes variation among the fitted trees and has no
coverage guarantee for a new response; calibrated bands are given by
\code{xfrf_conformal}.
}
\value{
Without a band, a matrix of predicted curves with one row per subject and
one column per response time. With a band, a list with components
\code{pred}, \code{lower}, \code{upper} and \code{tree_pred}, the last being
the array of tree predictions (subjects by response times by trees).
}
\examples{
\dontrun{
dat <- xfrf_sim_data("nonlinear", n = 500, replication = 1)
tr <- dat$train
te <- dat$test
ctrl <- xfrf_sim_settings()$xfrf
set.seed(dat$seeds["fit"])
fit <- xfrf_fit(tr$x, tr$x.scl, tr$y, y_grid = tr$meta$sy,
                n_trees = ctrl$n_trees, mtry = ctrl$mtry,
                min_leaf = ctrl$min_leaf, max_depth = ctrl$max_depth,
                n_thresholds = ctrl$n_thresholds, ridge = ctrl$ridge)
pred <- xfrf_predict(fit, te$x, te$x.scl)

# relative integrated error against the noise-free test curves
ise <- rowSums(sweep((pred - te$yt)^2, 2, fit$forest$w, "*"))
mean(ise) / tr$meta$sigma_y^2

# ensemble band for 200 test subjects
eb <- xfrf_predict(fit, lapply(te$x, function(a) a[1:200, ]),
                   te$x.scl[1:200, ], band_level = 0.95)
inside <- te$y[1:200, ] >= eb$lower & te$y[1:200, ] <= eb$upper
mean(apply(inside, 1, all))
}
}
