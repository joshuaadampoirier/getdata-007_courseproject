## ###################################################################################################
## AUTHOR:      Joshua Poirier
## Course:      Coursera getdata-007
## Instructor:  Jeff Leek
##
## Description: Course project
##              To demonstrate ability to collect, work with, and clean a data set
##
## NOTES:       OS:     Windows 7 Professional
##              RAM:    6.00 GB
## ASSUMPTIONS: Without intimate knowledge of the physics involved, or access to personnel with such
##              knowledge, several assumptions are made about the dataset regarding what are 
##              'variables' and what are 'observations'.  For the purposes of this exercise, the only
##              quantitative variables under consideration are mean and standard deviation for each
##              measurement.  The measurements themselves will be considered to be variables, as are
##              their domain.  The author recognizes that this could be interpreted otherwise;
##              however, it is the author's opinion that the methods taken result in the tidyest data
##              set.
## ###################################################################################################
run_analysis <- function() {
    
    library(dplyr)
    library(tidyr)
    
    ## Download and unzip the data set
    download_unzip(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                   fname = "getdata-projectfiles-UCI HAR Dataset.zip")
    
    ## ** PART ONE **
    ## ###############################################################################################
    ## PURPOSE: Read and merge the training and test data sets into one data set
    ## NOTES:   1)  The downloaded zip file was extracted to the working directory, so the files are
    ##              located in the 'UCI HAR Dataset' subfolder
    ##          2)  Assume whether the dataset is 'training' or 'test' is irrelevant (we don't need
    ##              to add a status variable), as it is not mentioned in the project outline
    ## ###############################################################################################
    columnNames <- cleanColumns()
    trainingData <- read.table("./UCI HAR Dataset/train/X_train.txt", col.names = columnNames)
    testData <- read.table("./UCI HAR Dataset/test/X_test.txt", col.names = columnNames)
    data <- rbind_list(trainingData, testData)
    rm(columnNames, trainingData, testData)     # cleanup memory
    
    
    ## ** PART TWO **
    ## ###############################################################################################
    ## PURPOSE: Extract only the measurements on the mean and standard deviation
    ## NOTES:   1)  Assume that we can ignore those columns containing "meanFreq", "angle", and 
    ##              "gravityMean" as they are not a true mean or standard deviation for their
    ##              respective measurements
    ## ###############################################################################################
    data <- select(data, 
                   contains("mean"), 
                   contains("std"), 
                   -contains("meanFreq"), 
                   -contains("angle"), 
                   -contains("gravityMean")) 
    
    
    ## ** PART THREE **
    ## ###############################################################################################
    ## PURPOSE: Use the descriptive activity names (from activity_labels.txt) to name the activities
    ##          in the data set
    ## NOTES:   1)  Must first read in and merge the training/test activity data files, and merge with
    ##              the main data frame.  It is implicit that the order of the rows match, so column
    ##              binding is acceptable.
    ##          2)  The activity data is read by the getActivityData() function found below.
    ##          3)  We also add the training/test subject data in this step
    ## ###############################################################################################
    trainingAct <- getActivityData("./UCI HAR Dataset/train/y_train.txt")
    testAct <- getActivityData("./UCI HAR Dataset/test/y_test.txt")
    ActivityLabel <- rbind_list(trainingAct, testAct)$ActivityLabel
    trainingSubjects <- read.table("./UCI HAR Dataset/train/subject_train.txt", 
                                   col.names = "SubjectKey")
    testSubjects <- read.table("./UCI HAR Dataset/test/subject_test.txt", 
                               col.names = "SubjectKey")
    SubjectKey <- rbind_list(trainingSubjects, testSubjects)
    data <- cbind(ActivityLabel, SubjectKey, data)
    
    
    ## ** PART FOUR ** Appropriately label the data set with descriptive variable names
    ##      NOTE:   1) This part utilizes the toFactors() function, converting several of the variables
    ##              to factors
    ##              2) It also adds an 'obsNum' observation number column - just an ID variable
    ## ** PART FOUR **
    ## ###############################################################################################
    ## PURPOSE: Appropriately label the data set with descriptive variable names
    ## NOTES:   1)  We add an 'obsNum' observation number column - just a unique ID variable
    ##          2)  This part uses the function toFactors() found below - this converts a number of
    ##              the variables to factors (used in Part Five).
    ## ###############################################################################################
    data$obsNum <- seq_len(nrow(data))
    data <- gather(data, 
                   variable, 
                   statisticValue, 
                   -ActivityLabel, 
                   -SubjectKey, 
                   -obsNum, 
                   -contains("angle"))
    data <- separate(data, col = variable, into = c("Domain", "variable"), sep = 1)
    data <- separate(data, col = variable, into = c("measurement", "statistic", "component"))
    data <- spread(data, statistic, statisticValue)
    data <- toFactors(data)
    write.table(data, file="tidyData.txt", sep=",", row.name=FALSE)
    
    
    ## ** PART FIVE **
    ## ###############################################################################################
    ## PURPOSE: Create a second, independent tidy data set with the average of each variable for each
    ##          activity and each subject.
    ## NOTES:   1)  Since we have created qualitative variables for Activity, Subject, Domain, 
    ##              Measurement, and Component - we will have to aggregate on all of these
    ## ###############################################################################################
    data2 <- with(data,
                  aggregate(data.frame(data$mean, data$std), 
                            by=list(measurement, component, Domain, ActivityLabel, SubjectKey),
                            FUN = mean))
    names(data2) <- c("Measurement", "Component", "Domain", "Activity", "SubjectKey", "Mean_mean", "Mean_std")
    write.table(data2, file="tidySummary.txt", sep=",", row.name=FALSE)

    data2    
    
}

