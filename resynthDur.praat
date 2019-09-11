##################################################
## Resynthesise duration
## This Script looks at labels for syllables
## The time in the selected interval is doubled 
##
## Author Catalina Torres 
## September 2019
## Adapted from resynthf0.praat by Pauline Welby
## welby@icp.inpg.fr
## April 2006
#################################################### 
baseDir$ = chooseDirectory$ ("Choose folder containing files to be modified:")
beginPause: "Input directory name without final slash"
    comment: "Enter directory where sound files  are kept:"
    sentence: "soundDir", "'baseDir$'/sound"
    comment: "Enter directory where TextGrid files are kept:"
    sentence: "textDir", "'baseDir$'/grid"
    comment: "Enter directory to which created sound files should be saved:"
  	sentence: "outDirSound" , "'baseDir$'/resynthDur"
    comment: "Specify tier name:"
    sentence: "tierName", "SYL"
clicked = endPause: "Continue", 1

# specify files to be worked on
Create Strings as file list... list 'soundDir$'/*.wav

# loop that goes through all files

numberOfFiles = Get number of strings
for ifile to numberOfFiles
   select Strings list
   fileName$ = Get string... ifile
   baseFile$ = fileName$ - ".wav"

# Read in the sound and TextGrid files with that base name

Read from file... 'soundDir$'/'baseFile$'.wav
Read from file... 'textDir$'/'baseFile$'.TextGrid

select TextGrid 'baseFile$'

## Search all tiers until appropriate tier is found
nTiers = Get number of tiers

for i from 1 to 'nTiers'

	tname$ = Get tier name... 'i'

		if tname$ = "'tierName$'"

		# Search for points for defining Duration			
		          nPoints = Get number of intervals... 'i'
			 for j from 1 to 'nPoints'
							
				lab$ = Get label of interval... 'i' 'j'

					 if lab$ = "1"
    				       	    time1s = Get start point... 'i' 'j'
					 endif

					  if lab$ = "1"
    				       	    time1e = Get end point... 'i' 'j'
					 endif

					 if lab$ = "F"
    				       	    timeFs = Get start point... 'i' 'j'
					 endif

					  if lab$ = "F"
    				       	    timeFe = Get end point... 'i' 'j'
					 endif
										 
			endfor
		endif

endfor



# specify new time value (relative to original value)

 new1s = time1s + 0.001
 new1e = time1e - 0.001 


# Create Manipulation object
select Sound 'baseFile$'
To Manipulation... 0.01 75 600

# Do the resynthesis
Extract duration tier
Rename... 'baseFile$'
#Create DurationTier: "lengthen", 0, 'time1s' + 'timeFe'
Add point:  'time1s', 1
Add point:  'new1s', 2
Add point:  'new1e', 2
Add point:  'time1e', 1
select Manipulation 'baseFile$'
plus DurationTier 'baseFile$'
Replace duration tier
select Manipulation 'baseFile$'
Get resynthesis (overlap-add)
Rename... resynthDUR-'baseFile$'


Save as WAV file... 'outDirSound$'/RD-'baseFile$'.wav

# Clean up

#Remove
#select Sound 'baseFile$'
#plus TextGrid 'baseFile$'
#plus Pitch 'baseFile$'
#plus Manipulation 'baseFile$'
#plus PitchTier 'baseFile$'
#Remove

endfor

select Strings list
Remove

################################################
##
## end of script
##
################################################