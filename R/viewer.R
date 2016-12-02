#' @export
standalone <- function(){ 
  cat("Press ESC (or Ctrl-C) to get back to the R session\n")
  wd <- system.file("app", package = "seasonalview")
  shiny::runApp(wd, quiet = TRUE)
}



#' Interactively Modify a Seasonal Adjustment Model
#' 
#' Interactively modify a \code{"seas"} object. The goal of \code{view} is 
#' to summarize all relevant options, plots and statistics that should be 
#' usually considered.
#' 
#' Frequently used options can be modified using the drop down selectors in the
#' upper left window. Each change will result in a re-estimation of the seasonal
#' adjustment model. The R-call, the output and the summary are updated
#' accordingly.
#'
#' Alternatively, the R-Call can be modified manually in the lower left window.
#' Press 'Run Call' to re-estimate the model and to adjust the option selectors,
#' the output, and the summary. With the 'to console' button, view is 
#' closed and the call is imported to R. The 'static' button substitutes 
#' automatic procedures by the automatically chosen 
#' spec-argument options, in the same way as \code{\link{static}}.
#'
#' The views in the upper right window can be selected from the drop down menu.
#'
#' The lower right panel shows the a summary, as described in the help page of
#' \code{\link{summary.seas}}. The 'Full X-13 output' button opens the complete 
#' output of X-13 in a separate tab or window.
#' 
#' 
#' @param x an object of class \code{"seas"}. 
#' @param story character, path to an \code{".Rmd"} file. 
#' @param quiet logical, if \code{TRUE} (default), error messages from calls in 
#'   view are not shown in the console
#'   
#' @return an object of class \code{"seas"}, the modified model.
#'
#' @examples
#' \dontrun{
#' 
#' m <- seas(AirPassengers)
#' 
#' view(m)
#' 
#' m2 <- view(m)  # save the model after closing the GUI
#' 
#' }
#' @export
view <- function(x = NULL, story = NULL, quiet = TRUE){ 
  if (!is.null(story)){
    if (!require(x13story)){
      stop("The 'x13story' package is needed to display stories.\n\n  devtools::install_github('christophsax/x13story')")
    }

    if (!grepl("\\.Rmd", story, ignore.case = TRUE)){
      stop("File must have rmarkdown extension (.Rmd)")
    }

    # auto download from the internet
    if (grepl("^http", story)){
      tfile <- tempfile(fileext = ".Rmd")
      download.file(story, tfile)
      story <- tfile
    }

    story <- normalizePath(story)
    .GlobalEnv$.story.passed.to.shiny <- x13story::parse_x13story(file = story)
    on.exit(rm(.story.passed.to.shiny, envir=.GlobalEnv))

    cat("Press ESC (or Ctrl-C) to get back to the R session\n")

    wd <- system.file("app", package = "seasonalview")

    shiny::runApp(wd, quiet = quiet)
    return(NULL)
  } 

  if (!inherits(x, "seas")){
    stop("first argument must be of class 'seas'")
  }

  .GlobalEnv$.model.passed.to.shiny <- m
  on.exit(rm(.model.passed.to.shiny, envir = .GlobalEnv))

  cat("Press ESC (or Ctrl-C) to get back to the R session\n")

  wd <- system.file("app", package = "seasonalview")

  shiny::runApp(wd, quiet = quiet)
}



