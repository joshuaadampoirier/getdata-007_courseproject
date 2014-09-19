getdata-007_courseproject
=========================

Course project submission for Coursera course getdata-007 (Getting and Cleaning Data via John Hopkin's University).

## Overview
The purpose of this project is to demonstrate my ability to collect, work with, and clean a data set.  A data set was given related to fitness trackers on a cell phone (using accelerometers).  The author (I) have followed the Project Instructions to the best of my ability, and used my judgement when required.
Without intimate knowledge of the physics involved, several assumptions were made regarding the nature and meaning of the dataset - specifically what are variables vs. observations.  For the purpose of this assignment, it is assumed that the only quantitative variables are mean and standard deviation (whereas the measurement types are observations).  The auther acknowledges that this could be interpreted otherwise; however, feels it results in the tidiest data set possible.
This repository contains this three files:
* CODEBOOK.md
* README.md
* run_analysis.r
### CODEBOOK.md 
This file contains a summary of the variables output through **Step 5** of the program, as well as an overview of the transformations applied to the raw data set to get them.

### README.md 
This file, it contains an overview of the data repository, and the algorithms used through **Steps 1-5**.

### run_analysis.r 
This file contains the code submission.  It completes the following tasks:
* Download the data to a ./data subfolder (if not already downloaded)
* Unzip the data file to the working directory (overwrites existing files)
* Read the training and test data sets
* Steps 1-5
* Writes the results of Step 4 and Step 5 to separate text files

## Run Analysis Code
### Functions
The *run_analysis.r* file contains the following functions:
* run_analysis() - main function
* download_unzip(url, fname) - helper function
* getActivityData(fname) - helper function
* cleanColumns() - helper function
* toFactors() - helper function

### Step One
This step reads and merges the *training* and *test* data sets into memory.  It is important to note that since there was no mention within the Project Description, it is assumed that the distinction between *training* and *test* data is unimportant.  As such, no *status* variable (indicating if the observation is *training* or *test*) was created.

### Step Two
This step extracts only the mean and standard deviation statistics of the measurements.  It is assumed that those statistical variables which are *meanFreq*, *angle*, or *gravityMean* are not of interest and can be excluded from this analysis.  This is performed by using the *select()* function from the **dplyr** package.

### Step Three
This step imports descriptive activity names (*WALKING*, *SITTING*, etc) from the *activity_labels.txt* file.  It first requires reading the *training* and *test* activity data sets - containing the activity ID's (not the descriptive labels).  This is performed by the *getActivityData(fname) function, which also joins this data set with the descriptive labels.  Column binding the returned descriptive labels to the main data set is then performed (since there is no joining ID, it is implicit that the rows line up).

### Step Four
This step appropriately labels the data set's variables with descriptive names.  Prior to reshaping the data frame, a unique observation number is added (which allows for tracking and additional manipulations).  
The *gather()* (from the **dplyr** package) function is used to convert the structured variable names into a measurement variable.  These measurement variables are then split (using the *spread()* function from the **dplyr** package), extracting out the domain (time or frequency), measurement, statistic, and component (vector *x*, *y*, or *z*, or a *scalar*).  **dplyr**'s *spread()* function is then used to convert the mean and standard devation (the statistic variable) into variables of their own.  For the purposes of this assignment, these represent our quantitative variables.
This step then also converts all variables (except *mean* and *standard devation*) into factors using the *toFactors()* function, and exports the resulting data frame to a text file.

### Step Five
This step creates an independent, tidy data set with the average for each variable.  This is performed using **dplyr**'s *aggregate()* function.  The names of the resulting data frames' variables are then updated, and the data frame exported to a text file (and submitted on the Coursera website, so it's not here!).  Finally, the data frame created in this step is returned.