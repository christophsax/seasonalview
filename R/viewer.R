#' @export
standalone <- function(){ 
  cat("Press ESC (or Ctrl-C) to get back to the R session\n")
  wd <- system.file("app", package = "seasonalview")
  shiny::runApp(wd, quiet = TRUE)
}


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



