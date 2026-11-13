#' Adds grey and labelled box for COVID-19 pandemic.
#'
#' @param plot A ggplot.
#' @param max_y The max y value.
#' @param text_size Font size for label. Default is 0.5.
#'
#' @returns A plot with COVID-19 box added.
add_covid_box_to_plot <- function(plot, max_y, text_size = 0.5){
  
  annotated <- plot +
    ggplot2::geom_rect(
      ggplot2::aes(NULL, NULL, xmin = "2019/20", xmax = "2021/22"),
      ymin = 0,
      ymax = max_y * 1.1,
      fill = "#686f73",
      colour = NA,
      size = text_size,
      alpha = 0.01
    ) +
    ggplot2::annotate(
      "text",
      x = "2020/21",
      y = max_y * 1.08,
      label = "COVID-19 pandemic",
      size = 2.7
    )
  
  return(annotated)
}