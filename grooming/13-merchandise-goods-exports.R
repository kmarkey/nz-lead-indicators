# Exports - summary data - monthly - merchandise goods only (imports and Exports chapter of Infoshare)


goods_all <- read.csv("data/EXP476601_20180809_095811_58.csv", skip = 1, na.strings = "..")
names(goods_all) <- c("Period", "goods")


goods_m <- goods_all %>%
  mutate(yr = as.numeric(substring(Period, 1, 4)),
         mon = substring(Period, 6, 7),
         mon = ifelse(mon == "1", 10, as.numeric(mon))) %>%
  arrange(yr, mon) %>%
  filter(!is.na(goods)) %>%
  select(yr, mon, goods) %>%
  as_tibble() %>%
  filter(yr >= 1960)

goods_ts <- ts(goods_m$goods, start = c(1960, 1), frequency = 12)

goods_m <- goods_m %>%
  mutate(goods_sa = as.vector(final(seas(goods_ts))),
         qtr= ceiling(mon / 3) ) 

goods_q <- goods_m %>%
  group_by(yr, qtr) %>%
  summarise(goods_sa = sum(goods_sa, na.rm = TRUE),
            goods = sum(goods)) %>%
  ungroup() %>%
  mutate(goods_growth = goods_sa / lag(goods_sa) - 1,
         goods_growth_lag = lag(goods_growth)) 
