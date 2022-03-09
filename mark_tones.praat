#################################################################
## label-tones.praat 
## 
## creates a TextGrid file with a number of tiers for for each specified .wav file
## goes through files, prompting user to click on beginning and end
## of target syllable and surrounding syllables
## 
## detects local F0 maxima and minima
## adds boundaries and points at specified locations, 
## displays the labelling to allow the user to make 
## any necessary corrections (for mis-clicks, for example)
##
## Pauline Welby
## welby@icp.inpg.fr
## September 2005
##
## works with Praat 4.3.29
##
#################################################################
# Notes 08.03.2022 - script creates new textgrid and takes you through to mark start 
# and end points - it would be better to have these predefined and use existing textgrids

# brings up form that prompts the user to enter directory name
# creates variable
baseDir$ = chooseDirectory$: "Select base directory (where soundfiles are kept)"
beginPause: "Add tonal labels - Parameters"
  comment: "Enter parent directory where sound files are kept:"
  sentence: "soundDir" , "'baseDir$'/sound"
  comment: "Enter directory where TextGrid files are kept:"
  sentence: "textDir" , "'baseDir$'/textgrids"
  comment: "Enter directory where list files are kept:"
  sentence: "listDir" , "'baseDir$'/list"
  comment: "Specify tier name: "
  sentence: "tierName" , "Ut"
  comment: "Enter the step size (window duration) for creation of Pitch object." 
  comment: "Remember '0' before decimal point."
  positive: "step", "0.005"
  comment: "Automatic zoom?"
  boolean: "zoom", 1
clicked = endPause: "Continue", 1

