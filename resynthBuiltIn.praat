 ##################################################
## Resynthesise duration
## This Script looks at labels for syllables
## The time in the selected interval of a tier is doubled 
## It creates a new tier with new boundaries for token
## (including increased duration)
## new boundaries are at zero crossing
##
## Author Catalina Torres 
## September 2019
## Adapted from resynthf0.praat by Pauline Welby
## welby@icp.inpg.fr
## April 2006
#################################################### 
baseDir$ = chooseDirectory$ ("Choose folder containing files to be modified:")
beginPause: "Input directory name without final slash"
    comment: "Enter subdirectory where sound files  are kept:"
    sentence: "soundDirName", "sound"
    comment: "Enter subdirectory where TextGrid files are kept:"
    sentence: "textDirName", "grid"
    comment: "Enter subdirectory to which created files should be saved:"
  	 sentence: "outSoundDirName" , "resynthOutput/sound"
  	 comment: "Enter directory to which created TextGrids should be saved:"
  	 sentence: "outGridDirName" , "resynthOutput/grid"
    comment: "Specify tier name:"
    sentence: "tierNumber", "4"
    comment: "Specify the keyword to search for"
    sentence: "keyword", "X"
    comment: "Specify the stretch factor:"
    sentence: "stretchFactor", "0.5"
clicked = endPause: "Continue", 1

soundDir$ = "'baseDir$'/'soundDirName$'"
textDir$ = "'baseDir$'/'textDirName$'"
outDirSound$ = "'baseDir$'/'outSoundDirName$'"
outGridDir$ = "'baseDir$'/'outGridDirName$'"

# Create all output directories
createFolder: outDirSound$
createFolder: outGridDir$


# Remove outputs from the Praat Info (script output)
clearinfo

# specify files to be worked on
Create Strings as file list... list 'soundDir$'/*.wav

# loop that goes through all files
numberOfFiles = Get number of strings
appendInfoLine: "Processing 'numberOfFiles' files from 'soundDir$'"
for ifile to numberOfFiles
   select Strings list
   fileName$ = Get string... ifile
   baseFile$ = fileName$ - ".wav"
   outSoundFile$ = "'outDirSound$'/'keyword$'-'baseFile$'.wav"
   outTextFile$ = "'outGridDir$'/'keyword$'-'baseFile$'.TextGrid"

   # Convert strings to numbers for convenience
   tierNumber = number(tierNumber$)
   stretchFactor = number(stretchFactor$)

	appendInfoLine: "Processing 'baseFile$'"

	# Read in the sound and TextGrid files with that base name
	Read from file... 'textDir$'/'baseFile$'.TextGrid
	select TextGrid 'baseFile$'

	# Find if the keyword is present

	# Using TextGridNavigator - not sure why this does not work
	# To TextGridNavigator (topic search): 'tierNumber',
   # ... { "'keyword$'" }, "is equal to", "OR",
   # ... "Match start to Match end"
   # Find first
   # found = Get index: 'tierNumber', "topic"
   # appendInfoLine: " searching for 'keyword$' in 'tierNumber' - found at 'index'"

   # Count how many times keyword$ appear in Tier tierNumber
   found = 0
	nPoints = Get number of intervals... 'tierNumber'
	for intervalIdx from 1 to 'nPoints'
		label$ = Get label of interval... 'tierNumber' 'intervalIdx'
		if label$ = keyword$
			found = found + 1
		endif
	endfor

   if found <= 0
   	appendInfoLine: " Keyword 'keyword$' not found in tier 'tierNumber' - Skipping"
		# Clean up opened files
		Remove
   else
		Read from file... 'soundDir$'/'baseFile$'.wav

		select TextGrid 'baseFile$'
		To DurationTier... tierNumber stretchFactor 0.0001 0.0001  "is equal to" 'keyword$'
		select Sound 'baseFile$'
		To Manipulation... 0.01 75 600
		plus DurationTier 'baseFile$'
		Replace duration tier
		select Manipulation 'baseFile$'
		Get resynthesis (overlap-add)
		Rename... resynthDUR-'baseFile$'
		Save as WAV file... 'outSoundFile$'
		appendInfoLine: " Saved processed Audio to  'outSoundFile$'"


		select TextGrid 'baseFile$'
		plus DurationTier 'baseFile$'
		To TextGrid (scale times)
		Rename... resynthDUR-'baseFile$'
		Write to text file... 'outTextFile$'
		appendInfoLine: " Saved processed TexGrid to  'outTextFile$'"


		# Clean up opened files
		Remove
		select Sound 'baseFile$'
		plus TextGrid 'baseFile$'
		plus Manipulation 'baseFile$'
		plus DurationTier 'baseFile$'
		plus Sound resynthDUR-'baseFile$'
		Remove
	endif
endfor

select Strings list
Remove

################################################
##
## end of script
##
################################################