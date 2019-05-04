# Overal descrition of the script:
# This script consists of three parts: Read Data, Create merged data, and Create tidy data. In the first part the train and test data
# are read into R. In the second part I merge these two data sets, select the releveant columns and give them descriptive names. In 
# the third part I calculate the mean of each column in the merged data set and convert it into a tidy data set. I mark the positions
# in the code where I specifically address each of the five tasks (marked by # ! Task X ! #)


# Load libraries
library(data.table)
library(dplyr)
library(tidyr)

######################
## Part1: Read Data ##
######################

# This part of the script reads the train and test data sets, together with the corresponding activity data and subject data, and the 
# feature and activity_label files. I merge each data set with the corresponding activity data and subject data sets into train_data
# and test_data. The column names are read from the feature file. I also replace the activity ennumration with the corresponding labels.

# Here I define the file paths: 
# - features and labels
Ffeature <- "/home/rok/Edjucation/2019.3.28. Data_Science-Specialization/Getting and Cleaning Data/Final Assighnment/data/UCI HAR Dataset/features.txt"
Flabel <- "/home/rok/Edjucation/2019.3.28. Data_Science-Specialization/Getting and Cleaning Data/Final Assighnment/data/UCI HAR Dataset/activity_labels.txt"      
# - train 
Ftrain_data <- "/home/rok/Edjucation/2019.3.28. Data_Science-Specialization/Getting and Cleaning Data/Final Assighnment/data/UCI HAR Dataset/train/X_train.txt"
Ftrain_al <- "/home/rok/Edjucation/2019.3.28. Data_Science-Specialization/Getting and Cleaning Data/Final Assighnment/data/UCI HAR Dataset/train/y_train.txt"
Ftrain_sub <- "/home/rok/Edjucation/2019.3.28. Data_Science-Specialization/Getting and Cleaning Data/Final Assighnment/data/UCI HAR Dataset/train/subject_train.txt"
# - test 
Ftest_data <- "/home/rok/Edjucation/2019.3.28. Data_Science-Specialization/Getting and Cleaning Data/Final Assighnment/data/UCI HAR Dataset/test/X_test.txt"
Ftest_al <- "/home/rok/Edjucation/2019.3.28. Data_Science-Specialization/Getting and Cleaning Data/Final Assighnment/data/UCI HAR Dataset/test/y_test.txt"
Ftest_sub <- "/home/rok/Edjucation/2019.3.28. Data_Science-Specialization/Getting and Cleaning Data/Final Assighnment/data/UCI HAR Dataset/test/subject_test.txt"


# Here I read the files and give them the appropriate column names:
# - features and labels 
feature <- fread(Ffeature)
label <- fread(Flabel)
# - train 
train_data <- fread(Ftrain_data, col.names = c(feature[,2])[[1]])
train_al <- fread(Ftrain_al, col.names = c("activity"))
train_sub <- fread(Ftrain_sub, col.names = c("subject"))
# test 
test_data <- fread(Ftest_data, col.names = c(feature[,2])[[1]])
test_al <- fread(Ftest_al, col.names = c("activity"))
test_sub <- fread(Ftest_sub, col.names = c("subject"))

# ! Task 4 ! #
# Here I convert the ennumerated activity label with the correspoding cahracter activitly label:
# - train
for (i in seq_along(c(label[,2])[[1]])) {
        train_al$activity[train_al$activity==i] <- label[[i,2]]   
}
# - test
for (i in seq_along(c(label[,2])[[1]])) {
        test_al$activity[test_al$activity==i] <- label[[i,2]]   
}

# Here I append the activity label and the subject information to the two data sets
train_data <- cbind(train_data, train_al,train_sub)
test_data <- cbind(test_data, test_al,test_sub)

# Here I remove all redundant obejcts
rm(feature, label,  test_al, test_sub, train_al, train_sub, Ftest_al, Ftest_sub, Ftrain_al, Ftrain_sub, Flabel, Ffeature, Ftest_data, Ftrain_data, i)




