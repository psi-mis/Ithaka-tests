#' Review & Delete Ithaka TEIs
#' 
#' Test server : clone.psi-mis.org
#' Production : data.psi-mis.org
#' 
#' @author Isaiah



# Set up ------------------------------------------------------------------

library(httr)
library(jsonlite)
library(googlesheets4)
library(hivstr)
library(magrittr)

# the server url e.g https://clone.psi-mis.org/
baseurl <- "https://clone.psi-mis.org/"
username <- ""
password <- ""

# wait time in seconds e.g 
sleep_time <- 60



hivstr::api_basic_auth(baseurl = baseurl, 
                       username = username,
                       password = password) -> login_d

if (!identical(login_d, T)){
  stop("Wrong server url, username or password!", call. = F)
}




googlesheets4::read_sheet("https://docs.google.com/spreadsheets/d/1KmiWZkova_FuYy6Gt6Hb_juH8sHAixubJV9WD3JYJVw/edit#gid=2107571705",
                          sheet = "duplicates-DHIS2") -> ithaka_teis

ithaka_teis_data <- purrr::map( ithaka_teis$Data.trackedEntityInstance, function(x){
  hivstr::api_get(
    URLencode(paste0(baseurl, "api/trackedEntityInstances/", x, "?fields=*"))
  ) 
}
)

ithaka_teis_data <- purrr::map(ithaka_teis_data, function(x){
  httr::content(x$response, "text") %>%
    fromJSON(.)
})

# delete
start_time <- Sys.time()
ithaka_teis_res <- purrr::map(ithaka_teis_data, function(x){
  
  if (has_enrollments(x)){
    if (has_events(x$enrollments) && is_one_event(x$enrollments)){
      httr::DELETE(
        paste0(baseurl, "api/events/", x$enrollments$events[[1]]$event) 
      ) -> event_d
    }
    
    if (is_one_enrollment(x)){
      httr::DELETE(
        paste0(baseurl, "api/enrollments/", x$enrollments$enrollment) 
      ) -> enrollment_d
    }
    
  }
  
  httr::DELETE(
    paste0(baseurl, "api/trackedEntityInstances/", x$trackedEntityInstance) 
  ) -> tei_d
  
  structure(
    list(
      trackedEntityInstance = tei_d,
      enrollment = enrollment_d,
      event = event_d
    ),
    class = "ithaka_delete_res"
  )
  
  #Sys.sleep(60)
})

end_time <- Sys.time()





  
has_events <- function(x){
  if ("events" %in% names(x)){
    if (length(x$events) != 0){
      TRUE
    } else{
      FALSE
    }
  } else{
    stop("Missing an enrollment!")
  }
}  

has_enrollments <- function(x){
  if ("enrollments" %in% names(x)){
    if (length(x$enrollments) != 0){
      TRUE
    } else{
      FALSE
      
    }
  } 
}

is_one_enrollment <- function(x){
  if (has_enrollments(x)){
    if (nrow(x$enrollments) == 1){
      TRUE
    } else{
      FALSE
      warning(
        sprintf("Tracked Entity Instance %s has more than one enrollemnt, only the first one will be deleted", sQuote(x$trackedEntityInstance)),
        call. = FALSE
      )
    }
  }
}

is_one_event <- function(x){
  if (has_events(x)){
    if (nrow(x$events[[1]]) == 1){
      TRUE
    } else{
      FALSE
      warning(
        sprintf("Enrollment %s has more than one event, only the first one will be deleted", sQuote(x$enrollments$enrollment)),
        call. = FALSE
      )
    }
  }
}




