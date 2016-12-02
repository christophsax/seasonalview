library(shiny)
library(seasonal)
library(dygraphs)
library(xts)
library(xtable)
library(shinydashboard)

data(holiday)
data(seasonal)


# --- Mode ---------------------------------------------------------------------

# Shiny app supports 3 modes: 

# 1. seasonal   where it works on an object of class "seas", with close and return
# 2. x13-story  where it works on an .Rmd file, to render stories
# 3. stand-alone, with upload and download buttons


if (exists(".model.passed.to.shiny", where = globalenv())){
  run.mode <- "seasonal"  
} else if (exists(".story.passed.to.shiny", where = globalenv())){
  run.mode <- "x13story"  
} else {
  run.mode <- "standalone"  
}


# triggers a few changes that we want to use on www.seasonal.website
on.website <- FALSE



# --- app directory ------------------------------------------------------------


# # make sure you have the same wd as on server
# if (version$os != "linux-gnu"){ 

#   setwd(system.file("app", package = "seasonalInspect"))
# } 


wd <- system.file("app", package = "seasonalview")

# load functions (may go to the R folder later on)
sapply(list.files(file.path(wd, "functions"), full.names=TRUE), source)


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
# save(SPECS, file = "~/seasweb/specs.rdata")

# 2016-11-28: Not clear why we are not using: data(specs)
load(file = file.path(wd, "specs.rdata"))

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
data(specs)

# views already there
pres <- c(unname(unlist(lSeries)), "forecast.backcasts")

sp <- c(sp, "rarely used views")
ruv <- SPECS[SPECS$is.save & SPECS$is.series, ]$long

ruv <- ruv[!ruv %in% pres]
class(ruv)
names(ruv) <- ruv
lSeries$`RARELY USED VIEWS` <- ruv


# --- Initial model / story ----------------------------------------------------

if (run.mode == "seasonal"){
  init.model <- .GlobalEnv$.model.passed.to.shiny
  init.story <- NULL

} else if (run.mode == "x13story"){
  # loading the already evaluated init.model saves 1/4 sec.
  load("init.model.rdata")

  # init.model <- seas(AirPassengers)
  # save(init.model, file = "init.model.rdata")

  

  init.story <- .story.passed.to.shiny
  # # so we can run it as 'app', too, outside of inspect
  # if (!exists("init.story")){
  #   story.file <- system.file(package = "x13story", "stories", "x11.Rmd")
  #   init.story <- x13story::parse_x13story(file = story.file)
  # }

} else {
  # loading the already evaluated init.model saves 1/4 sec.
  load("init.model.rdata")
  init.story <- NULL
}

init.model <- upd_seas(init.model, series = "main")




# --- Static HTML --------------------------------------------------------------



html.modal <- HTML('
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

html.logo <- tags$span(class="logo", tags$b(style = "padding-right: 3px;", "SEASONAL"), tags$small("X-13ARIMA-SEATS"))

if (run.mode == "seasonal"){
  html.header <- tags$header(class="main-header",
    html.logo,
    tags$nav(class="navbar navbar-static-top", role="navigation",
      tags$span(style="display:none;",
        tags$i(class="fa fa-bars")
      ),
      tags$a(href="#", class="sidebar-toggle", `data-toggle`="offcanvas", role="button",
        tags$span(class="sr-only", "Toggle navigation")
      ),
      tags$div(class="navbar-custom-menu", 
        tags$ul(class="nav navbar-nav",
          tags$li(tags$button(id="iOutput", href="#", type="button", style = "margin-right: 10px !important;", 
                         class="btn btn-default btn action-button btn-navbar",
                    tags$i(class="fa fa-file-text-o", style = "padding-right: 6px;"), " X-13 Output"
                  )
          ),
          tags$li(tags$button(id="iReturn", href="#", type="button",
                         class="btn btn-warning btn action-button btn-navbar",
                    tags$i(class="fa fa-sign-out", style = "padding-right: 6px;"), "To Console"
                  )
          )
        )
      )
    )
  ) 
}



if (run.mode == "x13story"){
  html.header <- tags$header(class="main-header",
    html.logo,
    tags$nav(class="navbar navbar-static-top", role="navigation",
      tags$span(style="display:none;",
        tags$i(class="fa fa-bars")
      ),
      tags$a(href="#", class="sidebar-toggle", `data-toggle`="offcanvas", role="button",
        tags$span(class="sr-only", "Toggle navigation")
      ),
      tags$div(class="navbar-custom-menu", 
        tags$ul(class="nav navbar-nav",
          tags$li(tags$button(id="iOutput", href="#", type="button", 
                         class="btn btn-default btn action-button btn-navbar",
                    tags$i(class="fa fa-file-text-o", style = "padding-right: 6px;"), " X-13 Output"
                  )
          )
        )
      )
    )
  ) 
}




# example menu entries
html_li_example <- function(id, title, body, icon, freq){
  tags$li(
          tags$a(class = "shiny-id-el", href="#", id = id,
            tags$i(class=paste("fa fa-fw", icon)),
            tags$h4(
              title#,
              # tags$small(
              #   tags$i(class=paste("fa", "fa-clock-o")),
              #   freq
              # )
            ),
            tags$p(body)
          )
        )
}



if (run.mode == "standalone"){
  html.header <- tags$header(class="main-header",
    html.logo,
    tags$nav(class="navbar navbar-static-top", role="navigation",
      tags$span(style="display:none;",
        tags$i(class="fa fa-bars")
      ),
      tags$a(href="#", class="sidebar-toggle", `data-toggle`="offcanvas", role="button",
        tags$span(class="sr-only", "Toggle navigation")
      ),
      tags$div(class="navbar-custom-menu", 
        tags$ul(class="nav navbar-nav",
          if (on.website){
            HTML('<li><a href="http://www.seasonal.website"><strong>Workbench</strong></a></li>
           <li><a href="seasonal.html">Introduction</a></li>
           <li style=""><a href="examples.html">Examples</a></li>')
          } else {
            NULL
          },
          # Exampe Menu
          tags$li(class="dropdown messages-menu",
            tags$a(href="#", class="dropdown-toggle", `data-toggle`="dropdown", 
                   style = "border-right: 1px solid #eee; margin-right: 10px;",
              tags$i(class="fa fa-line-chart"),
              tags$span(class="label label-danger", "4")
            ),
            tags$ul(id = "iExample", class="shiny-id-callback dropdown-menu",
              tags$li(class="header", "Example data series"), 
              tags$li(style="position: relative; overflow: hidden; width: auto; height: 200px;",
                tags$ul(class="menu",

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


          tags$li(tags$button(`data-target` = "#updown-modal",
                              `data-toggle` = "modal", type="button", 
                              style = "margin-right: 10px !important;", 
                              class="btn btn-success btn btn-navbar",
                              tags$i(class="fa fa-database", style = "padding-right: 6px;"), "Up-/Download"
                             )
                 )
        )
      )
    )
  ) 
}






