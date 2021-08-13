modify_list <- function(old, new) {
  for (n in names(new)) {
    old[[n]] <- new[[n]]
  }
  old
}

d_quote <- function(x, collapse = NULL, sep = " ") {
  # backwards compatible dQuote() for R < 3.6
  opts <- options("useFancyQuotes" = 2)
  on.exit(options(opts))
  paste(dQuote(x), sep = sep, collapse = collapse)
}

assert_named <- function(x, arg_name = NULL) {
  arg_name <- arg_name %||% rlang::quo_name(rlang::enquo(x))
  if (is.null(names(x)) || !all(nzchar(names(x)))) {
    stop("All items in `", arg_name, "` must be named.")
  }
}

to_snake_case <- function(x) {
  x <- strsplit(x, "[^[:alnum:]]")
  vapply(x, paste, collapse = "_", character(1))
}
