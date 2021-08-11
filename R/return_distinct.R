#' Return number of unique values mid-dplyr chain
#'
#' This function is designed to be inserted into a dplyr chain
#' when you want to return a count of unique values for a given
#' variable to the global environment without breaking the chain.
#' There are options to append the count to a list in the global
#' environment, or to add a new object to the global environment
#' which contains the count.
#'
#' @param data A data frame or tibble
#' @param x The variable from \code{data} that requires a count of unique
#' values.
#' @param append_to The name of a list in the global environment
#' to which the count will be appended. If a list named \code{append_to}
#' does not exist in the global environment, one is created.
#' @param name_to_append The name of the list item which is appended to
#' \code{append_to}
#' @param global_obj The name of a global object to return the count to.
#' If \code{global_obj} is used, \code{append_to} and \code{name_to_append}
#' are ignored.
#'
#' @return Returns the left-hand side of the pipe to the current
#' dplyr chain, while also returning counts to the global environment
#' @export
#'
#' @examples
#' palmerpenguins::penguins %>%
#'   return_distinct(species, counts, "species_overall") %>%
#'   dplyr::filter(island == "Biscoe") %>%
#'   return_distinct(species, counts, "species_biscoe")
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
      dplyr::summarise(dplyr::n_distinct({{ x }})) %>%
      dplyr::pull() %>%
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
        dplyr::summarise(dplyr::n_distinct({{ x }})) %>%
        dplyr::pull(),
      envir = .GlobalEnv
    )
  }

  data
}
