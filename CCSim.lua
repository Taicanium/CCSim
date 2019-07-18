_DEBUG = false
_RUNNING = true

CCSMStatus, CCSModule = pcall(require, "CCSCommon")
if not CCSMStatus or not CCSModule then error(tostring(CCSModule)) os.exit(1) end
CCSFStatus, CCSCommon = pcall(CCSModule)
if not CCSFStatus or not CCSCommon then error(tostring(CCSCommon)) os.exit(1) end

function simNew()
	UI:clear()
	UI:printp("\nHow many years should the simulation run? > ")
	CCSCommon.maxyears = UI:readn()
	while not CCSCommon.maxyears do
		UI:printp("Please enter a number. > ")
		CCSCommon.maxyears = UI:readn()
	end

	CCSCommon.maxyears = CCSCommon.maxyears+1 -- We start at year 1.

	UI:printc("\nDo you want to show detailed info in the console (y/n)?\n")
	UI:printp("Answering N may result in a slight speedup. > ")
	local datin = UI:readl()

	CCSCommon.showinfo = 0
	if datin:lower() == "y" then CCSCommon.showinfo = 1 end

	UI:printp("\nDo you want to produce 3D maps of the world at major events (y/n)? > ")
	datin = UI:readl()

	CCSCommon.doMaps = false
	if datin:lower() == "y" then CCSCommon.doMaps = true end

	UI:printp("\nDo you want to produce a GEDCOM file for royal lines (y/n)? > ")
	datin = UI:readl()

	CCSCommon.doGed = false
	if datin:lower() == "y" then CCSCommon.doGed = true end

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
end

function printIndi(i, f)
	if not i then return end
	local sOut = tostring(i.gIndex)..". ("..i.gender..") "
	if i.title then
		if not f then for x in i.title:gmatch("%S+") do sOut = sOut..x:sub(1, 1).."." end
		else sOut = sOut..i.title end
		sOut = sOut.." "
	end
	if i.givn then sOut = sOut..i.givn.." " end
	if i.surn then sOut = sOut..i.surn.." " end
	if i.number then sOut = sOut..i.number.." " end
	if i.birt or i.deat then sOut = sOut.."(" end
	if i.birt then
		if not i.deat then sOut = sOut.."b. " end
		if i.birt.dat then sOut = sOut..i.birt.dat end
		if i.birt.dat and i.birt.plac then sOut = sOut..", " end
		if i.birt.plac then
			if not f then
				sOut = sOut..i.birt.plac:sub(1, 3)
				if i.birt.plac:len() > 3 then sOut = sOut.."." end
			else sOut = sOut..i.birt.plac end
		end
		if i.deat then sOut = sOut.." - " else sOut = sOut..")" end
	end
	if i.deat then
		if not i.birt then sOut = sOut.."d. " end
		if i.deat.dat then sOut = sOut..i.deat.dat end
		if i.deat.dat and i.deat.plac then sOut = sOut..", " end
		if i.deat.plac then
			if not f then
				sOut = sOut..i.deat.plac:sub(1, 3)
				if i.deat.plac:len() > 3 then sOut = sOut.."." end
			else sOut = sOut..i.deat.plac end
		end
		sOut = sOut..")"
	end

	UI:printc(sOut.."\n")
end

