\name{xfrf_dgp}
\alias{xfrf_dgp}
\title{Generate Data from the Simulation Designs}
\description{
Generates functional predictors, scalar covariates and response curves from
the linear, threshold-and-interaction and smooth additive designs of the
simulation study.
}
\usage{
xfrf_dgp(n, model = c("linear", "nonlinear", "smooth"), j = 101, n_func = 5,
         n_scl = 5, sigma_y = 0.2, snr = 4, shares = NULL, nl_delta = 0.1,
         x_level_sd = c(1, 0.5, 0.5, 1, 0.5), x_gp_sd = c(0.3, 1, 1, 0.3, 1),
         x_range = 0.3, x_centers = c(0.5, 0.2, 0.8),
         x_widths = c(Inf, 0.06, 0.06), x_noise_sd = 0.1, noise_range = 0.1,
         mu_y = function(t) 1.5 * sin(pi * t) + 0.5 * t, jy = j)
}
\arguments{
\item{n}{the number of subjects.}
\item{model}{\code{"linear"}, \code{"nonlinear"} for thresholds and
interactions, or \code{"smooth"} for smooth additive effects.}
\item{j}{the number of equally spaced recording times of the predictors on
[0, 1].}
\item{n_func, n_scl}{the numbers of functional predictors and scalar
covariates, each at least three.}
\item{sigma_y}{the square root of the integrated variance of the noise-free
response.}
\item{snr}{the signal-to-noise ratio \eqn{\sigma_y^2/\sigma_\varepsilon^2}{sigma_y^2 / sigma_eps^2}.}
\item{shares}{the shares of the integrated signal variance of the
components; by default (0.22, 0.18, 0.15, 0.18, 0.15, 0.12) for the linear
model, (0.20, 0.20, 0.25, 0.15, 0.20) for the nonlinear model and equal
shares for the smooth model.}
\item{nl_delta}{the width of the smooth threshold
\eqn{\tau(u) = \tanh(u/\delta)}{tau(u) = tanh(u / delta)}.}
\item{x_level_sd, x_gp_sd}{the standard deviations of the random level and of
the Gaussian process of each functional predictor.}
\item{x_range}{the range of the Matern covariance of the predictor
processes.}
\item{x_centers, x_widths}{the centres and widths of the windows of the three
active predictors; an infinite width gives a constant window.}
\item{x_noise_sd}{the standard deviation of the recording errors.}
\item{noise_range}{the range of the Matern covariance of the response
errors.}
\item{mu_y}{the mean response function.}
\item{jy}{the number of equally spaced response times on [0, 1].}
}
\details{
Functional predictor \eqn{p} is
\deqn{X^{(p)}(s) = \mu_p(s) + L_p + G_p(s), \qquad \mu_p(s) = 0.5 \sin\{2\pi(s + (p-1)/P)\},}{X_p(s) = mu_p(s) + L_p + G_p(s),  mu_p(s) = 0.5 sin{2 pi (s + (p - 1)/P)},}
with a centred normal level \eqn{L_p} of standard deviation
\code{x_level_sd[p]} and an independent centred Gaussian process \eqn{G_p}
with Matern covariance of smoothness 5/2, range \code{x_range} and standard
deviation \code{x_gp_sd[p]}. Each curve is recorded at \code{j} equally
spaced times with independent normal errors of standard deviation
\code{x_noise_sd}. The scalar covariates are independent standard normal
variables, independent of the curves. With the default settings the first
and fourth curves vary mainly in level and the others mainly locally, so
each family of active curves has an inactive member with the same
distribution.

Only the first three curves and the first three scalars enter the signal.
The curves act through the standardized indices
\deqn{U_p = \sigma_{u,p}^{-1} \sum_j v_j a_p(s_j) \{X^{(p)}(s_j) - \mu_p(s_j)\}, \qquad p = 1, 2, 3,}{U_p = sum_j v_j a_p(s_j) {X_p(s_j) - mu_p(s_j)} / sigma_up,  p = 1, 2, 3,}
computed from the curves before recording errors, where \eqn{v_j} are
trapezoidal weights, \eqn{a_p} has unit trapezoidal integral, and
\eqn{\sigma_{u,p}}{sigma_up} makes \eqn{U_p} standard normal. With the
defaults \eqn{a_1} is constant and \eqn{a_2} and \eqn{a_3} are Gaussian
windows with standard deviation 0.06 centred at 0.2 and 0.8. The noise-free
response is
\deqn{m(t) = \mu_y(t) + \sum_{r} b_r(t) H_r,}{m(t) = mu_y(t) + sum_r b_r(t) H_r,}
with uncorrelated scores \eqn{H_r} of mean zero and variance one. Writing
\eqn{T_p}{T_p} for \eqn{\tau(U_p)}{tau(U_p)} divided by its standard
deviation, the scores are
\describe{
\item{linear}{\eqn{(U_1, U_2, U_3, Z_1, Z_2, Z_3)}.}
\item{nonlinear}{\eqn{T_1}, \eqn{T_1 \mathrm{sign}(Z_1)}{T_1 sign(Z_1)},
\eqn{T_2 1\{Z_1 > 0\} + T_3 1\{Z_1 \le 0\}}{T_2 1{Z_1 > 0} + T_3 1{Z_1 <= 0}},
\eqn{\mathrm{sign}(Z_2)}{sign(Z_2)} and
\eqn{T_1 \mathrm{sign}(Z_3)}{T_1 sign(Z_3)}, so that the first scalar
switches between the effects of the second and third curves and reverses
part of the effect of the first.}
\item{smooth}{the standardized versions of \eqn{\tanh(U_1)}{tanh(U_1)},
\eqn{\log(1 + e^{U_2})}{log(1 + exp(U_2))}, \eqn{\exp(-U_3^2/2)}{exp(-U_3^2 / 2)},
\eqn{Z_1}, \eqn{(Z_2^2 - 1)/\sqrt 2}{(Z_2^2 - 1) / sqrt(2)} and
\eqn{\sin(\pi Z_3/2)}{sin(pi Z_3 / 2)}.}
}
The response profiles \eqn{b_r} are scaled versions of two Gaussian bumps
centred at 0.2 and 0.75 with standard deviation 0.1, \eqn{\sin(\pi t)}{sin(pi t)},
a logistic rise at 0.5, \eqn{\exp(-3t)}{exp(-3 t)} and \eqn{\cos(2\pi t)}{cos(2 pi t)},
in this order; the nonlinear model uses the first five. Component \eqn{r}
contributes the share \code{shares[r]} of the integrated signal variance
\eqn{\sigma_y^2}{sigma_y^2} on the response grid. The observed response adds
a centred Gaussian process with Matern covariance of smoothness 3/2, range
\code{noise_range} and variance \eqn{\sigma_y^2/\mathrm{snr}}{sigma_y^2 / snr}.

The population importance of a predictor at response time \eqn{t} is the
mean squared change of \eqn{m(t)} when that predictor is replaced by an
independent copy. It is computed exactly and is zero for the inactive
predictors.
}
\value{
A list with components
\item{y}{the recorded response curves, one row per subject.}
\item{yt}{the noise-free response curves.}
\item{x}{a list of recorded predictor curves named \code{func1},
\code{func2}, and so on.}
\item{x.scl}{the matrix of scalar covariates, with columns \code{scalar1},
\code{scalar2}, and so on.}
\item{meta}{a list with the grids \code{sx} and \code{sy}, the population
importance curves \code{vi_true}, the windows \code{s_relevance}, the
coefficient surfaces \code{beta_func} and curves \code{beta_scalar} of the
linear model (\code{NULL} otherwise), the names of the active and inactive
predictors, the response \code{profiles}, the scaled \code{component_curves},
the \code{scores}, the indices \code{u}, the mean curves \code{mu_y} and
\code{mu_x}, \code{sigma_y}, \code{sigma_eps}, \code{snr} and the remaining
settings.}
}
\examples{
\dontrun{
set.seed(1)
lin <- xfrf_dgp(500, model = "linear")
nl <- xfrf_dgp(500, model = "nonlinear")
sm <- xfrf_dgp(500, model = "smooth")

matplot(lin$meta$sx, t(lin$x$func2[1:5, ]), type = "l", lty = 1,
        xlab = "s", ylab = "recorded func2")
matplot(nl$meta$sy, t(nl$y[1:5, ]), type = "l", lty = 1,
        xlab = "t", ylab = "response")

# integrated population importance in each design
w <- c(0.5, rep(1, 99), 0.5) / 100
round(cbind(linear = lin$meta$vi_true \%*\% w, nonlinear = nl$meta$vi_true \%*\% w,
            smooth = sm$meta$vi_true \%*\% w), 4)
}
}
