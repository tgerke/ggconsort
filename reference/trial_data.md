# Screened and randomized patients

A simulated dataset containing 3 trial exclusion variables, a treatment
allocation variable, and follow-up/analysis outcomes for the randomized
patients, supporting a complete four-stage CONSORT diagram (Enrollment,
Allocation, Follow-up, Analysis).

## Usage

``` r
trial_data
```

## Format

A tibble with 1200 rows and 8 variables:

- id:

  patient ID

- declined:

  indicator for declining to participate

- prior_chemo:

  indicator for prior chemotherapy, a trial exclusion

- bone_mets:

  indicator for bone metastases, a trial exclusion

- treatment:

  treatment assignment (`NA` for patients who were not randomized)

- lost_to_followup:

  indicator for loss to follow-up (`NA` for patients who were not
  randomized)

- discontinued:

  indicator for treatment discontinuation (`NA` for patients who were
  not randomized)

- not_analyzed:

  indicator for exclusion from the primary analysis (`NA` for patients
  who were not randomized)

## Source

dev/sim-data.R
