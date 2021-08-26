####
# THIS HEXSTICKER CODE WAS ONLY USED TO GENERATE A TEMPLATE
# THE ULTIMATE STICKER WAS MADE IN FIGMA, AND LOOSELY RESEMBLES
# THE ONE GENERATED FROM THIS SCRIPT
####

library(dplyr)
library(ggplot2)
library(ggtext)

ggplot(data = NULL) +
  geom_segment(
    aes(x = 0, xend = 0, y = 30, yend = 20),
    size = 0.75, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(2, "mm"), type = "closed")
  ) +
  geom_segment(
    aes(x = 0, xend = 15, y = 25, yend = 25),
    size = 0.75, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(2, "mm"), type = "closed")
  ) +
  geom_segment(
    aes(x = 0, xend = 0, y = 20, yend = 15),
    size = 0.75, linejoin = "mitre", lineend = "butt"
  ) +
  geom_segment(
    aes(x = -15, xend = 15, y = 15, yend = 15),
    size = 0.75, linejoin = "mitre", lineend = "butt"
  ) +
  geom_segment(
    aes(x = -15, xend = -15, y = 15, yend = 10),
    size = 0.75, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(2, "mm"), type = "closed")
  ) +
  geom_segment(
    aes(x = 15, xend = 15, y = 15, yend = 10),
    size = 0.75, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(2, "mm"), type = "closed")
  ) +
  geom_segment(
    aes(x = -15, xend = -15, y = 10, yend = 3),
    size = 0.75, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(2, "mm"), type = "closed")
  ) +
  geom_segment(
    aes(x = 15, xend = 15, y = 10, yend = 3),
    size = 0.75, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(2, "mm"), type = "closed")
  ) +
  geom_segment(
    aes(x = -15, xend = -15, y = 3, yend = -4),
    size = 0.75, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(2, "mm"), type = "closed")
  ) +
  geom_segment(
    aes(x = 15, xend = 15, y = 3, yend = -4),
    size = 0.75, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(2, "mm"), type = "closed")
  ) +
  geom_textbox(
    aes(x = 0, y = 30, label = "", vjust = 1),
    fill = "#794e58",
    box.r = unit(0, units = "npc"),
    width = unit(5, "line")
  ) +
  geom_textbox(
    aes(x = 0, y = 20, label = "", vjust = 1),
    fill = "#794e58",
    box.r = unit(0, units = "npc"),
    width = unit(3, "line")
  ) +
  geom_textbox(
    aes(x = 15, y = 25, label = "", hjust = 0),
    fill = "#794e58",
    box.r = unit(0, units = "npc"),
    width = unit(3, "line"),
    height = unit(2, "line")
  ) +
  geom_textbox(
    aes(x = -15, y = 10, label = "", vjust = 1),
    fill = "#794e58",
    box.r = unit(0, units = "npc"),
    width = unit(3.5, "line")
  ) +
  geom_textbox(
    aes(x = 15, y = 10, label = "", vjust = 1),
    fill = "#794e58",
    box.r = unit(0, units = "npc"),
    width = unit(3.5, "line")
  ) +
  geom_textbox(
    aes(x = -15, y = 3, label = "", vjust = 1),
    fill = "#794e58",
    box.r = unit(0, units = "npc"),
    width = unit(3.5, "line")
  ) +
  geom_textbox(
    aes(x = 15, y = 3, label = "", vjust = 1),
    fill = "#794e58",
    box.r = unit(0, units = "npc"),
    width = unit(3.5, "line")
  ) +
  geom_textbox(
    aes(x = -15, y = -4, label = "", vjust = 1),
    fill = "#794e58",
    box.r = unit(0, units = "npc"),
    width = unit(3.5, "line")
  ) +
  geom_textbox(
    aes(x = 15, y = -4, label = "", vjust = 1),
    fill = "#794e58",
    box.r = unit(0, units = "npc"),
    width = unit(3.5, "line")
  ) +
  xlim(-40, 50) +
  ylim(-10, 30) +
  theme_void() -> p

library(hexSticker)
library(showtext)

font_add_google("Noto Sans KR", regular.wt = 500)
showtext_auto()

sticker(
  p,
  package="ggconsort",
  p_x = 1,
  p_y = 1.5,
  p_size=20,
  p_family = "Noto Sans KR",
  p_color = "#4e796f",
  s_x=1.03,
  s_y=.8,
  s_width=1,
  s_height=1,
  h_fill = "#ffffff",
  h_color = "#4e796f",
  dpi = 900
) -> s

ggsave(
    filename= here::here("dev/ggconsort-hex.png"),
    plot = s,
    width = 9,
    height = 9
)

ggsave(
  filename= here::here("dev/ggconsort-hex.svg"),
  plot = s,
  width = 9,
  height = 9
)

