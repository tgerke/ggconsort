#' Screened and randomized patients
#'
#' A simulated dataset containing 3 trial exclusion variables and
#' a treatment allocation variable.
#'
#' @format A tibble with 1200 rows and 5 variables:
#' \describe{
#'   \item{id}{patient ID}
#'   \item{declined}{indicator for declining to participate}
#'   \item{prior_chemo}{indicator for prior chemotherapy, a trial exclusion}
#'   \item{bone_mets}{indicator for bone metastases, a trial exclusion}
#'   \item{treatment}{treatment assignment}
#' }
#' @source dev/sim-data.R
"trial_data"
