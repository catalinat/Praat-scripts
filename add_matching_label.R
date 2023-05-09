# This script goes through a folder with TextGrids, finds tiers and matching labels
# When it finds a matching label in the matching tier it adds a target label to a selected target interval with same time stamp 
# puts everything into new folder /fixed.

# you need to specify 
# matching_tier= tier with label 
# matching_label= the label that is present
# target_tier= the new tier for new label
# target_label= the new label

# Catalina Torres
# victor.pillac@google.com
#	catalina.torres@ivs.uzh.ch
#	(University of Zurich)

library(stringr)

# matching_label is the label we are looking for
# ! special characters need to be escaped with \\ (eg "\\?")
is_matching_label <- function(row, matching_label){
  new <- str_match(row, paste0("text = \"", matching_label, "\""))[1]
  ! is.na(new) # Regex matched
}

# is_matching_label("not a valid row", "\\?")
# is_matching_label("text = \"?\"", "\\?")
# is_matching_label("text = \"this is not ok\"", "\\?")

extract_tier <- function(row, current){
  new <- str_match(row, "item \\[(\\d+)\\]:")[2]
  if(is.na(new)){ # Regex did not match anything
    current
  } else {
    strtoi(new) # convert to integer
  }
}
# extract_tier("        item [4]:", -1)

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

find_matching_labels <- function(text_grid, matching_tier, matching_label) {
  matching_labels_min <- c()
  matching_labels_max <- c()
  
  tier <- -1
  xmin <- -1
  xmax <- -1
  glottalisation <- FALSE
  for (row in text_grid) {
    tier <- extract_tier(row, tier)
    if (tier != matching_tier ){
      # skip to next row (from input text_grid)
      # (don't run the lines after in the for loop)
      next
    }
    xmin <- extract_min(row, xmin)
    xmax <- extract_max(row, xmax)
    
    if(is_matching_label(row, matching_label)){
      # we found a glottalisation
      matching_labels_min <- matching_labels_min %>% append(xmin)
      matching_labels_max <- matching_labels_max %>% append(xmax)
    }
  }
  
  list(min=matching_labels_min, max=matching_labels_max)
  
}

# find_matching_labels(
#   "item [4]:
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
#             text = \"?\"
# "
# %>% strsplit('\n') %>% unlist
# )

add_target_labels <- function(text_grid, matching_labels, target_tier, target_label) {
  new_text_grid = c()
  
  tier <- -1
  xmin <- -1
  xmax <- -1
  current_matching_label <- 1
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
    
    if(current_matching_label <= length(matching_labels$min)
       & xmin == matching_labels$min[current_matching_label] 
       & xmax == matching_labels$max[current_matching_label]
       & str_detect(row, "text =")
    ) {
      # we found an interval matching a matching_labels
      row <- gsub("text = \"\"", paste0("text = \"", target_label, "\""), row)
      current_matching_label <- current_matching_label + 1 # look for the next matching_labels
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



add_target_labels_file <- function(source_file, matching_tier, matching_label, target_tier, target_label) {
  text_grid <-  readLines(source_file)
  
  all_matching_labels <- find_matching_labels(text_grid, matching_tier, matching_label)
  print(paste(source_file, "Found", length(all_matching_labels$min), "matching labels"))
  if (length(all_matching_labels$min) > 0) {
    new_text_grid <- add_target_labels(text_grid, all_matching_labels, target_tier=target_tier, target_label=target_label)
    save_new_text_grid(source_file, new_text_grid)
  } else {
    print("... skipping")
  }
}


# Find multiple files in directory
add_target_labels_in_directory <- function(directory, matching_tier, matching_label, target_tier, target_label) {
  for (f in list.files(directory, full.names = TRUE, pattern = ".+TextGrid")) {
    add_target_labels_file(f, matching_tier, matching_label, target_tier, target_label)
  }
}



# Select directory to be used
add_target_labels_in_directory("/Users/catalina/Desktop/TEST-candelete", 
                                 matching_tier=3, matching_label="\\?", 
                                 target_tier=2, target_label="GLO")
