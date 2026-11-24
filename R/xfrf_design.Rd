\name{xfrf_design}
\alias{xfrf_design}
\title{Spline Coordinates of Functional Predictors}
\description{
Builds the feature matrix used by the forest: the scalar covariates followed
by the B-spline coordinates of each functional predictor.
}
\usage{
xfrf_design(X_funcs = NULL, X_scalars = NULL, y_func = NULL, basis = NULL,
            y_grid = NULL, ridge = 1e-8)
}
\arguments{
\item{X_funcs}{a list of matrices, one per functional predictor, with one row
per subject and one column per recording time. A single matrix is accepted
when there is one predictor. List names are used as predictor names when
present; otherwise the predictors are called \code{func1}, \code{func2}, and
so on.}
\item{X_scalars}{a matrix of scalar covariates with one row per subject, or
\code{NULL}. Unnamed columns are called \code{scalar1}, \code{scalar2}, and
so on.}
\item{y_func}{a matrix of recorded response curves, one row per subject, or
\code{NULL}.}
\item{basis}{an optional list with one element per functional predictor. An
element may contain \code{argvals} (the recording grid), \code{nbasis} (the
number of B-splines) and \code{degree} (the polynomial degree, that is, the
order minus one).}
\item{y_grid}{the response grid. The default is equally spaced on [0, 1].}
\item{ridge}{the ridge parameter of the coordinates.}
}
\details{
For a predictor recorded at \eqn{s_1 < \cdots < s_G}{s_1 < ... < s_G}, let
\eqn{B} be the \eqn{G \times K}{G x K} matrix of B-spline values, \eqn{W} the
diagonal matrix of trapezoidal weights and \eqn{x} the recorded vector of a
subject. Its coordinates are
\deqn{\hat c = (B^\top W B + \rho I)^{-1} B^\top W x,}{c = (B'WB + rho I)^(-1) B'W x,}
the minimizer of the weighted residual sum of squares plus \eqn{\rho}{rho}
times the squared Euclidean norm of the coefficients. With
\eqn{\rho = 0}{rho = 0} this is the discrete least-squares spline fit, which
needs \eqn{B} to have full column rank. A small positive ridge changes the
axes on which the trees split but, under full column rank, not the
information that the coordinates carry about the recorded curve.

By default the grid is equally spaced on [0, 1], the splines are cubic,
\eqn{K = \min\{10, \max(4, [G/10])\}}{K = min(10, max(4, [G/10]))} with
\eqn{[\cdot]}{[.]} rounding to the nearest integer and ties to the even one,
and the interior knots are empirical quantiles of the grid. The coordinates
of a subject depend only on its own curves, so the encoding does not change
when the subjects are divided into folds.
}
\value{
An object of class \code{"xfrf_design"}, a list with components
\item{X}{the \eqn{n \times D}{n x D} feature matrix, \eqn{D} being the number
of scalar covariates plus the total number of B-splines.}
\item{Y}{the response matrix.}
\item{y_grid}{the response grid.}
\item{basis}{for each functional predictor, the basis matrix \code{B} on the
training grid, the grid \code{argvals}, \code{degree}, \code{knots},
\code{boundary}, the trapezoidal weights \code{w} and the columns \code{cols}
of \code{X} that hold its coordinates.}
\item{groups}{the columns of \code{X} that belong to each predictor.}
\item{type}{\code{"scalar"} or \code{"functional"} for each predictor.}
\item{feature_names}{the column names of \code{X}.}
\item{ridge}{the ridge parameter.}
\item{n}{the number of subjects.}
}
\examples{
\dontrun{
dat <- xfrf_dgp(250, model = "linear")
des <- xfrf_design(dat$x, dat$x.scl, dat$y, y_grid = dat$meta$sy)
dim(des$X)
des$groups$func2
matplot(des$basis$func2$argvals, des$basis$func2$B, type = "l",
        xlab = "s", ylab = "B-spline")
}
}
