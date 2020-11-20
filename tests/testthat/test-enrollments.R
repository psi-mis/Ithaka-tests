test_that("Enrollments are single", {
  #' @description Testing that there are no multiple enrollments in a TEI
  expect_null(ithaka_enrollments_to_delete)
})
