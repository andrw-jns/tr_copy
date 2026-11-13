# Adapted from SU tpma_explorer repo on 12/08/2026: https://github.com/The-Strategy-Unit/tpma-explorer.
# Link to function at time of adaptation: https://github.com/The-Strategy-Unit/tpma-explorer/blob/0af6eb12060bf817ee6a12674e1c93e1ecda1bd5/R/fct_plots.R#L65
plot_rates_funnel <- function(
    rates_funnel_data,
    funnel_calculations,
    y_axis_limits
) {
  rates_funnel_data <- rates_funnel_data |>
    dplyr::mutate(
      lower_cl_outlier = rate <= funnel_calculations$lcl3(denominator),
      upper_cl_outlier = rate >= funnel_calculations$ucl3(denominator),
      outlier = lower_cl_outlier | upper_cl_outlier
    )
  
  cl_line_type <- cl2_line_type <- cl3_line_type <- "dashed"
  cl_colour <- cl2_colour <- cl3_colour <- "#9d928a"
  
  plot_x_range <- c(0, max(rates_funnel_data[["denominator"]]) * 1.05)
  function_x_range <- plot_x_range * 1.2
  
  rates_funnel_data |>
    ggplot2::ggplot(ggplot2::aes(.data[["denominator"]], .data[["rate"]])) +
    ggplot2::geom_hline(
      yintercept = funnel_calculations[["cl"]],
      colour = cl_colour,
      linetype = cl_line_type
    ) +
    ggplot2::geom_function(
      fun = funnel_calculations[["lcl2"]],
      colour = cl2_colour,
      linetype = cl2_line_type,
      xlim = function_x_range,
      n = 1001
    ) +
    ggplot2::geom_function(
      fun = funnel_calculations[["ucl2"]],
      colour = cl2_colour,
      linetype = cl2_line_type,
      xlim = function_x_range,
      n = 1001
    ) +
    ggplot2::geom_function(
      fun = funnel_calculations[["lcl3"]],
      colour = cl3_colour,
      linetype = cl3_line_type,
      xlim = function_x_range,
      n = 1001
    ) +
    ggplot2::geom_function(
      fun = funnel_calculations[["ucl3"]],
      colour = cl3_colour,
      linetype = cl3_line_type,
      xlim = function_x_range,
      n = 1001
    ) +
    ggplot2::geom_point(
      ggplot2::aes(
        colour = .data[["outlier"]]),
      shape = 21
    ) +
    ggrepel::geom_text_repel(
      data = dplyr::filter(
        rates_funnel_data,
        .data[["outlier"]]
      ),
      ggplot2::aes(
        label = .data[["lad23nm"]],
        colour = .data[["outlier"]]
      ),
      max.overlaps = Inf # include all labels
    ) +
    ggplot2::scale_colour_manual(
      values = c(
        "FALSE" = scales::alpha("#2c2825", 1),
        "TRUE" = scales::alpha("#ec6555", 1)
      )
    ) +
    ggplot2::scale_x_continuous(
      labels = scales::comma_format(),
      guide = ggplot2::guide_axis(check.overlap = TRUE)
    ) +
    ggplot2::coord_cartesian(xlim = plot_x_range, ylim = y_axis_limits) +
    ggplot2::labs(
      x = "Catchment population of local authority"
    ) +
    StrategyUnitTheme::su_theme() +
    ggplot2::theme(legend.position = "none") 
}
