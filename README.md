
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
    high_bmi = biscoe_adelie_male %>% filter(body_mass_g > 4000),
    low_bmi = biscoe_adelie_male %>% filter(body_mass_g <= 4000),
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
    high_bmi = "Body mass > 4000g",
    low_bmi = "Body mass ≤ 4000g",
    excluded = "Excluded",
    excluded_not_adelie = "Not Adelie",
    excluded_not_adelie_male = "Not male",
    excluded_not_adelie_male_biscoe = "Not on Biscoe island"
  )
```

``` r
library(ggplot2)

consort_boxes <- tribble(
  ~name, ~x, ~y, ~label, 
  "full",        0, 50, cohort_count_adorn(penguin_cohorts, .full),
  "exclusions", 20, 40, glue::glue(
      '{cohort_count_adorn(penguin_cohorts, excluded)}<br>
      • {cohort_count_adorn(penguin_cohorts, excluded_not_adelie)}<br>
      • {cohort_count_adorn(penguin_cohorts, excluded_not_adelie_male)}<br>
      • {cohort_count_adorn(penguin_cohorts, excluded_not_adelie_male_biscoe)}
      '), 
  "final",       0, 30, cohort_count_adorn(penguin_cohorts, biscoe_adelie_male),
  "high_bmi",  -30, 10, cohort_count_adorn(penguin_cohorts, high_bmi),
  "low_bmi",    30, 10, cohort_count_adorn(penguin_cohorts, low_bmi)
)

consort_arrows <- tribble(
   ~start, ~start_side, ~end, ~end_side, ~start_x, ~start_y, ~end_x, ~end_y,
   "full",    "bottom", "exclusions",  "left",   0, 40,  NA, NA,
   "full",    "bottom",      "final",   "top",  NA, NA,  NA, NA,
  "arrow",     "arrow",      "arrow", "arrow",   0, 30,   0, 20,
   "line",      "line",       "line",  "line", -30, 20,  30, 20,
  "arrow",     "arrow",   "high_bmi",   "top", -30, 20, -30, NA,
  "arrow",     "arrow",    "low_bmi",   "top",  30, 20,  30, NA
)

consort_data <-  
  create_consort_data(consort_boxes, consort_arrows)

ggplot() + 
  geom_consort_arrow(data = consort_data$arrows) + 
  geom_consort_box(data = consort_data$boxes) + 
  xlim(-50, 65) + 
  ylim(5, 60) + 
  theme_void()
```

<img src="man/figures/README-example-consort-1.png" width="100%" />
