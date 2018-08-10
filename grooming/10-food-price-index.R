# food price index


# 215 KB
download.file("https://www.stats.govt.nz/assets/Uploads/Food-price-index/Food-price-index-June-2018/Download-data/food-price-index-june-2018-zipped-csv-tables.zip",
              destfile = "data/fpi-latest.zip", mode = "wb")

# There are three files and we only want one. We don't use the seasonally adjusted because it only goes back to 1999; we
# need longer so we do our own adjusting
filenames <- unzip("data/fpi-latest.zip", list = TRUE)
fn <- filenames[grepl("index-numbers-csv-tables", filenames$Name), "Name"]

unzip("data/fpi-latest.zip", exdir = "data", files = fn)
unlink("data/fpi-latest.zip")
fpi_all <- read.csv(paste0("data/", fn))


fpi_m <- fpi_all %>%
  filter(  Series_title_1 == "Food") %>%
  mutate(yr = as.numeric(substring(Period, 1, 4)),
         mon = substring(Period, 6, 7),
         mon = ifelse(mon == "1", 10, as.numeric(mon))) %>%
  arrange(yr, mon) %>%
  filter(!is.na(Data_value)) %>%
  rename(fpi = Data_value) %>%
  select(yr, mon, fpi)

fpi_ts <- ts(fpi_m$fpi, start = c(1960, 1), frequency = 12)

fpi_m <- fpi_m %>%
  mutate(fpi_sa = final(seas(fpi_ts)),
         qtr= ceiling(mon / 3) ) 

fpi_q <- fpi_m %>%
  group_by(yr, qtr) %>%
  summarise(fpi_sa = mean(fpi_sa, na.rm = TRUE),
            fpi = mean(fpi)) %>%
  ungroup() %>%
  mutate(fpi_growth = fpi_sa / lag(fpi_sa) - 1,
         fpi_growth_lag = lag(fpi_growth)) %>%
  as_tibble()



