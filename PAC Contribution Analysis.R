#Load Data
  employee_data <- read.csv("C:/Users/ashvi/OneDrive/Desktop/San Diego Taxpayer/Employee Compensation Data/Real Wages San Diego County/REAL_SD_Employee.csv")
  pac_data <- read.csv("C:/Users/ashvi/OneDrive/Desktop/PAC_Dataset.csv")
  CA_data <- read.csv("C:/Users/ashvi/OneDrive/Desktop/San Diego Taxpayer/Employee Compensation Data/CAEmployee_data/CAEmployee_data.csv")
  
#Load Libraries
  library(ggplot2)
  library(tidyverse)
  library(GGally)
  library(stats)
  
#Handle missing values
  employee_data$ElectedOfficial[is.na(employee_data$ElectedOfficial)] <- "No"
  employee_data$Judicial[is.na(employee_data$Judicial)] <- "No"
  employee_data$OtherPositions[is.na(employee_data$OtherPositions)] <- "None"
  salary_columns <- c('MinPositionSalary', 'MaxPositionSalary', 'ReportedBaseWage', 'RegularPay', 'OvertimePay', 'LumpSumPay', 'OtherPay')
  employee_data[salary_columns] <- lapply(employee_data[salary_columns], function(x) ifelse(is.na(x), 0, x))
  employee_data[salary_columns] <- lapply(employee_data[salary_columns], function(x) ifelse(is.na(x), 0, x))
  
#Filter the employee data for the police department
  police_employee_data <- subset(employee_data, grepl("Police", DepartmentOrSubdivision, ignore.case = TRUE))
  
#Merge the datasets on 'Year', 'EmployerName', and 'DepartmentOrSubdivision'
  merged_data <- merge(police_employee_data, pac_data, by.x = c("Year", "EmployerName", "DepartmentOrSubdivision"), by.y = c("YEAR", "City", "Pac"), all.x = TRUE)
  
#Rename whole department or subdivision to Police for merge
  merged_data <- merged_data %>%
    mutate(DepartmentOrSubdivision = 'Police')
  
#Relevant collukns to appropriate type
  CA_data$Year <- as.integer(CA_data$Year)
  
#Filter police data
  police_jobs_data <- CA_data %>%
    filter(grepl("Police", DepartmentOrSubdivision, ignore.case = TRUE))
  
#Calculate job growth for each city over the years
  job_growth <- police_jobs_data %>%
    group_by(EmployerName, Year) %>%
    summarize(TotalJobs = n()) %>%
    arrange(EmployerName, Year) %>%
    mutate(JobGrowth = (TotalJobs - lag(TotalJobs)) / lag(TotalJobs) * 100)
  
#Handle NA values in JobGrowth
  job_growth$JobGrowth[is.na(job_growth$JobGrowth)] <- 0

#Merge job growth data with the PAC contributions and employee wages data
  merged_data <- merge(merged_data, job_growth, by.x = c("Year", "EmployerName"), by.y = c("Year", "EmployerName"), all.x = TRUE)

#Run model
  model_with_growth <- lm(Real_TotalWages ~ AMOUNT, data = merged_data)
  summary(model_with_growth)