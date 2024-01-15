##################################################
## Replace or create boundaries in first tier
## This Script finds the text in tier one 
## Finds the first and last boundaries in tier 2
## Adds the first and last boundaries to tier 1
## Author Catalina Torres 
## Written by Victor Pillac
#################################################### 
baseDir$ = chooseDirectory$ ("Choose folder containing files to be modified:")
beginPause: "Input directory name without final slash"
    comment: "Enter directory where TextGrid files are kept:"
    sentence: "textDir", "'baseDir$'"
  	 comment: "Enter directory to which created TextGrids should be saved:"
  	 sentence: "saveDir" , "'baseDir$'/new"
     comment: "Specify tier name for text:"
     sentence: "tierName1", "utt"
     comment: "Specify tier name for boundaries:"
     sentence: "tierName2", "ort"
clicked = endPause: "Continue", 1

# specify files to be worked on
Create Strings as file list... list 'baseDir$'/*.TextGrid


# loop that goes through all files
numberOfFiles = Get number of strings
for ifile to numberOfFiles
	select Strings list
	fileName$ = Get string... ifile
	baseFile$ = fileName$ - ".TextGrid"

	# Read in the sound and TextGrid files with that base name
	Read from file... 'textDir$'/'baseFile$'.TextGrid
	appendInfoLine: "Processing", baseFile$

	select TextGrid 'baseFile$'

	# Find the boudaries from tier 2
	intervalsInTwo = Get number of intervals... 2
	time1s = Get end point... 2 1
	time1e = Get start point... 2 'intervalsInTwo'

	appendInfoLine: "Start:", time1s, " End: ", time1e

	# Check the first interval
	intervalsInOne = Get number of intervals... 1
	firstBoundary = Get end point... 1 1
	lastBoundary = Get start point... 1 'intervalsInOne'

	appendInfoLine: "Existing Boundaries", firstBoundary,  " ", lastBoundary
	if firstBoundary != time1s
		appendInfoLine: "Adding first boundary"
		intText$ = Get label of interval... 1 1
		# Add boundary in Tier 1 at time1s
		Insert boundary... 1 time1s
		# Move text
		# Set text on Tier 1 Interval 1 to be empty
		Set interval text... 1 1 
		# Set text on Tier 1 Interval 2 to be intText
		Set interval text... 1 2 'intText$'
	endif

	if lastBoundary != time1e
		appendInfoLine: "Adding last boundary"
		Insert boundary... 1 time1e
	endif

	Write to text file... 'saveDir$'/'baseFile$'.TextGrid

	# Clean up

	#Remove
	select TextGrid 'baseFile$'
	# plus TextGrid 'baseFile$'
	# plus Pitch 'baseFile$'
	# plus Manipulation 'baseFile$'
	# plus PitchTier 'baseFile$'
	Remove

endfor

select Strings list
Remove

################################################
##
## end of script
##
################################################