# CONSORT diagram layers for ggplot2

`geom_consort()` draws the boxes, arrows, and lines of a `ggconsort`
object created with
[`consort_box_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md),
[`consort_arrow_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md),
and
[`consort_line_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md).
It is the layer you will typically add to `ggplot(<ggconsort object>)`,
and it combines `geom_consort_arrow()` and `geom_consort_box()`, which
can also be used individually. `geom_consort_line()` draws a standalone
line segment with the same styling as the diagram lines.

## Usage

``` r
geom_consort(...)

geom_consort_arrow(...)

geom_consort_box(label_color = "black", label_size = 11, label_height = 1, ...)

geom_consort_line(x, xend, y, yend, ...)
```

## Arguments

- ...:

  Additional arguments passed to
  [`ggtext::geom_richtext()`](https://wilkelab.org/ggtext/reference/geom_richtext.html)
  by `geom_consort_box()`, e.g. `fill`. Ignored by
  `geom_consort_arrow()`.

- label_color:

  Color of the box label text.

- label_size:

  Size of the box label text, in points.

- label_height:

  Line height of the box label text.

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
  theme_consort()
```
