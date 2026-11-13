# Adapted from SU tpma_explorer repo on 12/08/2026: https://github.com/The-Strategy-Unit/tpma-explorer.
# Link to function at time of adaptation: https://github.com/The-Strategy-Unit/tpma-explorer/blob/0af6eb12060bf817ee6a12674e1c93e1ecda1bd5/R/utils_plot.R#L88
uprime_calculations <- function(df) {
  df <- dplyr::arrange(df, .data$denominator)
  
  cl <- df$national_rate[[1]] # centre line
  stdev <- sqrt(cl / df$denominator)
  z_i <- (df$rate - cl) / stdev
  mr <- abs(diff(z_i)) # moving range
  ulmr <- 3.267 * mean(mr, na.rm = TRUE) # upper-limit of moving range
  amr <- mean(mr[mr < ulmr], na.rm = TRUE) # average moving range
  sigma_z <- amr / 1.128
  sd_fn <- \(x) sqrt(cl / x) * sigma_z
  cl_fn <- \(s) \(x) cl + s * sd_fn(x)
  
  list(
    cl = cl,
    z_i = (df$rate - cl) / sd_fn(df$denominator),
    lcl3 = cl_fn(-3), # lower control limit
    ucl3 = cl_fn(3), # upper control limit
    lcl2 = cl_fn(-2),
    ucl2 = cl_fn(2)
  )
}