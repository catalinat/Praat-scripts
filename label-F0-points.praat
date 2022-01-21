#################################################################
## label-P1-P2-P3-P4 
##
## Reads TextGrids from a list 
## Prompts users to manual identify L1 and other points in F0
##
## Use to get an idea of tonal scaling for item sets for
## segmental intonation perception experiment
##
## 
## Saves TextGrid object as a file.
##
## Pauline Welby
## pauline.welby@lpl-aix.fr
## 06/09/2019
## Modified by Catalina Torres
## Phonetics laboratory, The University of Melbourne
## September 2019
## Praat 6.0.37
##
#################################################################

# brings up form that prompts the user to enter directory name
# creates variable
baseDir$ = chooseDirectory$ ("Choose folder containing files to be modified:")
beginPause: "Input Enter directory and output file name (without final slash)"
    comment: "Enter directory where soundfiles are kept:"
    sentence: "soundDir", "'baseDir$'" 
    comment: "Enter directory where TextGrid files are stored:"
    sentence: "textDir", "'baseDir$'"
    # comment: "Enter directory where list file (if any) is kept:"
    # sentence: "listDir", "'baseDir$'"
    # comment: "Enter comment Enter name of list file (without .txt extension), if applicable:"
    # sentence: "list", "list"
clicked = endPause: "Continue", 1

#Creates list of files from folder
Create Strings as file list... listwav 'soundDir$'/*.wav

beginPause: "Did you previously start annotating?"
  comment: "The file list (Strings listawav) is on Praat Objects."
  comment: "With which file number do you wish to start working?"
  integer: "nfile", 1
endPause: "OK", 1

# Makes list of files to be labelled, creates a variable with basename of file
# opens loop 

# Uncomment following line (and comment the read as list line below) to read in files using a regular expression
# Create Strings as file list... list 'textDir$'/*.wav

# Uncomment following line (and comment preceding line) to read in files from a list
# in a text file.

# select strings
select Strings listwav
nstrings = Get number of strings
# Read Strings from raw text file... 'listDir$'/'list$'.txt
for i from nfile to nstrings
   select Strings listwav
   fileName$ = Get string... i
# strip extension to get basename
   name$ = fileName$ - ".wav"

# Open sound file
	Read from file... 'soundDir$'/'name$'.wav

# Open TextGrid file
  Read from file... 'textDir$'/'name$'.TextGrid

# Create TextGrid
# To TextGrid: "tones misc", "tones misc"
# selects Sound object and displays it
select Sound 'name$'
Edit
editor Sound 'name$'

# prompts user to click on segmental landmarks, create variables with values at point clicked

 pause Click Click on li
 Move cursor to nearest zero crossing
 p1 = Get cursor

 pause Click Click on Hi
 Move cursor to nearest zero crossing
 p2 = Get cursor

 pause Click Click on la
 Move cursor to nearest zero crossing
 p3 = Get cursor

 pause Click Click on Ha
 Move cursor to nearest zero crossing
 p4 = Get cursor
 
Close
endeditor

# add tags in the TextGrid at right times

select TextGrid 'name$'

Insert point: 5, 'p1', "li"
Insert point: 5, 'p2', "Hi"
Insert point: 5, 'p3', "la"
Insert point: 5, 'p4', "Ha"

# allow user to confirm tagging (and make necessary changes)

select Sound 'name$'
plus TextGrid 'name$'
Edit
# pause script  
pause Confirm TextGrid 'name$' ('i' from 'nstrings') and click "Continue" 
#pause CONFIRM TextGrid

# save TextGrid file
select TextGrid 'name$'
Write to text file... 'textDir$'/'name$'.TextGrid

###### Cleaning up objects before proceeding to the next file
select Sound 'name$'
plus TextGrid 'name$'
Remove

endfor

###### After you're done with all files, remove Strings object for complete object cleaning up
select all 
Remove

exit You just finished your file list! Well done! 
########################################################
## END OF SCRIPT
########################################################