############################################################################################################################################################################################
# 
# create_pictures-with-tiers.praat (2.2)
# Laboratori de Fonètica (Universitat de Barcelona)
# 
#						DESCRIPTION
#	This script creates and saves pictures (PDF, wmf, eps, PraatPic) of all the sound files it finds in a folder.
#	The pictures contain a waveform, a spectrogram, an optional F0 track and a the content of the tiers of the TextGrid associated with the sound file. 
# 
#	The script is deisgned to carry out some operations automatically:
#	1) It detects automatically the F0 range of the picture of EACH sentence (unless you choose to specify it manually). 
#	2) It recognizes automatically the number of tiers in EACH texgrid and draws the picture consequently (i.e. in the picture there will be 
#	no unnecessary white space between the tiers and the spectrogram).
#	3) It establishes automatically the number of marks on the y axis and their placement. It places the first mark at the lowest multiple of 50 Hz within the range 
#	of the picture (e.g. at 50 Hz, or 100 Hz, or 150 Hz...). The following marks are placed every 50/100/150 Hz (depending on the range of the utterance).  
#	In the INSTRUCTIONS section you will find details about the other characteristics and options of the script (e.g changing the dynamic range, 
#	choosing the level of smooth in the F0 track, changing the axis' names, choosing the speakers range of F0...)
# 	 
#	
# 
#						INSTRUCTIONS
#	0. Before you start: Create the TextGrids with the same name of the sound they are made for. Save them in a folder. 
#
#	1. Open the script (Open/Read from file...), click Run in the upper menu and Run again. 
#	2. Set the parameters.
#		a) The 3 first fields are for the folders where you have your files. In the first field, write the name of the folder where you have your sound files.
#			In the second field, write the name of the folder where you have your Textgrids. In the third field, write the name of the folder where 
#			you want the pictures to be saved. Important: always write the path without bar at the end "/".
#		b) By changing the dynamic range you can make your spectrograms look 'cleaner'. The lowest it is, the lighter the spectogram looks.
#		c) Choose whether you want to draw the F0 curve or not. The F0 curve will be written twice, once in white and once in thinner black (Welby 2003).
#		d) Then specify if you want the F0 range to be defined automatically or manually. If you choose to set it manually, 
#		in the next window you'll be asked to define the F0 minimum and F0 maximum.
#		e) Choose if you want the F0 minimum and F0 maximum marks to appear on the y axis (if you place them, they might overlap with other marks).
#		Note that the F0 minimum and F0 maximum marks are placed at 'rounded' values, that means that 377.8 Hz is rounded to 380 Hz and 51.2 Hz is rounded to 50 Hz.
#		f) Decide how much you want the F0 curve to be smoothed. In this field, you need to enter the bandwidth (in Hertz). If you want a 
#		very smoothed curve, you should choose a smaller bandwidth (e.g. 10), whereas if you want a less smoothed curve you should choose a bigger bandwidth (e.g. 50).
#		Don't write 0 in here, because your curve would become plain.
#		g)In the next two choice menus, you can choose the label of the axes (in different languages). You can also decide not to label either or both of them.
#		h) You can change the picture width.
#		i)Mark the formats in which you want to save the pictures. Notice that PDF will only run if you are working on a Mac and wmf is only for Windows.
#		j)Mark whether you want more options or not. (See below for details)
#		Click OK
#
#		MORE OPTIONS WINDOW
#		If you chose the more options button or if you chose to set the speaker's range manually, a new window will appear. In this window you can:
#		a) Set the F0 range in the picture. You must write the numbers separated by a hyphen. This field will only appear if you chose "Set the range manually" 
#		in the previous form.
#  		b) Choose the spectrogram range. This is by default from 0 to 5000Hz.
#		c) If you have chosen not to draw the F0 curve, you can select here how many marks of frequency you want in the spectrogram. 
#		You'll be asked every how many Hz you want a mark.
#		d) Change the time marks of the x axis. By default, there is a mark without number at every 0.2 seconds and a mark with number at every 0.5 (the number appears 
#		written above the mark.)
#		e) If you are drawing the f0 curve and you've chosen "Show more options", you can choose here how do you want Praat to select the better candidates to be F0. 
#			The script runs with the autocorrelation method (Boersma, 1993) which is optimized for human intonation research, so if you are working with speech, 
#			you don't need to change anything.
#			Here you'll be asked for the octave cost, octave jump cost, the voiced/unvoiced cost and the voicing_threshold.
#
#
#
#		Click OK (the Revert button goes back to the Standards of the form)
#	
#	3. Now search your pictures, they have to be in the folder you specified in the first form.
#
#
#
#						CREDITS
# Feedback is always welcome, please if you notice any bugs or come up with anything that can improve this script, let me know!
# 	
# Wendy Elvira-García
# wendyelviragarcia@gmail.com
# october 2013
# Praat 5.3.46
# Citation: Elvira García, Wendy & Roseano, Paolo (2013). Create pictures with tiers 2.0. Praat script. (Retrieved from http://stel.ub.edu/labfon/en)
#
# This script is based on:
# draw-waveform-sgram-f0.praat
# Pauline Welby (2003)
# with the modifications made by Paolo Roseano (2011)
# 
#
###################################################################################################################################
#opciones por defecto