## ####################################################################################################
## This function downloads a compressed file (*.zip) and unzips it into the working directory
## PRE:     url - the URL of the file to be downloaded
##          fname - what name to save the file as (in the data subfolder)
## POST:    the file is downloaded (if it doesn't exist) to the data subfolder, and unzipped to the
##          working directory
## ####################################################################################################
download_unzip <- function(url, fname) {

    if (!file.exists("./data")) dir.create("data")
    if (!file.exists(paste("./data/", fname, sep=""))) {
        download.file(url, paste("./data/", fname, sep=""))
    }
    
    ## Unzip the data (overwrites previous unzips)
    unzip(paste("./data/", fname, sep=""))
    
}

## ####################################################################################################
## This function reads the activity label file and a given activity data file located in the 
## 'UCI HAR Dataset' subfolder (relative to the working directory), and returns a data frame of its 
## contents (with the ACTIVITY LABELS included).
## PRE:     none
## POST:    returns a data frame containing the activity data, including the ACTIVITY LABEL as a 
##          column.
## ####################################################################################################
getActivityData <- function(fname) {
    
    ## Read activity labels file
    columnNames <- c("ActivityKey", "ActivityLabel")
    activities <- read.table("./UCI HAR Dataset/activity_labels.txt", col.names = columnNames)
    
    ## Read activity data file
    activityData <- read.table(fname, col.names = "ActivityKey")
    
    ## Get activity label from 'activities' data frame
    activityData <- inner_join(activityData, activities, by = "ActivityKey")
    
}

## ###################################################################################################
## This function performs a variety of tasks to clean the names of the columns in the original data
## frame.  This includes removing brackets, and re-ordering the location of vector components (ie x,
## y, and z).
## PRE:     none
## POST:    a character vector containing the 'clean' column names (relating to the data set) is
##          returned
## ###################################################################################################
cleanColumns <- function() {
    
    ## read in column names from the features.txt file
    columnNames <- read.table("./UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)[,2]

    ## start cleaning the column names
    columnNames <- gsub("()", "", columnNames, fixed = TRUE)
    
    for(i in 1:length(columnNames)) {
        if (substring(columnNames[i], nchar(columnNames[i]) - 3) == "mean") {
            columnNames[i] <- paste(columnNames[i], "-Scalar")
        }
        else if (substring(columnNames[i], nchar(columnNames[i]) - 2) == "std") {
            columnNames[i] <- paste(columnNames[i], "-Scalar")
        }
    }
    
    columnNames <- gsub("BodyBody", "Body", columnNames)
    columnNames <- gsub("mean-x", "x-mean", columnNames)
    columnNames <- gsub("std-x", "x-std", columnNames)
    columnNames <- gsub("mean-y", "y-mean", columnNames)
    columnNames <- gsub("std-y", "y-std", columnNames)
    columnNames <- gsub("mean-z", "z-mean", columnNames)
    columnNames <- gsub("std-z", "z-std", columnNames)
    
    columnNames
    
}

## ###################################################################################################
## This function converts several of the variables in the data set to factors (as they are qualitative
## variables - not quantitative!).
## PRE:     data - the data frame containing variables to be converted to factors
## POST:    data - the data frame containing converted variables is returned
## ###################################################################################################
toFactors <- function(data) {

    ## convert variables to factors
    data$ActivityLabel <- as.factor(data$ActivityLabel)
    data$SubjectKey <- as.factor(data$SubjectKey)
    data$Domain <- as.factor(data$Domain)
    data$measurement <- as.factor(data$measurement)
    data$component <- as.factor(data$component) 
    
    data
}