library(dplyr)
library(ggplot2)
library(ggconsort)
library(palmerpenguins)

penguin_cohorts <-
  penguins %>%
  mutate(.id = row_number()) %>% # a unique ID for joins
  cohort_start("Penguins observerd by Palmer Station LTER") %>%
  # Define cohorts using named expressions --------------------
# Notice that you can use previously defined cohorts in subsequent steps
cohort_define(
  adelie = .full %>% filter(species == "Adelie"),
  adelie_male = adelie %>% filter(sex == "male"),
  biscoe_adelie_male = adelie_male %>% filter(island == "Biscoe"),
  high_bm = biscoe_adelie_male %>% filter(body_mass_g > 4000),
  low_bm = biscoe_adelie_male %>% filter(body_mass_g <= 4000),
  # anti_join is useful for counting exclusions
  excluded = anti_join(.full, biscoe_adelie_male, by = ".id"),
  excluded_not_adelie = anti_join(.full, adelie, by = ".id"),
  excluded_not_adelie_male = anti_join(adelie, adelie_male, by = ".id"),
  excluded_not_adelie_male_biscoe = anti_join(
    adelie_male, biscoe_adelie_male, by = ".id"
  )
) %>%
  # Provide text labels for cohorts ---------------------------
cohort_label(
  adelie = "Adelie penguins",
  adelie_male = "Adelie male penguins",
  biscoe_adelie_male = "Male Adelie penguins on Biscoe island",
  high_bm = "Body mass > 4000g",
  low_bm = "Body mass ≤ 4000g",
  excluded = "Excluded",
  excluded_not_adelie = "Not Adelie",
  excluded_not_adelie_male = "Not male",
  excluded_not_adelie_male_biscoe = "Not on Biscoe island"
)

penguin_cohorts <- penguin_cohorts %>%
  consort_box_add(
    "full", 0, 50, cohort_count_adorn(penguin_cohorts, .full)
  ) %>%
  consort_box_add(
    "exclusions", 20, 40, glue::glue(
      '{cohort_count_adorn(penguin_cohorts, excluded)}<br>
      • {cohort_count_adorn(penguin_cohorts, excluded_not_adelie)}<br>
      • {cohort_count_adorn(penguin_cohorts, excluded_not_adelie_male)}<br>
      • {cohort_count_adorn(penguin_cohorts, excluded_not_adelie_male_biscoe)}
      ')
  ) %>%
  consort_box_add(
    "final", 0, 30, cohort_count_adorn(penguin_cohorts, biscoe_adelie_male)
  ) %>%
  consort_box_add(
    "high_bm", -30, 10, cohort_count_adorn(penguin_cohorts, high_bm)
  ) %>%
  consort_box_add(
    "low_bm", 30, 10, cohort_count_adorn(penguin_cohorts, low_bm)
  ) %>%
  consort_arrow_add(
    end = "exclusions", end_side = "left", start_x = 0, start_y = 40
  ) %>%
  consort_arrow_add(
    "full", "bottom", "final", "top"
  ) %>%
  consort_arrow_add(
    start_x = 0, start_y = 30, end_x = 0, end_y = 20,
  ) %>%
  consort_line_add(
    start_x = -30, start_y = 20, end_x = 30, end_y = 20,
  ) %>%
  consort_arrow_add(
    end = "high_bm", end_side = "top", start_x = -30, start_y = 20
  ) %>%
  consort_arrow_add(
    end = "low_bm", end_side = "top", start_x = 30, start_y = 20
  )

p <- penguin_cohorts %>%
  ggplot() +
  xlim(-50, 60) +
  ylim(5, 55)

library(hexSticker)
library(showtext)

font_add_google("Noto Sans KR", regular.wt = 500)
showtext_auto()

sticker(
  p,
  package="→ ggconsort ↓",
  p_x = 1,
  p_y = 1.5,
  p_size=20,
  p_family = "Noto Sans KR",
  s_x=1.03,
  s_y=.8,
  s_width=1,
  s_height=1,
  h_fill = "#794e58",
  h_color = "#4e796f",
  dpi = 900
) %>%
  ggsave(
    filename= here::here("dev/ggconsort-hex.png"),
    width = 9,
    height = 9
  )

