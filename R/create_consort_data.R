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

  consort_boxes <- .data$consort %>%
    dplyr::filter(.data$type == "box")
  # consorts built without boxes never gain hjust/vjust columns
  if (!"hjust" %in% names(consort_boxes)) consort_boxes$hjust <- NA_real_
  if (!"vjust" %in% names(consort_boxes)) consort_boxes$vjust <- NA_real_
  consort_boxes <- consort_boxes %>%
    dplyr::select(
      "name", "box_x", "box_y", "label",
      hjust_user = "hjust", vjust_user = "vjust"
    )

  # box coordinates for connecting arrows and lines by box name
  box_anchors <- consort_boxes %>%
    dplyr::select("name", "box_x", "box_y")

  consort_arrows <- .data$consort %>%
    dplyr::filter(.data$type == "arrow") %>%
    dplyr::select(
      "start", "start_side", "end", "end_side",
      "start_x", "start_y", "end_x", "end_y"
    )
  # if no arrows are set up, allow the joins so the box prints
  if (nrow(consort_arrows) == 0) {
    consort_arrows <- dplyr::bind_rows(
      consort_arrows,
      dplyr::tibble(
        start = NA, start_side = NA, end = NA, end_side = NA,
        start_x = NA, start_y = NA, end_x = NA, end_y = NA
      )
    )
  }

  consort_lines <- .data$consort %>%
    dplyr::filter(.data$type == "line") %>%
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
  arrow_entries <- consort_arrows %>%
    dplyr::filter(!is.na(.data$end), !is.na(.data$end_side)) %>%
    # with no named-end arrows, `end` is logical NA and can't join on `name`
    dplyr::mutate(end = as.character(.data$end)) %>%
    dplyr::distinct(.data$end, .data$end_side) %>%
    dplyr::group_by(.data$end) %>%
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
  ) %>%
    dplyr::mutate(
      # user-supplied justification wins over arrow-based inference (#24)
      vjust = dplyr::coalesce(.data$vjust_user, .data$vjust_arrow, .5),
      hjust = dplyr::coalesce(.data$hjust_user, .data$hjust_arrow, .5),
      type = "box"
    ) %>%
    dplyr::select(
      -"hjust_user", -"vjust_user", -"hjust_arrow", -"vjust_arrow"
    )

  arrows <- dplyr::left_join(
    consort_arrows,
    box_anchors %>%
      dplyr::rename(x = "box_x", y = "box_y"),
    by = c("start" = "name")
  ) %>%
    dplyr::left_join(
      box_anchors %>%
        dplyr::rename(xend = "box_x", yend = "box_y"),
      by = c("end" = "name")
    ) %>%
    dplyr::mutate(
      x = dplyr::if_else(!is.na(.data$start_x), as.numeric(.data$start_x), .data$x),
      y = dplyr::if_else(!is.na(.data$start_y), as.numeric(.data$start_y), .data$y),
      xend = dplyr::if_else(!is.na(.data$end_x), as.numeric(.data$end_x), .data$xend),
      yend = dplyr::if_else(!is.na(.data$end_y), as.numeric(.data$end_y), .data$yend),
      type = "arrow"
    ) %>%
    dplyr::select(-dplyr::starts_with("start_"), -dplyr::starts_with("end_"))

  lines <- dplyr::left_join(
    consort_lines,
    box_anchors %>%
      dplyr::rename(x = "box_x", y = "box_y"),
    by = c("start" = "name")
  ) %>%
    dplyr::left_join(
      box_anchors %>%
        dplyr::rename(xend = "box_x", yend = "box_y"),
      by = c("end" = "name")
    ) %>%
    dplyr::mutate(
      x = dplyr::if_else(is.na(.data$start_x), .data$x, as.numeric(.data$start_x)),
      y = dplyr::if_else(is.na(.data$start_y), .data$y, as.numeric(.data$start_y)),
      xend = dplyr::if_else(is.na(.data$end_x), .data$xend, as.numeric(.data$end_x)),
      yend = dplyr::if_else(is.na(.data$end_y), .data$yend, as.numeric(.data$end_y)),
      type = "line"
    ) %>%
    dplyr::select(-dplyr::starts_with("start_"), -dplyr::starts_with("end_"))

  out <- dplyr::full_join(
    boxes,
    dplyr::bind_rows(arrows, lines),
    by = "type"
  )

  # drop rows that are all-NA apart from their type
  out %>%
    dplyr::filter(
      rowSums(is.na(out)) != (ncol(out) - 1)
    )
}
