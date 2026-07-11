#' @rdname geom_consort
#' @format NULL
#' @usage NULL
#' @export
GeomConsortDiagram <- ggplot2::ggproto("GeomConsortDiagram", ggplot2::Geom,
  required_aes = c("x", "y"),
  optional_aes = c(
    "xend", "yend", "label", "type", "name",
    "start", "end", "start_side", "end_side", "hjust", "vjust",
    "layout_row", "layout_row2", "layout_col",
    "stage_fill", "angle", "tee_group"
  ),
  draw_key = ggplot2::draw_key_blank,
  draw_panel = function(
    data, panel_params, coord,
    # ggplot2 standardizes user-facing *_color params to *_colour
    label_colour = "black", label_size = 11, label_height = 1,
    fill = "white", box_colour = "black"
  ) {
    coords <- coord$transform(data, panel_params)
    grid::gTree(
      diagram = coords,
      label_colour = label_colour,
      label_size = label_size,
      label_height = label_height,
      fill = fill,
      box_colour = box_colour,
      cl = "consort_diagram_grob"
    )
  }
)

# Boxes are sized in absolute text units, so their extents in panel (npc)
# coordinates are only knowable at draw time, on the open device. makeContent
# runs then: it measures every box, lays out row/column diagrams to fill the
# panel, and trims arrows to the measured box edges.
#' @exportS3Method grid::makeContent
makeContent.consort_diagram_grob <- function(x) {
  d <- x$diagram
  grid_mode <- "layout_row" %in% names(d) && any(!is.na(d$layout_row))
  if (grid_mode) {
    consort_content_grid(x)
  } else {
    consort_content_coord(x)
  }
}

# one box or stage badge, centered at (cx, cy) npc unless justified
consort_element_grob <- function(x, el, cx, cy, hjust = 0.5, vjust = 0.5) {
  is_stage <- identical(el$type, "stage")
  gridtext::richtext_grob(
    text = el$label,
    x = grid::unit(cx, "npc"),
    y = grid::unit(cy, "npc"),
    hjust = hjust,
    vjust = vjust,
    # multi-line labels (e.g. bulleted exclusion lists) read better ragged
    # right; single lines are centered either way
    halign = if (grepl("<br", el$label, fixed = TRUE)) 0 else 0.5,
    rot = if (is_stage) el$angle %|NA|% 0 else 0,
    gp = grid::gpar(
      col = x$label_colour,
      fontsize = x$label_size,
      lineheight = x$label_height
    ),
    box_gp = grid::gpar(
      col = x$box_colour,
      fill = if (is_stage) el$stage_fill else x$fill,
      lwd = 0.25 * ggplot2::.pt
    ),
    r = grid::unit(if (is_stage) 0.15 else 0, "lines"),
    padding = grid::unit(c(0.25, 0.25, 0.25, 0.25), "lines"),
    margin = grid::unit(c(0, 0, 0, 0), "pt")
  )
}

# measure a grob in npc; a degenerate (zero-size) panel, e.g. from oversized
# plot margins, makes npc conversion error -- fall back to zero extents
measure_grob_npc <- function(g) {
  tryCatch(
    c(
      grid::convertWidth(grid::grobWidth(g), "npc", valueOnly = TRUE),
      grid::convertHeight(grid::grobHeight(g), "npc", valueOnly = TRUE)
    ),
    error = function(e) c(0, 0)
  )
}

npc_line <- function(fun) {
  tryCatch(
    fun(grid::unit(1, "lines"), "npc", valueOnly = TRUE),
    error = function(e) 0
  )
}

consort_edge_grobs <- function(starts, ends, is_arrow) {
  gp <- grid::gpar(
    col = "black", lwd = 0.15 * ggplot2::.pt,
    lineend = "butt", linejoin = "mitre", fill = "black"
  )
  out <- list()
  if (any(is_arrow)) {
    out <- c(out, list(grid::segmentsGrob(
      x0 = starts[is_arrow, 1], y0 = starts[is_arrow, 2],
      x1 = ends[is_arrow, 1], y1 = ends[is_arrow, 2],
      default.units = "npc", gp = gp,
      arrow = grid::arrow(length = grid::unit(2, "mm"), type = "closed")
    )))
  }
  if (any(!is_arrow)) {
    out <- c(out, list(grid::segmentsGrob(
      x0 = starts[!is_arrow, 1], y0 = starts[!is_arrow, 2],
      x1 = ends[!is_arrow, 1], y1 = ends[!is_arrow, 2],
      default.units = "npc", gp = gp
    )))
  }
  out
}

side_midpoint <- function(rect, side) {
  switch(
    side,
    top = c(rect$cx, rect$top),
    bottom = c(rect$cx, rect$bottom),
    left = c(rect$left, rect$cy),
    right = c(rect$right, rect$cy)
  )
}

# ---- x/y coordinate mode ----------------------------------------------------

