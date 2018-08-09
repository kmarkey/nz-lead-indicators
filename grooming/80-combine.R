


ind_data <- gdp_q %>%
  full_join(bc_q, by = c("yr", "qtr")) %>%
  full_join(ect_q, by = c("yr", "qtr")) %>%
  full_join(bci_q, by = c("yr", "qtr")) %>%
  full_join(fpi_q, by = c("yr", "qtr")) %>%
  full_join(iva_q, by = c("yr", "qtr")) %>%
  arrange(yr, qtr) %>%
  mutate(yr_num = yr + qtr / 4 - 0.125)

ind_data_tidy <- ind_data %>%
  # Drop the non-seasonally-adjusted variables:
  select(-gdp_p_cv, -bci, -ect, -iva) %>%
  gather(variable, value, -yr, -qtr, -yr_num) %>%
  filter(!is.na(value)) %>%
  mutate(type = ifelse(grepl("_sa", variable), "Seasonally adjusted", "Original"),
         lag = ifelse(grepl("_lag", variable), "Lagged", "Non-lagged")) %>%
  filter(lag == "Lagged" | variable == "gdp_growth") %>%
  select(-yr, -qtr) %>%
  mutate(variable = fct_relevel(variable, c("gdp_growth", "gdp_growth_lag")))


ind_data_wide <- ind_data_tidy %>%
  select(-lag, -type) %>%
  spread(variable, value) 

ind_data_wide_names <- ind_data_wide %>%
  rename(`GDP growth one quarter ahead` = gdp_growth,
         `Business confidence` = bc_sa_lag,
         `Building consents` = bci_growth_lag,
         `Electronic card transactions` = ect_growth_lag,
         `Food price index` = fpi_growth_lag,
         `GDP growth` = gdp_growth_lag,
         `Visitor arrivals` = iva_growth_lag,
         `Period` = yr_num)
  
names(ind_data_wide_names) <- str_wrap(names(ind_data_wide_names), 12)


save(ind_data_wide, ind_data_tidy, ind_data_wide_names, file = "data/ind_data.rda")

#----------graphics to show data are all here----------------

p1 <- ind_data_tidy %>%
  ggplot(aes(x = yr_num, y = value)) +
  facet_wrap(~variable, scales = "free_y") +
  geom_line()

path_fn <- function(data, mapping, ...){
  p <- ggplot(data = data, mapping = mapping) + 
    geom_smooth(method = "lm", colour = "orange") +
    geom_path(colour = "grey", ...) +
    geom_point(colour = "steelblue", size = 0.5, ...)
     
  return(p)
}

p2 <- ggpairs(ind_data_wide_names, lower = list(continuous = path_fn))

svg("output/pairs.svg", 10, 10)
print(p2)
dev.off()