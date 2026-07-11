# Subset ggconsort cohort objects

Select a subset of cohorts from a `ggconsort_cohort` object

## Usage

``` r
cohort_select(.data, ...)
```

## Arguments

- .data:

  A `ggconsort_cohort` object

- ...:

  The cohort(s) to pull as an unquoted or `tidyselect` style expression

## Value

A `ggconsort_cohort` object

## Examples

``` r
cohorts <-
  trial_data |>
  cohort_start("Assessed for eligibility") |>
  cohort_define(
    consented = .full |> dplyr::filter(declined != 1),
    treatment_a = consented |> dplyr::filter(treatment == "Drug A"),
    treatment_b = consented |> dplyr::filter(treatment == "Drug B")
  ) |>
  cohort_label(
    consented = "Consented",
    treatment_a = "Allocated to arm A",
    treatment_b = "Allocated to arm B"
  )

cohorts |> cohort_select(consented)
#> A ggconsort cohort of 1200 observations with 1 cohort:
#>   - consented (1141)

cohorts |>
  cohort_select(starts_with("treatment_"))
#> A ggconsort cohort of 1200 observations with 2 cohorts:
#>   - treatment_a (469)
#>   - treatment_b (469)
```
