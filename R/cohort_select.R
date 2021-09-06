#' Subset ggconsort cohort objects
#'
#' Select a subset of cohorts from a \code{ggconsort_cohort}
#' object
#'
#' @param .data A \code{ggconsort_cohort} object
#'
#' @param ... The cohort(s) to pull as an unquoted or
#'   \code{tidyselect} style expression
#'
#' @return A \code{ggconsort_cohort} object
#'
#' @export
#' @examples
#' cohorts <-
#'   trial_data %>%
#'   cohort_start("Assessed for eligibility") %>%
#'   cohort_define(
#'     consented = .full %>% dplyr::filter(declined != 1),
#'     treatment_a = consented %>% dplyr::filter(treatment == "Drug A"),
#'     treatment_b = consented %>% dplyr::filter(treatment == "Drug B")
#'   ) %>%
#'   cohort_label(
#'     consented = "Consented",
#'     treatment_a = "Allocated to arm A",
#'     treatment_b = "Allocated to arm B"
#'   )
#'
#' cohorts %>% cohort_select(consented)
#'
#' cohorts %>%
#'   cohort_select(starts_with("treatment_"))
#'
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
