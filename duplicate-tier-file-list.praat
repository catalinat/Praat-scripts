#######################################################
### duplicate-tier-file-list
### This script opens a parent directory where files are kept.
### It duplicates a chosen tier and creates a new tier called whatever you call it,
### but you need to change that in the script
### Optionally, a list of all modified files can be obtained.
### TextGrids to be modified must have all the same number of tiers at the beginning!
###
### Catalina Torres, July 2018
### catalinat@student.unimelb.edu.au
#####################	Parameters	#######################
baseDir$ = chooseDirectory$: "Select base directory (where soundfiles are kept)"
beginPause: "Add tier in file list - Parameters"
  	comment: "Enter parent directory where files are kept:"
  	sentence: "Dir" , "'baseDir$'"
	comment: "Duplicate interval tier?"
	boolean: "duplicate_interval_tier" , 1
	integer: "position_to_be_duplicated" , ""
	integer: "position_new_duplicated_interval_tier" , ""
	comment: "Name of your new tier:"
	sentence: "Name", ""
	boolean: "save_list_of_modified_files" , 0
clicked = endPause: "Continue", 1
##########################################
if windows = 1
	slash$ = "\"
else
	slash$= "/"
endif

Create Strings as file list... list 'baseDir$'/*.TextGrid
if save_list_of_modified_files
	Save as raw text file: "'baseDir$''slash$'list.txt"
endif

numberOfFiles = Get number of strings
for ifile from 1 to numberOfFiles
	echo Modifying TextGrid 'ifile' from 'numberOfFiles'
	select Strings list
	nameFile$ = Get string... ifile
	nameObject$ = nameFile$ - ".TextGrid"

	do ("Read from file...", "'baseDir$'/'nameFile$'")
	select TextGrid 'nameObject$'
	
	if duplicate_interval_tier = 1
		Duplicate tier... 'position_to_be_duplicated' 'position_new_duplicated_interval_tier' Target
	endif


	do ("Save as text file...", "'baseDir$'/'nameFile$'")
	
select all
minus Strings list
Remove

endfor
select all
Remove
appendInfoLine: "Happy new tiers!"