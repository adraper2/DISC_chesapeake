# Aidan Draper 
# R script to create full dataframe covariates for Random Forest classification
# June 13, 2018

rm(list=ls())

library(raster)
library(magrittr)
library(rgdal)
library(ggplot2)


setwd("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/Landsat8/LC08_L1TP_015033_20160718_20170222_01_T1")


band2 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B2.TIF" %>% raster() %>% rasterToPoints()
band3 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B3.TIF" %>% raster() %>% rasterToPoints()
band4 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B4.TIF" %>% raster() %>% rasterToPoints()
band5 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B5.TIF" %>% raster() %>% rasterToPoints()

# NEED TO DOWNLOAD ARCMAP AND CREATE A .SHP FILE TO MASK THE PLOT TO

evi.value <- 2.5 * ((band5[,3] - band4[,3]) / (((band4[,3] * 6) + band5[,3]) - ((7.5 * band2[,3]) + 1)))
ndvi.value <- ((band5[,3] - band4[,3]) / (band5[,3] + band4[,3]))


