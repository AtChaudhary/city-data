#Load Data
  pac_data <- read.csv("C:/Users/ashvi/OneDrive/Desktop/Pac Contribution/PAC_Dataset.csv")
  employee_data <- read.csv("C:/Users/ashvi/OneDrive/Desktop/San Diego Taxpayer/Employee Compensation Data/Real Wages San Diego County/REAL_SD_Employee.csv")
  target_positions <-read.csv("C:/Users/ashvi/OneDrive/Desktop/San Diego Taxpayer/TargetPositions.csv")
  
#Load packages
  library(dplyr)
  library(stringr)
  library(tidyverse)
  
#Filter for police target positions
  police_positions <- target_positions %>%
    filter(str_detect(Department, regex("^(police|pol)", ignore_case = TRUE)))

#Filter for unique Department names
  unique_departments <- police_positions %>%
    distinct(Department)

#Filter employee data for police employees
  filtered_employee_data <- employee_data %>%
    filter(DepartmentOrSubdivision %in% unique_departments$Department)
  
#Rename DepartmentOrSubdivision to Department, and rename all entries to Police for merge
  updated_employee_data <- filtered_employee_data %>%
    rename(Department = DepartmentOrSubdivision) %>%
    mutate(Department = "Police")

#Keep important columns
  final_employee_data <- updated_employee_data %>%
    select(Year, EmployerName, Position, Department, Real_TotalWages)

#Rename columns for merge
  final_employee_data <- final_employee_data %>%
    rename(YEAR = Year, City = EmployerName)

#In Pac data sum up contributions by year
  summed_pac_data <- pac_data %>%
    group_by(City, YEAR) %>%
    summarise(Total_Amount = sum(AMOUNT, na.rm = TRUE))
  
#Merge
  merged_data <- final_employee_data %>%
    left_join(summed_pac_data, by = c("YEAR", "City"))

#Save dataset
  write.csv(merged_data, "C:/Users/ashvi/OneDrive/Desktop/San Diego Taxpayer/police_pac.csv", row.names = FALSE)
  
  
