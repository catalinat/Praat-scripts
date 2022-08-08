# This script goes through a folder with TextGrids, finds tiers and glottalisations
# When it finds a glottalisation it adds labeld "P" to interval with same time stamp in tier 2
# puts everything into new folder /fixed.

# Catalina Torres
#	catalina.torres@ivs.uzh.ch
#	(University of Zurich)

library(stringr)
is_glottalisation <- function(row){
  new <- str_match(row, "text = \"\\?\"")[1]
  ! is.na(new) # Regex matched
}

is_glottalisation("not a valid row")
# is_glottalisation("text = \"?\"")

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

find_glottalisations <- function(text_grid) {
  glottalisations_min <- c()
  glottalisations_max <- c()
  
  tier <- -1
  xmin <- 10
  xmax <- 10
  glottalisation <- FALSE
  for (row in text_grid) {
    tier <- extract_tier(row, tier)
    if (tier != 4 ){
      # skip to next row (from input text_grid)
      # (don't run the lines after in the for loop)
      next
    }
    xmin <- extract_min(row, xmin)
    xmax <- extract_max(row, xmax)
    
    if(is_glottalisation(row)){
      # we found a glottalisation
      glottalisations_min <- glottalisations_min %>% append(xmin)
      glottalisations_max <- glottalisations_max %>% append(xmax)
    }
  }
  
  list(min=glottalisations_min, max=glottalisations_max)
  
}

find_glottalisations(
  "
    item [4]:
        intervals [7]:
            xmin = 0.3656999630175841 
            xmax = 0.5957798655349141 
            text = \"@:\" 
        intervals [8]:
            xmin = 0.5957798655349141 
            xmax = 0.7804058792360017 
            text = \"<p:>\" 
        intervals [9]:
            xmin = 0.7804058792360017 
            xmax = 0.9018095196921487 
            text = \"ts\" 
        intervals [22]:
            xmin = 1.93 
            xmax = 1.99 
            text = \"<p:>\" 
" 
  %>% strsplit('\n') %>% unlist
)

add_glottalisations <- function(text_grid, glottalisations, target_tier=2, glottalisation_label="GLO") {
  new_text_grid = c()
  
  tier <- -1
  xmin <- 10
  xmax <- 10
  current_glottalisation <- 10
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
    
    if(current_glottalisation <= length(glottalisations$min)
       & xmin == glottalisations$min[current_glottalisation] 
       & xmax == glottalisations$max[current_glottalisation]
       & str_detect(row, "text =")
    ) {
      # we found an interval matching a glottalisation
      row <- gsub("text = \"\"", "text = \"GLO\"", row)
      current_glottalisation <- current_glottalisation + 1 # look for the next glottalisation
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



add_glottalisations_file <- function(source_file) {
  text_grid <-  readLines(source_file)
  
  glottalisations <- find_glottalisations(text_grid)
  print(paste(source_file, "Found", length(glottalisations$min), "glottalisations"))
  new_text_grid <- add_glottalisations(text_grid, glottalisations)
  save_new_text_grid(source_file, new_text_grid)
}

# Find multiple files in directory
add_glottalisations_in_directory <- function(directory) {
  for (f in list.files(directory, full.names = TRUE, pattern = ".+TextGrid")) {
    add_glottalisations_file(f)
  }
}



# Select directory to be used
add_glottalisations_in_directory("/Users/catalina/Desktop/TEST-candelete")
