##################################################
## Script looks at label files and does f0 resynthesis
## script works with folder organised into three other folders each for: 
## 1. sound files to be manipulated
## 2. TextGrids files with marked tonal targets
## 3. empty folder where new resynthesised sound files will be stored
## script gets F0 values for all marked poits
## resynthesis done with PSOLA
## new sound files carries RF- prefrix
##
## Pauline Welby
## welby@icp.inpg.fr
## April 2006
## Modified by Catalina Torres 
## September 2019
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
    sentence: "tierName", "Tones"
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

		# Search for points for defining F0			
		          nPoints = Get number of points... 'i'
			 for j from 1 to 'nPoints'
							
				lab$ = Get label of point... 'i' 'j'

					 if lab$ = "L1"
    				       	    timeA = Get time of point... 'i' 'j'
					 endif

					 if lab$ = "L2"
    				       	    timeB = Get time of point... 'i' 'j'
					 endif

					 if lab$ = "H1"
    				       	    timeC = Get time of point... 'i' 'j'
					 endif

                     if lab$ = "L3"
    				       		timeD = Get time of point... 'i' 'j'
					 endif

					 # if lab$ = "H2"
    		# 		       	    timeE = Get time of point... 'i' 'j'
					 # endif
										 
			endfor
		endif

endfor


# Select the Sound file and make a Manipulaton object
select Sound 'baseFile$'
To Pitch (ac)... 0 75 15 no 0.03 0.45 0.01 0.35 0.14 600
f0A = Get value at time... 'timeA' Hertz Linear
f0B = Get value at time... 'timeB' Hertz Linear
f0C = Get value at time... 'timeC' Hertz Linear
f0D = Get value at time... 'timeD' Hertz Linear
# f0E = Get value at time... 'timeE' Hertz Linear


# specify new f0 value (relative to original value)

newf0C = f0B
#newf0D = f0C

# Create Manipulation object
select Sound 'baseFile$'
To Manipulation... 0.01 75 600

# Do the resynthesis
Extract pitch tier
Rename... 'baseFile$'
Remove points between... 'timeA' 'timeD'
Add point... 'timeC' 'newf0C'
#Add point... 'timeD' 'newf0D'
select Manipulation 'baseFile$'
plus PitchTier 'baseFile$'
Replace pitch tier
select Manipulation 'baseFile$'
Get resynthesis (PSOLA)
Rename... resynth-'baseFile$'


Write to WAV file... 'soundDir$'/RF-'baseFile$'.wav

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