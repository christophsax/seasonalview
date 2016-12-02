adj_method <- function(x){
  stopifnot(inherits(x, "seas"))
  if (!is.null(x$spc$seats)) {
    "seats"
  } else if (!is.null(x$spc$x11)) {
    "x11"
  } else {
    "none"
  }
}
