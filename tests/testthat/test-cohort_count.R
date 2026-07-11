test_that("cohort_count() counts all cohorts with labels", {
  counts <- cohort_count(test_cohort())

  expect_s3_class(counts, "tbl_df")
  expect_equal(counts$cohort, c(".full", "consented", "excluded"))
  expect_equal(counts$count, c(10L, 7L, 3L))
  expect_equal(
    counts$label,
    c("Assessed for eligibility", "Consented", "Declined to participate")
  )
})

test_that("cohort_count() subsets cohorts with tidyselect", {
  counts <- cohort_count(test_cohort(), dplyr::starts_with("consent"))

  expect_equal(counts$cohort, "consented")
  expect_equal(counts$count, 7L)
})

test_that("cohort_count() requires a ggconsort cohort", {
  expect_error(cohort_count(mtcars), "must be a ggconsort cohort")
})

test_that("cohort_count_int() returns a named integer vector", {
  expect_equal(
    cohort_count_int(test_cohort()),
    c(.full = 10L, consented = 7L, excluded = 3L)
  )
})

test_that("cohort_count_adorn() glues labels and counts", {
  expect_equal(
    cohort_count_adorn(test_cohort(), consented),
    "Consented (n = 7)"
  )
})

test_that("cohort_count_adorn() formats counts with commas (#23)", {
  big_cohort <- dplyr::tibble(id = seq_len(5234)) %>%
    cohort_start("Records")

  expect_equal(
    cohort_count_adorn(big_cohort, .full),
    "Records (n = 5,234)"
  )
})

test_that("cohort_count_adorn() accepts a custom .label_fn", {
  out <- cohort_count_adorn(
    test_cohort(),
    consented,
    .label_fn = function(cohort, label, count, ...) {
      glue::glue("{count} {label} ({cohort})")
    }
  )

  expect_equal(as.character(out), "7 Consented (consented)")
})
