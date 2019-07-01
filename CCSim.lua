_DEBUG = false

CCSMStatus, CCSModule = pcall(require, "CCSCommon")
if not CCSMStatus or not CCSModule then error(tostring(CCSModule)) os.exit(1) end
CCSFStatus, CCSCommon = pcall(CCSModule)
if not CCSFStatus or not CCSCommon then error(tostring(CCSCommon)) os.exit(1) end

function main()
	UI:clear()
	UI:printf("\n\n\tCCSIM : Compact Country Simulator\n")

	UI:printp("\nHow many years should the simulation run? > ")
	CCSCommon.maxyears = UI:readn()
	while not CCSCommon.maxyears do
		UI:printp("Please enter a number. > ")
		CCSCommon.maxyears = UI:readn()
	end

	CCSCommon.maxyears = CCSCommon.maxyears+1 -- We start at year 1.

	UI:printc("\nDo you want to show detailed info in the console (y/n)?\n")
	UI:printp("Answering N may result in a slight speedup. > ")
	datin = UI:readl()
	datin = datin:lower()

	CCSCommon.showinfo = 0
	if datin == "y" then CCSCommon.showinfo = 1 end

	UI:printp("\nDo you want to produce 3D maps of the world at major events (y/n)? > ")
	datin = UI:readl()
	datin = datin:lower()

	CCSCommon.doMaps = false
	if datin == "y" then CCSCommon.doMaps = true end

	UI:printp("\nDo you want to produce a GEDCOM file for royal lines (y/n)? > ")
	datin = UI:readl()
	datin = datin:lower()

	CCSCommon.doGed = false
	if datin == "y" then CCSCommon.doGed = true end

	local done = nil
	while not done do
		UI:printp("\nData > ")
		datin = UI:readl()

		if datin:lower() == "random" then
			UI:printf("\nDefining countries...")

			CCSCommon:rseed()
			CCSCommon.thisWorld = World:new()
			CCSCommon.numCountries = math.random(7, 12)

			for j=1,CCSCommon.numCountries do
				UI:printl("Country %d/%d", j, CCSCommon.numCountries)
				local nl = Country:new()
				nl:set(CCSCommon)
				CCSCommon.thisWorld:add(nl)
				CCSCommon:getAlphabeticalCountries()
			end
			
			done = true
		else
			done = true
			local i, j = pcall(CCSCommon.fromFile, CCSCommon, datin)
			if not i then
				UI:printf("\nUnable to load data file! Please try again.")
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