###############################
## Part2: Create merged data ##
###############################

# In this part of the code I merge the test and train data sets, extract measurements with mean and standard deviation measurements,
# and label the column names with descriptive variable names.

# ! Task 1 ! #
# Here I merged the test and train data sets
data <- rbind(test_data, train_data)

# Some of column names (from the feature file) are repeated. I throw the repeated columns out in order to be able to convert 
# the data frame into a data table. This has no impat on the assighnment because non of the columns ar of thype mean() or std()  
unames <- unique(names(data)) # takes only unique column names
upoz <- match(unames, names(data)) # finds the positions of first occurence
data <- tbl_df(data[, unames, with = FALSE]) # subset the data frame based on first occurences of column names and convert to data table

# ! Task 2 ! #
# Here I selecti columns with mean() and std() in the column name, alon with the activity and subject columns
selection <- c(grep("activity", names(data)),grep("subject", names(data)),sort(grep("(.*mean[(][)].*)|(.*std[(][)].)", names(data))))
data <- select(data, selection)

# ! Task 3 ! #
# Here I label the columns with descriptive variable names
# NOTE: "_" is used for formating purposes, this is OK as data is not meant to be tidy at this point.
names(data) <- tolower(gsub("Mag-mean$","-mean-mag",gsub("std","standarddeviation", gsub("[(][)]","", gsub("^t","time-", gsub("^f","frequency-", names(data)))))))
names(data) <- gsub("gyro","-gyroscope", gsub("acc","-accelerometer",names(data)))
names(data) <- gsub("jerk", "-yes", gsub("accelerometer-", "accelerometer-no-", gsub("gyroscope-","gyroscope-no-", names(data))))
names(data) <- gsub("bodybody","body", names(data))

# Here I remove all redundant obejcts
rm(test_data, train_data, unames, upoz, selection)

#############################
## Part3: Create tidy data ##
#############################

# In this part I calculate the mean of each column in the merged data set and convert it into a tidy data set.

# Here I create a sepparator variable that will enable me to group the data into separate activity and subject classes 
# The sepparator variable is bassically a pasted character from activity and subject columns which I add to the data set. 
sepparator = array()
for (i in 1:dim(data)[1]) {
        sepparator[i] <- paste(data[i,1:2], collapse='')  
}
data$sepparator <- factor(sepparator) # Add the sepparator variable to the data set

# ! Task 5 ! #
# Here I group data based on the sepparator variable, I drop the subject and activity columns and I calculate the mean 
# for each group and column. I save the result to a temporary variable meandata.
meandata <- group_by(data, sepparator) %>%  select(-c(subject, activity)) %>% summarise_all(mean)

# Here I create a tidy data set: I gather all the columns with measurements into one column which I then sepparate
# based on domain (time-frequency),acceleration (body-gravity), device (accelerometer, gyroscope), derived (yes, no), 
# type (mean, standard deviation), coordinate (x,y,z,mag). Here derived=yes corresponds to Jerk signals derived=no
# corresponds to underived signls. coordinate=mag corresponds to the magnitude.
tidydata <- meandata %>% gather(domain_acceleration_device_derived_type_coordinate, value, -sepparator) %>% 
        separate(col = domain_acceleration_device_derived_type_coordinate, into = c("domain","acceleration","device","derived","type","coordinate")) 
# From the sepparator I back derive the activity and subject valriables, select all columns except the sepparator variable
# and finally order/sort the data table.
tidydata <- mutate(tidydata, activity = gsub(pattern = "[0-9]+$", "", x = tidydata$sepparator), subject = gsub(pattern = "^[A-Z&_]+", "", x = tidydata$sepparator)) %>%
        select(activity,subject, domain, acceleration, device, derived, type, coordinate, value) %>%
        arrange(activity,subject, domain, acceleration, device, derived, type, coordinate)

# Here I remove all redundant obejcts
rm(i, sepparator, meandata)

# I remove the sepparator variable from data
data <- select(data,-sepparator)