spectrogram_maximum_frequency = 5000

#variables para el tiempo cada (ms)
    time_mark_with_number = 0.5
    time_mark_without_number = 0.1
	 
# variables de puntos susceptibles de ser F0
	voicing_threshold = 0.45
	octave_cost = 0.01
	octave_jump_cost = 0.35
	voiced_unvoiced_cost = 0.14


############################		FORMULARIO		###################################################################
baseDir$ = chooseDirectory$ ("Choose folder containing files for images:")
beginPause: "Input directory name without final slash"
    comment: "Enter directory where sound files  are kept:"
    sentence: "Sounds_folder", "'baseDir$'"
    comment: "Enter directory where TextGrid files are kept:"
    sentence: "TextGrids_folder", "'baseDir$'"
    comment: "Enter directory to which created images should be saved:"
  	sentence: "Pictures_folder" , "'baseDir$'/images"
clicked = endPause: "Continue", 1


form Create_pictures
    # comment Where are your files?
    # sentence Sounds_folder /Users/catalinat/Documents/GitHub/MyWriting/Perception_experiment/figures/Sound
    # sentence TextGrids_folder /Users/catalinat/Documents/GitHub/MyWriting/Perception_experiment/figures/Sound
    # sentence Pictures_folder /Users/catalinat/Documents/GitHub/MyWriting/Perception_experiment/figures/Sound
	boolean Draw_spectrogram 1
    positive Dynamic_range 45
    boolean Draw_F0_curve yes
    optionmenu Range 2
	option Define range automatically
	option Define range manually
    comment Do you want the f0min and f0max values to appear in the y axis?
    boolean f0min_f0max_marks 1
    positive Smooth 6
    
   
    optionmenu Label_of_the_time_axis 4
		option No text
		option Tiempo (s)
		option Temps (s)
		option Time (s)
		option Tempo (s)
		option Zeit (s)
		option Denbora (s)
		option (s)
   
    optionmenu Label_of_the_frequency_axis 2
		option No text
		option F0 (Hz)
		option Frequency (Hz)
		option Frecuencia (Hz)
		option Freqüència (Hz)
		option Frequência (Hz)
		option Frequenza (Hz)
		option Frequenz (Hz)
		option Maiztasuna (Hz)
		option Fréquence (Hz)
		option (Hz)
   
    positive Picture_width 10
    
    comment In which format(s) do you want the picture?
    boolean PDF_(Mac_only) 1
    boolean Windows_Media_File_(.wmf_(Windows_only)) 0
    boolean EPS_(Best_quality!) 0
    boolean praatPic 0
    comment You can change more parametres:
    boolean Show_more_options 1
endform



#################		FORMULARIO OPCIONES		################################################################

