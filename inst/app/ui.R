library(shiny)
library(shinydashboard)
library(dygraphs)




dashboardPage(


  html.header

  ,
  dashboardSidebar(
    disable = TRUE
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "docs.css"),
      tags$script(src = "shinyIDCallback.js")
    ),

    fluidRow(
      column(4,


        uiOutput("oStory"),
        box(title = "Options", uiOutput("oFOpts"), width = NULL, 
            collapsible = TRUE, collapsed = (run.mode == "x13story")),

        tabBox(
          # Title can include an icon
          title = tagList(actionButton("iStatic", "Static", tags$i(class="fa fa-magic", style = "padding-right: 6px;"), class = "btn", style = "margin-right: 4px; margin-bottom: 3px;"), 
                          actionButton("iEvalCall", "Run Call", class = "btn btn-primary", tags$i(class="fa fa-play-circle-o", style = "padding-right: 6px;"), style = "color: #fff; margin-bottom: 3px; margin-right: -3px;")
                          ),
          id = "iActiveTerminal",
          tabPanel("R",
            uiOutput("oTerminal")
          ),
          tabPanel("X-13", 
            uiOutput("oTerminalX13")
          ), 
          width = NULL
        )
      ),

      column(8,
        # box(uiOutput("oViewSelect"), width = NULL),  

        box(title = uiOutput("oViewSelect"), dygraphOutput("oMainPlot"), footer = uiOutput("oLabel"), width = NULL),
        box(title = "Summary", 
          fluidRow(
            column(4, uiOutput("oSummaryCoefs")),
            column(4, uiOutput("oSummaryStats")),
            column(4, uiOutput("oSummaryTests"))
          ), width = NULL
        )
      )

    ),
    html.modal,

    # shinyIDCallback.js relies on this
    HTML('
    <script>
        $(".shiny-id-el").click(function() {
              $(".shiny-id-el").removeClass("active");
              $(this).addClass("active");
            });
    </script>
    '),
    if (on.website){
      ga
    } else {
      NULL
    }

  ), 
  title = "seasonal: R interface to X-13ARIMA-SEATS",
  skin = "black"


)