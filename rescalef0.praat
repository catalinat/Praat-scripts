##################################################
## Script looks at label in files and does f0 resynthesis
## script works with folder organised into three other folders each for: 
## 1. sound files to be manipulated
## 2. TextGrids files with marked tonal targets
## 3. empty folder where new resynthesised sound files will be stored
## script gets F0 values for all marked poits with I - a ereference point
## it finds all Fo values higher than the reference (+20Hz) and reduces them 
## to the reference level
## resynthesis done with PSOLA
## new sound files carries RF- prefrix
##
## Catalina Torres & Victir Pillac 
## January 2024
#################################################### 
baseDir$ = chooseDirectory$ ("Choose folder containing files to be modified:")
beginPause: "Input directory name without final slash"
    comment: "Enter directory where sound files  are kept:"
    sentence: "soundDir", "'baseDir$'/sound"
    comment: "Enter directory where TextGrid files are kept:"
    sentence: "textDir", "'baseDir$'/grid"
    comment: "Enter directory to which created sound files should be saved:"
  	 sentence: "outDirSound" , "'baseDir$'/resynth"
    comment: "Specify tier name:"
    sentence: "tierNumber", "5"
    comment: "Specify the label to search for"
    sentence: "labelc", "T"
    comment: "Specify the reference to search for"
    sentence: "reference", "I"
clicked = endPause: "Continue", 1

# Remove outputs from the Praat Info (script output)
clearinfo
#select all
#Remove

# specify files to be worked on
Create Strings as file list... list 'soundDir$'/*.wav

# loop that goes through all files

numberOfFiles = Get number of strings
for ifile to numberOfFiles
   select Strings list
   fileName$ = Get string... ifile
   baseFile$ = fileName$ - ".wav"


	appendInfoLine: "Processing 'baseFile$'"

	# Read in the sound and TextGrid files with that base name

	Read from file... 'soundDir$'/'baseFile$'.wav
	Read from file... 'textDir$'/'baseFile$'.TextGrid

 	# Create pitch object
	select Sound 'baseFile$'
	To Pitch (ac)... 0 75 15 no 0.03 0.45 0.01 0.35 0.14 600 

	# Create Manipulation object
	select Sound 'baseFile$'
	To Manipulation... 0.01 75 600
	Extract pitch tier
	Rename... 'baseFile$'
	# Stylize pitch (default: 2 semitones)
	# Stylize... 2.0 semitones


	# reset f0ref
	f0ref = -1

	select TextGrid 'baseFile$'

	# Convert strings to numbers for convenience
	tierNumber = number(tierNumber$)
	# Count how many times label$ appear in Tier tierNumber
	found = 0
	nPoints = Get number of points... 'tierNumber'
	
	# Go through all points and find the reference pitch
	for pointIdx from 1 to 'nPoints'
		label$ = Get label of point... 'tierNumber' 'pointIdx'
		# get time points for label$
		time = Get time of point... 'tierNumber' 'pointIdx'
		if label$ = reference$
			select Pitch 'baseFile$'
			f0ref = Get value at time... 'time' Hertz Linear
			select TextGrid 'baseFile$'
			appendInfoLine: "Found reference pitch: 'f0ref' ('label$' on point 'pointIdx' at 'time')"
		# elif label$ = labelc$
		# 	if f0ref < 0
		# 		appendInfoLine: "ERROR: Reference pitch not found"
		# 	else
		# 		appendInfoLine: "Modifying pitch of point ('label$' on point 'pointIdx' at 'time')"
		# 		select PitchTier 'baseFile$'
		# 		Add point... 'time' 'f0ref'
		# 		select TextGrid 'baseFile$'
		# 	endif
		endif
	endfor

	if f0ref < 0
		appendInfoLine: "ERROR: Reference pitch not found for 'baseFile$'"
	else
		select PitchTier 'baseFile$'
		nPoints = Get number of points


		f0ref = f0ref + 20

		# Go through all points from the pitch tier
		for pointIdx from 1 to 'nPoints'
			pitch = Get value at index... 'pointIdx'
			if pitch > f0ref
				# appendInfoLine: "Capping Pitch @ 'pointIdx': 'pitch' to 'f0ref'"	
				time = Get time from index... 'pointIdx'
				Remove point... 'pointIdx'
				Add point... 'time' 'f0ref'
			endif
		endfor

		# Execute manipulation
		select Manipulation 'baseFile$'
		plus PitchTier 'baseFile$'
		Replace pitch tier
		select Manipulation 'baseFile$'
		Get resynthesis (PSOLA)
		Rename... resynth-'baseFile$'

		Write to WAV file... 'outDirSound$'/RF-'baseFile$'.wav
	endif


	# Clean up
	select Sound 'baseFile$'
	plus TextGrid 'baseFile$'
	plus Pitch 'baseFile$'
	plus Manipulation 'baseFile$'
	plus PitchTier 'baseFile$'
	# Remove

endfor


################################################
##
## end of script
##
################################################