# x "seas" object
html_coefs <- function(x){
  coefs <- coef(summary(x))
  Signif <- symnum(coefs[, 'Pr(>|z|)'], corr = FALSE, na = FALSE, 
                    cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1), 
                    symbols = c("***", "**", "*", ".", " "), legend = FALSE)

  df <- data.frame(Name = rownames(coefs), Value = coefs[, 'Estimate'], Level = Signif)
  rownames(df) <- NULL
  a <- print(xtable(df), type = "html", html.table.attributes = "class = 'table table-condensed'", include.rownames = FALSE, include.colnames = FALSE,  print.results = FALSE)
  a <- gsub(' \\*\\*\\* ', '<span class="label label-table label-primary">0.1%</span>', a)
  a <- gsub(' \\*\\* ', '<span class="label label-table label-info">1%</span>', a)
  a <- gsub(' \\* ', '<span class="label label-table label-mint">5%</span>', a)
  a <- gsub(' \\. ', '<span class="label label-table label-default">10%</span>', a)
  a
}


html_stats <- function(x, digits = 5){
  x <- summary(x)
  class(x) <- "seas"  # make udg() working

  z <- list()

  if (!is.null(x$spc$seats)){
    z <- c(z, list(c("Adjustment", "SEATS")))
  }
  if (!is.null(x$spc$x11)){
    z <- c(z, list(c("Adjustment", "X11")))
  }
  
  z <- c(z, list(
          c("ARIMA", x$model$arima$model),
          c("Obs.", formatC(nobs(x), format = "d")),
          c("Transform", x$transform.function),
          c("AICc", formatC(unname(seasonal::udg(x, "aicc")), digits = digits)),
          c("BIC", formatC(BIC(x), digits = digits))
        )
      )

  df <- data.frame(do.call(rbind, z))

  a <- print(xtable(df), type = "html", html.table.attributes = "class = 'table table-condensed'", include.rownames = FALSE, include.colnames = FALSE,  print.results = FALSE)
  a
}


html_tests <- function(x, digits = 4){
  x <- summary(x)

  z <- list()

  # QS Test
  qsv <- x$qsv
  qsstars <- symnum(as.numeric(qsv['p-val']), 
                    corr = FALSE, na = FALSE, legend = FALSE,
                    cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1), 
                    symbols = c("***", "**", "*", ".", " "))
  z <- c(z, list(c("QS (H0: no seasonality in final series)", formatC(as.numeric(qsv['qs']), digits = digits), qsstars)))
  
  if (!is.null(x$resid)){
    # Box Ljung Test
    bltest <- Box.test(x$resid, lag = 24, type = "Ljung")
    blstars <- symnum(bltest$p.value, 
                      corr = FALSE, na = FALSE, legend = FALSE,
                      cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1), 
                      symbols = c("***", "**", "*", ".", " "))
    z <- c(z, list(c("Box-Ljung (H0: no residual autocorrelation)", 
        formatC(bltest$statistic, digits = digits), blstars)))
    
    # Normality
    swtest <- shapiro.test(x$resid)
    swstars <- symnum(swtest$p.value, 
                      corr = FALSE, na = FALSE, legend = FALSE,
                      cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1), 
                      symbols = c("***", "**", "*", ".", " "))
    z <- c(z, list(c("Shapiro (H0: normal distr. of residuals)", formatC(swtest$statistic, digits = digits), swstars)))
  }


  df <- data.frame(do.call(rbind, z))

  a <- print(xtable(df), type = "html", html.table.attributes = "class = 'table table-condensed'", include.rownames = FALSE, include.colnames = FALSE,  print.results = FALSE)

  a <- gsub(' \\*\\*\\* ', '<span class="label label-table label-error">0.1%</span>', a)
  a <- gsub(' \\*\\* ', '<span class="label label-table label-error">1%</span>', a)
  a <- gsub(' \\* ', '<span class="label label-table label-warning">5%</span>', a)
  a <- gsub(' \\. ', '<span class="label label-table label-default">10%</span>', a)


  a <- gsub('\\(', '<br><small class="text-muted">', a)
  a <- gsub('\\)', '</small>', a)
  a
}



