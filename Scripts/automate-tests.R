# Automate tests

catf <- function(..., file = "./tests/testthat/test-mapping.R", append = TRUE){
  cat(..., file = file, append = append)
}

options(useFancyQuotes = FALSE)

purrr::imap(ithaka_events_to_reveiw$dataValues, function(x, .y){
  col_names <- names(x)
  purrr::walk(col_names, function(name){
    codes <- ithaka_des_with_optionset[which(ithaka_des_with_optionset$id == name),]$optionSet$options[[1]]$code

    fun_code <- sprintf(
      "test_that(paste0('Test that ', %s, ' is part of ', '%s', ' Event uid: ', '%s'), {
    #' @description Testing events data mapping
    expect_true(%s %s c(%s))
  }) \n", sQuote(x[[name]]), paste(codes, collapse = ", "), ithaka_events_to_reveiw$event[[.y]], sQuote(x[[name]]), "%in%", paste(sQuote(codes), collapse = ", ")
    )

    catf(fun_code)

  })
})



# gen report
testdown::test_down("Aviro - DHIS2 Integration", author = "Isaiah")
