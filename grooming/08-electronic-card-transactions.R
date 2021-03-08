# Downloads, imports, seasonally adjusts and generally prepares the electronic card transactions data



download.file("https://www.stats.govt.nz/assets/Uploads/Electronic-card-transactions/Electronic-card-transactions-June-2018/Download-data/electronic-card-transactions-jun-2018-csv-tables.zip",
              destfile = "data/ect-latest.zip", mode = "wb")
unzip("data/ect-latest.zip", exdir = "data")
unlink("data/ect-latest.zip")

ect_name <- list.files("data", pattern = "^electronic-card-transactions", full.names = TRUE)
res <- file.rename(from = ect_name, to = "data/ect-latest.csv")
if(!res){stop("Something went wrong with the import of electronic card transactions data")}

ect_all <- read.csv("data/ect-latest.csv")

ect_q <- ect_all %>%
  filter(Group == "Total values - Electronic card transactions A/S/T by division" &
           Series_title_1 == "Actual" & 
           Series_title_2 == "RTS total industries" &
           Series_reference == "ECTQ.S19A1") %>%
  mutate(yr = as.numeric(substring(Period, 1, 4)),
         mon = substring(Period, 6, 7),
         mon = ifelse(mon == "1", 10, as.numeric(mon)),
         qtr = mon / 3) %>%
  arrange(yr, mon) %>%
  filter(!is.na(Data_value)) %>%
  rename(ect = Data_value) %>%
  select(yr, qtr, ect)

ect_ts <- ts(ect_q$ect, start = c(2002, 4), frequency = 4)
a<-final(seas(ect_ts))
ect_q <- ect_q %>%
  mutate(ect_sa = as.vector(final(seas(ect_ts))),
         ect_growth = ect_sa / lag(ect_sa) - 1,
         ect_growth_lag = lag(ect_growth)) %>%
  as_tibble()


