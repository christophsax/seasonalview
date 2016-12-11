#' Interactively Modify a Seasonal Adjustment Model
#' 
#' Interactively modify a \code{"seas"} object. The goal of \code{view} is 
#' to summarize all relevant options, plots and statistics when evaluating at a 
#' seasonal adjustment model.
#' 
#' Frequently used options can be modified using the drop down selectors in the
#' upper left window. Each change will result in a re-estimation of the seasonal
#' adjustment model. The R-call, the X-13 call, the graphical output and the 
#' summary are updated accordingly.
#'
#' Alternatively, the R call can be modified manually in the lower left window.
#' Press 'Run Call' to re-estimate the model and to adjust the option selectors,
#' the graphical output, and the summary. With the 'To console' button, view is 
#' closed and the call is imported to R. The 'Static' button substitutes 
#' automatic procedures by the automatically chosen 
#' spec-argument options, in the same way as \code{\link{static}}.
#'
#' If you are familiar with the X-13 spec syntax, you can modify the X-13 call,
#' with the same consequences as when modifying the R call.
#'
#' The lower right panel shows the a summary, as described in the help page of
#' \code{\link{summary.seas}}. The 'X-13 output' button opens the complete 
#' output of X-13 in a separate tab or window.
#' 
#' An experimental mode allows the exploration of interactive stories on 
#' seasonal adjustment. This requires the x13story package to be installed, 
#' which is not yet on CRAN. See references.
#' 
#' @param x an object of class \code{"seas"}. 
#' @param story character, path to an \code{".Rmd"} file. Can be also an URL on 
#'   the Internet.
#' @param quiet logical, if \code{TRUE} (default), error messages from calls in 
#'   \code{view} are not shown in the console.
#' @param ... arguments passed to \code{\link[shiny]{runApp}}. E.g, for choosing 
#'   it the GUI should open in the Browser or in the RStudio viewer pane (if you 
#'   are using RStudio).
#' 
#' @references Seasonal vignette with a more detailed description: 
#'   \url{http://www.seasonal.website/seasonal.html}
#'   
#'   Comprehensive list of R examples from the X-13ARIMA-SEATS manual: 
#'   \url{http://www.seasonal.website/examples.html}
#'   
#'   Official X-13ARIMA-SEATS manual: 
#'   \url{https://www.census.gov/ts/x13as/docX13ASHTML.pdf}
#' 
#'   Development version of the x13story package: 
#'   \url{https://github.com/christophsax/x13story}
#' 
#' @return an object of class \code{"seas"}, the modified model. Or \code{NULL}, 
#'   if the \code{story} argument has been supplied.
#'
#' @examples
#' \dontrun{
#' 
#' m <- seas(AirPassengers)
#' view(m)
#' 
#' m.new <- view(m)  # save the model after closing the GUI
#' }
#' @export
#' @importFrom xts as.xts
#' @importFrom xtable xtable
#' @importFrom utils read.csv
#' @importFrom stats ts time Box.test shapiro.test symnum coef
#' @importFrom dygraphs dygraph dyAnnotation dyLegend dyOptions
#' @importFrom seasonal outlier
#' @importFrom shiny tags tagList HTML
view <- function(x = NULL, story = NULL, quiet = TRUE, ...){ 

  if (!is.null(story)){

    if (!grepl("\\.Rmd", story, ignore.case = TRUE)){
      stop("File must have rmarkdown extension (.Rmd)")
    }

    # auto download from the internet
    if (grepl("^http", story)){
      tfile <- tempfile(fileext = ".Rmd")
      download.file(story, tfile)
      story <- tfile
    }

    .story.filename.passed.to.shiny <- normalizePath(story)

    wd <- system.file("app", package = "seasonalview")
    shiny::runApp(wd, quiet = quiet)
    return(NULL)
  } 

  if (!inherits(x, "seas")){
    stop("first argument must be of class 'seas'")
  }

  .model.passed.to.shiny <- x

  cat("Press ESC (or Ctrl-C) to get back to the R session\n")

  wd <- system.file("app", package = "seasonalview")
  shiny::runApp(wd, quiet = quiet, ...)
}



