# ggconsort (development version)

## New features

* `geom_consort()` is now a single layer that measures each box on the open
  graphics device at draw time. Boxes are placed exactly at their (`x`, `y`)
  coordinates (centered by default, or per user-supplied `hjust`/`vjust`),
  and arrows start and end precisely at the measured box edges instead of
  being anchored at box centers. Diagrams no longer depend on justification
  tricks to fake edge attachment, and connections stay correct at any device
  size. The previous layers remain available as `geom_consort_box()` and
  `geom_consort_arrow()`.

* Boxes that receive an arrow are no longer shifted by inferred justification;
  a box entered from the left keeps its position and only left-aligns if you
  ask for `hjust = 0`. Set `hjust`/`vjust` explicitly where the old inference
  was load-bearing.

# ggconsort 0.2.0

## New features

* `consort_box_add()` gains optional `hjust` and `vjust` arguments to set the
  text justification of an individual box, overriding the default inference
  from connected arrows (#24).

* `geom_consort_box()` (and therefore `geom_consort()`) now applies its
  `label_size`, `label_color`, and `label_height` arguments, so box text can
  be resized and recolored, and forwards `...` to `ggtext::geom_richtext()`
  (#18).

* `cohort_count_adorn()` formats counts with comma separators by default,
  e.g. `"Randomized (n = 5,932,291)"`. Use the `.label_fn` argument for
  custom formats (#23).

* `ggsave()` now works directly on a `ggconsort` object via a new
  `grid.draw()` method (#26).

* New pkgdown article showing how to build a PRISMA 2020 flow diagram (#14).

## Bug fixes

* `create_consort_data()` no longer errors on a diagram with no arrows or no
  lines (#21, #22, thanks @jrealgatius).

* Arrows and lines use `linewidth` instead of the `size` aesthetic deprecated
  in ggplot2 3.4.0; ggconsort now requires ggplot2 >= 3.4.0 (#28).

* `plot()` on a `ggconsort` object now passes its `margin_h` and `margin_v`
  arguments through to `theme_consort()`.

* A box with several incoming arrows is no longer drawn once per arrow; its
  text justification is inferred across all entry sides. `create_consort_data()`
  also gives an informative error when called on anything other than a
  ggconsort object.

## Documentation

* All exported functions are now documented, including `consort_box_add()`,
  `consort_arrow_add()`, `consort_line_add()`, and the `geom_consort()`
  family (#25).

* README and reference examples consistently list arrow start arguments
  before end arguments (#15).

# ggconsort 0.1.0

* Initial GitHub release.
