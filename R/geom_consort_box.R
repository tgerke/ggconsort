#' @export

# creates a box with squared edges, with label args
# that get passed to geom_richtext

# FIXME: hjust and vjust need to be adjusted according to whether
# arrows will be coming in from the left/right or center. This
# should be changed to more intuitive arguments like
# arrow_in = "top", arrow_in = c("top", "left") etc

geom_consort_box <- function(
  x, y, label, label_color = "black",
  label_size = "8pt", label_height = 1, ...
) {
  label <- glue::glue(
    '<span style="color:{label_color}; font-size:{label_size};">
    {label}
    </span>'
  )
  ggtext::geom_richtext(
    aes(x = x, y = y, label = label, lineheight = label_height, ...),
    label.r = unit(0, units = "npc")
  )
}
