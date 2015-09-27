require("data.table")
require("reshape2")

activity_labels<-read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
features<-read.table("./UCI HAR Dataset/features.txt")[,2]
extract_features<-grepl("mean|std", features)


Xtest<-read.table("./UCI HAR Dataset/test/X_test.txt")
ytest<-read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt")

names(Xtest)=features
Xtest=Xtest[,extract_features]

#activity labels
ytest[,2]=activity_labels[ytest[,1]]
names(ytest)=c("Activity_ID", "Activity_Label")
names(subject_test)="subject"

#bind data
test_data<-cbind(as.data.table(subject_test), ytest, Xtest)

#load process train 
X_train<-read.table("./UCI HAR Dataset/train/X_train.txt")
y_train<-read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train)=features

#Extract the mean and standard deviation for each measurement
X_train=X_train[,extract_features]

#activity data
y_train[,2]=activity_labels[y_train[,1]]
names(y_train)=c("Activity_ID", "Activity_Label")
names(subject_train)="subject"

#bind data
train_data<-cbind(as.data.table(subject_train), y_train, X_train)

#merge test and train
data=rbind(test_data, train_data)

id_labels=c("subject", "Activity_ID", "Activity_Label")
data_labels=setdiff(colnames(data), id_labels)
melt_data=melt(data, id = id_labels, measure.vars = data_labels)

#mean function to dataset 
tidy_data=dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file="./tidy_data.txt")
