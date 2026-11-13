# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c()
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Connecting to Azure ----------------------------------------------------------
container <- Sys.getenv("container")
lake <- Sys.getenv("lake")
folder <- Sys.getenv("folder")
path <- glue::glue("abfss://{container}@{lake}{folder}")

# set up access settings 
# get shared access signature auth for data
# nb, follow any authentication directions in the console.
vault_nm <- Sys.getenv("azure_key_vault")
vault <- tryCatch(
  AzureKeyVault::key_vault(vault_nm),
  error = function(e) {
    cli::cli_abort(
      "Failed to access Azure Key Vault {.val {vault_nm}}.
        Check your authentication and network connection. \n{e$message}"
    )
  }
)

# read from lake 
sas_nm <- glue::glue("alp-{container}-StrategyUnit-r")
# get the SAS for the relevant data, r = read access, w = write access
az_sas <- tryCatch(
  vault$secrets$get(sas_nm),
  error = function(e) {
    cli::cli_abort(
      "Could not retrieve SAS token {.val {sas_nm}} from Key Vault.
        Please ensure the secret exists and you have access. \n{e$message}"
    )
  }
)

if (is.null(az_sas$value) || nchar(az_sas$value) == 0) {
  cli::cli_abort(
    "SAS token {.val {sas_name}} is empty.
      Please check the Key Vault secret configuration."
  )
}

# set connection string
az_endpoint <- AzureStor::storage_endpoint(
  glue::glue("https://{lake}"),
  sas = az_sas$value
)

# set the storage container
az_container <- AzureStor::storage_container(az_endpoint, container)

# list files in the project folder
az_files <- AzureStor::list_adls_files(az_container, folder, recursive = TRUE)

## Getting data from Azure -----------------------------------------------------
### Readmissions ---------------------------------------------------------------
readmissions_rates_raw <- get_su_lakemart_parquet_file(
  "2026_08_readmissions/readmissions_rates.parquet/part",
  az_files,
  az_container
)

readmissions_age_sex_raw <- get_su_lakemart_parquet_file(
  "readmissions_age_sex.parquet/part",
  az_files,
  az_container
)

readmissions_top_n_raw <- get_su_lakemart_parquet_file(
  "2026_08_readmissions/readmissions_top_n.parquet/part",
  az_files,
  az_container
)

readmissions_overlaps_raw <- get_su_lakemart_parquet_file(
  "2026_08_readmissions/readmissions_overlaps.parquet/part",
  az_files,
  az_container
)

readmissions_percentage_raw <- get_su_lakemart_parquet_file(
  "2026_08_readmissions/readmissions_percentage.parquet/part",
  az_files,
  az_container
)

### Mean delayed discharge -----------------------------------------------------
discharge_ready_date_complete_raw <- get_su_lakemart_parquet_file(
  "2026_09_discharge_ready_date/discharge_ready_date_complete.parquet/part",
  az_files,
  az_container
)

hes_discharge_ready_date_negative_raw <- get_su_lakemart_parquet_file(
  "2026_09_discharge_ready_date/hes_discharge_ready_date_negative.parquet/part",
  az_files,
  az_container
)

hes_early_discharge_ready_dates_raw <- get_su_lakemart_parquet_file(
  "2026_09_discharge_ready_date/hes_early_discharge_ready_dates.parquet/part",
  az_files,
  az_container
)

hes_discharge_ready_date_outliers_raw <- get_su_lakemart_parquet_file(
  "2026_09_discharge_ready_date/hes_discharge_ready_date_outliers.parquet/part",
  az_files,
  az_container
)

delayed_discharge_age_sex_raw <- get_su_lakemart_parquet_file(
  "2026_09_discharge_ready_date/delayed_discharge_age_sex.parquet/part",
  az_files,
  az_container
)

