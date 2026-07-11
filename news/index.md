# Changelog

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
