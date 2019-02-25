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
	io.write(string.format("\n\n\tCCSIM : Compact Country Simulator\n\n"))

	if not CCSCommon:checkAutoload() then
		io.write(string.format("\nHow many years should the simulation run? > "))
		local datin = io.read()

		CCSCommon.maxyears = tonumber(datin)
		while not CCSCommon.maxyears do
			io.write(string.format("\nPlease enter a number. > "))
			datin = io.read()

			CCSCommon.maxyears = tonumber(datin)
		end

		io.write(string.format("\nDo you want to show detailed info in the console (y/n)?\nAnswering N may result in a slight speedup. > "))
		datin = io.read()
		datin = string.lower(datin)

		CCSCommon.showinfo = 0
		if string.lower(datin) == "y" then CCSCommon.showinfo = 1 end

		io.write(string.format("\nHow often do you want the world data to be autosaved?\nEnter a number of years, or -1 for never. > "))
		datin = io.read()
		CCSCommon.autosaveDur = tonumber(datin)
		while not CCSCommon.autosaveDur do
			io.write(string.format("\nPlease enter a number. > "))
			datin = io.read()

			CCSCommon.autosaveDur = tonumber(datin)
		end

		io.write(string.format("\nDo you want to produce a 3D map of the initial and final world states in R (y/n)? > "))
		datin = io.read()
		datin = string.lower(datin)

		CCSCommon.doR = false
		if string.lower(datin) == "y" then CCSCommon.doR = true end

		io.write(string.format("\nDo you want to produce a GEDCOM file for royal lines (y/n)? > "))
		datin = io.read()
		datin = string.lower(datin)

		CCSCommon.ged = false
		if string.lower(datin) == "y" then CCSCommon.ged = true end

		io.write(string.format("\nData > "))
		datin = io.read()

		if string.lower(datin) == "random" then
			CCSCommon.thisWorld = World:new()

			CCSCommon:rseed()
			CCSCommon.numCountries = math.random(9, 12)

			print("Defining countries...")

			for j=1,CCSCommon.numCountries do
				local nl = Country:new()
				nl:set(CCSCommon)
				CCSCommon.thisWorld:add(nl)
				CCSCommon:getAlphabeticalCountries()
			end

			if CCSCommon.doR then CCSCommon.thisWorld:constructVoxelPlanet(CCSCommon) end
		else
			CCSCommon.doR = false
			local done = nil
			while not done do
				local i, j = pcall(CCSCommon.fromFile, CCSCommon, datin)
				done = true
				if not i then
					io.write("Unable to locate data file! Please try again.\nData > ")
					datin = io.read()
					done = nil
				end
			end
		end
	end

	CCSCommon:loop()
end

main()
