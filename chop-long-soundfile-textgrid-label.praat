#########################################################################################################
### chop-long-soundfile.praat
###
### Saves little sound files from one big sound file.
###  
### Opens a soundfile as a LongSound object and reads in its associated TextGrid file.
###
### Extracts the portion of the sound file corresponding to all non-empty intervals on a specified tier,
### with an optional buffer on each end.
###
### Saves each extracted portion to a .wav file named:
### (<prefix>)<originalfilename>_<time_value>(<suffix>).wav
###
### NB: The time value (in seconds to two decimal places) of the beginning of the segment
### in the original sound file is included in the file name. 
###
### This disambiguates between two tokens of the same word and also allows one to find the word 
### in the longer sound file, if need be. 
###
### Creates and saves a TextGrid file for each token.
###
### Creates two separate directories for .wav and .TexGrid files 
### Creates a text file named:
### <orginal long sound file name>_list.txt
### that contains a list of all the .wav files created. Useful for keeping track of what came from where.
###
###
### Praat 4.4.16
###
### Pauline Welby  
### welby@icp.inpg.fr
### April 2006
### Modified by
### Catalina Torres, January 2018
###
#########################################################################################################

#  form that asks user for the directories containing file to be worked on, 
#  and for other information 
baseDir$ = chooseDirectory$: "Select base directory (where soundfiles are kept)"
beginPause: "Chop long soundfiles - Parameters"
  comment: "Enter parent directory where sound files are kept:"
  sentence: "soundDir" , "'baseDir$'"
  comment: "Enter directory where TextGrid files are kept:"
  sentence: "textDir" , "'baseDir$'/TextGrids"
  comment: "Enter directory to which created sound files should be saved:"
  sentence: "outDirSound" , "'baseDir$'/out"
  comment: "Enter directory to which created TextGrid files should be saved:"
  sentence: "outDirTex" , "'baseDir$'/grid"
  comment: "Specify tier name: "
  sentence: "tierName" , "utterances"
  comment: "Specify length of left and right buffer (in seconds):"
  positive: "margin" , "0.100"
  comment: "Optional prefix:"
  sentence: "prefix" , ""
  comment: "Optional suffix (.wav will be added anyway):"
  sentence: "suffix" , ""
  comment: "Append time point?"
  boolean: "append_time", 1
  comment: "Chop Textgrids?"
  boolean: "chopTextgrids", 1
  comment: "Enter basename of soundfile (without .wav extension)"
  sentence: "baseName", "Initial_MaxContrast_1_01"
clicked = endPause: "Continue", 1

# delete any existing record file
#filedelete 'outDir$'/list.txt

# print name of long sound file to output file 
#fileappend 'outDir$'/list.txt 'baseName$'.wav 'newline$'

writeInfoLine: "Start"
numberOfFiles = 1
for ifile to numberOfFiles
  # Read in the Sound and TextGrid files
  appendInfoLine: "Reading file: 'baseName$'.wav" 
  Open long sound file... 'soundDir$'/'baseName$'.wav
  Read from file... 'textDir$'/'baseName$'.TextGrid

  # Go through tiers and extract info

  select TextGrid 'baseName$'

  selectedTier = -1
  nTiers = Get number of tiers
  for i from 1 to 'nTiers'
    tname$ = Get tier name... 'i'
    if tname$ = "'tierName$'"
      if selectedTier != -1
        appendInfoLine: "Warning: Duplicate tier with name ['tierName$']"
      endif
      selectedTier = i
    endif
  endfor

  if selectedTier = -1
    appendInfoLine: "Warning: Tier ['tierName$'] not found"
  else
    # Find non-empty intervals
    appendInfoLine: "Intervals for Tier ['tierName$'] ('selectedTier'): "
    nInterv = Get number of intervals... 'selectedTier'

    for j from 1 to 'nInterv'
      lab$ = Get label of interval... 'selectedTier' 'j'

      if lab$ != ""
        # Get time values for start and end of the interval
        begwd = Get starting point... 'selectedTier' 'j'            
        endwd = Get end point... 'selectedTier' 'j'

        appendInfo: " 'lab$' ['begwd:2'-'endwd:2'] "

        # Base file name for sound output
        if append_time = 1
          timeStamp$ =  replace$ ("'begwd:2'", ".", "_", 0)
          outputBaseS$ = "'outDirSound$'/'prefix$''lab$'-'baseName$'-'timeStamp$''suffix$'"
        else
          outputBaseS$ = "'outDirSound$'/'prefix$''lab$''baseName$''suffix$'"
        endif

        # Base file name for outDirTex
        if append_time = 1
          timeStamp$ =  replace$ ("'begwd:2'", ".", "_", 0)
          outputBase$ = "'outDirTex$'/'prefix$''lab$''baseName$'-'timeStamp$''suffix$'"
        else
          outputBase$ = "'outDirTex$'/'prefix$''lab$''baseName$''suffix$'"
        endif


        appendInfo: " >  'outputBaseS$'"
        appendInfo: " >  'outputBase$'"

        # Add buffers, if specified
        begfile = 'begwd'-'margin'
        endfile = 'endwd'+'margin' 
        duration = 'endfile'-'begfile'

        # Create and save small .wav file

        # Split wav file
        select LongSound 'baseName$'
        Extract part... 'begfile' 'endfile' no
        Write to WAV file... 'outputBaseS$'.wav

        # Split Textgrid
        if chopTextgrids
          if fileReadable ( "'outputBase$'.TextGrid" )
            appendInfo: " (skipping existing textgrid) "
          else
            # Split wav file
            select TextGrid 'baseName$'
            Extract part... 'begfile' 'endfile' no

            # Set start time 0
            # Set end time 'duration'
            Write to text file... 'outputBase$'.TextGrid
    
            Remove
          endif
        endif
       # Write label of each saved interval to a text file (keeps a record of origin of small soundfiles)

       #fileappend 'outDirSound$'/'baseName$'_list.txt 'prefix$''lab$'_'begwd:1''suffix$'.wav 'newline$'
       #fileappend 'outDirTex$'/'baseName$'_list.txt 'prefix$''lab$'_'begwd:1''suffix$'.wav 'newline$'
       ## Object cleanup
       select Sound 'baseName$'
       Remove

       ## Re-select TextGrid
       select TextGrid 'baseName$'

       # New line in console
       appendInfoLine: ""
     endif
   endfor
  endif
  appendInfoLine: ""
endfor
#Complete object cleanup
select TextGrid 'baseName$'
plus LongSound 'baseName$'
appendInfoLine: "Done"
####### END OF SCRIPT #######for