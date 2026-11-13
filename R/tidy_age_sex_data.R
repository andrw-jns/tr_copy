#' Tidy age and sex data for population pyramid.
#'
#' @param data A dataframe of counts by age band and sex.
#' @param small_number_suppression_limit The cutoff for small number suppression.
#'
#' @returns The data with small numbers suppressed and age band and sex columns 
#' formatted for a population pyramid.
tidy_age_sex_data <- function(data, small_number_suppression_limit) {
  tidied <- data |> 
    dplyr::filter(sex %in% c(1, 2), !is.na(age_band)) |>
    dplyr::mutate(
      sex = ifelse(sex == 2, -1, 1), 
      # suppress small numbers and make negative values to plot on both sides 
      # of x axis:
      n = ifelse(n <= small_number_suppression_limit, NA, sex * n),
      sex = factor(sex, levels = c(-1, 1), labels = c("Female", "Male")),
      age_band = factor(
        age_band,
        levels = c(
          "0-4", "5-9", "10-14", "15-19", "15-17", "16-19", "18-19", "20-24", "25-29", 
          "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", 
          "65-69", "70-74", "75-79", "80-84", "85-89", "90+"))
    )
  
  return(tidied)
}