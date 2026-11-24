\name{xfrf_tune}
\alias{xfrf_tune}
\title{Grid Search over the Forest Controls}
\description{
Chooses the forest controls with the smallest cross-validated integrated
squared error over a grid of candidate values.
}
\usage{
xfrf_tune(design, grid, n_fold = 5, loo = FALSE, folds = NULL)
}
\arguments{
\item{design}{an object returned by \code{xfrf_design}.}
\item{grid}{a data frame with columns \code{n_trees}, \code{mtry},
\code{min_leaf} and \code{max_depth}, one row per candidate.}
\item{n_fold}{the number of folds.}
\item{loo}{if \code{TRUE}, leave-one-out cross-validation.}
\item{folds}{an optional list of row indices defining the folds.}
}
\details{
One partition into folds is drawn, or taken from \code{folds}, and used for
every candidate, so the candidates are compared on the same splits. The
criterion is the one computed by \code{xfrf_cv}.
}
\value{
A list with the grid and its cross-validated errors \code{results}, the
best row \code{best} and the \code{folds}.
}
\examples{
\dontrun{
dat <- xfrf_sim_data("nonlinear", n = 250, replication = 1)
des <- xfrf_design(dat$train$x, dat$train$x.scl, dat$train$y,
                   y_grid = dat$train$meta$sy)
grid <- expand.grid(n_trees = 200, mtry = c(10, 18, 30), min_leaf = c(3, 5, 10),
                    max_depth = 20)
set.seed(1)
tun <- xfrf_tune(des, grid, n_fold = 5)
tun$results
tun$best
}
}
