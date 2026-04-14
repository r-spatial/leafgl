# makeColorMatrix

Transform object to rgb color matrix

## Usage

``` r
makeColorMatrix(x, data, palette, ...)
```

## Arguments

- x:

  Object representing the color. Can be of class integer, numeric, Date,
  POSIX\*, character with color names or HEX codes, factor, matrix,
  data.frame, list, json or formula.

- data:

  The dataset

- palette:

  Name of a color palette. If `colourvalues` is installed, it is passed
  to
  [`colour_values_rgb`](https://symbolixau.github.io/colourvalues/reference/colour_values_rgb.html).
  To see all available palettes, please use
  [`colour_palettes`](https://symbolixau.github.io/colourvalues/reference/colour_palettes.html).
  If `colourvalues` is not installed, the palette is passed to
  [`colorNumeric`](https://rstudio.github.io/leaflet/reference/colorNumeric.html).

- ...:

  Passed to
  [`colour_palettes`](https://symbolixau.github.io/colourvalues/reference/colour_palettes.html)
  or
  [`colorNumeric`](https://rstudio.github.io/leaflet/reference/colorNumeric.html).

## Examples

``` r
{
## For Integer/Numeric/Factor
makeColorMatrix(23L)
makeColorMatrix(23)
makeColorMatrix(as.factor(23))

## For POSIXt / Date
makeColorMatrix(as.POSIXlt(Sys.time(), "America/New_York"), NULL)
makeColorMatrix(Sys.time(), NULL)
makeColorMatrix(Sys.Date(), NULL)

## For matrix/data.frame
makeColorMatrix(cbind(130,1,1), NULL)
makeColorMatrix(matrix(1:99, ncol = 3, byrow = TRUE), data.frame(x=c(1:33)))
makeColorMatrix(data.frame(matrix(1:99, ncol = 3, byrow = TRUE)), data.frame(x=c(1:33)))

## For characters
testdf <- data.frame(
  texts = LETTERS[1:10],
  vals = 1:10,
  vals1 = 11:20
)
makeColorMatrix("red", testdf)
makeColorMatrix("val", testdf)

## For formulaes
makeColorMatrix(~vals, testdf)
makeColorMatrix(~vals1, testdf)

## For JSON
makeColorMatrix(leafgl:::yyson_json_str(data.frame(r = 54, g = 186, b = 1)), NULL)

## For Lists
makeColorMatrix(list(1,2), data.frame(x=c(1,2)))
}
#>           [,1]        [,2]      [,3]
#> [1,] 0.2666667 0.003921569 0.3294118
#> [2,] 0.9921569 0.905882353 0.1450980
```
