---
title: "README"
author: "Rok Bohinc"
date: "May 4, 2019"
output: pdf_document
---


There are two scripst to adress the assighnment, "Download_file" and "run_analysis". 
"Download_file" downloads the files and unzips it in the corresponding directories.
"run_analysis" reads the downloaded files intp R, merges the train and test data sets, 
select the releveant columns and give them descriptive names. This data set is labeled
"data". "run_analysis" also calculate the mean of each column in the data set "data" and
converts it into a tidy data set labeled "tidydata".

Run first "Download_file" and then "run_analysis".


