#' Process the top n readmissions data.
#' Variant of get_top_n().
#'
#' @param data A dataframe of the top n diagnoses and procedures for a number of
#' TPMA.
#' @param limit The small number suppression limit.
#' @param diagnosis_lookup A lookup of diagnosis codes and descriptions.
#' @param procedure_lookup A lookup of procedure codes and descriptions.
#'
#' @returns A dataframe of top n data with rows for 'Other' activity (the 
#' remainder), small numbers suppressed and diagnosis/procedure descriptions by
#' the readmissions subgroups (pod, age_group and status).
get_top_n_readmissions <- function(data,
                                   limit,
                                   diagnosis_lookup,
                                   procedure_lookup
                                   ) {
  # Suppress small numbers:
  top_n <- data |>
    dplyr::mutate(n = ifelse(n <= limit, NA, n))
  
  # If there are any NA due to number suppression, then shouldn't include
  # a number or percentage for the 'Other' category, so first check if there
  # are NA then join and filter them out when calculating 'Other':
  number_na <- top_n |>
    dplyr::filter(is.na(n)) |>
    dplyr::summarise(number = dplyr::n(),
                     .by = c(status, pod, age_group, type))
  
  other <- top_n |>
    dplyr::left_join(number_na, by = c("status", "pod", "age_group", "type")) |>
    dplyr::filter(is.na(number)) |>
    dplyr::summarise(
      n = sum(n),
      perc = sum(perc),
      .by = c(status, pod, age_group, type)
    ) |>
    dplyr::mutate(
      total = n / perc,
      n_remainder = total - n,
      perc_remainder = n_remainder / total,
      code = "Other"
    ) |>
    dplyr::select(code,
                  n = n_remainder,
                  perc = perc_remainder,
                  status,
                  pod,
                  age_group,
                  type)
  
  top_n <- top_n |>
    dplyr::bind_rows(other) |>
    dplyr::left_join(diagnosis_lookup |> 
                       dplyr::select(-type),
              by = c("code" = "diagnosis_code")) |>
    dplyr::left_join(procedure_lookup |> 
                       dplyr::select(-type) |>
                       dplyr::rename(procedure_description = description),
              by = c("code")) |>
    dplyr::mutate(
      diagnosis_description = dplyr::case_when(
        type != "diagnosis" ~ NA,
        type == "diagnosis" & code == "Other" ~ "Other",
        type == "diagnosis" & is.na(diagnosis_description) ~ "Unknown/Invalid diagnosis code",
        .default = diagnosis_description
      ),
      procedure_description = dplyr::case_when(
        type != "procedure" ~ NA,
        type == "procedure" & code == "Other" ~ "Other",
        type == "procedure" & is.na(procedure_description) ~ "Unknown/Invalid procedure code",
        .default = procedure_description
      ),
      perc = perc * 100
    ) |>
    dplyr::arrange(status, pod, age_group) 
  
  return(top_n)
}