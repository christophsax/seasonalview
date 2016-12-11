shinyServer(function(input, output, session) {

# --- initialisazion -----------------------------------------------------------

# if (exists("ser", envir = globalenv())) rm("ser", envir = globalenv())
senv <- environment()  # the session environment 

# probably due to bad programming 
rUplMsg <- reactiveValues(upd = 0)   
rFOpts <- list()
gFiveBestMdl <- structure(list(arima = c("(0 1 0)(0 1 1)", "(1 1 1)(0 1 1)", "(0 1 1)(0 1 1)", "(1 1 0)(0 1 1)", "(0 1 2)(0 1 1)"), bic = c(-4.007, -3.986, -3.979, -3.977, -3.97)), .Names = c("arima", "bic"), row.names = c(NA, -5L), class = "data.frame")

rModel <- reactiveValues(seas = init.model, senv = senv)
rError <- reactiveValues(msg = "")   
rStory <- reactiveValues(story = init.story, view.no = 1)
rStoryFeedback <- reactiveValues(click = NULL, timestamp = Sys.time())

# a function with reactive consequences. Must be inside shinyServer()
upd_or_fail <- function(z){
  if (inherits(z, "try-error")){
    rError$msg <- z
  } else {
    rModel$seas <- z
    rError$msg <- ""
  }
}   


# --- URL ----------------------------------------------------------------------

if (on.website){
  qstr <- shiny::isolate(session$clientData$url_search)
  ql <- shiny::parseQueryString(qstr)
  if (!is.null(ql$call)){
    txt <- ql$call
    call <- try(as.call(parse(text = txt)[[1]]))
    if (inherits(call, "try-error")){
      z <- call
    } else {
      z <- seasonalview:::upd_seas(init.model, call = call, senv = senv)
    }
    upd_or_fail(z)
  }
}


# --- call updater -------------------------------------------------------------

# triggered by view
shiny::observe({
  series <- input$iSeries
  m <- shiny::isolate(rModel$seas)
  z <- seasonalview:::upd_seas(m, series = series, senv = senv)
  upd_or_fail(z)
})

# triggered by r or x13 terminal
shiny::observe({
 if (input$iEvalCall > 0){
    at <- shiny::isolate(input$iActiveTerminal)
    m <- shiny::isolate(rModel$seas)

    if (at == "R"){
      txt <- shiny::isolate(input$iTerminal)
      call <- try(as.call(parse(text = txt)[[1]]))
      if (inherits(call, "try-error")){
        z <- call
      } else {
        z <- seasonalview:::upd_seas(m, call = call, senv = senv)
      }
    } else if (at == "X-13"){
      txt <- shiny::isolate(input$iTerminalX13)
      call <- import.spc2(txt = txt)$seas
      if (inherits(call, "try-error")){
        z <- call
      } else {
        call$x <- m$call$x
        call$xreg <- m$call$xreg
        call$xtrans <- m$call$xtrans
        z <- seasonalview:::upd_seas(m, call = call, senv = senv)
      }
    } else {
      stop("wrong at value")
    }
    upd_or_fail(z)
  }
})

# triggered by selectors
shiny::observe({ 
  FOpts <- list()
  FOpts$method <- input$iMethod
  FOpts$transform <- input$iTransform
  FOpts$arima <- input$iArima
  FOpts$outlier <- input$iOutlier
  FOpts$easter <- input$iEaster
  FOpts$td <- input$iTd

  m <- shiny::isolate(rModel$seas)

  if (length(FOpts) > 0 && !is.null(m)){
    call <- seasonalview:::add_fopts(m, FOpts)
    z <- seasonalview:::upd_seas(m, call = call, senv = senv)
    upd_or_fail(z)
  }
 })


# --- consequences of rModel update --------------------------------------------

# plot
output$oMainPlot <- dygraphs::renderDygraph({

  m <- rModel$seas
  # could even get view from m
  p <- seasonalview:::plot_dygraph(m, series = m$series.view)  
  shiny::validate(shiny::need(!is.null(p), 
  "This view is not available for the model. Change view or model."))

  p <- dygraphs::dyOptions(p, gridLineColor = "#E1E5EA", axisLineColor = "#303030")

  p
})

# view selector (depends on adjustment method (x11/seats))
output$oViewSelect <- shiny::renderUI({
  m <- rModel$seas
  cc <- lSeries
  a <- shiny::selectInput("iSeries", NULL, choices = cc, selected = m$series.view, width = "240px")
  return(a)
})

# selectors updated by rModel
output$oFOpts <- shiny::renderUI({
  m <- rModel$seas

  fopts <- seasonalview:::get_fopts(m)

  # update if new fivebestmdl are available, otherwise, use last fivebestmdl
  if (is.null(m$spc$automdl$print)){
    fbm <- gFiveBestMdl
  } else {
    fbm <- fivebestmdl(m)
    assign("gFiveBestMdl", fbm, envir = senv)
  }

  if (!fopts$arima %in% c("auto", fbm$arima)){
    fopts$arima <- "user"
  }

  lFOpts2 <- lFOpts

  is.user <- sapply(fopts, identical, "user")
  lFOpts2[is.user] <- lFOpts.user[is.user]

  ll <- as.list(fbm$arima)
  names(ll) <- ll

  lFOpts2$arima$MANUAL <- c(ll, lFOpts2$arima$MANUAL)
  list(
    shiny::selectInput("iMethod", "Adjustment Method", choices = lFOpts2$method, selected = fopts$method, width = '100%'),
    shiny::selectInput("iTransform", "Pre-Transformation", choices = lFOpts2$transform, selected = fopts$transform, width = '100%'),
    shiny::selectInput("iArima", "Arima Model", choices = lFOpts2$arima, selected = fopts$arima, width = '100%'),
    shiny::selectInput("iOutlier", "Outlier", choices = lFOpts2$outlier, selected = fopts$outlier, width = '100%'),
    shiny::selectInput("iEaster", "Holiday", choices = lFOpts2$easter, selected = fopts$easter, width = '100%'),
    shiny::selectInput("iTd", "Trading Days", choices = lFOpts2$td, selected = fopts$td, width = '100%')    )
})

# summary
output$oSummaryCoefs <- shiny::renderUI({
  shiny::HTML(seasonalview:::html_coefs(rModel$seas))
})
output$oSummaryStats <- shiny::renderUI({
  shiny::HTML(seasonalview:::html_stats(rModel$seas))
})
output$oSummaryTests <- shiny::renderUI({
  shiny::HTML(seasonalview:::html_tests(rModel$seas))
})

# terminal
output$oTerminal <- shiny::renderUI({
  m <- rModel$seas
  cstr <- seasonalview:::format_seascall(m$call)
  shiny::tagList(
  shiny::tags$textarea(id="iTerminal", class="form-control", rows = 10, cols=60, cstr),
    # auto extending the textarea (a bit hacky)
    shiny::HTML('
    <script>
        $(document).ready(function(){
            $("#iTerminal").on("keyup keydown", function(){
              this.style.height = "2px";
              this.style.height =  this.scrollHeight + "px";
            })
        })
    </script>
    ')
  )
})

# x13terminal
output$oTerminalX13 <- shiny::renderUI({
  m <- rModel$seas
  cstr <- seasonal:::deparse_spclist(m$spc)
  shiny::tagList(
  shiny::tags$textarea(id="iTerminalX13", style = "min-height: 692px;", class="form-control", cols=60, cstr),
      shiny::HTML('
    <script>
        $(document).ready(function(){
            $("#iTerminalX13").on("keyup", function(){
              this.style.height = "2px";
              this.style.height =  this.scrollHeight + "px";
            })
        })
    </script>
    ')
  )
})


# --- stories ------------------------------------------------------------------

# show dom only if code is present
output$oStory <- shiny::renderUI({
  story <- rStory$story
  view.no <- rStory$view.no
  if (is.null(story)){
    return(NULL)
  } else {
    title <- attr(story, "yaml")$title
    return(withMathJax(seasonalview:::html_storyview(story[[view.no]], title = title)))
  }
})

# to avoid infinite loop cause by repeated clicks on 'next'
shiny::observe({
  iStoryFeedback <- input$iStoryFeedback[1]

# message((Sys.time() - shiny::isolate(rStoryFeedback$timestamp)) > 1)
  # wait 0.5 sec to accept new input
  if ((Sys.time() - shiny::isolate(rStoryFeedback$timestamp)) > 0.5){
    rStoryFeedback$click <- c(iStoryFeedback, rnorm(1))
    rStoryFeedback$timestamp <- Sys.time()
  }
})

# remove story DOM on close
shiny::observe({
  sfb <- rStoryFeedback$click[1]

  if (!is.null(sfb)){
    if (sfb == "close"){
      rStory$story <- NULL
      rStory$view.no <- 1
    }
  }
})


# update rStory by iSelectorFeedback
shiny::observe({
  sf <- input$iSelectorFeedback[1]
  if (!is.null(sf)){
    if (!sf %in% names(STORIES)){
      stop("ID not in names(STORY): ", sf)
    }
    rStory$story <- STORIES[[sf]]
    rStory$view.no <- 1
  }
})

# update rStory by Next and Prev
shiny::observe({
  sfb <- rStoryFeedback$click[1]
  p <- shiny::isolate(rStory$view.no)
  pp <- length(shiny::isolate(rStory$story))

  if (!is.null(sfb)){
    if (sfb == "next"){
      p <- min(p + 1, pp)
    } else if (sfb == "prev"){
      p <- max(1, p - 1)
    } else {
      return(NULL)
    }
    
    rStory$view.no <- p

  }
})

# update rModel by rStory
shiny::observe({
  # message("STORY UPD")
  story <- rStory$story
  view.no <- rStory$view.no

  if (is.null(story)){
    return(NULL)
  }

  # message(view.no)
  view <- story[[view.no]]

  # message(m$series.view)
  m <- view$m

  z <- seasonalview:::upd_seas(m, series = m$series.view, senv = senv)
  rModel$seas <- z
})


# --- errrors -----------------------------------------------------------------

# show error msg on error
shiny::observe({
  if (rError$msg == "") return(NULL)
  rawerr <- seasonal:::err_to_html(rError$msg)
  irev <- shiny::HTML('<button id="iRevert" type="button" class="btn action-button btn-danger" style = "margin-right: 4px; margin-top: 10px;">Revert</button>')
  error.id <<- shiny::showNotification(shiny::HTML(rawerr), action = irev, duration = NULL, type = "error")
})

# remove error msg if error is gone
shiny::observe({
   if (rError$msg != "") return(NULL)
   if (exists("error.id"))
   removeNotification(error.id)
  })

# click on iRevert does a pseudo-manipulation of the last working model and thus
# triggers an update (but no run of X-13)
shiny::observe({ 
  if (!is.null(input$iRevert)){
    if (input$iRevert > 0){
    m <- shiny::isolate(rModel$seas)
    z <- seasonalview:::upd_seas(m, senv = senv)
    z$msg <- ""  
    upd_or_fail(z)
    }
  }
})


# --- close and return ---------------------------------------------------------

if (run.mode == "seasonal"){
  shiny::observe({
    # if (input$iCancel > 0){
    #   shiny::stopApp()
    # }
    if (input$iReturn > 0){
      shiny::stopApp(returnValue = shiny::isolate(rModel$seas))
    }
  })
}

if (run.mode %in% c("seasonal", "x13story")){
  shiny::observe({ 
    if (input$iOutput > 0){
      out(shiny::isolate(rModel$seas))
    }
  })
}

shiny::observe({
  if (input$iStatic > 0){
    m <- shiny::isolate(rModel$seas)
    scl <- static(m, test = FALSE)

    # fix to avoid reevalation after sorting by add_fopts
    if (!is.null(scl$regression.variables)){
      rv <- scl$regression.variables
      eav <- c("easter[1]", "easter[8]", "easter[15]")
      tdv <- c("td", "td1coef")
      rv <- c(rv[!rv %in% eav], rv[rv %in% eav])
      rv <- c(rv[!rv %in% tdv], rv[rv %in% tdv])
      scl$regression.variables <- rv
    }
    
    z <- seasonalview:::upd_seas(m, call = scl, senv = senv)
    upd_or_fail(z)
  }
})


# --- upload and download ------------------------------------------------------

output$oDownloadCsv <- downloadHandler(
  filename = "download.csv",
  content = function(file) {
      m <- shiny::isolate(rModel$seas)
      view <- m$series.view
      dta <- seasonalview:::series0(m, view, reeval = FALSE, data.frame = TRUE)
      write.csv(dta, file, row.names = FALSE)
  }, 
  contentType = "text/csv"
)

output$oDownloadXlsx <- downloadHandler(
  filename = "download.xlsx",
  content = function(file) {
      m <- shiny::isolate(rModel$seas)
      view <- m$series.view
      dta <- seasonalview:::series0(m, view, reeval = FALSE, data.frame = TRUE)
      openxlsx::write.xlsx(dta, file)
  }, 
  contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
)

shiny::observe({
  upl <- input$iFile
  m <- shiny::isolate(rModel$seas)

  if (!is.null(upl)){

    uplMsg <- function(x, type = "error", duration = 15){
      error.id <- shiny::showNotification(shiny::HTML(x), 
                                   action = NULL, duration = duration, 
                                   type = type, closeButton = TRUE)
    }

    if (upl$size == 0){
      uplMsg("<h4>Upload error</h4><p>Uploaded file is of size 0.<p>")
    }
    type <- tools::file_ext(upl$name)
    if (!type %in% c("xlsx", "csv")){
      uplMsg("<h4>Upload error</h4>File type must be either <strong>xlsx</strong> or <strong>csv</strong>.")
      return(NULL)
    } 
    ser <- try(seasonalview:::read_anything(file.path(upl$datapath), type))
    if (inherits(ser, "try-error")){
      uplMsg("<h4>Reading error</h4> <p>The file should have the <strong>time in the first</strong>, the <strong>data in the second</strong> column.<p><p> Several time formats are supported, including Excel time formats.</p> <p>If you need an <strong>example file</strong>, download one of the demo series; the file is also uploadable.</p>")
    } else {
      uplMsg("<h4>Upload successful</h4> <p>Time dimension has been successfully recognized.<p>", "default", duration = 4)        
      
      call <- m$call
      call$x <- as.name("ser")
      assign("ser", ser, envir = senv)

      # also update if the call look the same; data has changed.
      z <- seasonalview:::upd_seas(init.model, call, force = TRUE, senv = senv)

      upd_or_fail(z)

    }
  }
})

shiny::observe({
  series.name <- input$iExample[1]
  m <- shiny::isolate(rModel$seas)

  if (!is.null(series.name)){
    call <- m$call

    # exception for chines imports
    if (series.name == "imp"){
      call$x <- as.call(parse(text = "window(imp, start = 2000)")[[1]])
    } else {
      call$x <- as.name(series.name)
    }
    z <- seasonalview:::upd_seas(m, call = call, senv = senv)
    upd_or_fail(z)
  }
})

})