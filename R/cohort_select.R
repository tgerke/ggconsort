#' @export

cohort_select <- function(.data, ...) {
  cohort <- tidyselect::eval_select(
    rlang::expr(c(".full", ...)),
    rlang::set_names(names(.data$data))
  )

  if (!rlang::has_length(cohort)) {
    return(.data)
  }

  .data$data <- .data$data[cohort]
  labelled_cohorts <- intersect(names(cohort), names(.data$labels))
  .data$labels <- .data$labels[labelled_cohorts]
  .data
}
