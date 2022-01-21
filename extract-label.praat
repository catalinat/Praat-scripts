 #	extract-labels (December 2019)
#
# 	Reads sound files and its TextGrid tier for each of the sounds to get:
#		a) Pitch accent label form point tier, 
#		b) Boundary tone label from the same point tier
#		c) label from one interval tier (prag)
#		d) labels from another interval tier (utterance)
# 		
#	
# 
# 								INSTRUCTIONS
#	0. You need a .wav with its Textgrid saved in the same folder and with at least 1 point tier and 2 interval tiers.
#	1. Run
#	2. FORM EXPLANATIONS:
#		First choose the name of the csv that will be created (now: labels)
#		Then choose interval tiers and point tier
#	3. Select folder with .wav + .TextGrids
#
#		Modified by Catalina Torres, Phonetics lab, University of Melbourne 
#		Catalinat@student.unimelb.edu.au
#		Original Wendy Elvira-Garcia
#		Laboratory of Phonetics (University of Barcelona)
#		
#		
##############################################################################################################





#Limpia los objetos que te has olvidado en el Praat antes de empezar, sÃ­, tb los que no guardaste.
select all
if numberOfSelected() > 0
	Remove
endif

if praatVersion < 5363
exit This script works only in Praat  5363 or later
endif

folder$ = chooseDirectory$ ("Choose folder with TextGrids and sound files:")

form Labels
	comment csv name (it will be created in the same folder where the files are kept): 
	text csvname labels
	comment Which data do you want to extract?
	comment Tier number for interval tier labels (utterance transcription):
	integer tier_interval 1
	comment Tier number for interval tier labels (pragmatics transcription):
	integer tier_prag 2
	comment Tier number for point tier label:
	integer point_tier 4

endform


#########################	Create file and header	#########################################



# Create csv file 
arqout$ = folder$ + "/" + csvname$ + ".csv"
if fileReadable (arqout$)
	pause There is already a file with that name, you will overwrite it
	deleteFile: arqout$
endif

	appendFileLine: arqout$, "Filename", tab$, "point-label-1", tab$, "point-label-2",tab$, "interval-label", tab$, "prag-label",newline$

##################################	BUCLE	#####################################


# loop to be closed at the end of script
# Create list of files 
Create Strings as file list... list 'folder$'/*.wav
# loop that goes through all files
numberOfFiles = Get number of strings
for ifile to numberOfFiles
	select Strings list
	file$ = Get string... ifile
	base$ = file$ - ".wav"
	fil$ = folder$ + file$
	

	# read sound file
	Read from file... 'folder$'/'file$'
	base$ = selected$ ("Sound")

	# read texgrid
	filegrid$ = base$ + ".TextGrid"
	Read from file... 'folder$'/'filegrid$'

	
		############################# 		LABELS 		#############################
	
		select TextGrid 'base$'
		numberOfPoints = Get number of points: point_tier
		
			
		for i from 1 to numberOfPoints
			for i to numberOfPoints
			etiquetapunto$ = Get label of point: point_tier, 1
			point_time = Get time of point: point_tier, 1
			
			etiquetapunto2$ = Get label of point: point_tier, i
			point_time2 = Get time of point: point_tier, i
			endfor
			
			interval = Get interval at time: tier_interval, point_time
			etiquetaintervalo$ = Get label of interval: tier_interval, interval
			
			prag = Get interval at time: tier_prag, point_time
			etiquetaprag$ = Get label of interval: tier_prag, prag
			appendFile: arqout$, base$, tab$, etiquetapunto$,  tab$, etiquetapunto2$, tab$, etiquetaintervalo$, tab$, etiquetaprag$, newline$
			
		endfor
		
	
	
	select all
	minus Strings list
	Remove

	
#end of loop
endfor

#clean and delete Strings list
select all
Remove
echo File has been created in the selected folder!