#' @export
ggplot.ggconsort_cohort <- function(data = NULL, ...) {
  stop("make a consort")
}

#' @importFrom ggplot2 ggplot
#' @export
ggplot.ggconsort <-function(
  data = NULL, mapping = ggplot2::aes(),
  margin_h = 0, margin_v = 0, ...,
  environment = parent.frame()
) {
  data %>%
    create_consort_data() %>%
    ggplot2::ggplot() +
    geom_consort() +
    theme_void() +
    coord_cartesian(clip = "off") +
    theme(plot.margin = margin(
      margin_v, margin_h, margin_v, margin_h,
      "line"
    ))
}
