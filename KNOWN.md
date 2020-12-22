# Bugs

There is a potential issue with the planet unwrap function causing land to be omitted from maps. It has so far appeared only as an isolated issue. Examination underway.

There is apparently an extremely rare issue causing a nil exception in the initial planet construction. I'm not sure what the cause could be, but it has to do with unwrapping. Perhaps related to the above? It seems to be more frequent in debug mode.

Continents are Way. Too. Round.

Over much longer simulations (> 5,000 years), lines of succession become mixed up and out of order.

# Possible Features

Package Curses with the program to save the user the energy of installing LuaRocks? Would need to include versions specific to various OSes, though.

Per the above, perhaps create an install script for CCSim that would handle determining the resident OS and downloading the dependencies accordingly.

Store event data in a temporary data file the same way we store genealogical data. This would eliminate the last major source of memory leakage.

# To-do

Work on implementing an autosave feature. Earlier versions had one (which was even buggier than the rest of the program), but it was removed on account of being so buggy as to be worthless.
