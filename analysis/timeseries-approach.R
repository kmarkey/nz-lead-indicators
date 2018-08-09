library(forecast)
library(mice)
library(tidyverse)
library(broom)

load("data/ind_data.rda")

ind_data_wide2 <- subset(ind_data_wide, !is.na(gdp_growth_lag)) %>%
  arrange(yr_num)
ind_imp <- mice::complete(mice(ind_data_wide2, m = 1, print = FALSE), 1)

Y <- ts(ind_imp$gdp_growth, start = c(1987, 4), frequency = 4)
X <- scale(select(ind_imp, -yr_num, -gdp_growth, -gdp_growth_lag))

mod <- auto.arima(Y, xreg = X)


broom::tidy(confint(mod))
# these results are similar to what we get with the ridge regression approach, but they lose in interpretability
# (because of the moving average and seasonal moving average rather than just relying on the lagged value of growth).
# Noticeably more positive about business confidence as an indicator though.