# Aidan Draper 
# R script to create full dataframe covariates for Random Forest classification
# June 13, 2018

rm(list=ls())

library(raster)
library(magrittr)
library(rgdal)
library(ggplot2)
library(randomForest)


setwd("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/Landsat8/LC08_L1TP_015033_20160718_20170222_01_T1")

# create our crop region layer
e <- as(extent(365375, 366400, 4303600, 4304800), 'SpatialPolygons')
crs(e) <- "+proj=utm +zone=18"

# import bands, crop them to the SERC region and raster to a data frame
band2 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B2.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band3 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B3.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band4 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B4.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band5 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B5.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()

# NEED TO DOWNLOAD ARCMAP AND CREATE A .SHP FILE TO MASK THE PLOT TO (too much data currently)

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

ggplot(data = full.data, aes(x=x, y=y)) + geom_point(aes(color = ndvi))

# copile the full dataframe to run

# Species Map Import 
species <- read.csv("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/DominantSpPerPlot.csv")

# remove plots with no location, if any
species <- species[!is.na(species$easting),]
species <- species[!is.na(species$northing),]

# convert UTM to lat, long
utm.coor.serc <- SpatialPoints(cbind(species$easting,species$northing), 
                               proj4string=CRS("+proj=utm +zone=18"))

# Convert to lat/long
long.lat.coor.serc <- as.data.frame(spTransform(utm.coor.serc,CRS("+proj=longlat")))

species.map <- data.frame(species[2:9],
                          lat = long.lat.coor.serc$coords.x1,
                          lon = long.lat.coor.serc$coords.x2,
                          easting = utm.coor.serc$coords.x1,
                          northing = utm.coor.serc$coords.x2)

rm(species, long.lat.coor.serc, utm.coor.serc)



training <- data.frame(easting = numeric(1457), northing = numeric(1457), 
                       scam = numeric(1457), ivfr = numeric(1457), c4 = numeric(1457), phau = numeric(1457), 
                       spcy = numeric(1457), tyla = numeric(1457), dead= numeric(1457), bare_water = numeric(1457),
                       band2 = numeric(1457), band3 = numeric(1457), band4 = numeric(1457), band5 = numeric(1457), 
                       ndvi = numeric(1457), evi = numeric(1457), ndwi = numeric(1457), savi = numeric(1457))

count <- 0
for(i in 1:nrow(full.data)){
  for (j in 1:nrow(species.map)){
    if (species.map[j,11] - full.data[i,1] < 30 & species.map[j,11] - full.data[i,1] > -20 & 
                  species.map[j,12] - full.data[i,2] < 30 & species.map[j,12] - full.data[i,2] > -20){
      #training <- rbind(training, c(full.data[i,1:2],species.map[j,1:8], full.data[i,3:10]))
      count = count + 1
      training[count,] <- c(full.data[i,1:2],species.map[j,1:8], full.data[i,3:10])
    }
  }
}
paste("Yes count:", count)
nrow(training)

# reassign ordinal values words
for (z in 3:10){
  training[which(is.na(training[,z])),z] <- "none"
  training[which(training[,z] == 0),z] <- "few"
  training[which(training[,z] == 1),z] <- "few more"
  training[which(training[,z] == 2),z] <- "little"
  training[which(training[,z] == 3),z] <- "some"
  training[which(training[,z] == 4),z] <- "most"
  training[which(training[,z] == 5),z] <- "all"
  training[,z] <- as.factor(training[,z])
}

save(training, file = '~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/training_set.rda')

#graph current species under landsat plots
ggplot() + 
  geom_rect(data=species.map, aes(xmin=(easting - min(training$easting))/30, xmax=(easting - min(training$easting) + 20)/30, ymin=(northing -min(training$northing))/30, ymax=(northing -min(training$northing) + 20)/30, fill = as.factor(unlist(species.map[1]))), color=NA) +
  labs(title=paste("Population Abundance"), x="X (30m increment)", y="Y (30m increment)", fill = "Cover") + 
  geom_rect(data=training, aes(xmin=(easting - min(training$easting))/30, xmax=(easting - min(training$easting) + 30)/30, ymin=(northing-min(training$northing))/30, ymax=(northing + 30 - min(training$northing))/30), color="black", fill = NA)

