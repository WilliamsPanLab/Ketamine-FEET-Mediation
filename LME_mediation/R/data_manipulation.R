# read data into long format
pivot_repeated_data <- function(data_table, desired_columns, variable_name){
  data <- data_table%>%
    select(desired_columns)%>%
    filter(Visit == 'visit_3_arm_1' | Visit == 'visit_4_arm_1' | Visit == 'visit_5_arm_1')%>%
    pivot_longer(-c(Subjects, Visit), names_to = "timepoint", values_to = variable_name)
  if (length(desired_columns[-(1:2)]) == 2) {
    data <- data %>%
      mutate(Time = case_when(timepoint ==  desired_columns[3] ~ "Pre-infusion", timepoint == desired_columns[4] ~ "Post-infusion"))%>%
      select(-timepoint)
  } 
  
  
  return(data)
  
}
