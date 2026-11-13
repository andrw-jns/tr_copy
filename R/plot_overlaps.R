#' Plot percentage of admissions that overlap with other TPMA.
#'
#' @param data A dataframe of the overlaps data.
#'
#' @returns A plot of the percentage of admissions that overlap with other TPMA.
plot_overlaps <- function(data) {
  data <- data |>
    dplyr::filter(!is.na(n))
  
  xmax <- max(data$perc, na.rm = TRUE) * 1.2
  
  data_existing <- data |>
    dplyr::filter(status == "existing") |>
    dplyr::select(tpma_full_name, existing_perc = perc, existing_n = n)
  
  plot <- data |>
    dplyr::filter(status == "new", perc >= 1) |>
    dplyr::left_join(data_existing, "tpma_full_name") |>
    ggplot2::ggplot() +
    ggplot2::aes(x = perc, y = reorder(tpma_full_name, perc), fill = status) +
    ggplot2::geom_col(position = ggplot2::position_dodge(1)) +
    ggplot2::geom_text(ggplot2::aes(
      label = glue::glue("{perc}% ({prettyNum(n, big.mark = ',')})")),
      hjust = -0.1, 
      size = 2.8
    ) +
    ggplot2::geom_point(
      ggplot2::aes(x = existing_perc, 
                   y = reorder(tpma_full_name, perc),
                   col = "existing"
                   ),
      size = 3
    ) +
    ggplot2::facet_wrap(~tpma_mechanism, ncol = 1, scales = "free_y") +
    ggplot2::xlim(0, xmax) +
    ggplot2::labs(x = "Percentage of emergency readmissions",
                  y = "TPMA") +
    StrategyUnitTheme::su_theme() +
    ggplot2::scale_fill_manual(values = colours) +
    ggplot2::scale_color_manual(values = colours) +
    ggplot2::theme(legend.position = "none")
  
  return(plot)
}