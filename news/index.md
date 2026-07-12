# Changelog

## ggconsort 0.4.0

### Breaking changes

- ggconsort now uses the base pipe `|>` throughout and no longer imports
  or re-exports magrittr’s `%>%`. Code that relied on ggconsort
  providing `%>%` should attach magrittr (or dplyr) itself. ggconsort
  now requires R \>= 4.1.

- In a row/column layout, row gaps are equalized but capped at 2 lines
  and the diagram is vertically centered, so large devices produce a
  compact CONSORT-style figure instead of a stretched one. Set
  `geom_consort(row_gap =)` for explicit control.

- [`consort_stage_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md)
  badges default to a new `"margin"` column, resolved at plot time to
  one column left of the leftmost box — stage labels sit in the margin
  as in the official CONSORT and PRISMA templates, and never collide
  with boxes. Pass an explicit `col` for the previous behavior.

### New features

- [`consort_box_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md)
  labels a box automatically when its `name` matches a cohort: the box
  text becomes the cohort’s label and count, as formatted by
  [`cohort_count_adorn()`](https://tgerke.github.io/ggconsort/reference/cohort_count.md),
  so most boxes need only a name and a grid position.

- New
  [`cohort_count_bullets()`](https://tgerke.github.io/ggconsort/reference/cohort_count.md)
  builds multi-line box labels — a header cohort followed by bulleted
  detail cohorts — replacing hand-written `glue()`/`<br>` blocks for
  CONSORT exclusion boxes and PRISMA reasons boxes.

- [`geom_consort()`](https://tgerke.github.io/ggconsort/reference/geom_consort.md)
  gains styling parameters: `family` (font), `linewidth` (box borders,
  with arrows scaled in proportion), `box_r` (corner radius),
  `box_padding`, `arrow_length` (arrow head size), `row_gap`, and
  `equal_columns` (draw every box in a column at the width of the
  column’s widest box, matching the uniform boxes of the official
  templates).

- [`consort_box_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md)
  gains per-box `fill`, `color`, and `text_color` overrides for
  highlighting individual boxes.

- [`consort_stage_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md)
  accepts a length-2 `col` to span columns, e.g.
  `col = c("main", "side")` for a PRISMA 2020 header bar.

- `trial_data` gains follow-up and analysis indicators
  (`lost_to_followup`, `discontinued`, `not_analyzed`) so a complete
  four-stage CONSORT diagram can be built from the bundled data.

### Bug fixes

- [`cohort_label()`](https://tgerke.github.io/ggconsort/reference/cohort_label.md)
  now errors informatively when a label is not a single (non-NA) string,
  instead of accepting values that fail later at plot time.

### Documentation

- New pkgdown article building a complete four-stage CONSORT diagram
  (Enrollment, Allocation, Follow-up, Analysis) with margin stage
  labels.

- The PRISMA article now includes the official template’s spanning
  header bar and uniform column widths; README and reference examples
  use the automatic box labels and
  [`cohort_count_bullets()`](https://tgerke.github.io/ggconsort/reference/cohort_count.md).

## ggconsort 0.3.0

### New features

- [`consort_box_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md)
  gains a row/column layout: declare `row` and `col` (`"main"`,
  `"side"`, `"left"`, or a number) instead of `x`/`y` coordinates, and
  the diagram is laid out at draw time from the measured box sizes — row
  gaps are equalized, columns are spread so nothing overlaps or clips,
  and the layout adapts to the device size. Explicit coordinates remain
  fully supported.

- In a row/column layout,
  [`consort_arrow_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md)
  needs only `start` and `end` box names: boxes in the same column
  connect vertically, boxes in the same row horizontally, boxes
  elsewhere by a branch off the start box’s column. A vector `end`
  (e.g. `end = c("arm_a", "arm_b")`) draws the classic T-split into
  study arms in one call.

- New
  [`consort_stage_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md)
  adds stage badges (“Allocation”, “Identification”, …) to a row/column
  layout, vertically centered on a row or a span of rows, with optional
  rotation (`angle = 90`) for PRISMA-style margin labels.

- [`geom_consort()`](https://tgerke.github.io/ggconsort/reference/geom_consort.md)
  is now a single layer that measures each box on the open graphics
  device at draw time. Boxes are placed exactly at their (`x`, `y`)
  coordinates (centered by default, or per user-supplied
  `hjust`/`vjust`), and arrows start and end precisely at the measured
  box edges instead of being anchored at box centers. Diagrams no longer
  depend on justification tricks to fake edge attachment, and
  connections stay correct at any device size. The previous layers
  remain available as
  [`geom_consort_box()`](https://tgerke.github.io/ggconsort/reference/geom_consort.md)
  and
  [`geom_consort_arrow()`](https://tgerke.github.io/ggconsort/reference/geom_consort.md).

- Boxes that receive an arrow are no longer shifted by inferred
  justification; a box entered from the left keeps its position and only
  left-aligns if you ask for `hjust = 0`. Set `hjust`/`vjust` explicitly
  where the old inference was load-bearing.

## ggconsort 0.2.0

### New features

- [`consort_box_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md)
  gains optional `hjust` and `vjust` arguments to set the text
  justification of an individual box, overriding the default inference
  from connected arrows
  ([\#24](https://github.com/tgerke/ggconsort/issues/24)).

- [`geom_consort_box()`](https://tgerke.github.io/ggconsort/reference/geom_consort.md)
  (and therefore
  [`geom_consort()`](https://tgerke.github.io/ggconsort/reference/geom_consort.md))
  now applies its `label_size`, `label_color`, and `label_height`
  arguments, so box text can be resized and recolored, and forwards
  `...` to
  [`ggtext::geom_richtext()`](https://wilkelab.org/ggtext/reference/geom_richtext.html)
  ([\#18](https://github.com/tgerke/ggconsort/issues/18)).

- [`cohort_count_adorn()`](https://tgerke.github.io/ggconsort/reference/cohort_count.md)
  formats counts with comma separators by default,
  e.g. `"Randomized (n = 5,932,291)"`. Use the `.label_fn` argument for
  custom formats
  ([\#23](https://github.com/tgerke/ggconsort/issues/23)).

- [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) now
  works directly on a `ggconsort` object via a new `grid.draw()` method
  ([\#26](https://github.com/tgerke/ggconsort/issues/26)).

- New pkgdown article showing how to build a PRISMA 2020 flow diagram
  ([\#14](https://github.com/tgerke/ggconsort/issues/14)).

### Bug fixes

- [`create_consort_data()`](https://tgerke.github.io/ggconsort/reference/create_consort_data.md)
  no longer errors on a diagram with no arrows or no lines
  ([\#21](https://github.com/tgerke/ggconsort/issues/21),
  [\#22](https://github.com/tgerke/ggconsort/issues/22), thanks
  [@jrealgatius](https://github.com/jrealgatius)).

- Arrows and lines use `linewidth` instead of the `size` aesthetic
  deprecated in ggplot2 3.4.0; ggconsort now requires ggplot2 \>= 3.4.0
  ([\#28](https://github.com/tgerke/ggconsort/issues/28)).

- [`plot()`](https://rdrr.io/r/graphics/plot.default.html) on a
  `ggconsort` object now passes its `margin_h` and `margin_v` arguments
  through to
  [`theme_consort()`](https://tgerke.github.io/ggconsort/reference/theme_consort.md).

- A box with several incoming arrows is no longer drawn once per arrow;
  its text justification is inferred across all entry sides.
  [`create_consort_data()`](https://tgerke.github.io/ggconsort/reference/create_consort_data.md)
  also gives an informative error when called on anything other than a
  ggconsort object.

### Documentation

- All exported functions are now documented, including
  [`consort_box_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md),
  [`consort_arrow_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md),
  [`consort_line_add()`](https://tgerke.github.io/ggconsort/reference/consort_box_add.md),
  and the
  [`geom_consort()`](https://tgerke.github.io/ggconsort/reference/geom_consort.md)
  family ([\#25](https://github.com/tgerke/ggconsort/issues/25)).

- README and reference examples consistently list arrow start arguments
  before end arguments
  ([\#15](https://github.com/tgerke/ggconsort/issues/15)).

## ggconsort 0.1.0

- Initial GitHub release.
