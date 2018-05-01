# CCSim
Compact Country Simulator; A teensy tiny little experimental Lua script that simulates international relations.

Still heavily in refinement. Definitely should be taken with a grain of salt at this point.

Long and short: Run the script, answer the prompts, and in response to "Data > " you may type "random" or give the name of a text file with country data in it. See 'File Format' for a description of the required format.

Side note: If you have a Linux system, I highly recommend using the custom interpreter (TREPL) bundled with the Torch project (https://github.com/torch/torch7). Simply having the libraries installed via Torch will reduce runtime of this script as drastically as several minutes to several seconds.

# File Format
As an alternative to randomly generated data, CCSim supports the use of a text file with predetermined country data to use as a base for its simulation (which remains random). monarchies.txt is a file included with this repository that provides predetermined data on the monarchies of England, France, Belgium, Denmark, and Japan, up to the year 2094 based on assumptions of the futures of those countries to that point. If the user wishes to write their own data file, the required data format is as follows:

YEAR (n) - This line may technically appear anywhere in the file, but it is recommended it be placed at the top for simplicity. (n) may be any positive integer; theoretically it may be negative, symbolizing, say, a year B.C., but I have not extensively tested what this will do to the simulation and it is not recommended.

C (s) - Defines a country. (s) is its name, which may include spaces. Note that all following lines, barring a YEAR line, will be considered as relating to this particular country (the 'focus' country), until either the end of the file is reached or a new C line is encountered.

(t) (s1) [s2] (n1) (n2) - Defines a ruler of the focus country. (t) is the ruler's title (which must be one of the titles listed in 'Systems' below), (s1) is their given name, [s2] is (ONLY in the case of a non-dynastic ruler) their surname, (n1) is the year they began their rule, and (n2) is the year their rule ended. Note that the n2 value of the last defined ruler does not necessarily need to correspond to the YEAR value; although I have not tested the script's behavior in such a case.

# Systems
Currently, CCSim simulates countries operating on five political systems: Republic, Democracy, Monarchy, Empire, and Oligarchy. Any country simulated in CCSim will always have one of these five systems, and data files written for CCSim must list rulers corresponding to them. It is possible for a country to undergo several different events which may result in a change in its political system, and countries listed in a data file do not need to only have one system; for its simulation, CCSim will define the country as having the system corresponding to the most recent ruler's title in the file, i.e. if the last ruler listed for a country has the title of 'King', it will define the country as a monarchy, regardless of any previous titles. Rulers listed in the file must have the highest title in the country's desired system, i.e. 'King' or 'President'. If they do not, the script will not define the system according to them, which will cause unexpected behavior.

Although currently only the two highest titles in each system can directly influence the output data of CCSim, the script defines various titles for people within each country that may be lost and gained at any point, unless that person is a ruler or a ruler's child.

It should be noted that the Monarchy and Empire systems are given a special designation of 'Dynastic' within CCSim; at the death of a ruler, if the country has one of these two systems, then the script will check if the last ruler had any children. If they did not, then a new ruler will be selected at random among the populace. If the system is not dynastic, the ruler will be selected at random regardless. A dynastic system also influences several other factors during random events, including the use of specific titles for female rulers (in non-dynastic systems, the same titles are used for male and female rulers).

Notably, when randomly generating countries, CCSim also generates a set of random names for rulers, including separate names for male and female rulers in the case of a dynastic country. If a data file is used, then only the names used for rulers in the file will be used in the simulation (my personal record is Queen Elizabeth CCLXIX); if the country is dynastic, but has no female rulers in the file (such as the Salic Law-following France), then CCSim will make an exception and generate a set of female-specific names.

The titles in each system are as follows:

Monarchy: "Homeless", "Citizen", "Mayor", "Knight/Dame", "Baron/Baroness", "Viscount/Viscountess", "Earl/Countess", "Marquis/Marquess", "Lord/Lady", "Duke/Duchess", "Prince/Princess", "King/Queen"

Republic: "Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Judge", "Senator", "Prime Minister", "President"

Democracy: "Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Senator", "Speaker"

Oligarchy: "Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Minister", "Oligarch", "Premier"

Empire: "Homeless", "Citizen", "Mayor", "Lord/Lady", "Governor", "Viceroy/Vicereine", "Prince/Princess", "Emperor/Empress"