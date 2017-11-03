#################################################
# Find the extension of a file like this:
#	@getExtension: fileName$
#	extension$ = getExtension.result$
#
# when given a file name, .result$ holds
# the extension, including the period
# If there's no extension, return empty string ""

procedure getExtension (.str$)

	#get index of last period
	.perInd = rindex_regex(.str$, "\.")

	#if no extension, return ""
	if .perInd == 0
		.result$ = ""
	else
		.result$ = right$ (.str$, (length (.str$) - .perInd) + 1)
	endif

endproc

#########################################################
#
#  .result$ contains the file name without the extension,
#  and without the parent directories (use getParentDir
#  if this is a problem).
#
#	@removeExtension: "/Users/daniel/name.wav"
#	root$ = removeExtension.result$
#	# root$ contains "name"
#
#	# to keep full path:
#	@getParentDir: "/Users/daniel/name.wav"
#	parents$ = getParentDir.result$
#	# parent$ contains "/Users/daniel/"
#
#  only accepts unix style paths:
#  if on Windows, use C:/Users/daniel/boss.txt,
#  not C:\Users\daniel\boss.txt

procedure removeExtension (.str$)

	#first, remove any parent directories
	#last slash index
	.slInd = rindex_regex(.str$, "/")

	#no parent directories
	.noPar$ = right$ (.str$, length (.str$) - .slInd)

	#last period index
	.perInd = rindex_regex(.noPar$, "\.")

	#if no extension
	if .perInd == 0
		.result$ = .noPar$
	else
		.result$ = left$ (.noPar$, .perInd - 1)
	endif

endproc

#######################################################
# If given a full path, will return the parent directories
# (the containing folders)
#
#	@getParentDir: "/Users/daniel/name.wav"
#	parents$ = getParentDir.result$
#	# parent$ contains "/Users/daniel/"
#
# Returns a blank string "" if no parent directory found

procedure getParentDir: .fil$

	#Search for last forward or backward slash
	.reg$ = "/|\\"
	.rightSlashIndex = rindex_regex(.fil$, .reg$)

	#appendInfoLine: "Input: ", .fil$, "Index: ",  .rightSlashIndex
	if .rightSlashIndex == 0
		.result$ = ""
	else
		.result$ = left$(.fil$, .rightSlashIndex)
	endif

endproc

################################################
# noParentDir.result$ contains the lowest-level
# file or folder name. Only tested with forward
# slashes (unix-style paths, which also work on
# Windows. Use "folder/file.txt" instead of 
# "folder\file.txt"). If the lowest level is 
# a folder, the ending slash is maintained.
#
# @noParentDir: "/home/daniel/Desktop/Mom/birthday.txt"
# fileNoParent$ = noParentDir.result$
# # fileNoParent$ contains "birthday.txt"
#
# The lines commented below are a test:
#f$[1] = "/home/daniel/file.txt"
#f$[2] = "/home/daniel/file"
#f$[3] = "/home/daniel/files/"
#f$[4] = "file.txt"
#f$[5] = "file"
#f$[6] = "//"
#
#for c to 6
#
#	@noParentDir: f$[c]
#	appendInfoLine: noParentDir.result$
#
#endfor
procedure noParentDir: .fil$
    .reg$ = "/|\\"

	.charCount = 0
	.matchFound = 0
	.filNoEndSlash$ = .fil$
	.replaceSlash = 0
	repeat
		.rightSlashIndex = rindex_regex(.filNoEndSlash$, .reg$)
		if .rightSlashIndex == 0
			.matchFound = 1
			.result$ = .filNoEndSlash$
		else
			.fullLen = length(.filNoEndSlash$)
			.len = (.fullLen - .rightSlashIndex)
		
			if .len == 0
				# The last character is a slash
				.filNoEndSlash$ = left$(.fil$, .fullLen - 1)
				.replaceSlash = 1
			else
				.result$ = right$(.filNoEndSlash$, .len)
				.matchFound = 1
			endif

		endif
		.charCount += 1
	until .matchFound or (.charCount > .fullLen)

	if .replaceSlash
		.result$ = .result$ + "/"
	endif

	if !.matchFound
		beginPause: "Warning!"
			comment: "Something went wrong in procedure ""noParentDir""."
			comment: "Either the file path was malformed, or there is"
			comment: "a programmer mistake in this procedure. The file"
			comment: "path is:"
			comment: .fil$
		clicked = endPause: "Continue anyway", 1
	endif
endproc

##############################################
# Get a safe file name like this:
#
#    @safeFileName: "fileName.wav"
#    outName$ = safeFileName.result$
#
# Simply keeps trying to find a file
# name that doesn't exist, adding numbers to
# the file name.
# If it finds a file that exists, it goes up
# in numbers using a zero-padded number surrounded.
# by parentheses (tries sound.wav, then sound(01).wav, etc.)
#
# This should work on relative as well as full paths
#
# Numbers are initially zero padded to
# two places (01, 02, 03), though it should have no trouble
# if there are more than 99 files with the same name.
# To change it to be three zeros by default, 
# for example, add this line somewhere toward the top of 
# your script, before calling @safeFileName. 
#
#	safeFileName_numZeros = 3

procedure safeFileName: .inFileName$
	.zeros = 2
	if variableExists: "safeFileName_numZeros"
		.zeros = safeFileName_numZeros 
	endif

    @getParentDir: .inFileName$
    .parentDir$ = getParentDir.result$

    @getExtension: .inFileName$
    .ext$ = getExtension.result$  

    @removeExtension: .inFileName$
    .root$ = removeExtension.result$

	.count = 0
    .outFileName$ = .inFileName$
    while fileReadable: .outFileName$

        .count += 1

        # if we had over a hundred files
        # of the same name, for example,
        # up the zero fill
        if .count >= (10 ^ .zeros)
            .zeros += 1
        endif

        @zeroFill: .count, .zeros
        .count$ = zeroFill.result$

        .outFileName$ = .parentDir$ + .root$ + "(" + .count$ + ")" + .ext$
    endwhile

    .result$ = .outFileName$

endproc

# Takes number as argument, number of zeros
# to fill, and returns a string
procedure zeroFill: .num, .numZeros

	.highestVal = 10 ^ .numZeros

	.num$ = string$: .num
	.numLen = length: .num$
	
	.numToAdd = .numZeros - .numLen

	.zeroPrefix$ = ""
	if .numToAdd > 0
		for .i from 1 to .numToAdd
			.zeroPrefix$ = .zeroPrefix$ + "0"
		endfor
	endif

	.result$ = .zeroPrefix$ + .num$

endproc
