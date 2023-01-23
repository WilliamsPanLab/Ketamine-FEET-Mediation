# motion parameters
motion_spikes <- import(paste(csvdir,"/KET_spikes_demo.csv",sep = ""))

# FEET faces task data
Faces_data <- import(paste(csvdir,"/KET_nonconscious_ROI_peak_Data4R_all_demo.csv",sep = ""))

roiname = setdiff(colnames(Faces_data), c("Subjects", "Dosage", "Task", "Contrast"))

Faces_data <- merge(motion_spikes, Faces_data, by = c("Subjects", "Dosage", "Task"), all.y =TRUE) %>%
  filter(as.double(Subjects) < subjn & is.na(Dosage) == FALSE) %>%
  mutate_at(vars(all_of(roiname)), funs(case_when(SpikesPercent > 0.25 ~ NaN, TRUE ~ .))) %>%
  select(-SpikesPercent, -MeanFD)

