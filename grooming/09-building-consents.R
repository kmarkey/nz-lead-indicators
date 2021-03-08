# Downloads, imports, seasonally adjusts and generally prepares the building consents issued data


# caution - 28MB - so we only download it if we have to
if(!exists("bci_all")){
  download.file("https://www.stats.govt.nz/assets/Uploads/Building-consents-issued/Building-consents-issued-June-2018/Download-data/building-consents-issued-june-2018-csv-tables.zip",
                destfile = "data/bci-latest.zip", mode = "wb")
  
  # There are about 6 files in here, most of them monthly, only one is quarterly and we will use that one for now (even
  # though the aim is to understand monthly leading indicators, for evaluating them we need the quarterly version to 
  # compare to GDP):
  unzip("data/bci-latest.zip", exdir = "data", files = "Building consents by region (Quarterly).csv")
  unlink("data/bci-latest.zip")
  bci_all <- read.csv("data/Building consents by region (Quarterly).csv")
}


bci_q <- bci_all %>%
  filter(  Series_title_1 == "New Zealand" & 
             
             # alternative to "All construction", has slightly fewer data points:
           Series_title_2 == "All buildings" & 
             
           Series_title_3 == "New plus altered" &
             
             # alternative to "Seasonally Adjusted" but this limits it to 1995 + so we're going to do our own:
           Series_title_5 == "Actual" &        
             
             # alternative to number:
           Units == "Dollars") %>%                 

  mutate(yr = as.numeric(substring(Period, 1, 4)),
         mon = substring(Period, 6, 7),
         mon = ifelse(mon == "1", 10, as.numeric(mon)),
         qtr = mon / 3) %>%
  arrange(yr, mon) %>%
  filter(!is.na(Data_value)) %>%
  rename(bci = Data_value) %>%
  select(yr, qtr, bci)

bci_ts <- ts(bci_q$bci, start = c(1965, 2), frequency = 4)

bci_q <- bci_q %>%
  mutate(bci_sa = as.vector(final(seas(bci_ts))),
         bci_growth = bci_sa / lag(bci_sa) - 1,
         bci_growth_lag = lag(bci_growth)) %>%
  as_tibble()

