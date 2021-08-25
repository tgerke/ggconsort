#' @export

# Sometimes lines without arrows are required, and
# this function allows us to keep styling consistent

geom_consort_line <- function(x, xend, y, yend, ...) {
  ggplot2::geom_segment(
    ggplot2::aes(x = x, xend = xend, y= y, yend = yend),
    size = 0.15, linejoin = "mitre", lineend = "butt"
  )
}
