row_ise <- function(y, yhat, w) {
  rowSums(sweep((y - yhat)^2, 2, w, "*"))
}