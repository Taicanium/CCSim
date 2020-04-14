# Bugs

There are sets of columns in produced maps that are cut entirely out for reasons unknown. This should be fixed as soon as possible.

Border checking scans for whether two countries or regions have respective coastlines (and thus whether they can reach other by water), but does not check whether the coastlines themselves are actually connected by water; that is, if the two countries or regions have coastlines on different bodies of water, it does not check if those bodies are themselves connected.

# Possible Features

Package Curses with the program to save the user the energy of installing LuaRocks? Would need to include versions specific to various OSes, though.

Per the above, perhaps create an install script for CCSim that would handle determining the resident OS and downloading the dependencies accordingly.

Work on implementing an autosave feature. Earlier (buggy) versions had one (which was even buggier than the rest of the program), but it was removed on account of being so buggy as to be worthless.

# To-do

Family data reviewing must be entirely rewritten to conform to the new temp-file-based data format implemented recently to save memory, since GEDCOM is no longer used.