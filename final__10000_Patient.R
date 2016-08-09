## Author : Kaustav Saha
## Basic Electronic Medical Record Analysis

##################################################################################################

rm(list=ls())

options(warn = -1)

suppressMessages(library(plyr))
suppressMessages(library(dplyr))
suppressMessages(library(lubridate))

path <- "C:/Users/Kaustav Saha/Desktop/HealthCare/Datasets/10000-Patients/"
setwd(path)

###############################################################################################
read_Data <- function()
{
  AdmissionsCorePopulatedTable  <<- as.data.frame(read.table("AdmissionsCorePopulatedTable.txt", 
                                                             sep="\t" , skip = 1, stringsAsFactors=FALSE,
                                                             col.names=c("PatientID", "AdmissionID",
                                                                         "AdmissionStartDate", "AdmissionEndDate")))
  
  AdmissionsDiagnosesCorePopulatedTable <<- as.data.frame(read.table("AdmissionsDiagnosesCorePopulatedTable.txt", 
                                                                     sep="\t" , skip = 1, stringsAsFactors=FALSE,
                                                                     col.names = c("PatientID","AdmissionID",
                                                                                   "PrimaryDiagnosisCode", "PrimaryDiagnosisDescription")))
  
  LabsCorePopulatedTable                <<- as.data.frame(read.table("LabsCorePopulatedTable.txt", 
                                                                     sep="\t" , skip = 1, stringsAsFactors=FALSE,
                                                                     col.names = c("PatientID","AdmissionID","LabName",
                                                                                   "LabValue","LabUnits", "LabDateTime")))
  
  PatientCorePopulatedTable             <<- as.data.frame(read.table("PatientCorePopulatedTable.txt", 
                                                                     sep="\t", skip = 1, stringsAsFactors=FALSE,
                                                                     col.names = c("PatientID","PatientGender",
                                                                                   "PatientDateOfBirth","PatientRace",
                                                                                   "PatientMaritalStatus","PatientLanguage",
                                                                                   "PatientPopulationPercentageBelowPoverty")))
}
################################################################################

################################################################################
check_Multiple_Admissions <- function()
{
  # Group by of patients with multiple admissions
  Multiple_Admission_Patients <- as.data.frame(table(AdmissionsCorePopulatedTable$PatientID))
  colnames(Multiple_Admission_Patients) <- c("PatientID","Number_of_Admissions")
  
  return(Multiple_Admission_Patients)
}
################################################################################

################################################################################
create_Master_Dataset <- function()
{
  Patient_with_Admission <- merge(PatientCorePopulatedTable, AdmissionsCorePopulatedTable)
  Patient_Record_with_Admission_Diagnoses <- merge(Patient_with_Admission,AdmissionsDiagnosesCorePopulatedTable,all.x = TRUE)
  
  # master dataset
  
  Master_10000_Patients <- merge(LabsCorePopulatedTable, Patient_Record_with_Admission_Diagnoses, by=c('PatientID', 'AdmissionID'))
  
  Master_10000_Patients$LabDateTime <- as.Date(Master_10000_Patients$LabDateTime)
  Master_10000_Patients$PatientDateOfBirth <- as.Date(Master_10000_Patients$PatientDateOfBirth)
  Master_10000_Patients$AdmissionStartDate <- as.Date(Master_10000_Patients$AdmissionStartDate)
  Master_10000_Patients$AdmissionEndDate <- as.Date(Master_10000_Patients$AdmissionEndDate)
  
  return(Master_10000_Patients)
}
##########################################################################################

#########################################################################################
distribution_of_Disease <- function()
{
  Diseases_Summary <- as.data.frame (Master_10000_Patients %>% group_by(PatientRace,
                                                                      PatientGender,
                                                                      PatientLanguage,
                                                                      PrimaryDiagnosisDescription) %>% tally())
  
  names(Diseases_Summary)[names(Diseases_Summary) == 'n'] <- 'Frequency'
  return(Diseases_Summary)
}
#######################################################################################

