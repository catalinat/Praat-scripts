# This script goes through a TextGrid and removes all the text from tier number 2 leaving all boundaries in
# puts everything into new folder /fixed.

#   Catalina Torres
#	catalinat@student.unimelb.edu.au 
#	Phonetics laboratory (The University of Melbourne)


remove_text_from_tier_5 <- function(source_file){
  
  text_grid <-  readLines(source_file)
  
  new_text_grid = c()
  
  in_tier_5 <- FALSE
  for (row in text_grid){
    if(grepl("item [2]:", row, fixed=TRUE)){
      in_tier_5 <- TRUE
    }
    if(grepl("item [3]:", row, fixed=TRUE)){
      in_tier_5 <- FALSE
    }
    
    if(in_tier_5){
      row <- gsub("text = \".*\"", "text = \"\"", row)
    }
    
    new_text_grid <- c(new_text_grid, row)
  }
  
  dest_dir <- paste(dirname(source_file), "fixed", sep = '/')
  dir.create(dest_dir, showWarnings = FALSE)
  dest_file <- paste(dest_dir, basename(source_file), sep = '/')
  fileConn<-file(dest_file)
  writeLines(new_text_grid, fileConn)
  close(fileConn)
  sprintf("File %s fixed and saved to %s",source_file, dest_file)
}


# Find multiple files in directory
fix_textgrids_in_directory <- function(directory){
  for (f in list.files(directory, full.names = TRUE, pattern = ".+TextGrid")) {
    remove_text_from_tier_5(f)
  }
}

# Select directory to be used
fix_textgrids_in_directory("/Users/catalina/Desktop/UZH-Projects/Vietnamese_stimuli/Rec_November_2023/segmented/textgrids/new")
