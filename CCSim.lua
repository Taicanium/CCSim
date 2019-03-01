CCSCommon = require("CCSCommon")()

function main()
	CCSCommon.clrcmd = "clear"
	local clrarr = os.execute("clear")

	if not clrarr then CCSCommon.clrcmd = "cls"
	elseif type(clrarr) == "number" then if clrarr ~= 0 then CCSCommon.clrcmd = "cls" end
	elseif type(clrarr) == "table" then for i, j in pairs(clrarr) do if not j then CCSCommon.clrcmd = "cls" end end end

	for i, j in pairs(CCSCommon.c_events) do
		CCSCommon.disabled[j.name:lower()] = false
		CCSCommon.disabled["!"..j.name:lower()] = false
	end

	CCSCommon:clearTerm()
	printf(CCSCommon.stdscr, "\n\tCCSIM : Compact Country Simulator\n")

	if not CCSCommon:checkAutoload() then
		printp(CCSCommon.stdscr, "\nHow many years should the simulation run? > ")
		local datin = readl(CCSCommon.stdscr)

		CCSCommon.maxyears = tonumber(datin)
		while not CCSCommon.maxyears do
			printp(CCSCommon.stdscr, "Please enter a number. > ")
			datin = readl(CCSCommon.stdscr)

			CCSCommon.maxyears = tonumber(datin)
		end

		printf(CCSCommon.stdscr, "\nDo you want to show detailed info in the console (y/n)?")
		printp(CCSCommon.stdscr, "Answering N may result in a slight speedup. > ")
		datin = readl(CCSCommon.stdscr)
		datin = string.lower(datin)

		CCSCommon.showinfo = 0
		if string.lower(datin) == "y" then CCSCommon.showinfo = 1 end

		printf(CCSCommon.stdscr, "\nHow often do you want the world data to be autosaved?")
		printp(CCSCommon.stdscr, "Enter a number of years, or -1 for never. > ")
		datin = readl(CCSCommon.stdscr)
		CCSCommon.autosaveDur = tonumber(datin)
		while not CCSCommon.autosaveDur do
			printp(CCSCommon.stdscr, "Please enter a number. > ")
			datin = readl(CCSCommon.stdscr)

			CCSCommon.autosaveDur = tonumber(datin)
		end

		printp(CCSCommon.stdscr, "\nDo you want to produce a 3D map of the initial and final world states in R (y/n)? > ")
		datin = readl(CCSCommon.stdscr)
		datin = string.lower(datin)

		CCSCommon.doR = false
		if string.lower(datin) == "y" then CCSCommon.doR = true end

		printp(CCSCommon.stdscr, "\nDo you want to produce a GEDCOM file for royal lines (y/n)? > ")
		datin = readl(CCSCommon.stdscr)
		datin = string.lower(datin)

		CCSCommon.ged = false
		if string.lower(datin) == "y" then CCSCommon.ged = true end

		local done = nil
		while not done do
			printp(CCSCommon.stdscr, "\nData > ")
			datin = readl(CCSCommon.stdscr)

			if string.lower(datin) == "random" then
				CCSCommon.thisWorld = World:new()

				CCSCommon:rseed()
				CCSCommon.numCountries = math.random(9, 12)

				printf(CCSCommon.stdscr, "\nDefining countries...")

				for j=1,CCSCommon.numCountries do
					local nl = Country:new()
					nl:set(CCSCommon)
					CCSCommon.thisWorld:add(nl)
					CCSCommon:getAlphabeticalCountries()
				end

				if CCSCommon.doR then CCSCommon.thisWorld:constructVoxelPlanet(CCSCommon) end
				done = true
			else
				local i, j = pcall(CCSCommon.fromFile, CCSCommon, datin)
				done = true
				if not i then
					printf(CCSCommon.stdscr, i, j, "\nUnable to load data file! Please try again.")
					done = nil
				end
			end
		end
	end

	CCSCommon:loop()
	
	os.exit(0)
end

main()
