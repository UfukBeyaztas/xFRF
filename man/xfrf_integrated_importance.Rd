\name{xfrf_integrated_importance}
\alias{xfrf_integrated_importance}
\title{Integrated Importance of Each Predictor}
\description{
Integrates the grouped or additive importance curves over the response grid.
}
\usage{
xfrf_integrated_importance(importance, object, type = c("grouped", "additive"))
}
\arguments{
\item{importance}{a list returned by \code{xfrf_importance}.}
\item{object}{the fitted object used to compute \code{importance}; its
trapezoidal weights are used.}
\item{type}{\code{"grouped"} for the joint-shuffle curves or
\code{"additive"} for the sums of the coordinate curves.}
}
\details{
The integral uses the trapezoidal weights of the response grid. For the
grouped curves it is the out-of-bag permutation importance of each predictor
under the integrated squared loss of the whole curve.
}
\value{
A named vector with one value per predictor.
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
imp <- xfrf_importance(fit)
sort(xfrf_integrated_importance(imp, fit), decreasing = TRUE)
sort(xfrf_integrated_importance(imp, fit, type = "additive"), decreasing = TRUE)
}
}
