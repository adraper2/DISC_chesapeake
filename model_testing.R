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

# create our crop region layer
e <- as(extent(365375, 366400, 4303600, 4304800), 'SpatialPolygons')
crs(e) <- "+proj=utm +zone=18"


# IMAGE PROCESSING
# import bands, crop them to the SERC region and raster to a data frame
band2 <- "Landsat8/LC08_L1TP_015033_20160718_20170222_01_T1/LC08_L1TP_015033_20160718_20170222_01_T1_B2.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band3 <- "Landsat8/LC08_L1TP_015033_20160718_20170222_01_T1/LC08_L1TP_015033_20160718_20170222_01_T1_B3.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band4 <- "Landsat8/LC08_L1TP_015033_20160718_20170222_01_T1/LC08_L1TP_015033_20160718_20170222_01_T1_B4.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band5 <- "Landsat8/LC08_L1TP_015033_20160718_20170222_01_T1/LC08_L1TP_015033_20160718_20170222_01_T1_B5.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()

# covariates for model and dataset construction
evi.value <- 2.5 * ((band5[1,3] - band4[1,3]) / (((band4[1,3] * 6) + band5[1,3]) - ((7.5 * band2[1,3]) + 1)))
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