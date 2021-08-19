#' Initialize a new ggconsort cohort
#'
#' Creates an object with an optional label which stores
#' the originating source data for downstream ggconsort cohorts
#'
#' @param .data A data frame or tibble
#' @param label A character string to describe the set of cohorts
#'
#' @return Returns a \code{ggconsort_cohort} object with
#' \code{$data} and \code{$labels} items
#' @export
#'
### FIXME: to add @examples
cohort_start <- function(.data, label = NULL) {
  stopifnot(is.data.frame(.data))
  x <- structure(
    list(
      data = list(.full = .data),
      labels = if (!is.null(label)) list(.full = label) else list()
    ),
    class = "ggconsort_cohort"
  )
  x
}
