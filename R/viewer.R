#' @export
standalone <- function(){ 
  cat("Press ESC (or Ctrl-C) to get back to the R session\n")
  wd <- system.file("app", package = "seasonalview")
  shiny::runApp(wd, quiet = TRUE)
}




#' @export
view <- function(x, story = NULL, quiet = TRUE){ 

  if (!is.null(story)){
    if (!require(x13story)){
      stop("The 'x13story' package is needed to display stories.\n\n  devtools::install_github('christophsax/x13story')")
    }

    view_story(file = story, quiet = quiet)
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




#' Local Display of Interactive Stories
#' @param file character, path to the rmarkdown file containing an X-13 story.
#' @param quiet logical, should the output of shiny be suppressed
#' @examples
#' \dontrun{
#' file <- system.file(package = "x13story", "stories", "x11.Rmd")
#' view(story = file)
#' }
#' 
view_story <- function(file, quiet = TRUE){ 

  if (!grepl("\\.Rmd", file, ignore.case = TRUE)){
    stop("File must have rmarkdown extension (.Rmd)")
  }

  # auto download from the internet
  if (grepl("^http", file)){
    tfile <- tempfile(fileext = ".Rmd")
    download.file(file, tfile)
    file <- tfile
  }

  file <- normalizePath(file)
  .GlobalEnv$.story.passed.to.shiny <- x13story::parse_x13story(file = file)
  on.exit(rm(.story.passed.to.shiny, envir=.GlobalEnv))

  cat("Press ESC (or Ctrl-C) to get back to the R session\n")

  wd <- system.file("app", package = "seasonalview")

  shiny::runApp(wd, quiet = quiet)

}




