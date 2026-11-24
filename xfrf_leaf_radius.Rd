\name{xfrf_leaf_radius}
\alias{xfrf_leaf_radius}
\title{Smallest Change of Selected Recording Times That Moves a Query to
Another Leaf}
\description{
For one query subject and one functional predictor, computes for every tree
the smallest weighted norm of a change of the recorded values, allowed only
at selected recording times, that moves the query to another leaf, and the
resulting bound on the change of the forest prediction.
}
\usage{
xfrf_leaf_radius(object, X_funcs = NULL, X_scalars = NULL, argvals = NULL,
                 predictor, E, r = NULL)
}
\arguments{
\item{object}{an object returned by \code{xfrf_fit}.}
\item{X_funcs}{a list of matrices with the recorded predictor curves of the
query; only the first row is used.}
\item{X_scalars}{a matrix with the scalar covariates of the query.}
\item{argvals}{optional recording grids of the query curves.}
\item{predictor}{the name or the index of the functional predictor that is
changed.}
\item{E}{the indices of the recording times at which changes are allowed.}
\item{r}{an optional vector of perturbation sizes for the bound.}
}
\details{
Let \eqn{v_j} be the trapezoidal weights of the query grid of the predictor
and \eqn{A = (B^\top W B + \rho I)^{-1} B^\top W}{A = (B'WB + rho I)^(-1) B'W}
its encoder matrix. A change \eqn{h} of the recorded vector that vanishes
outside \eqn{E} moves the coordinates of the predictor by \eqn{Ah} and leaves
the other features unchanged. Put
\deqn{L_{k,E} = \Big(\sum_{j \in E} A_{kj}^2 / v_j\Big)^{1/2}, \qquad \|h\|_W = \Big(\sum_j v_j h_j^2\Big)^{1/2}.}{L_kE = (sum_{j in E} A_kj^2 / v_j)^(1/2),  ||h||_W = (sum_j v_j h_j^2)^(1/2).}
For a node \eqn{u} on the query path of tree \eqn{b} that splits on
coordinate \eqn{k(u)} of the predictor, let \eqn{d_u} be the distance
between the query coordinate and the threshold. The infimum of
\eqn{\|h\|_W}{||h||_W} over the allowed changes that move the query to
another leaf of tree \eqn{b} is
\deqn{r_{b,E} = \min_{u:\, L_{k(u),E} > 0} d_u / L_{k(u),E},}{r_bE = min over u with L_k(u)E > 0 of d_u / L_k(u)E,}
and it is infinite when there is no such node. The infimum for changing the
leaf of at least one tree is the minimum over the trees. If \eqn{D_{bm}} is
the largest absolute difference at \eqn{t_m} between the query leaf mean and
any leaf mean of tree \eqn{b}, every allowed change with
\eqn{\|h\|_W \le r}{||h||_W <= r} moves the forest prediction at \eqn{t_m}
by at most
\deqn{\frac{1}{B} \sum_{b=1}^{B} D_{bm}\, 1\{r_{b,E} \le r\}.}{(1/B) sum_b D_bm 1{r_bE <= r}.}

The radius is measured on the recorded values before the spline fit. A
change at one recording time can move several coordinates, and a coordinate
can react to recording times outside the support of its basis function, so
recording times where an importance surface is zero can still change the
prediction.
}
\value{
A list with components
\item{radius}{the radius \eqn{r_{b,E}}{r_bE} of each tree.}
\item{min_radius}{the smallest radius over the trees.}
\item{spread}{the matrix of \eqn{D_{bm}}, one row per tree and one column
per response time.}
\item{bound}{the bound on the change of the prediction, one row per value of
\code{r} and one column per response time, or \code{NULL}.}
\item{encoder}{the encoder matrix \eqn{A} of the predictor on the query
grid.}
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
q_f <- lapply(te$x, function(a) a[1, , drop = FALSE])
q_s <- te$x.scl[1, , drop = FALSE]
s <- tr$meta$sx

# changes near the window of the second predictor and far from it
near <- which(abs(s - 0.2) <= 0.1)
far <- which(abs(s - 0.8) <= 0.1)
rn <- xfrf_leaf_radius(fit, q_f, q_s, predictor = "func2", E = near,
                       r = c(0.1, 0.2, 0.5))
rf <- xfrf_leaf_radius(fit, q_f, q_s, predictor = "func2", E = far,
                       r = c(0.1, 0.2, 0.5))
c(near = rn$min_radius, far = rf$min_radius)
apply(rn$bound, 1, max)
}
}
