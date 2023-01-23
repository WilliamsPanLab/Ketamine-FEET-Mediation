
############ load in raw CADSS and 5d-ASC scores
questionnaire_csv <-import(file = paste(csvdir,"/KET_CADSS_ASC_demo.csv",sep = ""))

############ load age and gender
age_gender <- import(file = paste(csvdir,"/KET_age_gender_demo.csv",sep = ""))


############ read 5D-ASC and replace missingness
desired_columns_once <- c("Subjects", "Visit", "dascscore_bliss", "dascscore_impair", "dascscore_anxiety")

data_once_pervisit <- questionnaire_csv %>%
  select(desired_columns_once) %>%
  filter(Visit == 'visit_3_arm_1' | Visit == 'visit_4_arm_1' | Visit == 'visit_5_arm_1') %>%
  mutate(Subjects = factor(Subjects, levels = subj_list)) %>%
  arrange(Subjects)

# replace missingness
data_once_pervisit_backup <- questionnaire_csv %>%
  select(desired_columns_once[1:2], matches('dasc\\d+{1}postscan$')) %>%
  filter(Visit == 'visit_3_arm_1' | Visit == 'visit_4_arm_1' | Visit == 'visit_5_arm_1') %>%
  mutate(Subjects = factor(Subjects, levels = subj_list)) %>%
  arrange(Subjects)

data_once_pervisit_backup <- data_once_pervisit_backup %>%
  group_by(Visit) %>%
  mutate_if(is.numeric, function(x) ifelse(is.na(x), mean(x, na.rm = T), x)) %>%
  ungroup()

data_once_pervisit_backup <- data_once_pervisit_backup %>%
  mutate(dascscore_bliss = dasc12postscan+dasc86postscan+dasc91postscan,  dascscore_impair = dasc8postscan+dasc27postscan+dasc38postscan+dasc47postscan+dasc64postscan+dasc67postscan+dasc78postscan, dascscore_anxiety = dasc32postscan+dasc43postscan+dasc44postscan+dasc46postscan+dasc56postscan+dasc89postscan)

# replace missingness and generate percentage for asc
measure_replace <- colnames(data_once_pervisit)[grepl("dascscore_", colnames(data_once_pervisit))]
data_once_pervisit[,measure_replace] <-  data_once_pervisit_backup[,measure_replace]

data_once_pervisit <- data_once_pervisit %>%
  mutate(dascscore_bliss = dascscore_bliss/3,  dascscore_impair = dascscore_impair/7, dascscore_anxiety = dascscore_anxiety/6)

data_once_pervisit <- merge(data_once_pervisit, Dosage, by = c("Subjects","Visit"), all=TRUE)

data_once_pervisit <- data_once_pervisit %>%
  ungroup() %>%
  select(-Visit)


############ read CADSS data collected pre- and post-administration and replace missingness as well
questionnaire_csv_repeated <- questionnaire_csv %>%
  filter(Visit == 'visit_3_arm_1' | Visit == 'visit_4_arm_1' | Visit == 'visit_5_arm_1') %>%
  select(c("Subjects", "Visit", matches("CADSS"), matches("cadss"))) 

# replace missingness
questionnaire_csv_repeated <- questionnaire_csv_repeated %>%
  group_by(Visit) %>%
  mutate_if(is.numeric, function(x) ifelse(is.na(x), mean(x, na.rm = T), x)) %>%
  ungroup()

questionnaire_csv_repeated <- questionnaire_csv_repeated %>%
  mutate("CADSS_depersonalization_preinfusion" = cadss3clin + cadss4clin + cadss5clin + cadss6clin + cadss7clin + cadss20clin + cadss21clin + cadss23clin, 
         "CADSS_depersonalization_postinfusion" = cadsspost3 + cadsspost4 + cadsspost5 + cadsspost6 + cadsspost7+ cadsspost20 + cadsspost21+ cadsspost23, 
         "CADSS_derealization_preinfusion" = cadss1clin + cadss2clin + cadss8clin + cadss9clin + cadss10clin + cadss11clin + cadss12clin + cadss13clin + cadss16clin + cadss17clin + cadss18clin + cadss19clin, 
         "CADSS_derealization_postinfusion" = cadsspost1 + cadsspost2 + cadsspost8 + cadsspost9 + cadsspost10+ cadsspost11 + cadsspost12 + cadsspost13+ cadsspost16 + cadsspost17 + cadsspost18 + + cadsspost19, 
         "CADSS_amnesia_preinfusion" = cadss14clin + cadss15clin + cadss22clin, 
         "CADSS_amnesia_postinfusion" = cadsspost14 + cadsspost15 + cadsspost22,
         "CADSS_preinfusion" = CADSS_depersonalization_preinfusion + CADSS_derealization_preinfusion + CADSS_amnesia_preinfusion,
         "CADSS_postinfusion" = CADSS_depersonalization_postinfusion + CADSS_derealization_postinfusion + CADSS_amnesia_postinfusion) 

