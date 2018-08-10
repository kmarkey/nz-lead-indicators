# Exploratory / expository graphics just to show the data
# Peter Ellis 9 August 2018


p0 <- ind_data %>%
  select(yr_num, everything(), -ends_with("growth"), -ends_with("lag"), -yr, -qtr) %>%
  gather(variable, value, -yr_num) %>%
  filter(!is.na(value)) %>%
  mutate(sa = ifelse(grepl("_sa", variable), "Seasonally adjusted", "Original")) %>%
  mutate(variable = gsub("_sa", "", variable)) %>%
  ggplot(aes(x = yr_num, colour = sa, y = value)) +
  facet_grid(variable ~ sa, scales = "free_y") +
  geom_line() +
  ggtitle("Potential leading indicators for the New Zealand economy",
          "Presented in original form; apart from business confidence ('bc'), all series are non-stationary\nso will need to be treated as growth rates for modelling.") +
  theme(legend.position = "none") +
  labs(x = "", colour = "",
       caption = "Source: OECD/NZIER (business confidence), Reserve Bank (trade weighted index), Stats NZ (all others)")

svg("./output/0128-line-charts.svg", 8, 12)
print(p0)
dev.off()


p1 <- ind_data_tidy %>%
  filter(variable != "gdp_growth") %>%
  ggplot(aes(x = yr_num, y = value)) +
  facet_wrap(~variable, scales = "free_y", ncol = 2) +
  geom_line()+
  ggtitle("Potential leading indicators for the New Zealand economy",
          "Presented as stationary series; mostly this means as growth rates of the seasonally adjusted original.") +
  theme(legend.position = "none") +
  labs(x = "", colour = "",
       caption = "Source: OECD/NZIER (business confidence), Reserve Bank (trade weighted index), Stats NZ (all others)")


svg("./output/0128-stationary-line-charts.svg", 9, 8)
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

svg("output/0128-pairs.svg", 16, 16)
print(p2)
dev.off()
