# This script sets up data on spells of which party provided the Prime Minister, as well
# as monthly and quarterly roll-ups.
#
# Peter Ellis, 1 August 2018

# a data frame of who was in power for every day over a 70 year period:
power <- data_frame(
  date = as.Date(c(
    "12/12/1957", "12/12/1960", "8/12/1972", "12/12/1975", 
    "26/07/1984", "2/11/1990", "5/12/1999", "19/11/2008", "26/10/2017"), format = "%d/%m/%Y"),
  pm_party = c(
    "Labour", "National", "Labour", "National",
    "Labour", "National", "Labour", "National", "Labour"),
  # the pm_id identifier is used later in grouping data together to avoid annoying connecting lines
  # across the years:
  pm_id = 1:9
) %>%
  right_join(
    data_frame(date = as.Date("1957-12-11") + 1:(70 * 365)),
    by = "date"
  ) %>%
  fill(pm_party, pm_id) %>%
  mutate(qtr = quarter(date),
         yr = year(date),
         mon = month(date))

# roll up by month for later use:		 
power_m <- power %>%
  group_by(yr, mon, pm_party, pm_id) %>%
  summarise(freq = n()) %>%
  group_by(yr, mon) %>%
  summarise(pm_party = pm_party[freq == max(freq)],
            pm_id = pm_id[freq == max(freq)])

# roll up by quarter for later use:
power_q <- power %>%
  group_by(yr, qtr, pm_party, pm_id) %>%
  summarise(freq = n()) %>%
  group_by(yr, qtr) %>%
  summarise(pm_party = pm_party[freq == max(freq)],
            pm_id = pm_id[freq == max(freq)])