# Makes list of files to be labelled, creates a variable with basename of file
# opens loop 
Create Strings as file list... listwav 'soundDir$'/*.wav


#Read Strings from raw text file... 'listDir$'/list.txt
numberOfFiles = Get number of strings
for ifile to numberOfFiles
   select Strings list
   fileName$ = Get string... ifile
   Read from file... 'soundDir$'/'fileName$'
   # strip extension to get basename
   baseFile$ = fileName$ - ".wav"

# Create Pitch object.
# Tweak the following settings, to set a higher voicing threshold, for example
# Note first value is the time step
To Pitch (ac)... 'step' 75 15 no 0.03 0.45 0.01 0.35 0.30 600

# Open sound file
	Read from file... 'soundDir$'/'baseFile$'.wav

# Open TextGrid file
  Read from file... 'textDir$'/'baseFile$'.TextGrid

# create .TextGrid file
# NB: The second instance of segments (without quotation marks) indicates that this 
# is a point tier
# make TextGrid
# select Sound 'baseFile$'
# To TextGrid... "misc tones phonological rhythmic syllables orthographic" tones






# get total duration (to use later in script to set zoom) 
durutt = Get total duration

# select Sound object and display it
select Sound 'baseFile$'
Edit
editor Sound 'baseFile$'

### THIS IS WHERE THE MARKING STARTS
### for targets with ZERO post-nuclear syllables

 if selectedTier = -1
    appendInfoLine: "Warning: Tier ['tierName$'] not found"
  else
    # Find non-empty intervals
    appendInfoLine: "Intervals for Tier ['tierName$'] ('selectedTier'): "
    nInterv = Get number of intervals... 'selectedTier'
   
   if lab$ != ""
        # Get time values for start and end of the interval
        uttBeg = Get starting point... 'selectedTier' 'j'            
        uttEnd = Get end point... 'selectedTier' 'j'

        appendInfo: " 'lab$' ['uttBeg:2'-'uttEnd:2'] "
   
  ###### OLD
   # prompts user to click on vowel beginning and end, create variables with values at point clicked

   #pause Click Get start utterance
   #Move cursor to nearest zero crossing
   #uttBeg = Get cursor
 
   #pause Click Get end utterance
   #Move cursor to nearest zero crossing
   #uttEnd = Get cursor
   
   if 'zoom' = 1
    # automatically zoom (to a one-second region at end of file)
    Zoom... 'durutt'-1 'durutt'
   endif

# RETAKE FROM HERE
   pause Click Get start target syllable
   Move cursor to nearest zero crossing
   targBeg = Get cursor

   targEnd = uttEnd

   pause Click Get start of syllable preceding target
   Move cursor to nearest zero crossing
   ptargBeg = Get cursor

Close
endeditor

  # find location of tones

  select Pitch 'baseFile$'

  # H* pitch accent
  
  hLoc = Get time of maximum... 'targBeg' 'targEnd' Hertz Parabolic

  # l(H*), low preceding H* pitch accent

  lLoc = Get time of minimum... 'ptargBeg' 'hLoc' Hertz Parabolic

  # L, low following H* pitch accent

  l2Loc = Get time of minimum... 'hLoc' 'uttEnd' Hertz Parabolic

  # add tags in the TextGrid at right times

  select TextGrid 'baseFile$'
  
  # insert tags in syllable tier
  Insert boundary... 5 'ptargBeg'
  Insert boundary... 5 'targBeg'
  Insert boundary... 5 'targEnd'

  # add text
  Set interval text... 5 2 sp1
  Set interval text... 5 3 s1

  Insert point... 2 'hLoc' H
  Insert point... 2 'lLoc' l
  Insert point... 2 'l2Loc' L

 endif

### for targets with ONE post-nuclear syllable

 if 'postTarg' = 1

   # prompts user to click on vowel beginning and end, create variables with values at point clicked

   pause Click Get start utterance
   Move cursor to nearest zero crossing
   uttBeg = Get cursor
 
   pause Click Get end utterance
   Move cursor to nearest zero crossing
   uttEnd = Get cursor

   if 'zoom' = 1
    # automatically zoom (to a one-second region at end of file)
    Zoom... 'durutt'-1 'durutt'
   endif

   pause Click Get start target syllable
   Move cursor to nearest zero crossing
   targBeg = Get cursor

   pause Click Get end target syllable
   Move cursor to nearest zero crossing
   targEnd = Get cursor

   pause Click Get start of syllable preceding target
   Move cursor to nearest zero crossing
   ptargBeg = Get cursor

Close
endeditor

  # find location of tones

  select Pitch 'baseFile$'

  # H* pitch accent  
  hLoc = Get time of maximum... 'targBeg' 'uttEnd' Hertz Parabolic

  # l(H*), low preceding H* pitch accent

  lLoc = Get time of minimum... 'ptargBeg' 'hLoc' Hertz Parabolic

  # L, low following H* pitch accent

  l2Loc = Get time of minimum... 'hLoc' 'uttEnd' Hertz Parabolic

  # add tags in the TextGrid at right times

  select TextGrid 'baseFile$'

  # insert tags in orthographic tier

  Insert boundary... 5 'ptargBeg'
  Insert boundary... 5 'targBeg'
  Insert boundary... 5 'targEnd'
  Insert boundary... 5 'uttEnd'

  # add text
  Set interval text... 5 2 sp1
  Set interval text... 5 3 s1
  Set interval text... 5 4 s2

  Insert point... 2 'hLoc' H
  Insert point... 2 'lLoc' l
  Insert point... 2 'l2Loc' L

 endif

 ### for targets with TWO post-nuclear syllables

 if 'postTarg' = 2

  # prompts user to click on vowel beginning and end, create variables with values at point clicked

   pause Click Get start utterance
   Move cursor to nearest zero crossing
   uttBeg = Get cursor
 
   pause Click Get end utterance
   Move cursor to nearest zero crossing
   uttEnd = Get cursor

   if 'zoom' = 1
    # automatically zoom (to a one-second region at end of file)
    Zoom... 'durutt'-1 'durutt'
   endif

   pause Click Get start target syllable
   Move cursor to nearest zero crossing
   targBeg = Get cursor

   pause Click Get end target syllable
   Move cursor to nearest zero crossing
   targEnd = Get cursor

   pause Click Get end of syllable following target
   Move cursor to nearest zero crossing
   ftargEnd = Get cursor

   pause Click Get start of syllable preceding target
   Move cursor to nearest zero crossing
   ptargBeg = Get cursor

Close
endeditor

   # find location of tones

   select Pitch 'baseFile$'

   # H* pitch accent

   hLoc = Get time of maximum... 'targBeg' 'uttEnd' Hertz Parabolic

   # l(H*), low preceding H* pitch accent

   lLoc = Get time of minimum... 'ptargBeg' 'hLoc' Hertz Parabolic

   # L, low following H* pitch accent

   l2Loc = Get time of minimum... 'hLoc' 'uttEnd' Hertz Parabolic

   # add tags in the TextGrid at right times

   select TextGrid 'baseFile$'

   # insert tags in syllable tier

   Insert boundary... 5 'ptargBeg'
   Insert boundary... 5 'targBeg'
   Insert boundary... 5 'targEnd'
   Insert boundary... 5 'ftargEnd'
   Insert boundary... 5 'uttEnd'

   # add text
   Set interval text... 5 2 sp1
   Set interval text... 5 3 s1
   Set interval text... 5 4 s2
   Set interval text... 5 5 s3

   Insert point... 2 'hLoc' H
   Insert point... 2 'lLoc' l
   Insert point... 2 'l2Loc' L

 endif

 ###

# allow user to confirm tagging (and make any necessary changes)

select Sound 'baseFile$'
plus TextGrid 'baseFile$'
Edit
pause CONFIRM TextGrid

# save TextGrid file

select TextGrid 'baseFile$'
Write to text file... 'textDir$'\'baseFile$'.TextGrid

###### Cleaning up objects before proceeding to the next file
select Sound 'baseFile$'
plus TextGrid 'baseFile$'
plus Pitch 'baseFile$'
Remove

endfor

###### Remove Strings object for complete object cleaning up
select Strings list
Remove
######

###############
##end of script
###############