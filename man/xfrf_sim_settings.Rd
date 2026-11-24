\name{xfrf_sim_settings}
\alias{xfrf_sim_settings}
\title{Settings of the Simulation Study}
\description{
Returns the design cells, the sample sizes and the fixed forest controls of
the simulation study.
}
\usage{
xfrf_sim_settings()
}
\details{
The study crosses the three models of \code{xfrf_dgp} with training sizes
100, 250 and 500, with 100 repetitions per cell and 1000 test subjects per
repetition. Curves are recorded at 101 equally spaced times, the integrated
signal variance is 0.04 and the signal-to-noise ratio is four. The forest
uses ten cubic B-spline coordinates per curve, 500 trees, one third of the
55 features at each node, minimum child size five, maximum depth 20, at most
20 thresholds and ridge \eqn{10^{-8}}{1e-8}. Calibrated bands use 30 percent
of the training subjects for calibration.
}
\value{
A list with the data frame \code{design} of the nine cells, \code{n_rep},
\code{n_test}, \code{j}, \code{sigma_y}, \code{snr}, the base \code{seed},
the list \code{xfrf} of forest controls, \code{cal_share} and the
miscoverage levels \code{alpha}.
}
\examples{
\dontrun{
st <- xfrf_sim_settings()
st$design
str(st$xfrf)
}
}
