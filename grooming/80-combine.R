


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

ind_data_tidy <- ind_data %>%
  # Drop some non-seasonally-adjusted variables that we won't be using:
  select(-gdp_p_cv, -bci, -ect, -iva) %>%
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


ind_data_wide <- ind_data_tidy %>%
  select(-lagged, -type, -diffed) %>%
  spread(variable, value) %>%
  mutate(yr_num2 = yr_num) %>%
  select(-yr_num) %>%
  rename(yr_num = yr_num2)

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


save(ind_data_wide, ind_data_tidy, ind_data_wide_names, file = "data/ind_data.rda")

#----------graphics to show data are all here----------------

p1 <- ind_data_tidy %>%
  filter(variable != "gdp_growth_lag") %>%
  ggplot(aes(x = yr_num, y = value)) +
  facet_wrap(~variable, scales = "free_y", ncol = 2) +
  geom_line()

svg("./output/line-charts.svg", 9, 8)
print(p1)
dev.off()

path_fn <- function(data, mapping, ...){
  p <- ggplot(data = data, mapping = mapping) + 
    geom_smooth(method = "lm", colour = "orange") +
    geom_path(colour = "grey", ...) +
    geom_point(colour = "steelblue", size = 0.5, ...)
     
  return(p)
}

p2 <- ggpairs(select(ind_data_wide_names, -yr_num), lower = list(continuous = path_fn))

svg("output/pairs.svg", 10, 10)
print(p2)
dev.off()
