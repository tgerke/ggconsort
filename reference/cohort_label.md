# Add labels to ggconsort cohorts

Add labels to ggconsort cohorts

## Usage

``` r
cohort_label(.data, ...)
```

## Arguments

- .data:

  A `ggconsort_cohort` object

- ...:

  A series of named expressions which provide labels corresponding to
  named cohorts in the `ggconsort_cohort` object

## Value

The modified `ggconsort_cohort` object which now includes additional
`$labels` items according to provided label definitions

## Examples

``` r
# labels feed cohort_count_adorn() and the automatic box labels of
# consort_box_add()
trial_data |>
  cohort_start("Assessed for eligibility") |>
  cohort_define(
    consented = .full |> dplyr::filter(declined != 1)
  ) |>
  cohort_label(consented = "Consented")
#> A ggconsort cohort of 1200 observations with 1 cohort:
#>   - consented (1141)
```
