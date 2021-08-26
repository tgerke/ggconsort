#' @export

consort_arrow_add <- function(
  .data, start = NA, start_side = NA, end = NA, end_side = NA,
  start_x = NA, start_y = NA, end_x = NA, end_y = NA
) {
  .data <- consort_start(.data)

  .data$consort <- bind_rows(
    .data$consort,
    tibble(
      name = NA, box_x = NA, box_y = NA, label = NA,
      type = "arrow",
      start = start, start_side = start_side, end = end, end_side = end_side,
      start_x = start_x, start_y = start_y, end_x = end_x, end_y = end_y
    )
  )

  .data
}
