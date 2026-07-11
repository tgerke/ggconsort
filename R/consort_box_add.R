#' Add boxes, arrows, lines, and stage badges to a CONSORT diagram
#'
#' These functions add the visual elements of a CONSORT diagram to a
#' \code{ggconsort_cohort} object, converting it to a \code{ggconsort} object
#' that can be plotted with [ggplot2::ggplot()] and [geom_consort()].
#'
#' * `consort_box_add()` adds a text box, either at explicit (`x`, `y`)
#'   coordinates or at a (`row`, `col`) grid position.
#' * `consort_arrow_add()` adds an arrow between two boxes (referenced by
#'   `name`) or between explicit coordinates.
#' * `consort_line_add()` adds a line without an arrow head, with the same
#'   interface as `consort_arrow_add()`.
#' * `consort_stage_add()` adds a stage badge (e.g. "Allocation") to a
#'   row/column layout.
#'
#' @section Row/column layout:
#' Instead of picking coordinates by hand, boxes can declare a grid position
#' with `row` and `col`. Rows count from 1 at the top. `col` is `"main"` (the
#' central spine, column 0), `"side"` (column 1, right of the spine),
#' `"left"` (column -1), or any number. Stage badges may also use
#' `"margin"` (their default), which resolves to one column left of the
#' leftmost box so badges sit in the margin, as in the official CONSORT and
#' PRISMA templates. At draw time ggconsort measures every box on the open
#' graphics device and lays the grid out to fill the plot: row gaps are
#' equalized (capped so large devices stay compact), columns are spread so
#' boxes never overlap, and nothing is clipped, whatever the device size.
#'
#' In a row/column layout, arrows need only `start` and `end` names:
#'
#' * boxes in the same column are connected vertically,
#' * boxes in the same row are connected horizontally,
#' * a box in another column and row is reached by a horizontal branch off
#'   the start box's vertical spine, at the height of the target box, and
#' * a vector `end` (e.g. `end = c("arm_a", "arm_b")`) draws the classic
#'   T-split: one drop from the start box, a crossbar, and an arrow down
#'   into each arm.
#'
#' A diagram must use either coordinates or rows/columns, not a mixture.
#'
#' @param .data A \code{ggconsort_cohort} object, or a \code{ggconsort} object
#'   returned by a previous `consort_*_add()` call.
#' @param name A character name identifying the box, used to connect arrows
#'   and lines to the box.
#' @param x,y Coordinates of the box. Omit them (and set `row`/`col`) to use
#'   the row/column layout instead.
#' @param label Text displayed in the box. Interpreted as markdown/HTML by
#'   ggtext/gridtext, so labels may contain formatting such as `<br>` or
#'   `**bold**`. When `name` matches a cohort defined with [cohort_define()],
#'   `label` may be omitted: the box is labeled automatically with the
#'   cohort's label and count, as by [cohort_count_adorn()].
#'   [cohort_count_bullets()] is a convenient way to build multi-line labels
#'   such as exclusion boxes.
#' @param hjust,vjust Optional numeric justification of the box relative to
#'   (`x`, `y`), in `[0, 1]`. By default boxes are centered on their
#'   coordinates (`hjust = vjust = 0.5`). E.g. `hjust = 0` places the box's
#'   left edge at `x`. Ignored in row/column layouts.
#' @param row,col Grid position of the box or stage badge (see the
#'   "Row/column layout" section). For `consort_stage_add()`, `row` and `col`
#'   may be length-2 vectors to center the badge across a span of rows or
#'   columns (e.g. `col = c("main", "side")` for a header bar spanning the
#'   diagram).
#' @param start,end Names of the boxes where the arrow or line starts and
#'   ends. In a row/column layout, `end` may be a vector of names to draw a
#'   T-split from `start` into several boxes.
#' @param start_side,end_side The side of the box (`"left"`, `"right"`,
#'   `"top"`, or `"bottom"`) that the arrow or line leaves from or points to.
#'   Optional: by default the sides follow from the relative positions of the
#'   two boxes.
#' @param start_x,start_y,end_x,end_y Explicit coordinates for the start and
#'   end of the arrow or line, as an alternative to naming boxes with
#'   `start`/`end`. Not available in row/column layouts.
#' @param fill For `consort_box_add()`, an optional fill color for this box,
#'   overriding the [geom_consort()] `fill`. For `consort_stage_add()`, the
#'   fill color of the stage badge.
#' @param color,text_color Optional border and text colors for this box,
#'   overriding the [geom_consort()] `box_color` and `label_color`.
#' @param angle Rotation of the stage badge text, in degrees (e.g. `90` for
#'   the vertical labels of a PRISMA diagram).
#'
#' @return A \code{ggconsort} object.
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
#' # row/column layout: no coordinates, spacing computed at draw time.
#' # Boxes named after a cohort are labeled automatically with its count.
#' consort <- cohorts |>
#'   consort_box_add("full", row = 1, col = "main",
#'     label = cohort_count_adorn(cohorts, .full)) |>
#'   consort_box_add("excluded", row = 2, col = "side") |>
#'   consort_box_add("randomized", row = 3, col = "main") |>
#'   consort_arrow_add(start = "full", end = "randomized") |>
#'   consort_arrow_add(start = "full", end = "excluded")
#'
#' library(ggplot2)
#' ggplot(consort) +
#'   geom_consort() +
#'   theme_consort()
#' @export
consort_box_add <- function(
  .data, name, x = NULL, y = NULL, label = NULL,
  hjust = NULL, vjust = NULL, row = NULL, col = NULL,
  fill = NULL, color = NULL, text_color = NULL
) {
  .data <- consort_start(.data)

  if (is.null(label)) {
    if (!name %in% names(.data$data)) {
      stop(
        "`label` is missing and \"", name, "\" is not a defined cohort. ",
        "Name the box after a cohort to label it automatically, or ",
        "supply `label`.",
        call. = FALSE
      )
    }
    label <- cohort_count_adorn(.data)[match(name, names(.data$data))]
  }

  has_xy <- !is.null(x) && !is.null(y)
  has_row <- !is.null(row)
  if (has_xy && has_row) {
    stop(
      "Supply either `x` and `y` or `row`/`col` for a box, not both.",
      call. = FALSE
    )
  }
  if (!has_xy && !has_row) {
    stop(
      "A box needs a position: either `x` and `y` coordinates, ",
      "or a `row` (with optional `col`) grid position.",
      call. = FALSE
    )
  }

  if (has_row) {
    col <- resolve_col(col %||% "main")
    # nominal coordinates; the actual layout is computed at draw time
    x <- col
    y <- -row
  } else {
    row <- NA_real_
    col <- NA_real_
  }

  .data$consort <- dplyr::bind_rows(
    .data$consort,
    dplyr::tibble(
      name = name, box_x = x, box_y = y, label = label,
      hjust = hjust %||% NA_real_, vjust = vjust %||% NA_real_,
      row = as.numeric(row), col = as.numeric(col),
      box_fill = fill %||% NA_character_,
      border_color = color %||% NA_character_,
      text_color = text_color %||% NA_character_,
      type = "box",
      start = NA, start_side = NA, end = NA, end_side = NA,
      start_x = NA, start_y = NA, end_x = NA, end_y = NA
    )
  )

  .data
}

