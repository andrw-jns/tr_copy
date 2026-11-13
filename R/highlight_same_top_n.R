#' Highlight diagnoses/procedures in a table that are in the top n for the
#' existing TPMA.
#'
#' @param table A flextable for the top n.
#' Also relies on `top_n_existing_codes` being in the environment, which is a 
#' vector of the top n diagnosis/procedure descriptions for the existing TPMA. 
#' I did try to have this as an argument in the function, but I could not get it
#' to work. 
#'
#' @returns A table with some rows highlighted.
highlight_same_top_n <- function(table) {
  highlighted <- table |>
    flextable::highlight(
      j = ~Description, 
      i = ~Description %in% top_n_existing_codes,
      color = "#fcdf83"
    )
  
  return(highlighted)
}