delayed_discharge_pod_raw <- get_su_lakemart_parquet_file(
  "2026_09_discharge_ready_date/delayed_discharge_pod.parquet/part",
  az_files,
  az_container
)

delayed_discharge_specialty_group_raw <- get_su_lakemart_parquet_file(
  "2026_09_discharge_ready_date/delayed_discharge_specialty_group.parquet/part",
  az_files,
  az_container
)

delayed_discharge_non_zero_raw <- get_su_lakemart_parquet_file(
  "2026_09_discharge_ready_date/delayed_discharge_non_zero.parquet/part",
  az_files,
  az_container
)

delayed_discharge_top_n_raw <- get_su_lakemart_parquet_file(
  "2026_09_discharge_ready_date/delayed_discharge_top_n.parquet/part",
  az_files,
  az_container
)

# Replace the target list below with your own:
list(
  tar_target(small_number_suppression_limit, 10),
  ## Lookups -------------------------------------------------------------------
  tar_target(
    # Local authority data from the ONS Open Geography Portal:
    # https://geoportal.statistics.gov.uk/datasets/ons::local-authority-districts-april-2023-names-and-codes-in-the-uk/about
    la_lookup_url,
    "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LAD_APR_2023_UK_NC/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson"
  ),
  tar_target(
    la_lookup,
    jsonlite::fromJSON(la_lookup_url)$features$properties |>
      as.data.frame() |>
      janitor::clean_names() |>
      dplyr::filter(stringr::str_starts(lad23cd, "E")) |>
      dplyr::select(lad23cd, lad23nm)
  ),
  tar_target(
    tpma_lookup_url,
    "https://raw.githubusercontent.com/The-Strategy-Unit/TPMAs/refs/heads/main/reference/tpma-lookup.csv"
  ),
  tar_target(
    tpma_lookup,
    readr::read_csv(tpma_lookup_url) |> 
      dplyr::mutate(
        tpma_subtype_adjusted = ifelse(is.na(tpma_subtype),
                                       "",
                                       glue::glue(" ({tpma_subtype})")),
        tpma_full_name = glue::glue("{tpma_name}{tpma_subtype_adjusted}")
      )
  ),
  tar_target(
    diagnosis_lookup,
    read.csv("reference_data/diagnoses.csv")
  ),
  tar_target(
    procedure_lookup,
    read.csv("reference_data/procedures.csv")
  ),
  ## Readmissions --------------------------------------------------------------
  tar_target(
    readmissions_rates,
    readmissions_rates_raw |>
      dplyr::mutate(n = crude_rate * denominator)
  ),
  tar_target(
    readmissions_age_sex,
    readmissions_age_sex_raw |>
      dplyr::mutate(
        age_band = dplyr::case_when(
          age_group == "0-17" & age_band == "15-19" ~ "15-17",
          age_group == "18-64" & age_band == "15-19" ~ "18-19",
          .default = age_band
        )) |>
      tidy_age_sex_data(small_number_suppression_limit)
  ),
  tar_target(
    readmissions_top_n,
    readmissions_top_n_raw |>
      get_top_n_readmissions(small_number_suppression_limit,
                             diagnosis_lookup,
                             procedure_lookup)
  ),
  tar_target(
    readmissions_overlaps,
    readmissions_overlaps_raw |>
      dplyr::mutate(
        n = ifelse(n <= small_number_suppression_limit, NA, n),
        perc = ifelse(is.na(n),
                      NA,
                      janitor::round_half_up(perc * 100, 0)
                      ),
        n = janitor::round_half_up(n, 0)
        ) |>
      dplyr::left_join(tpma_lookup,
                       by = c("strategy" = "tpma_variable")
      )
  ),
  tar_target(
    readmissions_percentage,
    readmissions_percentage_raw |>
      dplyr::group_by(status) |>
      PHEindicatormethods::phe_proportion(
        x = n_numerator,
        n = n_denominator,
        multiplier = 100
      )
  ),
  ## Mean delayed discharge ----------------------------------------------------
  tar_target(
    discharge_ready_date_complete,
    discharge_ready_date_complete_raw |>
      janitor::clean_names() |>
      dplyr::mutate(month = lubridate::ym(der_activity_month)) |>
      PHEindicatormethods::phe_proportion(
        x = has_disreadydate,
        n = number_spells,
        multiplier = 100
      )
  ),
  tar_target(
    hes_discharge_ready_date_negative,
    hes_discharge_ready_date_negative_raw |>
      janitor::clean_names()
  ),
  tar_target(
    hes_early_discharge_ready_dates,
    hes_early_discharge_ready_dates_raw |>
      janitor::clean_names() |>
      dplyr::mutate(month = lubridate::ym(der_activity_month))
  ),
  tar_target(
    hes_discharge_ready_date_outliers,
    hes_discharge_ready_date_outliers_raw |>
      janitor::clean_names() |>
      dplyr::mutate(month = lubridate::ym(der_activity_month))
  ),
  tar_target(
    delayed_discharge_age_sex,
    delayed_discharge_age_sex_raw |>
      janitor::clean_names() |>
      dplyr::mutate(month = lubridate::ym(der_activity_month)) |>
      dplyr::mutate(total_delay_duration_capped = n * delay_duration_capped)
  ),
  tar_target(
    mean_delayed_discharge_scale_2425,
    delayed_discharge_age_sex |>
      dplyr::filter(month >= as.Date("2024-04-01") & month < as.Date("2025-04-01")) |>
      dplyr::summarise(n = sum(n), total = sum(total_delay_duration_capped)) |>
      dplyr::mutate(mean = total / n)
  ),
  tar_target(
    mean_delayed_discharge_month,
    delayed_discharge_age_sex |>
      dplyr::summarise(n = sum(n), total = sum(total_delay_duration_capped),
                       .by = month) |>
      dplyr::mutate(mean = total / n)
  ),
  tar_target(
    mean_delayed_discharge_age_sex,
    delayed_discharge_age_sex |>
      dplyr::summarise(
        mean = sum(total_delay_duration_capped) / sum(n), 
        .by = c(age_band, sex)
      ) |>
      dplyr::rename(n = mean) |> # renamed so can use existing functions
      tidy_age_sex_data(0)
  ),
  tar_target(
    delayed_discharge_pod,
    delayed_discharge_pod_raw |>
      janitor::clean_names() |>
      dplyr::mutate(month = lubridate::ym(der_activity_month),
                    mean = total / n)
  ),
  tar_target(
    mean_delayed_discharge_scale_2425_pod,
    delayed_discharge_pod |>
      dplyr::filter(month >= as.Date("2024-04-01") & month < as.Date("2025-04-01")) |>
      dplyr::summarise(n = sum(n), total = sum(total), .by = pod) |>
      dplyr::mutate(mean = total / n)
  ),
  tar_target(
    delayed_discharge_specialty_group,
    delayed_discharge_specialty_group_raw |>
      janitor::clean_names() |>
      dplyr::mutate(month = lubridate::ym(der_activity_month),
                    mean = total / n)
  ),
  tar_target(
    mean_delayed_discharge_scale_2425_specialty_group,
    delayed_discharge_specialty_group |>
      dplyr::filter(month >= as.Date("2024-04-01") & month < as.Date("2025-04-01")) |>
      dplyr::summarise(n = sum(n), total = sum(total), .by = specialty_group) |>
      dplyr::mutate(mean = total / n)
  ),
  tar_target(
    delayed_discharge_non_zero,
    delayed_discharge_non_zero_raw |>
      janitor::clean_names()
  ),
  tar_target(
    delayed_discharge_top_n,
    delayed_discharge_top_n_raw |>
      get_top_n(small_number_suppression_limit,
                diagnosis_lookup,
                procedure_lookup)
  )
)
