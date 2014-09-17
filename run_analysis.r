## AUTHOR:      Joshua Poirier
## Course:      Coursera getdata-007
## Instructor:  Jeff Leek
##
## Description: Course project
##              To demonstrate ability to collect, work with, and clean a data set
##
## NOTES:       OS:     Windows 7 Professional
##              RAM:    6.00 GB
run_analysis <- function() {
    library(dplyr)
    library(tidyr)
    
    ## Download and unzip the data set
    download_unzip(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                   fname = "getdata-projectfiles-UCI HAR Dataset.zip")
    
    ## Read the data
    columnNames <- read.table("./UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)[,2]
    trainingData <- read.table("./UCI HAR Dataset/train/X_train.txt", col.names = columnNames)
    testData <- read.table("./UCI HAR Dataset/test/X_test.txt", col.names = columnNames)
    print(head(testData,3))
    
    ## ** PART ONE ** Merge the training and test sets
    data <- rbind_list(trainingData, testData)
    rm(columnNames, trainingData, testData)
    
    ## ** PART TWO ** Extract only the measurements on the mean and standard deviation
    data %>%
        select(contains("mean()"), contains("std()")) %>%
        dim()
    
    ## ** PART THREE **
    
    ## ** PART FOUR **
    
    ## ** PART FIVE **
}

## This function downloads a compressed file (*.zip) and unzips it into the working directory
## PRE:     url - the URL of the file to be downloaded
##          fname - what name to save the file as (in the data subfolder)
## POST:    the file is downloaded (if it doesn't exist) to the data subfolder, and unzipped to the
##          working directory
download_unzip <- function(url, fname) {
    if (!file.exists("./data")) dir.create("data")
    if (!file.exists(paste("./data/", fname, sep=""))) {
        download.file(url, paste("./data/", fname, sep=""))
    }
    
    ## Unzip the data (overwrites previous unzips)
    unzip(paste("./data/", fname, sep=""))
}