#' @export

consort_box_add <- function(.data, name, x, y, label) {
  .data <- consort_start(.data)

  .data$consort <- bind_rows(
    .data$consort,
    tibble(
      name = name, box_x = x, box_y = y, label = label,
      type = "box",
      start = NA, start_side = NA, end = NA, end_side = NA,
      start_x = NA, start_y = NA, end_x = NA, end_y = NA
    )
  )

  .data
}
