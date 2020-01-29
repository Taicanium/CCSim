# Bugs

Border checking scans for whether two countries or regions have respective coastlines (and thus whether they can reach other by water), but does not check whether the coastlines themselves are actually connected by water; that is, if the two countries or regions have coastlines on different bodies of water, it does not check if those bodies are themselves connected.

The program leaks intense amounts of memory over longer simulations, much more than would be expected from storing the info needed for its output. Should check on garbage collection for temporary table values used in various functions, these may be related.

Civil wars currently always result in victory for the ruling government.

https://i.imgur.com/Wrp2WMD.png - In this graph, red lines represent memory usage over a 500-year simulation without manual calls to garbage collection; blue lines represent simulations which call collectgarbage() every single step; and green lines represent simulations which call collectgarbage() every 50 steps. The red simulations occupied an average of 1.3 GB of RAM at their ends, while blue simulations occupied an average of 700 MB and green simulations occupied between 750 and 800 MB. Per this data, I have implemented manual calls to garbage collection every 25 steps; calling garbage collection every step nearly triples the needed running time, which isn't practical. This seems a good compromise.

# Possible Features

Package Curses with the program to save the user the energy of installing LuaRocks? Would need to include versions specific to various OSes, though.

Per the above, perhaps create an install script for CCSim that would handle determining the resident OS and downloading the dependencies accordingly.

Work on implementing an autosave feature. Earlier (buggy) versions had one (which was even buggier than the rest of the program), but it was removed on account of being so buggy as to be worthless.

A LOT of RAM could be saved by recording people and their families in a file, reading that file back at the end of the simulation, and using the data to generate the GEDCOM output; in contrast to keeping all of this information in memory. Over the course of a 10,000-year simulation, RAM usage approaches over 60 GB, and while genetic data is not responsible for all of this, it is an extremely significant part: I estimate it may account for as much as three-quarters. Granted, this could probably be reduced quite a bit by making the whole thing more efficient in and of itself; but disk usage would free up far, far more resources for longer simulations. I'd prefer to assign this priority, but it will take a fair amount of re-writing. And knowing my organizational levels these days it may be more of a "when I'm awake and not exhausted" type of situation.
