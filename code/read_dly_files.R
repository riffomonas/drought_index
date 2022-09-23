library(tidyverse)
library(glue)
library(lubridate)

# https://www.ncei.noaa.gov/pub/data/ghcn/daily/readme.txt
# ------------------------------
# Variable   Columns   Type
# ------------------------------
# ID            1-11   Character
# YEAR         12-15   Integer
# MONTH        16-17   Integer
# ELEMENT      18-21   Character
# VALUE1       22-26   Integer
# MFLAG1       27-27   Character
# QFLAG1       28-28   Character
# SFLAG1       29-29   Character
# VALUE2       30-34   Integer
# MFLAG2       35-35   Character
# QFLAG2       36-36   Character
# SFLAG2       37-37   Character
#   .           .          .
#   .           .          .
#   .           .          .
# VALUE31    262-266   Integer
# MFLAG31    267-267   Character
# QFLAG31    268-268   Character
# SFLAG31    269-269   Character
# ------------------------------

quadruple <- function(x){

    c(glue("VALUE{x}"), glue("MFLAG{x}"), glue("QFLAG{x}"), glue("SFLAG{x}"))

}

widths <- c(11, 4, 2, 4, rep(c(5, 1, 1, 1), 31))
headers <- c("ID", "YEAR", "MONTH", "ELEMENT", unlist(map(1:31, quadruple)))

read_fwf("data/ghcnd_cat.fwf.gz",
         fwf_widths(widths, headers),
         na = c("NA", "-9999"),
         col_types = cols(.default = col_character()),
         col_select = c(ID, YEAR, MONTH, ELEMENT, starts_with("VALUE")))

    # %>%
    rename_all(tolower) %>%
    filter(element == "PRCP") %>%
    select(-element) %>% 
    pivot_longer(cols = starts_with("value"),
                 names_to = "day", values_to = "prcp") %>%
    drop_na() %>%
    mutate(day = str_replace(day, "value", ""),
           date = ymd(glue("{year}-{month}-{day}")),
           prcp = as.numeric(prcp)/100) %>% # prcp now in cm
    select(id, date, prcp) %>%
    write_tsv("data/composite_dly.tsv")