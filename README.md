# DISC REU: Project 1

## Introduction
This is an on going research area in the McLachlan Lab at the University of Notre Dame. The goal of this project is to implement a similar methodology implemented by Meghan Vahsen (a graduate student in the lab who classified Tamarisk in the Colorado River Basin) to monitor population abundance of species of sedge and grass in the Chesapeake. In particular, we have data from the Smithsonian Environmental Research Center's marshland plots; their location in the Chesapeake can be observed below.

![alt text](https://raw.githubusercontent.com/adraper2/DISC_chesapeake/master/plots/location_reference.png)

In order to do so, a Biology student from Notre Dame, Luke Onken, and I have analyzed Landsat 8 OLI Satellite image data. The satellites orbit the Earth in roughly two week increments. Landsat images are particularly useful because they have been flying since 1972 when the <a href = "https://en.wikipedia.org/wiki/Landsat_program">Earth Resources Technology Satellite</a> (later renamed landsat) was first launched. 

40+ years of images would allow us to analyze sedge and grass population abundance over a long period of time in the hopes of analyzing significant species change. Specifically, the phragmites population is of interest. <a href = "http://www.cheswildlife.org/2015/05/phragmites-control-in-maryland/"> Phragmites</a> is an invasive species to the Chesapeake Bay area, as well as the Connecticut coast, Ontario, Ohio and many more areas around Eastern United States and Cananda. It has been known to grow in abundance and suffocate other species grass and sedge out of areas. This shift in grass populations has the power to disrupt the ecosystems in several ways, including _____.


## Initial Analysis and Descriptive Plots
This visual shows the approximate location in Latitude and Longitude of the SERC marshland region that we will be investigating. The map is produced using the ggamps and maps packages from Google. The dots represent the most dominant grass species within a 20 by 20 meter plot. 
```R
# Google Maps Visual
plot.map <- get_map(location = c(-76.54616, 38.87471), maptype = "hybrid", source = "google", zoom = 16)

ggmap(plot.map) + 
  geom_point(data = species.map, 
                             aes(x=lon, 
                                 y = lat, 
                                 color = species.map$species)) +
  theme(legend.position="none")
```
![alt text](https://raw.githubusercontent.com/adraper2/DISC_chesapeake/master/plots/chesapeake_plot.png)

Below are two stacked bar graphs to show the overall distribution of the dataset. The first visual shows which species should be easiest to classify based on the overall size of their bars and how large of boxes their extremes (0 - 1 and 4 - 5) are. The second plot shows the overall distribution of the ordinal scores. As expected, having no species present is the most prevelant group.
```R
# stacked bar visual 1 - species distribution comparison
ggplot(data=bar.plot.data[bar.plot.data$order !="NA",], aes(x = order, fill=species)) + 
  geom_bar(stat="count") + 
  coord_flip() + 
  scale_fill_brewer(palette = 5) +
  labs(title = "Species Distribution in the Chesapeake Bay", fill="Species", x="Denisty of Population (ordinal)", y="Frequency")
```
![alt text](https://raw.githubusercontent.com/adraper2/DISC_chesapeake/master/plots/stacked_bar1.png)

```R
# stacked bar visual 2 - population density comparison  
ggplot(data=bar.plot.data[bar.plot.data$order !="NA",], aes(x = species, fill=order)) + 
  geom_bar(stat="count") + 
  coord_flip() + 
  scale_fill_brewer() +
  labs(title = "Species Density (per plot) in the Chesapeake Bay", fill="Pop. Density", x="Species", y="Frequency")
```
![alt text](https://raw.githubusercontent.com/adraper2/DISC_chesapeake/master/plots/stacked_bar2.png)

## Model
The <a href = "https://github.com/adraper2/DISC_chesapeake/blob/master/training.R">training.R</a> file builds are training set while the <a href = "https://github.com/adraper2/DISC_chesapeake/blob/master/run_classifier.R">run_classifier.R</a> file runs the random forest algorithm on the constructed data frame, which can be accessed by loading the <a href = "https://github.com/adraper2/DISC_chesapeake/blob/master/training_set.rda">training_set.rda</a> file.

### Data Manipulation and Training
The first step was to import the bandwidths we would like to use from our Landsat GeoTIFF file. Then, we need to crop the region to focus on our SERC region and so that we are not dealing with such a large dataset. Finally, we convert the raster image to a matrix using the rasterToPoints() from the raster package.
```R
# create our crop region layer
e <- as(extent(365375, 366400, 4303600, 4304800), 'SpatialPolygons')
crs(e) <- "+proj=utm +zone=18"

# import bands, crop them to the SERC region and raster to a data frame
band2 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B2.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band3 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B3.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band4 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B4.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()
band5 <- "LC08_L1TP_015033_20160718_20170222_01_T1_B5.TIF" %>% raster() %>% crop(y = e) %>% rasterToPoints()
```

Next, we would like to compile our covariates (variables to determine the ordinal score of a species) for the model. These formulas were gathered from various research papers where other people used remote sensing for classifying vegetation, buildings, water, and more. In our case, we focused on variables that be believed would influence vegetation detection and also the bands that were commonly used. We then inserted our varaibles and original bandwidths into a data frame called full.data.
```R
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
```
Here is a visual of our NDVI score to make sure the plot region is correctly constrained and that the score fluxuates enough. In both cases, this was true for our NDVI score and crop layer.
![ndvi plot](https://raw.githubusercontent.com/adraper2/DISC_chesapeake/master/plots/ndvi_test.png)

The next step is to pull in the grass species data from the Smithsonian's marshland plots. This code was gradded from the <a href = "https://github.com/adraper2/DISC_chesapeake/blob/master/descriptive.R">descriptive.R</a> file and is needed for the next step, which involves calculating the plot overlap.
```R
# compile the full dataframe to run

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
```

Now that we have this data, we can calculate the overlap between the Smithsonian's plots and the Landsat plots. While we likely will not use this variable as a covariate in our final model, it serves as a good indicator of the weight that an ordinal plot should have on our classifier's predicted Landsat plot. It also presents some interesting figures about the distribution of of the proportion of overlap within our dataset. We will ellaborate on this shortly.

Now, the plot overlap calculation actually provides an interesting case.
![Plot-Overlap-Figure](https://raw.githubusercontent.com/adraper2/DISC_chesapeake/master/plots/plot_overlap_figure.png)
This figure describes the two cases within our scenario. The tan box represent the SERC 20 by 20 meter plot and the white box represents the 30 by 30 meter plot. The red area represents the overlap in both plots, which is what we want to find. The blue circles are the starting x and y coordinates that I have for each plot. We need to use both sets of x and y coordinates and our knowledge about the lengths of the plots to find the percent of overlap that the SERC plot has on the Landsat plot. So, to calculate this, we used the code below.

```R
#initialize our empty training set with our variables (columns) of interest
training <- data.frame(plot.id = numeric(1457), easting = numeric(1457), northing = numeric(1457), overlap = numeric(1457),
                       scam = numeric(1457), ivfr = numeric(1457), c4 = numeric(1457), phau = numeric(1457), 
                       spcy = numeric(1457), tyla = numeric(1457), dead= numeric(1457), bare_water = numeric(1457),
                       band2 = numeric(1457), band3 = numeric(1457), band4 = numeric(1457), band5 = numeric(1457), 
                       ndvi = numeric(1457), evi = numeric(1457), ndwi = numeric(1457), savi = numeric(1457))

count <- 0 # the number of times a plot will overlap
for(i in 1:nrow(full.data)){
  for (j in 1:nrow(species.map)){
    if (species.map[j,11] - full.data[i,1] < 30 & species.map[j,11] - full.data[i,1] > -20 & 
                  species.map[j,12] - full.data[i,2] < 30 & species.map[j,12] - full.data[i,2] > -20){
      count = count + 1
      training$plot.id[count] <- i 
      training[count,-c(1,4)] <- c(full.data[i,1:2],species.map[j,1:8], full.data[i,3:10])
      if(species.map[j,11] - full.data[i,1] < 0){
        # starting x point is outside landast
        x.overlap <- (species.map[j,11] + 20) - full.data[i,1]
      } else {
        x.overlap <- (full.data[i,1] + 30) - species.map[j,11]
      }
      if(species.map[j,12] - full.data[i,2] < 0){
        # starting y point is outside landast
        y.overlap <- (species.map[j,12] + 20) - full.data[i,2]
      } else {
        y.overlap <- (full.data[i,2] + 30) - species.map[j,12]
      }
      #cat("Overlap Area: ", (x.overlap * y.overlap) / 900, "\n")
      training$overlap[count] <- (x.overlap * y.overlap) / (30*30) # SERC plot overlap area / Landsat area
    }
  }
}
paste("Yes count:", count)
nrow(training)
```

The double for loop indexes the current rows for each dataset that we are using to grab the x and y coordinates. The rest comprises the overlap calculation algorithm. The first if statement says that if the difference between the x of both plots and the difference between the y of both plots are between -20 and 30 exclusively, then do the next steps. This if statement will tell us whether the plots overlap to begin with because we do not want to waste our time doing extra steps if they are not neccessary. Next, we need to find out whether we have case 1 or case 2. We do this separately for x and y but, in truth, if x of one plot is in the other’s plot so will the y of that plot. This code setup is just slightly easier to read. Anyway, a negative number indicates that the SERC plot is outside the Landsat plot, which means we need to use the opposite corner of the SERC plot. We find the length of the red boxes wall by finding the difference between the “new” x and y of one plot and the original x and y of the other. Then, we can calculate the area of this box by multiple our x and y overlap lengths. Finally, we just divide that by the total area of the Landsat plot and that gives us a decimal number from 0 to 1 representing the proportion of plot overlap.


### Model Results:
![model results](https://raw.githubusercontent.com/adraper2/DISC_chesapeake/master/plots/plot_comparison.png)
Here are our results of the finalized model (on the right) trained just on Landsat data compared to the original SERC ordinal data for Scam with the Landsat plot gridlines layed overtop (on the left). As you could see from our previous tables and OOB error percentage, it seemed the classifier is good at classifying no species population within a plot, but rather poor at predicting levels of ordinal data. With that being said, when we predicted the remaining 40% of our plots, it became apparent that the random forest classifier was rather good at averaging plot ordinal scores across multiple SERC plots within one Landsat plot. This tells us that the model was trained well enough on the 60% of the data we fed it to detect the "relative" true scores of population abundance. There is still some noise, but the classifier does a good job at predicting orders given its training and our actual plot data. Interestingly enough, the classifier never predicted all. This is actually a good sign for two reasons. For starters, it was only trained on one row that scored it as "all". Additionally, only one plot within the prediction dataset contained an "all" for scam, but there is some skepticim to the rest of the area within the plot, which most likely was not all scam. For these reasons, it is not that concerning that the model lacks the result of "all" for scam.
