#' @export

# sets some reasonable size and style defaults for edges

geom_consort_arrow <- function(x, xend, y, yend, data = NULL, ...) {
  geom_segment(
    aes(x = x, xend = xend, y= y, yend = yend),
    data = data %>% filter(start != "line"),
    size = 0.15, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(2, "mm"), type = "closed")
  )

  # geom_segment(
  #   aes(x = x, xend = xend, y= y, yend = yend),
  #   data = data %>% filter(start == "line"),
  #   size = 0.15
  # )
}
