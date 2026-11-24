\name{xfrf_cv}
\alias{xfrf_cv}
\title{Cross-Validated Prediction Error of the Forest}
\description{
Computes the cross-validated integrated squared error of the forest for given
controls.
}
\usage{
xfrf_cv(design, n_fold = 5, loo = FALSE, folds = NULL, \dots)
}
\arguments{
\item{design}{an object returned by \code{xfrf_design}.}
\item{n_fold}{the number of folds.}
\item{loo}{if \code{TRUE}, leave-one-out cross-validation.}
\item{folds}{an optional list of row indices defining the folds, for example
to keep all curves of one individual together.}
\item{\dots}{the forest controls \code{n_trees}, \code{mtry},
\code{min_leaf}, \code{max_depth} and \code{n_thresholds}.}
}
\details{
For a partition \eqn{\mathfrak P}{P} of the subjects into folds, the
criterion is
\deqn{\mathrm{CV} = \frac{1}{|\mathfrak P|} \sum_{F \in \mathfrak P} \frac{1}{|F|} \sum_{i \in F} \sum_m w_m \{y_{im} - \hat m^{(-F)}(\hat\xi_i)(t_m)\}^2,}{CV = (1/|P|) sum_F (1/|F|) sum_{i in F} sum_m w_m {y_im - m^(-F)(xi_i)(t_m)}^2,}
where \eqn{\hat m^{(-F)}}{m^(-F)} is the forest grown without fold \eqn{F}.
The coordinates of each subject come from its own curves, so the design is
not recomputed in the folds. If the controls are chosen by cross-validation
on the subjects that later supply the out-of-bag importance, the trees
depend on the responses of those subjects through the selection; fixing the
controls in advance, or choosing them on a separate sample, avoids this.
}
\value{
A list with the fold errors \code{fold_error}, their mean \code{cv_error}
and the \code{folds}.
}
\examples{
\dontrun{
dat <- xfrf_sim_data("nonlinear", n = 250, replication = 1)
des <- xfrf_design(dat$train$x, dat$train$x.scl, dat$train$y,
                   y_grid = dat$train$meta$sy)
set.seed(1)
cv <- xfrf_cv(des, n_fold = 5, n_trees = 200, min_leaf = 5)
cv$cv_error / dat$train$meta$sigma_y^2
}
}
