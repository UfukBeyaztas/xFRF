\name{xfrf_plot_surface}
\alias{xfrf_plot_surface}
\title{Plot Importance Surfaces}
\description{
Draws the importance surfaces of functional predictors as images with
contour lines.
}
\usage{
xfrf_plot_surface(importance, predictors = NULL, n_col = 64)
}
\arguments{
\item{importance}{a list returned by \code{xfrf_importance}.}
\item{predictors}{names or indices of the functional predictors to draw; all
by default.}
\item{n_col}{the number of colors of the diverging palette.}
}
\details{
The horizontal axis is predictor time \eqn{s} and the vertical axis is
response time \eqn{t}. Blue marks negative values, which arise when a
shuffled coordinate happens to reduce the out-of-bag error, and red marks
positive values. Several surfaces are arranged on one page.
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
xfrf_plot_surface(imp, predictors = c("func2", "func3"))
}
}
