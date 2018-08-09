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
# we still have 62 missing values for ect_growth_lag.  Can these be imputed?  Far from clear what it would really mean!
# are we imputing what ECT would have been, in the event that there were such things as electronic transactions? Or
# is the actual observed value just zero (probably before 1987, but in 1987 there were at least some eg credit cards?)


# naive approach *will* fit a model, but the NA is down to the lowest common denominator, when data available on all variables
mod <- lm(gdp_growth ~ ., data = ind_data_wide2)
summary(mod)
# suggests building consents issued and maybe ECT.  Makes it more important to do something about the missing ECT values.

#----------mice--------------------
ind_mi <- mice(ind_data_wide2)

mod_mi <- with(ind_mi, lm(gdp_growth ~ yr_num + gdp_growth_lag + bc_sa_lag + bci_growth_lag +
                            ect_growth_lag + fpi_growth_lag + iva_growth_lag))
summary(pool(mod_mi))

cbind(summary(pool(mod_mi)), round(summary(pool(mod_mi))$p.value, 3))

dim(ind_data_wide)

# I have 232 observations - many of them missing and a minimum of 7 variables





#-----with lasso-------
# I like Michael's answer at https://stats.stackexchange.com/questions/46719/multiple-imputation-and-model-selection:
# use in combination with bootstrap.
cv_results <- data_frame(lambda = numeric(), alpha = numeric(), mcve = numeric(), imputation = numeric())

for(imp in 1:5){
  the_data <- complete(ind_mi, imp)
  
  X <-as.matrix(select(the_data, -gdp_growth))
  Y <-  the_data$gdp_growth
  
  alphas <- seq(from = 0, to = 1, length.out = 20)
  
  for(i in alphas){
    cvfit <- cv.glmnet(as.matrix(X), Y, alpha = i)
    tmp <- data_frame(lambda = cvfit$lambda, alpha = i, mcve = cvfit$cvm, imputation = imp)   
    cv_results <- rbind(cv_results, tmp)
  }
}

cv_results %>%
  group_by(lambda, alpha) %>%
  summarise(mcve = mean(mcve)) %>%
  mutate(ordered_alpha = fct_reorder(as.character(round(alpha, 3)), mcve, .fun = min)) %>%
  ggplot(aes(x = lambda, y = sqrt(mcve), colour = ordered_alpha)) +
  geom_line(size = 2) +
  geom_line(size = 0.2, colour = "grey50", aes(group = ordered_alpha)) +
  scale_x_log10() +
  scale_colour_viridis("alpha", guide = guide_legend(reverse = TRUE), discrete = TRUE) +
  ggtitle("Cross-validation to select hyper parameters\nin elastic net regression") +
  scale_y_continuous("Square root of mean cross validation error", label = comma) +
  theme(legend.position = "right")

# This suggests a low value of alpha (ie far from its maximum of 1, which is a pure lasso) is quite effective
# In fact we will go with 0 - pure ridge regression.




# Define a function that creates a single imputed set of data from a bootstrapped resample, then fits ridge regression to it
ridge <- function(data, i){
  # create a single complete imputed set of data:
  the_data = complete(mice(data[i, ], m = 1, print = FALSE), 1)
  X <- as.matrix(dplyr::select(the_data, -gdp_growth))
  Y <-  the_data$gdp_growth
  
  # we're going to scale the data so the results are in terms of standard deviations of the 
  # variable in question, to make coefficients more comparable.  Note that this scaling takes
  # place *within* the bootstrap as it is part of the analytical process we are simulating
  # by resampling.  Also note we need to do some clever stuff to ensure both growth and lagged
  # growth are scaled the same way
  gdp_mu <- mean(Y)
  gdp_sigma <- sd(Y)
  gdp_l <- which(colnames(X) == "gdp_growth_lag")
  X[, -gdp_l] <- scale(X[, -gdp_l])
  X[, gdp_l] <- scale(X[, gdp_l], center = gdp_mu, scale = gdp_sigma)
  Y <- scale(Y, center = gdp_mu, scale = gdp_sigma)
  
  # work out the best lambda for this dataset using cross validation"
  lambda <- cv.glmnet(as.matrix(X), Y, alpha = 0)$lambda.min
  
  # fit the model:
  mod_rr <- glmnet(X, Y, alpha = 0, lambda = lambda)
  
  # return the results:
  as.vector(coef(mod_rr))
}

# Now we run the bootstrap, using the function above.
set.seed(321)
ridge_bt <- boot(data = ind_data_wide2, statistic = ridge, R = 999)


boot_coefs <- data_frame(
  variable = character(),
  lower = numeric(),
  upper = numeric(),
  point = numeric()
)
var_names <- c("Intercept", names(ind_data_wide_names)[-2])
for(i in 1:8){
  x <- boot.ci(ridge_bt, type = "perc", index = i)
  boot_coefs <- rbind(boot_coefs,
                      data_frame(variable = var_names[i],
                                 lower = x$percent[4],
                                 upper = x$percent[5],
                                 point = x$t0))
}

boot_coefs %>%
  filter(variable != "Intercept") %>%
  mutate(variable = ifelse(variable == "Period", "Linear\ntime trend", variable)) %>%
  mutate(variable = fct_reorder(variable, lower)) %>%
  ggplot(aes(y = variable)) +
  geom_vline(xintercept = 0, colour = "black") +
  geom_segment(aes(yend = variable, x = lower, xend = upper), size = 3, colour = "steelblue", alpha = 0.5) +
  geom_point(aes(x = point)) +
  labs(x = "Estimated impact on predicted next quarter's GDP growth of change in one standard deviation",
       y = "",
       caption = "95% confidence intervals based on bootstrapped ridge regression, with
electronic card transactions imputed differently for each bootstrap resample.
Analysis by http://freerangestats.info") +
  ggtitle("Business confidence, this quarter's economic growth, and building consents
are useful as leading indicators of next quarter's New Zealand economic growth",
          str_wrap("Variables considered are official statistics available from Stats NZ every month, within a month; plus the OECD business confidence measure (which is based on NZIER's Quarterly Survey of Business Opinion).", 80))
