# Minimal theme for CONSORT diagrams

A wrapper around
[`ggplot2::theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
that adds plot margins, so diagram boxes near the edges are not clipped.

## Usage

``` r
theme_consort(margin_h = 0, margin_v = 0, margin_unit = "line")
```

## Arguments

- margin_h, margin_v:

  Horizontal and vertical plot margins.

- margin_unit:

  Unit of the margins, passed to
  [`ggplot2::margin()`](https://ggplot2.tidyverse.org/reference/element.html).

## Value

A ggplot2 theme object.

## Examples

``` r
# see ?geom_consort for a complete diagram example
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_consort(margin_h = 8, margin_v = 1)
```
