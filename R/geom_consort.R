#' CONSORT diagram layers for ggplot2
#'
#' `geom_consort()` draws the boxes, arrows, and lines of a `ggconsort` object
#' created with [consort_box_add()], [consort_arrow_add()], and
#' [consort_line_add()]. It is the layer you will typically add to
#' `ggplot(<ggconsort object>)`, and it combines `geom_consort_arrow()` and
#' `geom_consort_box()`, which can also be used individually.
#' `geom_consort_line()` draws a standalone line segment with the same styling
#' as the diagram lines.
#'
#' @param label_color Color of the box label text.
#' @param label_size Size of the box label text, in points.
#' @param label_height Line height of the box label text.
#' @param ... Additional arguments passed to [ggtext::geom_richtext()] by
#'   `geom_consort_box()`, e.g. `fill`. Ignored by `geom_consort_arrow()`.
#'
#' @return A ggplot2 layer or list of layers that can be added to a plot.
#'
#' @examples
#' cohorts <- trial_data %>%
#'   cohort_start("Assessed for eligibility") %>%
#'   cohort_define(
#'     randomized = .full %>% dplyr::filter(declined != 1)
#'   ) %>%
#'   cohort_label(randomized = "Randomized")
#'
#' consort <- cohorts %>%
#'   consort_box_add("full", 0, 10, cohort_count_adorn(cohorts, .full)) %>%
#'   consort_box_add("randomized", 0, 0, cohort_count_adorn(cohorts, randomized)) %>%
#'   consort_arrow_add("full", "bottom", "randomized", "top")
#'
#' library(ggplot2)
#' ggplot(consort) +
#'   geom_consort() +
#'   theme_consort()
#' @export
geom_consort <- function(...) {
  list(
    geom_consort_arrow(...),
    geom_consort_box(...)
  )
}
