# Extract a cohort data frame

Pull a single tibble from a `ggconsort_cohort` object, often for
downstream analysis or deeper inspection.

## Usage

``` r
cohort_pull(.data, ...)
```

## Arguments

- .data:

  A `ggconsort_cohort` object

- ...:

  The cohort to pull as an unquoted expression

## Value

A tibble for a single cohort

## Examples

``` r
cohorts <- trial_data %>%
  cohort_start("Assessed for eligibility") %>%
    cohort_define(
      consented = .full %>% dplyr::filter(declined != 1),
      consented_chemonaive = consented %>% dplyr::filter(prior_chemo != 1)
    )

cohorts %>% cohort_pull(consented_chemonaive)
#> # A tibble: 1,028 × 5
#>       id declined prior_chemo bone_mets treatment
#>    <int>    <int>       <int>     <int> <chr>    
#>  1 65464        0           0         0 Drug A   
#>  2 48228        0           0         0 Drug B   
#>  3 92586        0           0         0 Drug A   
#>  4 70176        0           0         0 Drug B   
#>  5 89052        0           0         0 Drug A   
#>  6 97333        0           0         0 Drug B   
#>  7 80724        0           0         0 Drug A   
#>  8 65186        0           0         0 Drug B   
#>  9 48837        0           0         0 Drug A   
#> 10 99005        0           0         0 Drug B   
#> # ℹ 1,018 more rows
```
