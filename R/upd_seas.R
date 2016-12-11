# the good thing here is that we can update call and series at the same time,
# causing only ONE reevaluation.
upd_seas <- function(m, call = NULL, series = NULL, force = FALSE, senv){

  # series.view is not part of a seasobal obiect, but upd_seas will add it at the end.
  series.old <- m$series.view

  if (!is.null(series)){
    special.series <- c("main", "mainpc")
    if (series %in% special.series) {
      series0 <- NULL
    } else {
      if (series %in% c("irregular", "seasonal", "trend")){
        series0 <- paste0(adj_method(m), ".", series)
      } else {
        series0 <- series
      }
    }
  } else {
    series0 <- NULL
  }

  call.old <- m$call

  if (!is.null(series0)){
    if (is.null(call)){
      call.new <- upd_call(m$call, series0)
    } else {
      stopifnot(inherits(call, "call"))
      call.new <- upd_call(call, series0)
    }
  } else if (!is.null(call)){
    stopifnot(inherits(call, "call"))
    call.new <- call
  } else {
    call.new <- call.old
  }


  l.old <- as.list(call.old[-1])
  l.new <- as.list(call.new[-1])

  needs.upd <- length(union(setdiff(l.old, l.new), setdiff(l.new, l.old))) > 0

  if (needs.upd | force){
    # message("UPDATING...")
    z <- eval_or_fail_cl(call.new, senv)
  } else {
    z <- m
  }
 
  if (!inherits(z, "try-error")){
    if (!is.null(series)){
      z$series.view <- series
    } else {
      if (is.null(m$series.view)){
        z$series.view <- "main"
      } else {
        z$series.view <- m$series.view
      }
    }
  }
  z

}
