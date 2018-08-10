# Imports the business confidence data, filters to just New Zealand, seasonally adjusts, and makes quarterly rollup

bc <- read.csv("data/DP_LIVE_01082018094138947.csv", stringsAsFactors = FALSE)
names(bc)[1] <- "LOCATION" # read.csv corrupts the first name on the way in

# New Zealand only, and with better date formatting:
bc_nz <- bc %>%
  filter(LOCATION == "NZL") %>%
  mutate(Time = as.Date(paste0(TIME, "-15"), format = "%Y-%m-%d"),
         yr = year(Time),
         mon = month(Time),
         qtr = quarter(Time)) %>%
  select(-INDICATOR, -SUBJECT, -MEASURE, -FREQUENCY) %>%
  as_tibble() %>%
  left_join(power_m, by = c("yr", "mon"))


# Seasonally adjust
bc_ts <- ts(bc_nz$Value, start = c(1961, 6), frequency = 12)
bc_nz$bc_sa <- final(seas(bc_ts))


# Quarterly roll-up.  Business confidence doesn't need to be changed into a growth rate (first differenced) as it
# is already stationary, by the nature of it being a bounded statistic calculated from a survey question
bc_q <- bc_nz %>%
  group_by(yr, qtr) %>%
  summarise(bc_sa = mean(bc_sa),
            bc = mean(Value)) %>%
  ungroup() %>%
  mutate(bc_sa_lag = lag(bc_sa))
