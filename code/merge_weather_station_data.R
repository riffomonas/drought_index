#!/usr/bin/env Rscript

library(tidyverse)

prcp_data <- read_tsv("data/ghcnd_tidy.tsv.gz")

station_data <- read_tsv("data/ghcnd_regions_years.tsv")

# anti_join(prcp_data, station_data, by = "id")
# anti_join(station_data, prcp_data, by = "id")

lat_long_prcp <- inner_join(prcp_data, station_data, by = "id") %>%
  filter((year != first_year & year != last_year) | year == 2022) %>% 
  group_by(latitude, longitude, year) %>%
  summarize(mean_prcp = mean(prcp), .groups = "drop")


lat_long_prcp %>%
  group_by(latitude, longitude) %>%
  mutate(z_score = (mean_prcp - mean(mean_prcp)) / sd(mean_prcp),
         n = n()) %>%
  ungroup() %>%
  filter(n >= 50 & year == 2022) %>%
  select(-n, -mean_prcp, -year)
