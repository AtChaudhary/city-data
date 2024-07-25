#Set working directory
  setwd("C:/Users/ashvi/OneDrive/Desktop/Pac Contribution")

#Set folder path
  folder_path <- "C:/Users/ashvi/OneDrive/Desktop/Pac Contribution/"

#Load packages
  library(readxl)
  library(tidyverse)
  library(lubridate)

#Open datasets
  Oceanside <- read_excel("C:/Users/ashvi/OneDrive/Desktop/Pac Contribution/OceansidePoliceContributionsBinder.xlsx")
  LaMesa <- read_excel("C:/Users/ashvi/OneDrive/Desktop/Pac Contribution/LaMesaPoliceContributionsBinder.xlsx")
  ChulaVista <- read_excel("C:/Users/ashvi/OneDrive/Desktop/Pac Contribution/ChulaVistaPoliceContributionBinder.xlsx")
  Carlsbad <-read_excel("C:/Users/ashvi/OneDrive/Desktop/Pac Contribution/CarlsbadPoliceContributionsBinder.xlsx")
    #San Diego Data files seperate by year, appending them
      file_names <- paste0(2016:2024, "_f496.csv")
      datasets <- list()
      for (file in file_names) {
        file_path <- file.path(folder_path, file)
        if (file.exists(file_path)) {
          try({
            data <- read_csv(file_path)
            datasets <- append(datasets, list(data))
          }, silent = TRUE)
        }
      }
      San_Diego <- bind_rows(datasets)
      
#Preparing data for merge
      #Changing San_Diego date order
        #Convert Exp_Date from YYYYMMDD to Date format YYYY-MM-DD
          San_Diego$DATE <- ymd(San_Diego$Exp_Date)
        #Remove the original Exp_Date column
          San_Diego$Exp_Date <- NULL
        #Rename Amount to AMOUNT
          names(San_Diego)[names(San_Diego) == "Amount"] <- "AMOUNT"
      #Function to save Date column as Year and only keep Year, Amount, Date while adding a column for the respective city name.
          process_data <- function(data, city_name) {
            data %>%
              mutate(DATE = ymd(DATE),            # Convert Date to Date format (ensure it's in YYYY-MM-DD)
                     YEAR = year(DATE),           # Extract Year and create a new YEAR column
                     City = city_name)            # Add City column
          }
       #Process each dataset with the city name and amount column
          Carlsbad <- process_data(Carlsbad, "Carlsbad")
          ChulaVista <- process_data(ChulaVista, "ChulaVista")
          LaMesa <- process_data(LaMesa, "LaMesa")
          Oceanside <- process_data(Oceanside, "Oceanside")
          San_Diego <- process_data(San_Diego, "San_Diego")
        #Rename San_Diego to San Diego
          San_Diego <- San_Diego %>%
            mutate(City = ifelse(City == "San_Diego", "San Diego", City))
        #Rename LaMesa to La Mesa
          LaMesa <- LaMesa %>%
            mutate(City = ifelse(City == "LaMesa", "La Mesa", City))
          #Rename ChulaVista to Chula Vista
          ChulaVista <- ChulaVista %>%
            mutate(City = ifelse(City == "ChulaVista", "Chula Vista", City))
        #Function to keep YEAR, Amount, and add a column called PAC with police in it
          process_data <- function(data, city_name) {
            data %>%
              select(YEAR, AMOUNT, City) %>%
              mutate(Pac = "Police")
          }
        #Process Data
          Carlsbad <- process_data(Carlsbad, "Carlsbad")
          ChulaVista <- process_data(ChulaVista, "ChulaVista")
          LaMesa <- process_data(LaMesa, "LaMesa")
          Oceanside <- process_data(Oceanside, "Oceanside")
          San_Diego <- process_data(San_Diego, "San Diego")
        #Append PAC contributions datasets
          PAC <- bind_rows(Carlsbad, ChulaVista, LaMesa, Oceanside, San_Diego)
#save
write_csv(PAC, "C:/Users/ashvi/OneDrive/Desktop/PAC_Dataset.csv")