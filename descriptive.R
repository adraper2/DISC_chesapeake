# Aidan Draper
# May 27, 2018
# Descriptive Stats of Dominant Species data

rm(list=ls())

library(sp)
library(maps)
library(rgdal)
library(ggplot2)

# import dominant species dataset
species <- read.csv("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/DominantSpPerPlot.csv")

species <- species[!is.na(species$easting),]
species <- species[!is.na(species$northing),]

# visualizing species data
# prep UTM for lat, long
utm.coor <- SpatialPoints(cbind(species$easting,species$northing), 
                         proj4string=CRS("+proj=utm +zone=18"))

# Convert to lat/long
long.lat.coor <- as.data.frame(spTransform(utm.coor,CRS("+proj=longlat")))

species.map <- data.frame(species = species$simplifiedClass,
                         lat = long.lat.coor$coords.x1,
                         long = long.lat.coor$coords.x2)

species.map <- species.map[species.map$species!="",]

#write.csv(species.map, file = "species_map.csv")

# to see scale of data
maryland <- map_data('state', region = 'maryland')
ggplot() + theme(legend.position="none", legend.direction="horizontal", panel.background = element_rect(fill='lightblue1')) +
  geom_polygon( data=maryland, aes(x=long, y=lat),colour="black", fill="cornsilk") + 
  coord_map(xlim = c(-77.5, -75.75),ylim = c(39.2, 38)) + 
  geom_point(data = species.map, 
             aes(x=lat, 
                 y = long, 
                 color = "orange"), shape=8, size =3) +
  labs(title = "Plots in the Chesapeake Bay (for Reference)", y="Longitude", x="Latitude")


# attempt to visualize in R (need to figure out long and lat)
maryland <- map_data('state', region = 'maryland')
ggplot() + theme(legend.position="bottom", legend.direction="horizontal", panel.background = element_rect(fill='lightblue1')) +
  geom_polygon( data=maryland, aes(x=long, y=lat),colour="black", fill="cornsilk") + 
  coord_map(xlim = c(-76.54, -76.56),ylim = c(38.872, 38.8795)) + 
  geom_point(data = species.map, 
             aes(x=lat, 
                 y = long, 
                 color = species.map$species)) +
  #scale_size_continuous(name = "Species") +
  #scale_fill_gradient(low="green",high="darkgreen") +
  labs(title = "Grass and sedge species in the Chesapeake Bay", fill="Species", y="Longitude", x="Latitude")
  


# DESCRIPTIVE VISUALS

hist(species$scam, breaks =c(-1,0,1,2,3,4,5), col ="orange")
hist(species$ivfr, breaks =7)

# calculate frequency in a data frame for each column
freq.plot <- as.data.frame(table(species$scam,exclude=NULL))
colnames(freq.plot) <- c("Order", "Scam")
freq.plot$ivfr <- as.data.frame(table(species$ivfr,exclude=NULL))[,2]
freq.plot$c4 <- as.data.frame(table(species$c4,exclude=NULL))[,2]
freq.plot$phau <- as.data.frame(table(species$phau,exclude=NULL))[,2]
freq.plot$spcy <- as.data.frame(table(species$spcy,exclude=NULL))[,2]
freq.plot$tyla <- as.data.frame(table(species$tyla,exclude=NULL))[,2]
freq.plot$dead <- as.data.frame(table(species$dead,exclude=NULL))[,2]
freq.plot$bare_water <- as.data.frame(table(species$bare_water,exclude=NULL))[,2]

# get totals for each ordinal row
freq.plot$totals <- rep(NA,7)
for (row in 1:7){  
  sum <- 0
  for (col in 2:9){
    sum <- sum + freq.plot[row,col]
  }
  freq.plot$totals[row] <- sum
}

bar.plot.data <- as.data.frame(cbind(order=c(rep("0",194), rep("1",385), rep("2",388), rep("3",409),rep("4",337), rep("5",96), rep("NA",2399)),
                    species=c(rep("scam",freq.plot$Scam[1]), rep("ivfr",freq.plot$ivfr[1]), rep("c4",freq.plot$c4[1]), rep("phau",freq.plot$phau[1]), rep("spcy",freq.plot$spcy[1]), rep("tyla",freq.plot$tyla[1]), rep("dead",freq.plot$dead[1]), rep("bare_water",freq.plot$bare_water[1]),
                              rep("scam",freq.plot$Scam[2]), rep("ivfr",freq.plot$ivfr[2]), rep("c4",freq.plot$c4[2]), rep("phau",freq.plot$phau[2]), rep("spcy",freq.plot$spcy[2]), rep("tyla",freq.plot$tyla[2]), rep("dead",freq.plot$dead[2]), rep("bare_water",freq.plot$bare_water[2]),
                              rep("scam",freq.plot$Scam[3]), rep("ivfr",freq.plot$ivfr[3]), rep("c4",freq.plot$c4[3]), rep("phau",freq.plot$phau[3]), rep("spcy",freq.plot$spcy[3]), rep("tyla",freq.plot$tyla[3]), rep("dead",freq.plot$dead[3]), rep("bare_water",freq.plot$bare_water[3]),
                              rep("scam",freq.plot$Scam[4]), rep("ivfr",freq.plot$ivfr[4]), rep("c4",freq.plot$c4[4]), rep("phau",freq.plot$phau[4]), rep("spcy",freq.plot$spcy[4]), rep("tyla",freq.plot$tyla[4]), rep("dead",freq.plot$dead[4]), rep("bare_water",freq.plot$bare_water[4]),
                              rep("scam",freq.plot$Scam[5]), rep("ivfr",freq.plot$ivfr[5]), rep("c4",freq.plot$c4[5]), rep("phau",freq.plot$phau[5]), rep("spcy",freq.plot$spcy[5]), rep("tyla",freq.plot$tyla[5]), rep("dead",freq.plot$dead[5]), rep("bare_water",freq.plot$bare_water[5]),
                              rep("scam",freq.plot$Scam[6]), rep("ivfr",freq.plot$ivfr[6]), rep("c4",freq.plot$c4[6]), rep("phau",freq.plot$phau[6]), rep("spcy",freq.plot$spcy[6]), rep("tyla",freq.plot$tyla[6]), rep("dead",freq.plot$dead[6]), rep("bare_water",freq.plot$bare_water[6]),
                              rep("scam",freq.plot$Scam[7]), rep("ivfr",freq.plot$ivfr[7]), rep("c4",freq.plot$c4[7]), rep("phau",freq.plot$phau[7]), rep("spcy",freq.plot$spcy[7]), rep("tyla",freq.plot$tyla[7]), rep("dead",freq.plot$dead[7]), rep("bare_water",freq.plot$bare_water[7]))))

# stacked bar visual 1 - species distribution comparison
ggplot(data=bar.plot.data[bar.plot.data$order !="NA",], aes(x = order, fill=species)) + 
  geom_bar(stat="count") + 
  coord_flip() + 
  scale_fill_brewer(palette = 5) +
  labs(title = "Species Distribution in the Chesapeake Bay", fill="Species", x="Denisty of Population (ordinal)", y="Frequency")

# stacked bar visual 2 - population density comparison  
ggplot(data=bar.plot.data[bar.plot.data$order !="NA",], aes(x = species, fill=order)) + 
  geom_bar(stat="count") + 
  coord_flip() + 
  scale_fill_brewer() +
  labs(title = "Species Density (per plot) in the Chesapeake Bay", fill="Pop. Density", x="Species", y="Frequency")
  