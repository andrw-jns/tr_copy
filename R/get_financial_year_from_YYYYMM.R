#' Get financial year from dates in YYYYMM format.
#'
#' @param x A date in YYYYMM format. For example, 202403.
#'
#' @returns The financial year of that date in YYYYYY format.
get_financial_year_from_YYYYMM <- function(x) {
  month <- x |>
    stringr::str_sub(5, 6) |>
    as.numeric()
  
  year <- x |>
    stringr::str_sub(1, 4) |>
    as.numeric()
  
  fin_year <- ifelse(
    month < 4,
    glue::glue("{year-1}{stringr::str_sub(year, 3, 4)}"),
    glue::glue("{year}{stringr::str_sub(year + 1, 3, 4)}")
  )
  
  return(fin_year)
}