#' @export
ggplot.ggconsort_cohort <- function(data = NULL, ...) {
  stop("make a consort")
}

#' @importFrom ggplot2 ggplot
#' @export
ggplot.ggconsort <- function(
  data = NULL,
  mapping = ggplot2::aes(),
  ...,
  environment = parent.frame()
) {
  data %>%
    create_consort_data() %>%
    ggplot2::ggplot() +
    ggplot2::coord_cartesian(clip = "off")
}

#' @export
theme_consort <- function(margin_h = 0, margin_v = 0, margin_unit = "line") {
  ggplot2::theme_void() +
    ggplot2::theme(
      plot.margin = ggplot2::margin(
        margin_v, margin_h, margin_v, margin_h,
        unit = margin_unit
      )
    )
}

#' @export
plot.ggconsort <- function(x, y = NULL, ..., margin_h = 0, margin_v = 0) {
  ggplot(x) +
    geom_consort() +
    theme_consort()
}

#' @export
print.ggconsort <- function(x, ...) {
  print(plot.ggconsort(x, ...))
}
