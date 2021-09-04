#' Extract a cohort data frame
#'
#' Pull a single tibble from a \code{ggconsort_cohort} object,
#' often for downstream analysis or deeper inspection.
#'
#' @param .data A \code{ggconsort_cohort} object
#'
#' @param ... The cohort to pull as an unquoted expression
#'
#' @return A tibble for a single cohort
#'
#' @export
#' @examples
#' cohorts <- trial_data %>%
#'   cohort_start("Assessed for eligibility") %>%
#'     cohort_define(
#'       consented = .full %>% dplyr::filter(declined != 1),
#'       consented_chemonaive = consented %>% dplyr::filter(prior_chemo != 1)
#'     )
#'
#' cohorts %>% cohort_pull(consented_chemonaive)

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
