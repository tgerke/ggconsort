test_that("consort_box_add() converts a cohort to a ggconsort object", {
  consort <- test_cohort() |>
    consort_box_add("full", 0, 10, "Assessed")

  expect_s3_class(consort, "ggconsort")
  expect_s3_class(consort, "ggconsort_cohort")
  expect_equal(nrow(consort$consort), 1)
  expect_equal(consort$consort$type, "box")
  expect_equal(consort$consort$name, "full")
})

test_that("consort_box_add() stores hjust/vjust overrides (#24)", {
  consort <- test_cohort() |>
    consort_box_add("a", 0, 10, "A") |>
    consort_box_add("b", 0, 0, "B", hjust = 0, vjust = 1)

  expect_equal(consort$consort$hjust, c(NA, 0))
  expect_equal(consort$consort$vjust, c(NA, 1))
})

test_that("consort_arrow_add() and consort_line_add() add typed rows", {
  consort <- test_cohort() |>
    consort_box_add("a", 0, 10, "A") |>
    consort_box_add("b", 0, 0, "B") |>
    consort_arrow_add(start = "a", start_side = "bottom", end = "b", end_side = "top") |>
    consort_line_add(start_x = -5, start_y = 5, end_x = 5, end_y = 5)

  expect_equal(consort$consort$type, c("box", "box", "arrow", "line"))
})

test_that("consort_box_add() accepts a row/col grid position", {
  consort <- test_cohort() |>
    consort_box_add("full", row = 1, label = "Assessed") |>
    consort_box_add("side", row = 2, col = "side", label = "Excluded") |>
    consort_box_add("arm", row = 3, col = -1, label = "Arm A")

  expect_equal(consort$consort$row, c(1, 2, 3))
  expect_equal(consort$consort$col, c(0, 1, -1))
  # nominal coordinates keep the ggplot scales finite
  expect_equal(consort$consort$box_x, c(0, 1, -1))
  expect_equal(consort$consort$box_y, c(-1, -2, -3))
})

test_that("consort_box_add() rejects ambiguous or missing positions", {
  expect_error(
    test_cohort() |> consort_box_add("a", 0, 10, "A", row = 1),
    "not both"
  )
  expect_error(
    test_cohort() |> consort_box_add("a", label = "A"),
    "needs a position"
  )
  expect_error(
    test_cohort() |> consort_box_add("a", row = 1, col = "middle", label = "A"),
    "`col` must be"
  )
})

test_that("consort_stage_add() stores badges and row spans", {
  consort <- test_cohort() |>
    consort_box_add("a", row = 1, label = "A") |>
    consort_stage_add("Screening", row = c(1, 3), angle = 90)

  stage <- consort$consort[consort$consort$type == "stage", ]
  expect_equal(stage$row, 1)
  expect_equal(stage$row2, 3)
  # the default "margin" column is a sentinel resolved by
  # create_consort_data() once every box position is known
  expect_equal(stage$col, -Inf)
  expect_equal(stage$angle, 90)
  expect_error(
    test_cohort() |> consort_stage_add("x", row = "one"),
    "`row` must be"
  )
})

test_that("a vector `end` marks arrows as a T-split group", {
  consort <- test_cohort() |>
    consort_box_add("main", row = 1, label = "Main") |>
    consort_box_add("a", row = 2, col = -1, label = "A") |>
    consort_box_add("b", row = 2, col = 1, label = "B") |>
    consort_arrow_add(start = "main", end = c("a", "b"))

  arrows <- consort$consort[consort$consort$type == "arrow", ]
  expect_equal(nrow(arrows), 2)
  expect_equal(arrows$tee_group, rep("main-tee", 2))
})

test_that("consort_box_add() labels boxes automatically from cohort names", {
  consort <- test_cohort() |>
    consort_box_add("consented", row = 1)

  box <- consort$consort[consort$consort$type == "box", ]
  expect_equal(box$label, "Consented (n = 7)")

  expect_error(
    test_cohort() |> consort_box_add("mystery", row = 1),
    "not a defined cohort"
  )
})

test_that("consort_box_add() stores per-box style overrides", {
  consort <- test_cohort() |>
    consort_box_add(
      "a", row = 1, label = "A",
      fill = "grey90", color = "red", text_color = "blue"
    ) |>
    consort_box_add("b", row = 2, label = "B")

  boxes <- consort$consort[consort$consort$type == "box", ]
  expect_equal(boxes$box_fill, c("grey90", NA))
  expect_equal(boxes$border_color, c("red", NA))
  expect_equal(boxes$text_color, c("blue", NA))
})

test_that("stage badges span columns and resolve the margin column", {
  consort <- test_cohort() |>
    consort_box_add("a", row = 1, col = -1, label = "A") |>
    consort_box_add("b", row = 1, col = 1, label = "B") |>
    consort_stage_add("Header", row = 1, col = c(-1, 1)) |>
    consort_stage_add("Margin", row = 1)

  data <- create_consort_data(consort)
  stages <- data[data$type == "stage", ]

  # the header spans columns -1..1 and is centered between them
  expect_equal(stages$col[1], -1)
  expect_equal(stages$col2[1], 1)
  expect_equal(stages$x[1], 0)

  # the default "margin" column resolves to one left of the leftmost box
  expect_equal(stages$col[2], -2)
  expect_equal(stages$col2[2], -2)

  expect_error(
    test_cohort() |> consort_stage_add("x", row = 1, col = c(0, 1, 2)),
    "span columns"
  )
})
