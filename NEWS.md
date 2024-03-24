# seasonalview 0.4.0

Bug fixes:

* Remove warning about 'xts::indexClass' is deprecated. #15
* Significance tags visible for all levels #14


# seasonalview 0.3  2017-05-04

Bug fixes:

* do not add empty x11 = "" at the end of the R call
  https://github.com/christophsax/seasonalview/issues/10
* 'auto expand' of R and X-13 box was buggy and has been removed
  https://github.com/christophsax/seasonalview/issues/12
* add 'err_to_html' to seasonal, which was removed from the seasonal package,
  causing an application crash on error.
* less verbosity on the console. No output is written, unless it's a bug.


# seasonalview 0.2  2017-02-11

Under the hood:

* better way to pass stuff to shiny app, using shinyOptions().
* uses import.spc() from seasonal 1.4 for X-13 spc parsing.
* workaround functions to properly import xts, which depends on zoo functions,
  so that seasonalview can be imported from other packages, such as seasonal.
  This will be reworked once a new version of xts is on CRAN.
  https://github.com/joshuaulrich/xts/issues/162

Bug fixes:

* Fixed issue that led to a crash when X-13 code was manipulated.


# seasonalview 0.1.3  2016-12-14

* Initial CRAN Version
