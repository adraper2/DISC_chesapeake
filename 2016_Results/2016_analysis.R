# Analyzing datasets for 2016 images
library(ggplot2)

setwd("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/2016_Results")

curr.species <- c("phau","scam","c4")
curr.date <- '07-18-2016'
load(paste(curr.date,"_results.rdata", sep=""))

levels(results$phau)

summary(results)[,4:6]

plots <- data.frame(plot.levels = c(as.factor(results$phau.pred), as.factor(results$scam.pred), as.factor(results$c4.pred)), species = c(rep("phau", 521),rep("scam", 521), rep("c4", 521)))

g <- ggplot(plots,aes(x=plot.levels))
g + geom_bar(aes(fill = species), stat="count") + labs(title = "Stacked Bar of Plot Levels", subtitle = paste(curr.date))


# red scale for Phrag
cols = c("0%"="#ceb467", "less than 1%" = "#fce0e0", "1 - 5%" = "#ffa8a8", "6% - 25%" = "#f26a6a", "26 - 50%" = "#e83e3e", "51 - 75%" = "#c12020", "76% - 100%" = "#891818")
phau.graph <- ggplot() +
  geom_rect(data=results, aes(xmin=easting, xmax=easting + 30, ymin=northing, ymax=northing + 30, fill = as.factor(unlist(results[which(names(results)==paste(curr.species[1],".pred",sep=""))]))), color="black") +
  labs(title=paste(paste(curr.species[1],curr.date, "Population Classifier Predictions")),x="Easting", y="Northing", fill="Cover") +
  scale_x_continuous(limits = c(365430, 366280)) +
  scale_y_continuous(limits = c(4303800, 4304470)) + 
  scale_fill_manual(values = cols) + theme(plot.background = element_rect(fill = 'white'),
                                           axis.line=element_blank(),
                                           axis.text.x=element_blank(),
                                           axis.text.y=element_blank(),
                                           axis.ticks=element_blank(),
                                           axis.title.x=element_blank(),
                                           axis.title.y=element_blank())

phau.graph


# blue scale for scam
cols = c("0%"="#ceb467", "less than 1%" = "#d1ddfc", "1 - 5%" = "#adc0f4", "6% - 25%" = "#8ba6f4", "26 - 50%" = "#5e82ed", "51 - 75%" = "#2c2ccc", "76% - 100%" = "#231572")
scam.graph <- ggplot() +
  geom_rect(data=results, aes(xmin=easting, xmax=easting + 30, ymin=northing, ymax=northing + 30, fill = as.factor(unlist(results[which(names(results)==paste(curr.species[2],".pred",sep=""))]))), color="black") +
  labs(title=paste(paste(curr.species[2],curr.date, "Population Classifier Predictions")),x="Easting", y="Northing", fill="Cover") +
  scale_x_continuous(limits = c(365430, 366280)) +
  scale_y_continuous(limits = c(4303800, 4304470)) + 
  scale_fill_manual(values = cols) + theme(plot.background = element_rect(fill = 'white'),
                                           axis.line=element_blank(),
                                           axis.text.x=element_blank(),
                                           axis.text.y=element_blank(),
                                           axis.ticks=element_blank(),
                                           axis.title.x=element_blank(),
                                           axis.title.y=element_blank())

scam.graph

#green scale for c4
cols = c("0%"="#ceb467", "less than 1%" = "#ace5b2", "1 - 5%" = "#7aef87", "6% - 25%" = "#57d165", "26 - 50%" = "#21a31d", "51 - 75%" = "#197f24", "76% - 100%" = "#115118")
c4.graph <- ggplot() +
  geom_rect(data=results, aes(xmin=easting, xmax=easting + 30, ymin=northing, ymax=northing + 30, fill = as.factor(unlist(results[which(names(results)==paste(curr.species[3],".pred",sep=""))]))), color="black") +
  labs(title=paste(paste(curr.species[3],curr.date, "Population Classifier Predictions")),x="Easting", y="Northing", fill="Cover") +
  scale_x_continuous(limits = c(365430, 366280)) +
  scale_y_continuous(limits = c(4303800, 4304470)) + 
  scale_fill_manual(values = cols) + theme(plot.background = element_rect(fill = 'white'),
                                           axis.line=element_blank(),
                                           axis.text.x=element_blank(),
                                           axis.text.y=element_blank(),
                                           axis.ticks=element_blank(),
                                           axis.title.x=element_blank(),
                                           axis.title.y=element_blank())

c4.graph


# time series
image.dates <- c("03-28","04-13","05-15","05-31","07-02","07-18","08-03","09-04","10-22","11-07","11-23")
phau.plots <- 0
scam.plots <- 0
c4.plots <- 0
for(x in 1:length(image.dates)){
  load(paste(image.dates[x],"-2016_results.rdata", sep=""))
  # grab plot 500, 901, & ___ for phau
  # grab plot ___, ___, & 1095 for scam
  #ADD CODE TO GRAB SPECIFC ROWS BASED ON PLOT ID
  
}

# use to find correct plot
results <- subset(results,  subset = plot.id > 1096)
results <- subset(results,  subset = plot.id < 900)
