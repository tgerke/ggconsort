# Define ggconsort cohorts

Following a call to `cohort_start`, use `cohort_define` to construct
cohorts from the full source data which are appended to the
`ggconsort_cohort` object.

## Usage

``` r
cohort_define(.data, ...)
```

## Arguments

- .data:

  A `ggconsort_cohort` object

- ...:

  A series of named expressions which define the cohorts

## Value

The modified `ggconsort_cohort` object which now includes additional
`$data` items according to provided cohort definitions

## Examples

``` r
# cohorts draw on `.full` (the source data) or any earlier cohort;
# dplyr::anti_join() is a convenient way to count exclusions
trial_data |>
  cohort_start("Assessed for eligibility") |>
  cohort_define(
    consented = .full |> dplyr::filter(declined != 1),
    excluded = dplyr::anti_join(.full, consented, by = "id")
  )
#> A ggconsort cohort of 1200 observations with 2 cohorts:
#>   - consented (1141)
#>   - excluded (59)
```
