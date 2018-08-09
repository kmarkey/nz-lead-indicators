# International Travel and Migration, visitor arrivals.  For some reason, the downloadable CSVs only go back to 2008, so we manually get this
# from Infoshare (Tourism: ITM: Visitor Arrival Totals (Quarterly): Actual Counts.



iva <- read.csv("data/ITM330702_20180809_062851_36.csv", skip = 1)
names(iva) <- c("yr_qtr", "iva")

iva_q <- iva %>%
  mutate(qtr = substring(yr_qtr, 6, 6),
         yr = substring(yr_qtr, 1, 4)) %>%
  filter(yr == as.numeric(yr)) %>%
  arrange(yr, qtr) %>%
  # we don't want all the way back to 1921 because it makes it hard for seasonal adjustment, and really
  # the world was very very different then (and no GDP figures anyway)
  filter(yr > 1960)

head(iva_q)

# Much stronger seasonality in the GDP growth rates than there was in the business confidence:
iva_ts <- ts(iva_q$iva, start = c(1960, 1), frequency = 4)

iva_q <- iva_q %>%
  mutate(iva_sa = final(seas(iva_ts)), 
         iva_growth = iva_sa / lag(iva_sa) - 1,
         iva_growth_lag = lag(iva_growth)) %>%
  as_tibble()


