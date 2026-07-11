#' Screened and randomized patients
#'
#' A simulated dataset containing 3 trial exclusion variables, a treatment
#' allocation variable, and follow-up/analysis outcomes for the randomized
#' patients, supporting a complete four-stage CONSORT diagram (Enrollment,
#' Allocation, Follow-up, Analysis).
#'
#' @format A tibble with 1200 rows and 8 variables:
#' \describe{
#'   \item{id}{patient ID}
#'   \item{declined}{indicator for declining to participate}
#'   \item{prior_chemo}{indicator for prior chemotherapy, a trial exclusion}
#'   \item{bone_mets}{indicator for bone metastases, a trial exclusion}
#'   \item{treatment}{treatment assignment (`NA` for patients who were not
#'     randomized)}
#'   \item{lost_to_followup}{indicator for loss to follow-up (`NA` for
#'     patients who were not randomized)}
#'   \item{discontinued}{indicator for treatment discontinuation (`NA` for
#'     patients who were not randomized)}
#'   \item{not_analyzed}{indicator for exclusion from the primary analysis
#'     (`NA` for patients who were not randomized)}
#' }
#' @source dev/sim-data.R
"trial_data"
