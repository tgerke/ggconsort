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

#' @export
print.ggconsort_cohort <- function(x, ...) {
  counts <- cohort_count(x)
  count_full <- dplyr::filter(counts, .data$cohort == ".full")$count
  n_cohorts <- nrow(counts) - 1

  desc_obs <- ngettext(
    count_full,
    "A ggconsort cohort of %d observation",
    "A ggconsort cohort of %d observations"
  )
  desc_cohorts <- ngettext(n_cohorts, "with %d cohort", "with %d cohorts")
  description <- sprintf(paste(desc_obs, desc_cohorts), count_full, n_cohorts)
  description <- paste0(description, if (n_cohorts == 0) ".\n" else ":")

  cat(description)
  if (n_cohorts < 1) {
    return()
  }

  for (i in seq_len(min(n_cohorts, 8)) + 1) {
    # first cohort is the ".full" cohort
    cat("\n  - ", counts$cohort[[i]], " (", counts$count[[i]], ")", sep = "")
  }

  if (n_cohorts > 8) {
    cat("\n  ...and", n_cohorts - 8, "more.")
  }

  invisible(x)
}

#' @export
summary.ggconsort_cohort <- function(object, ...) {
  cohort_count(object)
}
