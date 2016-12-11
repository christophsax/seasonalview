html_storyview <- function(view, title = "My Story"){

  shinydashboard::box()  # to not let CRAN test complain about unused imports


  # if first or last, buttons are disabled
  p.button <- tags$button(id = "prev", class = "btn btn-sm btn-primary shiny-id-el", type = "button", 
                          tags$i(class = "fa fa-angle-left", style = "margin-right: 2px;"), 
                          "Prev")
  n.button <- tags$button(id = "next", class = "btn btn-sm btn-primary shiny-id-el", type = "button",
                          "Next",
                          tags$i(class = "fa fa-angle-right", style = "margin-left: 2px;")
                          )
  
  if (view$first) p.button$attribs$disabled <- NA
  if (view$last) n.button$attribs$disabled <- NA

  tagList(
    tags$div(id="iStoryFeedback", class="box",
      tags$div(class = "box-header with-border",
        tags$h3(class = "box-title", title),
        tags$div(class="box-tools pull-right", 
          tags$div(class = "btn-group",
            p.button,
            n.button
            
          ),
          tags$button(id = "close", class = "btn btn-box-tool shiny-id-el", tags$i(class = "fa fa-times"))
        )
      ),

      tags$div(class = "progress xxs", 
        tags$div(style = paste0("width: ", view$percent, "%;"), class = "progress-bar progress-bar-info")
      ),
      tags$div(class = "box-body story-body", 
        HTML(view$body.html)
      )
    ),

    tags$script('
          $(".shiny-id-el").click(function() {
                // $(".shiny-id-el").removeClass("active");
                var thisid = new Array();
                thisid.push($(this).attr("id"))
                thisid.push(Math.random());
                Shiny.onInputChange("iStoryFeedback", thisid);                
              });
      '
    )
  )
}


