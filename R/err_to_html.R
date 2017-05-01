
err_to_html <- function(txt){
  # format error message as html 

  # e1 <- 'Error: unexpected \')\' in "ts(dsfasdfasdfa))"'
  # e2 <- "Error in is.data.frame(data) : object 'dsfasdfasdfa' not found"
  # e3 <- "Error: X-13 run failed, with the following message(s):\n\nErrors:\n- dregression is not a valid spec name.\n\n"

  # err_to_html(e1)
  # err_to_html(e2)
  # err_to_html(e3)

  stopifnot(length(txt) == 1)

  if (grepl("\\n\\n", txt)){
    
    # seaprate title and body
    rm <- gregexpr("^.*?\\n\\n", txt)
    title <- regmatches(txt, rm)[[1]]
    title <- paste("<p>", gsub("\\n", "", title), "</p>")
    body0 <- regmatches(txt, rm, invert = TRUE)[[1]]
    body0 <- body0[body0 != ""]


    # separte in Errors, Warnings, Notes

    tp <- c("Notes:.+$", "Warnings:.+$", "Errors:.+$")
    names(tp) <- c("note", "warning", "error")

    body1 <- list()
    for (i in 1:length(tp)){
      rm <- gregexpr(tp[i], body0)
      body1[[names(tp)[i]]] <- regmatches(body0, rm)[[1]]
      body0 <- regmatches(body0, rm, invert = TRUE)[[1]]
    }

    # format as html
    body2 <- strsplit(unlist(body1), "\n- ")

    # browser()
    body3 <- lapply(body2, function(e) gsub("\\n", "", e))

    bullet_to_html <- function(x) {
      paste0("<p>", x[1], "</p>", "<ul>", paste(paste("<li>", x[-1], "</li>"), collapse = " "), "</ul>")
    }

    body <- paste(unlist(lapply(body3, bullet_to_html)), collapse = " ")

    z <- paste(title, body)

  } else {
    body <- paste0("<p>", txt, "</p>")
    z <- paste(body)
  }

  z
}