function gedReview(f)
	local indi = {}
	local fam = {}

	local fi = 1
	local fe = ""

	UI:printf("\nLoading GEDCOM data...")

	local l = f:read("*l")
	while l do
		local split = {}
		for x in l:gmatch("%S+") do table.insert(split, x) end
		if split[3] and split[3] == "INDI" then
			local ifs = split[2]:gsub("@", ""):gsub("I", ""):gsub("P", "")
			local index = tonumber(ifs)
			if index then
				indi[index] = {gIndex=index}
				fi = index
				fe = ""
			end
		end
		if split[3] and split[3] == "FAM" then
			local ifs = split[2]:gsub("@", ""):gsub("F", "")
			local index = tonumber(ifs)
			if index then
				fam[index] = {fIndex=index}
				fi = index
				fe = ""
			end
		end
		if split[2] == "NAME" then
			local name = ""
			for i=3,#split do name = name.." "..split[i] end
			for x in name:gmatch("/(%C+)/") do indi[fi].surn = x end
			for x in name:gmatch("/%C+/ (%C+)") do indi[fi].number = x end
			name = name:gsub("/%C+/ %C+", "")
			for x in name:gmatch("%C+") do if x:sub(x:len(), x:len()) == " " then indi[fi].givn = x:sub(1, x:len()-1) else indi[fi].givn = x end end
			fe = ""
		end
		if split[2] == "SURN" then
			indi[fi].surn = split[3]
			for i=4,#split do indi[fi].surn = indi[fi].surn.." "..split[i] end
			fe = ""
		end
		if split[2] == "GIVN" then
			indi[fi].givn = split[3]
			for i=4,#split do indi[fi].givn = indi[fi].givn.." "..split[i] end
			fe = ""
		end
		if split[2] == "NPFX" then
			indi[fi].title = split[3]
			for i=4,#split do indi[fi].title = indi[fi].title.." "..split[i] end
			fe = ""
		end
		if split[2] == "NSFX" then
			indi[fi].number = split[3]
			for i=4,#split do indi[fi].number = indi[fi].number.." "..split[i] end
			fe = ""
		end
		if split[2] == "SEX" then indi[fi].gender = split[3] fe = "" end
		if split[2] == "BIRT" then fe = split[2]:lower() indi[fi][fe] = {} end
		if split[2] == "DEAT" then fe = split[2]:lower() indi[fi][fe] = {} end
		if split[2] == "BURI" then fe = split[2]:lower() indi[fi][fe] = {} end
		if split[2] == "MARR" then fe = split[2]:lower() fam[fi][fe] = {} end
		if split[2] == "DATE" and fe ~= "" then
			local target = indi
			if fe == "marr" then target = fam end
			target[fi][fe].dat = split[3]
			for i=4,#split do target[fi][fe].dat = target[fi][fe].dat.." "..split[i] end
			if split[#split] and split[#split] == "BC" or split[#split] == "B.C." or split[#split] == "B.C.E." or split[#split] == "B." then target[fi][fe].dat = -(tonumber(split[#split-1])) elseif not tonumber(split[#split]) then target[fi][fe].dat = tonumber(split[#split-1]) else target[fi][fe].dat = tonumber(split[#split]) end
		end
		if split[2] == "PLAC" and fe ~= "" then
			local target = indi
			if fe == "marr" then target = fam end
			target[fi][fe].plac = split[3]
			for i=4,#split do target[fi][fe].plac = target[fi][fe].plac.." "..split[i] end
		end
		if split[2] == "FAMS" then
			if not indi[fi].fams then indi[fi].fams = {} end
			local ifs = split[3]:gsub("@", ""):gsub("F", "")
			table.insert(indi[fi].fams, tonumber(ifs))
			fe = ""
		end
		if split[2] == "FAMC" then
			local ifs = split[3]:gsub("@", ""):gsub("F", "")
			indi[fi].famc = tonumber(ifs)
			fe = ""
		end
		if split[2] == "HUSB" then
			local ifs = split[3]:gsub("@", ""):gsub("I", ""):gsub("P", "")
			fam[fi].husb = tonumber(ifs)
			fe = ""
		end
		if split[2] == "WIFE" then
			local ifs = split[3]:gsub("@", ""):gsub("I", ""):gsub("P", "")
			fam[fi].wife = tonumber(ifs)
			fe = ""
		end
		if split[2] == "CHIL" then
			if not fam[fi].chil then fam[fi].chil = {} end
			local ifs = split[3]:gsub("@", ""):gsub("I", ""):gsub("P", "")
			table.insert(fam[fi].chil, tonumber(ifs))
			fe = ""
		end

		l = f:read("*l")
	end

	local _REVIEWING = true
	fi = 1
	while _REVIEWING do
		UI:clear()
		local i = indi[fi]
		if i.famc and fam[i.famc] then
			local husb = indi[fam[i.famc].husb]
			local wife = indi[fam[i.famc].wife]
			local p1fam = fam[husb.famc]
			if p1fam then
				UI:printc("\t\t")
				printIndi(indi[p1fam.husb])
				UI:printc("\t\t")
				printIndi(indi[p1fam.wife])
			end
			UI:printc("\t")
			printIndi(husb)
			local p2fam = fam[wife.famc]
			if p2fam then
				UI:printc("\t\t")
				printIndi(indi[p2fam.husb])
				UI:printc("\t\t")
				printIndi(indi[p2fam.wife])
			end
			UI:printc("\t")
			printIndi(wife)
		end

		printIndi(i, true)

		if i.fams then for j=1,#i.fams do
			local fams = fam[i.fams[j]]
			if fams then
				local spouse = nil
				if i.gender:sub(1, 1) == "M" then spouse = indi[fams.wife] else spouse = indi[fams.husb] end
				if spouse then
					UI:printc("+ ")
					printIndi(spouse)
					for k=1,#fams.chil do if indi[fams.chil[k]] then
						UI:printc("    ")
						printIndi(indi[fams.chil[k]])
					end end
				end
			end
		end end

		UI:printp("\n\nEnter an individual number or a name to search by, or:\nF to move to the selected individual's father.\nM to move to the selected individual's mother.\nB to return to the previous menu.\n > ")
		local datin = UI:readl()
		if datin:lower() == "b" then _REVIEWING = false
		elseif datin:lower() == "f" then if i.famc then fi = fam[i.famc].husb or 1 end
		elseif datin:lower() == "m" then if i.famc then fi = fam[i.famc].wife or 1 end else
			fi = tonumber(datin)
			if not fi or not indi[fi] then
				local found = false
				local fullName = ""
				for j, k in pairs(indi) do if not found then
					fullName = k.givn
					if k.title then fullName = k.title.." "..fullName end
					if k.number then fullName = fullName.." "..k.number.." "..k.givn end
					fullName = fullName.." "..k.surn.." "
					if k.number then fullName = fullName.." "..k.number end
					fullName = fullName:lower() -- We duplicate the name and number in different places to account for searches such as, e.g., "Person I", "Person Surname I", "Person I Surname".
					if fullName:match(datin:lower()) then
						fi = j
						found = true
					end
				end end
				if not found then fi = 1 end
			end
		end
	end
end

function simReview()
	local _REVIEWING = true

	while _REVIEWING do
		UI:clear()
		local sCount = 0
		local sims = {}
		UI:printf("\nAvailable simulations:\n\n")

		for x in lfs.dir(".") do if lfs.attributes(x, "mode") == "directory" then
			local xn = tonumber(x)
			if xn then
				local tsstatus, ts = pcall(os.date, "%Y-%m-%d %H:%M:%S", xn)
				if tsstatus then
					local eventFile = false
					for y in lfs.dir(x) do if y:match("events.txt") then eventFile = true end end
					if eventFile then
						sCount = sCount+1
						table.insert(sims, x)
						UI:printf("%d\t-\t%s", sCount, os.date('%Y-%m-%d %H:%M:%S', xn))
					end
				end
			end
		end end

		if sCount == 0 then UI:printf("None") end

		UI:printf("\nEnter the number of a simulation, or B to return to the main menu.\n")
		UI:printp(" > ")
		local datin = UI:readl()

		if datin:lower() == "b" then _REVIEWING = false return end
		if tonumber(datin) and sims[tonumber(datin)] then
			local dirStamp = sims[tonumber(datin)]
			local eventFile = false
			local gedFile = false
			for x in lfs.dir(dirStamp) do
				if x:match("events.txt") then eventFile = true
				elseif x:match("royals.ged") then gedFile = true end
			end
			UI:clear()

			local _SELECTED = true
			while _SELECTED do
				UI:clear()
				UI:printf("\nSelected simulation performed %s", os.date('%Y-%m-%d %H:%M:%S', dirStamp))
				local ops = {}
				local thisOp = 1
				-- if eventFile then ops[thisOp] = "events.txt" UI:printf("%d\t-\t%s", thisOp, "Events and history") thisOp = thisOp+1 end
				if gedFile then ops[thisOp] = "royals.ged" UI:printf("%d\t-\t%s", thisOp, "Royal families and relations") thisOp = thisOp+1 end

				UI:printf("\nEnter a selection, or B to return to the previous menu.\n")
				UI:printp(" > ")
				datin = UI:readl()
				if datin:lower() == "b" then _SELECTED = false elseif tonumber(datin) and ops[tonumber(datin)] then
					local op = ops[tonumber(datin)]
					local f = io.open(CCSCommon:directory({dirStamp, op}))
					if f then
						if op == "royals.ged" then gedReview(f) end

						f:close()
						f = nil
					end
				end
			end
		end
	end
end

--[[ function simRemove()

	
	UI:printp("")
end ]]

function main()
	while _RUNNING do
		UI:clear()
		UI:printf("\n\n\tCCSIM : Compact Country Simulator\n\n")

		UI:printf("MAIN MENU\n\n1\t-\tBegin a new simulation.")
		if lfsstatus then
			UI:printf("2\t-\tReview the output of a previous simulation.")
			-- UI:printf("3\t-\tRemove previous simulations.\n")
			UI:printf("Q\t-\tExit the program.")
		end
		UI:printp(" > ")

		local datin = UI:readl()
		if datin == "1" then simNew() _RUNNING = false
		elseif datin == "2" and lfsstatus then simReview()
		--[[ elseif datin == "3" and lfsstatus then simRemove() ]]
		elseif datin:lower() == "q" then _RUNNING = false end
	end

	CCSCommon = nil
	if cursesstatus then curses.endwin() end
end

main()
os.exit(0)
