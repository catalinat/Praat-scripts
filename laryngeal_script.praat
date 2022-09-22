form Aspiration analysis
	comment Directory of sound files
	text sound_directory /Volumes/GoogleDrive/My Drive/Laryngeals JIPA/
	sentence sound_file_extension .wav
  comment Directory of TextGrid files
   text textGrid_directory /Volumes/GoogleDrive/My Drive/Laryngeals JIPA/
   sentence textGrid_file_extension .TextGrid
	comment Directory for resulting files
	text end_directory /Volumes/GoogleDrive/My Drive/Laryngeals JIPA/
	comment Language name
	text language_name
endform


##make a variable called "header_row$", then write that variable to the log file:

header_row$ = "Filename" + tab$ + "Sound label" + tab$ + "Laryngeal label" + tab$ + "Duration" + tab$ + "Laryngeal duration"  + tab$ + "Percent laryngeal" + tab$ + "Percent voiceless total" + tab$ + "Percent voiceless laryngeal" + tab$ + "Language" + newline$
header_row$ > 'end_directory$''language_name$'-log.txt

# Here, you make a listing of all the sound files in a directory.

strings= Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings

# Set up for-loop

for ifile to numberOfFiles
   select Strings list
	name$ = Get string... ifile
	# A sound file is opened from the listing:
	sound = Read from file... 'sound_directory$''name$'
	soundname$ = selected$ ("Sound", 1)

	# Open a TextGrid by the same name:
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"
		Read from file... 'gridfile$'
		textgrid = selected("TextGrid")
      

     number_of_intervals = Get number of intervals... 1
     for b from 1 to number_of_intervals
		
          interval_label$ = Get label of interval... 1 'b'
          if interval_label$ <> ""
               begin_vowel = Get starting point... 1 'b'
               end_vowel = Get end point... 1 'b'
               duration = (end_vowel - begin_vowel) * 1000
					
					##Extract sound clip for calculating total voiceless frames
	 					select Sound 'soundname$'
						Extract part... begin_vowel end_vowel rectangular 1.0 'no'
						extractname$ = selected$ ("Sound")
 						To Pitch (cc): 0, 50, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, 600
						select Sound 'extractname$'
						plus Pitch 'extractname$'
						pointproc=To PointProcess (cc)
						select Sound 'extractname$'
						plus Pitch 'extractname$'
						plus pointproc
						report$ = Voice report: 0, 0, 50, 600, 1.3, 1.6, 0.03, 0.45
						pctUnvoiced = extractNumber (report$, "Fraction of locally unvoiced frames: ")*100

						#cleanup
						select Sound 'extractname$'
						plus Pitch 'extractname$'
						plus pointproc
						Remove

					# get the asp interval number at the same time:
						select textgrid
						asp_interval = Get interval at time... 2 begin_vowel+0.000001
						
						begin_asp =  Get starting point... 2 asp_interval
						end_asp =  Get end point... 2 asp_interval	
						# get the label of that asp_interval:
    				 	asp_label$ = Get label of interval... 2 asp_interval
						if asp_label$ <> ""	
						duration_asp = (end_asp - begin_asp) * 1000
						percent_asp = (duration_asp/duration) * 100

					#change number below to be 1000/minimum pitch (ms)
						 	if duration_asp < 50
						    fileappend "'end_directory$''language_name$'-log.txt" 'name$''tab$''interval_label$''tab$''asp_label$''tab$''duration:2''tab$''duration_asp:2''tab$''percent_asp:2''tab$''pctUnvoiced''tab$'NaN'tab$''language_name$''newline$'
							else
					#Extract sound clip for calculating voiceless frames during aspiration
	 					select Sound 'soundname$'
						Extract part... begin_asp end_asp rectangular 1.0 'no'
						extractasp$ = selected$ ("Sound")
							To Pitch (cc): 0, 50, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, 600
							select Sound 'extractasp$'
							plus Pitch 'extractasp$'
							pointproc2 = To PointProcess (cc)
							select Sound 'extractasp$'
							plus Pitch 'extractasp$'
							plus pointproc2
							report_asp$ = Voice report: 0, 0, 50, 600, 1.3, 1.6, 0.03, 0.45
							pctUnvoicedAsp = extractNumber (report_asp$, "Fraction of locally unvoiced frames: ")*100
					

						  fileappend "'end_directory$''language_name$'-log.txt" 'name$''tab$''interval_label$''tab$''asp_label$''tab$''duration:3''tab$''duration_asp:3''tab$''percent_asp:2''tab$''pctUnvoiced:2''tab$''pctUnvoicedAsp:2''tab$''language_name$''newline$'
							
							#cleanup
							select Sound 'extractasp$'
							plus Pitch 'extractasp$'
							plus pointproc2
							Remove
							endif

							#for interval2 labels that are empty, find next interval
							else
							select textgrid
							asp_interval2 = Get interval at time... 2 end_asp+0.000001
							# get the label of that asp_interval2:
    				 		asp_label2$ = Get label of interval... 2 asp_interval2
							begin_asp2 =  Get starting point... 2 asp_interval2
							end_asp2 =  Get end point... 2 asp_interval2
							duration_asp2 = (end_asp2 - begin_asp2) * 1000
							percent_asp2 = (duration_asp2/duration) * 100

					#change number below to be 1000/minimum pitch (ms)
						 	if duration_asp2 < 50
						    fileappend "'end_directory$''language_name$'-log.txt" 'name$''tab$''interval_label$''tab$''asp_label2$''tab$''duration:2''tab$''duration_asp2:2''tab$''percent_asp2:2''tab$''pctUnvoiced''tab$'NaN'tab$''language_name$''newline$'
							else
					#Extract sound clip for calculating voiceless frames during aspiration
	 					select Sound 'soundname$'
						Extract part... begin_asp2 end_asp2 rectangular 1.0 'no'
						extractasp$ = selected$ ("Sound")
							To Pitch (cc): 0, 50, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, 600
							select Sound 'extractasp$'
							plus Pitch 'extractasp$'
							pointproc2 = To PointProcess (cc)
							select Sound 'extractasp$'
							plus Pitch 'extractasp$'
							plus pointproc2
							report_asp$ = Voice report: 0, 0, 50, 600, 1.3, 1.6, 0.03, 0.45
							pctUnvoicedAsp = extractNumber (report_asp$, "Fraction of locally unvoiced frames: ")*100
					

						  fileappend "'end_directory$''language_name$'-log.txt" 'name$''tab$''interval_label$''tab$''asp_label2$''tab$''duration:2''tab$''duration_asp2:2''tab$''percent_asp2:2''tab$''pctUnvoiced:2''tab$''pctUnvoicedAsp:2''tab$''language_name$''newline$'
							
							#cleanup
							select Sound 'extractasp$'
							plus Pitch 'extractasp$'
							plus pointproc2
							Remove

						endif
						endif
					select textgrid
				endif
     endfor

     select all
     minus Strings list
     Remove
endfor

# And at the end, a little bit of clean up and a message to let you know that it's all done.

select all
Remove
clearinfo
print All files have been processed.

