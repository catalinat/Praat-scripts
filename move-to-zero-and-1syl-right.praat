###################################################################################
# This script is used in combination with the resynthDur.praat script
# It moves left and right boundaries of labeled intervals 
# Since in resynthDur.praat the first syllable is lengthened
# This duration is added at the right boundary of the word 
# It puts left and right boundaries at zero crossings
# 
# Goes in a loop through separate folders containing multiple files
#
# Ignores empty intervals and intervals containing only a space
# or new line character (line break)
# Useful in creating precise duration before the beginning 
# of a sound when cutting stimuli  
# 
#
# Author: Catalina Torres
# Phonetics Laboratory University of Melbourne
# Modified from original script that moved boundaries to the left
# Danielle Daidone 5/2/17
#####################################################################################


baseDir$ = chooseDirectory$ ("Choose folder containing files to be modified:")
beginPause: "Move left to zero crossing and final boundary further to the right"
	comment: "Enter directory where sound files  are kept:"
    sentence: "soundDir", "'baseDir$'"
    comment: "Enter directory where TextGrid files are kept:"
    sentence: "textDir", "'baseDir$'/grid"
	comment: "Specify directory where new textgrid will be saved:"
	sentence: "saveDir",  "'baseDir$'/zero"
	comment: "Specify tier with information of changing duration:"
	sentence: "tierName", "SYL" 
	comment: "Specify tier to be processed:"
	integer: "proTier", "1" 
	comment: "With which file number do you wish to start working?"
	integer: "nfile", 1
endPause: "Continue", 1

writeInfoLine: "Boundaries moved for the following labeled intervals:'newline$'"

# specify files to be worked on
Create Strings as file list... list 'soundDir$'/*.wav

# loop that goes through all files
numberOfFiles = Get number of strings
for ifile to numberOfFiles
   select Strings list
   fileName$ = Get string... ifile
   baseFile$ = fileName$ - ".wav"
 
# Test if loop is working
#print 'baseFile$' 'tab$' "in the loop" 'newline$'

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
										 
			endfor
		endif

endfor



# specify new time value (relative to original value)
 new1s = time1s + 0.001
 new1e = time1e - 0.001 
# specify new value for modification 
 newAdd = new1e - new1s


	# Proceed to move boundaries 

      # check if specified tier is interval tier
      interval = Is interval tier... 'proTier'
      
      # Process intervals
      if interval 
         ni = Get number of intervals... 'proTier'
         for i to ni
          	label$[i] = Get label of interval... proTier i
         endfor


             for i to ni
             select TextGrid 'baseFile$'
		  
		  #if interval is labeled
		  if label$[i] = ""
		  elsif label$[i] = " "
		  elsif label$[i] = newline$
		  else
		  appendInfoLine: label$[i]
            
			#move left boundary to closest zero crossing
			select TextGrid 'baseFile$'
			boundary = Get start point... proTier i
			select Sound 'baseFile$'
			zero = Get nearest zero crossing... 1 boundary
			  if boundary != zero
				select TextGrid 'baseFile$'
				Remove left boundary... proTier i
				Insert boundary... proTier zero
			  endif
		    
			#move right boundary later by specified duration
			select TextGrid 'baseFile$'
			rightbound = Get end point... proTier i
			appendInfoLine: "original boundaries:'rightbound', 'boundary'"
			Insert boundary... proTier rightbound + newAdd
			Remove right boundary... proTier i
						
			#move right boundary to closest zero crossing
			boundary2 = Get end point... proTier i
			select Sound 'baseFile$'
			zero2 = Get nearest zero crossing... 1 boundary2
			  if boundary2 != zero2
				select TextGrid 'baseFile$'
				Remove right boundary... proTier i
				Insert boundary... proTier zero2
			  endif
			select TextGrid 'baseFile$'
			a = Get start point... proTier i
			b = Get end point... proTier i
			appendInfoLine: "new boundaries: 'a', 'b''newline$'"
			
		  endif
               endfor

        select TextGrid 'baseFile$'
        for i to ni
          name$ = label$[i]
          Set interval text... proTier i 'name$'
        endfor

	select TextGrid 'baseFile$'
	Write to text file... 'saveDir$'/'baseFile$'.TextGrid

	else
	writeInfoLine: "Specified tier is not an interval tier"
     endif

      endfor