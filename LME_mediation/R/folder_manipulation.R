# create folder, can work even if parent folder doesn't exist
create_folder_subfolder <- function(folder)
{
  dir.create(folder, recursive = TRUE)
  
}