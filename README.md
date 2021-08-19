
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
    biscoe = .full %>% filter(island == "Biscoe"),
    biscoe_adelie_male = biscoe %>% semi_join(adelie_male, by = ".id")
  ) %>%
  # Provide text labels for cohorts ---------------------------
  cohort_label(
    adelie = "Adelie penguins",
    adelie_male = "Adelie male penguins",
    biscoe = "Penguins on Biscoe island",
    biscoe_adelie_male = "Male Adelie penguins on Biscoe island"
  )
```

``` r
library(ggplot2)

  
ggplot(data = NULL) + 
  geom_consort_arrow(
    x = 0, xend = 0, y = 50, yend = 30 
  ) + 
  geom_consort_arrow(
    x = 0, xend = 20, y = 40, yend = 40
  ) + 
  geom_consort_box(
    x = 0, y = 50, vjust = 0,
    label = glue::glue(
      'All penguins (n = {
      penguin_cohorts %>% 
        summary() %>% 
        filter(cohort == ".full") %>% 
        pull(count)
      })'
    )
  ) + 
  geom_consort_box(
    x = 20, y = 40, hjust = 0,
    label = glue::glue(
      'Excluded (n = {
        summary(penguin_cohorts) %>%
          filter(cohort == ".full") %>% 
          pull(count) - 
        summary(penguin_cohorts) %>% 
          filter(cohort == "biscoe_adelie_male") %>% 
          pull(count)
      })<br>
      • Not male (n = {
        summary(penguin_cohorts) %>% 
          filter(cohort == ".full") %>% 
          pull(count) - 
        summary(penguin_cohorts) %>% 
          filter(cohort == "adelie_male") %>% 
          pull(count)
      })<br>
      • Not on Biscoe island (n = {
        summary(penguin_cohorts) %>% 
          filter(cohort == ".full") %>% 
          pull(count) - 
        summary(penguin_cohorts) %>% 
          filter(cohort == "biscoe") %>% 
          pull(count)
      })
      '###FIXME: the last count is not correct right now
    )
  ) +
  geom_consort_box(
    x = 0, y = 30, vjust = 1,
    label = glue::glue(
      '{
      penguin_cohorts %>% 
        summary() %>% 
        filter(cohort == "biscoe_adelie_male") %>% 
      pull(label)
      } (n = {
      penguin_cohorts %>% 
        summary() %>% 
        filter(cohort == "biscoe_adelie_male") %>% 
      pull(count)
      })'
    ), 
  ) +
  xlim(-50, 75) + 
  ylim(20, 60) + 
  theme_void()
```

<img src="man/figures/README-example-consort-1.png" width="100%" />

``` r
  #theme_linedraw() #a temporary theme while in progress
```
