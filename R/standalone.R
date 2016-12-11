#' Stand Alone Seasonal Web-Application 
#' 
#' Previews a stand alone web application for seasonal adjustment, whith the
#' same look and feel as \url{http://www.seasonal.website}. Allows import and export of
#' data via an 'Up-/Download' button.
#' 
#' @seealso \code{\link{view}} to interactively modify a \code{"seas"} object. 
#'
#' @export
#' @examples 
#' \dontrun{
#' standalone()
#' }
standalone <- function(){ 
  cat("Press ESC (or Ctrl-C) to get back to the R session\n")
  wd <- system.file("app", package = "seasonalview")
  shiny::runApp(wd, quiet = TRUE)
}

