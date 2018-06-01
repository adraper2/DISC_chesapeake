# Aidan Draper
# 05/31/2018
# Script to graph tif bands and calculate NDVI (Normalized Difference Vegetation Index)

rm(list=ls())

library(raster)
library(rgdal)
library(sp)
library(maps)
library(ggplot2)
library(ggmap)

setwd("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/Landsat8/LC08_L1TP_015033_20160718_20170222_01_T1")

band2 <- raster("LC08_L1TP_015033_20160718_20170222_01_T1_B2.TIF")
band3 <- raster("LC08_L1TP_015033_20160718_20170222_01_T1_B3.TIF")
band4 <- raster("LC08_L1TP_015033_20160718_20170222_01_T1_B4.TIF")
band5 <- raster("LC08_L1TP_015033_20160718_20170222_01_T1_B5.TIF")

# import dominant species dataset
species <- read.csv("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/DominantSpPerPlot.csv")

species <- species[!is.na(species$easting),]
species <- species[!is.na(species$northing),]

# convert UTM to lat, long
utm.coor <- SpatialPoints(cbind(species$easting,species$northing), 
                          proj4string=CRS("+proj=utm +zone=18"))

# Convert to lat/long
long.lat.coor <- as.data.frame(spTransform(utm.coor,CRS("+proj=longlat")))

species.map <- data.frame(species = species$simplifiedClass,
                          lat = long.lat.coor$coords.x1,
                          lon = long.lat.coor$coords.x2)

# basic color plot
rgb.stack <- stack(band2, band3, band4)
plotRGB(rgb.stack, stretch ="hist")

# reflection of vegetation (using NDVI)
ndvi <- (band5-band4)/(band5+band4)

# imitate a thermal image
breaks = seq(-0.5,0.5, 0.1)
palette <-  colorRampPalette(c("blue", "white", "red"))(10)
plot(ndvi, breaks=breaks, col=palette)

hist(ndvi)


# plot NDVI data over map of maryland

# first, I need to convert the NDVI points to latitude longitude
ndvi.p <- rasterToPoints(ndvi)
utm.coor <- SpatialPoints(cbind(ndvi.points[,1],ndvi.points[,2]), 
                          proj4string=CRS("+proj=utm +zone=18"))
long.lat.coor <- as.data.frame(spTransform(utm.coor,CRS("+proj=longlat")))

ndvi.points <- data.frame(layer=ndvi.p[,3], lat=long.lat.coor$coords.x1, lon=long.lat.coor$coords.x2)

# constrain the ndvi points to the plot region
ndvi.points <- ndvi.points[which(ndvi.points$lat > -76.555 & ndvi.points$lat < -76.537),]
ndvi.points <- ndvi.points[which(ndvi.points$lon > 38.8725 & ndvi.points$lon < 38.879),]

plot.map <- get_map(location = c(-76.54616, 38.87471), maptype = "hybrid", source = "google", zoom = 16)

ggmap(plot.map) + 
  # geom_polygon(data=ndvi.points, aes(x=long, y=lat)) +
  geom_point(data = species.map, 
                             aes(x=lat, 
                                 y = lon, 
                                 color = species.map$species)) +
  theme(legend.position="none")


sample.ndvi.points <- ndvi.points[sample(nrow(ndvi.points), 1000), ]

# SERC plots on top of Landat NDVI scores
ggplot() + 
  geom_point(data=ndvi.points, aes(x=lat, y=lon, color=layer), size=2.25) +
  geom_point(data = species.map[,3:2], aes(x=lat, y=lon), shape=1, color="darkslategray", size =1.5) +
  scale_color_gradient2(midpoint=median(ndvi.points$layer),low="lightblue", mid="bisque", high="darkolivegreen4") +
  labs(x="Latitude", y="Longitude")
  
  

