rebol [
	title: "GLASS - Style List"
	Author: "Christoph Budzinski"
	license: {
	    MIT License
	    Copyright (C)2011 Christoph Budzinski
	    Look at the file LICENSE.txt to read the license.
	}
	date: 2011-01-24
	
	documentation: {
	    Work in Progress, not usable yet
	
		Scans all files in the tutorial folder and displays a list of all the
		styles used in these files. After selecting a style from this list,
		all the tutorial files where the selected style appears in are displayed
		in a second list. Selected tutorial files are displayed in the editor style
	    in the area at the bottom.
	}
]

; execute SLIM library manager
do %../libs/slim.r

; open GLASS
gl: slim/open 'glass none

; open LIQUID and expose functions used
slim/open/expose 'liquid none [content fill link]

allitems: copy []

comment [
; This is the old style listing, which scanned a tutorial file's header to see which
; styles are being used, this is going to be replaced by using PARSE to do this automatically

files: load %../tutorials/
foreach file files [
	header: first load/header join %../tutorials/ file
	foreach widget header/widgets [
		if/else found? find extract allitems 2 to-string widget [
			append select allitems to-string widget to-string file
		] [
			append allitems reduce [to-string widget reduce [to-string file]]
		]
	]
]
]

; create and display the gui
gui: gl/layout/size [
	row [
		list1: scrolled-list no-label [] [
			; after selecting a style in the first list, display all the
			;   tutorial files the selected style appears in in the second
			;   list
			fill list2/aspects/list make-bulk/records 1 copy event/picked-data/2
		]
		list2: list [] [
			fill ed/aspects/text read join %../tutorials/ to-file event/picked-data
		]
	]
	row [
	column tight [
		ed: editor
		pad 5x5
		hscrl: scroller
	]
	column tight [
		row tight [
			vscrl: scroller
		]
	]
	]
] 640x480

; link the scrollbars to the editor
link/reset vscrl/aspects/maximum ed/material/number-of-lines
link/reset vscrl/aspects/visible ed/material/visible-lines
link/reset ed/aspects/top-off vscrl/aspects/value

link/reset hscrl/aspects/maximum ed/material/longest-line
link/reset hscrl/aspects/visible ed/material/visible-length
link/reset ed/aspects/left-off hscrl/aspects/value

; fill the list with the styles found in the tutorial files
fill list1/aspects/items make-bulk/records 2 copy sort/skip allitems 2

; just remove the block comment to work on the PARSE rule
comment [
	
digits: charset [#"0" - #"9"]
characters: charset [#"a" - #"z" #"A" - #"Z"]
alpha-numeric: union digits signs

; list of all GLASS widgets for use in the PARSE rule
widget-block: copy []
foreach widget gl/list-stylesheet [
	append widget-block widget
	append widget-block to-word "|"
]
remove back tail widget-block

; load the first tutorial file to test the PARSE rule on
tutorial: load %../tutorials/tutorial-1_hello-world.r
parse tutorial [
	some [to gl/layout into [
			; inside gl/layout block now
			(print "inside")
			some [to widget-block set found type! (print "found")]
		]
	]
]
]

; start event handling
do-events
