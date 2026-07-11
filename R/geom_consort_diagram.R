#' @rdname geom_consort
#' @format NULL
#' @usage NULL
#' @export
GeomConsortDiagram <- ggplot2::ggproto("GeomConsortDiagram", ggplot2::Geom,
  required_aes = c("x", "y"),
  optional_aes = c(
    "xend", "yend", "label", "type", "name",
    "start", "end", "start_side", "end_side", "hjust", "vjust"
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
# runs then: it measures each box and trims arrows to the measured edges.
#' @exportS3Method grid::makeContent
makeContent.consort_diagram_grob <- function(x) {
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
    g <- gridtext::richtext_grob(
      text = boxes$label[i],
      x = grid::unit(boxes$x[i], "npc"),
      y = grid::unit(boxes$y[i], "npc"),
      hjust = hjust,
      vjust = vjust,
      gp = grid::gpar(
        col = x$label_colour,
        fontsize = x$label_size,
        lineheight = x$label_height
      ),
      box_gp = grid::gpar(
        col = x$box_colour, fill = x$fill, lwd = 0.25 * ggplot2::.pt
      ),
      r = grid::unit(0, "pt"),
      padding = grid::unit(c(0.25, 0.25, 0.25, 0.25), "lines"),
      margin = grid::unit(c(0, 0, 0, 0), "pt")
    )
    box_grobs[[i]] <- g

    # a degenerate (zero-size) panel, e.g. from oversized plot margins, makes
    # npc conversion error; fall back to zero extents (anchor-point arrows)
    size <- tryCatch(
      c(
        grid::convertWidth(grid::grobWidth(g), "npc", valueOnly = TRUE),
        grid::convertHeight(grid::grobHeight(g), "npc", valueOnly = TRUE)
      ),
      error = function(e) c(0, 0)
    )
    w <- size[1]
    h <- size[2]
    left <- boxes$x[i] - hjust * w
    bottom <- boxes$y[i] - vjust * h
    rects[i, ] <- list(
      boxes$name[i] %|NA|% "", left, left + w, bottom, bottom + h,
      left + w / 2, bottom + h / 2
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
    switch(
      side,
      top = c(r$cx, r$top),
      bottom = c(r$cx, r$bottom),
      left = c(r$left, r$cy),
      right = c(r$right, r$cy)
    )
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
    gp <- grid::gpar(
      col = "black", lwd = 0.15 * ggplot2::.pt,
      lineend = "butt", linejoin = "mitre", fill = "black"
    )
    is_arrow <- edges$type == "arrow"
    if (any(is_arrow)) {
      edge_grobs <- c(edge_grobs, list(grid::segmentsGrob(
        x0 = starts[is_arrow, 1], y0 = starts[is_arrow, 2],
        x1 = ends[is_arrow, 1], y1 = ends[is_arrow, 2],
        default.units = "npc", gp = gp,
        arrow = grid::arrow(length = grid::unit(2, "mm"), type = "closed")
      )))
    }
    if (any(!is_arrow)) {
      edge_grobs <- c(edge_grobs, list(grid::segmentsGrob(
        x0 = starts[!is_arrow, 1], y0 = starts[!is_arrow, 2],
        x1 = ends[!is_arrow, 1], y1 = ends[!is_arrow, 2],
        default.units = "npc", gp = gp
      )))
    }
  }

  grid::setChildren(x, do.call(grid::gList, c(edge_grobs, box_grobs)))
}

`%|NA|%` <- function(a, b) {
  if (length(a) == 0 || is.na(a)) b else a
}
