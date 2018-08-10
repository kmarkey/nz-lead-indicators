

# full set of data, in a pretty wide format:
ind_data <- gdp_q %>%
  full_join(bc_q, by = c("yr", "qtr")) %>%
  full_join(ect_q, by = c("yr", "qtr")) %>%
  full_join(bci_q, by = c("yr", "qtr")) %>%
  full_join(fpi_q, by = c("yr", "qtr")) %>%
  full_join(iva_q, by = c("yr", "qtr")) %>%
  full_join(cars_q, by = c("yr", "qtr")) %>%
  full_join(com_vcl_q, by = c("yr", "qtr")) %>%
  full_join(goods_q, by = c("yr", "qtr")) %>%
  full_join(fx_q, by = c("yr", "qtr")) %>%
  full_join(lst_q, by = c("yr", "qtr")) %>%
  arrange(yr, qtr) %>%
  mutate(yr_num = yr + qtr / 4 - 0.125)

# tidy format, and just the stationary versions (ie growth etc):
ind_data_tidy <- ind_data %>%
  # Drop some non-seasonally-adjusted variables that we won't be using:
  select(-gdp, -bc, -bci, -ect, -iva) %>%
  gather(variable, value, -yr, -qtr, -yr_num) %>%
  filter(!is.na(value)) %>%
  mutate(type = ifelse(grepl("_sa", variable), "Seasonally adjusted", "Original"),
         lagged = ifelse(grepl("_lag", variable), "Lagged", "Non-lagged"),
         diffed = ifelse(grepl("_growth", variable), "Growth", "Original")) %>%
  filter(diffed == "Growth" | variable %in% c("bc_sa")) %>%
  filter(lagged != "Lagged" | variable == "gdp_growth_lag") %>%
  select(-yr, -qtr) %>%
  mutate(variable = fct_relevel(variable, c("gdp_growth", "gdp_growth_lag", "ect_growth", "bc_sa",
                                            "cars_growth", "com_vcl_growth", "iva_growth", "bci_growth", 
                                            "twi_growth", "lst_growth", "goods_growth")))

# wide again, but with only the variables we need.  Useful for modelling.
ind_data_wide <- ind_data_tidy %>%
  select(-lagged, -type, -diffed) %>%
  spread(variable, value) %>%
  mutate(yr_num2 = yr_num) %>%
  select(-yr_num) %>%
  rename(yr_num = yr_num2)

# wide version with meaningful names:
ind_data_wide_names <- ind_data_wide %>%
  rename(`GDP growth one quarter ago` = gdp_growth_lag,
         `Business confidence` = bc_sa,
         `Building consents` = bci_growth,
         `Electronic card transactions` = ect_growth,
         `Food price index` = fpi_growth,
         `GDP growth` = gdp_growth,
         `Visitor arrivals` = iva_growth,
         `Cars and stationwagons registered` = cars_growth,
         `Commercial vehicles registered` = com_vcl_growth,
         `Exports of goods` = goods_growth,
         `Trade-weighted currency index` = twi_growth,
         `Number livestock slaughtered` = lst_growth)
  
names(ind_data_wide_names) <- str_wrap(names(ind_data_wide_names), 15)

# Save all four versions:
save(ind_data, ind_data_wide, ind_data_tidy, ind_data_wide_names, file = "data/ind_data.rda")

