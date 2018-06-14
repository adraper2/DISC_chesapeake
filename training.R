# Aidan Draper 
# R script to create full dataframe covariates for Random Forest classification
# June 13, 2018

rm(list=ls())

library(raster)
library(magrittr)
library(rgdal)
library(ggplot2)


setwd("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/Landsat8/LC08_L1TP_015033_20160718_20170222_01_T1")

e <- as(extent(365375, 366400, 4303600, 4304800), 'SpatialPolygons')
crs(e) <- "+proj=utm +zone=18"

band2 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B2.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band3 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B3.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band4 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B4.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band5 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B5.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()

# NEED TO DOWNLOAD ARCMAP AND CREATE A .SHP FILE TO MASK THE PLOT TO (too much data currently)

evi.value <- 2.5 * ((band5[,3] - band4[,3]) / (((band4[,3] * 6) + band5[,3]) - ((7.5 * band2[,3]) + 1)))
ndvi.value <- ((band5[,3] - band4[,3]) / (band5[,3] + band4[,3]))
ndwi.value <- (band3[,3] - band5[,3]) / (band3[,3] + band5[,3])
savi.value <- (1.5 * ((band5[,3] - band4[,3]) / (band5[,3] + band4[,3] + 1.5)))

full.data <- data.frame(x = band2[,1], 
                        y = band2[,2], 
                        band2 = band2[,3],
                        band3 = band3[,3],
                        band4 = band4[,3],
                        band5 = band5[,3],
                        ndvi = ndvi.value,
                        evi = evi.value,
                        ndwi = ndwi.value,
                        savi = savi.value)

ggplot(data = full.data, aes(x=x, y=y)) + geom_point(aes(color = ndvi))


