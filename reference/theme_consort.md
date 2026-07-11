# Minimal theme for CONSORT diagrams

A wrapper around
[`ggplot2::theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
that adds plot margins. Margins give diagrams with explicit `x`/`y`
coordinates breathing room so boxes near the edges are not clipped;
row/column layouts size themselves to the device and rarely need them.

## Usage

``` r
theme_consort(margin_h = 0, margin_v = 0, margin_unit = "line")
```

## Arguments

- margin_h, margin_v:

  Horizontal and vertical plot margins.

- margin_unit:

  Unit of the margins, passed to
  [`ggplot2::margin()`](https://ggplot2.tidyverse.org/reference/element.html).

## Value

A ggplot2 theme object.

## Examples

``` r
cohorts <- trial_data |>
  cohort_start("Assessed for eligibility") |>
  cohort_define(
    randomized = .full |> dplyr::filter(declined != 1)
  ) |>
  cohort_label(randomized = "Randomized")

consort <- cohorts |>
  consort_box_add("full", row = 1, label = cohort_count_adorn(cohorts, .full)) |>
  consort_box_add("randomized", row = 2, label = cohort_count_adorn(cohorts, randomized)) |>
  consort_arrow_add(start = "full", end = "randomized")

library(ggplot2)
ggplot(consort) +
  geom_consort() +
  theme_consort()
```
