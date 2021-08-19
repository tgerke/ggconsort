#' @export

# sets some reasonable size and style defaults for edges

geom_consort_arrow <- function(x, xend, y, yend, ...) {
  geom_segment(
    aes(x = x, xend = xend, y= y, yend = yend),
    size = 0.15, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(2, "mm"), type = "closed")
  )
}
