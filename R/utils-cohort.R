is_cohort <- function(x) {
  inherits(x, "ggconsort_cohort")
}

assert_cohort <- function(x, arg_name = NULL) {
  arg_name <- arg_name %||% rlang::quo_name(rlang::enquo(x))
  if (!is_cohort(x)) {
    stop("`", arg_name, "` must be a ggconsort cohort created with `cohort_start()`.")
  }
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
