read_anything <- function(file = "~/test.xlsx", type = NULL){
  # Input checks

  file <- normalizePath(file, mustWork = TRUE)
  
  # require(tools)
  if (is.null(type)){
    type <- tools::file_ext(file)
  }

  if (type == "xlsx"){

    df <- openxlsx::read.xlsx(file)

    series <- df[, 2]
    tc.raw <- df[, 1]

    series <- as.numeric(series)

    if (inherits(tc.raw, "numeric")){
      tc.Date <- openxlsx::convertToDate(tc.raw)
    } else if (inherits(tc.raw, "character")){
      tc.Date <- try(as.Date(tc.raw), silent = TRUE)
    } else {
      stop("wrong class of tc.raw")
    }

    if (inherits(tc.Date, "Date")){
      # from zoo:::as.yearmon.Date:
      tc.time <- with(as.POSIXlt(tc.Date, tz = "GMT"), 1900 + year + mon / 12)

      deltat <- unique(diff(tc.time))
      stopifnot(length(deltat) == 1)

      z <- ts(series, start = tc.time[1], deltat = deltat)

    } else if (inherits(tc.Date, "try-error")){
      tc.char <- gsub("[:-QMqm]", "-", tc.raw)

      tc.split <- strsplit(tc.char, "-")
      if (!identical(2L, unique(sapply(tc.split, length)))){
        stop("character date strings must be of length 2")
      }

      fr <- length(unique(sapply(tc.split, `[[`, 2)))
      z <- ts(series, start = as.numeric(tc.split[[1]]), frequency = as.numeric(fr))
    }
  } else if (type == "csv"){
    df <- read.csv(file)

    series <- df[, 2]
    tc.raw <- df[, 1]

    series <- as.numeric(series)

    tc.Date <- try(as.Date(tc.raw), silent = TRUE)

    if (inherits(tc.Date, "Date")){
      # from zoo:::as.yearmon.Date:
      tc.time <- with(as.POSIXlt(tc.Date, tz = "GMT"), 1900 + year + mon / 12)

      deltat <- unique(diff(tc.time))
      stopifnot(length(deltat) == 1)

      z <- ts(series, start = tc.time[1], deltat = deltat)

    } else if (inherits(tc.Date, "try-error")){
      tc.char <- gsub("[:-QMqm]", "-", tc.raw)

      tc.split <- strsplit(tc.char, "-")
      if (!identical(2L, unique(sapply(tc.split, length)))){
        stop("character date strings must be of length 2")
      }

      fr <- length(unique(sapply(tc.split, `[[`, 2)))
      z <- ts(series, start = as.numeric(tc.split[[1]]), frequency = as.numeric(fr))
    }



  } else {
    stop("wrong file type.")
  }
  z

}


# Excel Date Format
# 2014:3, 2014:4 ...

# convertToDate(x)

# tc.raw <- c("2014:3", "2014:4")
# x <- c("2014-3", "2014-4")
# x <- c("2014Q3", "2014Q4")
# x <- c("2014M3", "2014M4")




