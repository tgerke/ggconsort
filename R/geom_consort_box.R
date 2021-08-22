#' @export

# creates a box with squared edges, with label args
# that get passed to geom_richtext

# note that can take vectors like arrow_in = c("top", "left")

geom_consort_box <- function(
  x, y, label, arrow_in = "none", data = NULL,
  label_color = "black", label_size = "8pt", label_height = 1,
  ...
) {

  data <- data %>%
    mutate(
      vjust = if_else(
        arrow_in == "top", 1, .5
      ),
      hjust = case_when(
        arrow_in == "left" ~ 0,
        arrow_in == "right" ~ 1,
        TRUE ~ .5
      )
    )
  # if ("top" %in% arrow_in) {
  #   vjust = 1
  # } else {
  #   vjust = .5
  # }
  #
  # if ("left" %in% arrow_in) {
  #   hjust = 0
  # } else if ("right" %in% arrow_in) {
  #   hjust = 1
  # } else {
  #   hjust = .5
  # }
  #
  # label <- glue::glue(
  #   '<span style="color:{label_color}; font-size:{label_size};">
  #   {label}
  #   </span>'
  # )

  ggtext::geom_richtext(
    aes(
      x = x, y = y, label = label,
      lineheight = label_height,
      vjust = vjust, hjust = hjust, ...
    ),
    data = data,
    label.r = unit(0, units = "npc")
  )
}
