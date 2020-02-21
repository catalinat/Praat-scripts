##################################################
## Resynthesise duration
## This Script looks at labels for syllables
## The time in the selected interval of a tier (SYL) is lengthened by a strech factor 
## Time is scaled in TextGrid after manipulation
## It creates a new tier (cuts) with new boundaries for token and text (x)
## New tier includes increased duration +
## new boundaries at zero crossing
##
## Author Catalina Torres and Victor Pillac
## October 2019
## Adapted from resynthf0.praat by Pauline Welby
## welby@icp.inpg.fr
## April 2006
## See also http://www.fon.hum.uva.nl/praat/manual/TextGrid__To_DurationTier___.html
#################################################### 
baseDir$ = chooseDirectory$ ("Choose folder containing files to be modified:")
beginPause: "Input directory name without final slash"
    comment: "Enter directory where sound files  are kept:"
    sentence: "soundDir", "'baseDir$'/sound"
    comment: "Enter directory where TextGrid files are kept:"
    sentence: "textDir", "'baseDir$'/grid"
    comment: "Enter directory to which created sound files should be saved:"
  	sentence: "outDirSound" , "'baseDir$'/TEST"
    comment: "Target tier name:"
    sentence: "tierName", "SYL"
    comment: "Target label for interval to stretch:"
    sentence: "targetLabel", "1"
    # comment: "Stretch factor to change target inteval duration "
    # sentence: "stretchFactor", "210/'targetIntervalEnd'"
clicked = endPause: "Continue", 1


# specify files to be worked on
Create Strings as file list... list 'soundDir$'/*.wav

# Stretch factor for the first syllable
#stretchFactor = 'stretchFactor$'

# loop that goes through all files
numberOfFiles = Get number of strings
for ifile to numberOfFiles
   select Strings list
   fileName$ = Get string... ifile
   baseFile$ = fileName$ - ".wav"


	writeInfoLine: "Processing file ", baseFile$

	# Read in the sound and TextGrid files with that base name

	Read from file... 'soundDir$'/'baseFile$'.wav
	Read from file... 'textDir$'/'baseFile$'.TextGrid

	# Frst we need to make sure the TextGrid matches the sound file length exactly
	# select TextGrid 'baseFile$'
	# plus Sound 'baseFile$'
	# Scale times

	## Search all tiers until appropriate tier is found
	select TextGrid 'baseFile$'
	nTiers = Get number of tiers

	for i from 1 to 'nTiers'
		tname$ = Get tier name... 'i'
		if tname$ = "'tierName$'"
		# Search for points for defining Duration			
	          nPoints = Get number of intervals... 'i'
			 for j from 1 to 'nPoints'
							
				lab$ = Get label of interval... 'i' 'j'

				 if lab$ = "ar"
		       	    tokenStart = Get start point... 'i' 'j'
				 endif

				 if lab$ = "'targetLabel$'"
		       	    targetIntervalStart = Get start point... 'i' 'j'
		       	    targetIntervalEnd = Get end point... 'i' 'j'
				 endif

				 if lab$ = "F"
		       	    tokenEnd = Get end point... 'i' 'j'
				 endif
										 
			endfor
		endif
	endfor

	# Create two new points slightly after the start and before the end 
	#  to define the step function to change duration
	paddedIntervalStart = targetIntervalStart + 0.001
	paddedIntervalEnd = targetIntervalEnd - 0.001 
     

	# Create Manipulation object
	select Sound 'baseFile$'
	To Manipulation... 0.01 75 600

	appendInfoLine: "Changing duration of interval with label 'targetLabel$' from tier 'tierName$'"
	appendInfoLine: "Start: ", targetIntervalStart, "End: ", targetIntervalEnd
	appendInfoLine: "Token duration :", (tokenEnd - tokenStart)

	# Do the resynthesis
	Extract duration tier
	Rename... 'baseFile$'
	Add point:  'targetIntervalStart', 1
	Add point:  'paddedIntervalStart', 190/'targetIntervalEnd'
	Add point:  'paddedIntervalEnd', 190/'targetIntervalEnd'
	Add point:  'targetIntervalEnd', 1

	select Manipulation 'baseFile$'
	plus DurationTier 'baseFile$'
	Replace duration tier
	
	select Manipulation 'baseFile$'
	Get resynthesis (overlap-add)
	Rename... rd-'baseFile$'
	appendInfoLine: "Saving new wav file to 'outDirSound$'/rd-'baseFile$'.wav"
	Save as WAV file... 'outDirSound$'/rd-'baseFile$'.wav

	# # Create new boundaries for the token
 #    durationDelta = (paddedIntervalEnd - paddedIntervalStart) * (stretchFactor - 1)
	# zeroStart = Get nearest zero crossing... 1 tokenStart
	# zeroEnd = Get nearest zero crossing... 1 tokenEnd + durationDelta
	
	# # Scale the TextGrid
	# select TextGrid 'baseFile$'
	# plus DurationTier 'baseFile$'
	# To TextGrid (scale times)
	# Rename... rd-'baseFile$'

	# appendInfoLine: "Adding a new tier 'cuts' with new token boundaries"
	# Insert interval tier: 1, "cuts"
	# Insert boundary... 1 zeroStart
	# Insert boundary... 1 zeroEnd
	# Set interval text... 1 2 x

	# appendInfoLine: "New Token duration :", (tokenEnd - tokenStart)

	#appendInfoLine: "Saving new TextGrid to 'outDirSound$'/rd-'baseFile$'.TextGrid"
	#Save as text file... 'outDirSound$'/rd-'baseFile$'.TextGrid

	# cleanup selection
	#select Manipulation 'baseFile$'
	#plus DurationTier 'baseFile$'
	#plus TextGrid 'baseFile$'
	#plus Sound 'baseFile$'
	#plus TextGrid rd-'baseFile$'
	#plus Sound rd-'baseFile$'
	#Remove
endfor


################################################
##
## end of script
##
################################################