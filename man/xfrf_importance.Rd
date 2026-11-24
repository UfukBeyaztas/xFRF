\name{xfrf_importance}
\alias{xfrf_importance}
\title{Out-of-Bag Importance Curves and Surfaces}
\description{
Computes grouped importance curves of all predictors, importance curves of
the single spline coordinates, and importance surfaces of the functional
predictors.
}
\usage{
xfrf_importance(object, n_perm = 1)
}
\arguments{
\item{object}{an object returned by \code{xfrf_fit}.}
\item{n_perm}{the number of permutations per tree and coordinate for the
coordinate curves.}
}
\details{
Let \eqn{O_b} be the out-of-bag set of tree \eqn{b}, \eqn{N_b} its size and
\eqn{T_b} the tree. For a set \eqn{G} of coordinates and a permutation
\eqn{\sigma}{sigma} of \eqn{O_b}, the score of the tree at response time
\eqn{t_m} is
\deqn{D_{Gb}(t_m) = \frac{1}{N_b} \sum_{i \in O_b} \Big[\{y_{im} - T_b(\hat\xi_i^{(G,\sigma)})(t_m)\}^2 - \{y_{im} - T_b(\hat\xi_i)(t_m)\}^2\Big],}{D_Gb(t_m) = (1/N_b) sum_{i in O_b} [ {y_im - T_b(xi_i^(G,sigma))(t_m)}^2 - {y_im - T_b(xi_i)(t_m)}^2 ],}
where \eqn{\hat\xi_i^{(G,\sigma)}}{xi_i^(G,sigma)} takes the coordinates in
\eqn{G} from subject \eqn{\sigma(i)}{sigma(i)} and keeps the response and the
other coordinates of subject \eqn{i}.

The grouped curve of a predictor takes \eqn{G} to be its whole block, uses
one permutation per tree for all predictors, and averages over the trees
with a nonempty out-of-bag set. Exchanging the whole block keeps the joint
distribution of the coordinates of a curve, so the curve shows what is lost
at each response time when the predictor is replaced by that of another
subject. Its integral over \eqn{t} is the out-of-bag importance under the
integrated squared loss. The coordinate curve of a single coordinate uses
\code{n_perm} permutations per tree and divides the total by the number of
trees, trees with an empty out-of-bag set contributing zero. The additive
curve of a predictor is the sum of its coordinate curves. It differs from
the grouped curve in general, because the coordinates of a curve are
dependent and can interact in the trees.

The importance surface of functional predictor \eqn{p} is
\deqn{S_p(s, t_m) = \sum_{k=1}^{K_p} \phi_{pk}(s)\, \mathrm{VI}_{(p,k)}(t_m),}{S_p(s, t_m) = sum_k phi_pk(s) VI_pk(t_m),}
on the training grid of the predictor. Since the B-splines are nonnegative
and sum to one, \eqn{S_p(s, t_m)} is a weighted average of the importances of
the coordinates whose basis functions are positive at \eqn{s}. A coordinate
can still depend on recorded values outside the support of its basis
function, so the surface shows where the fitted forest uses the spline
coordinates rather than which recording times drive the response.

A uniform permutation returns a subject its own block with probability
\eqn{1/N_b}. Given the fitted tree, the expected score of the tree is
therefore \eqn{1 - 1/N_b} times the increase of its mean squared error when
the block is replaced by that of an independent subject. When the block is
independent of the other inputs, this expectation equals
\eqn{2(1 - 1/N_b)} times the expected covariance, conditional on the other
coordinates, between the tree prediction and the regression function on the
coordinates, and it is zero whenever the block is also independent of the
response and the other inputs. Repeated curves of one individual are not
independent subjects, and their out-of-bag scores should be read as
descriptive.

The grouped curves are computed first, then the coordinate curves, so a call
made right after the fitted forest with the seed of \code{xfrf_sim_data}
reproduces the out-of-bag importance of the simulation study.
}
\value{
A list with components
\item{grouped}{the grouped importance curves, one row per predictor.}
\item{additive}{the sums of the coordinate curves, one row per predictor.}
\item{coordinate}{the coordinate importance curves, one row per feature.}
\item{surface}{a list with the importance surface of each functional
predictor, rows indexing predictor time and columns response time.}
\item{s}{the predictor grids of the surfaces.}
\item{t}{the response grid.}
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
imp <- xfrf_importance(fit)

# integrated importance and the population reference of the design
est <- xfrf_integrated_importance(imp, fit)
ref <- drop(tr$meta$vi_true[names(est), ] \%*\% fit$forest$w)
round(cbind(estimate = est, reference = ref), 4)

xfrf_plot_curves(imp, predictors = c("func1", "func2", "func3",
                                     "scalar1", "scalar2", "scalar3"))
xfrf_plot_surface(imp, predictors = c("func2", "func3"))
}
}
