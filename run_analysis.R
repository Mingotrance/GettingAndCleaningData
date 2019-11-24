library(reshape2)


## Download the dataset:

if (!file.exists("getdata_dataset.zip")){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, "getdata_dataset.zip", method="curl")
}  

## Unzip the dataset
if (!file.exists("UCI HAR Dataset")) { 
  unzip("getdata_dataset.zip") 
}

# Load the datasets
traindataset <- read.table("UCI HAR Dataset/train/X_train.txt")
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
testdataset <- read.table("UCI HAR Dataset/test/X_test.txt")
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")


# Load activity labels and features
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

# Extract only the mean and sd columns
featuresrequired <- grep(".*mean.*|.*std.*", features[,2])

#rename column names
featuresrequired.names <- features[featuresrequired,2]
featuresrequired.names = gsub('-mean', 'Mean', featuresrequired.names)
featuresrequired.names <- gsub('[-()]', '', featuresrequired.names)


# Only load load the desired columns and add the feature and subject columns to the left
traindatasetlight <- traindataset[featuresrequired]
trainReady <- cbind(trainSubjects, trainActivities, traindatasetlight)
testdatasetlight <- testdataset[featuresrequired]
testReady <- cbind(testSubjects, testActivities, testdatasetlight)


# merge datasets (row bind) and add labels
dataset <- rbind(trainReady, testReady)
colnames(dataset) <- c("subject", "activity", featuresrequired.names)

# turn activities & subjects into factors
dataset$activity <- factor(dataset$activity, levels = activityLabels[,1], labels = activityLabels[,2])
dataset$subject <- as.factor(dataset$subject)

# Produce tidy dataset
dataset.melted <- melt(dataset, id = c("subject", "activity"))
dataset.mean <- dcast(dataset.melted, subject + activity ~ variable, mean)
write.table(dataset.mean, "result.txt", row.names = FALSE, quote = FALSE)