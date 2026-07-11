consort_for_plotting <- function() {
  cohorts <- test_cohort()

  cohorts %>%
    consort_box_add("full", 0, 20, cohort_count_adorn(cohorts, .full)) %>%
    consort_box_add(
      "exclusions", 10, 10, cohort_count_adorn(cohorts, excluded),
      hjust = 0
    ) %>%
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
    theme_consort(margin_h = 16, margin_v = 1)

  vdiffr::expect_doppelganger("consort-diagram", p)
})

test_that("geom_consort() anchors arrows at measured box edges", {
  consort <- consort_for_plotting()
  p <- ggplot2::ggplot(consort) +
    geom_consort() +
    theme_consort()

  path <- tempfile(fileext = ".pdf")
  on.exit(unlink(path), add = TRUE)
  grDevices::pdf(path, width = 7, height = 5)
  g <- grid::grid.force(ggplot2::ggplotGrob(p), draw = TRUE)
  grDevices::dev.off()

  tree <- grid::getGrob(g, "consort_diagram_grob", grep = TRUE)
  seg <- grid::getGrob(tree, "segments", grep = TRUE)

  # anchors in npc: data range 0..20 (y) and 0..10 (x), plus 5% expansion
  npc_y <- function(y) (y + 1) / 22
  npc_x <- function(x) (x + 0.5) / 11

  x0 <- as.numeric(seg$x0)
  y0 <- as.numeric(seg$y0)
  x1 <- as.numeric(seg$x1)
  y1 <- as.numeric(seg$y1)

  # arrow 1: full (bottom) -> consented (top), trimmed to the measured edges
  expect_equal(x0[1], npc_x(0))
  expect_equal(x1[1], npc_x(0))
  expect_lt(y0[1], npc_y(20))
  expect_gt(y1[1], npc_y(0))

  # arrow 2: explicit start on the spine -> left edge of the hjust = 0 side
  # box, whose left edge sits exactly at its anchor
  expect_equal(y0[2], npc_y(10))
  expect_equal(y1[2], npc_y(10))
  expect_equal(x0[2], npc_x(0))
  expect_equal(x1[2], npc_x(10), tolerance = 1e-6)
})
