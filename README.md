# DISC REU: Project 1

## Introduction
This is an on going research area in the McLachlan Lab at the University of Notre Dame. The goal of this project is to implement a similar methodology implemented by Meghan Vahsen (a graduate student in the lab who classified Tamarisk in the Colorado River Basin) to monitor population abundance of species of sedge and grass in the Chesapeake. In particular, we have data from the Smithsonian Environmental Research Center's marshland plots; their location in the Chesapeake can be observed below.

![alt text](https://raw.githubusercontent.com/adraper2/DISC_chesapeake/master/plots/location_reference.png)

In order to do so, a Biology student from Notre Dame, Luke Onken, and I have analyzed Landsat 8 OLI Satellite image data. The satellites orbit the Earth in roughly two week increments. Landsat images are particularly useful because they have been flying since 1972 when the <a href = "https://en.wikipedia.org/wiki/Landsat_program">Earth Resources Technology Satellite</a> (later renamed landsat) was first launched. 

40+ years of images would allow us to analyze sedge and grass population abundance over a long period of time in the hopes of analyzing significant species change. Specifically, the phragmites population is of interest. <a href = "http://www.cheswildlife.org/2015/05/phragmites-control-in-maryland/"> Phragmites</a> is an invasive species to the Chesapeake Bay area, as well as the Connecticut coast, Ontario, Ohio and many more areas around Eastern United States and Cananda. It has been known to grow in abundance and suffocate other species grass and sedge out of areas. This shift in grass populations has the power to disrupt the ecosystems in several ways, including _____.

## Classifying sedge and grass plots using satellite image processing
This is a directory for all of the R code and Landsat/drone images processed to classify sedge and grass plots in the Chesapeake Bay.


## Descriptive Plots

```R
# Google Maps Visual
plot.map <- get_map(location = c(-76.54616, 38.87471), maptype = "hybrid", source = "google", zoom = 16)

ggmap(plot.map) + 
  geom_point(data = species.map, 
                             aes(x=lat, 
                                 y = lon, 
                                 color = species.map$species)) +
  theme(legend.position="none")
```
![alt text](https://raw.githubusercontent.com/adraper2/DISC_chesapeake/master/plots/chesapeake_plot.png)

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


## NDVI Analysis
The NDVI score is calculated using the infared and red bandwidths from the Landsat OLI satellite image. The formula is (Infrared - Red) / (Infrared + Red). This formula is a particularily useful plot to use because of the great shift of light reflectance observed from Red to Near Infrared for vegetation in satellite images. This number helps observe rates of photosynthesis, which differ across grass species depending on the time of the year. NDVI is one of the crucial covariates to classifying marshland grass species.

![NDVI Score Image](https://raw.githubusercontent.com/adraper2/DISC_chesapeake/master/plots/NDVI_score.png)

![NDVI plot with SERCs plots](https://raw.githubusercontent.com/adraper2/DISC_chesapeake/master/plots/NDVI_serc.png)

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


### Model Results:
![model results](https://raw.githubusercontent.com/adraper2/DISC_chesapeake/master/plots/plot_comparison.png)
Here are our results of the finalized model (on the right) trained just on Landsat data compared to the original SERC ordinal data for Scam with the Landsat plot gridlines layed overtop (on the left). As you could see from our previous tables and OOB error percentage, it seemed the classifier is good at classifying no species population within a plot, but rather poor at predicting levels of ordinal data. With that being said, when we predicted the remaining 40% of our plots, it became apparent that the random forest classifier was rather good at averaging plot ordinal scores across multiple SERC plots within one Landsat plot. This tells us that the model was trained well enough on the 60% of the data we fed it to detect the "relative" true scores of population abundance. There is still some noise, but the classifier does a good job at predicting orders given its training and our actual plot data. Interestingly enough, the classifier never predicted all. This is actually a good sign for two reasons. For starters, it was only trained on one row that scored it as "all". Additionally, only one plot within the prediction dataset contained an "all" for scam, but there is some skepticim to the rest of the area within the plot, which most likely was not all scam. For these reasons, it is not that concerning that the model lacks the result of "all" for scam.
