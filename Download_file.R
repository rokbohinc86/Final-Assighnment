# Overal descrition of the script:
# This script downloads the data and unzip it in the corresponding directories

# set working directory and create dir named data where I download data
setwd("/home/rok/Edjucation/2019.3.28. Data_Science-Specialization/Getting and Cleaning Data/Final Assighnment")
if (!file.exists("data")){
        dir.create("data")
}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# download data 
download.file(fileURL, destfile = "./data/Samsung.zip", method = "curl")

# record the date the data has been downloaded
dateDownloaded <- date()

# Extract data
library(zip)
setwd("./data/")
unzip("./Samsung.zip")

rm(fileURL)