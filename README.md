# CCSim
Compact Country Simulator; A teensy tiny little experimental Lua script that simulates international relations.

Still heavily in refinement. Definitely should be taken with a grain of salt at this point.

Long and short: Run the script, answer the prompts, and in response to "Data > " you may type "random" or give the name of a text file with country data in it. See 'File Format' for a description of the required format.

Side note: If you have a Linux system, I highly recommend using the custom interpreter (TREPL) bundled with the Torch project (https://github.com/torch/torch7). Simply having the libraries bundled with Torch may reduce runtime of this script as dramatically as from several minutes to several seconds.

# File Format
As an alternative to randomly generated data, CCSim supports the use of a text file with predetermined country data to use as a base for its simulation (which remains random). monarchies.txt is a file included with this repository that provides predetermined data on the monarchies of England, France, Belgium, Denmark, Russia, and Japan, up to the year 2094 based on assumptions of the futures of those countries to that point. If the user wishes to write their own data file, the required data format is as follows:

Year (n) - This line may technically appear anywhere in the file, but it is recommended it be placed at the top for simplicity. (n) is the year at which the simulation will start, and may be any positive integer; theoretically it may be negative, symbolizing, say, a year B.C., but I have not extensively tested what this will do to the simulation and it is not recommended.

C (s) - Defines a country. (s) is its name, which may include spaces. Note that all following lines, barring a Year line, will be considered as relating to this particular country (the 'focus' country), until either the end of the file is reached or a new C line is encountered.

R (s) - Defines a region within the focus country, which presently serves no purpose except as something that can be lost or gained in a war or invasion. This region will be set as the focus region, so that until the next R or C line, the user may also define a city within this region.

S (s) - Defines a city within the focus region, which presently serves no purpose at all.

P (s) - Defines a city within the focus region, and sets it to be the capital of the focus country.

(t) (s1) [s2] (n1) (n2) - Defines a ruler of the focus country. (t) is the ruler's title (which must be one of the titles listed in 'Systems' below), (s1) is their given name, [s2] is their surname (in the case of a non-dynastic ruler; omit s2 otherwise), (n1) is the year they began their rule, and (n2) is the year their rule ended. Note that the n2 value of the last defined ruler does not necessarily need to correspond to the Year value; although I have not tested the script's behavior in such a case.

# Politics

The newest feature to be added to CCSim is the simulation of political parties within each country. Every citizen is bound to register for one, but they may change their alignment at random (they are more likely to do so if their party is not popular). In the extended console output of CCSim, the political party to which the current ruler belongs is listed underneath the ruler's name; beside the name of the party, you will see a string of numbers in the format (## P, ## E, ## C). These correspond to, respectively, the party's specific stance on issues relating to personal/individual freedoms; economic and monetary freedoms; and freedom of cultural expression.

Political parties are not presently capable of influencing the output data, except that a radical party (defined as a party whose total freedoms add up to -225 or less, or 225 or more), if it achieves more than 45% popularity, will instantly cause a revolution in that country. Likewise, if the current ruler's party falls below 20% popularity, a revolution will also automatically occur.

In the real world, a focus on personal freedoms but not so much economic freedoms is often indicative of a liberal or neoliberal party, such as the American Democratic party. The opposite, focusing on economic freedom and deregulation but to some extent sacrificing personal or cultural liberty to that end, is usually indicative of a conservative party, such as the American Republican party. Desiring both is indicative of Libertarianism or Anarchism, while desiring neither is a sign of Authoritarianism.

# Systems
Currently, CCSim simulates countries operating on five political systems: Republic, Democracy, Monarchy, Empire, and Oligarchy. Any country simulated in CCSim will always have one of these five systems, and data files written for CCSim must list rulers corresponding to them. It is possible for a country to undergo several different events which may result in a change in its political system, and countries listed in a data file do not need to only have one system; for its simulation, CCSim will define the country as having the system corresponding to the most recent ruler's title in the file, i.e. if the last ruler listed for a country has the title of 'King', it will define the country as a monarchy, regardless of any previous titles. Rulers listed in the file must have the highest title in the country's desired system, i.e. 'King' or 'President'. If they do not, the script will not define the system according to them, which will cause unexpected behavior.

Although currently only the two highest titles in each system can directly influence the output data of CCSim, the script defines various titles for people within each country that may be lost and gained at any point, unless that person is a ruler or a ruler's child.

It should be noted that the Monarchy and Empire systems are given a special designation of 'Dynastic' within CCSim; at the death of a ruler, if the country has one of these two systems, then the script will check if the last ruler had any children. If they did, it will select the oldest son (or oldest daughter if there are no sons) and make them the new ruler. If they did not, then a new ruler will be selected at random among the populace. If the system is not dynastic, the ruler will be selected at random regardless. A dynastic system also influences several other factors during random events, including the use of specific titles for female rulers (in non-dynastic systems, the same titles are used for male and female rulers).

Notably, when randomly generating countries, CCSim also generates a set of random names for rulers, including separate names for male and female rulers in the case of a dynastic country. If a data file is used, then only the names used for rulers in the file will be used in the simulation (my personal record is Queen Elizabeth CCLXIX); if the country is dynastic, but has no female rulers in the file (such as the Salic Law-following France), then CCSim will make an exception and generate a set of female-specific names.

The titles in each system are as follows:

Monarchy: "Homeless", "Citizen", "Mayor", "Knight/Dame", "Baron/Baroness", "Viscount/Viscountess", "Earl/Countess", "Marquis/Marquess", "Lord/Lady", "Duke/Duchess", "Prince/Princess", "King/Queen"

Republic: "Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Judge", "Senator", "Minister", "President"

Democracy: "Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Senator", "Speaker", "Chairman"

Oligarchy: "Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Minister", "Oligarch", "Premier"

Empire: "Homeless", "Citizen", "Mayor", "Lord/Lady", "Governor", "Viceroy/Vicereine", "Prince/Princess", "Emperor/Empress"