if show_more_options = 1 or range = 2 or draw_F0_curve = 0
	beginPause ("Options")
		if range = 2 and draw_F0_curve = 1
			comment ("Introduce manually the range of the speaker.")
			sentence ("Manual_range", "50-400")
		endif

		if draw_spectrogram = 1 and show_more_options = 1 and draw_F0_curve = 1
			comment ("Spectrogram settings")
    			positive ("Spectrogram_maximum_frequency", 5000)
		endif

		if draw_F0_curve = 0 and draw_spectrogram = 1
			comment ("Spectrogram settings")
    			positive ("Spectrogram_maximum_frequency", 8000)
			comment ("¿Every how many Hertzs do you want a frequency mark?")
    			positive ("Frequency_marks_every", 2000)
			
		endif

		if show_more_options = 1
			comment ("¿Every how many seconds do you want a time mark in the waveform?")
			positive ("time_mark_without_number at every (seconds)", 0.1)
 			positive ("time_mark_with_number at every (seconds)", 0.5 )
		endif

		if draw_F0_curve = 1 and show_more_options = 1
			comment ("Find the F0 path")
			positive ("voicing_threshold", 0.45)
			positive ("octave_cost", 0.01)
			positive ("octave_jump_cost", 0.35) 
			positive ("voiced_unvoiced_cost", 0.14)
		endif
   	
	endPause ("OK", 1)
endif



#######################################################################################################
#variables de range
if range = 2
	f0max =  extractNumber (manual_range$, "-")
	f0max$ = "'f0max'"
	f0min$ = "'manual_range$'" - "'f0max$'" 
	f0min$= "'f0min$'" - "-"
	f0min = 'f0min$'
endif

#################		EMPIEZA EL SCRIPT		#########################################################

if praatVersion < 5340
	exit Your Praat version is too old. Download the new one.
endif

