shinydashboard::dashboardPage(
  html.header,
  shinydashboard::dashboardSidebar(disable = TRUE),
  shinydashboard::dashboardBody(
    shiny::tags$head(
      shiny::tags$link(rel = "stylesheet", type = "text/css", href = "docs.css"),
      shiny::tags$script(src = "shinyIDCallback.js")
    ),

    shiny::fluidRow(

      shiny::column(4,
        shiny::uiOutput("oStory"),
        shinydashboard::box(title = "Options", uiOutput("oFOpts"), width = NULL, 
            collapsible = TRUE, collapsed = (run.mode == "x13story")),
        shinydashboard::tabBox(
          title = shiny::tagList(shiny::actionButton("iStatic", "Static", shiny::tags$i(class="fa fa-magic", style = "padding-right: 6px;"), class = "btn", style = "margin-right: 4px; margin-bottom: 3px;"), 
                          shiny::actionButton("iEvalCall", "Run Call", class = "btn btn-primary", shiny::tags$i(class="fa fa-play-circle-o", style = "padding-right: 6px;"), style = "color: #fff; margin-bottom: 3px; margin-right: -3px;")
                          ),
          id = "iActiveTerminal",
          shiny::tabPanel("R",
            shiny::uiOutput("oTerminal")
          ),
          shiny::tabPanel("X-13", 
            shiny::uiOutput("oTerminalX13")
          ), 
          width = NULL
        )
      ),

      shiny::column(8,
        tags$div(id="output-box", class="box",
          tags$div(class = "box-header with-border",
            tags$h3(class = "box-title", uiOutput("oViewSelect")),
            HTML('<small hidden id = "info-zoom" class = "pull-right text-muted">click and drag to zoom &mdash; double-click to restore</small>')
          ),
          tags$div(class = "box-body", 
            dygraphs::dygraphOutput("oMainPlot")
          ),
          tags$div(class = "box-footer", 
            shiny::uiOutput("oLabel")
          )
        ),
        shinydashboard::box(title = "Summary", 
          shiny::fluidRow(
            shiny::column(4, shiny::uiOutput("oSummaryCoefs")),
            shiny::column(4, shiny::uiOutput("oSummaryStats")),
            shiny::column(4, shiny::uiOutput("oSummaryTests"))
          ), width = NULL
        )
      )

    ),

    # additional stuff at the end
    html.modal,
    shiny::tags$script(src = "docs.js"),
    if (on.website){
      ga
    } else {
      NULL
    }

  ), 
  title = "seasonal: R interface to X-13ARIMA-SEATS",
  skin = "black"
)