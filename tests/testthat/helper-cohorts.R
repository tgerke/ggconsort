# a small cohort used across tests: 10 subjects, 3 declined
test_cohort <- function() {
  df <- dplyr::tibble(
    id = 1:10,
    declined = c(rep(1, 3), rep(0, 7))
  )

  df %>%
    cohort_start("Assessed for eligibility") %>%
    cohort_define(
      consented = .full %>% dplyr::filter(declined == 0),
      excluded = dplyr::anti_join(.full, consented, by = "id")
    ) %>%
    cohort_label(
      consented = "Consented",
      excluded = "Declined to participate"
    )
}
