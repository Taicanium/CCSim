require 'CCSCommon'

function main()
	_running = true
	
	local clrarr = os.execute("clear")
	if clrarr == nil then clrcmd = "cls" else clrcmd = "clear" end
	
	os.execute(clrcmd)
	io.write(string.format("\tCCSIM : Compact Country Simulator\n\n"))
	
	io.write(string.format("\n How many years should the simulation run? > "))
	local datin = io.read()
	
	yearstorun = tonumber(datin)
	while yearstorun == nil do
		io.write(string.format("\n Please enter a number. > "))
		datin = io.read()
		
		yearstorun = tonumber(datin)
	end
	
	maxyears = yearstorun
	
	io.write(string.format("\n Do you want to show detailed info in the console before it is saved (y/n)?\n Answering N may result in a slight speedup. > "))
	datin = io.read()
	datin = string.lower(datin)
	
	if string.lower(datin) == "y" then showinfo = 1 else showinfo = 0 end
	
	io.write(string.format("\n Data > "))
	datin = io.read()
	
	if string.lower(datin) == "random" then
		thisWorld = World:new()
	
		numCountries = 8
	
		for j=1,numCountries do
			local nl = country:new()
			nl:set()
			thisWorld:add(nl)
		end
	else
		fromFile(datin)
	end
	
	loop()
	finish()
	thisWorld = nil
	
	print(" Done!")
end

main()
