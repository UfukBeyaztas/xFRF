\name{xfrf_conformal}
\alias{xfrf_conformal}
\title{Split-Conformal Simultaneous Prediction Bands}
\description{
Fits the forest on a proper training set and calibrates simultaneous
prediction bands on the remaining subjects.
}
\usage{
xfrf_conformal(X_funcs = NULL, X_scalars = NULL, y_func, cal,
               alpha = c(0.05, 0.10), id = NULL, rel_floor = 1e-8,
               abs_floor = 0, \dots)
}
\arguments{
\item{X_funcs}{a list of matrices of recorded predictor curves.}
\item{X_scalars}{a matrix of scalar covariates, or \code{NULL}.}
\item{y_func}{a matrix of recorded response curves.}
\item{cal}{the row indices of the calibration subjects. The other rows form
the proper training set.}
\item{alpha}{the miscoverage levels.}
\item{id}{an optional vector of record identifiers, one per row, for data
with several curves per record.}
\item{rel_floor, abs_floor}{floors of the standard deviation modulation.}
\item{\dots}{further arguments of \code{xfrf_fit}, such as \code{y_grid} and
the forest controls.}
}
\details{
The forest \eqn{\hat f}{f} is fitted on the proper training set. Two
modulation curves are formed from that set alone: \eqn{u = 1}, and the
pointwise standard deviation of the out-of-bag residuals, floored as
\eqn{u(t_m) = \max\{\mathrm{sd}(t_m), c_r \max_l \mathrm{sd}(t_l), c_a\}}{u(t_m) = max{sd(t_m), c_r max_l sd(t_l), c_a}}
with \eqn{c_r} = \code{rel_floor} and \eqn{c_a} = \code{abs_floor}. The score
of a calibration record is
\deqn{S_i = \max_{m} \frac{|Y_i(t_m) - \hat f(\hat\xi_i)(t_m)|}{u(t_m)},}{S_i = max_m |Y_i(t_m) - f(xi_i)(t_m)| / u(t_m),}
the maximum running also over all curves of the record when \code{id} is
given. With \eqn{n_{cal}}{n_cal} calibration records and
\eqn{k = \lceil (n_{cal} + 1)(1 - \alpha) \rceil}{k = ceiling((n_cal + 1)(1 - alpha))},
the cutoff \eqn{q} is the \eqn{k}th smallest score, or infinity when
\eqn{k > n_{cal}}{k > n_cal}. The band at a new input \eqn{x} is
\eqn{\hat f(x)(t_m) \pm q\, u(t_m)}{f(x)(t_m) +/- q u(t_m)} on the recorded
response grid.

If the calibration records and a new record are exchangeable given the
proper training set, the band contains the new record at every recorded time
with probability at least \eqn{1 - \alpha}{1 - alpha}. The guarantee is
marginal over the new record and says nothing about times between grid
points. When an individual contributes several curves, calibration and
testing must treat its curves as one record, which is what \code{id} does,
and no record may appear in both the proper training and the calibration
set.

The simulation study calibrates on 30 percent of the training subjects,
given by \code{xfrf_sim_data}, with \code{rel_floor = 1e-8} and
\code{abs_floor = 0}.
}
\value{
An object of class \code{"xfrf_conformal"}, a list with components
\item{fit}{the forest fitted on the proper training set.}
\item{alpha}{the miscoverage levels.}
\item{u}{the modulation curves \code{constant} and \code{sd}.}
\item{q}{the cutoffs, one row per level and one column per modulation.}
\item{scores}{the sorted calibration scores for each modulation.}
\item{n_cal}{the number of calibration records.}
\item{train, cal}{the row indices of the proper training and calibration
sets.}
}
\examples{
\dontrun{
dat <- xfrf_sim_data("nonlinear", n = 500, replication = 1)
tr <- dat$train
te <- dat$test
ctrl <- xfrf_sim_settings()$xfrf
set.seed(dat$seeds["band"])
cf <- xfrf_conformal(tr$x, tr$x.scl, tr$y, cal = dat$cal, alpha = c(0.05, 0.10),
                     y_grid = tr$meta$sy, n_trees = ctrl$n_trees,
                     mtry = ctrl$mtry, min_leaf = ctrl$min_leaf,
                     max_depth = ctrl$max_depth)
cf$q

band <- xfrf_conformal_band(cf, te$x, te$x.scl, alpha = 0.05,
                            modulation = "constant")
mean(apply(te$y >= band$lower & te$y <= band$upper, 1, all))
mean(rowSums(sweep(band$upper - band$lower, 2, cf$fit$forest$w, "*")))
}
}
