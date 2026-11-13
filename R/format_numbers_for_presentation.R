#' Formats numbers for presentation.
#'
#' @param number A number.
#'
#' @returns A string of the number rounded to 2 decimal places and with commas.
format_numbers_for_presentation <- function(number) {
  formatted <- number |>
    janitor::round_half_up(2) |>
    prettyNum(big.mark = ",")
  
  return(formatted)
}