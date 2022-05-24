#####################################################################################
# Move right boundary of labeled intervals 
# Puts right boundaries at zero crossings
#
# Goes in a loop through separate folders
#
# Ignores empty intervals and intervals containing only a space
# or new line character (line break)
# Useful in creating precise duration before the end 
# of a sound when cutting stimuli  
# 
#
# Author: Catalina Torres
# DLL University of Zurich
# Modified from original script that moved boundaries to the left
# Danielle Daidone 5/2/17
#####################################################################################
baseDir$ = chooseDirectory$ ("Choose folder containing files to be modified:")
beginPause: "Move left and boundaries to zero crossing"
	comment: "Enter directory where sound files  are kept:"
    sentence: "soundDir", "'baseDir$'/out"
    comment: "Enter directory where TextGrid files are kept:"
    sentence: "textDir", "'baseDir$'/grid"
	comment: "Specify directory where new textgrid will be saved:"
	sentence: "saveDir",  "'baseDir$'/zero"
	comment: "Specify tier to be processed:"
	integer: "tier", "1" 
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


      #check if specified tier is interval tier
      interval = Is interval tier... 'tier'
      
      # Process intervals
      if interval
         ni = Get number of intervals... 'tier'
         for i to ni
          	label$[i] = Get label of interval... tier i
         endfor

             for i to ni
             select TextGrid 'baseFile$'
		  
		  #if interval is labeled
		  if label$[i] = ""
		  elsif label$[i] = " "
		  elsif label$[i] = newline$
		  else
		  appendInfoLine: label$[i]
            
			#move right boundary to closest zero crossing
			boundary = Get end point... tier i
			select Sound 'baseFile$'
			zero = Get nearest zero crossing... 1 boundary
			  if boundary != zero
				select TextGrid 'baseFile$'
				Remove right boundary... tier i
				Insert boundary... tier zero
			   endif
		
			
			select TextGrid 'baseFile$'
			b = Get end point... tier i
			appendInfoLine: "new boundaries: 'a', 'b''newline$'"
		

        select TextGrid 'baseFile$'
        for i to ni
          name$ = label$[i]
          Set interval text... tier i 'name$'
        endfor

	select TextGrid 'baseFile$'
	#Write to text file... 'baseDir$'_'baseFile$'.TextGrid
	Write to text file... 'saveDir$'/'baseFile$'.TextGrid
	Remove

	else
	writeInfoLine: "Specified tier is not an interval tier"
    endif

  endfor

  endfor