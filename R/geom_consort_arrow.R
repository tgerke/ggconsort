#' @rdname geom_consort
#' @export
geom_consort_arrow <- function(...) {
  list(
    ggplot2::geom_segment(
      ggplot2::aes(x = .data$x, xend = .data$xend, y = .data$y, yend = .data$yend),
      data = function(d) dplyr::filter(d, .data$type == "arrow"),
      linewidth = 0.15, linejoin = "mitre", lineend = "butt",
      arrow = ggplot2::arrow(length = ggplot2::unit(2, "mm"), type = "closed")
    ),
    ggplot2::geom_segment(
      ggplot2::aes(x = .data$x, xend = .data$xend, y = .data$y, yend = .data$yend),
      data = function(d) dplyr::filter(d, .data$type == "line"),
      linewidth = 0.15
    )
  )
}
