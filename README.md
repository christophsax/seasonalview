Graphical User Interface for Seasonal Adjustment
------------------------------------------------

<!-- badges: start -->
[![R-CMD-check](https://github.com/christophsax/seasonalview/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/christophsax/seasonalview/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->


An R package that unifies the 
[shiny](https://cran.r-project.org/package=shiny)-based graphical user 
interfaces from the [seasonal](https://cran.r-project.org/package=seasonal) and
[x13story](https://github.com/christophsax/x13story) packages and the online
adjustment tool on [www.seasonal.website](http://www.seasonal.website).

To install from CRAN, use:

    install.packages("seasonalview")


### Seasonal

The main function of the package is the `view` function, which works like the 
depreciated `inspect` function in
[seasonal](https://cran.r-project.org/package=seasonal) (which it replaces). 
[seasonalview](https://cran.r-project.org/package=seasonalview) is imported by [seasonal](https://cran.r-project.org/package=seasonal), so loading is not necessary:

    library(seasonal)  
    m <- seas(AirPassengers)
    view(m)

<img src="https://raw.githubusercontent.com/christophsax/seasonalview/master/img/seasonal.png" width="70%"/>


### X-13 Story

If you have the [x13story](https://github.com/christophsax/x13story) package
installed, you can call the function with the `story` argument. This will render
an 
[R Markdown document](https://raw.githubusercontent.com/christophsax/x13story/master/inst/stories/x11.Rmd) 
and produce a *story* on seasonal adjustment that can be manipulated
interactively.

    view(story = "https://raw.githubusercontent.com/christophsax/x13story/master/inst/stories/x11.Rmd")

<img src="https://raw.githubusercontent.com/christophsax/seasonalview/master/img/x13story.png" width="70%"/>


### Stand-alone

Finally, you can set up a stand-alone seasonal adjustment tool, either locally
or on a server. While itself not very useful, the `standalone` function
showcases how a local version of
[www.seasonal.website](http://www.seasonal.website) would look like:

    library(seasonalview)
    standalone()

<img src="https://raw.githubusercontent.com/christophsax/seasonalview/master/img/standalone.png" width="70%"/>


### License and Credits

**seasonalview** is free and open source, licensed under GPL-3. It is built on
top of a large number of great open source tools. It uses
[shiny](https://cran.r-project.org/package=shiny) and
[shinydashboard](https://cran.r-project.org/package=shinydashboard).
It also
uses [dygraphs](https://dygraphs.com/), and, of course,
[seasonal](https://cran.r-project.org/package=seasonal),
[x13binary](https://cran.r-project.org/package=x13binary) and
X-13ARIMA-SEATS, the wonderful seasonal
adjustment software by the U.S. Census Bureau.

Thanks for your feedback, your ideas and bug-reports. [Contact me.](mailto:christoph.sax@gmail.com)
