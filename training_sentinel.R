# Training a model on sentinel-2 data
# Aidan Draper
# June 21, 2018

rm(list=ls())

library(raster)
library(magrittr)
library(rgdal)
library(ggplot2)

setwd("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/Sentinel2/07-20-2016_IMG_DATA")

# create our crop region layer
e <- as(extent(365375, 366400, 4303600, 4304800), 'SpatialPolygons')
crs(e) <- "+proj=utm +zone=18"

# import bands, crop them to the SERC region and raster to a data frame
band2 <- "S2A_OPER_MSI_L1C_TL_MTI__20160720T205749_A005628_T18SUJ_B02.jp2" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band3 <- "S2A_OPER_MSI_L1C_TL_MTI__20160720T205749_A005628_T18SUJ_B03.jp2" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band4 <- "S2A_OPER_MSI_L1C_TL_MTI__20160720T205749_A005628_T18SUJ_B04.jp2" %>% raster() %>% crop(y = e) %>% rasterToPoints()
# for sentinel band 8 is Near Infrared
band8 <- "S2A_OPER_MSI_L1C_TL_MTI__20160720T205749_A005628_T18SUJ_B08.jp2" %>% raster() %>% crop(y = e) %>% rasterToPoints()


