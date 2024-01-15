######################################################################################################
#
# Merge TextGrids (Original + New)
# orig_directory = directory where the original TextGrids are
# new_directory = directory with new TextGrids (that you want to merge with your original ones)
# outputdir = directory where your new TextGridfiles will be stored
# optional: removes tiers 2 and 3 from 'NEW'
# 
# CT 24.10.2023
######################################################################################################


### DEFINE I/O and new sentence tier ##
baseDir$ = chooseDirectory$: "Select base directory (where soundfiles are kept)"
beginPause: "Give the working directories"

	comment: "Give the directory for the original TextGrids"
	sentence: "orig_directory", "'baseDir$'/"

	comment: "Give the directory for the new TextGrids"
	sentence: "new_directory", "'baseDir$'/new"

	comment: "Give the outputdirectory"
	sentence: "outputdir", "'baseDir$'/output"

clicked = endPause: "Continue", 1
if windows = 1
	slash$ = "\"
else
	slash$= "/"
endif

	## (2) Loop through TextGrids 
	Create Strings as file list...  list 'orig_directory$'*.TextGrid

	n_wav = Get number of strings

	for ifile from 1 to n_wav

		select Strings list
		curr_file$ = Get string... 'ifile'
   	Read from file... 'orig_directory$'/'curr_file$'
		Rename... ORIG_TextGrid

   	Read from file... 'new_directory$'/'curr_file$'
		Rename... NEW_TextGrid
#		Remove tier... 3
#		Remove tier... 2

		plusObject: "TextGrid ORIG_TextGrid"
		Merge

	Save as text file... 'outputdir$'/'curr_file$'


	select all 
	minus Strings list
	Remove

endfor