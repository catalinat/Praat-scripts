# This script goes through a folder with TextGrids, finds tiers and interval 
# It moves the first and last boundaries from interval tiers 1,2,and 3
# to match first and last boundary from tier 4
# puts everything into new folder /fixed.

# Catalina Torres
#	catalina.torres@ivs.uzh.ch
#	(University of Zurich)
library(stringr)
extract_tier <- function(row, current){
  new <- str_match(row, "item \\[(\\d+)\\]:")[2]
  if(is.na(new)){
    current
  } else {
    strtoi(new)
  }
}
extract_interval <- function(row, current){
  new <- str_match(row, "intervals \\[(\\d+)\\]:")[2]
  if(is.na(new)){
    current
  } else {
    strtoi(new)
  }
}
extract_interval_count <- function(row, current){
  new <- str_match(row, "intervals: size = (\\d+)")[2]
  if(is.na(new)){
    current
  } else {
    strtoi(new)
  }
}

move_boundary_file <- function(source_file, move_left=TRUE, move_right=TRUE) {
  text_grid <-  readLines(source_file)
  
  boundary <- find_boundary(text_grid)
  new_text_grid <- move_boundary(text_grid, boundary[1], boundary[2])
  save_new_text_grid(source_file, new_text_grid)
}

find_boundary <- function(text_grid) {
  replace_value <- c()
  
  tier <- -1
  interval <- -1
  interval_count <- -10
  for (row in text_grid) {
    tier <- extract_tier(row, tier)
    if (tier != 4 ){
      # skip to next row (from input text_grid)
      # (don't run the lines after in the for loop)
      next
    }
    interval_count <- extract_interval_count(row, interval_count)
    interval <- extract_interval(row, interval)
    print(row)
    print(paste(interval_count, interval))
    if (tier == 4 & interval == 1 & 
        grepl("xmax", row, fixed = TRUE)) {
        left_boundary <- gsub("\\s+xmax = ","",row) # \\s+ means one or more (+) space characters
    } else if (tier == 4 & interval == interval_count 
               & grepl("xmin", row, fixed = TRUE)){ # 4th tier, last interval
      right_boundary <- gsub("\\s+xmin = ","",row)
    }
  }
  
  c(left_boundary, right_boundary )
}

move_boundary <- function(text_grid, left_boundary, right_boundary) {
  new_text_grid = c()
  
  tier <- -1
  interval <- -1
  interval_count <- -10
  for (row in text_grid) {
    tier <- extract_tier(row, tier)
    interval_count <- extract_interval_count(row, interval_count)
    interval <- extract_interval(row, interval)
      if (tier <= 3 & interval == 1) {
        row <- gsub("xmax = .*", paste("xmax =", left_boundary), row)
      }
      if (tier <=  3 & interval == 2) {
        row <- gsub("xmin = .*", paste("xmin =", left_boundary), row)
      }
    
    
      if (tier <= 3 & interval == interval_count) {
        row <- gsub("xmin = .*", paste("xmin =", right_boundary), row)
      }
      if (tier <=  3 & interval == interval_count - 1) {
        row <- gsub("xmax = .*", paste("xmax =", right_boundary), row)
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
move_boundary_in_directory <- function(directory) {
  for (f in list.files(directory, full.names = TRUE, pattern = ".+TextGrid")) {
    move_boundary_file(f)
  }
}




### Test cases
# interval = "            xmax = 0.040000"
# identical("            xmax = 0.1", gsub("xmax = .*", "xmax = 0.1", interval))
# 
# 
# test_file = readLines("~/Desktop/move-boundary-test.txt")
# boundaries <- find_boundary(test_file)
# if (boundaries[1] != "0.099977") {
#   stop(paste("Wrong left boundary: ", boundaries[1]))
# }
# if (boundaries[2] != "2.505102") {
#   stop(paste("Wrong right boundary: ", boundaries[2]))
# }
# 
# ## Full test
# move_boundary_file("~/Desktop/move-boundary-test.txt")
# expected = readLines("~/Desktop/move-boundary-expected.txt") #file has been deleted
# fixed_file = readLines("~/Desktop/fixed/move-boundary-test.txt")
# if(!identical(expected, fixed_file)) {
#   writeLines(fixed_file)
#   stop("Incorrect output")
# } else {
#   print("It works :-)")
# }





# Select directory to be used
move_boundary_in_directory("/Users/catalina/Desktop/UZH-Projects/Central_Pame/Audio/First_pass/D-Apr2023/newGrids")
