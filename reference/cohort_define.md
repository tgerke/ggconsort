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
