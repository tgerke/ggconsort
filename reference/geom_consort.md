# CONSORT diagram layers for ggplot2

`geom_consort()` draws the boxes, arrows, and lines of a `ggconsort`
object created with
[`consort_box_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md),
[`consort_arrow_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md),
and
[`consort_line_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md).
It measures the rendered size of each box at draw time, so boxes are
centered on their (`x`, `y`) coordinates and arrows start and end
exactly at box edges, whatever the device size. `geom_consort_arrow()`
and `geom_consort_box()` are the legacy component layers, which anchor
arrows at box centers and shift box text by its justification; they
remain available for diagrams that depend on that behavior.
`geom_consort_line()` draws a standalone line segment with the same
styling as the diagram lines.

## Usage

``` r
geom_consort(
  label_color = "black",
  label_size = 11,
  label_height = 1,
  fill = "white",
  box_color = "black"
)

geom_consort_arrow(...)

geom_consort_box(label_color = "black", label_size = 11, label_height = 1, ...)

geom_consort_line(x, xend, y, yend, ...)
```

## Arguments

- label_color:

  Color of the box label text.

- label_size:

  Size of the box label text, in points.

- label_height:

  Line height of the box label text.

- fill:

  Fill color of the boxes.

- box_color:

  Color of the box borders.

- ...:

  For `geom_consort_box()`, additional arguments passed to
  [`ggtext::geom_richtext()`](https://wilkelab.org/ggtext/reference/geom_richtext.html).
  Ignored by `geom_consort_arrow()`.

- x, xend, y, yend:

  Coordinates of the line segment drawn by `geom_consort_line()`.

## Value

A ggplot2 layer or list of layers that can be added to a plot.

## Examples

``` r
cohorts <- trial_data %>%
  cohort_start("Assessed for eligibility") %>%
  cohort_define(
    randomized = .full %>% dplyr::filter(declined != 1)
  ) %>%
  cohort_label(randomized = "Randomized")

consort <- cohorts %>%
  consort_box_add("full", 0, 10, cohort_count_adorn(cohorts, .full)) %>%
  consort_box_add("randomized", 0, 0, cohort_count_adorn(cohorts, randomized)) %>%
  consort_arrow_add("full", "bottom", "randomized", "top")

library(ggplot2)
ggplot(consort) +
  geom_consort() +
  theme_consort(margin_h = 12, margin_v = 5)
```
