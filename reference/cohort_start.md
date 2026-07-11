# Initialize a new ggconsort cohort

Creates an object with an optional label which stores the originating
source data for downstream ggconsort cohorts

## Usage

``` r
cohort_start(.data, label = NULL)
```

## Arguments

- .data:

  A data frame or tibble

- label:

  A character string to describe the set of cohorts

## Value

Returns a `ggconsort_cohort` object with `$data` and `$labels` items

## Examples

``` r
trial_data |>
  cohort_start("Assessed for eligibility")
#> A ggconsort cohort of 1200 observations with 0 cohorts.
```
