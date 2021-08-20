#' @export

cohort_pull <- function(.data, ...) {
  cohort <- tidyselect::eval_select(
    rlang::expr(c(...)),
    rlang::set_names(names(.data$data))
  )

  if (rlang::has_length(cohort, n = 1)) {
    return(.data$data[[cohort]])
  }

  .data$data[cohort]
}