consort_content_coord <- function(x) {
  d <- x$diagram
  boxes <- d[d$type == "box", , drop = FALSE]
  edges <- d[d$type %in% c("arrow", "line"), , drop = FALSE]

  box_grobs <- vector("list", nrow(boxes))
  rects <- data.frame(
    name = character(nrow(boxes)), left = numeric(nrow(boxes)),
    right = numeric(nrow(boxes)), bottom = numeric(nrow(boxes)),
    top = numeric(nrow(boxes)), cx = numeric(nrow(boxes)),
    cy = numeric(nrow(boxes))
  )

  for (i in seq_len(nrow(boxes))) {
    hjust <- boxes$hjust[i] %|NA|% 0.5
    vjust <- boxes$vjust[i] %|NA|% 0.5
    g <- consort_element_grob(
      x, boxes[i, ], boxes$x[i], boxes$y[i], hjust = hjust, vjust = vjust
    )
    box_grobs[[i]] <- g

    size <- measure_grob_npc(g)
    left <- boxes$x[i] - hjust * size[1]
    bottom <- boxes$y[i] - vjust * size[2]
    rects[i, ] <- list(
      boxes$name[i] %|NA|% "", left, left + size[1], bottom, bottom + size[2],
      left + size[1] / 2, bottom + size[2] / 2
    )
  }

  # arrow endpoint for one edge end: the midpoint of the named box's side,
  # or the explicit/anchor coordinates when no box (or an unknown box) is named
  anchor_point <- function(name, side, x0, y0, x_other, y_other) {
    idx <- if (is.na(name)) NA_integer_ else match(name, rects$name)
    if (is.na(idx)) {
      return(c(x0, y0))
    }
    r <- rects[idx, ]
    if (is.na(side)) {
      dx <- x_other - r$cx
      dy <- y_other - r$cy
      side <- if (abs(dx) > abs(dy)) {
        if (dx > 0) "right" else "left"
      } else {
        if (dy > 0) "top" else "bottom"
      }
    }
    side_midpoint(r, side)
  }

  edge_grobs <- list()
  if (nrow(edges) > 0) {
    starts <- matrix(NA_real_, nrow(edges), 2)
    ends <- matrix(NA_real_, nrow(edges), 2)
    for (i in seq_len(nrow(edges))) {
      starts[i, ] <- anchor_point(
        edges$start[i], edges$start_side[i],
        edges$x[i], edges$y[i], edges$xend[i], edges$yend[i]
      )
      ends[i, ] <- anchor_point(
        edges$end[i], edges$end_side[i],
        edges$xend[i], edges$yend[i], edges$x[i], edges$y[i]
      )
    }
    edge_grobs <- consort_edge_grobs(starts, ends, edges$type == "arrow")
  }

  grid::setChildren(x, do.call(grid::gList, c(edge_grobs, box_grobs)))
}

# ---- row/column grid mode ---------------------------------------------------

