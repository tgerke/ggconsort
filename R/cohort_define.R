#' Define ggconsort cohorts
#'
#' Following a call to \code{cohort_start}, use \code{cohort_define}
#' to construct cohorts from the full source data which are appended
#' to the \code{ggconsort_cohort} object.
#'
#' @param .data A \code{ggconsort_cohort} object
#' @param ... A series of named expressions which define the cohorts
#'
#' @return The modified \code{ggconsort_cohort} object which now includes
#' additional \code{$data} items according to provided cohort definitions
#' @export
#'
### FIXME: to add @examples
cohort_define <- function(.data, ...) {
  assert_cohort(.data)

  exprs <- rlang::enexprs(...)
  assert_named(exprs, "...")

  for (cohort_name in names(exprs)) {
    cohort <- rlang::eval_tidy(exprs[[cohort_name]], data = .data$data)

    .data$data[[cohort_name]] <- cohort %>% dplyr::ungroup()

    if (dplyr::is.grouped_df(cohort)) {
      # if the cohort is grouped, we add new cohorts for each group level,
      # separated by `.` and prefixed with the `cohort_name`
      groups <-
        cohort %>%
        dplyr::group_keys() %>%
        dplyr::mutate(
          .key = apply(., 1, function(x) paste(to_snake_case(x), collapse = ".")),
          .key = paste0(cohort_name, ".", .key)
        )

      cohort <-
        cohort %>%
        dplyr::left_join(groups, by = head(names(groups), -1)) %>%
        dplyr::group_by(.key) %>%
        dplyr::group_nest()

      for (i in seq_len(nrow(cohort))) {
        .data$data[[cohort$.key[[i]]]] <- cohort$data[[i]]
      }
    }
  }

  .data
}
