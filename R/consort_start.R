#' Initialize a ggconsort object for plotting. Used internally.
#' @param .data A \code{ggconsort_cohort} object
#' @keywords Internal

consort_start <- function(.data) {
  if (inherits(.data, "ggconsort")) {
    return(.data)
  }

  assert_cohort(.data)

  .data[['consort']] <- list()
  class(.data) <- c("ggconsort", class(.data))

  .data
}
