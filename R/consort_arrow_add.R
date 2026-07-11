#' @rdname consort_box_add
#' @export
consort_arrow_add <- function(
  .data, start = NA, start_side = NA, end = NA, end_side = NA,
  start_x = NA, start_y = NA, end_x = NA, end_y = NA
) {
  .data <- consort_start(.data)

  # a vector `end` marks a T-split: one drop from `start`, a crossbar, and
  # an arrow into each end box (row/column layouts only)
  tee_group <- if (length(end) > 1) paste0(start[1], "-tee") else NA

  .data$consort <- dplyr::bind_rows(
    .data$consort,
    dplyr::tibble(
      name = NA, box_x = NA, box_y = NA, label = NA,
      type = "arrow", tee_group = tee_group,
      start = start, start_side = start_side, end = end, end_side = end_side,
      start_x = start_x, start_y = start_y, end_x = end_x, end_y = end_y
    )
  )

  .data
}
