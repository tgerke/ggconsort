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
