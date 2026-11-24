tree_predict_one <- function(tree, x) {
  node <- tree
  x <- as.numeric(x)
  while (!is.null(node$feature)) {
    node <- if (x[node$feature] < node$threshold) node$left else node$right
    if (is.null(node)) stop("Malformed tree.")
  }
  node$prediction
}
