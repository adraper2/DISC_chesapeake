# Meeting Notes - Post Skype call reflection

I have recorded notes from meetings dated below. (Select a date to jump to that meeting's header.)
> [November 20th, 2018](https://github.com/adraper2/DISC_chesapeake/blob/master/Meetings/MeetingNotes.md#november-20th-2018)

### November 20th, 2018 (Meeting with Jason, Haley and Megan)
Today we discussed the next steps to the project. I will be talking about our direction as well as my to-do list for the rest of the Fall semester. We also discussed a bunch of different methodologies/complexities that either directly relate to what we are currently working with or that might be interesting to look at in the future. 

These directions included:
- Creating multiple models for each month using the current code
- Exploring sampling techniques for spatial resolutions with multiple SERC plots: this included adding weights to the sample function in R, a clustered sampling approach based on plot, or sampling plots without replacement in general. We were somewhat worried about grabbing the *outlier* plot from a group of three where clearly the other two might be better fits to what the whole resolution describes
- Creating a "best-fit" peak-greeness spatial resolution training set from multiple images
- Heterogeneity in plots: comparing models
- Creating a statistical / probabilistic model that took into account multiple plots from different times periods
- Considering the position that plots fit within the spatial resolution. For example, euclidean distance to the centroid of a resolution as a way to select what plots to use

We seem to most interested about identifying peak-greeness for the species *Schoenoplectus Americanus*, Phragmites, and C4. This means potentially identifying the curvature that leads to a peak time period across Landsat images. This would be a line graph with each critical point in the curvature of the line being a Landsat image on the x-axis and the species abundance (no NA or none), or summation of just most 75-100% plots identified, for the specific species. Essentially its a time series plot. The hope is that it can tell us the months or time period in which we can expect a species to be performing the best. Knowing this can help us identify when to fly drones and when to attempt to classify species abundance from past years (because it should be easiest to identify species during their peak-greeness rather than when they are mostly dead...).

We had multiple concerns that arose while discussing the past model. The first being that we were just using a single image (August 19th), which means that species that are not even close to suspected peak-greeness, like C4, are suffering at being identified. Another was that we haven't checked two details about the covariates we are using in the original model. This included colinearity in variables to see if they have the same variable importance when testing new datasets. The other sanity check was about variables being dependent or correlated with one another, which means they might be weighted too similarly in the way that they predict, which would mean there is bias in our covariates. Additionally, we mentioned that there is some consideration needed in sampling multiple plots from the same plot id. I will need to updates lines 37-40 in `run_classifier.R` file.

The tasks we mentioned were:
[] Looking at colinearity between variables (something that Megan and Haley may be able to do together): this may mean grabbing some covariates we weeded out from before
[] **I meant to mention this during the skype call but, forgot. Megan mentioned that she had to look at the correlation between covariates because if there is too much correlation that can affect the model as well. This has not been done yet.**

My next steps are:
[] Creating a bulleted list of what will be included in the paper as of now
[] Creating a collection of models based on **cloudless** images from 2015 to 2017 and rerunning the last code that tests the August model on those images

**The original model may need updates in these areas:**
- Heterogeneity between covariates in case they are dependent on one another (which is probably true considering we use covariates made from bands and then also the bands themselves)
- Colinearity check for sanity
