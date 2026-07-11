# Count the number of rows in each ggconsort cohort

Count the number of rows in each ggconsort cohort

## Usage

``` r
cohort_count(.data, ...)

cohort_count_int(.data, ...)

cohort_count_adorn(.data, ..., .label_fn = NULL)

cohort_count_bullets(.data, ..., .label_fn = NULL)
```

## Arguments

- .data:

  A `ggconsort_cohort` object

- ...:

  Cohorts to include in the output, can be quoted or unquoted cohort
  names, or tidyselect helpers such as
  [`tidyselect::starts_with()`](https://tidyselect.r-lib.org/reference/starts_with.html).

- .label_fn:

  An optional custom function for formatting cohort counts. It is called
  once per cohort with the arguments `label`, `count`, and `cohort`, and
  should return a single string.

## Value

A `tibble` with cohort name, row number total, and label.

## Functions

- `cohort_count()`: Returns a tibble with cohort name, row number total
  and label.

- `cohort_count_int()`: Returns a named vector with cohort counts.

- `cohort_count_adorn()`: Returns a cohort count in "(n = )" or other
  custom format. By default, counts are formatted with comma separators,
  e.g. "Randomized (n = 5,932,291)".

- `cohort_count_bullets()`: Returns a multi-line box label: the first
  selected cohort becomes the header line and the rest become bullet
  points, e.g. for the "Excluded" box of a CONSORT diagram: "Excluded (n
  = 262)" followed by one bulleted line per reason. Each line is
  formatted as by `cohort_count_adorn()`.

## Examples

``` r
cohorts <- trial_data |>
  cohort_start("Assessed for eligibility") |>
    cohort_define(
      consented = .full |> dplyr::filter(declined != 1),
      consented_chemonaive = consented |> dplyr::filter(prior_chemo != 1)
    ) |>
    cohort_label(
      consented = "Consented",
      consented_chemonaive = "Chemotherapy naive"
    )

cohorts |>
  cohort_count()
#> # A tibble: 3 × 3
#>   cohort               count label                   
#>   <chr>                <int> <chr>                   
#> 1 .full                 1200 Assessed for eligibility
#> 2 consented             1141 Consented               
#> 3 consented_chemonaive  1028 Chemotherapy naive      

cohorts |>
  cohort_count_adorn()
#> [1] "Assessed for eligibility (n = 1,200)"
#> [2] "Consented (n = 1,141)"               
#> [3] "Chemotherapy naive (n = 1,028)"      

cohorts |>
  cohort_count_adorn(
    starts_with("consented"),
    .label_fn = function(cohort, label, count, ...) {
      glue::glue("{count} {label} ({cohort})")
    }
  )
#> [1] "1141 Consented (consented)"                    
#> [2] "1028 Chemotherapy naive (consented_chemonaive)"

cohorts |>
  cohort_count_bullets(consented, consented_chemonaive)
#> [1] "Consented (n = 1,141)<br>• Chemotherapy naive (n = 1,028)"
```
