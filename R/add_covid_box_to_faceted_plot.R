#' Adds grey and labelled box for COVID-19 pandemic.
#'
#' @param plot A ggplot.
#' @param max_y A dataframe of max y values.
#' @param text_size Font size for label. Default is 0.5.
#'
#' @returns A plot with COVID-19 box added.
add_covid_box_to_faceted_plot <- function(plot, max_y, text_size = 0.5){
  
  annotated <- plot +
    ggplot2::geom_rect(
      data = max_y,
      ggplot2::aes(
        ymin = 0, 
        ymax = ymax * 1.1, 
        xmin = "2019/20", 
        xmax = "2021/22",
        x = NULL, 
        y = NULL
        ),
      fill = "#686f73",
      colour = NA,
      size = text_size,
      alpha = 0.2
    ) +
    ggplot2::geom_text(
      data = max_y,
      ggplot2::aes(x = "2020/21", y = ymax * 1.08, label = "COVID-19 pandemic"),
      size = 2.7
    )
  
  return(annotated)
}
