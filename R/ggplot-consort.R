#' @export
ggplot.ggconsort_cohort <- function(data = NULL, ...) {
  stop(
    "This ggconsort cohort has no diagram elements yet. ",
    "Add them with `consort_box_add()` and `consort_arrow_add()` ",
    "before plotting.",
    call. = FALSE
  )
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

#' Minimal theme for CONSORT diagrams
#'
#' A wrapper around [ggplot2::theme_void()] that adds plot margins, so diagram
#' boxes near the edges are not clipped.
#'
#' @param margin_h,margin_v Horizontal and vertical plot margins.
#' @param margin_unit Unit of the margins, passed to [ggplot2::margin()].
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' # see ?geom_consort for a complete diagram example
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   theme_consort(margin_h = 8, margin_v = 1)
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
    theme_consort(margin_h = margin_h, margin_v = margin_v)
}

#' @export
print.ggconsort <- function(x, ...) {
  print(plot.ggconsort(x, ...))
}

# makes ggsave() work on a ggconsort object directly (#26)
#' @exportS3Method grid::grid.draw
grid.draw.ggconsort <- function(x, recording = TRUE) {
  grid::grid.draw(plot.ggconsort(x), recording = recording)
}
