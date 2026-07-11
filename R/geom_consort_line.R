#' @rdname geom_consort
#' @param x,xend,y,yend Coordinates of the line segment drawn by
#'   `geom_consort_line()`.
#' @export
geom_consort_line <- function(x, xend, y, yend, ...) {
  ggplot2::geom_segment(
    ggplot2::aes(x = x, xend = xend, y = y, yend = yend),
    linewidth = 0.15, linejoin = "mitre", lineend = "butt"
  )
}
