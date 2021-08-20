#' Count the number of rows in each ggconsort cohort
#'
#' @param .data A \code{ggconsort_cohort} object
#' @param cohort An optional string that defines a cohort
#' within `.data` to count
#'
#' @return A \code{tibble} with cohort name, row number total, and label;
#' or, when `cohort` is provided, an integer count for that specific cohort.
#' @export
#'
### FIXME: to add @examples
### FIXME: add option to return distinct counts of a given variable
cohort_count <- function(.data, cohort = NULL) {
  assert_cohort(.data)
  is_cohort_null <- rlang::is_null(cohort)

  labels <- if (length(.data$labels)) {
    list(
      cohort = names(.data$labels),
      label = unname(unlist(.data$labels))
    ) %>%
      dplyr::as_tibble()
  }

  counts <-
    lapply(.data$data, function(x) dplyr::tibble(count = nrow(x))) %>%
    dplyr::bind_rows(.id = "cohort")

  if (is.null(labels) & is_cohort_null) {
    return(counts)
  } else if (!is_cohort_null) {
    counts %>%
      dplyr::filter(cohort == {{ cohort }}) %>%
      dplyr::pull(count) %>%
      return()
  } else {
    dplyr::left_join(counts, labels, by = "cohort") %>%
      return()
  }

}
