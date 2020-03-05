
#' Transform object to rgb color matrix
#' @title make_color_matrix
#' @param x Object representing the color. Can be of class integer, numeric, Date,
#'   POSIX*, character with color names or HEX codes, factor, matrix, data.frame,
#'   list, json or formula.
#' @param data The dataset
#' @param palette Name of a color palette. If \code{colourvalues} is installed, it is
#'   passed to \code{\link[colourvalues]{colour_values_rgb}}. To see all available
#'   palettes, please use \code{\link[colourvalues]{colour_palettes}}.
#'   If \code{colourvalues} is not installed, the palette is passed to
#'   \code{\link[leaflet]{colorNumeric}}.
#' @param ... Passed to \code{\link[colourvalues]{colour_palettes}} or
#'   \code{\link[leaflet]{colorNumeric}}.
#' @rdname make_color_matrix
#' @export
#' @examples {
#' ## For Integer/Numeric/Factor
#' make_color_matrix(23L)
#' make_color_matrix(23)
#' make_color_matrix(as.factor(23))
#'
#' ## For POSIXt / Date
#' make_color_matrix(as.POSIXlt(Sys.time(), "America/New_York"), NULL)
#' make_color_matrix(Sys.time(), NULL)
#' make_color_matrix(Sys.Date(), NULL)
#'
#' ## For matrix/data.frame
#' make_color_matrix(cbind(130,1,1), NULL)
#' make_color_matrix(matrix(1:99, ncol = 3, byrow = TRUE), data.frame(x=c(1:33)))
#' make_color_matrix(data.frame(matrix(1:99, ncol = 3, byrow = TRUE)), data.frame(x=c(1:33)))
#'
#' ## For characters
#' library(leaflet)
#' make_color_matrix("red", breweries91)
#' make_color_matrix("blue", breweries91)
#' make_color_matrix("#36ba01", breweries91)
#' make_color_matrix("founded", data.frame(breweries91))
#'
#' ## For formulaes
#' make_color_matrix(~founded, breweries91)
#' make_color_matrix(~founded + zipcode, breweries91)
#'
#' ## For JSON
#' library(jsonify)
#' make_color_matrix(jsonify::to_json(data.frame(r = 54, g = 186, b = 1)), NULL)
#'
#' ## For Lists
#' make_color_matrix(list(1,2), data.frame(x=c(1,2)))
#' }
make_color_matrix <-  function(x, data, palette, ...) {
  UseMethod("make_color_matrix", x)
}

#' @export
make_color_matrix.integer <- function(x, data = NULL, palette = "viridis", ...) {
  if (requireNamespace("colourvalues", quietly = TRUE)) {
    x <- checkDim(x, data)
    colourvalues::colour_values_rgb(x,
                                    palette = palette,
                                    include_alpha = FALSE, ...) / 255
  } else {
    if (length(x) == 1) {
      x <- grDevices::colors()[x]
      t(grDevices::col2rgb(x, alpha = FALSE)) / 255
    } else {
      x <- checkDim(x, data)
      pal <- leaflet::colorNumeric(palette, x, alpha = FALSE, ...)
      t(grDevices::col2rgb(pal(x), alpha = FALSE)) / 255
    }
  }
}
#' @export
make_color_matrix.numeric <- make_color_matrix.integer

#' @export
make_color_matrix.factor <- function(x, data = NULL, palette = "viridis", ...) {
  x <- tryCatch(as.integer(as.character(as.factor(x))),
                error = function(e) as.numeric(as.factor(x)),
                warning = function(e) as.numeric(as.factor(x)),
                finally = function(e) stop("Cannot process factor."))

  make_color_matrix(x, data, palette, ...)
}

#' @export
make_color_matrix.formula <- function(x, data, palette = "viridis", ...) {
  x <- leaflet::evalFormula(x, data)
  make_color_matrix(x, data, palette, ...)
}

#' @export
make_color_matrix.character <- function(x, data, palette = "viridis", ...) {
  ## If x is a column name, take the column values and feed method again
  if (length(x) == 1 && x %in% colnames(data)) {
    x <- data[[x]]
    return(make_color_matrix(x, data, palette, ...))
  }
  ## Otherwise we assume its a color-name / HEX-code.
  ## If that errors, convert to integer/factor, and feed back
  x <- checkDim(x, data)
  col <- tryCatch(t(grDevices::col2rgb(x)) / 255,
           error = function(e) {
             x <- as.integer(as.factor(x))
             make_color_matrix(x, data, palette, ...)
           }
  )
  col
}

#' @export
make_color_matrix.matrix <- function(x, data, palette = "viridis", ...) {
  if (all(apply(x, 2, class) == "character")) {
    x <- matrix(apply(x, 2, as.numeric), ncol = 3)
  }
  x <- checkDim(x, data)
  if (any(x > 1)) {
    x / 255
  } else {
    x
  }
}
#' @export
make_color_matrix.data.frame <- make_color_matrix.matrix

#' @export
make_color_matrix.list <- function(x, data = NULL, palette = "viridis", ...) {
  classes <- lapply(x, class)
  if (all(classes == "numeric")) {
    x <- unlist(x)
  } else if (all(classes == "matrix")) {
    x <- do.call(rbind, x)
  } else {
    x <- as.numeric(unlist(x))
  }
  make_color_matrix(x, data, palette, ...)
}

#' @export
make_color_matrix.json <- function(x, data = NULL, palette = "viridis", ...) {
  x <- jsonify::from_json(x)
  make_color_matrix(x, data, palette, ...)
}

#' @export
make_color_matrix.Date <- function(x, data = NULL, palette = "viridis", ...) {
  x <- as.numeric(x)
  make_color_matrix(x, data, palette, ...)
}
#' @export
make_color_matrix.POSIXct <- make_color_matrix.Date
#' @export
make_color_matrix.POSIXlt <- make_color_matrix.Date



#' checkDim
#' @description Check the length of the color vector. It must match the
#'   number of rows of the dataset.
#' @param x The color vector
#' @param data The dataset
checkDim <- function(x, data) {
  nro_d <- nrow(data)
  if (inherits(x, "matrix") || inherits(x, "data.frame")) {
    if (nrow(x) != 1 && nro_d != nrow(x)) {
      warning("Number of rows of color matrix does not match number of data rows.\n",
              "  Just the first row is taken.")
      x <- x[1,,drop = FALSE]
    }
  } else {
    len_x <- length(x)
    if ((length(x) != 1) && (len_x != nro_d)) {
      warning("Length of color vector does not match number of data rows.\n",
              "  The vector is repeated to match the number of rows.")
      x <- rep(x, ceiling(nro_d / len_x))[1:nro_d]
    }
  }
  return(x)
}

