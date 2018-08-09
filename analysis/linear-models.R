# This analysis program ignores the time series nature of the data other than by including lagged growth as a variable.

library(mice)
library(forecast)
library(tidyverse)
library(glmnet)
library(scales)
library(viridis)
library(boot)

load("data/ind_data.rda")

summary(ind_data_wide) # 109 cases where even gdp_growth is missing.  No point in using them
ind_data_wide2 <- subset(ind_data_wide, !is.na(gdp_growth_lag))

summary(ind_data_wide2)
# we still have 61 missing values for ect_growth_lag.  Can these be imputed?  Far from clear what it would really mean!
# are we imputing what ECT would have been, in the event that there were such things as electronic transactions? Or
# is the actual observed value just zero (probably before 1987, but in 1987 there were at least some eg credit cards?)


# naive approach *will* fit a plausible model, but the NA is down to the lowest common denominator, when data available on all variables
mod <- lm(gdp_growth ~ ., data = ind_data_wide2)
summary(mod)
# suggests building consents issued and maybe ECT.  Makes it more important to do something about the missing ECT values.
# And there's big collinearity problems here.  We need to a) address the missing data and b) the collinearity.

#----------mice--------------------
ind_mi <- mice(ind_data_wide2)

mod_mi <- with(ind_mi, lm(gdp_growth ~ yr_num + gdp_growth_lag + bc_sa + bci_growth +
                            ect_growth + fpi_growth + iva_growth + goods_growth + 
                            cars_growth + com_vcl_growth + twi_growth + lst_growth))
summary(pool(mod_mi))

cbind(summary(pool(mod_mi)), round(summary(pool(mod_mi))$p.value, 3))

dim(ind_data_wide)

# I have 233 observations - many of them missing and a minimum of 13 variables.  Not enough degrees of freedom for much 
# mucking around with non-linearity here (only about 20 observations per variable)





#-----with lasso, ridge, or elastic net regularization-------
# I like Michael's answer at https://stats.stackexchange.com/questions/46719/multiple-imputation-and-model-selection:
# use in combination with bootstrap.
cv_results <- data_frame(lambda = numeric(), alpha = numeric(), mcve = numeric(), imputation = numeric())

for(imp in 1:5){
  the_data <- mice::complete(ind_mi, imp)
  
  X <-as.matrix(select(the_data, -gdp_growth))
  Y <-  the_data$gdp_growth
  
  alphas <- seq(from = 0, to = 1, length.out = 21)
  
  for(i in alphas){
    cvfit <- cv.glmnet(as.matrix(X), Y, alpha = i)
    tmp <- data_frame(lambda = cvfit$lambda, alpha = i, mcve = cvfit$cvm, imputation = imp)   
    cv_results <- rbind(cv_results, tmp)
  }
}

cv_res_grp <- cv_results %>%
  group_by(lambda, alpha) %>%
  summarise(mcve = mean(mcve)) %>%
  ungroup() %>%
  arrange(mcve)

p4 <-  cv_res_grp %>%
  mutate(ordered_alpha = as.factor(round(alpha, 3)),
         ordered_alpha = fct_reorder(ordered_alpha, mcve, .fun = min)) %>%
  ggplot(aes(x = lambda, y = sqrt(mcve), colour = ordered_alpha)) +
  geom_line(size = 2) +
  scale_x_log10(label = comma) +
  scale_colour_viridis("alpha", guide = guide_legend(reverse = TRUE), discrete = TRUE) +
  ggtitle("Cross-validation to select hyper parameters in elastic net regression") +
  scale_y_continuous("Square root of mean cross validation error", label = comma) +
  theme(legend.position = "right")

# This suggests a range of values of alpha will work
# 0 is pure ridge regression (leaves all variables in but shrinks to zero) and 1 is the lasso
# (selects variables).  In practice I tried with several methods and get very similar results
svg("./output/hyper-params-glmnet.svg", 8, 6)
print(p4)
dev.off()

chosen_alpha <- arrange(cv_res_grp, mcve)[1, ]$alpha

# Define a function that creates a single imputed set of data from a bootstrapped resample, then fits ridge regression to it
elastic <- function(data, i){
  # create a single complete imputed set of data:
  the_data = mice::complete(mice(data[i, ], m = 1, print = FALSE), 1)
  X <- as.matrix(dplyr::select(the_data, -gdp_growth))
  Y <-  the_data$gdp_growth
  
  # we're going to scale the data so the results are in terms of standard deviations of the 
  # variable in question, to make coefficients more comparable.  Note that this scaling takes
  # place *within* the bootstrap as it is part of the analytical process we are simulating
  # by resampling.  
  X <- scale(X)

  # work out the best lambda for this dataset using cross validation"
  lambda <- cv.glmnet(as.matrix(X), Y, alpha = chosen_alpha)$lambda.min
  
  # fit the model:
  mod_rr <- glmnet(X, Y, alpha = chosen_alpha, lambda = lambda)
  
  # return the results:
  as.vector(coef(mod_rr))
}

# Now we run the bootstrap, using the function above.
set.seed(321)
elastic_bt <- boot(data = ind_data_wide2, statistic = elastic, R = 999)


boot_coefs <- data_frame(
  variable = character(),
  lower = numeric(),
  upper = numeric(),
  point = numeric()
)
var_names <- c("Intercept", names(ind_data_wide_names)[-2])
for(i in 1:length(var_names)){
  x <- boot.ci(elastic_bt, type = "perc", index = i)
  boot_coefs <- rbind(boot_coefs,
                      data_frame(variable = var_names[i],
                                 lower = x$percent[4],
                                 upper = x$percent[5],
                                 point = x$t0))
}

p3 <- boot_coefs %>%
  filter(!variable %in% c("yr_num", "Intercept")) %>%
  # next line is in there in case we do still want the time trend in the graphic.  But it's never significant,
  # and it's hard to explian.
  mutate(variable = ifelse(variable == "yr_num", "Linear\ntime trend", variable)) %>%
  mutate(variable = fct_reorder(variable, lower)) %>%
  ggplot(aes(y = variable)) +
  geom_vline(xintercept = 0, colour = "black") +
  geom_segment(aes(yend = variable, x = lower, xend = upper), size = 3, colour = "steelblue", alpha = 0.5) +
  geom_point(aes(x = point)) +
  scale_x_continuous(label = percent) +
  labs(x = "Estimated impact in percentage points on predicted next quarter's GDP growth,
of change in one standard deviation in the explanatory variable",
       y = "",
       caption = "95% confidence intervals based on bootstrapped elastic net regularized regression, with
electronic card transactions imputed differently for each bootstrap resample.
Analysis by http://freerangestats.info") +
  ggtitle("Previous quarter's economic growth, food prices and car registrations
are useful as leading indicators of this quarter's New Zealand economic growth",
          str_wrap("Variables considered are official statistics available from Stats NZ every month, within a month; plus the OECD business confidence measure (which is based on NZIER's Quarterly Survey of Business Opinion); and the trade weighted index for currency published by RBNZ.", 80))


svg("./output/ridge-boot-results.svg", 8, 7)
print(p3)
dev.off()
