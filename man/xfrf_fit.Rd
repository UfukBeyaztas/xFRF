\name{xfrf_fit}
\alias{xfrf_fit}
\alias{print.xfrf}
\title{Fit an Explainable Functional Random Forest}
\description{
Encodes the functional predictors by B-spline coordinates and grows a random
forest whose leaves contain mean response curves.
}
\usage{
xfrf_fit(X_funcs = NULL, X_scalars = NULL, y_func, basis = NULL, y_grid = NULL,
         n_trees = 200, mtry = NULL, min_leaf = 5, max_depth = 20,
         n_thresholds = 20, ridge = 1e-8)

\method{print}{xfrf}(x, \dots)
}
\arguments{
\item{X_funcs}{a list of matrices of recorded predictor curves, one row per
subject.}
\item{X_scalars}{a matrix of scalar covariates, or \code{NULL}.}
\item{y_func}{a matrix of recorded response curves, one row per subject.}
\item{basis}{optional basis settings, as in \code{xfrf_design}.}
\item{y_grid}{the response grid. The default is equally spaced on [0, 1].}
\item{n_trees}{the number of trees.}
\item{mtry}{the number of candidate coordinates drawn at each node. The
default is \eqn{\max(1, \lfloor D/3 \rfloor)}{max(1, floor(D / 3))}, where
\eqn{D} is the number of features.}
\item{min_leaf}{the minimum number of subjects in each child.}
\item{max_depth}{the maximum depth of a tree.}
\item{n_thresholds}{the largest number of candidate thresholds per coordinate
and node.}
\item{ridge}{the ridge parameter of the coordinates.}
\item{x}{an object of class \code{"xfrf"}.}
\item{\dots}{not used.}
}
\details{
Each tree is grown on a bootstrap sample of the \eqn{n} subjects. A split of
node \eqn{N} at coordinate \eqn{j} and threshold \eqn{c} sends the subjects
with feature value below \eqn{c} to the left child. Its gain is the
reduction in the trapezoidal integrated sum of squares of the response
curves,
\deqn{\Delta = \frac{|N_L|\,|N_R|}{|N|} \sum_{m} w_m (\bar y_{Lm} - \bar y_{Rm})^2,}{gain = |N_L| |N_R| / |N| * sum_m w_m (ybar_Lm - ybar_Rm)^2,}
where \eqn{w_m} are the trapezoidal weights of the response grid and
\eqn{\bar y_{L}}{ybar_L} and \eqn{\bar y_{R}}{ybar_R} are the child mean
vectors. At fixed parent size the gain grows with the distance between the
child means and, at a fixed distance, favors balanced splits.

At each node \code{mtry} coordinates are drawn without replacement. The
candidate thresholds are midpoints between consecutive distinct values; when
there are more than \code{n_thresholds} of them, \code{n_thresholds} equally
spaced ones are kept. Both children must hold at least \code{min_leaf}
subjects. For each coordinate the first threshold of largest gain is kept,
and a coordinate drawn later replaces the current winner only when its gain
is larger by a relative margin of \eqn{10^{-10}}{1e-10}. A node becomes a
leaf when its impurity is at most \eqn{10^{-12}}{1e-12}, when it holds at
most \code{2 * min_leaf} subjects, when its depth equals \code{max_depth}, or
when no admissible split has positive gain.

The forest prediction averages the leaf mean curves reached by a feature
vector. It is a weighted average of the training curves with nonnegative
weights summing to one, so any property shared by all training curves and
kept by convex combinations, such as nonnegativity, monotonicity or a common
bound, holds for the prediction as well. The out-of-bag error is recorded
after each tree.

The simulation study uses 500 trees and the default values of the other
controls; \code{xfrf_sim_settings} returns them.
}
\value{
An object of class \code{"xfrf"}, a list with components
\item{design}{the encoded training data, as returned by \code{xfrf_design}.}
\item{forest}{a list with the fitted \code{trees}, the bootstrap indices
\code{inbag}, the controls \code{n_trees}, \code{mtry}, \code{min_leaf},
\code{max_depth} and \code{n_thresholds}, the response grid \code{y_grid},
its trapezoidal weights \code{w}, the \code{feature_names} and the
out-of-bag integrated squared error \code{oob_error} after each tree.}
\item{call}{the matched call.}
The print method gives a short summary and returns \code{x} invisibly.
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
fit
xfrf_plot_oob(fit)
}
}
