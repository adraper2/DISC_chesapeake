# Aidan Draper
# May 27, 2018
# R Script to visualize maximum and minimum cover of a species in order to build training sets for the classifiers

rm(list=ls())

library(raster)
library(rgdal)
library(ggplot2)


setwd("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/Landsat8/LC08_L1TP_015033_20160718_20170222_01_T1")

# NDVI points import from bandwidths 4 and 5
band4 <- raster("LC08_L1TP_015033_20160718_20170222_01_T1_B4.TIF")
band5 <- raster("LC08_L1TP_015033_20160718_20170222_01_T1_B5.TIF")

ndvi.p <- rasterToPoints((band5-band4)/(band5 + band4))
utm.coor <- SpatialPoints(cbind(ndvi.p[,1],ndvi.p[,2]), 
                          proj4string=CRS("+proj=utm +zone=18"))
long.lat.coor <- as.data.frame(spTransform(utm.coor,CRS("+proj=longlat")))

ndvi.points <- data.frame(layer=ndvi.p[,3], lat=long.lat.coor$coords.x1, lon=long.lat.coor$coords.x2, easting = utm.coor$coords.x1, northing = utm.coor$coords.x2)

# constrain the ndvi points to the plot region
ndvi.points <- ndvi.points[which(ndvi.points$lat > -76.555 & ndvi.points$lat < -76.537),]
ndvi.points <- ndvi.points[which(ndvi.points$lon > 38.8725 & ndvi.points$lon < 38.879),]


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

#remove excess environment vars to free memory
rm(species); rm(utm.coor); rm(long.lat.coor.serc); rm(utm.coor.serc); rm(band4); rm(band5); rm(long.lat.coor); rm(ndvi.p)

# save a user-defined dataset 
user.species = readline(prompt="Enter a species (scam, phau, ivfr, c4, spcy, tyla, dead or bare_water): ")
curr.species.map <- species.map[which(species.map[,user.species]%in%c(NA, 0, 4,5)),c(which(names(species.map)%in%user.species),9:12)]

#graph current species under landsat plots
ggplot() + 
  geom_rect(data=curr.species.map, aes(xmin=(easting - min(ndvi.points$easting))/30, xmax=(easting - min(ndvi.points$easting) + 20)/30, ymin=(northing -min(ndvi.points$northing))/30, ymax=(northing -min(ndvi.points$northing) + 20)/30, fill = as.factor(unlist(curr.species.map[1]))), color=NA) +
  labs(title=paste(user.species,"'s Population Abundance"), x="X (30m increment)", y="Y (30m increment)", fill = "Cover") + 
  geom_rect(data=ndvi.points, aes(xmin=(easting - min(ndvi.points$easting))/30, xmax=(easting - min(ndvi.points$easting) + 30)/30, ymin=(northing-min(ndvi.points$northing))/30, ymax=(northing + 30 - min(ndvi.points$northing))/30), color="black", fill = NA)

rm(curr.species.map)

