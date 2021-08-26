
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggconsort

<!-- badges: start -->
<!-- badges: end -->

## Overview

The goal of ggconsort is to provide convenience functions for creating
[CONSORT
diagrams](http://www.consort-statement.org/consort-statement/flow-diagram)
with ggplot2. ggconsort segments CONSORT creation into two stages: (1)
CONSORT annotation capture at the time of data wrangling, and (2)
diagram layout. With the introduction of a `ggconsort_cohort` class,
stage (1) can be accomplished within dplyr chains. Specifically, the
following functions are implemented inside a dplyr chain to define a
`ggconsort_cohort`:

-   `cohort_start()` initializes a `ggconsort_cohort` object which
    contains a labeled copy of the source data
-   `cohort_define()` constructs cohorts that are variations of the
    source data or other cohorts
-   `cohort_label()` adds labels to each named cohort within the
    `ggconsort_cohort` object

Diagram layout in stage 2 is streamlined by ggconsort geoms:

-   `geom_consort()` plots a CONSORT diagram from a data frame
    constructed with `create_consort_data()`
-   Internally, `geom_consort()` is a wrapper for 3 geoms which form the
    basis for CONSORT plotting; these may be used for finer control:
    `geom_consort_box()`, `geom_consort_arrow`, and
    `geom_consort_line()`

## Installation

You can install the released version of ggconsort from
[GitHub](https://github.com/tgerke/ggconsort) with:

``` r
# install.packages("devtools")
devtools::install_github("tgerke/ggconsort")
```

## Usage

Suppose that we would like to study male penguins on Biscoe island from
the `palmerpenguins::penguins` dataset. Specifically, we want to compare
features in male Biscoe penguins who have body mass &gt; 4000g to those
with body mass ≤ 4000g. To arrive at our analytic data, we need to
perform filtering operations, and we would like to represent that
process in a CONSORT diagram.

We first define the `ggconsort_cohort` object (`penguin_cohorts`) in the
following dplyr chain.

``` r
library(dplyr)
library(ggplot2)
library(ggconsort)
library(palmerpenguins)

penguin_cohorts <- 
  penguins %>%
  mutate(.id = row_number()) %>% # a unique ID for joins
  cohort_start("Penguins observerd by Palmer Station LTER") %>%
  # Define cohorts using named expressions --------------------
  # Notice that you can use previously defined cohorts in subsequent steps
  cohort_define(
    adelie = .full %>% filter(species == "Adelie"),
    adelie_male = adelie %>% filter(sex == "male"),
    biscoe_adelie_male = adelie_male %>% filter(island == "Biscoe"),
    high_bm = biscoe_adelie_male %>% filter(body_mass_g > 4000),
    low_bm = biscoe_adelie_male %>% filter(body_mass_g <= 4000),
    # anti_join is useful for counting exclusions
    excluded = anti_join(.full, biscoe_adelie_male, by = ".id"),
    excluded_not_adelie = anti_join(.full, adelie, by = ".id"),
    excluded_not_adelie_male = anti_join(adelie, adelie_male, by = ".id"),
    excluded_not_adelie_male_biscoe = anti_join(
      adelie_male, biscoe_adelie_male, by = ".id"
    )
  ) %>%
  # Provide text labels for cohorts ---------------------------
  cohort_label(
    adelie = "Adelie penguins",
    adelie_male = "Adelie male penguins",
    biscoe_adelie_male = "Male Adelie penguins on Biscoe island",
    high_bm = "Body mass > 4000g",
    low_bm = "Body mass ≤ 4000g",
    excluded = "Excluded",
    excluded_not_adelie = "Not Adelie",
    excluded_not_adelie_male = "Not male",
    excluded_not_adelie_male_biscoe = "Not on Biscoe island"
  )
```

Next, we define data frames for the CONSORT “boxes” and “arrows”,
combine these data frames with `create_consort_data`, and plot with
`geom_consort`.

``` r
penguin_consort <- penguin_cohorts %>%
  consort_box_add(
    "full", 0, 50, cohort_count_adorn(penguin_cohorts, .full)
  ) %>%
  consort_box_add(
    "exclusions", 20, 40, glue::glue(
      '{cohort_count_adorn(penguin_cohorts, excluded)}<br>
      • {cohort_count_adorn(penguin_cohorts, excluded_not_adelie)}<br>
      • {cohort_count_adorn(penguin_cohorts, excluded_not_adelie_male)}<br>
      • {cohort_count_adorn(penguin_cohorts, excluded_not_adelie_male_biscoe)}
      ')
  ) %>%
  consort_box_add(
    "final", 0, 30, cohort_count_adorn(penguin_cohorts, biscoe_adelie_male)
  ) %>%
  consort_box_add(
    "high_bm", -30, 10, cohort_count_adorn(penguin_cohorts, high_bm)
  ) %>%
  consort_box_add(
    "low_bm", 30, 10, cohort_count_adorn(penguin_cohorts, low_bm)
  ) %>%
  consort_arrow_add(
    "full", "bottom", "exclusions", "left", 0, 40
  ) %>%
  consort_arrow_add(
    "full", "bottom", "final", "top"
  ) %>% 
  consort_arrow_add(
    start_x = 0, start_y = 30, end_x = 0, end_y = 20,
  ) %>%
  consort_line_add(
    start_x = -30, start_y = 20, end_x = 30, end_y = 20,
  ) %>% 
  consort_arrow_add(
    end = "high_bm", end_side = "top", start_x = -30, start_y = 20
  ) %>%
  consort_arrow_add(
    end = "low_bm", end_side = "top", start_x = 30, start_y = 20
  )

create_consort_data(penguin_consort) %>%
  ggplot() + 
  geom_consort() + 
  xlim(-50, 65) + 
  ylim(5, 60) + 
  theme_void()
```

<img src="man/figures/README-example-consort-1.png" width="100%" />

At this point, we are ready for analysis. The following retrieves the
desired data frame:

``` r
penguin_cohorts %>%
  cohort_pull(biscoe_adelie_male)
#> # A tibble: 22 x 9
#>    species island bill_length_mm bill_depth_mm flipper_length_mm body_mass_g
#>    <fct>   <fct>           <dbl>         <dbl>             <int>       <int>
#>  1 Adelie  Biscoe           37.7          18.7               180        3600
#>  2 Adelie  Biscoe           38.2          18.1               185        3950
#>  3 Adelie  Biscoe           38.8          17.2               180        3800
#>  4 Adelie  Biscoe           40.6          18.6               183        3550
#>  5 Adelie  Biscoe           40.5          18.9               180        3950
#>  6 Adelie  Biscoe           40.1          18.9               188        4300
#>  7 Adelie  Biscoe           42            19.5               200        4050
#>  8 Adelie  Biscoe           41.4          18.6               191        3700
#>  9 Adelie  Biscoe           40.6          18.8               193        3800
#> 10 Adelie  Biscoe           37.6          19.1               194        3750
#> # … with 12 more rows, and 3 more variables: sex <fct>, year <int>, .id <int>
```
