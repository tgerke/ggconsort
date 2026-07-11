consort_for_plotting <- function() {
  cohorts <- test_cohort()

  cohorts %>%
    consort_box_add("full", 0, 20, cohort_count_adorn(cohorts, .full)) %>%
    consort_box_add("exclusions", 10, 10, cohort_count_adorn(cohorts, excluded)) %>%
    consort_box_add("consented", 0, 0, cohort_count_adorn(cohorts, consented)) %>%
    consort_arrow_add(
      start = "full", start_side = "bottom",
      end = "consented", end_side = "top"
    ) %>%
    consort_arrow_add(
      start_x = 0, start_y = 10,
      end = "exclusions", end_side = "left"
    )
}

test_that("plotting a cohort without consort elements is an error", {
  expect_error(
    ggplot2::ggplot(test_cohort()),
    "no diagram elements"
  )
})

test_that("plot.ggconsort() returns a ggplot", {
  p <- plot(consort_for_plotting())

  expect_s3_class(p, "ggplot")
})

test_that("building a consort plot raises no deprecation warnings (#28)", {
  p <- ggplot2::ggplot(consort_for_plotting()) +
    geom_consort() +
    theme_consort()

  expect_no_warning(ggplot2::ggplot_build(p))
})

test_that("geom_consort_box() converts label_size points to mm (#18)", {
  layer <- geom_consort_box(label_size = 14)

  expect_equal(layer$aes_params$size, 14 / ggplot2::.pt)
})

test_that("ggsave() works directly on a ggconsort object (#26)", {
  path <- tempfile(fileext = ".png")
  on.exit(unlink(path), add = TRUE)

  ggplot2::ggsave(path, consort_for_plotting(), width = 5, height = 4)

  expect_true(file.exists(path))
})

test_that("consort diagram renders consistently", {
  skip_if_not_installed("vdiffr")

  p <- ggplot2::ggplot(consort_for_plotting()) +
    geom_consort() +
    theme_consort(margin_h = 8, margin_v = 1)

  vdiffr::expect_doppelganger("consort-diagram", p)
})
