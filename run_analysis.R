library(qdap)
library(data.table)


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
                assign(names[i], read.table(paths[i], header = F, sep = "", stringsAsFactors = F))
                        }

# Column names for data
colabs <- c("Subject", "Activity", features$V2)

# combine test and train files into one table
testdata <- cbind(subject_test, y_test, X_test)
traindata <- cbind(subject_train, y_train, X_train)

# combine both data sets and label columns
alldata <- rbind(testdata, traindata)
colnames(alldata) <- colabs

#Relabel activity index
alldata$Activity <- multigsub(activity_labels$V1, activity_labels$V2, alldata$Activity)

# Subset mean and std data
cols <- grep("Subject|Activity|mean|std", colnames(alldata), value = T)
alldata <- alldata[, cols]
