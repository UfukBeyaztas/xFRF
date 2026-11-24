\name{xFRF-package}
\alias{xFRF-package}
\alias{xFRF}
\docType{package}
\title{Explainable Functional Random Forests for Functional Responses}
\description{
Random forests that predict a response curve from functional predictors
observed on grids and from scalar covariates, with permutation importance
resolved over response time and over predictor time.
}
\details{
Each functional predictor is replaced by its ridge-stabilized least-squares
coordinates in a clamped B-spline basis, computed with trapezoidal weights on
its own recording grid. The trees split on these coordinates and on the
scalar covariates. The split criterion is the trapezoidal integrated sum of
squares of the response curves, so one partition serves the whole curve, and
each leaf stores the mean response vector of its subjects. The forest
averages the leaf curves, which makes every prediction a convex combination
of the training curves.

Shuffling a whole predictor among the out-of-bag subjects of each tree gives
an importance curve over response time. Shuffling the spline coordinates one
at a time gives one curve per coordinate, and weighting these curves by the
B-spline values at predictor time \eqn{s} gives an importance surface over
\eqn{(s, t)}. For a predictor block that is independent of the other inputs,
the expected out-of-bag score of a tree is \eqn{2(1 - 1/N_b)}{2(1 - 1/N_b)}
times an expected conditional covariance between the tree and the regression
function, where \eqn{N_b} is the size of its out-of-bag set.

Further functions compute the smallest change of selected recording times
that moves a query to another leaf, tree-quantile ensemble bands,
split-conformal simultaneous bands, cross-validation over the forest
controls, and the three simulation designs used to study the method: a
linear model, a model with thresholds and interactions, and a smooth
additive model.

The main functions are \code{xfrf_fit}, \code{xfrf_predict},
\code{xfrf_importance} and \code{xfrf_conformal}. \code{xfrf_sim_data}
returns the data of any repetition of the simulation study.
}
\author{
Ufuk Beyaztas

Maintainer: Ufuk Beyaztas <ufuk.beyaztas@marmara.edu.tr>
}
\keyword{package}
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
fit

pred <- xfrf_predict(fit, te$x, te$x.scl)
ise <- rowSums(sweep((pred - te$yt)^2, 2, fit$forest$w, "*"))
mean(ise) / tr$meta$sigma_y^2

imp <- xfrf_importance(fit)
round(xfrf_integrated_importance(imp, fit), 4)
xfrf_plot_curves(imp, predictors = c("func1", "func2", "func3",
                                     "scalar1", "scalar2", "scalar3"))
xfrf_plot_surface(imp, predictors = c("func2", "func3"))
}
}
