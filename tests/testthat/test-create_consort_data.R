test_that("create_consort_data() requires a ggconsort object", {
  expect_error(
    create_consort_data(mtcars),
    "must be a ggconsort object"
  )
  # a cohort without any consort_*_add() calls is not enough
  expect_error(
    create_consort_data(test_cohort()),
    "must be a ggconsort object"
  )
})

test_that("a box with several incoming arrows keeps a single row", {
  data <- test_cohort() |>
    consort_box_add("a", 0, 10, "A") |>
    consort_box_add("b", 10, 10, "B") |>
    consort_box_add("target", 5, 0, "target box") |>
    consort_arrow_add(start = "a", start_side = "bottom", end = "target", end_side = "top") |>
    consort_arrow_add(start = "b", start_side = "bottom", end = "target", end_side = "left") |>
    create_consort_data()

  target <- data[data$type == "box" & !is.na(data$name) & data$name == "target", ]
  expect_equal(nrow(target), 1)
  expect_equal(target$arrow_in, "top,left")
  # top entry sets vjust, left entry sets hjust
  expect_equal(target$vjust, 1)
  expect_equal(target$hjust, 0)
})

test_that("a box-only consort builds plotting data (#21, #22)", {
  data <- test_cohort() |>
    consort_box_add("full", 0, 10, "Assessed") |>
    create_consort_data()

  expect_equal(nrow(data), 1)
  expect_equal(data$type, "box")
})

test_that("arrows carry names and sides through for edge anchoring", {
  data <- test_cohort() |>
    consort_box_add("a", 0, 10, "A") |>
    consort_box_add("b", 5, 0, "B") |>
    consort_arrow_add(start = "a", start_side = "bottom", end = "b", end_side = "top") |>
    create_consort_data()

  arrow <- data[data$type == "arrow", ]
  expect_equal(arrow$start, "a")
  expect_equal(arrow$start_side, "bottom")
  expect_equal(arrow$end, "b")
  expect_equal(arrow$end_side, "top")
  # boxes expose x/y alongside legacy box_x/box_y
  boxes <- data[data$type == "box", ]
  expect_equal(boxes$x, boxes$box_x)
  expect_equal(boxes$y, boxes$box_y)
})

test_that("arrows resolve coordinates from box names", {
  data <- test_cohort() |>
    consort_box_add("a", 0, 10, "A") |>
    consort_box_add("b", 5, 0, "B") |>
    consort_arrow_add(start = "a", start_side = "bottom", end = "b", end_side = "top") |>
    create_consort_data()

  arrow <- data[data$type == "arrow", ]
  expect_equal(arrow$x, 0)
  expect_equal(arrow$y, 10)
  expect_equal(arrow$xend, 5)
  expect_equal(arrow$yend, 0)
})

test_that("justification is inferred from the arrow entry side", {
  data <- test_cohort() |>
    consort_box_add("a", 0, 10, "A") |>
    consort_box_add("side", 5, 10, "side box") |>
    consort_arrow_add(start_x = 0, start_y = 10, end = "side", end_side = "left") |>
    create_consort_data()

  side <- data[data$type == "box" & !is.na(data$name) & data$name == "side", ]
  expect_equal(side$hjust, 0)
  expect_equal(side$vjust, 0.5)
})

test_that("user hjust/vjust overrides beat arrow-based inference (#24)", {
  data <- test_cohort() |>
    consort_box_add("a", 0, 10, "A") |>
    consort_box_add("side", 5, 10, "side box", hjust = 0.5, vjust = 1) |>
    consort_arrow_add(start_x = 0, start_y = 10, end = "side", end_side = "left") |>
    create_consort_data()

  side <- data[data$type == "box" & !is.na(data$name) & data$name == "side", ]
  expect_equal(side$hjust, 0.5)
  expect_equal(side$vjust, 1)
})

test_that("boxes without arrows default to centered text", {
  data <- test_cohort() |>
    consort_box_add("a", 0, 10, "A") |>
    consort_arrow_add(start_x = 0, start_y = 5, end_x = 0, end_y = 0) |>
    create_consort_data()

  box <- data[data$type == "box", ]
  expect_equal(box$hjust, 0.5)
  expect_equal(box$vjust, 0.5)
})

test_that("layout modes cannot be mixed", {
  expect_error(
    test_cohort() |>
      consort_box_add("a", row = 1, label = "A") |>
      consort_box_add("b", 0, 0, "B") |>
      create_consort_data(),
    "same layout"
  )
  expect_error(
    test_cohort() |>
      consort_box_add("a", 0, 10, "A") |>
      consort_stage_add("Stage", row = 1) |>
      create_consort_data(),
    "row/column layout"
  )
  expect_error(
    test_cohort() |>
      consort_box_add("a", row = 1, label = "A") |>
      consort_arrow_add(start_x = 0, start_y = 10, end = "a", end_side = "top") |>
      create_consort_data(),
    "not available in a row/column layout"
  )
})

test_that("grid layouts pass rows, columns, and stages through", {
  data <- test_cohort() |>
    consort_box_add("a", row = 1, label = "A") |>
    consort_box_add("b", row = 2, col = "side", label = "B") |>
    consort_arrow_add(start = "a", end = "b") |>
    consort_stage_add("Stage", row = c(1, 2)) |>
    create_consort_data()

  boxes <- data[data$type == "box", ]
  expect_equal(boxes$row, c(1, 2))
  expect_equal(boxes$col, c(0, 1))

  stage <- data[data$type == "stage", ]
  expect_equal(stage$label, "Stage")
  expect_equal(stage$row2, 2)
  expect_equal(stage$stage_fill, "#9bc0fc")

  arrow <- data[data$type == "arrow", ]
  expect_equal(arrow$start, "a")
  expect_equal(arrow$end, "b")
})
