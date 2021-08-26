#' @export

consort_start <- function(.data) {
  if (inherits(.data, "ggconsort")) {
    return(.data)
  }

  assert_cohort(.data)

  .data[['consort']] <- list()
  class(.data) <- c("ggconsort", class(.data))

  .data
}
