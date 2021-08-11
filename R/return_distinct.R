return_distinct <- function(
  data, x, append_to = NULL, name_to_append = NULL, global_obj = NULL
) {
  # forces the computation of data, which is necessary in pipe chains
  force(data)

  append_flag <- !rlang::quo_is_null(rlang::enquo(append_to))
  append_name_flag <- !rlang::is_null(name_to_append)
  # need to check that both append and global are not NULL

  if (append_flag) {
    obj_name <- rlang::as_name(rlang::enquo(append_to))

    # initialize the list if it doesn't yet exist
    if (!exists(obj_name, envir = .GlobalEnv)) {
      assign(obj_name, list(), envir = .GlobalEnv)
    }

    out <- data %>%
      summarise(n_distinct({{ x }})) %>%
      pull %>%
      append(append_to, .)

    if (!append_name_flag) {
      name_to_append <- rlang::as_name(rlang::enquo(x))
    }
    out <- out %>%
      rlang::set_names(c(names(.) %>% head(-1), name_to_append))

    assign(obj_name, out, envir = .GlobalEnv)

  } else {
    obj_name <- rlang::as_name(rlang::enquo(global_obj))

    assign(
      obj_name,
      data %>%
        summarise(n_distinct({{ x }})) %>%
        pull,
      envir = .GlobalEnv
    )
  }

  data
}
