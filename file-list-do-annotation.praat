 #	visor-corrector-de-TextGrids (v. 1.1 - febrero 2014)
#
#							DESCRIPCIÓN
#	Este script abre uno a uno todos los ficheros .wav de una carpeta acompañados de su 
#	respectivo TextGrid en el editor de Praat para permitir su corrección, guarda el TextGrid
#	y abre el siguiente fichero.
#
#
#							INSTRUCCIONES
#
#	0. Para usar este script necesitas una serie de ficheros .wav y sus respectivos TextGrid.
#	1. Abre el script con Praat (Read from file...) y selecciona el script o simplemente arrastra el fichero al icono de Praat.
#	2. Se abrirá una ventana donde se pregunta donde están tus archivos, selecciona la carpeta y clica "OK"
#	3. Se abrirá un formulario donde puedes elegir si quieres empezar a trabajar con el archivo 1 de la lista 
#		o si, por el contrario, ya habías trabajado con esos archivos antes y sabes el número por el que te quedaste.
#		Clica OK.
#	4. Se abrirán el sonido y el TextGrid juntos. Corrige lo que sea necesario y cuando acabes clica "Continue".
#	5. El TextGrid se guardará en la misma carpeta donde estaba (¡esto significa que se sobreescribirá!)
#		y se abrirá el archivo siguiente de la lista.
#
#	Wendy Elvira-García (2013). Visor-corrector de TextGrids. [praat script]
#	wendyelviragarcia@gmail.com
#	Laboratori de Fonètica (Universitat de Barcelona)
#
###########################################################################################

#seleccionador de carpeta (sólo crea una variable)
#comenta esta linea (pon una almohadilla) y descomenta las 4 lineas del siguiente bloque, si quieres poner la ruta escrita, sin el selector.
folder$ = chooseDirectory$ ("Elige la carpeta cuyos archivos quieres ver/modificar:")

# form
# comment Pon la ruta de la carpeta donde están los archivos:
# word Folder Users/usuario/carpeta
# endform


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