library(qdap)
library(data.table)
library(tools)
library(dplyr)
library(stringr)


# gets all .txt files in data directory
all.files  <- list.files(path="UCI HAR Dataset",
                         recursive=T,
                         pattern=".txt"
                         ,full.names=T)

# creates vector of just the desired file's paths
paths <- all.files[!grepl("Inertial|READ|info", all.files)]

# create a vector of object names based on file names
names <- gsub(".txt", "", basename(paths))

# Loop in desired files and put them in containers
for(i in seq_along(paths)){
                assign(names[i],
                       read.table(
                               paths[i],
                               header = F,
                               sep = "",
                               stringsAsFactors = F
                               )
                       )
                }

# Column names for data
colabs <- c("Participant", "Activity", features$V2)

# Combine test and train files into one table
testdata <- cbind(subject_test, y_test, X_test)
traindata <- cbind(subject_train, y_train, X_train)

# Combine both data sets and label columns
alldata <- rbind(testdata, traindata)
colnames(alldata) <- colabs

# Reformat activity labels and relabel activity index
activity_labels$V2 <- toTitleCase(tolower(gsub("_", " ", activity_labels$V2)))
alldata$Activity <- multigsub(activity_labels$V1, activity_labels$V2, alldata$Activity)

# Dump unused objects
rm(activity_labels, features, subject_test, subject_train, testdata, traindata, X_test, X_train, y_test, y_train)
rm(all.files, colabs, i, names, paths)

# Clean up column labels and subset mean and std data (Omitting meanFreq columns)
cols <- grep("Participant|Activity|mean[()]|std", colnames(alldata), value = T)
alldata <- as_tibble(alldata[, cols])
cols <- gsub("BodyBody", "Body", cols)
rm(cols)

# Clean up and summarize data based on participant and activity, rename columns
tidydata <- alldata %>%
                group_by(Participant, Activity) %>%
                summarize_if(is.numeric, mean) %>%
                rename_at(vars(-(1:2)), ~ paste0(., " Average"))
View(tidydata)

# Write tidydata to hard drive for submission
write.table(tidydata, file="BartonTidyData.txt", row.names = F)
                                                                           