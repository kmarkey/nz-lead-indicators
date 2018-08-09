# This program runs the entire repository; if everything is in working order you should be able to open the RStudio project
# and "Source" this script and everything should create the necessary data (including downloading it when not part of the
# GitHub repository), tidying it up, and running analysis.
#
# Peter Ellis 9 August 2018

#---------------Functionality---------------
library(tidyverse)
library(lubridate)
library(scales)
library(seasonal)
library(GGally)
library(openxlsx)
library(mice)
library(forecast)
library(glmnet)
library(viridis)
library(boot)
library(broom)


#--------------Grooming------------------
# Data download (when can be automated), import, tidying, and grooming in general
files <- list.files("grooming", full.names = TRUE)
for(f in files){source(f)}


#----------------Analysis-----------------
source("analysis/linear-models.R") # takes a few minutes because of a bootstrap operation
source("analysis/timeseries-approach.R")
