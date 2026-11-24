\name{xfrf_oob}
\alias{xfrf_oob}
\title{Out-of-Bag Predictions}
\description{
Returns the out-of-bag predicted curves of the training subjects.
}
\usage{
xfrf_oob(object)
}
\arguments{
\item{object}{an object returned by \code{xfrf_fit}.}
}
\details{
The out-of-bag prediction of a subject averages the predictions of the trees
whose bootstrap sample does not contain it. A subject that is in every
bootstrap sample has no such tree and receives \code{NA}.
}
\value{
A matrix of out-of-bag predicted curves, one row per training subject.
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
oob <- xfrf_oob(fit)
res_sd <- apply(tr$y - oob, 2, sd, na.rm = TRUE)
plot(tr$meta$sy, res_sd, type = "l", xlab = "t",
     ylab = "out-of-bag residual standard deviation")
}
}
