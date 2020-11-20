

# Set up ------------------------------------------------------------------

library(gsheetr)
library(jsonlite)
library(httr)
library(magrittr)

baseurl <- "https://clone.psi-mis.org/"
base <- substr(baseurl, 9,25)

gsheetr::login_dhis2(baseurl,
                     usr = keyringr::get_kc_account(base, "internet"),
                     pwd = keyringr::decrypt_kc_pw(base, "internet"))

ua <- httr::user_agent("Isaiah Nyabuto <inyabuto@psi.org>")

# Get all the enrollments
ithaka_tei <- httr::GET(paste0(baseurl,"api/trackedEntityInstances.json?program=g4P0sySF7KD&ou=rP1W74RpNWF&ouMode=DESCENDANTS&fields=trackedEntityInstance,enrollments[enrollment]&paging=false"),
                        ua) %>%
  httr::content(., "text") %>%
  jsonlite::fromJSON(.) %>%
  .$trackedEntityInstances


# Get the ithaka enrollments
ithaka_enrollments <- ithaka_tei$enrollments %>%
  purrr::map(., function(x){
    if (nrow(x) > 1){
      len <- nrow(x)
      x[2:len,1]
    } else{
      x
    }
  })

# Filter the ones to delete
ithaka_enrollments_to_delete <- Filter(is.character, ithaka_enrollments) %>%
  unlist()

## Delete enrollments
# ithaka_enrollments_to_delete_d <- purrr::map(ithaka_enrollments_to_delete, function(x){
#   DELETE(paste0(baseurl, "api/enrollments/", x), ua)
# })



