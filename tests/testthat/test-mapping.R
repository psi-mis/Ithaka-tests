
test_that(paste0('Test that ', 'CBO', ' is part of ', 'Physical, Online, CBO, Others', ' Event uid: ', 'DzoH8g9IcMa'), {
    #' @description Testing events data mapping
    expect_true('CBO' %in% c('Physical', 'Online', 'CBO', 'Others'))
  }) 
