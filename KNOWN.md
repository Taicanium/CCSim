# Bugs

There is an issue with lines of succession that causes random cousins to succeed instead of children born after a person takes the throne.

Languages are occasionally mislabeled according to time period, causing, e.g. "English (period 4)" to appear twice in the same descent tree.

# Possible Features

Package Curses with the program to save the user the energy of installing LuaRocks? Would need to include versions specific to various OSes, though.

Per the above, perhaps create an install script for CCSim that would handle determining the resident OS and downloading the dependencies accordingly.

Work on implementing an autosave feature. Earlier versions had one (which was even buggier than the rest of the program), but it was removed on account of being so buggy as to be worthless.

Store event data in a temporary data file the same way we now store genealogical data. This would eliminate the last major source of memory leakage.

# To-do

I have been working on learning the TIFF format with the intention of replacing BMP maps with TIFF maps. TIFF is a much more compact (and compression-friendly) file format and doesn't appear too difficult to implement. However it is still something I need to become familiar enough with to code around.

The new family data output doesn't include native and spoken languages. Won't be too hard to add. Just need time to.