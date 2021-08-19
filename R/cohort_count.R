#' Count the number of rows in each ggconsort cohort
#'
#' @param .data A \code{ggconsort_cohort} object
#'
#' @return A \code{tibble} with cohort name, row number total, and label
#' @export
#'
### FIXME: to add @examples
cohort_count <- function(.data) {
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

  if (is.null(labels)) {
    return(counts)
  }

  dplyr::left_join(counts, labels, by = "cohort")
}
