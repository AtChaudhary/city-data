# Set the working directory
setwd("C:/Users/ashvi/OneDrive/Desktop/City Data")
library(dplyr)
# Loop through the years 2009 to 2023
for (year in 2009:2023) {
  # Construct the folder name
  folder_name <- paste0(year, "_City")
  
  # Get the list of .csv files in the folder
  files <- list.files(path = folder_name, pattern = "\\.csv$", full.names = TRUE)
  
  # Check if there's exactly one .csv file in the folder
  if (length(files) == 1) {
    # Read the .csv file
    data <- read.csv(files[1])
    
    # Assign the data frame to a variable in the global environment
    assign(paste0("data_", year), data, envir = .GlobalEnv)
  } else {
    warning(paste("Expected exactly one .csv file in", folder_name, "but found", length(files)))
  }
}

#Find Unique Values and which one are important
unique_values <- unique(data_2009$DepartmentOrSubdivision)
print(unique_values)
#Load Library to work with large dataset after appending it all
library(data.table)
# List of datasets
dataset_names <- paste0("data_", 2009:2023)
datasets <- lapply(dataset_names, get)
#append datasets
combined_data <- rbindlist(datasets)
#Keeping San Diego County observations only
SDCounty_20092023 <- combined_data %>%
  filter(EmployerCounty == "San Diego")
