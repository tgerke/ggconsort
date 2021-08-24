#' @export

# combines tibbles like consort_boxes and consort_arrows into a
# usable form for ggconsort geoms
# consort_boxes and consort_arrows are expected to have certain formats
# FIXME: to describe and check for those formats

create_consort_data <- function(consort_boxes, consort_arrows) {
  # first, find out what arrows a box receives for hjust and vjust settings
  # FIXME: account for 2+ arrows coming in by summarizing those rows
  boxes <- left_join(
    consort_boxes,
    consort_arrows %>% select(end, end_side),
    by = c("name" = "end")
  ) %>%
    mutate(
      vjust = if_else(
        end_side == "top", 1, .5, missing = .5
      ),
      hjust = case_when(
        end_side == "left" ~ 0,
        end_side == "right" ~ 1,
        TRUE ~ .5
      )
    )

  arrows <- left_join(
    consort_arrows,
    consort_boxes %>% select(-label),
    by = c("start" = "name")
  ) %>%
    left_join(
      consort_boxes %>%
        select(-label) %>%
        rename(xend = x, yend = y),
      by = c("end" = "name")
    ) %>%
    mutate(
      x = if_else(is.na(start_x), x, as.numeric(start_x)),
      y = if_else(is.na(start_y), y, as.numeric(start_y)),
      xend = if_else(is.na(end_x), xend, as.numeric(end_x)),
      yend = if_else(is.na(end_y), yend, as.numeric(end_y))
    ) %>%
    select(-starts_with("start_manual"))

  return(list(boxes = boxes, arrows = arrows))
}
