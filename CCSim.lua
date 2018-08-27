CCSCommon = require("CCSCommon")()

function main()
	_running = true
	
	clrarr = os.execute("clear")
	if clrarr == nil then CCSCommon.clrcmd = "cls" else CCSCommon.clrcmd = "clear" end
	
	os.execute(CCSCommon.clrcmd)
	io.write(string.format("\n\tCCSIM : Compact Country Simulator\n\n"))
	
	if CCSCommon:checkAutoload() == false then
		io.write(string.format("\nHow many years should the simulation run? > "))
		datin = io.read()
		
		CCSCommon.maxyears = tonumber(datin)
		while CCSCommon.maxyears == nil do
			io.write(string.format("\nPlease enter a number. > "))
			datin = io.read()
			
			CCSCommon.maxyears = tonumber(datin)
		end
		
		io.write(string.format("\nDo you want to show detailed info in the console before it is saved (y/n)?\n Answering N may result in a slight speedup. > "))
		datin = io.read()
		datin = string.lower(datin)
		
		if string.lower(datin) == "y" then CCSCommon.showinfo = 1 else CCSCommon.showinfo = 0 end
		
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
		
		io.write(string.format("\nData > "))
		datin = io.read()
		
		if string.lower(datin) == "random" then
			CCSCommon.thisWorld = World:new()
		
			CCSCommon:rseed()
			CCSCommon.numCountries = math.random(8, 12)
		
			print("Defining countries...")
		
			for j=1,CCSCommon.numCountries do
				nl = Country:new()
				nl:set(CCSCommon)
				CCSCommon.thisWorld:add(nl)
			end
			
			if CCSCommon.doR == true then CCSCommon.thisWorld:constructVoxelPlanet(CCSCommon) end
		else
			CCSCommon.doR = false
			CCSCommon:fromFile(datin)
		end
	end
	
	local f = io.open("output.txt", "w+")
	f:flush()
	f:close()
	f = nil
	os.remove("output.txt")
	
	CCSCommon:loop()
	CCSCommon.thisWorld = nil
end

main()
