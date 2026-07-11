# Layout engine design notes (2026-07)

Decisions behind the draw-time layout engine and the row/column API, for
future maintainers.

## Why measurement happens at draw time

Box positions are data coordinates but box sizes are absolute text units, so
a diagram's proportions depend on the device it is drawn on. Anything decided
before drawing (spacing, arrow endpoints, panel expansion) is wrong at some
device size. `geom_consort()` therefore returns a `gTree` whose
`makeContent()` method (the ggrepel pattern) runs during rendering, with the
panel viewport current: it builds each label with `gridtext::richtext_grob()`,
measures it with `grobWidth()`/`grobHeight()`, and only then places boxes and
routes arrows. Resizing a device re-runs `makeContent()`, so layouts reflow.

## Two layout modes

- **Coordinate mode** (`consort_box_add(name, x, y, ...)`): boxes are drawn
  centered on their coordinates (or per user `hjust`/`vjust`), and arrows are
  trimmed to the measured box edges. The pre-0.3 behavior of shifting a box by
  a justification inferred from arrow entry sides survives only in the legacy
  `geom_consort_box()`/`geom_consort_arrow()` layers.
- **Grid mode** (`consort_box_add(name, row =, col =, ...)`): user code
  contains no coordinates. Boxes get nominal coordinates (`x = col`,
  `y = -row`) so ggplot scales train, but `makeContent()` ignores them and
  computes the real layout in npc. Modes cannot be mixed in one diagram.

## Grid layout rules

- Rows stack from the top; each row is as tall as its tallest element, and
  the leftover panel height is split into equal gaps (minimum one line).
- Column separation is pairwise per row: two adjacent columns are pushed
  apart just enough that elements sharing a row don't collide (plus one line
  of gap). A wide side box therefore only claims space in its own rows —
  computing column widths as a global max instead pushed the README's
  "Excluded" box off-panel. Leftover width is distributed into the gaps.
- Everything is laid out inside a half-line padding so borders and
  arrowheads at the extremes aren't clipped; `theme_consort()` margins are
  no longer needed for that.
- Arrow routing: same column → vertical, same row → horizontal (PRISMA
  style, box edge to box edge), otherwise a horizontal branch off the start
  box's column at the target box's height. A vector `end` becomes a T-split
  (drop, crossbar, per-arm arrows) grouped via `tee_group`.
- Stage badges are layout elements like boxes (rounded corners, fill,
  optional rotation). A badge spanning rows (`row = c(2, 4)`) centers between
  those row centers and does not contribute to row heights.

## Known limitations

- Extra user-added ggplot layers position by data coordinates; in grid mode
  those are nominal (`x = col`, `y = -row`), not the drawn layout, so
  annotations should use `consort_stage_add()` instead.
- `col` could not be an aesthetic name (ggplot2 aliases it to `colour`);
  the geom maps `layout_row`/`layout_col`/`layout_row2`.
- ggplot2 renames `*_color` layer params to `*_colour` before they reach
  `draw_panel()`, hence the British spellings in `GeomConsortDiagram`.
