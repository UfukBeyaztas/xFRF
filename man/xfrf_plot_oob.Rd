\name{xfrf_plot_oob}
\alias{xfrf_plot_oob}
\title{Plot the Out-of-Bag Error}
\description{
Draws the out-of-bag integrated squared error against the number of trees.
}
\usage{
xfrf_plot_oob(object)
}
\arguments{
\item{object}{an object returned by \code{xfrf_fit}.}
}
\details{
After \eqn{b} trees, the error is the mean over the subjects with at least
one out-of-bag tree of the trapezoidal integrated squared difference between
the response and the out-of-bag prediction. A flat curve indicates that more
trees would change the predictions little.
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
xfrf_plot_oob(fit)
}
}
