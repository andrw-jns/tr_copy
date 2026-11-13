#' Formats a string into a title for tables and plots.
#'
#' @param col_name A string.
#'
#' @return A string.
format_as_title <- function(col_name) {
  title <- col_name |>
    stringr::str_replace_all("_", " ") |>
    stringr::str_to_sentence() |>
    stringr::str_replace_all(
      c("Pod" = "Point of delivery",
        "Perc" = "Percentage",
        "Tpma" = "TPMA")
    )
  
  return(title)
}