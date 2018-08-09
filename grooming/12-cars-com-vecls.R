# Vehicles registered


vec <- read.csv("data/TPT052602_20180809_093759_53.csv", skip = 1, na.strings = "..")
names(vec) <- c("yr_qtr", "cars", "com_vcl")

# "cars" is total cars and stationwagons registered
# com_vcl is total commercial vehcicles registered

vec <- vec %>%
  mutate(qtr = as.numeric(substring(yr_qtr, 6, 6)),
         yr = as.numeric(substring(yr_qtr, 1, 4))) %>%
  filter(!is.na(yr)) %>%
  arrange(yr, qtr) %>%
  select(-yr_qtr) %>%
  as_tibble()

cars_q <- vec %>%
  filter(yr > 1960) %>%
  select(-com_vcl)

cars_ts <- ts(cars_q$cars, start = c(1961, 1), frequency = 4)

cars_q <- cars_q %>%
  mutate(cars_sa = final(seas(cars_ts)), 
         cars_growth = cars_sa / lag(cars_sa) - 1,
         cars_growth_lag = lag(cars_growth)) 


com_vcl_q <- vec %>%
  filter(yr > 1960) %>%
  select(-cars) %>%
  filter(!is.na(com_vcl))

cv_ts <- ts(com_vcl_q$com_vcl, start = c(1974, 1), frequency = 4)

com_vcl_q <- com_vcl_q %>%
  mutate(com_vcl_sa = final(seas(cv_ts)), 
         com_vcl_growth = com_vcl_sa / lag(com_vcl_sa) - 1,
         com_vcl_growth_lag = lag(com_vcl_growth)) 

