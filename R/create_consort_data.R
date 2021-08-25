#' @export

# combines tibbles like consort_boxes and consort_arrows into a
# usable form for ggconsort geoms
# consort_boxes and consort_arrows are expected to have certain formats
# FIXME: to describe and check for those formats

create_consort_data <- function(consort_boxes, consort_arrows) {
  # first, find out what arrows a box receives for hjust and vjust settings
  # FIXME: account for 2+ arrows coming in by summarizing those rows
  boxes <- dplyr::left_join(
    consort_boxes,
    consort_arrows %>% dplyr::select(.data$end, .data$end_side),
    by = c("name" = "end")
  ) %>%
    dplyr::mutate(
      vjust = dplyr::if_else(
        .data$end_side == "top", 1, .5, missing = .5
      ),
      hjust = dplyr::case_when(
        .data$end_side == "left" ~ 0,
        .data$end_side == "right" ~ 1,
        TRUE ~ .5
      ),
      type = "box"
    ) %>%
    dplyr::rename(
      arrow_in = .data$end_side,
      box_x = .data$x,
      box_y = .data$y
    )

  arrows <- dplyr::left_join(
    consort_arrows,
    consort_boxes %>% dplyr::select(-.data$label),
    by = c("start" = "name")
  ) %>%
    dplyr::left_join(
      consort_boxes %>%
        dplyr::select(-.data$label) %>%
        dplyr::rename(xend = .data$x, yend = .data$y),
      by = c("end" = "name")
    ) %>%
    dplyr::mutate(
      x = dplyr::if_else(is.na(.data$start_x), .data$x, as.numeric(.data$start_x)),
      y = dplyr::if_else(is.na(.data$start_y), .data$y, as.numeric(.data$start_y)),
      xend = dplyr::if_else(is.na(.data$end_x), .data$xend, as.numeric(.data$end_x)),
      yend = dplyr::if_else(is.na(.data$end_y), .data$yend, as.numeric(.data$end_y)),
      type = dplyr::if_else(.data$start == "line", "line", "arrow")
    ) %>%
    dplyr::select(-dplyr::starts_with("start_"), -dplyr::starts_with("end_"))

  dplyr::full_join(boxes, arrows, by = "type")
}
