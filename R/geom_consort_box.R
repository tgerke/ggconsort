#' @rdname geom_consort
#' @export
geom_consort_box <- function(
  label_color = "black", label_size = 11, label_height = 1,
  ...
) {
  ggtext::geom_richtext(
    ggplot2::aes(
      x = .data$box_x, y = .data$box_y, label = .data$label,
      vjust = .data$vjust, hjust = .data$hjust
    ),
    data = function(d) dplyr::filter(d, .data$type == "box"),
    colour = label_color,
    # geom_richtext sizes are in mm; label_size is in points
    size = label_size / ggplot2::.pt,
    lineheight = label_height,
    label.r = ggplot2::unit(0, units = "npc"),
    ...
  )
}
