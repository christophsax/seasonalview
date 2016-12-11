# like series, but also handles
# c("main", "mainpc"), c("irregular", "seasonal", "trend")
# as they are returned by the series selector

# returns xts or data.frame, with series name also for single series
series0 <- function(m, series, reeval = TRUE, data.frame = FALSE){
  if (series %in% c("main", "mainpc")){
    z0 <- cbind(original = seasonal::original(m), adjusted = seasonal::final(m))
    if (series == "mainpc") z0 <- pc(z0)
  } else {
    if (series %in% c("irregular", "seasonal", "trend")){
      series <- paste0(adj_method(m), ".", series)
    }
    z0 <- series(m, series, reeval = FALSE)
  }
  if (is.null(z0)) return(NULL)

  if (data.frame){
    df0 <- data.frame(z0)
    if (NCOL(df0) == 1){
      colnames(df0) <- series
    }
    if (!is.ts(z0)){
      time <- seq(NROW(z0))
    } else {
      time <- paste(floor(time(z0)), cycle(z0), sep = ":")
    }
    return(data.frame(time = time, df0))
  }
  
  z <- try(as.xts(z0))

  if (inherits(z, "try-error")){
    z <- try(xts::xts(z0, order.by = as.Date(paste(seq(NROW(z0)), "1", "1", sep = "-"))))
  }

   if (inherits(z, "try-error")){
    stop('xts conversion problem with series: ', series)
  }

  if (NCOL(z) == 1){
    colnames(z) <- series
  }
  z
}

pc <- function(x){
  z <- diff(x) / lag(x, -1)
  if (inherits(z, "mts")){
    colnames(z) <- paste(colnames(x), "(%)")
  }
  z
}

