path_rf <- file.path("UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)

## Reading the source files
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

## 1. Merges the training and the test sets to create one data set
## 1.1 Concatenate the data set, according to type
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
## 1.2 Set names
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
## 1.3 Merge all in one data frame
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

## 2. Extracts only the measurements on the mean and standard deviation for each measurement
## 2.1 Subset names
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
## 2.2 Subset the data frame
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
## 2.3 Checking the structure
str(Data)

## 3. Uses descriptive activity names to name the activities in the data set
## 3.1 Geting activity names from “activity_labels.txt”
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
# 3.2 
Data$activity<-factor(Data$activity)
Data$activity<- factor(Data$activity,labels=as.character(activityLabels$V2))

## 4. Appropriately labels the data set with descriptive variable names
## 4.1 prefix t is replaced by time
##    Acc is replaced by Accelerometer
##    Gyro is replaced by Gyroscope
##    prefix f is replaced by frequency
##    Mag is replaced by Magnitude
##    BodyBody is replaced by Body
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

## 5. creates a second, independent tidy data set with the average of each variable for each activity and each subject
library(plyr)
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)