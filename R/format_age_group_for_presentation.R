#' Formats age group for presentation.
#'
#' @param string A string for an age group.
#'
#' @returns A string of the age group like "x-y" or "65 plus".
format_age_group_for_presentation <- function(string) {
  formatted <- string |>
    stringr::str_replace_all(c(
      "65_plus" = "65+", 
      "_" = "-"
      )) |>
    format_as_title()
  
  return(formatted)
}