#' @rdname consort_box_add
#' @export
consort_stage_add <- function(
  .data, label, row, col = "margin", fill = "#9bc0fc", angle = 0
) {
  .data <- consort_start(.data)

  if (!is.numeric(row) || !length(row) %in% 1:2) {
    stop("`row` must be one row number, or two to span rows.", call. = FALSE)
  }
  if (!length(col) %in% 1:2) {
    stop(
      "`col` must be one column, or two to span columns.",
      call. = FALSE
    )
  }
  col <- vapply(as.list(col), resolve_col, numeric(1))
  row_first <- min(row)
  row_last <- max(row)
  col_first <- min(col)
  col_last <- max(col)

  .data$consort <- dplyr::bind_rows(
    .data$consort,
    dplyr::tibble(
      name = NA, label = label,
      box_x = mean(c(col_first, col_last)),
      box_y = -mean(c(row_first, row_last)),
      hjust = NA_real_, vjust = NA_real_,
      row = row_first, row2 = row_last,
      col = col_first, col2 = col_last,
      stage_fill = fill, angle = angle,
      type = "stage",
      start = NA, start_side = NA, end = NA, end_side = NA,
      start_x = NA, start_y = NA, end_x = NA, end_y = NA
    )
  )

  .data
}

resolve_col <- function(col) {
  if (is.numeric(col) && length(col) == 1) {
    return(col)
  }
  if (is.character(col) && length(col) == 1) {
    # "margin" is a sentinel: create_consort_data() resolves it to one
    # column left of the leftmost box, so stage badges never collide with
    # boxes whatever columns the diagram uses
    resolved <- c(main = 0, side = 1, left = -1, margin = -Inf)[col]
    if (!is.na(resolved)) {
      return(unname(resolved))
    }
  }
  stop(
    "`col` must be \"main\", \"side\", \"left\", \"margin\", or a single ",
    "number.",
    call. = FALSE
  )
}
