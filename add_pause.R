# This script goes through a folder with TextGrids, finds tiers and pauses (in tier 5)
# When it finds a pause it adds labeld "P" to interval with same time stamp in tier 2
# puts everything into new folder /fixed.

# Catalina Torres
#	catalina.torres@ivs.uzh.ch
#	(University of Zurich)

library(stringr)
is_pause <- function(row){
  new <- str_match(row, "text = \"<p:>\"")[1]
  ! is.na(new) # Regex matched
}

# is_pause("not a valid row")
# is_pause("text = \"<p:>\"")

extract_tier <- function(row, current){
  new <- str_match(row, "item \\[(\\d+)\\]:")[2]
  if(is.na(new)){ # Regex did not match anything
    current
  } else {
    strtoi(new) # convert to integer
  }
}
#extract_tier("        item [4]:", -1)

extract_min <- function(row, current){
  new <- str_match(row, "xmin = (.+)")[2]
  if(is.na(new)){
    current
  } else {
    as.numeric(new) # convert to numeric
  }
}
# extract_min("            xmin = 0.099977 ", -1)
# extract_min("            xmax = 0.17 ", -1)

extract_max <- function(row, current){
  new <- str_match(row, "xmax = (.+)")[2]
  if(is.na(new)){
    current
  } else {
    as.numeric(new)
  }
}

# extract_max("            xmin = 0.099977 ", -1)
# extract_max("             xmax = 0.7804058792360017 ", -1)

find_pauses <- function(text_grid) {
  pauses_min <- c()
  pauses_max <- c()
  
  tier <- -1
  xmin <- -1
  xmax <- -1
  pause <- FALSE
  for (row in text_grid) {
    tier <- extract_tier(row, tier)
    if (tier != 5 ){
      # skip to next row (from input text_grid)
      # (don't run the lines after in the for loop)
      next
    }
    xmin <- extract_min(row, xmin)
    xmax <- extract_max(row, xmax)
    
    if(is_pause(row)){
      # we found a pause
      pauses_min <- pauses_min %>% append(xmin)
      pauses_max <- pauses_max %>% append(xmax)
    }
  }
  
  list(min=pauses_min, max=pauses_max)
}

# find_pauses(
# "
#     item [4]:
#         intervals [7]:
#             xmin = 0.3656999630175841 
#             xmax = 0.5957798655349141 
#             text = \"@:\" 
#         intervals [8]:
#             xmin = 0.5957798655349141 
#             xmax = 0.7804058792360017 
#             text = \"<p:>\" 
#         intervals [9]:
#             xmin = 0.7804058792360017 
#             xmax = 0.9018095196921487 
#             text = \"ts\" 
#         intervals [22]:
#             xmin = 1.93 
#             xmax = 1.99 
#             text = \"<p:>\" 
# " 
# %>% strsplit('\n') %>% unlist
# )

add_pauses <- function(text_grid, pauses, target_tier=2, pause_label="P") {
  new_text_grid = c()
  
  tier <- -1
  xmin <- -1
  xmax <- -1
  current_pause <- 1
  for (row in text_grid) {
    tier <- extract_tier(row, tier)
    
    if (tier != target_tier){
      # skip to next row (from input text_grid)
      # (don't run the lines after in the for loop)
      new_text_grid <- c(new_text_grid, row)
      next
    }
    xmin <- extract_min(row, xmin)
    xmax <- extract_max(row, xmax)
    
    if(current_pause <= length(pauses$min)
       & xmin == pauses$min[current_pause] 
       & xmax == pauses$max[current_pause]
       & str_detect(row, "text =")
       ) {
      # we found an interval matching a pause
      row <- gsub("text = \"\"", "text = \"P\"", row)
      current_pause <- current_pause + 1 # look for the next pause
    }
    
    
    new_text_grid <- c(new_text_grid, row)
  }
  
  new_text_grid
}

save_new_text_grid <- function(source_file, new_text_grid) {
  dest_dir <- paste(dirname(source_file), "fixed", sep = '/')
  dir.create(dest_dir, showWarnings = FALSE)
  dest_file <- paste(dest_dir, basename(source_file), sep = '/')
  fileConn <- file(dest_file)
  writeLines(new_text_grid, fileConn)
  close(fileConn)
  sprintf("File %s fixed and saved to %s", source_file, dest_file)
}



add_pauses_file <- function(source_file) {
  text_grid <-  readLines(source_file)
  
  pauses <- find_pauses(text_grid)
  print(paste(source_file, "Found", length(pauses$min), "pauses"))
  new_text_grid <- add_pauses(text_grid, pauses)
  save_new_text_grid(source_file, new_text_grid)
}

# Find multiple files in directory
add_pauses_in_directory <- function(directory) {
  for (f in list.files(directory, full.names = TRUE, pattern = ".+TextGrid")) {
    add_pauses_file(f)
  }
}



# Select directory to be used
add_pauses_in_directory("/Users/catalina/Desktop/can_delete")
