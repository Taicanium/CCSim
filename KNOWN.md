#Bugs

Border checking scans for whether two countries or regions have respective coastlines (and thus whether they can reach other by water), but does not check whether the coastlines themsleves are actually connected by water; that is, if the two countries or regions have coastlines on different bodies of water, it does not check if those bodies are themselves connected.

The program leaks intense amounts of memory over longer simulations, much more than would be expected from storing the info needed for its output. Should check on garbage collection for temporary table values used in various functions, these may be related.

#Possible Features

Add current system and ruler to the legend of the BMP maps?

Package Curses, LFS and LuaSocket with the program to save the user the energy of installing LuaRocks? Would need to include versions specific to various OSes, though.

Per the above, perhaps create an install script for CCSim that would handle determining the resident OS and downloading the dependencies accordingly.