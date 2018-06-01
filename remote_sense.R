# Aidan Draper
# May 31, 2018
# A classifier for sedge and grass species classification using satellite images

rm(list=ls())

library(jpeg)
library(imager)
library(VSURF)
library(randomForest)

setwd("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/")

#landsat8 <- readJPEG("Landsat8/LC08_L1TP_015033_20160819_20170222_01_T1.jpg",native = TRUE)

im <- load.image("Landsat8/LC08_L1TP_015033_20160819_20170222_01_T1.jpg")

im.xedges <- deriche(im,2,order=2,axis="x") #Edge detector along x-axis
# plot(im.xedges)

# if(exists("rasterImage")){
#   plot(1:2, type='n')
#   rasterImage(landsat8,1,1,2,2)
# }

