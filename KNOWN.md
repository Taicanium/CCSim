# Bugs

Border checking scans for whether two countries or regions have respective coastlines (and thus whether they can reach other by water), but does not check whether the coastlines themselves are actually connected by water; that is, if the two countries or regions have coastlines on different bodies of water, it does not check if those bodies are themselves connected.

The program leaks intense amounts of memory over longer simulations, much more than would be expected from storing the info needed for its output. Should check on garbage collection for temporary table values used in various functions, these may be related.

Correct suffixes for countries. "Tusalv" does not sound pleasant even by fantasy standards.

# Possible Features

Add current system and ruler to the legend of the BMP maps?

Package Curses, LFS and LuaSocket with the program to save the user the energy of installing LuaRocks? Would need to include versions specific to various OSes, though.

Per the above, perhaps create an install script for CCSim that would handle determining the resident OS and downloading the dependencies accordingly.

Work on implementing an autosave feature. Earlier (buggy) versions had one (which was even buggier than the rest of the program), but it was removed on account of being so buggy as to be worthless.
Perhaps use something like this format:

74 52 44 53						tRDS (Magic Number)
00 00 00 01						(Number of entries in the index table)
00 00 00 19						(Length of this entry in the index table in bytes)
00 00 00 09						(Length of this entry's label in bytes)
74 68 69 73 57 6f 72 6c 64		thisWorld
00 00 00 01						(Index in the data table to which this entry points)
00 00 00 01						(Index in the index table of which this entry is a child: for CCSCommon.thisWorld, CCSCommon.)
00 00 00 01						(Number of entries in the data table)
00 00 00 00						(Length of this entry in the data table in bytes)
(etc.)