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
    aes(
      x = box_x, y = box_y, label = label,
      lineheight = label_height,
      vjust = vjust, hjust = hjust, ...
    ),
    data = . %>% filter(type == "box"),
    label.r = unit(0, units = "npc")
  )
}
