##Getting and Cleaning Data Course Project

## Setting working directory to Project_Module3

if (!file.exists('./Project_Module3')){
  dir.create("./Project_Module3")
}
setwd("~/Project_Module3")

##Downloading File 

fileurl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists("./UCI HARS Dataset")){
  download.file(fileurl,'UCI HARS Dataset.zip', mode = 'wb')
  unzip("UCI HARS Dataset.zip", exdir = getwd())
}

##Read and Convert Data

library(data.table)
setwd("~/Project_Module3/UCI HAR Dataset")
features <- read.csv('features.txt', header = FALSE, sep = ' ')
features <- as.character(features[,2])

trainX <- read.table('./train/X_train.txt')
trainY <- read.csv('./train/y_train.txt', header = FALSE, sep = ' ')
trainSubject <- read.csv('./train/subject_train.txt',header = FALSE, sep = ' ')

Train<-  data.frame(trainSubject, trainY, trainX)
names(Train) <- c(c('subject', 'activity'), features)

testX <- read.table('./test/X_test.txt')
testY <- read.csv('./test/y_test.txt', header = FALSE, sep = ' ')
testSubject <- read.csv('./test/subject_test.txt', header = FALSE, sep = ' ')

Test <-  data.frame(testSubject, testY, testX)
names(Test) <- c(c('subject', 'activity'), features)


##Merges the Training and Testing Sets into 1 data set

allData <- rbind(Train, Test)

##Extracts only the measurements on the mean and standard deviation for each measurement

mean_std <- grep('mean|std', features)
sub <- allData[,c(1,2,mean_std + 2)]

##Uses descriptive activity names to name the activities in the data set

activityLabels <- read.table('activity_labels.txt', header = FALSE)
activityLabels <- as.character(activityLabels[,2])
sub$activity <- activityLabels[sub$activity]

##Appropriately labels the data set with descriptive variable names.

nameNew <- names(sub)
nameNew <- gsub("[(][)]", "", nameNew)
nameNew <- gsub("^t", "Time Domain", nameNew)
nameNew <- gsub("^f", "Frequency Domain", nameNew)
nameNew <- gsub("Acc", "Accelerometer", nameNew)
nameNew <- gsub("Gyro", "Gyroscope", nameNew)
nameNew <- gsub("Mag", "Magnitude", nameNew)
nameNew <- gsub("-mean-", " Mean ", nameNew)
nameNew <- gsub("-std-", " StandardDeviation ", nameNew)
nameNew <- gsub("-", "_", nameNew)
names(sub) <- nameNew

## the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

tidyData <- aggregate(sub[,3:81], by = list(activity = sub$activity, subject = sub$subject),FUN = mean)
write.table(x = tidyData, file = "data_tidy.txt", row.names = FALSE)

