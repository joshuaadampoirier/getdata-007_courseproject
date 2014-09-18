## ####################################################################################################
## AUTHOR:      Joshua Poirier
## Course:      Coursera getdata-007
## Instructor:  Jeff Leek
##
## Description: Course project
##              To demonstrate ability to collect, work with, and clean a data set
##
## NOTES:       OS:     Windows 7 Professional
##              RAM:    6.00 GB
## ####################################################################################################
run_analysis <- function() {
    
    library(dplyr)
    library(tidyr)
    
    ## Download and unzip the data set (uses download_unzip() function found below)
    download_unzip(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                   fname = "getdata-projectfiles-UCI HAR Dataset.zip")
    
    ## Read the data - add 'Status' column indicating training or test data
    ##      NOTE:  Assume features.txt is clean and does not require modifications
    columnNames <- cleanColumns()
    trainingData <- read.table("./UCI HAR Dataset/train/X_train.txt", col.names = columnNames)
    testData <- read.table("./UCI HAR Dataset/test/X_test.txt", col.names = columnNames)
    trainingData$Status = "Training"
    testData$Status = "Test"
    
    ## ** PART ONE ** Merge the training and test sets
    data <- rbind_list(trainingData, testData)
    rm(columnNames, trainingData, testData)     # cleanup memory
    
    ## ** PART TWO ** Extract only the measurements on the mean and standard deviation
    data <- select(data, contains("mean"), contains("std"), -contains("meanFreq"), -contains("angle"), -contains("gravityMean")) 
    
    ## ** PART THREE ** Create descriptive activity variable column by linking the 'X' data files with
    ##                  the 'Y' activity data and 'activity labels' files
    ##      NOTE:   1)  This part utilizes the getActivityData() function found below
    ##              2)  We will also add a "subject" variable based on subject_test.txt and 
    ##                  subject_train.txt
    trainingAct <- getActivityData("./UCI HAR Dataset/train/y_train.txt")
    testAct <- getActivityData("./UCI HAR Dataset/test/y_test.txt")
    ActivityLabel <- rbind_list(trainingAct, testAct)$ActivityLabel
    trainingSubjects <- read.table("./UCI HAR Dataset/train/subject_train.txt", col.names = "SubjectKey")
    testSubjects <- read.table("./UCI HAR Dataset/test/subject_test.txt", col.names = "SubjectKey")
    SubjectKey <- rbind_list(trainingSubjects, testSubjects)
    data <- cbind(ActivityLabel, SubjectKey, data)
    
    ## ** PART FOUR **
    data$obsNum <- seq_len(nrow(data))
    data <- gather(data, variable, statisticValue, -ActivityLabel, -SubjectKey, -obsNum, -contains("angle"))
    data <- separate(data, col = variable, into = c("Domain", "variable"), sep = 1)
    data <- separate(data, col = variable, into = c("measurement", "statistic", "component"))
    data <- spread(data, statistic, statisticValue)
    
    ## TO DO:
        ## Convert components which are string "NA" to actual NA's
        ## To factors: ActivityLabel, SubjectKey, obsNum, Domain, measurement, component
    
    ## ** PART FIVE **
    
    data
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

cleanColumns <- function() {
    
    columnNames <- read.table("./UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)[,2]
    columnNames <- gsub("()", "", columnNames, fixed = TRUE)
    
    for(i in 1:length(columnNames)) {
        if (substring(columnNames[i], nchar(columnNames[i]) - 3) == "mean") {
            columnNames[i] <- paste(columnNames[i], "-NA")
        }
        else if (substring(columnNames[i], nchar(columnNames[i]) - 2) == "std") {
            columnNames[i] <- paste(columnNames[i], "-NA")
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
