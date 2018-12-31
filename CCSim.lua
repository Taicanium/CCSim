CCSCommon = require("CCSCommon")()

function main()
	local clrarr = os.execute("clear")
	if clrarr == nil then CCSCommon.clrcmd = "cls"
	elseif type(clrarr) == "table" then if clrarr[1] == false then CCSCommon.clrcmd = "cls" else CCSCommon.clrcmd = "clear" end
	elseif type(clrarr) == "number" then if clrarr ~= 0 then CCSCommon.clrcmd = "cls" else CCSCommon.clrcmd = "clear" end
	elseif type(clrarr) == "boolean" then if clrarr == false then CCSCommon.clrcmd = "cls" else CCSCommon.clrcmd = "clear" end end

	os.execute(CCSCommon.clrcmd)
	io.write(string.format("\n\n\tCCSIM : Compact Country Simulator\n\n"))

	if CCSCommon:checkAutoload() == false then
		io.write(string.format("\nHow many years should the simulation run? > "))
		local datin = io.read()

		CCSCommon.maxyears = tonumber(datin)
		while CCSCommon.maxyears == nil do
			io.write(string.format("\nPlease enter a number. > "))
			datin = io.read()

			CCSCommon.maxyears = tonumber(datin)
		end

		io.write(string.format("\nDo you want to show detailed info in the console before it is saved (y/n)?\n Answering N may result in a slight speedup. > "))
		datin = io.read()
		datin = string.lower(datin)

		CCSCommon.showinfo = 0
		if string.lower(datin) == "y" then CCSCommon.showinfo = 1 end

		io.write(string.format("\nHow often do you want the world data to be autosaved? Enter a number of years, or -1 for never. > "))
		datin = io.read()
		CCSCommon.autosaveDur = tonumber(datin)
		while CCSCommon.autosaveDur == nil do
			io.write(string.format("\n Please enter a number. > "))
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
				nl:set(CCSCommon, j)
				CCSCommon.thisWorld:add(nl)
			end

			if CCSCommon.doR == true then CCSCommon.thisWorld:constructVoxelPlanet(CCSCommon) end
		else
			CCSCommon.doR = false
			CCSCommon:fromFile(datin)
		end
	end

	CCSCommon:loop()
end

main()
