# library(seasonalview)  # to be able to run the app without loading the package

# --- Mode ---------------------------------------------------------------------

# Shiny app supports 3 modes: 

# 1. seasonal   where it works on an object of class "seas", with close and return
# 2. x13-story  where it works on an .Rmd file, to render stories
# 3. stand-alone, with upload and download buttons

# frame number from which we can pick up stuff passed to shiny app 
# (1 if seasonalview::view is called from globalenv)

# browser()

# call.nframe <- as.integer(Sys.getenv("SHINY_CALL_NFRAME"))

# message("called from: ", call.nframe)

if (!is.null(getShinyOption(".model.passed.to.shiny"))){
  run.mode <- "seasonal"  
} else if (!is.null(getShinyOption(".story.filename.passed.to.shiny"))){
  run.mode <- "x13story"  

  # move this to view() when x13story is on CRAN
  # if (!requireNamespace("x13story", quietly = TRUE)){  
  if (!suppressWarnings(require("x13story", quietly = TRUE))){  ## currently needed
    stop("The 'x13story' package is needed to display stories.\n\n  devtools::install_github('christophsax/x13story')", call. = FALSE)
  }

  cat("Press ESC (or Ctrl-C) to get back to the R session\n")

} else {
  run.mode <- "standalone"  
}

# triggers a few changes that we want to use on www.seasonal.website
on.website <- FALSE

# --- app directory ------------------------------------------------------------

if (on.website){
  library(seasonalview)
  wd <- "."
  sapply(list.files(file.path(wd, "functions"), full.names=TRUE), source)
} else {
  wd <- system.file("app", package = "seasonalview")
}

# --- List with options ------------------------------------------------------

lFOpts <- list()
lFOpts$method <- c("SEATS", "X11")

lFOpts$transform <- 
  list("AUTOMATIC" = list("AIC Test" = "auto"), 
       "MANUAL" = list("Logarithmic" = "log", 
                       "Square Root" = "sqrt",
                       "No Transformation" = "none"))

lFOpts$arima <- 
  list("AUTOMATIC" = list("Auto Search" = "auto"))

lFOpts$outlier <- 
  list("AUTOMATIC" = list("Auto Critical Value" = "auto", 
                          "Low Critical Value (3)" = "cv3", 
                          "Medium Critical Value (4)" = "cv4",
                          "High Critical Value (5)" = "cv5"), 
       "MANUAL" = list("No detection" = "none"))

lFOpts$easter <- 
  list("AUTOMATIC" = list("AIC Test Easter" = "easter.aic"), 
      "MANUAL" = list("1-Day before Easter" = "easter[1]", 
                      "1-Week before Easter" = "easter[8]", 
                      "Chinese New Year" = "cny",
                      "Indian Diwali" = "diwali",
                      "No Adjustment" = "none"))
lFOpts$td <- 
  list("AUTOMATIC" = list("AIC Test" = "td.aic"), 
      "MANUAL" = list("1-Coefficient" = "td1coef", 
                      "6-Coefficients" = "td", 
                      "No Adjustment" = "none"))

lFOpts.unlist <- lapply(lFOpts, unlist)

lFOpts.user <- lFOpts
for (i in 2:length(lFOpts)){
   lFOpts.user[[i]]$MANUAL$User <- "user"
}


# --- List with series ---------------------------------------------------------

# SPECS <- read.csv("ressources/speclist/table_web.csv", header = TRUE, stringsAsFactors = FALSE)
# save(SPECS, file = "data/specs.RData")

# upper part of iSeries 
load(file = file.path(wd, "data/specs.RData"))

lSeries <- list()
lSeries$MAIN <- c("Original and Adjusted Series" = "main", "Original and Adjusted Series (%)" = "mainpc")

SPECS2 <- SPECS[SPECS$seats, ]
SPECS2$long <- gsub("seats.", "", SPECS2$long)
SPECS2$spec <- gsub("seats", "seats/x11", SPECS2$spec)

sp <- unique(SPECS2$spec)
for (spi in sp){
  argi <- SPECS2[SPECS2$spec == spi, ]$long
  names(argi) <- SPECS2[SPECS2$spec == spi, ]$descr
  lSeries[[toupper(spi)]] <- argi
}

### add rarely used views
# lowser part of iSeries 
stopifnot(packageVersion("seasonal") >= "1.10.0")
SPECS <- seasonal:::get_specs()

# views already there
pres <- unname(unlist(lSeries))