consort_content_grid <- function(x) {
  d <- x$diagram
  els <- d[d$type %in% c("box", "stage"), , drop = FALSE]
  edges <- d[d$type %in% c("arrow", "line"), , drop = FALSE]

  n <- nrow(els)
  w <- h <- numeric(n)
  for (i in seq_len(n)) {
    size <- measure_grob_npc(consort_element_grob(x, els[i, ], 0.5, 0.5))
    w[i] <- size[1]
    h[i] <- size[2]
  }

  spans <- els$type == "stage" & !is.na(els$layout_row2) &
    els$layout_row2 > els$layout_row

  # the layout fills the panel minus a small padding so box borders and
  # arrowheads at the extremes are never clipped
  pad_y <- 0.5 * npc_line(grid::convertHeight)
  pad_x <- 0.5 * npc_line(grid::convertWidth)

  # vertical: stack rows from the top, equalizing the gaps; a row is as tall
  # as its tallest element (row-spanning stages don't count)
  rows <- sort(unique(c(els$layout_row, els$layout_row2[spans])))
  row_h <- vapply(
    rows,
    function(r) max(c(0, h[!spans & els$layout_row == r])),
    numeric(1)
  )
  min_gap <- npc_line(grid::convertHeight)
  if (length(rows) > 1) {
    gap <- max((1 - 2 * pad_y - sum(row_h)) / (length(rows) - 1), min_gap)
    row_top <- (1 - pad_y) - cumsum(c(0, utils::head(row_h + gap, -1)))
    row_cy <- row_top - row_h / 2
  } else {
    row_cy <- 0.5
  }

  # horizontal: adjacent columns are separated just enough that no two
  # elements sharing a row overlap (a wide box only claims space in its own
  # rows), then the diagram is stretched to fill the panel
  cols <- sort(unique(els$layout_col))
  min_gap_x <- npc_line(grid::convertWidth)
  el_row_lo <- els$layout_row
  el_row_hi <- ifelse(spans, els$layout_row2, els$layout_row)
  half_in_row <- function(cc, r) {
    in_cell <- els$layout_col == cc & el_row_lo <= r & el_row_hi >= r
    max(c(0, w[in_cell])) / 2
  }
  if (length(cols) > 1) {
    sep <- vapply(
      seq_len(length(cols) - 1),
      function(k) {
        min_gap_x + max(vapply(
          rows,
          function(r) half_in_row(cols[k], r) + half_in_row(cols[k + 1], r),
          numeric(1)
        ))
      },
      numeric(1)
    )
    rel_cx <- cumsum(c(0, sep))
    rel_at <- rel_cx[match(els$layout_col, cols)]
    extent <- c(min(rel_at - w / 2), max(rel_at + w / 2))
    slack <- (1 - 2 * pad_x) - diff(extent)
    if (slack > 0) {
      sep <- sep + slack / length(sep)
      rel_cx <- cumsum(c(0, sep))
      rel_at <- rel_cx[match(els$layout_col, cols)]
      extent <- c(min(rel_at - w / 2), max(rel_at + w / 2))
    }
    col_cx <- rel_cx + (pad_x - extent[1])
  } else {
    col_cx <- 0.5
  }

  cx <- col_cx[match(els$layout_col, cols)]
  cy <- ifelse(
    spans,
    (row_cy[match(els$layout_row, rows)] +
       row_cy[match(els$layout_row2, rows)]) / 2,
    row_cy[match(els$layout_row, rows)]
  )

  rects <- data.frame(
    name = ifelse(is.na(els$name), "", els$name),
    left = cx - w / 2, right = cx + w / 2,
    bottom = cy - h / 2, top = cy + h / 2,
    cx = cx, cy = cy,
    row = els$layout_row, col = els$layout_col
  )

  el_grobs <- vector("list", n)
  for (i in seq_len(n)) {
    el_grobs[[i]] <- consort_element_grob(x, els[i, ], cx[i], cy[i])
  }

  # route edges between named boxes: vertically within a column, horizontally
  # within a row, and otherwise as a horizontal branch off the start box's
  # column at the height of the target box
  route <- function(e) {
    si <- match(e$start, rects$name)
    ei <- match(e$end, rects$name)
    if (is.na(si) || is.na(ei)) {
      return(NULL)
    }
    sr <- rects[si, ]
    er <- rects[ei, ]

    if (!is.na(e$start_side) && !is.na(e$end_side)) {
      return(rbind(side_midpoint(sr, e$start_side), side_midpoint(er, e$end_side)))
    }
    if (sr$col == er$col) {
      if (er$row >= sr$row) {
        rbind(c(sr$cx, sr$bottom), c(er$cx, er$top))
      } else {
        rbind(c(sr$cx, sr$top), c(er$cx, er$bottom))
      }
    } else if (sr$row == er$row) {
      if (er$col >= sr$col) {
        rbind(c(sr$right, sr$cy), c(er$left, er$cy))
      } else {
        rbind(c(sr$left, sr$cy), c(er$right, er$cy))
      }
    } else {
      if (er$col >= sr$col) {
        rbind(c(sr$cx, er$cy), c(er$left, er$cy))
      } else {
        rbind(c(sr$cx, er$cy), c(er$right, er$cy))
      }
    }
  }

  starts <- ends <- matrix(numeric(0), 0, 2)
  is_arrow <- logical(0)
  add_edge <- function(p0, p1, arrow) {
    starts <<- rbind(starts, p0)
    ends <<- rbind(ends, p1)
    is_arrow <<- c(is_arrow, arrow)
  }

  simple <- edges[is.na(edges$tee_group), , drop = FALSE]
  for (i in seq_len(nrow(simple))) {
    seg <- route(simple[i, ])
    if (!is.null(seg)) {
      add_edge(seg[1, ], seg[2, ], simple$type[i] == "arrow")
    }
  }

  # T-splits: one drop from the start box, a crossbar halfway to the target
  # row, then an arrow down into each end box
  for (tg in unique(stats::na.omit(edges$tee_group))) {
    grp <- edges[!is.na(edges$tee_group) & edges$tee_group == tg, , drop = FALSE]
    si <- match(grp$start[1], rects$name)
    ei <- match(grp$end, rects$name)
    if (is.na(si) || anyNA(ei)) {
      next
    }
    sr <- rects[si, ]
    er <- rects[ei, , drop = FALSE]
    y_mid <- (sr$bottom + max(er$top)) / 2
    add_edge(c(sr$cx, sr$bottom), c(sr$cx, y_mid), arrow = FALSE)
    add_edge(
      c(min(c(er$cx, sr$cx)), y_mid), c(max(c(er$cx, sr$cx)), y_mid),
      arrow = FALSE
    )
    for (k in seq_len(nrow(er))) {
      add_edge(c(er$cx[k], y_mid), c(er$cx[k], er$top[k]), arrow = TRUE)
    }
  }

  edge_grobs <- if (nrow(starts) > 0) {
    consort_edge_grobs(starts, ends, is_arrow)
  } else {
    list()
  }

  grid::setChildren(x, do.call(grid::gList, c(edge_grobs, el_grobs)))
}

`%|NA|%` <- function(a, b) {
  if (length(a) == 0 || is.na(a)) b else a
}
