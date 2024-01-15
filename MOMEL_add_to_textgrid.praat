 ##################################################
## This script uses the MOMEL and Intsint algorithms to
## calculate f0 min and max points of a pitch file
## It creates three new point tiers (Momel, Insint, IntsintMomel)
## 
## Reequirements: folder with sound files, textgrids
## 
## Author Catalina Torres 
## Created by Victor Pillac
## 
## catalina.torres@ivs.uzh.ch
## November 2023
#################################################### 
baseDir$ = chooseDirectory$ ("Choose folder containing files to be modified:")
beginPause: "Input directory name without final slash"
    comment: "Enter subdirectory where sound files  are kept:"
    sentence: "soundDirName", "sound"
    comment: "Enter subdirectory where TextGrid files are kept:"
    sentence: "textDirName", "grid"
  	comment: "Enter directory to which created TextGrids should be saved:"
  	sentence: "outGridDirName" , "Output"
clicked = endPause: "Continue", 1

soundDir$ = "'baseDir$'/'soundDirName$'"
textDir$ = "'baseDir$'/'textDirName$'"
outGridDir$ = "'baseDir$'/'outGridDirName$'"

# Create all output directories
createFolder: outGridDir$


# Remove outputs from the Praat Info (script output)
clearinfo

#from here V
#textDir$ = "/Users/catalina/Desktop/TEST-MOMEL-SG/P05"
#soundDir$ = "/Users/catalina/Desktop/TEST-MOMEL-SG/P05"
#outGridDir$ = "/Users/catalina/Desktop/TEST-MOMEL-SG/"
#baseFile$ = "P05F_051_adjo_obj1_VZ3_TS5_normal"



# specify files to be worked on
Create Strings as file list... list 'soundDir$'/*.wav

# loop that goes through all files
numberOfFiles = Get number of strings
appendInfoLine: "Processing 'numberOfFiles' files from 'soundDir$'"
for ifile to numberOfFiles
   select Strings list
   fileName$ = Get string... ifile
   baseFile$ = fileName$ - ".wav"
   outTextFile$ = "'outGridDir$'/'baseFile$'.TextGrid"



	# Read in the sound and TextGrid files with that base name
	Read from file... 'textDir$'/'baseFile$'.TextGrid
	Read from file... 'soundDir$'/'baseFile$'.wav

	appendInfoLine: "Processing 'baseFile$'"

	# First rename base TextGrid to merge later
	selectObject: "TextGrid 'baseFile$'"
	Rename: "'baseFile$'-base"

	selectObject: "Sound 'baseFile$'"

	runScript: preferencesDirectory$ + "/plugin_momel-intsint/analysis/automatic_min_max_f0.praat", "1.0 (= octaves)"
	runScript: preferencesDirectory$ + "/plugin_momel-intsint/analysis/momel_single_file.praat", "20 50 400 1.04 20 5 0.05"
	runScript: preferencesDirectory$ + "/plugin_momel-intsint/analysis/code_with_intsint.praat"


	selectObject: "TextGrid 'baseFile$'"
	plusObject: “TextGrid 'baseFile$'-base”
	Merge
	Rename: "'baseFile$'"
	Write to text file... 'outTextFile$'

	selectObject: "TextGrid 'baseFile$'"
	plusObject: “TextGrid 'baseFile$'-base”
	plusObject: “Sound 'baseFile$'”
	plusObject: “Pitch 'baseFile$'”
	plusObject: “PitchTier 'baseFile$'”
	plusObject: “Strings 'baseFile$'”
	Remove
	selectObject: "TextGrid 'baseFile$'"
	Remove
endfor