#' @export

# sets some reasonable size and style defaults for edges

geom_consort_arrow <- function(x, xend, y, yend, data = NULL, ...) {
  list(
    ggplot2::geom_segment(
      ggplot2::aes(x = .data$x, xend = .data$xend, y = .data$y, yend = .data$yend),
      data = function(d) dplyr::filter(d, .data$type == "arrow"),
      size = 0.15, linejoin = "mitre", lineend = "butt",
      arrow = ggplot2::arrow(length = ggplot2::unit(2, "mm"), type = "closed")
    ),
    ggplot2::geom_segment(
      ggplot2::aes(x = .data$x, xend = .data$xend, y = .data$y, yend = .data$yend),
      data = function(d) dplyr::filter(d, .data$type == "line"),
      size = 0.15
    )
  )
}
