fileNameUtils
====

Description
-----------

fileNameUtils contains a few procedures meant to ease breaking apart and
manipulating file names in Praat scripts. You can just copy the procedures 
you want to use to the bottom of your script and you're off and running. 

See below for descriptions, there are also examples
in the files themselves. If you need help or find a mistake, 
let me know. daniel.riggs1@gmail.com

Summary
-------

Note that I use "return" as a shorthand for finding the result in: 
   myResult$ = procedureName.result$

* @safeFileName: .inFileName$

Returns a file name that doesn't exist, using `[dash][zeroPaddedNumber]`, i.e.
if "fileName.wav" exists, it will return "fileName-01.wav".

* @getExtension: .fileName$

Returns extension, including dot. Returns an empty string if no period in name

* @removeExtension: .fileName$

Returns part of file name without extension, (i.e. returns "sound1" for "sound1.wav"),
but does not include parent directories (returns "sound1" for "/home/daniel/sound1.wav").

* @getParentDir: .fileName$

Returns parent directory, including trailing forward slash. (i.e. returns "/home/daniel/" for 
"/home/daniel/sound1.wav")
