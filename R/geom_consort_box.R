#' @export

# creates a box with squared edges, with label args
# that get passed to geom_richtext

# note that can take vectors like arrow_in = c("top", "left")

geom_consort_box <- function(
  x, y, label, data = NULL,
  label_color = "black", label_size = "8pt", label_height = 1,
  ...
) {

  ggtext::geom_richtext(
    ggplot2::aes(
      x = .data$box_x, y = .data$box_y, label = .data$label,
      lineheight = .data$label_height,
      vjust = .data$vjust, hjust = .data$hjust, ...
    ),
    data = function(d) dplyr::filter(d, .data$type == "box"),
    label.r = ggplot2::unit(0, units = "npc")
  )
}
