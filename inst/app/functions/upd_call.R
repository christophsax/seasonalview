
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

  lc <- as.list(x)

  # remove existing 'save arguments'
  lc <- lc[!grepl(".save", names(lc), fixed = TRUE)]

  lc <- c(lc[1], lc[-1][setdiff(names(lc[-1]), names(ll))], ll)
  as.call(lc)
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

