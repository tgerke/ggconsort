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
  # FIXME: account for 2+ arrows coming in by summarizing those rows
  # FIXME: need to assert that we've got a cohort with consort data

  consort_boxes <- .data$consort %>%
    dplyr::filter(type == "box")
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
    dplyr::filter(type == "arrow") %>%
    dplyr::select(
      start, start_side, end, end_side,
      start_x, start_y, end_x, end_y
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
    dplyr::filter(type == "line") %>%
    dplyr::select(
      start, start_side, end, end_side,
      start_x, start_y, end_x, end_y
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

  boxes <- dplyr::left_join(
    consort_boxes,
    consort_arrows %>% dplyr::select(end, end_side),
    by = c("name" = "end")
  ) %>%
    dplyr::mutate(
      # user-supplied justification wins over arrow-based inference (#24)
      vjust = dplyr::coalesce(
        vjust_user,
        dplyr::if_else(
          end_side == "top", 1, .5, missing = .5
        )
      ),
      hjust = dplyr::coalesce(
        hjust_user,
        dplyr::case_when(
          end_side == "left" ~ 0,
          end_side == "right" ~ 1,
          TRUE ~ .5
        )
      ),
      type = "box"
    ) %>%
    dplyr::select(-"hjust_user", -"vjust_user") %>%
    dplyr::rename(
      arrow_in = end_side
    )

  arrows <- dplyr::left_join(
    consort_arrows,
    box_anchors %>%
      dplyr::rename(x = box_x, y = box_y),
    by = c("start" = "name")
  ) %>%
    dplyr::left_join(
      box_anchors %>%
        dplyr::rename(xend = box_x, yend = box_y),
      by = c("end" = "name")
    ) %>%
    dplyr::mutate(
      x = dplyr::if_else(!is.na(start_x), as.numeric(start_x), x),
      y = dplyr::if_else(!is.na(start_y), as.numeric(start_y), y),
      xend = dplyr::if_else(!is.na(end_x), as.numeric(end_x), xend),
      yend = dplyr::if_else(!is.na(end_y), as.numeric(end_y), yend),
      type = "arrow"
    ) %>%
    dplyr::select(-dplyr::starts_with("start_"), -dplyr::starts_with("end_"))

  lines <- dplyr::left_join(
    consort_lines,
    box_anchors %>%
      dplyr::rename(x = box_x, y = box_y),
    by = c("start" = "name")
  ) %>%
    dplyr::left_join(
      box_anchors %>%
        dplyr::rename(xend = box_x, yend = box_y),
      by = c("end" = "name")
    ) %>%
    dplyr::mutate(
      x = dplyr::if_else(is.na(start_x), x, as.numeric(start_x)),
      y = dplyr::if_else(is.na(start_y), y, as.numeric(start_y)),
      xend = dplyr::if_else(is.na(end_x), xend, as.numeric(end_x)),
      yend = dplyr::if_else(is.na(end_y), yend, as.numeric(end_y)),
      type = "line"
    ) %>%
    dplyr::select(-dplyr::starts_with("start_"), -dplyr::starts_with("end_"))

  dplyr::full_join(
    boxes,
    dplyr::bind_rows(arrows, lines),
    by = "type"
  ) %>%
    dplyr::filter(
      rowSums(is.na(.)) != (ncol(.) - 1)
    )
}
