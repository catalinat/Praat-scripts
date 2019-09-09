#							DESCRIPCTION
#	This script opens a series of .wav files with their corresponding textgrids.
#	It allows to do modifications on a one by one basis and saves the new material in the existing folder. 
#
#
#							INSTRUCTIONS
#
#	0. To use this script you will need a series of .wav files and their corresponding textgrids.
#	1. Open the script and click on "Run"
#	2. A window will open. Navigate to the desired folder and click "choose".
#	3. A new window will open. Here you can decide if you wish to start with the first recording in the list, or a different one.
# 		Click "Ok" to continue. 
#	4. A sound file and the corresponding textgrid will open up. Do the necessary corrections and click "Continue".
#	5. The new created textgrid will be saved in the folder (the old version is overwritten).
#	6. The next file to be changed will open up and you can continue your work. 
#Uncovering the acoustic vowel space of a previously undescribed language 
#	Original Wendy Elvira-García (2013). Visor-corrector de TextGrids. [praat script]
#	wendyelviragarcia@gmail.com
#	Laboratori de Fonètica (Universitat de Barcelona)
#   Modified by Catalina Torres
#	catalinat@student.unimelb.edu.au 
#	Phonetics laboratory (The University of Melbourne)
###########################################################################################

#seleccionador de carpeta (sólo crea una variable)
#comenta esta linea (pon una almohadilla) y descomenta las 4 lineas del siguiente bloque, si quieres poner la ruta escrita, sin el selector.
folder$ = chooseDirectory$ ("Choose folder containing files to be modified:")



#Crea la lista de archivos de todos los wav de esa carpeta
Create Strings as file list... listawav 'folder$'/*.wav

#comenta este bloque (5 lineas) si no quieres que te de la opción de empezar por un archivo que no sea el 1.

beginPause ("Did you previously start annotating?")
	comment ("The file list (Strings listawav) is on Praat Objects.")
	comment ("With which file number do you wish to start working?")
	integer ("nfile", 1)
endPause ("OK", 1)


#selecciona la lista y extrae en una variable el numero de archivos que tiene
select Strings listawav
nstrings = Get number of strings

#empieza el bucle 
for i from nfile to nstrings
	select Strings listawav
	#Llevo el .wav que toca a objetos
	nombresonido$ = Get string... i
	Read from file... 'folder$'/'nombresonido$'

	#llevo el TextGrid de ese .wav a objetos
	base$ = nombresonido$ - ".wav"
	nombregrid$ = base$ + ".TextGrid"
	Read from file... 'folder$'/'nombregrid$'

	#Selecciono los sonidos y los veo
	select Sound 'base$'
	plus TextGrid 'base$'
	View & Edit
	
	#pauso el script para dejar interaccionar al investigador
	pause Annotate TextGrid 'base$' ('i' from 'nstrings') and click "Continue" the TextGrid will be saved automatically.
 

	#Guardo el TextGrid
	select TextGrid 'base$'
	Save as text file... 'folder$'/'nombregrid$'
	
	#limpio la lista de objetos y de paso cierro la ventana del editor
	select all
	minus Strings listawav
	Remove
endfor

#limpieza de objetos final
select all
Remove

exit You just finished your file list! Well done! 