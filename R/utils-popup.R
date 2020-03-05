
#' Transform object to popup
#' @title make_popup
#' @param x Object representing the popup
#' @param data The dataset
#' @rdname make_popup
#' @export
make_popup <-  function(x, data) {
  UseMethod("make_popup", x)
}

#' @export
make_popup.formula <- function(x, data) {
  leaflet::evalFormula(x, data)
}

#' @export
make_popup.character <- function(x, data) {
  if (all(x %in% names(data))) {
    if (length(x) == 1) {
      data[[x]]
    } else {
      names <- x
      x <- do.call(cbind, lapply(x, function(x) .subset2(data, x)))
      colnames(x) <- names
      make_popup(x, data)
    }
  } else {
    checkDimPop(x, data)
  }
}

#' @export
make_popup.shiny.tag <- function(x, data) {
  x <- as.character(x)
  x <- checkDimPop(x, data)
  # if (length(x) == 1) {
    htmltools::HTML(x)
  # } else {
  #   lapply(x, htmltools::HTML)
  # }
}

#' @export
make_popup.matrix <- function(x, data) {
  names_x <- colnames(x)
  x <- apply(x, 1, function(x)
    paste0("<b>", names_x, "</b>: ", x,
          collapse = "<br>"))
  checkDimPop(x, data)
}
#' @export
make_popup.data.frame <- make_popup.matrix

#' @export
make_popup.sf <- function(x, data) {
  x <- data.frame(x)
  ## Remove Geometry Columns ???
  x[,"geometry"] <- NULL
  x[,"latitude"] <- NULL
  x[,"longitude"] <- NULL
  x[,"optional"] <- NULL
  ## Feed back to method
  make_popup(x, data)
}
#' @export
make_popup.Spatial <- make_popup.sf

#' @export
make_popup.logical <- function(x, data) {
  if (x == TRUE) {
    make_popup(data, data)
  } else {
    return(NULL)
  }
}

#' @export
make_popup.list <- function(x, data) {
  x <- do.call(cbind, x)
  make_popup(x, data)
}

#' @export
make_popup.json <- function(x, data) {
  x <- jsonify::from_json(x)
  make_popup(x, data)
}

#' @export
make_popup.default <- function(x, data) {
  x <- as.character(x)
  make_popup(x, data)
}



#' checkDim
#' @description Check the length of the popup vector. It must match the
#'   number of rows of the dataset.
#' @param x The popup vector
#' @param data The dataset
checkDimPop <- function(x, data) {
  nro_d <- nrow(data)
  len_x <- length(x)
  if (len_x != nro_d) {
    warning("Length of popups does not match number of data rows.\n",
            "  The vector is repeated to match the number of rows.")
    x <- rep(x, ceiling(nro_d / len_x))[1:nro_d]
  }
  return(x)
}

