# If googleErrorReportingR is not installed:
# devtools::install_github("https://github.com/ixpantia/googleErrorReportingR")
# 
# Also, please make sure that you have the following environmental variables set
#  PROJECT_ID=<your gcp project id>
#  ERROR_REPORTING_API_KEY=<your api key>
# 
# Based in plumber examples in:  https://www.rplumber.io/

library(plumber)
library(tidyverse)
library(googleErrorReportingR)
message <- googleErrorReportingR::format_error_message()
message$serviceContext$service <- "errordemos"
message$serviceContext$version <- "v0.0.1"

#* @apiTitle Plumber Example API

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg = "") {
  list(msg = paste0("The message is: '", msg, "'"))
}

#* Plot a histogram
#* @serializer png
#* @param n The number of random values
#* @get /plot
function(n = 100) {

  if (n < 0) {

    # This is to try to catch the error before the stop (stop demo)

    googleErrorReportingR::report_error(message)

    stop("Argument should be an integer greather than 0")


  } else {
      rand <- rnorm(n)
      result <- tryCatch({
        hist(rand)
      }, warning = function(w) {
        message$message <- w
        googleErrorReportingR::report_error(message)
      }, error = function(e) {
        message$message <- e
        googleErrorReportingR::report_error(message)
      }, finally = {
        message$message <- "finally"
        googleErrorReportingR::report_error(message)
      })
      
  }

}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b) {
  as.numeric(a) + as.numeric(b)
}


