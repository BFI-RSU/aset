# Load libraries

library(readxl)
library(here)
library(dplyr)
library(tidyr)

# Load data
load_data <- function() {
  df <- read_xlsx(file_path, sheet = sheet_name)
}



load_data_screens_content <- function() {
  df <- read_xlsx(file_path, sheet = sheet_name)%>%
    pivot_longer(
      cols = c(all_adults, `55_plus`, `16_24`),
      names_to = "age_group",
      values_to = "percentage"
    )
  return(df)
}



load_data_screens_films <- function() {
  df <- read_xlsx(file_path, sheet = sheet_name)%>%
    pivot_longer(
      cols = -c(screen_type, age_group),
      names_to = "film_type",
      values_to = "percentage"
    )
  return(df)
}



load_data_content_location <- function() {
  df <- read_xlsx(file_path, sheet = sheet_name)%>%
    pivot_longer(
      cols = c(all_adults, habitual_shortform_on_smartphone_at_home),
      names_to = "viewer_type",
      values_to = "percentage"
    )
  return(df)
}



simple_table <- function() {
  df <- read_xlsx(file_path, sheet = sheet_name)

  knitr::kable(df)
}


load_data_social <- function() {
  df <- read_xlsx(file_path, sheet = sheet_name)%>%
    pivot_longer(
      cols = c(Adults, Females, Males),
      names_to = "sex",
      values_to = "percentage"
    )
  return(df)
}