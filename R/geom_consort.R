#' CONSORT diagram layers for ggplot2
#'
#' `geom_consort()` draws the boxes, arrows, and lines of a `ggconsort` object
#' created with [consort_box_add()], [consort_arrow_add()], and
#' [consort_line_add()]. It measures the rendered size of each box at draw
#' time, so boxes are centered on their (`x`, `y`) coordinates and arrows
#' start and end exactly at box edges, whatever the device size.
#' `geom_consort_arrow()` and `geom_consort_box()` are the legacy component
#' layers, which anchor arrows at box centers and shift box text by its
#' justification; they remain available for diagrams that depend on that
#' behavior. `geom_consort_line()` draws a standalone line segment with the
#' same styling as the diagram lines.
#'
#' @param label_color Color of the box label text.
#' @param label_size Size of the box label text, in points.
#' @param label_height Line height of the box label text.
#' @param fill Fill color of the boxes.
#' @param box_color Color of the box borders.
#' @param ... For `geom_consort_box()`, additional arguments passed to
#'   [ggtext::geom_richtext()]. Ignored by `geom_consort_arrow()`.
#'
#' @return A ggplot2 layer or list of layers that can be added to a plot.
#'
#' @examples
#' cohorts <- trial_data |>
#'   cohort_start("Assessed for eligibility") |>
#'   cohort_define(
#'     randomized = .full |> dplyr::filter(declined != 1)
#'   ) |>
#'   cohort_label(randomized = "Randomized")
#'
#' consort <- cohorts |>
#'   consort_box_add("full", 0, 10, cohort_count_adorn(cohorts, .full)) |>
#'   consort_box_add("randomized", 0, 0, cohort_count_adorn(cohorts, randomized)) |>
#'   consort_arrow_add("full", "bottom", "randomized", "top")
#'
#' library(ggplot2)
#' ggplot(consort) +
#'   geom_consort() +
#'   theme_consort(margin_h = 12, margin_v = 5)
#' @export
geom_consort <- function(
  label_color = "black", label_size = 11, label_height = 1,
  fill = "white", box_color = "black"
) {
  ggplot2::layer(
    geom = GeomConsortDiagram,
    stat = "identity",
    position = "identity",
    data = NULL,
    mapping = ggplot2::aes(
      x = .data$x, y = .data$y, xend = .data$xend, yend = .data$yend,
      label = .data$label, type = .data$type, name = .data$name,
      start = .data$start, end = .data$end,
      start_side = .data$start_side, end_side = .data$end_side,
      hjust = .data$hjust_user, vjust = .data$vjust_user,
      # `col` would collide with the ggplot2 colour alias, hence layout_*
      layout_row = .data$row, layout_row2 = .data$row2, layout_col = .data$col,
      stage_fill = .data$stage_fill, angle = .data$angle,
      tee_group = .data$tee_group
    ),
    show.legend = FALSE,
    inherit.aes = FALSE,
    params = list(
      label_color = label_color,
      label_size = label_size,
      label_height = label_height,
      fill = fill,
      box_color = box_color
    )
  )
}
