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
#'
#' @export
cohort_count_int <- function(.data, ...) {
  counts <- cohort_count(.data, ...)

  rlang::set_names(counts$count, counts$cohort)
}

default_label_count <- function(...) {
  glue::glue("{label} (n = {count})", ..., .envir = parent.frame())
}

#' @describeIn cohort_count Returns a cohort count in "(n = )" or
#'   other custom format
#'
#' @param .label_fn An optional custom function for formatting cohort counts
#'
#' @export
#' @examples
#' cohorts <- trial_data %>%
#'   cohort_start("Assessed for eligibility") %>%
#'     cohort_define(
#'       consented = .full %>% dplyr::filter(declined != 1),
#'       consented_chemonaive = consented %>% dplyr::filter(prior_chemo != 1)
#'     ) %>%
#'     cohort_label(
#'       consented = "Consented",
#'       consented_chemonaive = "Chemotherapy naive"
#'     )
#'
#' cohorts %>%
#'   cohort_count()
#'
#' cohorts %>%
#'   cohort_count_adorn()
#'
#' cohorts %>%
#'   cohort_count_adorn(
#'     starts_with("consented"),
#'     .label_fn = function(cohort, label, count, ...) {
#'       glue::glue("{count} {label} ({cohort})")
#'     }
#'   )
cohort_count_adorn <- function(.data, ..., .label_fn = NULL) {
  counts <- cohort_count(.data, ...)
  counts$label <- counts$label %||% ""
  # reorder so that `.x` is label and `.y` is count
  counts <- counts %>%
    dplyr::select(.data$label, .data$count, dplyr::everything())

  .label_fn <- .label_fn %||% default_label_count
  purrr::pmap_chr(counts, .label_fn)
}
