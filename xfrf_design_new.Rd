\name{xfrf_design_new}
\alias{xfrf_design_new}
\title{Spline Coordinates of New Subjects}
\description{
Computes the feature vectors of new subjects with the knots, degree and ridge
of a training design.
}
\usage{
xfrf_design_new(design, X_funcs = NULL, X_scalars = NULL, argvals = NULL)
}
\arguments{
\item{design}{an object returned by \code{xfrf_design}.}
\item{X_funcs}{a list of matrices of recorded predictor curves of the new
subjects, in the order of the training predictors.}
\item{X_scalars}{a matrix of scalar covariates of the new subjects.}
\item{argvals}{an optional list with the recording grid of each functional
predictor of the new subjects.}
}
\details{
The B-splines and the trapezoidal weights are evaluated on the grid of the
new curves, while the knots, the degree and the ridge stay as in training.
When \code{argvals} is not given, the training grid is used if the number of
recording times agrees, and an equally spaced grid over the training range
otherwise.
}
\value{
The feature matrix of the new subjects, with the columns in training order.
}
\examples{
\dontrun{
tr <- xfrf_dgp(250, model = "smooth")
te <- xfrf_dgp(100, model = "smooth")
des <- xfrf_design(tr$x, tr$x.scl, tr$y, y_grid = tr$meta$sy)
X_new <- xfrf_design_new(des, te$x, te$x.scl)
dim(X_new)

# the same curves recorded on every second grid point
sub <- seq(1, 101, by = 2)
X_sub <- xfrf_design_new(des, lapply(te$x, function(a) a[, sub]), te$x.scl,
                         argvals = rep(list(te$meta$sx[sub]), 5))
summary(as.vector(X_sub - X_new))
}
}
