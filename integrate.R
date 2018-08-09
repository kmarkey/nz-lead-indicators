library(tidyverse)
library(lubridate)
library(scales)
library(seasonal)
library(GGally)


# Grooming
files <- list.files("grooming", full.names = TRUE)
for(f in files){source(f)}

# Analysis
