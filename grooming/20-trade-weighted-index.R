library(openxlsx)

download.file("https://www.rbnz.govt.nz/-/media/ReserveBank/Files/Statistics/tables/b1/hb1-monthly-1973-1998.xlsx",
              destfile = "data/hb1-monthly-1973-1998.xlsx", mode = "wb")

download.file("https://www.rbnz.govt.nz/-/media/ReserveBank/Files/Statistics/tables/b1/hb1-monthly.xlsx",
              destfile = "data/hb1-monthly.xlsx", mode = "wb")


old_fx <- read.xlsx("data/hb1-monthly-1973-1998.xlsx", sheet = "Data", cols = c(1, 3), 
                    startRow = 133, detectDates = TRUE, colNames = FALSE)
new_fx <- read.xlsx("data/hb1-monthly.xlsx", sheet = "Data", cols = c(1, 3), 
                    startRow = 6, detectDates = TRUE, colNames = FALSE)

fx <- rbind(old_fx, new_fx)
names(fx) <- c("period", "twi")

fx_q <- fx %>%
  as_tibble() %>%
  mutate(yr = year(period),
         qtr = quarter(period)) %>%
  group_by(yr, qtr) %>%
  summarise(twi = mean(twi)) %>%
  ungroup() %>%
  mutate(twi_growth = twi / lag(twi, 1) - 1,
         twi_growth_lag = lag(twi_growth))
