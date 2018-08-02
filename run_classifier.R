# Aidan Draper 
# R script to run classifier models given the species name
# June 17, 2018

rm(list=ls())

library(ggplot2)
library(randomForest)
library(gridExtra)
library(reprtree)

# To install the reprtree package off of GitHub (run once initially then recomment it out)
#options(repos='http://cran.rstudio.org')
#have.packages <- installed.packages()
#cran.packages <- c('devtools','plotrix','randomForest','tree')
#to.install <- setdiff(cran.packages, have.packages[,1])
#if(length(to.install)>0) install.packages(to.install)
#
#library(devtools)
#if(!('reprtree' %in% installed.packages())){
#  install_github('araastat/reprtree')
#}
#for(p in c(cran.packages, 'reprtree')) eval(substitute(library(pkg), list(pkg=p)))


setwd("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/")
load(file='training_set.rda')

set.seed(2000)

curr.species = 'phau'
current <- training[,which(names(training)==curr.species)]
samp <- sample(nrow(training), .6 * nrow(training))
train <- training[samp,]
test <- training[-samp,]

model = randomForest(phau ~ .,data = train[,-c(1:6,8:11,17)], keep.forest=TRUE)

model

reprtree:::plot.getTree(model) #produce the random forest tree visual

#save(model, file=paste("Classifiers/",curr.species,"_model.rda",sep=""))

#par(bg = '#ecf0f8f9')
#plot(0, 0, type="n", ann=FALSE, axes=FALSE)
#u <- par("usr") # The coordinates of the plot area
#rect(u[1], u[3], u[2], u[4], col="white", border=NA)
#par(new=TRUE)
plot(model, main="", cex.main=2, cex.lab=1.4, cex.axis=1.4)

#par(bg = '#ecf0f8f9')
#plot(0, 0, type="n", ann=FALSE, axes=FALSE)
#u <- par("usr") # The coordinates of the plot area
#rect(u[1] + 0.07, u[3], u[2], u[4], col="white", border=NA)
#par(new=TRUE)
varImpPlot(model, main="", cex.main=2, cex.lab=1.4, cex.axis=1.4)

pred <- predict(model, newdata = test)
table(pred, test$phau)

pred <- factor(pred, levels = c("0%", "less than 1%", "1 - 5%", "6% - 25%", "26 - 50%", "51 - 75%", "76% - 100%"))
cols = c("0%"="#ceb467", "less than 1%" = "#ace5b2", "1 - 5%" = "#7aef87", "6% - 25%" = "#57d165", "26 - 50%" = "#21a31d", "51 - 75%" = "#197f24", "76% - 100%" = "#115118")

pred.graph <- ggplot() +
  geom_rect(data=test, aes(xmin=easting, xmax=easting + 30, ymin=northing, ymax=northing + 30, fill = as.factor(unlist(pred))), color="black") +
  labs(title=paste("Pop. Abundance Prediction on 40% of Plots"), x="Easting", y="Northing", fill="Cover") +
  scale_x_continuous(limits = c(365430, 366280)) +
  scale_y_continuous(limits = c(4303800, 4304470)) + 
  scale_fill_manual(values = cols)

pred.graph
#ggsave(paste("plots/prediction_visual_",curr.species,"2.png", sep=""))


# predict all of data to see all classifications

pred2 <- predict(model, newdata = training)
table(pred2, training$phau)
pred2 <- factor(pred2, levels = c("0%", "less than 1%", "1 - 5%", "6% - 25%", "26 - 50%", "51 - 75%", "76% - 100%"))
#cols = c("0%"="#ceb467", "less than 1%" = "#ace5b2", "1 - 5%" = "#7aef87", "6% - 25%" = "#57d165", "26 - 50%" = "#21a31d", "51 - 75%" = "#197f24", "76% - 100%" = "#115118")

# red scale for Phrag
cols = c("0%"="#ceb467", "less than 1%" = "#fce0e0", "1 - 5%" = "#ffa8a8", "6% - 25%" = "#f26a6a", "26 - 50%" = "#e83e3e", "51 - 75%" = "#c12020", "76% - 100%" = "#891818")

# blue scale for scam
#cols = c("0%"="#ceb467", "less than 1%" = "#d1ddfc", "1 - 5%" = "#adc0f4", "6% - 25%" = "#8ba6f4", "26 - 50%" = "#5e82ed", "51 - 75%" = "#2c2ccc", "76% - 100%" = "#231572")



pred2.graph <- ggplot() +
  geom_rect(data=training, aes(xmin=easting, xmax=easting + 30, ymin=northing, ymax=northing + 30, fill = as.factor(unlist(pred2))), color="black") +
  labs(title=paste("Phragmites Population Classifier Predictions"),x="Easting", y="Northing", fill="Cover") +
  scale_x_continuous(limits = c(365430, 366280)) +
  scale_y_continuous(limits = c(4303800, 4304470)) + 
  scale_fill_manual(values = cols) + theme(plot.background = element_rect(fill = 'white'),
                                           axis.line=element_blank(),
                                           axis.text.x=element_blank(),
                                           axis.text.y=element_blank(),
                                           axis.ticks=element_blank(),
                                           axis.title.x=element_blank(),
                                           axis.title.y=element_blank())

pred2.graph


# # model comparison without less important variables
# model2 = randomForest(phau ~ .,data = train[,-c(1:3,5, 9, 10, 18)], keep.forest=TRUE)
# 
# model2
# 
# plot(model2)
# varImpPlot(model2)
# 
# pred2 <- predict(model2, newdata = test)
# table(pred2, test$scam)
# 
# pred2 <- factor(pred, levels = c("none", "few", "few more", "little", "some", "most", "all"))
# cols = c("none"="#ceb467", "few" = "#ace5b2", "few more" = "#7aef87", "little" = "#57d165", "some" = "#21a31d", "most" = "#197f24", "all" = "#115118")
# 
# pred2.graph <- ggplot(data=test) +
#   geom_rect(aes(xmin=easting, xmax=easting + 30, ymin=northing, ymax=northing + 30, fill = as.factor(unlist(pred2))), color="black") + 
#   labs(title=paste(curr.species, "Population Abundance Predictions"), x="Easting", y="Northing", fill="Cover") +
#   scale_x_continuous(limits = c(365430, 366280)) +
#   scale_y_continuous(limits = c(4303800, 4304470)) +
#   scale_fill_manual(values = cols)
# 
# pred2.graph

#ggsave(paste("plots/prediction_visual_",curr.species,".png", sep=""))

# need to run training.R concurrently
grid.arrange(serc.plots, pred2.graph, ncol=2)
#ggsave(paste("plots/plot_comparison_",curr.species,".png", sep=""), arrangeGrob(serc.plots, pred2.graph, ncol=2), width = 14)

