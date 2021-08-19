is_cohort <- function(x) {
  inherits(x, "ggconsort_cohort")
}

assert_cohort <- function(x, arg_name = NULL) {
  arg_name <- arg_name %||% rlang::quo_name(rlang::enquo(x))
  if (!is_cohort(x)) {
    stop("`", arg_name, "` must be a ggconsort cohort created with `cohort_start()`.")
  }
}
