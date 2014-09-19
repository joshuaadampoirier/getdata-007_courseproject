---
title: "Course Project Codebook"
author: "Joshua Poirier"
date: "Friday, September 19, 2014"
output: html_document
---

### Code Book
This section refers to the final data output via **Step 5** of the run_analysis() program.  Later sections of this code book will describe what processes were applied to each variable to get from the raw data to this data set.

- Measurement
    - The type of measurement applied for this observation.  This value is a factor.
    - This variable was parsed out of the column names from the raw data set during **Step Four**.  It is assumed that these are separate observations.
        - BodyAcc: Body Acceleration
        - BodyAccJerk: Body Acceleration Jerk (time derivative of the acceleration)
        - BodyAccJerkMag: Magnitude of Body Jerk
        - BodyAccMag: Magnitude of Body Acceleration
        - BodyGyro: Body Gyro
        - BodyGyroJerk: Body Gyro Jerk (time derivative of the acceleration)
        - BodyGyroJerkMag: Body Gyro Jerk Magnitude
        - BodyGyroMag: Body Gyro Magnitude
        - GravityAcc: Gravity Acceleration
        - GravityAccMag: Gravity Acceleration Magnitude
        
- Component
    - This refers to the component of the observation.  This value is a factor.
    - This variable was parsed out of the column names from the raw data set.  Those columns containing an *X* surrounded by special characters (eg *-X-*) were considered to be X-component observations.  Columns without *X*, *Y*, or *Z* are considered *Scalar* observations - as they are the vector sum of the components.  This variable is parsed out during **Step Four**.
        - Scalar: This is a magnitude observation
        - X: This is a x-component vector observation
        - Y: This is a y-component vector observation
        - Z: This is a z-component vector observation
    
- Domain
    - This refers to the domain for which the observation takes place.  This value is a factor.
    - This variable was parsed out of the column names from the raw data set.  Columns beginning with a *t* are time domain observations, and columns beginning with an *f* are frequency domain observations.  This variable is parsed out during **Step Four**.
        - f: This is a frequency domain observation
        - t: This is a time domain observation
        
- Activity
    - This describes the activity which the subject was performing during the observation.  This value is a factor.
    - This data was read into the data frame during **Step 3**.  The variable used the subject ID (which was read in for each observation) as a key for joining to the actual activity descriptions.
        - LAYING: The subject was laying down during the observation
        - SITTING: The subject was sitting during the observation
        - STANDING: The subject was standing during the observation
        - WALKING: The subject was walking during the observation
        - WALKING_DOWNSTAIRS: The subject was walking *down* stairs during the observation
        - WALKING_UPSTAIRS: The subject was walking *up* stairs during the observation
        
- SubjectKey
    - This is the ID of the subject who is being observed.  This value is a factor.
    - This variable was read into the data frame during **Step Three** from the raw data.  Implicit row coercion was used as there was no key linking the separate files.
        - 1-30: The ID of the subject (a descriptive table was not provided with the raw data set)
    
- Mean_mean
    - This is the average value of the *mean* statistic given the above parameters.  This value is a numeric.  It was calculated using the *aggregate()* function of the **dplyr** package.
    
- Mean_std
    - This is the average value of the *standard deviation* statistic given the same set of parameters used to generate the *Mean_mean* variable.  This value is a numeric.  It was calculated using the *aggregate()* function of the **dplyr** package.
    
### Raw Data Code Book
Please view the raw data code book.  Raw data is available for download here: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip.