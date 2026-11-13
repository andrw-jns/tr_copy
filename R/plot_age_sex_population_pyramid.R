#' Plot the age and sex population pyramid.
#'
#' @param data A dataframe of total activity by age band and sex.
#'
#' @returns A plot of the age and sex population pyramid.
plot_age_sex_population_pyramid <- function(data) {
  plot <- data |>
    ggplot2::ggplot() +
    ggplot2::aes(x = n, y = age_band, fill = sex, col = sex) +
    ggplot2::geom_col(position = "stack", width = 1, alpha = 0.7) +
    ggplot2::labs(x = "Number of admissions",
                  y = "Age band") +
    ggplot2::guides(fill = ggplot2::guide_legend("Sex"),
                    colour = ggplot2::guide_legend("Sex")) +
    ggplot2::scale_x_continuous(labels = purrr::compose(scales::comma, abs)) +
    StrategyUnitTheme::su_theme() +
    StrategyUnitTheme::scale_fill_su(palette = "charcoals") +
    StrategyUnitTheme::scale_colour_su(palette = "charcoals") +
    ggplot2::theme(legend.position = "bottom")
  
  return(plot)
}