#########################################################################################
abnormal_Behavior_Detection <- function(stat_Estimate)
{
  Abnormal_df <- Master_10000_Patients
  
  Lab_Stats <<- ddply(Abnormal_df, .(LabName), summarize,  upper = mean(LabValue) + stat_Estimate * sd(LabValue),
                      lower = mean(LabValue) - stat_Estimate * sd(LabValue))
  
  Abnormal_df$abnormal <- apply(Abnormal_df, 1, function(row) {
    
    match_LabName <- as.data.frame(Lab_Stats[Lab_Stats$LabName == row["LabName"],])
    limit_check <- as.numeric(row["LabValue"])
    
    if(limit_check > match_LabName$upper | limit_check < match_LabName$lower)
    {
      return('yes')
    }
    else return('no')
  })
  
  Abnormal_Lab_Report_Set <<- subset(Abnormal_df, abnormal=='yes') 
  PatientId_Abnormal_Set_with_duplicates <- as.data.frame(Abnormal_Lab_Report_Set$PatientID)
  PatientId_Abnormal_Set_unique <- as.data.frame(PatientId_Abnormal_Set_with_duplicates[!duplicated(PatientId_Abnormal_Set_with_duplicates), ])
  colnames(PatientId_Abnormal_Set_unique) <- "PatientID"
  
  Abnormal_Patients <-  merge(PatientId_Abnormal_Set_unique,PatientCorePopulatedTable)
  
  return(Abnormal_Patients)
}
############################################################################################

##########################################################################################
distribution_of_Lab_Report <- function()
{
  df <- Master_10000_Patients
  
  df$LabDateTime <- as.character(substr(df$LabDateTime,1,4))
  distribution_time <- as.data.frame(table(df$LabDateTime))
  colnames(distribution_time) <- c("year","Freq")
  barplot(distribution_time$Freq, names.arg=distribution_time$year,col = c("blue") , 
          main = " Distribution of Number of Lab Reports (10000 Patients)")
  
}
############################################################################################

##########################################################################################
write_Data <- function()
{
  Path_Multiple_Admission_Patients <- paste0(path,"/Data/Multiple_Admission_Patients.csv")
  Path_Master_10000_Patients         <- paste0(path,"/Data/Master_10000_Patients.csv")
  Path_Diseases_Summary            <- paste0(path,"/Data/Diseases_Summary.csv")
  Path_Abnormal_Patients           <- paste0(path,"/Data/Abnormal_Patients.csv")
  
  write.csv(Multiple_Admission_Patients,   file = Path_Multiple_Admission_Patients)
  write.csv(Master_10000_Patients,         file = Path_Master_10000_Patients)
  write.csv(Diseases_Summary,              file = Path_Diseases_Summary)
  write.csv(Abnormal_Patients,             file = Path_Abnormal_Patients)
}

#########################################################################################
############# Using Functions here ######################################

#### Reading Data #########
start <- proc.time()
read_Data()
print("Time Taken for Reading Data in secs")
print(proc.time() - start)
##########################

#### Checking Patients with multiple admissions #######
Multiple_Admission_Patients <- check_Multiple_Admissions()
############################

##### Creating Master Dataset #########################
start <- proc.time()
Master_10000_Patients <- create_Master_Dataset()
print("Time Taken for creating Master Dataset in secs")
print(proc.time() - start)
#######################################################

####### Distribution of Diseases among the patients ######
Diseases_Summary <- distribution_of_Disease()
##########################################################

########## Detecting Abnormal Patients ###################
start <- proc.time()
Abnormal_Patients <- abnormal_Behavior_Detection(1.5)
print("Time Taken for detecting Abnormal Patients in secs")
print(proc.time() - start)
##########################################################

######## Distribution of Lab Reports on Time Scale
distribution_of_Lab_Report()
##########################################################

################ Writing Data to Local ####################
start <- proc.time()
write_Data()
print("Writing Data to Local in secs")
print(proc.time() - start)
###########################################################

########### End of File ###########################################################################