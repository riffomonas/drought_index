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

this_year <- lat_long_prcp %>%
  filter(year == 2022) %>%
  select(-year)

inner_join(lat_long_prcp, this_year, by = c("latitude", "longitude")) %>%
  rename(all_years = mean_prcp.x,
         this_year = mean_prcp.y) %>%
  group_by(latitude, longitude) %>%
  summarize(z_score = (min(this_year) - mean(all_years)) / sd(all_years),
         n = n(),
         .groups = "drop") %>%
  filter(n >= 50)