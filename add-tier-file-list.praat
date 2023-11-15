###########################################################
# add-tier-file-list
# This script opens a parent directory where files are kept
# There are four different options, you can:
# 1. remove a tier - (point or interval tier)
# 2. Add a point tier
# 3. Add one or even two interval tiers
# - Save a list of all your modified textgrids
# Catalina Torres, August 2018.
# catalinat@student.unimelb.edu.au
#####################	Parameters	#######################
baseDir$ = chooseDirectory$: "Select base directory (where soundfiles are kept)"
beginPause: "Add tier in file list - Parameters"
  	comment: "Enter parent directory where files are kept:"
  	sentence: "Dir" , "'baseDir$'"
	comment: "Remove tiers?"
	boolean: "remove_tier" , 0
	comment: "What number of tier do you wish to remove (position tier)?"
	integer: "tier_number_to_be_removed" , 0
	comment: "Add point tier?"
	boolean: "point_tier" , 0
	integer: "position_point_tier" , 5
	word: 	 "name_point_tier" , "Tones"
	comment: "Add interval tier 1?"
	boolean: "add_interval_tier_1" , 0
	word: 	 "name_interval_tier_1" , "Ut"
	integer: "position_interval_tier_1" , 2
	comment: "Add interval tier 2?"
	boolean: "add_interval_tier_2" , 0
	word: 	 "name_interval_tier_2" , "SYL"
	integer: "position_interval_tier_2" , 3
	boolean: "save_list_of_modified_files" , 1
clicked = endPause: "Continue", 1
##########################################
if windows = 1
	barra$ = "\"
else
	barra$= "/"
endif


Create Strings as file list... lista 'baseDir$'/*.TextGrid
if save_list_of_modified_files
	Save as raw text file: "'baseDir$''barra$'lista.txt"
endif

numberOfFiles = Get number of strings
for ifile from 1 to numberOfFiles
	echo Modifying TextGrid 'ifile' from 'numberOfFiles'
	select Strings lista
	nombreArchivo$ = Get string... ifile
	nombreObjeto$ = nombreArchivo$ - ".TextGrid"

	do ("Read from file...", "'baseDir$'/'nombreArchivo$'")
	select TextGrid 'nombreObjeto$'
	if remove_tier = 1
		Remove tier... 'tier_number_to_be_removed'
	endif
	
	if point_tier = 1
		Insert point tier... 'position_point_tier' Tones
	endif
	
	if add_interval_tier_1 = 1
		Insert interval tier... 'position_interval_tier_1' vot
	endif

	if add_interval_tier_2 = 1
		Insert interval tier... 'position_interval_tier_2' SYL
	endif


	do ("Save as text file...", "'baseDir$'/'nombreArchivo$'")
	
select all
minus Strings lista
Remove

endfor
select all
Remove
appendInfoLine: "Happy new tiers!"