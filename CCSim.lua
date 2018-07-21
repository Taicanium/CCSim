CCSCommon = require("CCSCommon")()

function main()
	_running = true
	
	local clrarr = os.execute("clear")
	if clrarr == nil then CCSCommon.clrcmd = "cls" else CCSCommon.clrcmd = "clear" end
	
	os.execute(CCSCommon.clrcmd)
	io.write(string.format("\tCCSIM : Compact Country Simulator\n\n"))
	
	io.write(string.format("\n How many years should the simulation run? > "))
	local datin = io.read()
	
	CCSCommon.maxyears = tonumber(datin)
	while CCSCommon.maxyears == nil do
		io.write(string.format("\n Please enter a number. > "))
		datin = io.read()
		
		CCSCommon.maxyears = tonumber(datin)
	end
	
	io.write(string.format("\n Do you want to show detailed info in the console before it is saved (y/n)?\n Answering N may result in a slight speedup. > "))
	datin = io.read()
	datin = string.lower(datin)
	
	if string.lower(datin) == "y" then CCSCommon.showinfo = 1 else CCSCommon.showinfo = 0 end
	
	io.write(string.format("\n Data > "))
	datin = io.read()
	
	if string.lower(datin) == "random" then
		CCSCommon.thisWorld = World:new()
	
		CCSCommon.numCountries = 8
	
		for j=1,CCSCommon.numCountries do
			local nl = Country:new()
			nl:set(CCSCommon)
			CCSCommon.thisWorld:add(nl)
		end
	else
		CCSCommon:fromFile(datin)
	end
	
	CCSCommon:loop()
	CCSCommon.thisWorld = nil
end

main()
