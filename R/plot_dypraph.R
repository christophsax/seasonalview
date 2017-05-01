plot_dygraph <- function(m, series = "main"){

  ser <- series0(m, series, reeval = FALSE)
  if(!inherits(ser, "xts")){
    # message("This view is not available for the model. Change view or model.")
    return(NULL)
  }
  per <- periodicity_xtsimp(ser)

  d <- dygraph_xtsimp(ser, periodicity = per)  
  if (series %in% c("main", "mainpc")){
    om <- outlier(m)
    if (any(!is.na(om))){
        ot <- time_xtsimp(as_xts_xtsimp(om))[!is.na(om)]
        ol <- om[!is.na(om)]
        for (i in 1:length(ot)){
            # d <- dyEvent(d, date = ot[i], label = ol[i], labelLoc = "bottom")
          d <- dygraphs::dyAnnotation(d, x = ot[i], text = ol[i], width = 23, height = 23)
        }
    }
  } 

  series.colors <- c("#2a6894", "#00a65a", "#f39c12", "#f56954", "#001F3F")

  d <- dygraphs::dyLegend(d, show = "always", width = 300, labelsDiv = "oLabel")
  d <- dygraphs::dyOptions(d, gridLineColor = "#E1E5EA", 
                 axisLineColor = "#303030",
                 colors = (series.colors[1:NCOL(ser)]),
                 animatedZooms = TRUE,
                 retainDateWindow = TRUE
                 )
  d

}



