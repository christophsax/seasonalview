# adjusted versions of the following functions to make the package importable

# - dygraphs::dygraph
# - xts:::as.xts.ts
# - xts:::time.xts
# - xts::periodicity

# (the underlying problem is that the xts package DEPENDS on zoo, and all the
# following packages have to depend as well. The 'dygraphs' package circumvents
# this problem by exporting the functions from zoo, but this makes the dygraph
# package non-exportable.)


#' @importFrom stats frequency tsp median end start
#' @importFrom htmlwidgets createWidget sizingPolicy
dygraph_xtsimp <- function (data, main = NULL, xlab = NULL, ylab = NULL, periodicity = NULL, 
    group = NULL, elementId = NULL, width = NULL, height = NULL) 
{

    format <- "date"

    stopifnot(inherits(data, "xts"))

    asISO8601Time <- function (x){
        if (!inherits(x, "POSIXct")) 
            x <- as.POSIXct(x, tz = "GMT")
        format(x, format = "%04Y-%m-%dT%H:%M:%OS3Z", tz = "GMT")
    }


    if (format == "date") {
        if (is.null(periodicity)) {
            if (nrow(data) < 2) {
                # content of: dygraphs:::defaultPeriodicity
                periodicity <- structure(list(difftime = structure(0, units = "secs", 
                    class = "difftime"), frequency = 0, start = start(data), 
                    end = end(data), units = "secs", scale = "seconds", label = "second"), 
                    class = "periodicity")
                # periodicity <- defaultPeriodicity(data)
            }
            else {
                periodicity <- xts::periodicity(data)
            }
        }
        time <- time_xtsimp(data)
        data <- zoo::coredata(data)
        data <- unclass(as.data.frame(data))
        timeColumn <- list()
        timeColumn[[periodicity$label]] <- asISO8601Time(time)
        data <- append(timeColumn, data)
    }
    else {
        data <- as.list(data)
    }
    attrs <- list()
    attrs$title <- main
    attrs$xlabel <- xlab
    attrs$ylabel <- ylab
    attrs$labels <- names(data)
    attrs$legend <- "auto"
    attrs$retainDateWindow <- FALSE
    attrs$axes$x <- list()
    attrs$axes$x$pixelsPerLabel <- 60
    x <- list()
    x$attrs <- attrs
    x$scale <- if (format == "date") 
        periodicity$scale
    else NULL
    x$group <- group
    x$annotations <- list()
    x$shadings <- list()
    x$events <- list()
    x$format <- format
    attr(x, "time") <- if (format == "date") 
        time
    else NULL
    attr(x, "data") <- data
    attr(x, "autoSeries") <- 2
    names(data) <- NULL
    x$data <- data
    htmlwidgets::createWidget(name = "dygraphs", x = x, width = width, 
        height = height, htmlwidgets::sizingPolicy(viewer.padding = 10, 
            browser.fill = TRUE), elementId = elementId)
}



periodicity_xtsimp <- function(x){
    # if (timeBased(x) || !is.xts(x)) 
    #     x <- try.xts(x, error = "'x' needs to be timeBased or xtsible")
    p <- median(diff(xts::.index(x)))
    if (is.na(p)) 
        stop("can not calculate periodicity of 1 observation")
    units <- "days"
    scale <- "yearly"
    label <- "year"
    if (p < 60) {
        units <- "secs"
        scale <- "seconds"
        label <- "second"
    }
    else if (p < 3600) {
        units <- "mins"
        scale <- "minute"
        label <- "minute"
        p <- p/60L
    }
    else if (p < 86400) {
        units <- "hours"
        scale <- "hourly"
        label <- "hour"
    }
    else if (p == 86400) {
        scale <- "daily"
        label <- "day"
    }
    else if (p <= 604800) {
        scale <- "weekly"
        label <- "week"
    }
    else if (p <= 2678400) {
        scale <- "monthly"
        label <- "month"
    }
    else if (p <= 7948800) {
        scale <- "quarterly"
        label <- "quarter"
    }
    structure(list(difftime = structure(p, units = units, class = "difftime"), 
        frequency = p, start = NULL, end = NULL, units = units, 
        scale = scale, label = label), class = "periodicity")
}


time_xtsimp <- function (x, ...){
  if (is.null(xts::tclass(x))) return(NULL)
  if (xts::tclass(x) == "yearmon")
    return(zoo::as.yearmon(.POSIXct(xts::.index(x), tz = attr(xts::.index(x), "tzone"))))
  if (xts::tclass(x) == "yearqtr")
    return(zoo::as.yearqtr(.POSIXct(xts::.index(x), tz = attr(xts::.index(x), "tzone"))))
  # xts:::time.xts(x)
  time(x)
}


as_xts_xtsimp <- function(x) {
    stopifnot(inherits(x, "ts"))
    x.mat <- structure(as.matrix(x), dimnames = dimnames(x))
    colnames(x.mat) <- colnames(x)

        if (frequency(x) == 1) {
            yr <- tsp(x)[1]%/%1
            mo <- tsp(x)[1]%%1
            if (mo%%(1/12) != 0 || yr > 3000) {
                dateFormat <- ifelse(max(time(x)) > 86400, "POSIXct", 
                  "Date")
                order.by <- do.call(paste("as", dateFormat, sep = "."), 
                  list(as.numeric(time(x)), origin = "1970-01-01"))
            } else {
                mo <- ifelse(length(mo) < 1, 1, floor(mo * 12) + 
                  1)
                order.by <- seq.Date(as.Date(xts::firstof(yr, mo), 
                  origin = "1970-01-01"), length.out = length(x), 
                  by = "year")
            }
        } else if (frequency(x) == 4) {
            order.by <- zoo::as.yearqtr(time(x))
        } else if (frequency(x) == 12) {
            order.by <- zoo::as.yearmon(time(x))
        } else if (frequency(x) == 2){ 
          # this should work somehow, so here is some bad code:
          yr <- floor(time(x))
          mo <- cycle(x) - 1
          order.by <- as.Date(paste(yr, (mo * 6) + 1, "1", sep = "-"))
        } else {
            stop("could not convert index to appropriate type")
        }
    xx <- xts::xts(x.mat, order.by = order.by, frequency = frequency(x))
    attr(xx, "tsp") <- NULL
    xx
}
