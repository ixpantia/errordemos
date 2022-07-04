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
library(jsonlite)
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
#* @serializer json
#* @param n The number of random values
#* @get /error
function(n = 100) {
  
  result <- tryCatch(
    rnorm(n), 
    error = function(e) {
    message$message <- as.character(e)
    googleErrorReportingR::report_error(message)
    return(as.character(e))
  })
      
  return(result)
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b) {
  as.numeric(a) + as.numeric(b)
}


