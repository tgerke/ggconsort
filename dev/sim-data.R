library(dplyr)

set.seed(8675309)

n <- 1200

screen_data <- tibble(
  id = sample(10000:99999, size = n, replace = FALSE),
  declined = sample(0:1, n, replace = TRUE, prob = c(.95, .05)),
  prior_chemo = sample(0:1, n, replace = TRUE, prob = c(.90, .10)),
  bone_mets = sample(0:1, n, replace = TRUE, prob = c(.90, .10)),
) %>%
  mutate(
    excluded = if_else(declined | prior_chemo | bone_mets, 1, 0)
  )

randomized <- screen_data %>%
  filter(excluded == 0) %>%
  mutate(
    treatment = if_else(row_number() %% 2 == 1, "Drug A", "Drug B")
  )

trial_data <- screen_data %>%
  select(-excluded) %>%
  left_join(
    randomized %>%
      select(id, treatment),
    by = "id"
  )

# usethis::use_data(trial_data)
