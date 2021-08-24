#' @export

# sets some reasonable size and style defaults for edges

geom_consort_arrow <- function(x, xend, y, yend, data = NULL, ...) {
  list(
    geom_segment(
      aes(x = x, xend = xend, y= y, yend = yend),
      data = function(d) filter(d, type == "arrow"),
      size = 0.15, linejoin = "mitre", lineend = "butt",
      arrow = arrow(length = unit(2, "mm"), type = "closed")
    ),
    geom_segment(
      aes(x = x, xend = xend, y= y, yend = yend),
      data = function(d) filter(d, type == "line"),
      size = 0.15
    )
  )
}
