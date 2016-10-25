## Author : Kaustav Saha
## Basic Electronic Medical Record Analysis

##################################################################################################

rm(list=ls())

options(warn = -1)

suppressMessages(library(plyr))
suppressMessages(library(dplyr))
suppressMessages(library(lubridate))

path <- "/home/kaustav/R_Scripts/HealthCare/Datasets/100_Patients/"
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
  
  Master_100_Patients <- merge(LabsCorePopulatedTable, Patient_Record_with_Admission_Diagnoses, by=c('PatientID', 'AdmissionID'))
  
  Master_100_Patients$LabDateTime <- as.Date(Master_100_Patients$LabDateTime)
  Master_100_Patients$PatientDateOfBirth <- as.Date(Master_100_Patients$PatientDateOfBirth)
  Master_100_Patients$AdmissionStartDate <- as.Date(Master_100_Patients$AdmissionStartDate)
  Master_100_Patients$AdmissionEndDate <- as.Date(Master_100_Patients$AdmissionEndDate)
  
  return(Master_100_Patients)
}
##########################################################################################

#########################################################################################
distribution_of_Disease <- function()
{
  Diseases_Summary <- as.data.frame (Master_100_Patients %>% group_by(PatientRace,
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
  Abnormal_df <- Master_100_Patients
  
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
  df <- Master_100_Patients
  
  df$LabDateTime <- as.character(substr(df$LabDateTime,1,4))
  distribution_time <- as.data.frame(table(df$LabDateTime))
  colnames(distribution_time) <- c("year","Freq")
  barplot(distribution_time$Freq, names.arg=distribution_time$year,col = c("blue") , 
          main = " Distribution of Number of Lab Reports (100 Patients)")
  
}
############################################################################################

##########################################################################################
write_Data <- function()
{
  Path_Multiple_Admission_Patients <- paste0(path,"/Data/Multiple_Admission_Patients.csv")
  Path_Master_100_Patients         <- paste0(path,"/Data/Master_100_Patients.csv")
  Path_Diseases_Summary            <- paste0(path,"/Data/Diseases_Summary.csv")
  Path_Abnormal_Patients           <- paste0(path,"/Data/Abnormal_Patients.csv")
  
  write.csv(Multiple_Admission_Patients, file = Path_Multiple_Admission_Patients)
  write.csv(Master_100_Patients,         file = Path_Master_100_Patients)
  write.csv(Diseases_Summary,            file = Path_Diseases_Summary)
  write.csv(Abnormal_Patients,           file = Path_Abnormal_Patients)
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
Master_100_Patients <- create_Master_Dataset()
colnames(Master_100_Patients)

my_id = as.data.frame('')
my_id = as.data.frame(rownames(Master_100_Patients))
colnames(my_id) = 'id'

table26 = cbind(my_id,Master_100_Patients)

table26 <- as.data.frame(lapply(table25, as.character), stringsAsFactors=FALSE)

colnames(table26) = c("id","col_1_patientid","col_2_admissionid","col_3_labname","col_4_labvalue","col_5_labunits",                               
                      "col_6_labdatetime","col_7_patientgender","col_8_patientdateofbirth","col_91_patientrace",                            
                      "col_92_patientmaritalstatus","col_93_patientlanguage",                        
                      "col_94_patientpopulationpercentagebelowpoverty","col_95_admissionstartdate",                   
                      "col_96_admissionenddate","col_97_primarydiagnosiscode",                  
                      "col_98_primarydiagnosisdescription"            )

CREATE TABLE rcass.table26 (id text, col_1_patientid text,col_2_admissionid text,col_3_labname text,
                            col_4_labvalue text, col_5_labunits text,                               
                            col_6_labdatetime text,col_7_patientgender text, col_8_patientdateofbirth text,
                            col_91_patientrace text,col_92_patientmaritalstatus text,col_93_patientlanguage text,                        
                            col_94_patientpopulationpercentagebelowpoverty text, col_95_admissionstartdate text,                   
                            col_96_admissionenddate text,col_97_primarydiagnosiscode text,                  
                            col_98_primarydiagnosisdescription text , PRIMARY KEY(id) ) WITH COMPACT STORAGE ;


sub = table13[1:10,1:4]
sub <- data.frame(lapply(sub, as.character), stringsAsFactors=FALSE)
sub_frame = as.data.frame(cbind(zz$id,zz$col_1_PatientID,))
colnames(sub_frame) = c('id','col_1_PatientID')
CREATE TABLE rcass.table22 (id text, col_1_patientid text,col_2_AdmissionID text,col_3_LabName text,
                            PRIMARY KEY(id) ) WITH COMPACT STORAGE ;


sub = as.data.frame(sub)
colnames(sub) = c('id', 'col_1_patientid', 'col_2_admissionid','col_3_labname') 
typeof(sub$col_2_AdmissionID)
start <- proc.time()
zz = sample_n(table13, 10)

start <- proc.time()
#zz = table23[1:10000,]
#RC.write.table(connect.handle, "table26", table26)
mycars <- as.data.frame(RC.read.table(connect.handle, "table26"))

sum(is.na(mycars))
print("Time Taken for creating Master Dataset in secs")
print(proc.time() - start)
#######################################################

####### Distribution of Diseases among the patients ######
Diseases_Summary <- distribution_of_Disease()
##########################################################

########## Detecting Abnormal Patients ###################
start <- proc.time()
Abnormal_Patients <- abnormal_Behavior_Detection(1.77)
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






































































