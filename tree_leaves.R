tree_leaves <- function(tree) {
  if (is.null(tree$feature)) return(matrix(tree$prediction, nrow = 1))
  rbind(tree_leaves(tree$left), tree_leaves(tree$right))
}