# convert to percentage of max
questionnaire_csv_repeated <- questionnaire_csv_repeated %>%
  mutate(CADSS_preinfusion = 100.0*CADSS_preinfusion/(23*4),
         CADSS_postinfusion = 100.0*CADSS_postinfusion/(23*4),
         CADSS_depersonalization_preinfusion = 100.0*CADSS_depersonalization_preinfusion/(8.0*4), 
         CADSS_depersonalization_postinfusion = 100.0*CADSS_depersonalization_postinfusion/(8.0*4), 
         CADSS_derealization_preinfusion = 100.0*CADSS_derealization_preinfusion/(12.0*4), 
         CADSS_derealization_postinfusion = 100.0*CADSS_derealization_postinfusion/(12.0*4), 
         CADSS_amnesia_preinfusion = 100.0*CADSS_amnesia_preinfusion/(3.0*4), 
         CADSS_amnesia_postinfusion = 100.0*CADSS_amnesia_postinfusion/(3.0*4)) 

desired_columns = cbind(c("CADSS_preinfusion", "CADSS_postinfusion",""), c("CADSS_depersonalization_preinfusion", "CADSS_depersonalization_postinfusion",""), c("CADSS_derealization_preinfusion", "CADSS_derealization_postinfusion",""), c("CADSS_amnesia_preinfusion", "CADSS_amnesia_postinfusion",""))

desired_names = c("CADSS", "CADSS_depersonalization", "CADSS_derealization", "CADSS_amnesia")
for (icolumn in 1:length(desired_columns[1,])) {
  selected_column <-  c("Subjects", "Visit", desired_columns[,icolumn])
  selected_column <- selected_column[selected_column!=""]
  variable_name = desired_names[icolumn]
  assign(variable_name, pivot_repeated_data(questionnaire_csv_repeated,selected_column , variable_name))
}


# merge repeated data
data_repeated_pervisit <- Reduce(function(x, y) merge(x, y, by = c("Subjects","Visit","Time"), all=TRUE), list(CADSS, CADSS_depersonalization, CADSS_derealization, CADSS_amnesia))%>%
  mutate(Time = factor(Time, levels = c("Pre-infusion","Post-infusion")))%>%
  arrange(Subjects, Visit, Time) %>%
  mutate(Subjects = factor(Subjects, levels = subj_list)) %>%
  arrange(Subjects)

# generate post-pre measures for repeated measures
desired_columns = c("CADSS", "CADSS_depersonalization", "CADSS_derealization", "CADSS_amnesia")
for (icolumn in desired_columns) {
  new_name <- as.symbol(paste0(icolumn, "_post_pre", sep=""))
  data_repeated_pervisit <- data_repeated_pervisit %>%
    group_by(Subjects, Visit) %>%
    mutate(!!new_name := get(icolumn)[Time == "Post-infusion"] - get(icolumn)[Time == "Pre-infusion"]) %>%
    ungroup()
}

data_repeated_pervisit <- merge(data_repeated_pervisit, Dosage, by = c("Subjects","Visit"), all=TRUE) %>%
  select(-Visit)

# generate post - pre change
data_repeated_post_pre <- data_repeated_pervisit %>%
  ungroup() %>%
  filter(Time == "Post-infusion") %>%
  select(Subjects, Dosage, CADSS_post_pre, CADSS_depersonalization_post_pre, CADSS_derealization_post_pre, CADSS_amnesia_post_pre)
