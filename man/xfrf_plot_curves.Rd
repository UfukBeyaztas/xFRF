\name{xfrf_plot_curves}
\alias{xfrf_plot_curves}
\title{Plot Importance Curves}
\description{
Draws grouped or additive importance curves over the response domain.
}
\usage{
xfrf_plot_curves(importance, predictors = NULL, type = c("grouped", "additive"))
}
\arguments{
\item{importance}{a list returned by \code{xfrf_importance}.}
\item{predictors}{names or indices of the predictors to draw; all by
default.}
\item{type}{\code{"grouped"} or \code{"additive"}.}
}
\value{
\code{NULL}, invisibly.
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
xfrf_plot_curves(imp, predictors = c("func1", "scalar1"))
xfrf_plot_curves(imp, predictors = c("func1", "scalar1"), type = "additive")
}
}
