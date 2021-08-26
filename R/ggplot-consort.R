#' @export
ggplot.ggconsort_cohort <- function(
  data = NULL, mapping = ggplot2::aes(), ..., environment = parent.frame()
) {
  data %>%
    create_consort_data() %>%
    ggplot2::ggplot(mapping = mapping, environment = environment, ...)
}

#' @export
ggplot.ggconsort <- function(data, ...) {
  data %>%
    create_consort_data() %>%
    ggplot2::ggplot() +
    geom_consort() +
    ggplot2::theme_void()
}

# plot.ggconsort <- function(x, ...) {
#   ggplot(x) + geom_consort_stuff() + theme_void()
# }
#
# print.ggconsort <- plot.ggconsort
