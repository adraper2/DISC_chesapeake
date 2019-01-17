# Meeting Notes - Post Skype call reflection

I have recorded notes from meetings dated below. (Select a date to jump to that meeting's header.)
> [November 20th, 2018](https://github.com/adraper2/DISC_chesapeake/blob/master/Meetings/MeetingNotes.md#november-20th-2018-meeting-with-jason-haley-and-megan)

> [January 10th, 2019](https://github.com/adraper2/DISC_chesapeake/blob/master/Meetings/MeetingNotes.md#january-10th-2019-meeting-with-jason-haley-and-megan)

### November 20th, 2018 (Meeting with Jason, Haley and Megan)
Today we discussed the next steps to the project. I will be talking about our direction as well as my to-do list for the rest of the Fall semester. We also discussed a bunch of different methodologies/complexities that either directly relate to what we are currently working with or that might be interesting to look at in the future. 

**These directions included:**
- Creating multiple models for each month using the current code
- Exploring sampling techniques for spatial resolutions with multiple SERC plots: this included adding weights to the sample function in R, a clustered sampling approach based on plot, or sampling plots without replacement in general. We were somewhat worried about grabbing the *outlier* plot from a group of three where clearly the other two might be better fits to what the whole resolution describes
- Creating a "best-fit" peak-greeness spatial resolution training set from multiple images
- Heterogeneity in plots: comparing a model that uses multiple plots in the same resolution (our original model) vs. a model that uses a sampling technique to only use one plot in each resolution
- Creating a statistical / probabilistic model that took into account multiple plots from different times periods
- Considering the position that plots fit within the spatial resolution. For example, euclidean distance to the centroid of a resolution as a way to select what plots to use

We seem to most interested about identifying peak-greeness for the species *Schoenoplectus Americanus*, Phragmites, and C4. This means potentially identifying the curvature that leads to a peak time period across Landsat images. This would be a line graph with each critical point in the curvature of the line being a Landsat image on the x-axis and the species abundance (no NA or none), or summation of just most 75-100% plots identified, for the specific species. Essentially its a time series plot. The hope is that it can tell us the months or time period in which we can expect a species to be performing the best. Knowing this can help us identify when to fly drones and when to attempt to classify species abundance from past years (because it should be easiest to identify species during their peak-greeness rather than when they are mostly dead...).

We had multiple concerns that arose while discussing the past model. The first being that we were just using a single image (August 19th), which means that species that are not even close to suspected peak-greeness, like C4, are suffering at being identified. Another was that we haven't checked two details about the covariates we are using in the original model. This included colinearity in variables to see if they have the same variable importance when testing new datasets. The other sanity check was about variables being dependent or correlated with one another, which means they might be weighted too similarly in the way that they predict, which would mean there is bias in our covariates. Additionally, we mentioned that there is some consideration needed in sampling multiple plots from the same plot id. I will need to updates lines 37-40 in `run_classifier.R` file.

**The tasks we mentioned were:**
- [ ] Looking at colinearity between variables (something that Megan and Haley may be able to do together): this may mean grabbing some covariates we weeded out from before
- [ ] **I meant to mention this during the skype call but, forgot. Megan mentioned that she had to look at the correlation between covariates because if there is too much correlation that can affect the model as well. This has not been done yet.**

**My next steps are:**
- [x] Creating a bulleted list of what will be included in the paper as of now
- [ ] Creating a collection of models based on **cloudless** images from 2015 to 2017 and rerunning the last code that tests the August model on those images

**The original model may need updates in these areas:**
- Heterogeneity between covariates in case they are dependent on one another (which is probably true considering we use covariates made from bands and then also the bands themselves) **STILL NEED TO DO**
- ~~Colinearity check for sanity~~ *This was done*

### January 10th, 2019 (Meeting with Jason, Haley and Megan)
Today we talked about project progress, what people can be doing to help, authorship, and also levels of depth in explaining importance in papers.

**Project Progress:**
I have just finished fixing a bug in sampling where we were not using unique rows/plots from the dataset to train the model (01/17/2019). Additionally, I have started an Overleaf Latex file that I will be sharing with Haley so that writing progress can be made. 

**What Everyone is Doing:**
- Haley: assisting with paper
- Megan: sharing resources (R packages, related publications, and more) and is available for any questions / help
- Aidan: is structuring paper, writing, and fixing past model before transitioning back to 2016 *cloudless* predictions.

**Depth in paper explanation:**
I quickly learned that I was too big picture in my intro to the paper. I have since deleted the intro that I had. I am going back and explaining the direct importance and relevance of this model as well as how it relates to just a slight bigger picture in what the McLachlan Lab and SERC are studying themselves. 

**The tasks we mentioned were:**
- [ ] Looking at colinearity between variables (Megan shared the R package,
 `rfUtilities`, with me)
- [ ] Correcting for top of atmosphere reflectance, which we forgot to do. This can be done with the `reflconvS` R package
- [ ] Paper writing in general. (I have shared the file with Haley)

**My next steps are:**
- [x] Working through the row / plot ID selection bug that I had.
- [ ] Reworking the introduction to the paper and writing as much as I can of what we have done.
- [ ] Correcting TOA with `reflconvS`
- [ ] Checking colinearity with `rfUtilities`
- [ ] Rerunnning 2016 images with cloudless images only and corrected model


