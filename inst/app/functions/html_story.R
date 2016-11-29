
HTMLMenuLi <- function(e, id){
  title <- attr(e, "yaml")$title
  subtitle <- attr(e, "yaml")$subtitle
  icon <- attr(e, "yaml")$icon

  if (is.null(icon)) icon <- "fa-road"
  if (is.null(subtitle)) subtitle <- "Add a subtitle to your YAML header"
  if (is.null(title)) title <- "Add a title to your YAML header"

  tags$li(
    tags$a(id = id, href="#", class="media shiny-id-el shiny-force",
      tags$div(class="media-left", 
        tags$span(class="icon-wrap bg-danger",
          tags$i(class="fa fa-calendar fa-lg")
        )
      ),
      tags$div(class="media-body", 
        tags$div(class="text-nowrap", title),
        tags$small(class="text-muted", subtitle)
      )
    )
  )
}                           


HTMLMenu <- function(STORIES){
  # tags$p("dsfsdfsd")
  
  tagList(
    tags$div(id="iSelectorFeedback", class="shiny-id-callback",
      tags$ul(class = "head-list", 
        tagList(
        Map(HTMLMenuLi, e = STORIES, id = names(STORIES))
        )
      )
    ),
    tags$script('
          $(".shiny-id-el").click(function() {
                $(".shiny-id-el").removeClass("active");
                $(this).addClass("active");
              });
      '
    )
  )
}


HTMLx13view <- function(view, title = "My Story"){

  # if first or last, buttons are disabled
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

          #tags$button(id = "close", class = "btn btn-default shiny-id-el", tags$i(class = "fa fa-times"))
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


