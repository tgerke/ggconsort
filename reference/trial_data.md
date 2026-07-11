# Screened and randomized patients

A simulated dataset containing 3 trial exclusion variables and a
treatment allocation variable.

## Usage

``` r
trial_data
```

## Format

A tibble with 1200 rows and 5 variables:

- id:

  patient ID

- declined:

  indicator for declining to participate

- prior_chemo:

  indicator for prior chemotherapy, a trial exclusion

- bone_mets:

  indicator for bone metastases, a trial exclusion

- treatment:

  treatment assignment

## Source

dev/sim-data.R
