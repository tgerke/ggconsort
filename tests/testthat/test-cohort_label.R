test_that("cohort_label() stores labels on the cohort", {
  cohorts <- test_cohort()

  expect_equal(cohorts$labels$consented, "Consented")
  expect_equal(cohorts$labels$excluded, "Declined to participate")
})

test_that("cohort_label() overwrites an existing label", {
  cohorts <- test_cohort() |>
    cohort_label(consented = "Enrolled")

  expect_equal(cohorts$labels$consented, "Enrolled")
})

test_that("cohort_label() rejects unknown cohort names", {
  expect_error(
    test_cohort() |> cohort_label(nonexistent = "Oops"),
    "Unknown cohort name"
  )
})

test_that("cohort_label() rejects labels that are not length-1 strings", {
  cohorts <- test_cohort()

  expect_error(
    cohorts |> cohort_label(consented = 1),
    "Label must be a single string"
  )
  expect_error(
    cohorts |> cohort_label(consented = c("A", "B")),
    "Label must be a single string"
  )
  expect_error(
    cohorts |> cohort_label(consented = NA_character_),
    "Label must be a single string"
  )
  expect_error(
    cohorts |> cohort_label(consented = 1, excluded = "Fine", .full = NULL),
    "Labels must be a single string, not NA: .consented., ..full."
  )
})
