# Aidan Draper
# August 16, 2018
# Testing Classifiers on Different Images

rm(list=ls())

library(raster)
library(magrittr)

# import models to run on processed images later
setwd("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/")
load(file = "Classifiers/phau_model.rda")
phau_model <- model
rm(model)

load(file = "Classifiers/scam_model.rda")
scam_model <- model
rm(model)

