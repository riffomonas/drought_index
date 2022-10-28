#!/usr/bin/env Rscript

library(tidyverse)
library(lubridate)
library(glue)
library(showtext)

font_add_google("Roboto slab", family="roboto-slab")
font_add_google("Montserrat", family="montserrat")

showtext_auto()
showtext_opts(dpi = 300)

prcp_data <- read_tsv("data/ghcnd_tidy.tsv.gz")

station_data <- read_tsv("data/ghcnd_regions_years.tsv")

buffered_end <- today() - 5
buffered_start <- buffered_end - 30

lat_long_prcp <- inner_join(prcp_data, station_data, by = "id") %>%
  filter((year != first_year & year != last_year) | year == year(buffered_end)) %>% 
  group_by(latitude, longitude, year) %>%
  summarize(mean_prcp = mean(prcp), .groups = "drop")

end <- case_when(month(buffered_start) != month(buffered_end) ~ format(buffered_end, "%B %-d, %Y"),
                 month(buffered_start) == month(buffered_end) ~ format(buffered_end, "%-d, %Y"),
                 TRUE ~ NA_character_)

start <- case_when(year(buffered_start) != year(buffered_end) ~ format(buffered_start, "%B %-d, %Y"),
                   year(buffered_start) == year(buffered_end) ~ format(buffered_start, "%B %-d"),
                   TRUE ~ NA_character_)

date_range <- glue("{start} to {end}")

lat_long_prcp %>%
  group_by(latitude, longitude) %>%
  mutate(z_score = (mean_prcp - mean(mean_prcp)) / sd(mean_prcp),
         n = n()) %>%
  ungroup() %>%
  filter(n >= 50 & year == year(buffered_end)) %>%
  select(-n, -mean_prcp, -year) %>% 
  mutate(z_score = if_else(z_score > 2, 2, z_score),
         z_score = if_else(z_score < -2, -2, z_score)) %>%
  ggplot(aes(x = longitude, y = latitude, fill = z_score)) +
    geom_tile() +
    coord_fixed() +
    scale_fill_gradient2(name = NULL,
                         low = "#a6611a", mid = "#f5f5f5", high = "#018571",
                         midpoint = 0,
                         breaks = c(-2, -1, 0, 1, 2),
                         labels = c("<-2", "-1", "0", "1", ">2")) +
    theme(plot.background = element_rect(fill = "black", color = "black"),
          panel.background = element_rect(fill = "black"),
          plot.title = element_text(color = "#f5f5f5", size = 18,
                                    family = "roboto-slab"),
          plot.title.position = "plot",
          plot.subtitle = element_text(color = "#f5f5f5", size = 10,
                                       family = "montserrat"),
          plot.caption =  element_text(color = "#f5f5f5",
                                       family = "montserrat"),
          panel.grid = element_blank(),
          legend.background = element_blank(),
          legend.text = element_text(color = "#f5f5f5", family = "montserrat"),
          legend.position = c(0.15, 0.0),
          legend.direction = "horizontal",
          legend.key.height = unit(0.25, "cm"),
          axis.text = element_blank()) +
    labs(title = glue("Amount of precipitation for {date_range}"),
         subtitle = "Standardized Z-scores for at least the past 50 years",
         caption = "Precipitation data collected from GHCN daily data at NOAA")

ggsave("visuals/world_drought.png", width = 8, height = 4)
