
#' Transform object to popup
#' @title makePopup
#' @param x Object representing the popup
#' @param data The dataset
#' @rdname makePopup
#' @export
makePopup <-  function(x, data) {
  UseMethod("makePopup", x)
}

#' @export
makePopup.formula <- function(x, data) {
  leaflet::evalFormula(x, data)
}

#' @export
makePopup.character <- function(x, data) {
  if (all(x %in% names(data))) {
    if (length(x) == 1) {
      data[[x]]
    } else {
      names <- x
      x <- do.call(cbind, lapply(x, function(x) .subset2(data, x)))
      colnames(x) <- names
      makePopup(x, data)
    }
  } else {
    checkDimPop(x, data)
  }
}

#' @export
makePopup.shiny.tag <- function(x, data) {
  x <- as.character(x)
  x <- checkDimPop(x, data)
  # if (length(x) == 1) {
    htmltools::HTML(x)
  # } else {
  #   lapply(x, htmltools::HTML)
  # }
}

#' @export
makePopup.matrix <- function(x, data) {
  names_x <- colnames(x)
  x <- apply(x, 1, function(x)
    paste0("<b>", names_x, "</b>: ", x,
          collapse = "<br>"))
  checkDimPop(x, data)
}
#' @export
makePopup.data.frame <- makePopup.matrix

#' @export
makePopup.sf <- function(x, data) {
  x <- data.frame(x)
  ## Remove Geometry Columns ???
  x[,"geometry"] <- NULL
  x[,"latitude"] <- NULL
  x[,"longitude"] <- NULL
  x[,"optional"] <- NULL
  ## Feed back to method
  makePopup(x, data)
}
#' @export
makePopup.Spatial <- makePopup.sf

#' @export
makePopup.logical <- function(x, data) {
  if (x == TRUE) {
    makePopup(data, data)
  } else {
    return(NULL)
  }
}

#' @export
makePopup.list <- function(x, data) {
  x <- do.call(cbind, x)
  makePopup(x, data)
}

#' @export
makePopup.json <- function(x, data) {
  x <- jsonify::from_json(x)
  makePopup(x, data)
}

#' @export
makePopup.default <- function(x, data) {
  x <- as.character(x)
  makePopup(x, data)
}



#' checkDim
#' @description Check the length of the popup vector. It must match the
#'   number of rows of the dataset.
#' @param x The popup vector
#' @param data The dataset
checkDimPop <- function(x, data) {
  if (inherits(data, "sfc")) nro_d = length(data) else nro_d = nrow(data)
  len_x <- length(x)
  if (len_x != nro_d) {
    warning("Length of popups does not match number of data rows.\n",
            "  The vector is repeated to match the number of rows.")
    x <- rep(x, ceiling(nro_d / len_x))[1:nro_d]
  }
  return(x)
}

