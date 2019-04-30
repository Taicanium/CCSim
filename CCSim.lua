_DEBUG = false

CCSCommon = require("CCSCommon")()
if not CCSCommon then os.exit(-1) end

function main()
	CCSCommon:clearTerm()
	printf(CCSCommon.stdscr, "\n\n\tCCSIM : Compact Country Simulator\n")

	printp(CCSCommon.stdscr, "\nHow many years should the simulation run? > ")
	local datin = readl(CCSCommon.stdscr)

	CCSCommon.maxyears = tonumber(datin)
	while not CCSCommon.maxyears do
		printp(CCSCommon.stdscr, "Please enter a number. > ")
		datin = readl(CCSCommon.stdscr)

		CCSCommon.maxyears = tonumber(datin)
	end

	CCSCommon.maxyears = CCSCommon.maxyears+1 -- We start at year 1.

	printc(CCSCommon.stdscr, "\nDo you want to show detailed info in the console (y/n)?\n")
	printp(CCSCommon.stdscr, "Answering N may result in a slight speedup. > ")
	datin = readl(CCSCommon.stdscr)
	datin = datin:lower()

	CCSCommon.showinfo = 0
	if datin == "y" then CCSCommon.showinfo = 1 end

	printp(CCSCommon.stdscr, "\nDo you want to produce 3D maps of the world at major events (y/n)? > ")
	datin = readl(CCSCommon.stdscr)
	datin = datin:lower()

	CCSCommon.doMaps = false
	if datin == "y" then CCSCommon.doMaps = true end

	local done = nil
	while not done do
		printp(CCSCommon.stdscr, "\nData > ")
		datin = readl(CCSCommon.stdscr)

		if datin:lower() == "random" then
			printf(CCSCommon.stdscr, "\nDefining countries...")

			CCSCommon:rseed()
			CCSCommon.thisWorld = World:new()
			CCSCommon.numCountries = math.random(7, 12)

			for j=1,CCSCommon.numCountries do
				printl(CCSCommon.stdscr, "Country %d/%d", j, CCSCommon.numCountries)
				local nl = Country:new()
				nl:set(CCSCommon)
				CCSCommon.thisWorld:add(nl)
				CCSCommon:getAlphabeticalCountries()
			end

			done = true
		else
			local i, j = pcall(CCSCommon.fromFile, CCSCommon, datin)
			done = true
			if not i then
				printf(CCSCommon.stdscr, "\nUnable to load data file! Please try again.")
				done = nil
			end
		end
	end

	CCSCommon.thisWorld:constructVoxelPlanet(CCSCommon)
	CCSCommon:loop()
	CCSCommon = nil
	if cursesstatus then curses.endwin() end
end

main()
os.exit(0)