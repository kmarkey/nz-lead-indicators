# Total GDP, chain volume, production measure:
gdp <- read.csv("data/SNE445001_20180801_075329_92.csv", stringsAsFactors = FALSE, skip = 1)
names(gdp) <- c("yr_qtr", "gdp_p_cv")

gdp_q <- gdp %>%
  mutate(qtr = substring(yr_qtr, 6, 6),
         yr = substring(yr_qtr, 1, 4),
         yr_num = as.numeric(yr) + as.numeric(qtr) / 4 - 0.125) %>%
  filter(yr == as.numeric(yr)) %>%
  arrange(yr, qtr)

# Much stronger seasonality in the GDP growth rates than there was in the business confidence:
gdp_ts <- ts(gdp_q$gdp_p_cv, start = c(1987, 3), frequency = 4)

# create a seasonally adjusted version of the volume series, which we'll use for growth rates
gdp_q <- gdp_q %>%
  mutate(gdp_sa = final(seas(gdp_ts)),
         gdp_growth = gdp_sa / lag(gdp_sa) - 1) %>%
  as_tibble()

