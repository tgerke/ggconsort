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

## Documentation

* All exported functions are now documented, including `consort_box_add()`,
  `consort_arrow_add()`, `consort_line_add()`, and the `geom_consort()`
  family (#25).

* README and reference examples consistently list arrow start arguments
  before end arguments (#15).

# ggconsort 0.1.0

* Initial GitHub release.
