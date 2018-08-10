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
library(stargazer)
library(knitr)     # for kable

#----------setup----------
# optional styling, use if you want it to be consistent with the freerangestats.info blog:
# source("r/freerangestats-styling.R")
# Note that if you uncomment the above line, you get lots of warnings for graphics that are
# created directly in RStudio (as opposed to writing to an SVG or PNG device).

#--------------Grooming------------------
# Data download (when it can be automated), import, tidying, and grooming in general.
# Caution - one of the files (for building consents issued) includes downloading 28MB the first time each R session:
files <- list.files("grooming", full.names = TRUE)
for(f in files){source(f)}


#----------------Analysis-----------------
source("analysis/linear-models.R") # takes a few minutes because of a bootstrap operation
source("analysis/timeseries-approach.R")
