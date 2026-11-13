#' Get a table for the top n.
#' Can be used for existing and new TPMA.
#'
#' @param data A dataframe for the top n diagnoses/procedures.
#'
#' @returns A formatted table of the data.
get_top_n_table <- function(data) {
  n <- data |>
    dplyr::filter(description != "Other") |>
    nrow()
  
  table <- data |>
    dplyr::select(
      description,
      n,
      perc
    ) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::where(is.numeric),
        ~ format_numbers_for_presentation(.)
      )
    ) |>
    dplyr::rename(number_of_admissions = n) |>
    dplyr::rename_with( ~ format_as_title(.)) |>
    create_flextable() |>
    flextable::hline(i = n, border = flextable::fp_border_default()) |>
    flextable::hline(i = (n + 1),
                     border = flextable::fp_border_default(width = 3))
  
  return(table)
}