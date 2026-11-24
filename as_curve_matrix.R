as_curve_matrix <- function(x, name = "input") {
  if (is.null(x)) return(NULL)
  if (is.matrix(x)) return(x)
  if (is.data.frame(x)) return(as.matrix(x))
  if (is.vector(x)) return(matrix(x, ncol = 1))
  stop(name, " must be a matrix, a data frame or a vector.")
}