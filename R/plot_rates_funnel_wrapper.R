#' Wrapper for funnel plotting functions.
#'
#' @param data A dataframe of age and sex standardised rates by LA.
#'
#' @returns A funnel plot of LA age and sex standardised rates by catchment population.
plot_rates_funnel_wrapper <- function(data) {
  data_national <- data |>
    dplyr::filter(lad23cd == "national") |>
    dplyr::pull(std_rate)
  
  funnel_calculations <- data |>
    dplyr::filter_out(lad23cd == "national") |>
    dplyr::mutate(national_rate = data_national) |>
    dplyr::rename(rate = std_rate) |>
    uprime_calculations()
  
  rates_funnel_data <- data |>
    dplyr::filter_out(lad23cd == "national") |>
    dplyr::rename(rate = std_rate)
  
  plot <- plot_rates_funnel(
    rates_funnel_data,
    funnel_calculations,
    y_axis_limits = c(0, max(rates_funnel_data[["rate"]]))
  )
  
  return(plot)
}