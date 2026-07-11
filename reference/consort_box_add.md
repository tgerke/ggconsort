# Add boxes, arrows, lines, and stage badges to a CONSORT diagram

These functions add the visual elements of a CONSORT diagram to a
`ggconsort_cohort` object, converting it to a `ggconsort` object that
can be plotted with
[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)
and
[`geom_consort()`](https://tgerke.github.io/ggconsort/reference/geom_consort.md).

## Usage

``` r
consort_arrow_add(
  .data,
  start = NA,
  start_side = NA,
  end = NA,
  end_side = NA,
  start_x = NA,
  start_y = NA,
  end_x = NA,
  end_y = NA
)

consort_box_add(
  .data,
  name,
  x = NULL,
  y = NULL,
  label,
  hjust = NULL,
  vjust = NULL,
  row = NULL,
  col = NULL
)

consort_stage_add(.data, label, row, col = "left", fill = "#9bc0fc", angle = 0)

consort_line_add(
  .data,
  start = NA,
  start_side = NA,
  end = NA,
  end_side = NA,
  start_x = NA,
  start_y = NA,
  end_x = NA,
  end_y = NA
)
```

## Arguments

- .data:

  A `ggconsort_cohort` object, or a `ggconsort` object returned by a
  previous `consort_*_add()` call.

- start, end:

  Names of the boxes where the arrow or line starts and ends. In a
  row/column layout, `end` may be a vector of names to draw a T-split
  from `start` into several boxes.

- start_side, end_side:

  The side of the box (`"left"`, `"right"`, `"top"`, or `"bottom"`) that
  the arrow or line leaves from or points to. Optional: by default the
  sides follow from the relative positions of the two boxes.

- start_x, start_y, end_x, end_y:

  Explicit coordinates for the start and end of the arrow or line, as an
  alternative to naming boxes with `start`/`end`. Not available in
  row/column layouts.

- name:

  A character name identifying the box, used to connect arrows and lines
  to the box.

- x, y:

  Coordinates of the box. Omit them (and set `row`/`col`) to use the
  row/column layout instead.

- label:

  Text displayed in the box. Interpreted as markdown/HTML by
  ggtext/gridtext, so labels may contain formatting such as `<br>` or
  `**bold**`.
  [`cohort_count_adorn()`](https://tgerke.github.io/ggconsort/reference/cohort_count.md)
  is a convenient way to build labels with cohort counts.

- hjust, vjust:

  Optional numeric justification of the box relative to (`x`, `y`), in
  `[0, 1]`. By default boxes are centered on their coordinates
  (`hjust = vjust = 0.5`). E.g. `hjust = 0` places the box's left edge
  at `x`. Ignored in row/column layouts.

- row, col:

  Grid position of the box or stage badge (see the "Row/column layout"
  section). For `consort_stage_add()`, `row` may be a length-2 vector to
  center the badge across a span of rows.

- fill:

  Fill color of the stage badge.

- angle:

  Rotation of the stage badge text, in degrees (e.g. `90` for the
  vertical labels of a PRISMA diagram).

## Value

A `ggconsort` object.

## Details

- `consort_box_add()` adds a text box, either at explicit (`x`, `y`)
  coordinates or at a (`row`, `col`) grid position.

- `consort_arrow_add()` adds an arrow between two boxes (referenced by
  `name`) or between explicit coordinates.

- `consort_line_add()` adds a line without an arrow head, with the same
  interface as `consort_arrow_add()`.

- `consort_stage_add()` adds a stage badge (e.g. "Allocation") to a
  row/column layout.

## Row/column layout

Instead of picking coordinates by hand, boxes can declare a grid
position with `row` and `col`. Rows count from 1 at the top. `col` is
`"main"` (the central spine, column 0), `"side"` (column 1, right of the
spine), `"left"` (column -1), or any number. At draw time ggconsort
measures every box on the open graphics device and lays the grid out to
fill the plot: row gaps are equalized, columns are spread so boxes never
overlap, and nothing is clipped, whatever the device size.

In a row/column layout, arrows need only `start` and `end` names:

- boxes in the same column are connected vertically,

- boxes in the same row are connected horizontally,

- a box in another column and row is reached by a horizontal branch off
  the start box's vertical spine, at the height of the target box, and

- a vector `end` (e.g. `end = c("arm_a", "arm_b")`) draws the classic
  T-split: one drop from the start box, a crossbar, and an arrow down
  into each arm.

A diagram must use either coordinates or rows/columns, not a mixture.

## Examples

``` r
cohorts <- trial_data %>%
  cohort_start("Assessed for eligibility") %>%
  cohort_define(
    randomized = .full %>% dplyr::filter(declined != 1),
    excluded = dplyr::anti_join(.full, randomized, by = "id")
  ) %>%
  cohort_label(
    randomized = "Randomized",
    excluded = "Declined to participate"
  )

# row/column layout: no coordinates, spacing computed at draw time
consort <- cohorts %>%
  consort_box_add("full", row = 1, col = "main",
    label = cohort_count_adorn(cohorts, .full)) %>%
  consort_box_add("exclusions", row = 2, col = "side",
    label = cohort_count_adorn(cohorts, excluded)) %>%
  consort_box_add("randomized", row = 3, col = "main",
    label = cohort_count_adorn(cohorts, randomized)) %>%
  consort_arrow_add(start = "full", end = "randomized") %>%
  consort_arrow_add(start = "full", end = "exclusions")

library(ggplot2)
ggplot(consort) +
  geom_consort() +
  theme_consort()
```