sp <- c(sp, "rarely used views")
ruv <- SPECS[SPECS$is.save & SPECS$is.series, ]$long

ruv <- ruv[!ruv %in% pres]
class(ruv)
names(ruv) <- ruv
lSeries$`RARELY USED VIEWS` <- ruv


# --- Initial model / story ----------------------------------------------------

if (run.mode == "seasonal"){
  init.model <- getShinyOption(".model.passed.to.shiny")
  init.story <- NULL

} else if (run.mode == "x13story"){
  # loading the already evaluated init.model saves 1/4 sec.
  load("data/init.model.RData")
  # init.model <- seas(AirPassengers)
  # save(init.model, file = "data/init.model.RData")

  story <- getShinyOption(".story.filename.passed.to.shiny")
  init.story <- x13story::parse_x13story(file = story)

} else {
  # loading the already evaluated init.model saves 1/4 sec.
  load("data/init.model.RData")
  init.story <- NULL
}

init.model <- seasonalview:::upd_seas(init.model, series = "main")


# --- Static HTML --------------------------------------------------------------

html.modal <- shiny::HTML('
  <div class="modal fade" id="updown-modal" role="dialog" tabindex="-1" aria-labelledby="demo-default-modal" aria-hidden="true" style="display: none;">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">×</span></button>
          <h4 class="modal-title">Upload</h4>
        </div>
        <div class="modal-body">
          <p>Upload and adjust your own data. <strong>Data is not stored</strong> and will be deleted after the session.</p>
                <ul>
                    <li>XLSX and CSV are supported.</li>
                    <li>The first row contains headers.</li>
                    <li>The <strong>first column contains the time</strong> (for format, see table below), the second the data.</li>
                    <li>Only <strong>monthly</strong> and <strong>quarterly</strong> series can be ajusted.</li>
                    <li>Download a series for an example (below). The result can be uploadad again.</li>
                </ul>
            <table class="table  table-condensed" >
              <thead>
                <tr>
                  <th>time format</th>
                  <th>example</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>separation by colon, dash, or letter</td>
                  <td><code>2014:3, 2014:4</code>, <code>2014-3, 2014-4</code>, <code>2014Q3, 2014Q4</code>, <code>2014M3, 2014M4</code></td>
                </tr>
                <tr>
                  <td>first day of period, Excel date or character string</td>
                  <td><code>2014-03-01, 2014-04-01</code></td>
                </tr>
              </tbody>
            </table>
            <div class="btn btn-file btn-primary" >
                <input id="iFile" name="file" type="file" accept=NULL>
                <span>
                    Upload XLSX or CSV
                </span>
            </div>
        </div>
        <div class="modal-header">
            <h4 class="modal-title">Download</h4>
        </div>
        <div class="modal-body">
            <p>Download the series shown in the Output panel.</p>
            <a id="oDownloadCsv" class="shiny-download-link btn btn-success" type="button" target="_blank">Download CSV</a>
            <a id="oDownloadXlsx" class="shiny-download-link btn btn-success" type="button" target="_blank">Download XLSX</a>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
        </div>
      </div>
      <!-- /.modal-content -->
    </div>
  </div>
')

html.logo <- shiny::tags$span(class="logo", shiny::tags$b(style = "padding-right: 3px;", "SEASONAL"), shiny::tags$small("X-13ARIMA-SEATS"))

if (run.mode == "seasonal"){
  html.header <- shiny::tags$header(class="main-header",
    html.logo,
    shiny::tags$nav(class="navbar navbar-static-top", role="navigation",
      shiny::tags$span(style="display:none;",
        shiny::tags$i(class="fa fa-bars")
      ),
      shiny::tags$a(href="#", class="sidebar-toggle", `data-toggle`="offcanvas", role="button",
        shiny::tags$span(class="sr-only", "Toggle navigation")
      ),
      shiny::tags$div(class="navbar-custom-menu", 
        shiny::tags$ul(class="nav navbar-nav",
          shiny::tags$li(shiny::tags$button(id="iOutput", href="#", type="button", style = "margin-right: 10px !important;", 
                         class="btn btn-default btn action-button btn-navbar",
                    shiny::tags$i(class="fa fa-file-text-o", style = "padding-right: 6px;"), " X-13 Output"
                  )
          ),
          shiny::tags$li(shiny::tags$button(id="iReturn", href="#", type="button",
                         class="btn btn-warning btn action-button btn-navbar",
                    shiny::tags$i(class="fa fa-sign-out", style = "padding-right: 6px;"), "To Console"
                  )
          )
        )
      )
    )
  ) 
}


if (run.mode == "x13story"){
  html.header <- shiny::tags$header(class="main-header",
    html.logo,
    shiny::tags$nav(class="navbar navbar-static-top", role="navigation",
      shiny::tags$span(style="display:none;",
        shiny::tags$i(class="fa fa-bars")
      ),
      shiny::tags$a(href="#", class="sidebar-toggle", `data-toggle`="offcanvas", role="button",
        shiny::tags$span(class="sr-only", "Toggle navigation")
      ),
      shiny::tags$div(class="navbar-custom-menu", 
        shiny::tags$ul(class="nav navbar-nav",
          shiny::tags$li(shiny::tags$button(id="iOutput", href="#", type="button", 
                         class="btn btn-default btn action-button btn-navbar",
                    shiny::tags$i(class="fa fa-file-text-o", style = "padding-right: 6px;"), " X-13 Output"
                  )
          )
        )
      )
    )
  ) 
}


# example menu entries
html_li_example <- function(id, title, body, icon, freq){
  shiny::tags$li(
          shiny::tags$a(class = "shiny-id-el", href="#", id = id,
            shiny::tags$i(class=paste("fa fa-fw", icon)),
            shiny::tags$h4(
              title#,
              # shiny::tags$small(
              #   shiny::tags$i(class=paste("fa", "fa-clock-o")),
              #   freq
              # )
            ),
            shiny::tags$p(body)
          )
        )
}


if (run.mode == "standalone"){
  html.header <- shiny::tags$header(class="main-header",
    html.logo,
    shiny::tags$nav(class="navbar navbar-static-top", role="navigation",
      shiny::tags$span(style="display:none;",
        shiny::tags$i(class="fa fa-bars")
      ),
      shiny::tags$a(href="#", class="sidebar-toggle", `data-toggle`="offcanvas", role="button",
        shiny::tags$span(class="sr-only", "Toggle navigation")
      ),
      shiny::tags$div(class="navbar-custom-menu", 
        shiny::tags$ul(class="nav navbar-nav",
          if (on.website){
            shiny::HTML('<li><a href="http://www.seasonal.website"><strong>Workbench</strong></a></li>
           <li><a href="seasonal.html">Introduction</a></li>
           <li style=""><a href="examples.html">Examples</a></li>')
          } else {
            NULL
          },
          # Exampe Menu
          shiny::tags$li(class="dropdown messages-menu",
            shiny::tags$a(href="#", class="dropdown-toggle", `data-toggle`="dropdown", 
                   style = "border-right: 1px solid #eee; margin-right: 10px;",
              shiny::tags$i(class="fa fa-line-chart"),
              shiny::tags$span(class="label label-danger", "4")
            ),
            shiny::tags$ul(id = "iExample", class="shiny-id-callback dropdown-menu",
              shiny::tags$li(class="header", "Example data series"), 
              shiny::tags$li(style="position: relative; overflow: hidden; width: auto; height: 200px;",
                shiny::tags$ul(class="menu",

                  html_li_example(id = "AirPassengers", 
                                  title = "Airline Passengers", 
                                  body = "The classic Box & Jenkins airline data", 
                                  icon = "fa-fighter-jet text-red", 
                                  freq = "monthly"),

                  html_li_example(id = "ldeaths", 
                          title = "Deadly Lung Diseases", 
                          body = "Bronchitis, emphysema and asthma, UK", 
                          icon = "fa-medkit text-green", 
                          freq = "quaterly"),
             
                  html_li_example(id = "imp", 
                          title = "Imports to China", 
                          body = "Dollar value of goods", 
                          icon = "fa-ship text-yellow", 
                          freq = "monthly"),

                  html_li_example(id = "iip", 
                          title = "Industrial Production, India", 
                          body = "Overall industrial sector, index value", 
                          icon = "fa-flask text-aqua", 
                          freq = "monthly")
                )
              )
            )
          ),
          shiny::tags$li(shiny::tags$button(`data-target` = "#updown-modal",
                              `data-toggle` = "modal", type="button", 
                              style = "margin-right: 10px !important;", 
                              class="btn btn-success btn btn-navbar",
                              shiny::tags$i(class="fa fa-database", style = "padding-right: 6px;"), "Up-/Download"
                             )
                 )
        )
      )
    )
  ) 
}






