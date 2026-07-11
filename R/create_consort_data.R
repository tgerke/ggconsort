#' Build the plotting data for a ggconsort diagram
#'
#' Combines the boxes, arrows, and lines of a \code{ggconsort} object into a
#' single tibble in the format expected by the [geom_consort()] geoms. Called
#' internally by \code{ggplot.ggconsort()}; you should rarely need to call it
#' directly.
#'
#' @param .data A \code{ggconsort} object built with [consort_box_add()] and
#'   friends.
#' @param ... Unused; reserved for future use.
#'
#' @return A tibble with one row per box, arrow, and line.
#'
#' @keywords internal
#' @export
create_consort_data <- function(.data, ...) {
  if (!inherits(.data, "ggconsort")) {
    stop(
      "`.data` must be a ggconsort object with diagram elements added by ",
      "`consort_box_add()`, `consort_arrow_add()`, or `consort_line_add()`.",
      call. = FALSE
    )
  }

  # columns that only some element types (or newer ggconsort versions) add
  elements <- .data$consort
  optional_defaults <- list(
    hjust = NA_real_, vjust = NA_real_,
    row = NA_real_, row2 = NA_real_, col = NA_real_, col2 = NA_real_,
    stage_fill = NA_character_, angle = NA_real_, tee_group = NA_character_,
    box_fill = NA_character_, border_color = NA_character_,
    text_color = NA_character_
  )
  for (nm in names(optional_defaults)) {
    if (!nm %in% names(elements)) elements[[nm]] <- optional_defaults[[nm]]
  }

  is_box <- elements$type == "box"
  grid_mode <- any(is_box & !is.na(elements$row))
  if (grid_mode && any(is_box & is.na(elements$row))) {
    stop(
      "All boxes must use the same layout: either `row`/`col` grid ",
      "positions or `x`/`y` coordinates, not a mixture.",
      call. = FALSE
    )
  }
  if (!grid_mode && any(elements$type == "stage")) {
    stop(
      "`consort_stage_add()` requires a row/column layout; ",
      "give your boxes `row`/`col` positions.",
      call. = FALSE
    )
  }
  is_edge <- elements$type %in% c("arrow", "line")
  has_explicit <- !is.na(elements$start_x) | !is.na(elements$start_y) |
    !is.na(elements$end_x) | !is.na(elements$end_y)
  if (grid_mode && any(is_edge & has_explicit)) {
    stop(
      "Explicit arrow/line coordinates (`start_x`, `end_y`, ...) are not ",
      "available in a row/column layout; connect boxes by name instead.",
      call. = FALSE
    )
  }

  consort_boxes <- elements |>
    dplyr::filter(.data$type == "box") |>
    dplyr::select(
      "name", "box_x", "box_y", "label", "row", "col",
      "box_fill", "border_color", "text_color",
      hjust_user = "hjust", vjust_user = "vjust"
    )

  # box coordinates for connecting arrows and lines by box name
  box_anchors <- consort_boxes |>
    dplyr::select("name", "box_x", "box_y")

  consort_arrows <- elements |>
    dplyr::filter(.data$type == "arrow") |>
    dplyr::select(
      "start", "start_side", "end", "end_side",
      "start_x", "start_y", "end_x", "end_y", "tee_group"
    )
  # if no arrows are set up, allow the joins so the box prints
  if (nrow(consort_arrows) == 0) {
    consort_arrows <- dplyr::bind_rows(
      consort_arrows,
      dplyr::tibble(
        start = NA, start_side = NA, end = NA, end_side = NA,
        start_x = NA, start_y = NA, end_x = NA, end_y = NA,
        tee_group = NA_character_
      )
    )
  }

  consort_lines <- elements |>
    dplyr::filter(.data$type == "line") |>
    dplyr::select(
      "start", "start_side", "end", "end_side",
      "start_x", "start_y", "end_x", "end_y"
    )
  # if no lines are set up, allow the joins so the box prints
  if (nrow(consort_lines) == 0) {
    consort_lines <- dplyr::bind_rows(
      consort_lines,
      dplyr::tibble(
        start = NA, start_side = NA, end = NA, end_side = NA,
        start_x = NA, start_y = NA, end_x = NA, end_y = NA
      )
    )
  }

  # one row per box regardless of how many arrows come in; justification is
  # inferred across all entry sides (top beats center vertically, left beats
  # right horizontally)
  arrow_entries <- consort_arrows |>
    dplyr::filter(!is.na(.data$end), !is.na(.data$end_side)) |>
    # with no named-end arrows, `end` is logical NA and can't join on `name`
    dplyr::mutate(end = as.character(.data$end)) |>
    dplyr::distinct(.data$end, .data$end_side) |>
    dplyr::group_by(.data$end) |>
    dplyr::summarise(
      arrow_in = paste(.data$end_side, collapse = ","),
      vjust_arrow = dplyr::if_else(any(.data$end_side == "top"), 1, .5),
      hjust_arrow = dplyr::case_when(
        any(.data$end_side == "left") ~ 0,
        any(.data$end_side == "right") ~ 1,
        TRUE ~ .5
      ),
      .groups = "drop"
    )

  boxes <- dplyr::left_join(
    consort_boxes,
    arrow_entries,
    by = c("name" = "end")
  ) |>
    dplyr::mutate(
      # blended hjust/vjust (user beats arrow-based inference, #24) feed the
      # legacy geom_consort_box(); geom_consort() reads only hjust/vjust_user
      # and measures boxes at draw time instead
      vjust = dplyr::coalesce(.data$vjust_user, .data$vjust_arrow, .5),
      hjust = dplyr::coalesce(.data$hjust_user, .data$hjust_arrow, .5),
      x = .data$box_x,
      y = .data$box_y,
      type = "box"
    ) |>
    dplyr::select(-"hjust_arrow", -"vjust_arrow")

  arrows <- dplyr::left_join(
    consort_arrows,
    box_anchors |>
      dplyr::rename(x = "box_x", y = "box_y"),
    by = c("start" = "name")
  ) |>
    dplyr::left_join(
      box_anchors |>
        dplyr::rename(xend = "box_x", yend = "box_y"),
      by = c("end" = "name")
    ) |>
    dplyr::mutate(
      x = dplyr::if_else(!is.na(.data$start_x), as.numeric(.data$start_x), .data$x),
      y = dplyr::if_else(!is.na(.data$start_y), as.numeric(.data$start_y), .data$y),
      xend = dplyr::if_else(!is.na(.data$end_x), as.numeric(.data$end_x), .data$xend),
      yend = dplyr::if_else(!is.na(.data$end_y), as.numeric(.data$end_y), .data$yend),
      type = "arrow"
    ) |>
    dplyr::select(-"start_x", -"start_y", -"end_x", -"end_y")

  lines <- dplyr::left_join(
    consort_lines,
    box_anchors |>
      dplyr::rename(x = "box_x", y = "box_y"),
    by = c("start" = "name")
  ) |>
    dplyr::left_join(
      box_anchors |>
        dplyr::rename(xend = "box_x", yend = "box_y"),
      by = c("end" = "name")
    ) |>
    dplyr::mutate(
      x = dplyr::if_else(is.na(.data$start_x), .data$x, as.numeric(.data$start_x)),
      y = dplyr::if_else(is.na(.data$start_y), .data$y, as.numeric(.data$start_y)),
      xend = dplyr::if_else(is.na(.data$end_x), .data$xend, as.numeric(.data$end_x)),
      yend = dplyr::if_else(is.na(.data$end_y), .data$yend, as.numeric(.data$end_y)),
      type = "line"
    ) |>
    dplyr::select(-"start_x", -"start_y", -"end_x", -"end_y")

  # stage badges at col = "margin" (stored as -Inf) go one column left of
  # the leftmost box, now that every box position is known
  margin_col <- suppressWarnings(min(elements$col[is_box], na.rm = TRUE)) - 1
  stages <- elements |>
    dplyr::filter(.data$type == "stage") |>
    dplyr::mutate(
      col = dplyr::if_else(is.infinite(.data$col), margin_col, .data$col),
      col2 = dplyr::coalesce(.data$col2, .data$col),
      col2 = dplyr::if_else(is.infinite(.data$col2), margin_col, .data$col2)
    ) |>
    dplyr::transmute(
      .data$label,
      x = (.data$col + .data$col2) / 2, y = .data$box_y,
      .data$row, .data$row2, .data$col, .data$col2,
      .data$stage_fill, .data$angle,
      type = "stage"
    )

  out <- dplyr::bind_rows(boxes, arrows, lines, stages) |>
    dplyr::mutate(
      dplyr::across(
        c("start", "end", "start_side", "end_side"),
        as.character
      )
    )

  # drop rows that are all-NA apart from their type
  out |>
    dplyr::filter(
      rowSums(is.na(out)) != (ncol(out) - 1)
    )
}
