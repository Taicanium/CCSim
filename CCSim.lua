_DEBUG = false

CCSCommon = require("CCSCommon")()

function main()
	CCSCommon.clrcmd = "clear"
	local clrarr = os.execute("clear")

	if not clrarr then CCSCommon.clrcmd = "cls"
	elseif type(clrarr) == "number" and clrarr ~= 0 then CCSCommon.clrcmd = "cls"
	elseif type(clrarr) == "table" then for i, j in pairs(clrarr) do if not i or not j then CCSCommon.clrcmd = "cls" end end end

	for i, j in pairs(CCSCommon.c_events) do
		CCSCommon.disabled[j.name:lower()] = false
		CCSCommon.disabled["!"..j.name:lower()] = false
	end

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
	if datin:lower() == "y" then CCSCommon.showinfo = 1 end

	printp(CCSCommon.stdscr, "\nDo you want to produce 3D maps of the world at major events (y/n)? > ")
	datin = readl(CCSCommon.stdscr)
	datin = datin:lower()

	CCSCommon.doMaps = false
	if datin:lower() == "y" then CCSCommon.doMaps = true end

	printp(CCSCommon.stdscr, "\nDo you want to produce a GEDCOM file for royal lines (y/n)? > ")
	datin = readl(CCSCommon.stdscr)
	datin = datin:lower()

	CCSCommon.ged = false
	if datin:lower() == "y" then CCSCommon.ged = true end

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

	if CCSCommon.doMaps then
		if CCSCommon.clrcmd == "cls" then pcall(os.execute, "rmdir /S /Q maps") -- Windows
		elseif CCSCommon.clrcmd == "clear" then pcall(os.execute, "rm -r -f maps") end -- Linux

		if lfsstatus then pcall(lfs.mkdir, "./maps") else pcall(os.execute, "mkdir maps") end
	end

	CCSCommon.thisWorld:constructVoxelPlanet(CCSCommon)
	CCSCommon:loop()
	CCSCommon = nil
	if cursesstatus then curses.endwin() end
end

main()
os.exit(0)