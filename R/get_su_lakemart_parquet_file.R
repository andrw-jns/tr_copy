# Adapted from 
# https://github.com/The-Strategy-Unit/nnhip_index_and_scorecard/blob/main/R/utils.R
# on 06/08/2026.

#' Get a Strategy Unit LakeMart Parquet File
#'
#' @description
#' Retrieves and consolidates all indvidual `part-*` files from a Parquet
#' dataset stored in the Strategy Unit LakeMart area of UDAL, returning the
#' combined data as a single tibble.
#'
#' @details
#' This function relies on several environment variables to construct the
#' connection path and authenticate against Azure Data Lake Storage (ADLS).
#' These must be available in the R session before calling the function.
#'
#' @section Required environment variables:
#' The following environment variables must be set (e.g. via `.Renviron`,
#' `Sys.setenv()`, or your project settings):
#'
#' - **`container`** - the ADLS container name
#' - **`lake`** - the ADLS account name including domain name
#' - **`folder`** - the folder path within the container where the Parquet
#' files reside.
#' - **`azure_key_vault`** - The name of the Azure Key Vault containing SAS
#' tokens.
#'
#' The function expects a read-access SAS token stored in Key Vault under the
#' name: `"alp-{container}-StrategyUnit-r"`.
#'
#' @section How file matching works:
#' The `str_file_pattern` argument is used to filter file names returned from
#' ADLS. It should match part of the Parquet dataset path, for example:
#' ```
#' "matching_referrals.parquet/part"
#' ```
#' All matching Parquet files are downloaded and read using
#' `arrow::read_parquet()`, then combined row-wise into a single tibble.
#'
#' @section Error handling:
#' The function performs several validation checks and will abort with a clear
#' diagnostic message if:
#' - required environment variables are missing or empty,
#' - the Azure Key Vault cannot be accessed,
#' - the expected SAS token is not found in Key Vault,
#' - no files match the supplied `str_file_pattern`
#'
#' These checks are intended to make configuration issues easier to diagnose.
#'
#' @param str_file_pattern String. A substring used to identify the Parquet dataset within the Strategy Unit LakeMart folder structure.
#'
#' @returns A tibble containing the combined data from all matching Parquet part files.
#'
#' @examples
#' \dontrun{
#' df <- get_su_lakemart_parquet_file("matching_referrals.parquet/part")
#' }
get_su_lakemart_parquet_file <- function(str_file_pattern = "", az_files, az_container) {
  # ensure a file pattern was supplied
  if (nchar(str_file_pattern) == 0) {
    cli::cli_abort(
      "{.var str_file_pattern} must be a string matching part of a parquet file, e.g. {.val matching_referrals.parquet/part}"
    )
  }
  
  # identify parquet files in the matching_variables folder
  requested_file <-
    az_files |>
    tibble::as_tibble() |>
    dplyr::filter(stringr::str_detect(
      string = name,
      pattern = str_file_pattern
    )) |>
    dplyr::pull(name)
  
  if (length(requested_file) == 0) {
    cli::cli_abort(
      "No files found matching pattern {.val {str_file_pattern}} in folder {.val {folder}}."
    )
  }
  
  # read all parquet files to a single df
  df_return <-
    purrr::map_dfr(
      .x = requested_file,
      .f = \(.x) {
        AzureStor::storage_download(
          container = az_container,
          src = .x,
          dest = NULL
        ) |>
          arrow::read_parquet()
      }
    )
  
  # return the df
  return(df_return)
}