
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggconsort

<!-- badges: start -->
<!-- badges: end -->

The goal of ggconsort is to provide convenience functions for creating
CONSORT diagrams with `ggplot2`.

## Installation

You can install the released version of ggconsort from
[GitHub](https://github.com/tgerke/ggconsort) with:

``` r
devtools::install_github("tgerke/ggconsort")
```

## Example

**This paragraph needs to be modified**

In the following, we filter the `penguins` data to only those from
Biscoe island. In the same `dplyr` chain, we collect the number of
distinct species overall (i.e. before the filter to Biscoe) and the
number of distinct species on Biscoe into a list called `counts`. In the
next step, we will use `counts` to construct a basic data flow diagram.

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(ggconsort)
library(palmerpenguins)

penguin_cohorts <- 
  penguins %>%
  mutate(.id = row_number()) %>%
  cohort_start("Penguins observerd by Palmer Station LTER") %>%
  # Define cohorts using named expressions --------------------
  # Notice that you can use previously defined cohorts in subsequent steps
  cohort_define(
    adelie = .full %>% filter(species == "Adelie"),
    adelie_male = adelie %>% filter(sex == "male"),
    biscoe_adelie_male = adelie_male %>% filter(island == "Biscoe"),
    # for counting exclusions
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
    excluded = "Excluded",
    excluded_not_adelie = "Not Adelie",
    excluded_not_adelie_male = "Not male",
    excluded_not_adelie_male_biscoe = "Not on Biscoe island"
  )
```

``` r
library(ggplot2)

# arrow_in describes which side(s) of the box receive arrows
consort_boxes <- tribble(
  ~name, ~x, ~y, ~label, 
  "full", 0, 50, cohort_count_adorn(penguin_cohorts, .full),
  "exclusions", 20, 40, glue::glue(
      '{cohort_count_adorn(penguin_cohorts, excluded)}<br>
      • {cohort_count_adorn(penguin_cohorts, excluded_not_adelie)}<br>
      • {cohort_count_adorn(penguin_cohorts, excluded_not_adelie_male)}<br>
      • {cohort_count_adorn(penguin_cohorts, excluded_not_adelie_male_biscoe)}
      '), 
  "final", 0, 30, cohort_count_adorn(penguin_cohorts, biscoe_adelie_male),
)

consort_arrows <- tribble(
   ~start, ~start_side,         ~end, ~end_side,
    "full",   "bottom", "exclusions",    "left",
    "full",   "bottom",      "final",     "top"
)

consort_data <-  
  create_consort_data(consort_boxes, consort_arrows)

ggplot() + 
  geom_consort_arrow(data = consort_data$arrows) + 
  geom_consort_box(data = consort_data$boxes) + 
  xlim(-50, 75) + 
  ylim(20, 60) + 
  theme_void()
```

<img src="man/figures/README-example-consort-1.png" width="100%" />

``` r
# needed consort_arrows to look like this
# consort_arrows <- tribble(
#   ~x, ~xend, ~y, ~yend,
#   0, 0, 50, 30,
#   0, 20, 40, 40
# )
```
