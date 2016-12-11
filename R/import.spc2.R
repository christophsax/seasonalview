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