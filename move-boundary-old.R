# This script goes through a TextGrid and removes all the text from tier number 2 leaving all boundaries in
# puts everything into new folder /fixed.

#   Catalina Torres
#	catalinat@student.unimelb.edu.au
#	Phonetics laboratory (The University of Melbourne)
library(stringr)
extract_tier <- function(row, current){
  new <- str_match(row, "item \\[(\\d+)\\]:")[2]
  if(is.na(new)){
    strtoi(current)
  } else {
    new
  }
}
extract_interval <- function(row, current){
  new <- str_match(row, "intervals \\[(\\d+)\\]:")[2]
  if(is.na(new)){
    strtoi(current)
  } else {
    new
  }
}
extract_interval_count <- function(row, current){
  new <- str_match(row, "intervals: size = (\\d+):")[2]
  if(is.na(new)){
    strtoi(current)
  } else {
    new
  }
}

move_boundary_file <- function(source_file, move_left=TRUE, move_right=TRUE) {
  text_grid <-  readLines(source_file)
  
  boundary <- find_boundary(text_grid)
  new_text_grid <- move_left_boundary(text_grid, boundary)
  save_new_text_grid(source_file, new_text_grid)
}

find_boundary <- function(text_grid) {
  replace_value <- c()
  
  tier <- NA
  interval <- NA
  interval_count <- NA
  for (row in text_grid) {
    tier <- extract_tier(row, tier)
    if (tier != 4 ){
      # skip to next row (from input text_grid)
      # (don't run the lines after in the for loop)
      next 
    }
    interval_count <- extract_interval_count(row, interval_count)
    interval <- extract_interval(row, interval)
    if (tier == 4 & interval == 1 & 
        grepl("xmax", row, fixed = TRUE)) {
        left_boundary <- gsub("\\s+xmax = ","",row) # \\s+ means one or more (+) space characters
    } else if (tier == 4 & interval == extract_interval_count & grepl("xmin", row, fixed = TRUE)){ # 4th tier, last interval
      right_boundary <- gsub("\\s+xmin = ","",row)
    }
  }
  
  c(left_boundary, right_boundary )
}

move_left_boundary <- function(text_grid, left_boundary) {
  new_text_grid = c()
  
  in_tier_1_3 <- FALSE
  in_interval_1 <- FALSE
  in_interval_2 <- FALSE
  for (row in text_grid) {
    ## FIXME replace with extract methods
    if (grepl("item [1]:", row, fixed = TRUE)) {
      in_tier_1_3 <- TRUE
    }
    if (grepl("item [2]:", row, fixed = TRUE)) {
      in_tier_1_3 <- TRUE
    }
    if (grepl("item [3]:", row, fixed = TRUE)) {
      in_tier_1_3 <- TRUE
    }
    if (grepl("item [4]:", row, fixed = TRUE)) {
      in_tier_1_3 <- FALSE
    }
    
    if (grepl("intervals [1]:", row, fixed = TRUE)) {
      in_interval_1 <- TRUE
      in_interval_2 <- FALSE
    } else if (grepl("intervals [2]:", row, fixed = TRUE)) {
      in_interval_1 <- FALSE
      in_interval_2 <- TRUE
    } else if (grepl("intervals [", row, fixed = TRUE)) {
      in_interval_1 <- FALSE
      in_interval_2 <- FALSE
    }
    
    
    if (in_tier_1_3) {
      if (in_interval_1) {
        row <- gsub("xmax = .*", paste("xmax =", left_boundary), row)
      }
      if (in_interval_2) {
        row <- gsub("xmin = .*", paste("xmin =", left_boundary), row)
      }
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

# Find multiple files in directory
move_left_boundary_in_directory <- function(directory) {
  for (f in list.files(directory, full.names = TRUE, pattern = ".+TextGrid")) {
    move_boundary_file(f)
  }
}




### Test cases
interval = "            xmax = 0.040000"
identical("            xmax = 0.1", gsub("xmax = .*", "xmax = 0.1", interval))


test_file = readLines("~/Desktop/move-boundary-test.txt")
test_left_boundary <- find_boundary(test_file)
if (test_left_boundary != "0.099977") {
  stop(paste("Wrong left boundary: ", test_left_boundary))
}

## Full test
move_boundary_file("~/Desktop/move-boundary-test.txt")
expected = readLines("~/Desktop/move-boundary-expected.txt")
fixed_file = readLines("~/Desktop/fixed/move-boundary-test.txt")
if(!identical(expected, fixed_file)) {
  writeLines(fixed_file)
  stop("Incorrect output")
} else {
  print("It works :-)")
}





# Select directory to be used
move_left_boundary_in_directory("/Users/catalina/Desktop/TEST-candelete")
