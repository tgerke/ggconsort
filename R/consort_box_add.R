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
#' `"left"` (column -1), or any number. At draw time ggconsort measures every
#' box on the open graphics device and lays the grid out to fill the plot:
#' row gaps are equalized, columns are spread so boxes never overlap, and
#' nothing is clipped, whatever the device size.
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
#'   `**bold**`. [cohort_count_adorn()] is a convenient way to build labels
#'   with cohort counts.
#' @param hjust,vjust Optional numeric justification of the box relative to
#'   (`x`, `y`), in `[0, 1]`. By default boxes are centered on their
#'   coordinates (`hjust = vjust = 0.5`). E.g. `hjust = 0` places the box's
#'   left edge at `x`. Ignored in row/column layouts.
#' @param row,col Grid position of the box or stage badge (see the
#'   "Row/column layout" section). For `consort_stage_add()`, `row` may be a
#'   length-2 vector to center the badge across a span of rows.
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
#' @param fill Fill color of the stage badge.
#' @param angle Rotation of the stage badge text, in degrees (e.g. `90` for
#'   the vertical labels of a PRISMA diagram).
#'
#' @return A \code{ggconsort} object.
#'
#' @examples
#' cohorts <- trial_data %>%
#'   cohort_start("Assessed for eligibility") %>%
#'   cohort_define(
#'     randomized = .full %>% dplyr::filter(declined != 1),
#'     excluded = dplyr::anti_join(.full, randomized, by = "id")
#'   ) %>%
#'   cohort_label(
#'     randomized = "Randomized",
#'     excluded = "Declined to participate"
#'   )
#'
#' # row/column layout: no coordinates, spacing computed at draw time
#' consort <- cohorts %>%
#'   consort_box_add("full", row = 1, col = "main",
#'     label = cohort_count_adorn(cohorts, .full)) %>%
#'   consort_box_add("exclusions", row = 2, col = "side",
#'     label = cohort_count_adorn(cohorts, excluded)) %>%
#'   consort_box_add("randomized", row = 3, col = "main",
#'     label = cohort_count_adorn(cohorts, randomized)) %>%
#'   consort_arrow_add(start = "full", end = "randomized") %>%
#'   consort_arrow_add(start = "full", end = "exclusions")
#'
#' library(ggplot2)
#' ggplot(consort) +
#'   geom_consort() +
#'   theme_consort()
#' @export
consort_box_add <- function(
  .data, name, x = NULL, y = NULL, label,
  hjust = NULL, vjust = NULL, row = NULL, col = NULL
) {
  .data <- consort_start(.data)

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
  .data, label, row, col = "left", fill = "#9bc0fc", angle = 0
) {
  .data <- consort_start(.data)

  if (!is.numeric(row) || !length(row) %in% 1:2) {
    stop("`row` must be one row number, or two to span rows.", call. = FALSE)
  }
  col <- resolve_col(col)
  row_first <- min(row)
  row_last <- max(row)

  .data$consort <- dplyr::bind_rows(
    .data$consort,
    dplyr::tibble(
      name = NA, label = label,
      box_x = col, box_y = -mean(c(row_first, row_last)),
      hjust = NA_real_, vjust = NA_real_,
      row = row_first, row2 = row_last, col = as.numeric(col),
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
    resolved <- c(main = 0, side = 1, left = -1)[col]
    if (!is.na(resolved)) {
      return(unname(resolved))
    }
  }
  stop(
    "`col` must be \"main\", \"side\", \"left\", or a single number.",
    call. = FALSE
  )
}
