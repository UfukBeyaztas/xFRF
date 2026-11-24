\name{xfrf_sim_data}
\alias{xfrf_sim_data}
\title{Data of One Repetition of the Simulation Study}
\description{
Generates the training sample, the test sample and the calibration split of
one repetition of the simulation study, together with the seeds used there.
}
\usage{
xfrf_sim_data(model = c("linear", "nonlinear", "smooth"), n = 100,
              replication = 1, seed = 2026, n_test = 1000)
}
\arguments{
\item{model}{\code{"linear"}, \code{"nonlinear"} or \code{"smooth"}.}
\item{n}{the training size, 100, 250 or 500.}
\item{replication}{the repetition number.}
\item{seed}{the base seed of the study.}
\item{n_test}{the number of test subjects.}
}
\details{
Let \eqn{a} be the position of \code{model} in (linear, nonlinear, smooth)
and \eqn{k} the position of \code{n} in (100, 250, 500). The test sample is
generated with seed \eqn{\mathrm{seed} + 10^8 a + r}{seed + 1e8 a + r} and the
training sample with \eqn{\mathrm{seed} + 10^8 a + 10^6 k + r}{seed + 1e8 a + 1e6 k + r},
\eqn{r} being the repetition, so a test sample is shared by the three
training sizes of a model and repetition. The calibration subjects, 30
percent of the training sample, are drawn with the training seed plus
\eqn{5 \times 10^5}{5e5}. Setting the seed \code{seeds["fit"]} and then
calling \code{xfrf_fit} with the controls of \code{xfrf_sim_settings} and
then \code{xfrf_importance} reproduces the forest and the out-of-bag
importance of that repetition. Setting \code{seeds["band"]} and then calling
\code{xfrf_conformal} with \code{cal} reproduces its calibrated bands.

The function calls \code{set.seed} and therefore changes the random number
stream of the session. Exact reproduction requires the default generators
of R (Mersenne-Twister, Inversion and Rejection).
}
\value{
A list with components
\item{train}{the training sample, as returned by \code{xfrf_dgp}.}
\item{test}{the test sample.}
\item{cal}{the sorted row indices of the calibration subjects.}
\item{seeds}{the named seeds \code{test}, \code{train}, \code{split},
\code{fit} and \code{band}.}
}
\examples{
\dontrun{
# relative integrated error of xFRF in the first five repetitions of the
# threshold-and-interaction design with 250 training subjects
ctrl <- xfrf_sim_settings()$xfrf
err <- numeric(5)
for (r in 1:5) {
  dat <- xfrf_sim_data("nonlinear", n = 250, replication = r)
  tr <- dat$train
  te <- dat$test
  set.seed(dat$seeds["fit"])
  fit <- xfrf_fit(tr$x, tr$x.scl, tr$y, y_grid = tr$meta$sy,
                  n_trees = ctrl$n_trees, mtry = ctrl$mtry,
                  min_leaf = ctrl$min_leaf, max_depth = ctrl$max_depth,
                  n_thresholds = ctrl$n_thresholds, ridge = ctrl$ridge)
  pred <- xfrf_predict(fit, te$x, te$x.scl)
  err[r] <- mean(rowSums(sweep((pred - te$yt)^2, 2, fit$forest$w, "*"))) /
    tr$meta$sigma_y^2
}
err
}
}
