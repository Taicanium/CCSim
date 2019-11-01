# CCSim
Compact Country Simulator; A teensy tiny, highly experimental Lua script that simulates international relations.

Long and short: Run the script, answer the prompts, and in response to "Data > " you may type "random" or give the name of a text file with country data in it. See 'File Format' for a description of the required format.

If the player sets it as such, at the start of the simulation, the script will output a file called "initial.r" in the root directory, which is written in the R programming language. This script file can be executed to produce an interactive 3D model view of the world's initial state, including coloring to indicate the territory of each country. CCSim will also generate a "final.r" upon the simulation's completion.

R is an interpreted language just like Lua, and an R interpreter is available for download at https://cloud.r-project.org/. More information on the language can be found at https://www.r-project.org.

If you have a Linux system, I highly recommend using the custom interpreter (TREPL) bundled with the Torch project (https://github.com/torch/torch7). Simply installing the libraries bundled with Torch may reduce runtime of this script as dramatically as from several minutes to several seconds. Be sure, if you do this, to configure your Torch installation with Lua 5.2, and not LuaJIT! The JIT interpreter is incapable of addressing the amount of memory CCSim uses.

# File Format
As an alternative to randomly generated data, CCSim supports the use of a text file with predetermined country data to use as a base for its simulation (which remains random). "monarchies.txt" is a file included with this repository that provides predetermined data on the monarchies of England, France, Belgium, Denmark, Russia, and Japan, up to the year 2094 based on assumptions of the futures of those countries (and disregarding the revolutions in France and Russia) to that point. "allcountries.txt" includes the preceding data in addition to all other present countries on Earth (as of 2018), and their capital cities.

If the user wishes to write their own data file, the required data format is as follows:

Year (n) - This line may technically appear anywhere in the file, but it is recommended it be placed at the top for simplicity. (n) is the year at which the simulation will start, and may be any positive integer; theoretically it may be negative, symbolizing, say, a year B.C., but I have not extensively tested what this will do to the simulation and it is not recommended.

Disable (s) - This line may also appear anywhere in the file, but would serve easier at the top. (s) is any of CCSim's defined random events; this line will prevent that event from ever occurring in a simulation using this data file. CCSim's defined events are listed under the Events section below.

C (s) - Defines a country. (s) is its name, which may include spaces. Note that all following lines, barring a Year line, will be considered as relating to this particular country (the 'focus' country), until either the end of the file is reached or a new C line is encountered.

R (s) - Defines a region within the focus country, which presently serves no purpose except as something that can be lost or gained in a war or invasion. This region will be set as the focus region, so that until the next R or C line, the user may also define a city within this region.

S (s) - Defines a city within the focus region, which presently serves no purpose at all.

P (s) - Defines a city within the focus region, and sets it to be the capital of the focus country.

(t) (s1) [s2] (n1) (n2) - Defines a ruler of the focus country. (t) is the ruler's title (which must be one of the titles listed in 'Systems' below), (s1) is their given name, [s2] is their surname (in the case of a non-dynastic ruler; this should be omitted otherwise), (n1) is the year they began their rule, and (n2) is the year their rule ended. Note that the n2 value of the last defined ruler does not necessarily need to correspond to the Year value; although I have not tested the script's behavior in such a case.

# Events

CCSim utilizes predefined events that may occur randomly throughout a simulation (unless disabled). Some occur instantaneously (such as the Coup d'Etat event), while others are procedural and influenced by the current state of the simulation (such as wars and civil wars). Certain 'inverse' events - such as invasions and conquering - are made more likely to occur if a country is more stable.

Procedural events have a status variable which dictates how close either side is to victory. A value of 0 indicates a complete tossup; -100 is victory for the initiator of the event and 100 is victory for the target. The status is initially set depending on the strength and stability of either side; if the initiator is significantly stronger and more stable, for example, the status may begin with a value of -30. It is possible for the event to begin with a status already less than -100 or greater than 100, in which case the event will immediately end the following year in a victory for the respective side.

All of CCSim's defined events are as follows:

Coup d'Etat - This event results in a change in the ruler of a country, without changing its political system. The previous ruler may either be exiled to another country or executed.

Revolution - This event results in a change in the ruler of a country, as well as a change in its political system. The previous ruler may either be exiled to another country or executed, although the chance of execution is more likely versus during a Coup event (50 percent versus 25 percent).

Civil War - This event is procedural; the opposing rebels take the place of the initiating side, and the present government takes the place of the target. If the opposition wins, the result is the same as a revolution; if the government wins, there is no change except for a loss of stability and strength. Other countries may intervene on behalf of either side, depending on their relationship with the government. If it is positive (specifically greater than 70 on a scale of 1 to 100), the foreign country has a chance every year to intervene on the government's side, which becomes more likely the better their relations. The opposite is true for the rebels: If the foreign country has a relationship score of 20 or less, they may intervene on behalf of the rebels.

War - Like civil wars, this event is procedural. The victor gains strength and stability, while the defeated country loses it. If one side is significantly stronger than the other (at least 20 percent stronger) when the event ends, they will claim a region of the loser as their own, complete with all the citizens residing there. This event may not occur between two countries with good relations.

Alliance - This event is procedural, but its ending (and beginning) is dependent on the relationship between the initiator and target, and has no negative impact once ended. While this event is in place, either country will have a chance to intervene on the side of the other during a war. If this happens, their strength will be factored in as part of the war event's status variable.

Independence - This event results in a region of a country gaining its independence. It becomes a country in and of itself, with its own regions and cities. Citizens living in the region when it gains independence will become its citizens, as will an additional one-fifth of all citizens in the parent country.

Invade - This event results in a loss of stability for the target. Like the war event, if the initiator is much stronger than the target, the initiator will claim a region of the target as its own. It is not procedural, and may happen at random, though it becomes impossible if either the two countries have good relations or the initiator is weaker than the target.

Conquer - This event results in the target becoming a region of the initiator, and no longer acting as a country. All citizens residing in the target are moved to the initiator, and the initiator loses a small amount of stability, but gains a large amount of strength. The two countries must have a relationship score of 10 out of 100 or lower. The conquered country may later regain its independence.

Capital Migration - This event is rather simple, in that it changes the capital of a country from its current city to another random one. It currently serves no purpose other than aesthetics.

Annex - This event is similar to conquering, except that it only occurs between two countries who have very good relations (greater than 85 out of 100) and who share a majority ethnic group. People may migrate between countries over time, leading to intermingling of ethnicities.

# Systems
Currently, CCSim simulates countries operating on five political systems: Republic, Democracy, Monarchy, Empire, and Oligarchy. Any country simulated in CCSim will always have one of these five systems, and data files written for CCSim must list rulers corresponding to them. It is possible for a country to undergo several different events which may result in a change in its political system, and countries listed in a data file do not need to only have one system; for its simulation, CCSim will define the country as having the system corresponding to the most recent ruler's title in the file, i.e. if the last ruler listed for a country has the title of 'King', it will define the country as a monarchy, regardless of any previous titles. Rulers listed in the file must have the highest title in the country's desired system, i.e. 'King' or 'President'. If they do not, the script will not define the system according to them, which will cause unexpected behavior.

The script defines various titles for people within each country that may be lost and gained at any point, unless that person is a ruler or a ruler's child. Save for the highest titles being used to define rulers, they currently serve no purpose other than aesthetics.

It should be noted that the Monarchy and Empire systems are given a special designation of 'dynastic' within CCSim; at the death of a ruler, if the country has one of these two systems, then the script will check if the last ruler had any children. If they did, it will select the oldest son (or oldest daughter if there are no sons) and make them the new ruler. If they did not, then a new ruler will be selected at random among the populace. If the system is not dynastic, the ruler will be selected at random regardless. A dynastic system also influences several other factors, including the use of specific titles for female rulers (in non-dynastic systems, the same titles are used for male and female rulers).

Notably, when randomly generating countries, CCSim also generates a set of random names for rulers, including separate names for male and female rulers in the case of a dynastic country. If a data file is used, then only the names used for rulers in the file will be included in the simulation (my personal record is Queen Elizabeth CCLXIX of Belgium); if the country is dynastic, but has no female rulers in the file (such as the Salic Law-abiding France), then CCSim will make an exception and generate a set of female-specific names.

The titles in each system are as follows:

Monarchy: "Homeless", "Citizen", "Mayor", "Knight/Dame", "Lord/Lady", "Baron/Baroness", "Viscount/Viscountess", "Earl/Countess", "Marquis/Marquess", "Duke/Duchess", "Prince/Princess", "King/Queen"

Republic: "Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Judge", "Senator", "Minister", "President"

Democracy: "Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Senator", "Speaker", "Prime Minister"

Oligarchy: "Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Minister", "Oligarch", "Premier"

Empire: "Homeless", "Citizen", "Mayor", "Lord/Lady", "Governor", "Viceroy/Vicereine", "Prince/Princess", "Emperor/Empress"

# Politics
Every citizen is bound to register with a political party, but they may change their alignment at random (they are more likely to do so if there is another party whose policy leans correlate more closely with their own beliefs). Each party and person has three randomly generated values associated with them, defined as PBelief, EBelief, and CBelief. These correspond to, respectively, the party's specific stance on issues relating to personal/individual freedoms; economic and monetary freedoms; and freedom of cultural expression. These values may change slowly over time, at the rate of one percentage point per year. Values of this format are also generated for each and every person, and they will tend to register for the party whose PTotal--the sum of the three policy values--is closest to their own unique PTotal.

Political parties are not presently capable of influencing the output data. In earlier versions, if a radical party (defined as a party whose total freedoms add up to -225 or less, or 225 or more) achieved more than 45% popularity, it instantly triggered a revolution in that country. Likewise, if the current ruler's party fell below 20% popularity, a revolution also automatically occurred. This has been removed as part of a reworking of popularity calculations; it is now extremely rare for any one party to achieve more than 30% popularity, and the vast majority rarely rise above 20%.