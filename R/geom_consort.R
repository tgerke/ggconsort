#' @export

geom_consort <- function(...) {
  list(
    geom_consort_arrow(...),
    geom_consort_box(...)
  )
}
