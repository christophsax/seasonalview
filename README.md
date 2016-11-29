Graphical User Interface for Seasonal Adjusmtent
------------------------------------------------

An R package that unifies the [shiny](https://cran.r-project.org/package=shiny)-
based graphical user interfaces from the
[seasonal](https://cran.r-project.org/package=seasonal) and
[x13story](https://github.com/christophsax/x13story) packages and the online
adjustment tool on [www.seasonal.website](https://www.seasonal.website).

These interfaces have grown over time and have become difficult to maintain. The
**seasonalview** package is an attempt to unify their code base. It  takes the
best from each interface, and makes it available to the others. In a way, this
is a summary of what I learned about
[shiny](https://cran.r-project.org/package=shiny) and web development over the
last years.

To install this early version of the package, use:

    devtools::install_packages("christophsax/seasonallab")

The main function of the package is the `view` function, which works exactly as
the current `inspect` function in
[seasonal](https://cran.r-project.org/package=seasonal). Here is an example:

    library(seaonalview)  # this will also load seasonal
    m <- seas(AirPassengers)
    view(m)

If you have the [x13story](https://github.com/christophsax/x13story) package
installed, you can call the function with the `story` argument. This will render
an R Markdown document and produce a *story* on seasonal adjustment that can be
manipulated interactively.

    mystory <- system.file(package = "x13story", "stories", "x11.Rmd")
    view(story = mystory)

Finally, you can set up a stand-alone seasonal adjustment tool, either locally
or on a server. While itself not very useful, the `standalone` function
showcases how a local version of
[www.seasonal.website](https://www.seasonal.website) would look like this:

    standalone()

Thanks for your feedback, ideas, bug-reports. 
[Contact me.](mailto:christoph.sax@gmail.com)
