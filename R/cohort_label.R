#' Add labels to ggconsort cohorts
#'
#' @param .data A \code{ggconsort_cohort} object
#' @param ... A series of named expressions which provide labels
#' corresponding to named cohorts in the \code{ggconsort_cohort} object
#'
#' @return The modified \code{ggconsort_cohort} object which now includes
#' additional \code{$labels} items according to provided label definitions
#' @export
#'
#' @examples
#' # labels feed cohort_count_adorn() and the automatic box labels of
#' # consort_box_add()
#' trial_data |>
#'   cohort_start("Assessed for eligibility") |>
#'   cohort_define(
#'     consented = .full |> dplyr::filter(declined != 1)
#'   ) |>
#'   cohort_label(consented = "Consented")
cohort_label <- function(.data, ...) {
  assert_cohort(.data)

  labels <- list(...)
  assert_named(labels, "...")

  # check that all labels are length-1 strings
  bad <- !vapply(
    labels,
    function(x) is.character(x) && length(x) == 1 && !is.na(x),
    logical(1)
  )
  if (any(bad)) {
    msg <- sprintf(
      "%s must be a single string, not NA: %s",
      ngettext(sum(bad), "Label", "Labels"),
      d_quote(names(labels)[bad], collapse = ", ")
    )
    stop(msg)
  }

  # check that label names match cohort names
  unexpected <- setdiff(names(labels), names(.data$data))
  if (length(unexpected)) {
    msg <- sprintf(
      "Unknown cohort %s: %s",
      ngettext(length(unexpected), "name", "names"),
      d_quote(unexpected, collapse = ", ")
    )
    stop(msg)
  }

  .data$labels <- modify_list(.data$labels, labels)

  .data
}
