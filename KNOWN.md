# Bugs

Border checking scans for whether two countries or regions have respective coastlines (and thus whether they can reach other by water), but does not check whether the coastlines themselves are actually connected by water; that is, if the two countries or regions have coastlines on different bodies of water, it does not check if those bodies are themselves connected.

The program leaks intense amounts of memory over longer simulations, much more than would be expected from storing the info needed for its output. Should check on garbage collection for temporary table values used in various functions, these may be related.

Some country demonyms might sound better if they end in "ian" rather than "an". They used to end in "ian", but recent corrections to suffix generation caused all such endings to be shortened to "an".

# Possible Features

Add current system and ruler to the legend of the BMP maps?

Package Curses, LFS and LuaSocket with the program to save the user the energy of installing LuaRocks? Would need to include versions specific to various OSes, though.

Per the above, perhaps create an install script for CCSim that would handle determining the resident OS and downloading the dependencies accordingly.

Work on implementing an autosave feature. Earlier (buggy) versions had one (which was even buggier than the rest of the program), but it was removed on account of being so buggy as to be worthless.

A LOT of RAM could be saved by recording people and their families in a file, reading that file back at the end of the simulation, and using the data to generate the GEDCOM output; in contrast to keeping all of this information in memory. Over the course of a 10,000-year simulation, RAM usage approaches over 60 GB, and while genetic data is not responsible for all of this, it is an extremely significant part: I estimate it may account for as much as three-quarters. Granted, this could probably be reduced quite a bit by making the whole thing more efficient in and of itself; but disk usage would free up far, far more resources for longer simulations.
I'd prefer to assign this priority, but it will take a fair amount of re-writing. And knowing my organizational levels these days it may be more of a "when I'm awake and not exhausted" type of situation.
