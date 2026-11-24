# xFRF: explainable functional random forests

xFRF is an R package for predicting a whole response curve from functional predictors, scalar covariates, or both. Along with the predictions, it shows which inputs the forest relies on and in which part of the response curve.

Each functional predictor is reduced to a few B-spline coordinates, computed on the grid where that curve was recorded. The trees split on these coordinates and on the scalar covariates. A split is chosen by how much it reduces the integrated squared error of the response curves, so one partition serves the whole curve. Every leaf stores the mean curve of its subjects, and the forest averages the leaf curves of its trees. As a result, each prediction is a weighted average of the training curves.

Importance is measured on the out-of-bag subjects of each tree. Shuffling a whole predictor among those subjects gives an importance curve over response time. Shuffling the spline coordinates one at a time, and weighting the results by the B-spline values, gives an importance surface over predictor time and response time. The surface shows where along a predictor curve the forest picks up information, and for which part of the response.

The package also includes:

- split-conformal prediction bands that contain a whole new curve at the recorded times with the nominal probability;
- the smallest change of chosen recording times that moves a subject to another leaf, with a bound on how much the prediction can change;
- cross-validation and grid search over the forest controls;
- the three simulation designs of the accompanying paper, with a function that rebuilds any repetition of the study exactly.

## Installation

xFRF is written in plain R, so no compiler or Rtools is needed. It requires R 3.6.0 or later and depends only on packages that come with R (graphics, grDevices, splines, stats and utils).

Install it from GitHub with the remotes package:

```r
install.packages("remotes")
remotes::install_github("UfukBeyaztas/xFRF")
```
Then load the package:

```r
library(xFRF)
```

## User manual

The reference manual, with every help page, is in this repository: [xFRF_0.1.0.pdf](xFRF_0.1.0.pdf). After installation, the same pages are available inside R, for example through `help(package = "xFRF")` or `?xfrf_fit`. Each help page gives the method behind the function and an example built on the simulation designs of the paper.

## A first example

The data below come from the simulation design with thresholds and interactions. It has five functional predictors and five scalar covariates; only the first three of each affect the response. `xfrf_sim_data()` returns the training set, the test set and the seeds of one repetition of the study.

```r
library(xFRF)

dat <- xfrf_sim_data("nonlinear", n = 250, replication = 1)
tr <- dat$train
te <- dat$test

set.seed(dat$seeds["fit"])
fit <- xfrf_fit(X_funcs = tr$x, X_scalars = tr$x.scl, y_func = tr$y,
                y_grid = tr$meta$sy, n_trees = 200)
fit

# prediction error relative to the variance of the noise-free curves
pred <- xfrf_predict(fit, te$x, te$x.scl)
ise <- rowSums(sweep((pred - te$yt)^2, 2, fit$forest$w, "*"))
mean(ise) / tr$meta$sigma_y^2

# out-of-bag importance
imp <- xfrf_importance(fit)
sort(xfrf_integrated_importance(imp, fit), decreasing = TRUE)

xfrf_plot_curves(imp, predictors = c("func1", "scalar1"))
xfrf_plot_surface(imp, predictors = c("func2", "func3"))
```

On a desktop computer, the fit takes about a minute and a half, and the importance calculation about half a minute. In this example the six active inputs rank above the four inactive ones. The surfaces of `func2` and `func3` concentrate near predictor times 0.2 and 0.8, where those curves enter the response.

## Prediction bands

The bands of `xfrf_conformal()` use part of the training data for calibration. They are simultaneous: under exchangeability, a new curve lies inside the band at every recorded time with probability at least 1 - alpha. When an individual contributes several curves, pass an `id` vector, so that calibration treats each individual as one record.

```r
set.seed(dat$seeds["band"])
cf <- xfrf_conformal(tr$x, tr$x.scl, tr$y, cal = dat$cal, alpha = c(0.05, 0.10),
                     y_grid = tr$meta$sy, n_trees = 200)

band <- xfrf_conformal_band(cf, te$x, te$x.scl, alpha = 0.05, modulation = "sd")
mean(apply(te$y >= band$lower & te$y <= band$upper, 1, all))
```

`xfrf_predict(fit, ..., band_level = 0.95)` also returns quantiles of the individual tree predictions. These show how much the trees disagree, but they are not calibrated and usually cover far less than the nominal level.

## Which recording times can change a prediction

The coordinate of a B-spline can depend on recorded values outside the support of that basis function. A region where an importance surface is zero can therefore still contain recording times that change a prediction. `xfrf_leaf_radius()` measures this directly. For one subject and a chosen set of recording times, it returns, for every tree, the smallest weighted change of those values that moves the subject to another leaf, together with a bound on the resulting change of the predicted curve.

```r
s <- tr$meta$sx
q_f <- lapply(te$x, function(a) a[1, , drop = FALSE])
q_s <- te$x.scl[1, , drop = FALSE]
lr <- xfrf_leaf_radius(fit, q_f, q_s, predictor = "func2",
                       E = which(abs(s - 0.2) <= 0.1), r = c(0.1, 0.5))
lr$min_radius
```

## Reproducing the simulation study

`xfrf_sim_settings()` lists the nine design cells (three models and training sizes 100, 250 and 500) and the forest controls used in the paper: 500 trees, one third of the features at each node, minimum child size five, maximum depth 20, at most 20 thresholds per feature and ridge 1e-8. `xfrf_sim_data(model, n, replication)` regenerates the training and test samples of a repetition and its calibration split. It also returns the seeds that were set before fitting the forest and the calibrated bands. With the default random number generators of R, the code below gives the fitted forest and the out-of-bag importance of that repetition.

```r
ctrl <- xfrf_sim_settings()$xfrf
dat <- xfrf_sim_data("smooth", n = 500, replication = 7)

set.seed(dat$seeds["fit"])
fit <- xfrf_fit(dat$train$x, dat$train$x.scl, dat$train$y,
                y_grid = dat$train$meta$sy, n_trees = ctrl$n_trees,
                mtry = ctrl$mtry, min_leaf = ctrl$min_leaf,
                max_depth = ctrl$max_depth, n_thresholds = ctrl$n_thresholds,
                ridge = ctrl$ridge)
imp <- xfrf_importance(fit)
```

The population importance curves of each design are stored in `dat$train$meta$vi_true`. They can be compared with the estimates.

## Main functions

| Function | What it does |
|---|---|
| `xfrf_fit()` | encodes the curves and grows the forest |
| `xfrf_predict()` | predicts response curves, optionally with tree-quantile bands |
| `xfrf_oob()` | out-of-bag predictions of the training subjects |
| `xfrf_importance()` | grouped and coordinate importance curves, and importance surfaces |
| `xfrf_integrated_importance()` | one importance value per predictor |
| `xfrf_conformal()`, `xfrf_conformal_band()` | calibrated simultaneous prediction bands |
| `xfrf_leaf_radius()` | smallest change of chosen recording times that moves a subject to another leaf |
| `xfrf_cv()`, `xfrf_tune()` | cross-validation and grid search over the forest controls |
| `xfrf_design()`, `xfrf_design_new()` | B-spline coordinates for training and new subjects |
| `xfrf_plot_surface()`, `xfrf_plot_curves()`, `xfrf_plot_oob()` | plots |
| `xfrf_dgp()`, `xfrf_sim_settings()`, `xfrf_sim_data()` | simulation designs of the paper |

## License and contact

xFRF is released under the GPL-3 license. Questions and bug reports are welcome through the issue tracker of this repository, or by email to Ufuk Beyaztas (ufuk.beyaztas@marmara.edu.tr).
