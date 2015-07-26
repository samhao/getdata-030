1) It first downloads the zip file from "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" and name the zip file to ‘dataset.zip’

2) It unzips the zipfile and renames the download folder from ‘UCI HAR Dataset’ to ‘data’ for easy coding.

3) It creates 2 subfolder within ‘data’ folder: ‘all’ and ‘tidy’. ‘all’ subfolder is used to hold the merged dataset from ‘test’ and ‘train’, while the ‘tidy’ subfolder is to be used to hold the tidy dataset to be generated.

4) The script then generates a list of file names from the ‘data/test’ folder by pattern matching ’*.txt’. Since the ‘data/train’ folder contains the data files with the exactly the same structure AND their file name is identical except ‘test’ to be replaced by ‘train’, another list can be created simply by proper substition the file list from ‘data/test’. finally, substitute ‘test’ with ‘all’ will generate the name of list files in the merged folder in ‘data/all’ subfolder.

5) The main logic of merging is to read the dataset from ‘data/test’, line by line as string, then read the corresponding dataset from ‘data/train’, combine them, trim the whitespace from both end, then globally sustitue ‘’ to a single ‘’, then write the output to the ‘data/all’ of the merged dataset. the main reason to go through this is that many of the datafile have records with ‘’ separating one numeric field from another, and it is not possible to read them in as space delimited CSV file. Though you can read them in as a width delimited file, the performance of loading them in is poor when I tried that approach. [line 48 - 54]

6) Next subject, feature, feature label, and activity dataset are all read in from ‘data/all’ folder from step 5. activity_label and feature_label are read in as well from ‘data’ folder

7) In order to create proper column names for the merged dataset, the make.names function is used to first generate a set of legal R dataset column names, then a global substitution of ‘..’ to ‘.’ furthuer cleans up the resulting column names. [line 89 - 94]

8) Select only column name that has ‘std’ or ‘mean’ to get a subset of the merged dataset, then added column subject_id and actitivty_id. [line 101 - 114]

9) The wide format of the dataset from step 8 is tranformed to the log format, summarized to give the mean and record count, grouped by subject, activity, and feature. [line 121 - 127]

10) Finally, both the wide format and long format tidy dataset are written to files.

