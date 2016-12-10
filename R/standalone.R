#' Stand Alone Seasonal Web-Application 
#' 
#' Previews a stand alone web application for seasonal adjustment, whith the
#' same look as \url{www.seasonal.website}. Allows importing and exporting of 
#' data via the 'Up-/Download' button.
#' 
#' @seealso \code{\link{view}} for an interactive GUI that imports and exports
#'   from the R console.
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

