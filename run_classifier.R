# Aidan Draper 
# R script to run classifier models given the species name
# June 17, 2018

rm(list=ls())

library(ggplot2)
library(randomForest)
library(gridExtra)

setwd("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/")
load(file='training_set.rda')

set.seed(2000)

curr.species = 'phau'
current <- training[,which(names(training)==curr.species)]
samp <- sample(nrow(training), .6 * nrow(training))
train <- training[samp,]
test <- training[-samp,]

model = randomForest(phau ~ .,data = train[,-c(1:4)], keep.forest=TRUE)

model

plot(model)
varImpPlot(model)

pred <- predict(model, newdata = test)
table(pred, test$scam)

pred <- factor(pred, levels = c("none", "few", "few more", "little", "some", "most", "all"))

pred.graph <- ggplot() +
  geom_rect(data=test, aes(xmin=easting, xmax=easting + 30, ymin=northing, ymax=northing + 30, fill = as.factor(unlist(pred))), color="black") +
  labs(title=paste(curr.species, "Population Abundance Prediction w/ all vars"), x="Easting", y="Northing", fill="Cover") +
  scale_x_continuous(limits = c(365430, 366280)) +
  scale_y_continuous(limits = c(4303800, 4304470)) 

pred.graph

ggsave(paste("plots/prediction_visual_",curr.species,".png", sep=""))



# model comparison without less important variables
model2 = randomForest(phau ~ .,data = train[,-c(1:3,5, 9, 10, 18)], keep.forest=TRUE)

model2

plot(model2)
varImpPlot(model2)

pred2 <- predict(model2, newdata = test)
table(pred2, test$scam)

pred2 <- factor(pred, levels = c("none", "few", "few more", "little", "some", "most", "all"))
cols = c("none"="#ceb467", "few" = "#ace5b2", "few more" = "#7aef87", "little" = "#57d165", "some" = "#21a31d", "most" = "#197f24", "all" = "#115118")

pred2.graph <- ggplot(data=test) +
  geom_rect(aes(xmin=easting, xmax=easting + 30, ymin=northing, ymax=northing + 30, fill = as.factor(unlist(pred2))), color="black") + 
  labs(title=paste(curr.species, "Population Abundance Predictions"), x="Easting", y="Northing", fill="Cover") +
  scale_x_continuous(limits = c(365430, 366280)) +
  scale_y_continuous(limits = c(4303800, 4304470)) +
  scale_fill_manual(values = cols)

pred2.graph

ggsave(paste("plots/prediction_visual_",curr.species,"2.png", sep=""))

# need to run training.R concurrently
grid.arrange(serc.plots, pred2.graph, ncol=2)
ggsave(paste("plots/plot_comparison_",curr.species,".png", sep=""), arrangeGrob(serc.plots, pred2.graph, ncol=2), width = 11)

