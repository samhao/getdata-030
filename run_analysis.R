
## pre-processing: import necessary libraries to run the script

rm(list = ls())
library(data.table)
library(stringr)
library(dplyr)
library(tidyr)

# download zipfile
'http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip' %>%    
    download.file(destfile = 'dataset.zip')

# timestamp
datetime.downloaded <- "Date and Time the files downloaded: " %>% 
    c(date()) %>%
    paste (collapse = " ") %>%     
    print

unzip(zipfile = 'dataset.zip')

# 1) remove directory data
# 2) rename folder 'UCI HAR Dataset' to 'data'
if (file.exists('data'))
    'data' %>% unlink (recursive = TRUE, force = TRUE)

'UCI HAR Dataset' %>% file.rename('data')

## go through script requirement
#### 1. Merges the training and the test sets to create one data set.

# create 'data/all' and 'data/tidy' directories
if (dir.exists("./data/all")) 
    unlink("./data/all", recursive = TRUE, force = TRUE)
if (dir.exists("./data/tidy")) 
    unlink("./data/tidy", recursive = TRUE, force = TRUE)

'./data/all' %>% dir.create
'./data/tidy' %>% dir.create

# get file names for each 'data/test', 'data/train', 'data/all' directories
filelist1 <- './data/test' %>% 
    dir(pattern = '.txt$', full.names = TRUE)

filelist2 <- filelist1 %>% gsub ('test', 'train', .)
filelist3 <- filelist1 %>% gsub ('test', 'all', .)

for (i in 1:length(filelist1)) {
    readLines(filelist1[i]) %>%                ## read file in 'data/test'
        combine(readLines(filelist2[i])) %>%   ## combine file in 'data/train'
        str_trim %>%                           ## remove leading spaces
        gsub("  ", " ", .) %>%                 ## change double spaces to single spaces
        writeLines(filelist3[i])               ## write result file in 'data/all'
}

## two helper functions below
allfname <- function (fname) {
    paste0('./data/all/', fname) %>% return
}

datafname <- function (fname) {
    paste0('./data/', fname) %>% return
}

## read in subject, feature, feature label, and activity file
subject <- allfname('subject_all.txt') %>% 
    read.table(header = FALSE, sep = ' ')

feature <- allfname('X_all.txt') %>%
    read.table(header = FALSE, sep = ' ')

activity <- allfname('y_all.txt') %>%
    read.table(header = FALSE, sep = ' ')


activity_label <- datafname('activity_labels.txt') %>%
    read.table(header = FALSE, sep = ' ')
setnames(activity_label, 1:2, c("activity_id", "activities"))


feature_label <- datafname('features.txt') %>%
    read.table(header = FALSE, sep = ' ')
    
## create merged file
merged <- data.table(feature) %>%
    tbl_df

## set up column headings for merged file
mergedname <- feature_label[,2] %>%
    make.names(unique = TRUE, allow_ = TRUE) %>%    ## convert to legal name for column headings
    gsub ("\\.\\.", "\\.", .)                %>%    ## change '..' to '.'
    gsub ("\\.\\.", "\\.", .)                       ## do it again.
    
setnames(merged, 1:length(mergedname), mergedname )

rm("filelist1", "filelist2", "filelist3", "mergedname", "feature", "feature_label")

#### 2. Extracts only the measurements on the mean and standard deviation for each measurement. 


mean_std <- merged %>%   
    select (contains('mean'), contains('std') )    ## use only the measurements on the mean and standard deviation for each measurement. 

#### 3. Uses descriptive activity names to name the activities in the data set

mean_std$subject_id = subject$V1
mean_std$activity_id = activity$V1

mean_std <- mean_std %>%
    inner_join (activity_label) %>%      # join mean_std table with activity_label table on activity_id key
    select (-activity_id)

paste0('Dimmension of mean_std table: ', paste(dim(mean_std), collapse = ','))

#### 4. Appropriately labels the data set with descriptive variable names. 
    # this requirement was already taken care of in step 1 & 3

#### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## summarize data using dplyer package methodology
summarized <- mean_std %>%
    gather(key = 'features', 'value', -subject_id, -activities) %>%
    group_by (subject_id, activities, features) %>%
    summarize(mean = mean(value), count = n()) %>%
    arrange(subject_id, activities, features) %>%
    tbl_df %>%
    print

## write to tidy dataset to 'data/tidy' folder
write.table(mean_std, file = './data/tidy/detailed.txt', 
            sep = ',', row.names = FALSE)
write.table(summarized, file = './data/tidy/summarized.txt', 
            sep = ',', row.names = FALSE)

#final clean up
rm("activity", "activity_label", "merged", "subject", "i", "allfname", "datafname", "datetime.downloaded")

summary(summarized)
paste0('Dimmension of summarized table: ', paste(dim(summarized), collapse = ','))

