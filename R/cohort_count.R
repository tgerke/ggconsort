#' Count the number of rows in each ggconsort cohort
#'
#' @param .data A \code{ggconsort_cohort} object
#' @param ... Cohorts to include in the output, can be quoted or unquoted
#'   cohort names, or \pkg{tidyselect} helpers such as
#'   [tidyselect::starts_with()].
#'
#' @return A \code{tibble} with cohort name, row number total, and label.
#'
#' @describeIn cohort_count Returns a tibble with cohort name, row number total
#'   and label.
#' @export
#'
### FIXME: to add @examples
### FIXME: add option to return distinct counts of a given variable
cohort_count <- function(.data, ...) {
  assert_cohort(.data)

  cohort <- tidyselect::eval_select(
    rlang::expr(c(...)),
    rlang::set_names(names(.data$data))
  )

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

  if (rlang::has_length(cohort)) {
    counts <- counts %>%
      dplyr::slice(!!cohort)
  }

  if (is.null(labels)) {
    return(counts)
  }

  dplyr::left_join(counts, labels, by = "cohort")
}

#' @describeIn cohort_count Returns a named vector with cohort counts.
#' @export
cohort_count_int <- function(.data, ...) {
  counts <- cohort_count(.data, ...)

  rlang::set_names(counts$count, counts$cohort)
}

#' @describeIn label_fn Returns a cohort count in "{label} (n = {count})" format
label_fn <- function(.data, ...) {
  counts <- cohort_count(.data, ...)

  purrr::map2_chr(
    .x = counts$label, .y = counts$count,
    ~ glue::glue('{.x} (n = {.y})')
  )
}

#' @describeIn cohort_count_adorn Returns a cohort count in "(n = )" format
#' @export
cohort_count_adorn <- function(.data, ..., .label_fn = label_fn) {
  label_fn(.data, ...)
}
