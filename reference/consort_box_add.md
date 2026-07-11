# Add boxes, arrows, and lines to a CONSORT diagram

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

consort_box_add(.data, name, x, y, label, hjust = NULL, vjust = NULL)

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

  Names of the boxes where the arrow or line starts and ends.

- start_side, end_side:

  The side of the box (`"left"`, `"right"`, `"top"`, or `"bottom"`) that
  the arrow or line leaves from or points to.

- start_x, start_y, end_x, end_y:

  Explicit coordinates for the start and end of the arrow or line, as an
  alternative to naming boxes with `start`/`end`.

- name:

  A character name identifying the box, used to connect arrows and lines
  to the box.

- x, y:

  Coordinates of the box.

- label:

  Text displayed in the box. Interpreted as markdown/HTML by
  [`ggtext::geom_richtext()`](https://wilkelab.org/ggtext/reference/geom_richtext.html),
  so labels may contain formatting such as `<br>` or `**bold**`.
  [`cohort_count_adorn()`](https://tgerke.github.io/ggconsort/reference/cohort_count.md)
  is a convenient way to build labels with cohort counts.

- hjust, vjust:

  Optional numeric justification of the box text relative to (`x`, `y`),
  in `[0, 1]` (e.g. `hjust = 0` is left-aligned, `0.5` is centered, `1`
  is right-aligned). By default, justification is inferred from the side
  on which an arrow enters the box, and is centered otherwise. Supply
  values to override that inference.

## Value

A `ggconsort` object.

## Details

- `consort_box_add()` adds a text box at (`x`, `y`).

- `consort_arrow_add()` adds an arrow between two boxes (referenced by
  `name`) or between explicit coordinates.

- `consort_line_add()` adds a line without an arrow head, with the same
  interface as `consort_arrow_add()`.

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

consort <- cohorts %>%
  consort_box_add("full", 0, 20, cohort_count_adorn(cohorts, .full)) %>%
  consort_box_add("exclusions", 10, 10, cohort_count_adorn(cohorts, excluded)) %>%
  consort_box_add("randomized", 0, 0, cohort_count_adorn(cohorts, randomized)) %>%
  consort_arrow_add(start = "full", start_side = "bottom", end = "randomized", end_side = "top") %>%
  consort_arrow_add(start_x = 0, start_y = 10, end = "exclusions", end_side = "left")

consort
```
