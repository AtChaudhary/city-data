# load necessary packages
library(readr)
library(dplyr)
library(stringr)
# Set working directory to the location of your files
setwd("C:/Users/ashvi/OneDrive/Desktop/Sheriff Data")

# Generate a vector of file names from 2009 to 2023
years <- 2009:2023
file_list <- paste0(years, "_County.csv")

# Function to read and label each file
read_and_label <- function(file) {
  data <- read_csv(file)
  data$Year <- sub("_County.csv", "", basename(file)) # Extract year from file name
  return(data)
}

# Initialize an empty list to store the data frames
data_list <- list()

# Read and store each file into the list
for (file in file_list) {
  if (file.exists(file)) {
    data_list[[file]] <- read_and_label(file)
  } else {
    warning(paste("File does not exist:", file))
  }
}

# Combine all data frames into one
combined_data <- bind_rows(data_list)

#Filter for San Diego County
SD_County <- combined_data %>% 
  filter(EmployerName == "San Diego")
#Find Approximate matches in DepartmentOrSubdivision for with keyword "Sheriff"
sheriff_departments <- unique_departments %>%
  filter(str_detect(DepartmentOrSubdivision, regex("Sheriff", ignore_case = TRUE)))

# View the filtered unique departments
print(sheriff_departments)
#Found there is only Sheriff, now filtering for "Sheriff"
SD_Sheriff <- SD_County %>% 
  filter(DepartmentOrSubdivision == "Sheriff")
#Prepare to append with San Diego City Employee Data
SD_City <- read_csv("C:/Users/ashvi/OneDrive/Desktop/San Diego Taxpayer/Employee Compensation Data/SDCountyEmployee_Data.csv")

#Append
SD_City_Sheriff <- bind_rows(SD_County, SD_City)

#ERROR:Year collum not same type, convert Year collum in both datasets to charecter
SD_County <- SD_County %>% mutate(Year = as.character(Year))
SD_City <- SD_City %>% mutate(Year = as.character(Year))

#Append
SD_City_Sheriff <- bind_rows(SD_County, SD_City)

#Save
write_csv(SD_City_Sheriff, "C:/Users/ashvi/OneDrive/Desktop/San Diego Taxpayer/Employee Compensation Data/SanDiegoCity+Sheriff/SD_City_Sheriff.csv")
