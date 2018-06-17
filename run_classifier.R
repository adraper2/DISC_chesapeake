# Aidan Draper 
# R script to run classifier models given the species name
# June 17, 2018


setwd("~/Documents/Junior_Year/DISC_REU/DISC_chesapeake/")
load(file='training_set.rda')

curr.species = 'scam'
current <- training[,which(names(training)==curr.species)]
samp <- sample(nrow(training), .6 * nrow(training))
train <- training[samp,]
test <- training[-samp,]

model = randomForest(scam ~ .,data = train[,-c(1:2)], keep.forest=TRUE)

model

plot(model)
varImpPlot(model)

pred <- predict(model, newdata = test)
table(pred, test$scam)