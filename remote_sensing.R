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

band1 <- raster("LC08_L1TP_015033_20160718_20170222_01_T1_B1.TIF")
band2 <- raster("LC08_L1TP_015033_20160718_20170222_01_T1_B2.TIF")
band3 <- raster("LC08_L1TP_015033_20160718_20170222_01_T1_B3.TIF")
band4 <- raster("LC08_L1TP_015033_20160718_20170222_01_T1_B4.TIF")
band5 <- raster("LC08_L1TP_015033_20160718_20170222_01_T1_B5.TIF")
band6 <- raster("LC08_L1TP_015033_20160718_20170222_01_T1_B2.TIF")
band7 <- raster("LC08_L1TP_015033_20160718_20170222_01_T1_B2.TIF")

# import dominant species dataset
species <- read.csv("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/DominantSpPerPlot.csv")

species <- species[!is.na(species$easting),]
species <- species[!is.na(species$northing),]

# convert UTM to lat, long
utm.coor.serc <- SpatialPoints(cbind(species$easting,species$northing), 
                          proj4string=CRS("+proj=utm +zone=18"))

# Convert to lat/long
long.lat.coor.serc <- as.data.frame(spTransform(utm.coor.serc,CRS("+proj=longlat")))

species.map <- data.frame(species = species$simplifiedClass,
                          lat = long.lat.coor.serc$coords.x1,
                          lon = long.lat.coor.serc$coords.x2,
                          easting = utm.coor.serc$coords.x1,
                          northing = utm.coor.serc$coords.x2)

species.map[which(species.map$species == ""),1] <- "no species"

# basic color plot
rgb.stack <- stack(band4, band3, band2)
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
utm.coor <- SpatialPoints(cbind(ndvi.p[,1],ndvi.p[,2]), 
                          proj4string=CRS("+proj=utm +zone=18"))
long.lat.coor <- as.data.frame(spTransform(utm.coor,CRS("+proj=longlat")))

ndvi.points <- data.frame(layer=ndvi.p[,3], lat=long.lat.coor$coords.x1, lon=long.lat.coor$coords.x2, easting = utm.coor$coords.x1, northing = utm.coor$coords.x2)

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
  labs(title=paste("Smithsonian Research Center's Marshland"), color="Dominant Species") +
  theme(plot.background = element_rect(fill = '#ecf0f8f9'),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank())


#sample.ndvi.points <- ndvi.points[sample(nrow(ndvi.points), 1000), ]

# SERC plots on top of Landat NDVI scores
ggplot() + 
  geom_point(data=ndvi.points, aes(x=lat, y=lon, color=layer), size=2.25) +
  geom_point(data = species.map[,3:2], aes(x=lat, y=lon), shape=1, color="darkslategray", size =1.5) +
  scale_color_gradient2(midpoint=median(ndvi.points$layer),low="lightblue", mid="bisque", high="darkolivegreen4") +
  labs(x="Latitude", y="Longitude")



# plotting utm data

ggplot() + 
  geom_rect(data=species.map, aes(xmin=easting, xmax=easting + 20, ymin=northing, ymax=northing + 20, fill = species), color=NA) + 
  geom_rect(data=ndvi.points, aes(xmin=easting, xmax=easting + 30, ymin=northing, ymax=northing + 30), color="black", fill = NA)

  #scale_color_gradient2(midpoint=median(ndvi.points$layer),low="lightblue", mid="bisque", high="darkolivegreen4") +
  #labs(x="Easting", y="Northing")
  
