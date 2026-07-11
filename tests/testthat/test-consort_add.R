test_that("consort_box_add() converts a cohort to a ggconsort object", {
  consort <- test_cohort() %>%
    consort_box_add("full", 0, 10, "Assessed")

  expect_s3_class(consort, "ggconsort")
  expect_s3_class(consort, "ggconsort_cohort")
  expect_equal(nrow(consort$consort), 1)
  expect_equal(consort$consort$type, "box")
  expect_equal(consort$consort$name, "full")
})

test_that("consort_box_add() stores hjust/vjust overrides (#24)", {
  consort <- test_cohort() %>%
    consort_box_add("a", 0, 10, "A") %>%
    consort_box_add("b", 0, 0, "B", hjust = 0, vjust = 1)

  expect_equal(consort$consort$hjust, c(NA, 0))
  expect_equal(consort$consort$vjust, c(NA, 1))
})

test_that("consort_arrow_add() and consort_line_add() add typed rows", {
  consort <- test_cohort() %>%
    consort_box_add("a", 0, 10, "A") %>%
    consort_box_add("b", 0, 0, "B") %>%
    consort_arrow_add(start = "a", start_side = "bottom", end = "b", end_side = "top") %>%
    consort_line_add(start_x = -5, start_y = 5, end_x = 5, end_y = 5)

  expect_equal(consort$consort$type, c("box", "box", "arrow", "line"))
})
