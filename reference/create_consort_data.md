# Build the plotting data for a ggconsort diagram

Combines the boxes, arrows, and lines of a `ggconsort` object into a
single tibble in the format expected by the
[`geom_consort()`](https://tgerke.github.io/ggconsort/reference/geom_consort.md)
geoms. Called internally by `ggplot.ggconsort()`; you should rarely need
to call it directly.

## Usage

``` r
create_consort_data(.data, ...)
```

## Arguments

- .data:

  A `ggconsort` object built with
  [`consort_box_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md)
  and friends.

- ...:

  Unused; reserved for future use.

## Value

A tibble with one row per box, arrow, and line.
