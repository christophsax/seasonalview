
# m <- seas(AirPassengers, forecast.save = "forecasts")

# x <- m$call

# a <- upd_call(x, "estimate.armacmatrix")

# upd_call(a, "forecast.forecasts")


# this works but is a bit too strict. E.g. if we have another forecast.save
# activated, it would overwrite it. If we want to use it in series(), this must
# be fixed. For the website, it is probably ok.

# m <- seas(AirPassengers)
# call <- upd_call(call, "seats.seasonal")

upd_call <- function(x, series){

  # message("series:", series)
  stopifnot(inherits(x, "call"))
  
  SPECS <- NULL 
  data(specs, envir = environment(), package = "seasonal")  # avoid side effects
  
  is.dotted <- grepl("\\.", series)
  
  # check validiy of short or long names
  is.valid <- logical(length = length(series))
  is.valid[is.dotted] <- series[is.dotted] %in% SPECS$long[SPECS$is.series]
  is.valid[!is.dotted] <- series[!is.dotted] %in% SPECS$short[SPECS$is.series]

  if (any(!is.valid)){
    stop(paste0("\nseries not valid: ", paste(series[!is.valid], collapse = ", "), "\nsee ?series for a list of importable series "))
  }
  
  # unique short names
  series.short <- unique(c(series[!is.dotted], 
    merge(data.frame(long = series[is.dotted]), SPECS)$short))


  series.NA <- series.short

  activated <- NULL
  ll <- list()
  j <- 1  # flexible index to allow for an arbitrary number of requirements
  for (i in seq_along(series.NA)){
    series.NA.i <- series.NA[i]
    spec.i <- as.character(SPECS[SPECS$short == series.NA.i & SPECS$is.series, ]$spec)
    if (length(spec.i) > 1) stop("not unique.")
    activated <- c(activated, spec.i)

    requires.i <- as.character(SPECS[SPECS$short == series.NA.i & SPECS$is.series, ]$requires)
    if (length(requires.i) > 0){
      requires.list <- eval(parse(text = paste("list(", requires.i, ")")))
      ll <- c(ll, requires.list)
      j <- length(ll) + 1
    }
    
    ll[[j]] <- series.NA.i
    names(ll)[j] <- paste0(spec.i, '.save')
    j <- j + 1
  }
# browser()
  lc <- as.list(x)

  # remove existing 'save arguments'
  lc <- lc[!grepl(".save", names(lc), fixed = TRUE)]

  lc <- c(lc[1], lc[-1][setdiff(names(lc[-1]), names(ll))], ll)
  as.call(lc)
}




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
  # browser()
  # 
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




# like series, but also handles
# c("main", "mainpc"), c("irregular", "seasonal", "trend")
# as they are returned by the series selector

# returns xts or data.frame, with series name also for single series

series0 <- function(m, series, reeval = TRUE, data.frame = FALSE){
  if (series %in% c("main", "mainpc")){
    z0 <- cbind(original = original(m), adjusted = final(m))
    if (series == "mainpc") z0 <- PC(z0)
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
  
  z <- try(xts::as.xts(z0))

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

plot_dygraph <- function(m, series = "main"){
  ser <- series0(m, series, reeval = FALSE)
  if(!inherits(ser, "xts")){
    message("This view is not available for the model. Change view or model.")
    return(NULL)
  }
  d <- dygraph(ser)  
  if (series %in% c("main", "mainpc")){
    om <- outlier(m)
    if (any(!is.na(om))){
        ot <- time(as.xts(om))[!is.na(om)]
        ol <- om[!is.na(om)]
        for (i in 1:length(ot)){
            # d <- dyEvent(d, date = ot[i], label = ol[i], labelLoc = "bottom")
          d <- dyAnnotation(d, x = ot[i], text = ol[i], width = 23, height = 23)
        }
    }
  } 

  series.colors <- c("#2a6894", "#00a65a", "#f39c12", "#f56954", "#001F3F")

  d <- dyLegend(d, show = "always", width = 300, labelsDiv = "oLabel")
  d <- dyOptions(d, gridLineColor = "#E1E5EA", 
                 axisLineColor = "#303030",
                 colors = (series.colors[1:NCOL(ser)]),
                 animatedZooms = TRUE)
  d

}


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




import.spc2 <- function(file = NULL, txt){
  
  # stopifnot(file.exists(file))

  z <- list()

  # txt <- readLines(file)
  txt <- txt
  txt <- gsub("\\\\", "/", txt)  # window file names to unix
  txt <- gsub("#.*$", "", txt) # remove comments

  # keep everything lowercase, except filenames
  pp.cap <- seasonal:::parse_spc(txt)
  pp <- seasonal:::parse_spc(tolower(txt))
  pp[['series']][['file']] <- pp.cap[['series']][['file']]
  pp[['transform']][['file']] <- pp.cap[['transform']][['file']]
  pp[['regression']][['file']] <- pp.cap[['regression']][['file']]

  xstr <- seasonal:::ext_ser_call(pp$series, "x")
  xregstr <- seasonal:::ext_ser_call(pp$regression, "xreg")
  xtransstr <- seasonal:::ext_ser_call(pp$transform, "xtrans")

  # clean args that are produced by seas
  pp[c("series", "regression", "transform")] <- lapply(pp[c("series", "regression", "transform")], function(spc) spc[!names(spc) %in% c("file", "data", "start", "name", "title", "format", "period", "user")])
  
  if (identical(pp$series, structure(list(), .Names = character(0)))){
    pp$series <- NULL
  }

  # construct the main call
  ep <- seasonal:::expand_spclist_to_args(pp)
  ep <- seasonal:::rem_defaults_from_args(ep)

  # add xtrans, xreg and x as series
  if (!is.null(xtransstr)) ep <- c(list(xtrans = quote(xtrans)), ep)
  if (!is.null(xregstr)) ep <- c(list(xreg = quote(xreg)), ep)
  ep <- c(list(x = quote(x)), ep)

  z$x <- if (!is.null(xstr)) parse(text = xstr)[[1]]
  z$xtrans <- if (!is.null(xtransstr)) parse(text = xtransstr)[[1]]
  z$xreg <- if (!is.null(xregstr)) parse(text = xregstr)[[1]]

  z$seas <- as.call(c(quote(seas), ep))

  class(z) <- "import.spc"
  z

}

