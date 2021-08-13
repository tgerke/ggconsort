#' @export
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

#' @export
cohort_label <- function(.data, ...) {
  assert_cohort(.data)

  labels <- list(...)
  assert_named(labels, "...")
  # FIXME: check that all labels are length-1 strings, too

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

#' @export
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

  for (i in seq_len(nrow(counts))[-1]) {
    cat("\n  - ", counts$cohort[[i]], " (", counts$count[[i]], ")", sep = "")
  }

  invisible(x)
}

#' @export
summary.ggconsort_cohort <- function(object, ...) {
  cohort_count(object)
}
