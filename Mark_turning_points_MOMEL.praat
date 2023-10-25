# This program is the PRAAT Script of the MOMEL (Hirst & Espesser) Algorithm
# It can be run under PC, UNIX and also MAC and LINUX machines
# It can be used with the PRAAT Program, or even from prompt
# The input is a sound file or a PRAAT generated pitch file with the following arguments

#	16/04/2000 Upgraded Version
#	25/05/2004 replaced 'copy' by '=' & lower-case names
#       2/08/2004  Bert Remijsen - I added the option to get the turning points in a PitchTier
#                  and in a TextGrid (see last choice in form; in script all changes are 
#                  highlighted by '#BR#').

#	File		Input sound file or pitch if run under PRAAT
#	Delta		percentage of accepted error between MOMEL and initial curves
#	A		Size of generating targets
#	R		Size of discriminating targets
#	hzmin		Minimum accepted frequency
#	hzmax		Maximum accepted frequency
#	Draw mode	Yes / No				(Draw curves : only available under PRAAT)
#	Debug mode	Yes / No				(Generate temp file to check)
#	Stylzation	Linear / Spline
#	Version		MOMEL / New
# ----------------
# CT added loop so that the script goes through a folder with recordings and saves 
# the new Texgrids files

#	First part : Pre-processing of F0
#	pref.c

#	Initialize Text Window
clearinfo

#	Loading parameters through a window if under PRAAT, else by prompt command line
#	praat momel.script file.wav 5 30 20 80 500 Yes Yes (which are default values)
form Parameters
	comment Enter parent directory where files are kept:
	word inputdir /Users/catalina/Desktop/TEST-MOMEL
#	comment Filename (with extension):
#	word File ALSA_Fr_PDV1-35_88.wav
	positive Delta 5
	positive A 30
	positive R 20
	positive Hzmin 80
	positive Hzmax 500
	choice draw_mode: 1
		button Yes
		button No
	choice debug_mode: 2
		button Yes
		button No
	choice stylization_: 2
		button Linear
		button Spline
	choice version_: 1
		button Momel
		button new
	choice output_as_PitchTier_and_TextGrid: 1
		button Yes
		button No
endform


