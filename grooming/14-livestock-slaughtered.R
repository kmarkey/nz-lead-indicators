# Livestock slaughted
# weight is there as an optiob in Infoshare but there are no values, so we'll just use numbers.  Very crude.


lst <- read.csv("data/LSS154702_20180810_120736_86.csv", skip = 4, na.strings = "..")
names(lst) <- c("yr_qtr", "lst_num", "lst_wt")

lst_q <- lst %>%
  mutate(qtr = as.numeric(substring(yr_qtr, 6, 6)),
         yr = as.numeric(substring(yr_qtr, 1, 4))) %>%
  filter(!is.na(yr)) %>%
  arrange(yr, qtr) %>%
  select(-yr_qtr) %>%
  as_tibble() %>%
  select(-lst_wt)

lst_ts <- ts(lst_q$lst_num, start = c(1981, 4), frequency = 4)

lst_q <- lst_q %>%
  mutate(lst_sa = final(seas(lst_ts)), 
         lst_growth = lst_sa / lag(lst_sa) - 1,
         lst_growth_lag = lag(lst_growth)) 


