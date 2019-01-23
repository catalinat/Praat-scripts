#####
# Description:
# Draws raw data from a table as line graph or scatter plot and adds a
# trendline based on a simple linear regression analysis (Praat built-in
# method). You can select various graphics options (color, line style, data
# symbols etc.).
#
# Requirements:
# Table with 2 columns. The first (left) column is considered a factor
# (or explanatory variable) and drawn to the horizontal axis. The second
# (right) column is treated as stochastic data (dependent variable) and is drawn
# to the vertical axis. If you have a table with only one column (stochastic
# data, n rows) the script can insert the necessary factor column and fill it
# with a simple series of increasing values (1..n). The script is also able
# to switch columns.
#
# Usage:
# Select an appropriate table and run the script.
#
# jm, 2014-10-10
#####

# check selected table and provide options for column insertion or switching
table = selected ()
# we may work with a temporary copy of the original table
worktable = table
nOfCols = Get number of columns
if nOfCols > 2
	exitScript: "We need a table with maximal 2 columns (col1: explanatory, col2: dependent)."
elsif nOfCols = 1
	beginPause: "Data and Trendline (Simple Linear Regression)"
		comment: "The selected table has only one column. To calculate"
		comment: "linear regression we need two columns. Assuming that"
		comment: "the existing column contains stochastic data (dependent"
		comment: "variable, vertical axis) we can insert a column with a"
		comment: "simple series of increasing values (explanatory variable,"
		comment: "horizontal axis). We can add that auxiliary column to"
		comment: "the original table or a temporary copy."
		comment: "If you want us to do add a column customize the column"
		comment: "label and click the appropriate button. Otherwise cancel."
		sentence: "Column label", "measurements"
	clicked = endPause: "Cancel", "Add to original", "Add to copy", 3, 1
	if clicked = 1
		goto THEEND
	else
		# column insertion
		nOfRows = Get number of rows
		if clicked = 3
			worktable = Copy: "tmptable"
		endif
		Insert column: 1, column_label$
		for i from 1 to nOfRows
			Set numeric value: i, column_label$, i
		endfor
	endif
elsif nOfCols = 2
	beginPause: "Data and Trendline (Simple Linear Regression)"
		comment: "The first column is considered a factor (explanatory variable,"
		comment: "horizontal axis), the second column is treated as stochastic"
		comment: "data (dependent variable, vertical axis)."
		comment: "If that's correct click Continue. If you you want us to switch"
		comment: "columns temporarily click Switch."
	clicked = endPause: "Cancel", "Switch", "Continue", 3, 1
	if clicked = 1
		goto THEEND
	elsif clicked = 2
		# column switching
		worktable = Copy: "tmptable"
		switchcol$ = Get column label: 1
		# remove left column...
		Remove column: switchcol$
		# ...and add it to the right
		Append column: switchcol$
		nOfRows = Get number of rows
		# fill switched column with values from the original table
		for i from 1 to nOfRows
			selectObject: table
			value = Get value: i, switchcol$
			selectObject: worktable
			Set numeric value: i, switchcol$, value
		endfor
	endif
endif

# ask user for graphics options
beginPause: "Data and Trendline: Configuration"
	comment: "General options:"
	boolean: "Erase all", 1
	natural: "Font size", 12
	choice: "Garnish", 1
		option: "yes"
		option: "no"
	comment: "Data options:"
	choice: "Draw data as", 1
		option: "Line graph"
		option: "Scatter plot"
	optionMenu: "Data color", 1
		option: "Black"
		option: "White"
		option: "Red"
		option: "Green"
		option: "Blue"
		option: "Yellow"
		option: "Cyan"
		option: "Magenta"
		option: "Maroon"
		option: "Lime"
		option: "Navy"
		option: "Teal"
		option: "Purple"
		option: "Olive"
		option: "Pink"
		option: "Silver"
		option: "Grey"
	word: "Data symbol (+xo. for scatter plots)", "+"
	real: "left Horizontal range", "0 (= auto)"
	real: "right Horizontal range", "0 (= auto)"
	real: "left Vertical range", "0 (= auto)"
	real: "right Vertical range", "0 (= auto)"
	comment: "Trendline options:"
	optionMenu: "Line type", 1
		option: "Solid line"
		option: "Dotted line"
		option: "Dashed line"
		option: "Dashed-dotted line"
	optionMenu: "Line color", 5
		option: "Black"
		option: "White"
		option: "Red"
		option: "Green"
		option: "Blue"
		option: "Yellow"
		option: "Cyan"
		option: "Magenta"
		option: "Maroon"
		option: "Lime"
		option: "Navy"
		option: "Teal"
		option: "Purple"
		option: "Olive"
		option: "Pink"
		option: "Silver"
		option: "Grey"
	natural: "Line width", 1
clicked = endPause: "Cancel", "OK", 2, 1
if clicked = 1
	goto THEEND
endif

# get some table parameters
selectObject: worktable
col1$ = Get column label: 1
col2$ = Get column label: 2
minX = Get minimum: col1$
maxX = Get maximum: col1$

# set graphics options (data)
Helvetica
Font size: font_size
Solid line
Line width: 1
Colour: data_color$
if erase_all = 1
	Erase all
endif
if draw_data_as = 1
	Line graph where: col2$, left_Vertical_range, right_Vertical_range, col1$, left_Horizontal_range, right_Horizontal_range, data_symbol$, 0, garnish$, "1"
else
	Scatter plot (mark): col1$, left_Horizontal_range, right_Horizontal_range, col2$, left_Vertical_range, right_Vertical_range, 1, garnish$, data_symbol$
endif

# set graphics options (trendline)
Colour: line_color$
Line width: line_width
do (line_type$)

# linear regression analysis
lreg = To linear regression
lreg$ = Info
intercept = extractNumber (lreg$, "Intercept: ")
slope = extractNumber (lreg$, "Coefficient of factor " + col1$ + ": ")

# calculate trendline coordinates and draw
startLinFit = intercept + slope * minX
endLinFit = intercept + slope * maxX
Draw line: minX, startLinFit, maxX, endLinFit

# clean up
label THEEND
nocheck removeObject: lreg
if worktable <> table
	nocheck removeObject: worktable
endif
selectObject: table