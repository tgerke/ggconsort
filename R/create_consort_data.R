#' @export

# combines tibbles like consort_boxes and consort_arrows into a
# usable form for ggconsort geoms
# consort_boxes and consort_arrows are expected to have certain formats
# FIXME: to describe and check for those formats

create_consort_data <- function(.data, ...) {
  # FIXME: account for 2+ arrows coming in by summarizing those rows
  # FIXME: need to assert that we've got a cohort with consort data

  consort_boxes <- .data$consort %>%
    dplyr::filter(type == "box") %>%
    dplyr::select(name, box_x, box_y, label)

  consort_arrows <- .data$consort %>%
    dplyr::filter(type %in% c("arrow", "line")) %>%
    dplyr::select(
      start, start_side, end, end_side,
      start_x, start_y, end_x, end_y
    )

  boxes <- dplyr::left_join(
    consort_boxes,
    consort_arrows %>% dplyr::select(end, end_side),
    by = c("name" = "end")
  ) %>%
    dplyr::mutate(
      vjust = dplyr::if_else(
        end_side == "top", 1, .5, missing = .5
      ),
      hjust = dplyr::case_when(
        end_side == "left" ~ 0,
        end_side == "right" ~ 1,
        TRUE ~ .5
      ),
      type = "box"
    ) %>%
    dplyr::rename(
      arrow_in = end_side
    )

  arrows <- dplyr::left_join(
    consort_arrows,
    consort_boxes %>% dplyr::select(-label),
    by = c("start" = "name")
  ) %>%
    dplyr::left_join(
      consort_boxes %>%
        dplyr::select(-label) %>%
        dplyr::rename(xend = x, yend = y),
      by = c("end" = "name")
    ) %>%
    dplyr::mutate(
      x = dplyr::if_else(is.na(start_x), x, as.numeric(start_x)),
      y = dplyr::if_else(is.na(start_y), y, as.numeric(start_y)),
      xend = dplyr::if_else(is.na(end_x), xend, as.numeric(end_x)),
      yend = dplyr::if_else(is.na(end_y), yend, as.numeric(end_y)),
      type = dplyr::if_else(start == "line", "line", "arrow")
    ) %>%
    dplyr::select(-dplyr::starts_with("start_"), -dplyr::starts_with("end_"))

  dplyr::full_join(boxes, arrows, by = "type")
}
