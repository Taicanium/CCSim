# Bugs

There is an issue with lines of succession that causes random cousins to succeed instead of children born to the previous monarch after their succession to the throne.

Populations are sometimes being created out of nothing upon independence instead of migrated from the parent country. This is a failsafe implemented on purpose, but it indicates -- well, the need for activation of the failsafe i.e. there is yet another issue with the independence event.

# Possible Features

Package Curses with the program to save the user the energy of installing LuaRocks? Would need to include versions specific to various OSes, though.

Per the above, perhaps create an install script for CCSim that would handle determining the resident OS and downloading the dependencies accordingly.

Work on implementing an autosave feature. Earlier versions had one (which was even buggier than the rest of the program), but it was removed on account of being so buggy as to be worthless.

Store event data in a temporary data file the same way we now store genealogical data. This would eliminate the last major source of memory leakage.

# To-do

I have been working on learning the TIFF format with the intention of replacing BMP maps with TIFF maps. TIFF is a much more compact (and compression-friendly) file format and doesn't appear too difficult to implement. However it is still something I need to become familiar enough with to code around.

Congruent archipelagos should be assigned their own seas. It would make for separation from the parent ocean, and add to the "Bodies of Water" listing in maps, after all.
