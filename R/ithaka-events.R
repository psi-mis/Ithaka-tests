
ithaka_des <- httr::GET(paste0(baseurl, "api/programStages/KUlYsnUDuOS?fields=programStageDataElements[dataElement[id,name,optionSet[name,%20options[name,code]]]]"),
                        ua) %>%
  httr::content(., "text") %>%
  jsonlite::fromJSON(.)

ithaka_des <- ithaka_des$programStageDataElements$dataElement

ithaka_des_with_optionset <- ithaka_des[which(!is.na(ithaka_des$optionSet$name)),]

# pull ithaka events
ithaka_events <- httr::GET(paste0(baseurl, "api/events?program=g4P0sySF7KD&paging=false")) %>%
  httr::content(., "text") %>%
  jsonlite::fromJSON(.)


not_empty <- function(df){
  if (dim(df)[1] > 0){
    TRUE
  } else{
    FALSE
  }
}

# filter thee events with dataValues to reveiw
ithaka_events_to_reveiw <- ithaka_events$events[which(purrr::map_lgl(ithaka_events$events$dataValues, not_empty)),]

# dataValues_wider view

ithaka_events_to_reveiw$dataValues <- purrr::map(ithaka_events_to_reveiw$dataValues, function(x){
 tidyr::pivot_wider(x, 4, "dataElement",) %>%
    dplyr::select(tidyselect::any_of(ithaka_des_with_optionset$id))

})



# ithaka_des_with_optionsets <- ithaka_des %>%
#   dplyr::filter(!is.na(.$programStageDataElements$dataElement$optionSet$name))


