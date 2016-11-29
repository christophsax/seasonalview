PC <- function(x){
  z <- diff(x) / lag(x, -1)
  if (inherits(z, "mts")){
    colnames(z) <- paste(colnames(x), "(%)")
  }
  z
}