Create Strings as file list... list 'sounds_folder$'/*.wav
numberOfFiles = Get number of strings

#empieza el bucle
for ifile to numberOfFiles
	select Strings list
	fileName$ = Get string... ifile
	base$ = fileName$ - ".wav"

	# Lee el Sonido y el TextGrid
	Read from file... 'textGrids_folder$'/'base$'.TextGrid
	Read from file... 'sounds_folder$'/'base$'.wav

	# Crea objeto Spectrogram 
	if draw_spectrogram = 1
		select Sound 'base$'
		To Spectrogram... 0.005 'spectrogram_maximum_frequency' 0.002 20 Gaussian
	endif
	# Dibuja el oscilograma, espectrograma el pitch, el TextGrid y una caja alrededor de todo ello.


	# Fuente de texto y color
	Times
	Font size... 14
	Line width... 1
	Black

	# Hace la ventana rosa para el oscilograma
      	Viewport... 0 'picture_width' 0 2
	# Dibuja el oscilograma
	select Sound 'base$'
	Draw... 0 0 0 0 no curve
 
	if draw_spectrogram = 1
		# Crea la ventana de imagen para el espectrograma
		Viewport... 0 'picture_width' 1 4
		# Dibuja el espectrograma
		select Spectrogram 'base$'
		Paint... 0 0 0 0 100 yes dynamic_range 6 0 no
	endif

	if draw_F0_curve = 1
		if range = 1
			# Crea objeto pitch con unos valores estándar muy grandes para que quepa todo
			select Sound 'base$'
			To Pitch (ac)... 0.005 50 15 no 0.03 'voicing_threshold' 'octave_cost' 'octave_jump_cost' 'voiced_unvoiced_cost' 650
			Smooth... smooth
			f0min = Get minimum... 0 0 Hertz Parabolic
			f0max = Get maximum... 0 0 Hertz Parabolic
			f0min = f0min - 50
			f0max = f0max + 50
			Rename... pitch_viejo
			select Sound 'base$'
			To Pitch... 0.005 'f0min' 'f0max'
			Smooth... smooth
		endif

		if range = 2 
			# Crea objeto pitch
			select Sound 'base$'
			To Pitch (ac)... 0.005 'f0min' 15 no 0.03 'voicing_threshold' 'octave_cost' 'octave_jump_cost' 'voiced_unvoiced_cost' 'f0max'
			Smooth... smooth
		endif

		# Dibuja el pitch
		# Linea blanca de debajo
		Line width... 10
		White
		Viewport... 0 'picture_width' 1 4
		select Pitch 'base$'
		Draw... 0 0 'f0min' 'f0max' no

		# Como una linea negra
		Line width... 6
		Black
		Draw... 0 0 'f0min' 'f0max' no
	
		# #Dibuja las s de F0. Eje y
		Line width... 1

		# Pone las marcas de f0 máxima y mínima si así se ha indicado en el formulario
		if f0min_f0max_marks = 1
			f0min$ = fixed$(f0min, 0)
			f0max$= fixed$(f0max, 0)
			f0min_redondeado = number (f0min$)
			f0max_redondeado = number (f0max$)
			f0max_redondeado = f0max_redondeado/10
			f0min_redondeado = f0min_redondeado/10
			f0max_redondeado$ = fixed$(f0max_redondeado, 0)
			f0max_redondeado = number (f0max_redondeado$)
			f0min_redondeado$ = fixed$(f0min_redondeado, 0)
			f0min_redondeado = number (f0min_redondeado$)
			f0min_redondeado = f0min_redondeado * 10
			f0max_redondeado = f0max_redondeado * 10
			One mark left... f0min_redondeado yes no no
			One mark left... f0max_redondeado yes no no

			#One mark left... 'f0max' yes no no
			#One mark left... 'f0min' yes no no
		endif
		
		
		# Determina cada cuánto (50, 100 o 150Hz) tiene que haber marcas según lo grande que sea el range del hablante
		speakers_range = f0max - f0min


		if speakers_range >= 500
			intervalo_entre_marcas = 150
		elsif speakers_range >= 300
			intervalo_entre_marcas = 100
		elsif speakers_range < 300
			intervalo_entre_marcas = 50
		endif

		numero_de_marcasf0 = (speakers_range/intervalo_entre_marcas)+ 1
	
		# Determina cuál será la primera marca que aparezca en el espectrograma según cuál sea el f0 min que se ha indicado
		
		if f0min >= 250
			marca = 250
		elsif f0min >= 200
			marca = 200
		elsif f0min >= 150
			marca = 150
		elsif f0min >= 100
			marca = 100
		elsif f0min >= 50
			marca = 50
		elsif f0min < 50
			marca = 0
		endif
	
		# Pone las marcas de F0 en Hz según los parámetros anteriores.
		for i to numero_de_marcasf0
			marca = marca + intervalo_entre_marcas
			marca$ = "'marca'"
			if marca <= f0max
				do ("One mark left...", 'marca', "yes", "yes", "no", "'marca$'")
			endif
		endfor

		
		#Dibuja la caja
		Draw inner box
		Draw... 0 0 'f0min' 'f0max' no
		
		#Determina el texto que aparecerá como título del eje y
		if label_of_the_frequency_axis <> 1
			if label_of_the_frequency_axis = 2
				label_of_the_frequency_axis$ = "F0 (Hz)"
			endif
			if label_of_the_frequency_axis = 3
				label_of_the_frequency_axis$ = "Frequency (Hz)"
			elsif label_of_the_frequency_axis = 4
				label_of_the_frequency_axis$ = "Frecuencia (Hz)"
			elsif label_of_the_frequency_axis = 5
				label_of_the_frequency_axis$ = "Freqüència (Hz)"
			elsif label_of_the_frequency_axis = 6
				label_of_the_frequency_axis$ = "Frequência (Hz)"
			elsif label_of_the_frequency_axis = 7
				label_of_the_frequency_axis$ = "Frequenz (Hz)"
			elsif label_of_the_frequency_axis = 8
				label_of_the_frequency_axis$ = "Maiztasuna (Hz)"
			elsif label_of_the_frequency_axis = 9
				label_of_the_frequency_axis$ = "Fréquence (Hz)"
			elsif label_of_the_frequency_axis = 10
				label_of_the_frequency_axis$ = "(Hz)"
			endif
			#escribe el título del eje y
			Text left... yes 'label_of_the_frequency_axis$'
		endif 
	endif


	#si no se va a poner el F0 que salgan las marcas de valor frecuencial del espectrograma
	if draw_F0_curve = 0
		do ("Marks left every...", 1, frequency_marks_every, "yes", "yes", "no")


	
		if label_of_the_frequency_axis <> 1	
			if label_of_the_frequency_axis = 2
				label_of_the_frequency_axis$ = "Hz"
			elsif label_of_the_frequency_axis = 3
				label_of_the_frequency_axis$ = "Frequency (Hz)"
			elsif label_of_the_frequency_axis = 4
				label_of_the_frequency_axis$ = "Frecuencia (Hz)"
			elsif label_of_the_frequency_axis = 5
				label_of_the_frequency_axis$ = "Freqüència (Hz)"
			elsif label_of_the_frequency_axis = 6
				label_of_the_frequency_axis$ = "Frequência (Hz)"
			elsif label_of_the_frequency_axis = 7
				label_of_the_frequency_axis$ = "Frequenz (Hz)"
			elsif label_of_the_frequency_axis = 8
				label_of_the_frequency_axis$ = "Maiztasuna (Hz)"
			elsif label_of_the_frequency_axis = 9
				label_of_the_frequency_axis$ = "Fréquence (Hz)"
			elsif label_of_the_frequency_axis = 10
				label_of_the_frequency_axis$ = "(Hz)"
			endif
		#escribe el texto del eje y, si no hay curva de f0
		Text left... yes 'label_of_the_frequency_axis$'
		endif
	endif






#######################		DIBUJA EL TEXTGRID		####################################

	#Busca cuantos tiers hay en el texgrid
	select TextGrid 'base$'
	numberOfTiers = Get number of tiers

	# Define el tamaño de la caja para textgrid según el número de tiers que se ha indicado
	cajatextgrid = (4 + 0.5 * 'numberOfTiers') - 0.02 * 'numberOfTiers'
	

	# Ventana rosa para los texgrid
	Viewport... 0 'picture_width' 1 'cajatextgrid'
	

	# Dibuja el TextGrid
	select TextGrid 'base$'
	Draw... 0 0 yes yes no

	# Crea ventana para línea exterior
	Viewport... 0 'picture_width' 0 'cajatextgrid'
	# Dibuja la línea exterior
	Black
	Draw inner box


		# Label x axis
	if label_of_the_time_axis <> 1
		if label_of_the_time_axis = 2
			label_of_the_time_axis$ = "Tiempo (s)"
		elsif label_of_the_time_axis = 3
			label_of_the_time_axis$ = "Temps (s)"
		elsif label_of_the_time_axis = 4
			label_of_the_time_axis$ = "Time (s)"
		elsif label_of_the_time_axis = 5
			label_of_the_time_axis$ = "Tempo (s)"
		elsif label_of_the_time_axis = 6
			label_of_the_time_axis$ = "Zeit (s)"
		elsif label_of_the_time_axis = 7
			label_of_the_time_axis$ = "Denbora (s)"
		elsif label_of_the_time_axis = 8
			label_of_the_time_axis$ = "(s)"
		endif
		#escribe el título del eje x (de tiempo)
		Text bottom... no 'label_of_the_time_axis$'
	endif

	#Pone las marcas del eje de tiempo
	Marks bottom every... 1 'time_mark_without_number' no yes no
	Marks bottom every... 1 'time_mark_with_number' yes yes no

  #############################		GUARDA LA IMAGEN	##############################
  	if pDF = 1
  		Save as PDF file... 'pictures_folder$'/'base$'.pdf
	endif

	if windows_Media_File = 1
		Write to Windows metafile... 'pictures_folder$'/'base$'.wmf
	endif

	if ePS = 1
		Write to EPS file... 'pictures_folder$'/'base$'.eps
	endif

	if praatPic = 1
		Write to praat picture file... 'pictures_folder$'/'base$'.praapic
	endif

	# borra la caja de picture si no dibujaría encima
	Erase all

#	# Limpia objetos
#	select all
#	minus Strings list
#	Remove
   
	
endfor

################################################################
#	ACCIONES FINALES
################################################################

# Limpieza final
#select Strings list
#Remove

#echo Se han creado imágenes para 'ifile' sonidos.

