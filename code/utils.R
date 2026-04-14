## utils.R — Shared helper functions for Group 7 COVID-19 project
## All coder scripts should source this file: source("code/utils.R")

suppressPackageStartupMessages({
  library(tidyverse)
  library(yaml)
  library(knitr)
  library(gtsummary)
})

#' Read the project configuration file
read_config <- function(path = here::here("config", "config.yml")) {
  yaml::read_yaml(path)
}

#' Load and clean the COVID data based on config
load_data <- function(config = read_config()) {
  df <- read.csv(here::here(config$data_file), stringsAsFactors = FALSE)

  # Clean column names to lowercase
  names(df) <- tolower(names(df))

  # Recode sex
  df <- df %>%
    mutate(
      sex = case_when(
        sex == "female" | sex == 1 ~ "Female",
        sex == "male"   | sex == 2 ~ "Male",
        TRUE ~ as.character(sex)
      )
    )

  # Create binary comorbidity indicators (handle "Yes"/"No" and 1/2 coding)
  comorbidity_cols <- c("diabetes", "copd", "asthma", "inmsupr",
                        "hipertension", "other_disease", "cardiovascular",
                        "obesity", "renal_chronic", "tobacco", "pneumonia")
  for (col in comorbidity_cols) {
    if (col %in% names(df)) {
      df[[col]] <- case_when(
        df[[col]] == "Yes" | df[[col]] == 1 ~ 1,
        df[[col]] == "No"  | df[[col]] == 2 ~ 0,
        TRUE ~ NA_real_
      )
    }
  }

  # Create died indicator
  df <- df %>%
    mutate(
      died = ifelse(!is.na(date_died), 1, 0),
      intubed_bin = case_when(
        intubed == "Yes" | intubed == 1 ~ 1,
        intubed == "No"  | intubed == 2 ~ 0,
        TRUE ~ NA_real_
      ),
      icu_bin = case_when(
        icu == "Yes" | icu == 1 ~ 1,
        icu == "No"  | icu == 2 ~ 0,
        TRUE ~ NA_real_
      )
    )

  # Create age group
  df <- df %>%
    mutate(
      age_group = cut(age,
                      breaks = c(-Inf, 17, 39, 59, 79, Inf),
                      labels = c("0-17", "18-39", "40-59", "60-79", "80+"))
    )

  # Count comorbidities
  df <- df %>%
    mutate(
      n_comorbidities = rowSums(
        select(., diabetes, copd, asthma, inmsupr, hipertension,
               cardiovascular, obesity, renal_chronic, tobacco),
        na.rm = TRUE
      ),
      comorbidity_group = case_when(
        n_comorbidities == 0 ~ "0",
        n_comorbidities == 1 ~ "1",
        n_comorbidities == 2 ~ "2",
        n_comorbidities >= 3 ~ "3+",
      )
    )

  df
}

#' Apply config-based filters (age, sex, confirmed_only)
apply_filters <- function(df, config = read_config()) {
  # Age filter
  age_min <- config$age_range[1]
  age_max <- config$age_range[2]
  df <- df %>% filter(age >= age_min, age <= age_max)

  # Sex filter
  if (config$sex_filter != "all") {
    sex_val <- tools::toTitleCase(config$sex_filter)
    df <- df %>% filter(sex == sex_val)
  }

  # Confirmed only filter
  if (isTRUE(config$confirmed_only)) {
    df <- df %>% filter(clasiffication_final %in% 1:3)
  }

  df
}

#' Common ggplot theme for consistent styling
theme_covid <- function() {
  theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 15),
      plot.subtitle = element_text(color = "grey40"),
      legend.position = "bottom"
    )
}
