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
#' @param family Font family of the box label text. The default (`""`) uses
#'   the device default.
#' @param fill Fill color of the boxes. Individual boxes can override this
#'   with the `fill` argument of [consort_box_add()].
#' @param box_color Color of the box borders.
#' @param linewidth Width of the box borders; arrows and lines are drawn
#'   slightly lighter, in proportion.
#' @param box_r Corner radius of the boxes, in lines. The default `0` draws
#'   square corners, as in the official CONSORT and PRISMA templates.
#' @param box_padding Padding between a box's text and its border, in lines.
#' @param arrow_length Length of the arrow heads, in millimeters.
#' @param row_gap In a row/column layout, the vertical gap between rows, in
#'   lines. The default (`NULL`) equalizes the gaps to fill the panel, capped
#'   at 2 lines so the diagram stays compact on large devices.
#' @param equal_columns In a row/column layout, should all boxes in a column
#'   be drawn at the width of the column's widest box? The official CONSORT
#'   and PRISMA templates use uniform-width boxes.
#' @param ... For `geom_consort_box()`, additional arguments passed to
#'   [ggtext::geom_richtext()]. Ignored by `geom_consort_arrow()`.
#'
#' @return A ggplot2 layer or list of layers that can be added to a plot.
#'
#' @examples
#' cohorts <- trial_data |>
#'   cohort_start("Assessed for eligibility") |>
#'   cohort_define(
#'     randomized = .full |> dplyr::filter(declined != 1),
#'     excluded = dplyr::anti_join(.full, randomized, by = "id")
#'   ) |>
#'   cohort_label(
#'     randomized = "Randomized",
#'     excluded = "Declined to participate"
#'   )
#'
#' consort <- cohorts |>
#'   consort_box_add("full", row = 1, label = cohort_count_adorn(cohorts, .full)) |>
#'   consort_box_add("excluded", row = 2, col = "side") |>
#'   consort_box_add("randomized", row = 3) |>
#'   consort_arrow_add(start = "full", end = "randomized") |>
#'   consort_arrow_add(start = "full", end = "excluded")
#'
#' library(ggplot2)
#' ggplot(consort) +
#'   geom_consort() +
#'   theme_consort()
#' @export
geom_consort <- function(
  label_color = "black", label_size = 11, label_height = 1,
  family = "", fill = "white", box_color = "black",
  linewidth = 0.25, box_r = 0, box_padding = 0.25, arrow_length = 2,
  row_gap = NULL, equal_columns = FALSE
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
      layout_col2 = .data$col2,
      stage_fill = .data$stage_fill, angle = .data$angle,
      tee_group = .data$tee_group,
      box_fill = .data$box_fill,
      border_colour = .data$border_color, text_colour = .data$text_color
    ),
    show.legend = FALSE,
    inherit.aes = FALSE,
    params = list(
      label_color = label_color,
      label_size = label_size,
      label_height = label_height,
      family = family,
      fill = fill,
      box_color = box_color,
      linewidth = linewidth,
      box_r = box_r,
      box_padding = box_padding,
      arrow_length = arrow_length,
      row_gap = row_gap,
      equal_columns = equal_columns
    )
  )
}
