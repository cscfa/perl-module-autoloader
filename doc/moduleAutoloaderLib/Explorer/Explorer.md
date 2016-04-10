# Explorer
The Explorer package introduce directory exploring.

Use [strict](http://perldoc.perl.org/strict.html)

Use [warnings](http://perldoc.perl.org/warnings.html)

Version: 1.0

Date: 2016/04/09

Author: Matthieu vallance <matthieu.vallance@cscfa.fr>

Module: [ModuleAutoloader](../../ModuleAutoloader.md)

License: MIT

## Attributes

No one now

## Methods

#### New

Base Explorer default constructor

**return:** Explorer


#### searchDirectoriesContaining
	
This search method allow to search a specified file pattern
into a directory recursively or not. Give params as hash.

**param:** text       pattern     the file pattern to search for
**param:** array:text directories a set of directory where search the file
**param:** boolean    recursive   the recursion search state

**return:** a reference to an array containing each of the directories that contain a file matching the given pattern

#### recursiveSearchDirectoriesContaining

_note: internal use only, perform searchDirectoriesContaining with 'recursive'.

This search method perform the same things as searchDirectoriesContaining but
force recursive.

**param:** text       pattern     the file pattern to search for
**param:** array:text directories a set of directory where search the file

**return:** a reference to an array containing each of the directories that contain a file matching the given pattern

#### getDirectoryContent

This method return a set of file and directory that exists into
the given directory. It allowed to perform a patern matching.

**param:** give parameters into an object
	* text    directory        The directory where searh
	* text    pattern          The file pattern to match [optional][default: ".+"]
	* text 	  directoryPattern The directory pattern to match [optional][default: ".+"]
	* boolean withoutDirectory Exclude directory from search results [optional][default: false]
	* boolean withoutFile      Exclude files from search results [optional][default: false]
	
**throw:** DirectoryException if opendir or closedir failed
**throw:** ParameterException if directory parameter is omited

**return:** a pseudo object that contain:
	* file: an array of finded files
	* directory: an array of finded directories