# specify files to be worked on
Create Strings as file list... list 'inputdir$'/*.wav


# loop that goes through all files
numberOfFiles = Get number of strings
for ifile to numberOfFiles
   select Strings list
   fileName$ = Get string... ifile
   file$ = fileName$ - ".wav"
 
	# Test if loop is working
	print 'file$' 'tab$' "in the loop" 'newline$'

	# Read in the sound files with that base name
	Read from file... 'inputdir$'/'file$'.wav
	
	
	# start original MOMEL
	# 	Generate the pitch file whatever the input

	# BR
	Erase all
	# /BR
	nfile = 1
	for i from 1 to nfile
		if file$ <> "Sound" and file$ <> "sound"
			if file$ <> "Pitch" and file$ <> "pitch"

	# /BR
			To Pitch... 0.01 75 600
			print Read pitch from sound 'file$'
			printline
		endif
	else
		To Pitch... 0.01 75 600
		print Read pitch from Selected Sound
		printline
	endif

	name3$ = selected$("Pitch")
	# Create the temp output files if in debug mode
	if debug_mode = 1
		output$ =  name3$+".cibles"
		filedelete 'output$'

		out$ = name3$+".pref"
		filedelete 'out$'

		out_f0$ = name3$+".f0"
		filedelete 'out_f0$'
	endif

	#	Create the MOMEL file whatever the mode

	# BR added inputdir
	output_momel$ = inputdir$+"\"+name3$+".momel"
	# /BR
	filedelete 'output_momel'

	#	Generate no - Octave Jump Pitch / Remove previous Pitch
	name3 = selected("Pitch")
	select 'name3'
	Kill octave jumps
	name1 = selected("Pitch")
	select 'name3'
	Remove
	select 'name1'

	#	Read Pitch to hz
	duration = Get duration
	duration = floor(duration * 100)
	for i from 1 to duration
		value = Get value at time... (i/100) Hertz Nearest
		if value <> undefined
			hz'i' = value
		else
			hz'i' = 0
		endif
	endfor

	if debug_mode = 1
		#	Save the initial f0 curve
		for i from 1 to duration
			value = hz'i'
			fileappend  'out_f0$' 'value' 'newline$'
		endfor
	endif

	#	Initializing variables
	cfiltre = 1 + 'Delta' / 100
	seuilv = 'Hzmin'
	nval = duration
	lfen = 'A'
	lfens2 = lfen / 2
	maxec = cfiltre
	if version_ = 1
		interval = lfen
	else
		interval = lfens2
	endif

	#	Pre-processing itself
	for i from 1 to (nval - 1)
		h = i - 1
		j = i + 1
		if (hz'i' < seuilv)
			hz'i' = 0
		elsif ((hz'i' / (hz'h' + 1) > cfiltre) and (hz'i' / (hz'j' + 1) > cfiltre))
			# Quite never reached with praat F0 values
		 	 	   hz'i' = 0
			endif
		endif
	endfor

	# hz is now the correct matrix

	if debug_mode = 1
		# Outputs values in output.pref
		for i to (nval)
			value = hz'i'
			fileappend  'out$' 'value' 'newline$'
		endfor
	endif

	# end of PREF.C

	# Here comes CIBLE.H / up is used to specify CAPITAL

		# step in ms
		up_pas = 10

		# 70 s  with a step of 10 ms
		up_nvalm = 7000

		# voicing threshold in Hz
		up_seuilv = 50

	# 	Formatting hz array to hznew
	for i from 1 to (nval + lfen)
		hz_new'i' = 0
	endfor
	for i from 1 to nval
		k = i + lfens2
		hz_new'k' = hz'i'
	endfor

	#	 Begining of CIBLE.C

	# 	Initializing polynom values
	pa1 = 0
	pa2 = 0
	pa3 = 0

	# Create the POND array
	for ix from 1 to (nval + lfen)
		if hz_new'ix' > up_seuilv
			pond'ix' = 1
		else
			# RG add
			pond'ix' = 0
		endif
	endfor

	compteur = 0

	for ix from (1+lfens2) to (nval+lfens2)
		# Start and End window
		dpx = ix - lfens2
		fpx = dpx + lfen
		nsup = 0
		nsupr = -1

		for i from dpx to fpx
			pondloc'i' = pond'i'
		endfor
		error = 0
		while (nsup > nsupr) and (error = 0)
			nsupr = nsup
		    	nsup = 0
			call calcrgp
		    	if error = 0
			# function BREAK doesn't seem to exist in the Praat language --> to fix
			# break
				for x from dpx to fpx
					if (hz_new'x' = 0) or ( (hzes'x'/ hz_new'x') > maxec)
						pondloc'x' = 0
						nsup = nsup + 1
					endif
				endfor
			endif
		 endwhile

		 # End of block
		xc = 0
		yc = 0

		if ( error = 0 ) and ( pa2 <> 0 )
			# Everything is alright
			 vxc = -pa1 / (2 * pa2)

			# Has to check the code : lfen or lfens2

			 if (vxc > ix - interval) and (vxc < ix + interval)
				vyc = pa0 + (pa1 + pa2 * vxc) * vxc
				if (vyc > hzmin)  and (vyc < hzmax)
		    			xc = vxc
					yc = vyc
				endif
			endif
		endif
		compteur = compteur + 1
		# Preparing CIB ARRAY
		if xc <> 0
			xc = xc - lfens2 - 1
		endif
		cib_x'compteur' = xc
		cib_y'compteur' = yc
		if debug_mode = 1
			fileappend  'output$' 'xc' 'yc' 'newline$'
		endif
	endfor

	procedure  calcrgp
	# Value returned by error    0 : OK (default)       1 : Problem
		pn = 0
		sx = 0
		sx2 = 0
		sx3 = 0
		sx4 = 0
		sy = 0
		sxy = 0
		sx2y = 0

		error = 0

		for k from dpx to fpx
			p = pondloc'k'
			if p <> 0
				val_ix = k
				y = hz_new'k'
				x2 = val_ix * val_ix
				x3 = x2 * val_ix
				x4 = x2 * x2
				xy = val_ix * y
				x2y = x2 * y

				pn = pn + p
				sx = sx + (p * val_ix)
				sx2 = sx2 + (p * x2)
				sx3 = sx3 + (p * x3)
				sx4 = sx4 + (p * x4)
				sy = sy + (p * y)
				sxy = sxy + (p * xy)
				sx2y = sx2y + (p * x2y)
			endif
		endfor
	##########################################################
		# 	The pn value is taken arbitrary !!!

	###	if pn < 3
		if pn = 0
			error = 1
			print Error type 1 pn=0
			printline
		endif

		if error = 0
			spdxy = sxy - ( (sx * sy) / pn )
			spdx2 = sx2 - ( (sx * sx) / pn )
			spdx3 = sx3 - ( (sx * sx2) / pn )
			spdx4 = sx4 - ( (sx2 * sx2) / pn )
			spdx2y = sx2y - ( (sx2 * sy) / pn )

			muet = spdx2 * spdx4 - spdx3 * spdx3
	##		if (spdx2 = 0) or (muet = 0)
			if spdx2 = 0
				error = 1
				print Error type 2 spdx2=0
				printline
			endif
	#################
			if muet = 0
				error = 1
				print Error type 2 muet=0
	                        printline
	                endif
	#################		

			if error = 0
				pa2 = (spdx2y * spdx2 - spdxy * spdx3) / muet
				pa1 = (spdxy - pa2 * spdx3) / spdx2
				pa0 = (sy - pa1 * sx - pa2 * sx2) / pn

				for m from dpx to fpx
					hzes'm' = pa0 + (pa1 + pa2 * m) * m
				endfor
			endif
		endif
	endproc

	# End of CIBLE.C

	# Just added to check cibles
	for i from 1 to compteur
		x = cib_x'i'
		cib_x_save'i' = x
		y = cib_y'i'
		cib_y_save'i' = y
	endfor
	compteur_save = compteur
	# End of add

	#	REDUC.C

	#	Initializing values

	up_seuilv = seuilv
	up_parmax = 1000
	faux = 0
	vrai = 1
	up_fsigma = 1

	lfen = 'R'
	lf = lfen / 2
	xds = 0
	yds = 0
	np = 0

	for i from 1 to nval
		j1 = 1
		if i > lf
			j1 = i - lf
		endif
		j2 = nval
		if (i + lf) < nval
			j2 = i + lf
		endif

		# Left side
		sxg = 0
		syg = 0
		ng = 0
		for j from j1 to i
			if cib_y'j' > up_seuilv
				sxg = sxg + cib_x'j'
				syg = syg + cib_y'j'
				ng = ng + 1
		 	endif
		endfor

		# Right side
		sxd = 0
		syd = 0
		nd = 0

		for j from (i + 1) to j2
			if cib_y'j' > up_seuilv
				sxd = sxd + cib_x'j'
				syd = syd + cib_y'j'
				nd = nd + 1
			endif
		endfor

		#	If cible on both left and right sides
		xdist'i' = -1
		ydist'i' = -1
		if (nd * ng > 0)
			xdist'i' = abs (sxg / ng - sxd / nd)
			ydist'i' = abs (syg / ng - syd / nd)
			xds = xds + xdist'i'
			yds = yds + ydist'i'
			np = np + 1
		endif
	endfor

	# Ponderation byr 1/ mean distance
	px = np / xds
	py = np / yds

	for i from 1 to nval
		dist'i' = -1
		if (xdist'i' > 0)
			#	Code has changed !!!
			#	 ... / (px + py) has been removed because useless
			dist'i' = xdist'i' * px + ydist'i' * py
		endif
	endfor

	# seuil = moy des dist ponderees
	#	Code has changed !!!
	#	... / (px + py) has been removed because useless
	seuil = 2

	#	Initializing values
	j = 0
	xd'j' = 0
	ncible = 0
	susseuil = faux

	# Look for maxima of rises
	for i from 1 to nval
		if susseuil = faux
			if dist'i' > seuil
				susseuil = vrai
				xmax = i
			endif
		endif
		if susseuil = vrai
			if dist'i' > dist'xmax'
				xmax = i
			endif
			if dist'i' < seuil
		 		ncible = ncible + 1
				xd'ncible' = xmax
				susseuil = faux
			endif
		endif
	endfor

	# Last end "cible" (Target)
	if susseuil = vrai
		ncible = ncible + 1
		xd'ncible' = xmax
	endif

	if xmax < (nval +1)
		ncible = ncible + 1
		xd'ncible' = nval
	endif

	#  ncibles is the number of partitions
	# from 0 to ncible beginnings of partition xd[i]

	for ip from 0 to (ncible-1)
		debut = xd'ip'
		j = ip + 1
		fin = xd'j'
		if debug_mode = 1
			print Partition 'ip' 'debut'  'fin'
			printline
		endif
	endfor

	# partition on x

	# ncibr point on the previous reducted target

	ncibr = -1
	if debug_mode = 1
		print ncible 'ncible'
		printline
	endif

	for ip from 0 to (ncible-1)
		# 	Current partition
		parinf = 1+xd'ip'
		j = ip+1
		parsup = xd'j'

		if debug_mode = 1
			print Cible 'ip'       'parinf' to 'parsup'
			printline
		endif

		for k from 0 to 1
			sx = 0
			sx2 = 0
			sy = 0
			sy2 = 0
			n = 0

			for j from parinf to parsup
				if cib_y'j' > 0
			  		sx = sx + cib_x'j'
					sx2 = sx2 + cib_x'j' * cib_x'j'
					sy = sy + cib_y'j'
					sy2 = sy2 + cib_y'j' * cib_y'j'
					n = n +1
				endif
			endfor

			if n > 1
				# For the variance
				xm = sx / n
				ym = sy / n
				varx = (sx2 / n) - (xm * xm)
				vary = (sy2 / n) - (ym * ym)

				if varx <= 0
					# case where variance should be +epsilon
					varx = 0.1
				endif
				if vary <= 0
					vary = 0.1
				endif
				et2x = up_fsigma * sqrt (varx)
				et2y = up_fsigma * sqrt (vary)
				seuilbx = xm - et2x
				seuilhx = xm + et2x
				seuilby = ym - et2y
				seuilhy = ym + et2y

				for j from parinf to parsup
					# elimination 
					if (cib_y'j' > 0) and ( (cib_x'j' < seuilbx) or (cib_x'j' > seuilhx) or (cib_y'j' < seuilby) or (cib_y'j' > seuilhy) )
						cib_x'j' = 0
						cib_y'j' = 0
					endif
				endfor
			endif
		endfor

	# recalculate means
		sx = 0
		sy = 0
		n = 0
		for j from parinf to parsup
			if cib_y'j' > 0
				sx = sx + cib_x'j'
				sy = sy + cib_y'j'
				n = n + 1
		    	endif
		 endfor
		 if n > 0
			cibred_cour_x = sx / n
			cibred_cour_y = sy / n
			cibred_cour_p = n

			if ncibr < 0
				ncibr = ncibr + 1
				cibred_x'ncibr' = cibred_cour_x
				cibred_y'ncibr' = cibred_cour_y
				cibred_p'ncibr' = cibred_cour_p
		    
			#  If cibred[].x are not strictly bigger than the previous
			#  the less weighted value is deleted
	 
			else
				if cibred_cour_x > cibred_x'ncibr'
					# 1 cibred en +  car t croissant 
					ncibr = ncibr + 1
					cibred_x'ncibr' = cibred_cour_x
					cibred_y'ncibr' = cibred_cour_y
					cibred_p'ncibr' = cibred_cour_p

				else
		   			# t <= previous
		   			if cibred_cour_p > cibred_p'ncibr'
			  			# if current p  >, then erase the previous one
			 			cibred_x'ncibr' = cibred_cour_x
						cibred_y'ncibr' = cibred_cour_y
						cibred_p'ncibr' = cibred_cour_p
					endif
				endif
			endif
		endif 
	endfor

	#	Output to the screen

	mini = Get minimum... 0 0 Hertz Parabolic
	maxi = Get maximum... 0 0 Hertz Parabolic
	global_range = maxi - mini
	f0min = 10 * round( (mini - (global_range /10)) / 12) 
	f0max = 10 * round( (maxi + (global_range /10)) / 10)
	if draw_mode = 1
		#	First draw the f0 curve
		Line width... 1
		Black
		Draw... 0 0 f0min f0max yes
	endif

	#	Add the target points
	Green

	# BR#
	select Pitch 'name3$'
	dur2 = Get duration
	Create PitchTier... 'name3$' 0.0 dur2
	pitchtier = selected ("PitchTier")
	Create TextGrid... 0.0 dur2 'name3$' 'name3$'
	textgrid = selected ("TextGrid")
	#/BR#

	for cib from 0 to ncibr
		ft'cib' = 10 * cibred_x'cib'
		fh'cib' = cibred_y'cib'
		value_x = cibred_x'cib' / 100
		value_y = cibred_y'cib'
		if draw_mode = 1

	#BR taken out#		Text... value_x Centre value_y Half o

	#BR#
	radius = dur2 / 100
	Paint circle... Green value_x value_y 'radius'
	#/BR#

		endif

	#BR#
	select 'pitchtier'
	Add point... 'value_x' 'value_y'
	select 'textgrid'
	rndy = round('value_y')
	Insert point... 1 'value_x' 'rndy'
	#/BR#

	endfor

	#BR#
	if output_as_PitchTier_and_TextGrid = 1
	   select 'pitchtier'
	   Write to text file... 'inputdir$'\'name3$'_momel.PitchTier
	   select 'textgrid'
	   Write to text file... 'inputdir$'\'name3$'_momel.TextGrid
	endif
	#/BR#

	#	Then the quadratic regression SPLINE

	nval = ncibr + 1
	nvalm1 = ncibr

	pas = 10
	procedure conv ms
		out = ms/pas + 0.5
	endproc

	durms = 10000

	if stylization_ = 2
		# Inflection points
		for i from 0 to (nvalm1 - 1)
			j = i+1
			fk'i' = ( ft'i' + ft'j' ) /2
		endfor
		fk'nvalm1' = durms
		# conversion ms en pas
		for i from 0 to nvalm1
			call conv ft'i'
			t'i' = out
			call conv fk'i'
			k'i' = out
			h'i' = fh'i'
		endfor
		index = 0
		call quasp nvalm1

		procedure parv x up_h h up_t t k
			out_parv = up_h + ( (h-up_h) * (x-up_t)*(x-up_t) ) / ( (k-up_t)*(t-up_t) )
		endproc

		procedure quasp m
		for x from 0 to k0
			call parv x h0 h1 t0 t1 k0
			y = out_parv
			index = index +1
			tab'index' = y
		endfor
	 
		for i from 1 to (m-1)
			for x from x to t'i'
				j = i-1
				call parv x h'i' h'j' t'i' t'j' k'j'
				y = out_parv
				index = index +1
				tab'index' = y
			endfor

		  	for x from x to k'i'
				j = i+1
				call parv x h'i' h'j' t'i' t'j' k'i'
				y = out_parv
				index = index +1
				tab'index' = y
			endfor
		endfor

		for x from x to (k'm')
			j = m-1
			call parv x h'm' h'j' t'm' t'j' k'j'
			y = out_parv
			index = index +1
			tab'index' = y
		endfor
		endproc

	# addition of next line suggested by Paul Boersma as conveyed by Dominika Oliver.
	duration = index
	elsif stylization_ = 1

		# conversion ms en pas
		for i from 0 to nvalm1
			call conv ft'i'
			t'i' = out
			print Cibles 'i' 	'out'
			h'i' = fh'i'
			out = h'i'
			print 	'out'
			printline
		endfor
		t_new0 = 0
		h_new0 = h0
		temp = nvalm1 + 2
		t_new'temp' = duration + 1
		h_new'temp' = h'nvalm1'
		for i from 0 to nvalm1
			j = i+1
			t_new'j' = t'i'
			h_new'j' = h'i'
		endfor
		for i from 1 to duration
			k=0
			repeat
				k = k+1
			until t_new'k' > i
			index = k - 1
			c = (h_new'k' - h_new'index') / (t_new'k' - t_new'index')
			b = h_new'index' - c * t_new'index'
			tab'i' = c * i + b
		endfor
	endif


	#	Fill the MOMEL file
	Red

	x1 = 0.005
	y1 = tab1
	fileappend  'output_momel$' 'y1' 'newline$'
	for i from 2 to duration
		x2 = (i-0.5) /100
		y2 = tab'i'
		if draw_mode = 1
			if y1>f0min and y2 >f0min and y1<f0max and y2<f0max
				Draw line... x1 y1 x2 y2
			endif
		endif
		fileappend  'output_momel$' 'x2' 'y2' 'newline$'
		x1 = x2
		y1 = y2
	endfor


	# Just added to check cibles
	Black
	Line width... 2
	x1 = cib_x_save1 / 100
	y1 = cib_y_save1

	for i from 2 to compteur_save
		x2 = cib_x_save'i' /100
		y2 = cib_y_save'i'
		if x2 <> 0 and y2 <> 0
			if abs(x1 - x2) < 0.08
				if draw_mode = 1
					Draw line... x1 y1 x2 y2
					# Text... x2 Centre y2 Half o
				endif
			endif
				x1 = x2
				y1 = y2
		endif
		if debug_mode = 1
			print 'x1' 'y1'
			printline
		endif
	endfor
	# 	End of add

	#	Write the title
	if draw_mode = 1
		Black
		12
		if stylization_ = 1
			Text top... no F0 curve and its linear stylization
		elsif stylization_ = 2
			Text top... no F0 curve and its MOMEL stylization
		endif
	endif
	endfor
	do ("Save as text file...", "'inputdir$'/'file$'.TextGrid")
endfor
# 	Restore default option
Black
10
Line width... 1
