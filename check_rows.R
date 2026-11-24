check_rows <- function(...) {
  objs <- Filter(Negate(is.null), list(...))
  if (length(objs) > 1) {
    nr <- sapply(objs, nrow)
    if (length(unique(nr)) != 1) {
      stop("All inputs must have the same number of rows (subjects).")
    }
  }
  invisible(TRUE)
}