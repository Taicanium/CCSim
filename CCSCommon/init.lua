if not loadstring then loadstring = load end
if not table.unpack then table.unpack = function(t, n)
	if not n then return table.unpack(t, 1)
	elseif t[n] then return t[n], table.unpack(t, n+1) end
	return t
end end
if not debug or not debug.upvaluejoin or not debug.getupvalue or not debug.setupvalue or not loadstring then error("Could not locate the Lua debug library! CCSim will not function without it!") return nil end

cursesstatus, curses = pcall(require, "curses")

_time = os.clock
_stamp = os.time
if _time() > 15 then _time = os.time end
if _stamp() < 15 then _stamp = os.clock end

debugTimes = {}

function debugLine()
	local tmpF = true
	while tmpF do
		UI:printp("\n Debug line > ")
		datin = UI:readl()
		if datin == "" then tmpF = false else
			tmpF = loadstring(datin)
			if tmpF then
				local stat, err = pcall(tmpF)
				if not stat then UI:printf(err) else UI:printf(stat) end
			end
		end
	end
end

--[[ function eventReview(f)
	local countries = {}

	local l = f:read("*l")
	while l do
		local split = {}
		for x in l:gmatch("%S+") do table.insert(split, x) end
	end
end ]]

function gedReview(f)
	local indi = {}
	local fam = {}
	local fi = 1
	local fe = ""
	local ic = 0
	local fc = 0
	local mi = 1
	local matches = {}
	local _REVIEWING = true

	if f then
		UI:printf("\nCounting GEDCOM objects...")

		local l = f:read("*l")
		while l do
			local split = {}
			for x in l:gmatch("%S+") do table.insert(split, x) end
			if split[1] and split[1] == "0" and split[3] then
				if split[3] == "INDI" then ic = ic+1 fi = ic
				elseif split[3] == "FAM" then fc = fc+1 fi = fc end
			end
			if math.fmod(fi, 10000) == 0 and fi > 1 then UI:printl(string.format("%d People, %d Families", ic, fc)) end
			l = f:read("*l")
			split = nil
		end

		UI:printl(string.format("%d People, %d Families", ic, fc))
		fi = 1
		f:seek("set")
		UI:printf("\nLoading GEDCOM data...")

		l = f:read("*l")
		while l do
			local split = {}
			for x in l:gmatch("%S+") do table.insert(split, x) end
			if split[1] and split[1] == "0" and split[3] then
				if split[3] == "INDI" then
					if fi > 0 and indi[fi] and math.fmod(fi, 10000) == 0 then UI:printl(string.format("%d/%d People", fi, ic)) end
					local ifs = split[2]:gsub("@", ""):gsub("I", ""):gsub("P", "")
					local index = tonumber(ifs)
					if index then
						indi[index] = {gIndex=index}
						fi = index
						fe = ""
					end
				elseif split[3] == "FAM" then
					if fi > 0 and fam[fi] and math.fmod(fi, 10000) == 0 then UI:printl(string.format("%d/%d Families", fi, fc)) end
					local ifs = split[2]:gsub("@", ""):gsub("F", "")
					local index = tonumber(ifs)
					if index then
						fam[index] = {fIndex=index}
						fi = index
						fe = ""
					end
				end
			elseif split[2] == "NAME" and indi[fi] and not indi[fi].surn and not indi[fi].givn then
				local name = ""
				for i=3,#split do name = name.." "..split[i] end
				if not indi[fi].surn then for x in name:gmatch("/(%C+)/") do indi[fi].surn = x end end
				if not indi[fi].number then for x in name:gmatch("/%C+/ (%C+)") do indi[fi].number = x end end
				if not indi[fi].givn then
					name = name:gsub("/%C+/ %C+", "")
					name = name:gsub("/%C+/", "")
					name = name:gsub("//", "")
					for x in name:gmatch("%C+") do if x:sub(x:len(), x:len()) == " " then indi[fi].givn = x:sub(1, x:len()-1) else indi[fi].givn = x end end
				end
				if indi[fi].givn and not indi[fi].givn:match("%w") then indi[fi].givn = nil end
				if indi[fi].surn and not indi[fi].surn:match("%w") then indi[fi].surn = nil end
				if indi[fi].number and not indi[fi].number:match("%w") then indi[fi].number = nil end
				fe = ""
			elseif split[2] == "SURN" then
				indi[fi].surn = split[3]
				for i=4,#split do indi[fi].surn = indi[fi].surn.." "..split[i] end
				if not indi[fi].surn:match("%w") then indi[fi].surn = nil end
				fe = ""
			elseif split[2] == "GIVN" then
				indi[fi].givn = split[3]
				for i=4,#split do indi[fi].givn = indi[fi].givn.." "..split[i] end
				if not indi[fi].givn:match("%w") then indi[fi].givn = nil end
				fe = ""
			elseif split[2] == "NPFX" then
				indi[fi].title = split[3]
				for i=4,#split do indi[fi].title = indi[fi].title.." "..split[i] end
				if not indi[fi].title:match("%w") then indi[fi].title = nil end
				fe = ""
			elseif split[2] == "NSFX" then
				indi[fi].number = split[3]
				for i=4,#split do indi[fi].number = indi[fi].number.." "..split[i] end
				if not indi[fi].number:match("%w") then indi[fi].number = nil end
				fe = ""
			elseif split[2] == "SEX" then indi[fi].gender = split[3] fe = ""
			elseif split[2] == "BIRT" then fe = split[2]:lower() indi[fi][fe] = {}
			elseif split[2] == "DEAT" then fe = split[2]:lower() indi[fi][fe] = {}
			elseif split[2] == "BURI" then fe = split[2]:lower() indi[fi][fe] = {}
			elseif split[2] == "MARR" then fe = split[2]:lower() fam[fi][fe] = {}
			elseif split[2] == "DATE" and fe ~= "" then
				local target = indi
				if fe == "marr" then target = fam end
				target[fi][fe].dat = split[3]
				for i=4,#split do target[fi][fe].dat = target[fi][fe].dat.." "..split[i] end
				if split[#split] and split[#split] == "BC" or split[#split] == "B.C." or split[#split] == "B.C.E." or split[#split] == "B." or split[#split] == "C." or split[#split] == "E." then
					local sI = #split
					while split[sI] and not tonumber(split[sI]) do sI = sI-1 end
					if split[sI] then target[fi][fe].dat = -(tonumber(split[sI])) else target[fi][fe].dat = nil end
				elseif not tonumber(split[#split]) then
					local sI = #split
					while split[sI] and not tonumber(split[sI]) do sI = sI-1 end
					if split[sI] then target[fi][fe].dat = tonumber(split[sI]) else target[fi][fe].dat = nil end
				else target[fi][fe].dat = tonumber(split[#split]) end
				if target[fi][fe].dat then target[fi][fe].dat = tostring(target[fi][fe].dat) end
				if target[fi][fe].dat then if target[fi][fe].dat == "" or target[fi][fe].dat == "0" or target[fi][fe].dat == "nil" then target[fi][fe].dat = nil end end
			elseif split[2] == "PLAC" and fe ~= "" then
				local target = indi
				if fe == "marr" then target = fam end
				target[fi][fe].plac = split[3]
				for i=4,#split do target[fi][fe].plac = target[fi][fe].plac.." "..split[i] end
				while target[fi][fe].plac:match(", ,") do target[fi][fe].plac = target[fi][fe].plac:gsub(", ,", ",") end
				if not target[fi][fe].plac:match("%w") then target[fi][fe].plac = nil end
				if target[fi][fe].plac then if target[fi][fe].plac == "" or target[fi][fe].plac == "0" or target[fi][fe].plac == "nil" then target[fi][fe].plac = nil end end
			elseif split[2] == "FAMS" then
				if not indi[fi].fams then indi[fi].fams = {} end
				local ifs = split[3]:gsub("@", ""):gsub("F", "")
				table.insert(indi[fi].fams, tonumber(ifs))
				fe = ""
			elseif split[2] == "FAMC" then
				local ifs = split[3]:gsub("@", ""):gsub("F", "")
				indi[fi].famc = tonumber(ifs)
				fe = ""
			elseif split[2] == "NOTE" and indi[fi] then
				if not indi[fi].notes then indi[fi].notes = {} end
				local note = ""
				if split[3] then
					note = split[3]
					for s=4,#split do note = note.." "..split[s] end
				end
				table.insert(indi[fi].notes, note)
			elseif split[2] == "CONT" and indi[fi] and indi[fi].notes then
				local note = ""
				if split[3] then
					note = split[3]
					for s=4,#split do note = note.." "..split[s] end
				end
				table.insert(indi[fi].notes, note)
			elseif split[2] == "HUSB" then
				local ifs = split[3]:gsub("@", ""):gsub("I", ""):gsub("P", "")
				fam[fi].husb = tonumber(ifs)
				fe = ""
			elseif split[2] == "WIFE" then
				local ifs = split[3]:gsub("@", ""):gsub("I", ""):gsub("P", "")
				fam[fi].wife = tonumber(ifs)
				fe = ""
			elseif split[2] == "CHIL" then
				if not fam[fi].chil then fam[fi].chil = {} end
				local ifs = split[3]:gsub("@", ""):gsub("I", ""):gsub("P", "")
				table.insert(fam[fi].chil, tonumber(ifs))
				fe = ""
			end

			split = nil
			l = f:read("*l")
		end
	else
		indi = CCSCommon.indi
		fam = CCSCommon.fam
		ic = CCSCommon.indiCount
		fc = CCSCommon.famCount
		fi = CCSCommon:randomChoice(indi, true)
	end

	while _REVIEWING do
		UI:clear()
		local i = indi[fi]
		local gIndex = i.gIndex
		local gender = i.gender
		local title = i.rulerTitle or i.title
		local givn = i.givn or i.name
		local surn = i.surn or i.surname
		local famc = i.famc
		local fams = i.fams
		if givn and title then givn = givn:gsub(title.." ", ""):gsub(title, "") end
		if famc and fam[famc] then
			local husb = indi[fam[famc].husb]
			local wife = indi[fam[famc].wife]
			if husb then
				local p1fam = fam[husb.famc]
				if p1fam then
					printIndi(indi[p1fam.husb], 3)
					printIndi(indi[p1fam.wife], 3)
				end
				printIndi(husb, 2)
			end
			if wife then
				local p2fam = fam[wife.famc]
				if p2fam then
					printIndi(indi[p2fam.husb], 3)
					printIndi(indi[p2fam.wife], 3)
				end
				printIndi(wife, 2)
			end
		end

		printIndi(i, 0)

		if fams then for j=1,#fams do
			local fams = fam[fams[j]]
			if fams then
				local spouse = nil
				if gender == "M" then spouse = indi[fams.wife] else spouse = indi[fams.husb] end
				if spouse then printIndi(spouse, 1) end
				if fams.chil then for k=1,#fams.chil do if indi[fams.chil[k]] then printIndi(indi[fams.chil[k]], -1) end end end
			end
		end end

		UI:printc("\n")
		if #matches > 0 then UI:printc(string.format("\nViewing match %d/%d.", mi, #matches)) end
		UI:printc("\nEnter an individual number or a name to search by, or:\nB to return to the previous menu.\nF to move to the selected individual's father.\nM to move to the selected individual's mother.\n")
		if #matches > 0 then
			if mi < #matches then UI:printc("N to move to the next match.\n") end
			if mi > 1 then UI:printc("P to move to the previous match.\n") end
		end
		UI:printc("S to view this person's notes.\n")
		UI:printp("\n > ")
		local datin = UI:readl()
		local oldFI = fi
		if datin:lower() == "b" then matches = {} _REVIEWING = false
		elseif datin:lower() == "f" and famc then fi = fam[famc].husb or oldFI
		elseif datin:lower() == "m" and famc then fi = fam[famc].wife or oldFI
		elseif datin:lower() == "n" then
			mi = mi+1
			if mi > #matches then mi = #matches end
			if mi == 0 then mi = 1 end
			fi = matches[mi]
		elseif datin:lower() == "p" then
			mi = mi-1
			if mi < 1 then mi = 1 end
			fi = matches[mi]
		elseif datin:lower() == "e" and _DEBUG then debugLine()
		elseif datin:lower() == "s" then
			UI:clear()
			printIndi(i, 0)
			UI:printc("\n\n")
			if i.notes then for s=1,#i.notes do UI:printf(i.notes[s]) end else UI:printf("This individual has no notes.") end
			UI:readl()
		elseif datin ~= "" then
			matches = {}
			fi = tonumber(datin)
			if not fi then fi = datin end
			if not fi or not indi[fi] then
				local scanned = 0
				for j, k in pairs(indi) do
					local allMatch = true
					local fullName = ""
					local ktitle = k.rulerTitle or k.title
					local kgivn = k.givn or k.name
					local ksurn = k.surn or k.surname
					local knumber = CCSCommon:roman(k.number)
					if ktitle and ktitle ~= "" then fullName = ktitle.." " end
					if kgivn then fullName = fullName..kgivn.." " end
					if ksurn then fullName = fullName..ksurn.." " end
					if knumber and k.number ~= 0 then fullName = fullName..knumber end
					fullName = fullName:lower()
					for x in string.gmatch(datin:lower(), "%w+") do if not fullName:match(x) then allMatch = false end end
					if allMatch then table.insert(matches, j) end
					scanned = scanned + 1
					if scanned > 1 and math.fmod(scanned, 10000) == 0 then UI:printl(string.format("Scanned %d/%d people...", scanned, ic)) end
				end
				if #matches > 0 then fi = matches[1] mi = 1 end
			end
		end
		if not indi[fi] then fi = oldFI end
		if not indi[fi] then fi = CCSCommon:randomChoice(indi, true) end
	end
end

function getLineTolerance(rl)
	local remainingLines = rl
	if not rl then remainingLines = 1 else remainingLines = remainingLines+1 end -- We wish to have a final line on which to blink the cursor.
	if cursesstatus then return UI.y-rl else return 25-rl end
end

function printIndi(i, f)
	if not i then return end
	local gIndex = i.gIndex
	local gender = i.gender
	local title = i.rulerTitle or i.title
	local givn = i.givn or i.name
	local surn = i.surn or i.surname
	local number = i.number
	local birt = i.birt or {dat=tostring(i.birth), plac=i.birthplace}
	local deat = i.deat or {dat=tostring(i.death), plac=i.deathplace}
	if birt and birt.dat then
		if birt.dat == "" or birt.dat == "0" or birt.dat == "nil" then birt.dat = nil end
		if birt.plac == "" or birt.plac == "0" or birt.plac == "nil" then birt.plac = nil end
	end
	if deat and deat.dat then
		if deat.dat == "" or deat.dat == "0" or deat.dat == "nil" then deat.dat = nil end
		if deat.plac == "" or deat.plac == "0" or deat.plac == "nil" then deat.plac = nil end
	end
	local sOut = tostring(gIndex)..". ("..gender..") "
	if title and title ~= "" then
		if f ~= 0 then for x in title:gmatch("%S+") do sOut = sOut..x:sub(1, 1).."." end
		else sOut = sOut..title end
		sOut = sOut.." "
	end
	if givn then sOut = sOut..givn.." "end
	if surn then sOut = sOut..surn.." " end
	if number and number ~= 0 then sOut = sOut..CCSCommon:roman(number).." " end
	if birt or deat then sOut = sOut.."(" end
	if birt and ((birt.dat and birt.dat ~= "0") or (birt.plac and birt.plac ~= "")) then
		if not deat or ((not deat.dat or deat.dat == "0") and (not deat.plac or deat.plac == "")) then sOut = sOut.."b. " end
		if birt.dat and birt.dat ~= "0" then sOut = sOut..birt.dat end
		if birt.dat and birt.dat ~= "0" and birt.plac then sOut = sOut..", " end
		if birt.plac and birt.plac ~= "" then
			if f ~= 0 then
				sOut = sOut..birt.plac:sub(1, 3)
				if birt.plac:len() > 3 then sOut = sOut.."." end
			else sOut = sOut..birt.plac end
		end
		if deat and ((deat.dat and deat.dat ~= "0") or (deat.plac and deat.plac ~= "")) then sOut = sOut.." - " else sOut = sOut..")" end
	end
	if deat and ((deat.dat and deat.dat ~= "0") or (deat.plac and deat.plac ~= "")) then
		if not birt or ((not birt.dat or birt.dat == "0") and (not birt.plac or birt.plac == "")) then sOut = sOut.."d. " end
		if deat.dat and deat.dat ~= "0" then sOut = sOut..deat.dat end
		if deat.dat and deat.dat ~= "0" and deat.plac then sOut = sOut..", " end
		if deat.plac and deat.plac ~= "" then
			if f ~= 0 then
				sOut = sOut..deat.plac:sub(1, 3)
				if deat.plac:len() > 3 then sOut = sOut.."." end
			else sOut = sOut..deat.plac end
		end
		sOut = sOut..")"
	end

	local indent = ""
	if f == 1 then indent = "+ "
	elseif f == 2 then indent = "\t"
	elseif f == 3 then indent = "\t\t"
	elseif f == -1 then indent = "    " end
	UI:printc(indent..sOut.."\n")
end

function simNew()
	UI:clear()

	UI:printp("\nDo you want to show detailed info in the console (y/n)? > ")
	local datin = UI:readl()

	CCSCommon.showinfo = 0
	if datin:lower() == "y" then CCSCommon.showinfo = 1 end

	UI:printp("\nDo you want to produce maps of the world at major events (y/n)? > ")
	datin = UI:readl()

	CCSCommon.doMaps = false
	if datin:lower() == "y" then CCSCommon.doMaps = true end

	local done = false
	while not done do
		UI:printp("\nData > ")
		datin = UI:readl()
		done = true

		if datin:lower() == "random" then
			UI:printf("\nDefining countries...")

			CCSCommon:rseed()

			CCSCommon.thisWorld = World:new()
			local numCountries = math.random(6, 10)

			for j=1,numCountries do
				UI:printl(string.format("Country %d/%d", j, numCountries))
				local nl = Country:new()
				nl:set(CCSCommon)
				CCSCommon.thisWorld:add(nl)
			end

			CCSCommon:getAlphabetical()
		else
			local i, j = pcall(CCSCommon.fromFile, CCSCommon, datin)
			if not i then
				UI:printf("\nUnable to load data file! Please try again.")
				done = false
			end
		end
	end

	CCSCommon.thisWorld:constructVoxelPlanet(CCSCommon)
	CCSCommon:loop()
end

--[[ function simRemove()


	UI:printp("")
end ]]

function simReview()
	local _REVIEWING = true

	while _REVIEWING do
		UI:clear()
		local sCount = 0
		local sims = {}

		local dirDotCmd = "dir . /b /ad"
		if UI.clrcmd == "clear" then dirDotCmd = "dir -1 ." end

		UI:printf("\nAvailable simulations:\n")

		for x in io.popen(dirDotCmd):lines() do
			local xn = tonumber(x)
			if xn then
				local tsstatus, ts = pcall(os.date, "%Y-%m-%d %H:%M:%S", xn)
				if tsstatus then
					local eventFile = false
					local dirSimCmd = "dir "..x.." /b /a-d"
					if UI.clrcmd == "clear" then dirSimCmd = "dir -1 "..x end
					for y in io.popen(dirSimCmd):lines() do if y:match("events.txt") then eventFile = true end end
					if eventFile then
						sCount = sCount+1
						table.insert(sims, x)
						UI:printf(string.format("%d\t-\t%s", sCount, os.date("%Y-%m-%d %H:%M:%S", xn)))
					end
				end
			end
		end

		if sCount == 0 then UI:printf("None") end

		UI:printf("\nEnter the number of a simulation, or B to return to the main menu.\n")
		UI:printp(" > ")
		local datin = UI:readl()

		if datin:lower() == "b" then _REVIEWING = false
		elseif tonumber(datin) and sims[tonumber(datin)] then
			local dirStamp = sims[tonumber(datin)]
			local dirSimCmd = "dir "..dirStamp.." /b /a-d"
			if UI.clrcmd == "clear" then dirSimCmd = "dir -1 "..dirStamp end
			local eventFile = false
			local gedFile = false
			local lineFile = false
			for x in io.popen(dirSimCmd):lines() do
				if x:match("events.txt") then eventFile = true
				elseif x:match("families.ged") then gedFile = true
				elseif x:match("royals.ged") then lineFile = true end
			end
			UI:clear()

			local _SELECTED = true
			while _SELECTED do
				UI:clear()
				UI:printf(string.format("\nSelected simulation performed %s\n", os.date('%Y-%m-%d %H:%M:%S', dirStamp)))
				local ops = {}
				local thisOp = 1
				-- if eventFile then ops[thisOp] = "events.txt" UI:printf(string.format("%d\t-\t%s", thisOp, "Events and history")) thisOp = thisOp+1 end
				if gedFile then ops[thisOp] = "families.ged" UI:printf(string.format("%d\t-\t%s", thisOp, "Royal families and relations")) thisOp = thisOp+1 end
				if lineFile then ops[thisOp] = "royals.ged" UI:printf(string.format("%d\t-\t%s", thisOp, "Royal lines of descent")) thisOp = thisOp+1 end

				UI:printf("\nEnter a selection, or B to return to the previous menu.\n")
				UI:printp(" > ")
				datin = UI:readl()
				if datin:lower() == "b" then _SELECTED = false elseif tonumber(datin) and ops[tonumber(datin)] then
					local op = ops[tonumber(datin)]
					local f = io.open(CCSCommon:directory({dirStamp, op}))
					if f then
						-- if op == "events.txt" then eventReview(f) end
						if op == "royals.ged" or op == "families.ged" then gedReview(f) end

						f:close()
						f = nil
					end
				end
			end
		end
	end
end

function testGlyphs()
	local bmp = {}
	local top = 2
	local bottom = 7
	local pad = 8
	local width = 2
	for j=1,pad do table.insert(bmp, {}) end
	for j, k in pairs(CCSCommon.glyphs) do
		for l=1,pad do for m=1,pad do table.insert(bmp[l], {0, 0, 0}) end end
		width = width+(pad-2)
	end
	local margin = 1
	local glyphArr = {}
	for j, k in pairs(CCSCommon.glyphs) do
		local xi = -1
		for l=1,#glyphArr do if xi == -1 and string.byte(j) < string.byte(glyphArr[l]) then xi = l end end
		if xi == -1 then table.insert(glyphArr, j) else table.insert(glyphArr, xi, j) end
	end
	for j=1,#glyphArr do
		local glyphIndex = glyphArr[j]
		local k = CCSCommon.glyphs[glyphIndex]
		local letterRow = 1
		local letterColumn = 1
		for l=margin,margin+5 do
			for m=top,bottom do
				if k[letterColumn][letterRow] == 1 then bmp[m][l] = {255, 255, 255}
				else bmp[m][l] = {0, 0, 0} end
				letterColumn = letterColumn+1
			end
			letterColumn = 1
			letterRow = letterRow+1
		end
		margin = margin+6
	end
	local adjusted = {}
	local yi = 1
	for i=1,pad do
		adjusted[yi*2] = {}
		adjusted[(yi*2)-1] = {}
		local col = bmp[i]
		for j=1,width do
			adjusted[yi*2][j*2] = col[j]
			adjusted[(yi*2)-1][j*2] = col[j]
			adjusted[yi*2][(j*2)-1] = col[j]
			adjusted[(yi*2)-1][(j*2)-1] = col[j]
		end
		yi = yi+1
	end
	pad = pad*2
	width = width*2
	local bf = io.open("glyphs.bmp", "w+")
	local bmpString = "424Ds000000003600000028000000wh0100180000000000r130B0000130B00000000000000000000"
	local hStringLE = string.format("%.8x", pad)
	local wStringLE = string.format("%.8x", width)
	local rStringLE = ""
	local sStringLE = ""
	local hStringBE = ""
	local wStringBE = ""
	local rStringBE = ""
	local sStringBE = ""
	for x in hStringLE:gmatch("%w%w") do hStringBE = x..hStringBE end
	for x in wStringLE:gmatch("%w%w") do wStringBE = x..wStringBE end
	bmpString = bmpString:gsub("w", wStringBE)
	bmpString = bmpString:gsub("h", hStringBE)

	local byteCount = 0
	for y=pad,1,-1 do
		local btWritten = 0
		for x=1,width do
			btWritten = btWritten+3
			byteCount = byteCount+3
		end
		while math.fmod(btWritten, 4) ~= 0 do
			btWritten = btWritten+1
			byteCount = byteCount+1
		end
	end

	rStringLE = string.format("%.8x", byteCount)
	sStringLE = string.format("%.8x", byteCount+54)
	for x in sStringLE:gmatch("%w%w") do sStringBE = x..sStringBE end
	for x in rStringLE:gmatch("%w%w") do rStringBE = x..rStringBE end
	bmpString = bmpString:gsub("s", sStringBE)
	bmpString = bmpString:gsub("r", rStringBE)

	for x in bmpString:gmatch("%w%w") do bf:write(string.char(tonumber(x, 16))) end

	for y=pad,1,-1 do
		local btWritten = 0
		for x=1,width do
			if adjusted[y] and adjusted[y][x] then
				bf:write(string.char(adjusted[y][x][3]))
				bf:write(string.char(adjusted[y][x][2]))
				bf:write(string.char(adjusted[y][x][1]))
			else
				bf:write(string.char(0))
				bf:write(string.char(0))
				bf:write(string.char(0))
			end
			btWritten = btWritten+3
		end
		while math.fmod(btWritten, 4) ~= 0 do
			bf:write(string.char(0))
			btWritten = btWritten+1
		end
	end

	bf:flush()
	bf:close()
	bf = nil
end

function testNames(n)
	local f = io.open("names.txt", "w+")
	if not f then return end
	local c = n
	if not n then c = 12 end
	for i=1,c do
		f:write(string.format(" -- LENGTH %d, PERSONAL --", i))
		for j=1,c do f:write(string.format("\n%s", CCSCommon:name(true, i, i))) end
		f:write(string.format("\n\n -- LENGTH %d, IMPERSONAL --", i))
		for j=1,c do f:write(string.format("\n%s", CCSCommon:name(false, i, i))) end
		f:write("\n\n")
	end
	f:flush()
	f:close()
	f = nil
end

City = require("CCSCommon.City")()
Country = require("CCSCommon.Country")()
Language = require("CCSCommon.Language")()
Party = require("CCSCommon.Party")()
Person = require("CCSCommon.Person")()
Region = require("CCSCommon.Region")()
UI = require("CCSCommon.UI")()
World = require("CCSCommon.World")()

return
	function()
		local CCSCommon = {
			alpha = {},
			c_events = {
				{
					name="Alliance",
					chance=24,
					target=nil,
					args=2,
					inverse=true,
					beginEvent=function(self, parent, c1) end,
					doStep=function(self, parent, c1)
						if not self.target then return -1 end
						if c1.relations[self.target.name] and c1.relations[self.target.name] < 35 and math.random(1, 50) < 5 then return self:endEvent(parent, c1) end
						if math.random(1, 750) < 5 then return self:endEvent(parent, c1) end
						return 0
					end,
					endEvent=function(self, parent, c1)
						for i=#self.target.alliances,1,-1 do if self.target.alliances[i] == c1.name then table.remove(self.target.alliances, i) end end
						for i=#c1.alliances,1,-1 do if c1.alliances[i] == self.target.name then table.remove(c1.alliances, i) end end

						return -1
					end,
					performEvent=function(self, parent, c1, c2)
						for i=1,#c1.ongoing-1 do if c1.ongoing[i].name == "War" and c1.ongoing[i].target.name == c2.name then return -1 end end
						for i=1,#c2.ongoing do if c2.ongoing[i].name == "War" and c2.ongoing[i].target.name == c1.name then return -1 end end
						for i=1,#c1.alliances do if c1.alliances[i] == c2.name then return -1 end end
						for i=1,#c2.alliances do if c2.alliances[i] == c1.name then return -1 end end

						if c1.relations[c2.name] and c1.relations[c2.name] > 70 then
							self.target = c2
							table.insert(c2.alliances, c1.name)
							table.insert(c1.alliances, c2.name)
							return 0
						end

						return -1
					end
				},
				{
					name="Annexation",
					chance=3,
					target=nil,
					args=2,
					inverse=true,
					performEvent=function(self, parent, c1, c2)
						local patron = false

						for i=1,#c2.rulers do if c2.rulers[i].Country == c1.name then patron = true end end
						for i=1,#c1.rulers do if c1.rulers[i].Country == c2.name then patron = true end end

						if not patron then
							if c1.majority == c2.majority then
								if c1.relations[c2.name] and c1.relations[c2.name] > 85 then
									c1:event(parent, "Annexed "..c2.name)
									c2:event(parent, "Annexed by "..c1.name)

									local newr = Region:new()
									newr.name = c2.name

									for i=#c2.people,1,-1 do
										c2.people[i].region = newr
										c2.people[i].nationality = c1.name
										c2.people[i].military = false
										c2.people[i].isruler = false
										c2.people[i].level = 2
										c2.people[i].title = "Citizen"
										c2.people[i].parentRuler = false
										table.insert(c1.people, table.remove(c2.people, i))
									end

									c2.people = nil

									for i, j in pairs(c2.regions) do
										table.insert(newr.subregions, j)
										for k, l in pairs(j.cities) do newr.cities[k] = l end
									end

									for i=1,#parent.thisWorld.planetdefined do
										local x, y, z = table.unpack(parent.thisWorld.planetdefined[i])
										if parent.thisWorld.planet[x][y][z].country == c2.name then
											parent.thisWorld.planet[x][y][z].country = c1.name
											parent.thisWorld.planet[x][y][z].region = c2.name
											table.insert(c1.nodes, {x, y, z})
											table.insert(newr.nodes, {x, y, z})
										end
									end

									c1.stability = c1.stability-8
									if c1.stability < 1 then c1.stability = 1 end
									if #c2.rulers > 0 then c2.rulers[#c2.rulers].To = parent.years end

									c1.regions[newr.name] = newr
									parent.thisWorld:delete(parent, c2)
								end
							end
						end

						return -1
					end
				},
				{
					name="Capital Migration",
					chance=3,
					target=nil,
					args=1,
					inverse=false,
					performEvent=function(self, parent, c)
						local cCount = 0
						for i, j in pairs(c.regions) do for k, l in pairs(j.cities) do cCount = cCount+1 end end

						if cCount > 2 then
							local oldcap = c.capitalcity
							if not oldcap then oldcap = "" end
							c.capitalregion = nil
							c.capitalcity = nil

							while not c.capitalcity do
								for i, j in pairs(c.regions) do
									for k, l in pairs(j.cities) do
										if l.name ~= oldcap and not c.capitalcity and math.random(1, 100) == 35 then
											c.capitalregion = j.name
											c.capitalcity = k

											local msg = "Capital moved"
											if oldcap ~= "" then msg = msg.." from "..oldcap end
											msg = msg.." to "..c.capitalcity

											c:event(parent, msg)
										end
									end
								end
							end
						end

						return -1
					end
				},
				{
					name="Civil War",
					chance=3,
					target=nil,
					args=1,
					eString="",
					inverse=false,
					status=0,
					opIntervened = {},
					govIntervened = {},
					beginEvent=function(self, parent, c)
						c.civilWars = c.civilWars+1
						c:event(parent, "Beginning of "..parent:ordinal(c.civilWars).." civil war")
						self.status = parent:strengthFactor(c) -- -100 is victory for the opposition side; 100 is victory for the present government.
						local statString = ""
						if self.status <= -10 then statString = tostring(math.floor(math.abs(self.status))).."% opposition"
						elseif self.status >= 10 then statString = tostring(math.floor(math.abs(self.status))).."% government"
						else statString = "tossup" end
						if self.status <= -100 then statString = "opposition victory"
						elseif self.status >= 100 then statString = "government victory" end
						self.eString = string.format("%s %s civil war (%s)", parent:ordinal(c.civilWars), c.demonym, statString)
						self.opIntervened = {}
						self.govIntervened = {}
					end,
					doStep=function(self, parent, c)
						for i, cp in pairs(parent.thisWorld.countries) do
							if cp.name ~= c.name then
								local interv = false
								for j=1,#self.opIntervened do if self.opIntervened[j] == cp.name then interv = true end end
								for j=1,#self.govIntervened do if self.govIntervened[j] == cp.name then interv = true end end
								if not interv then
									if cp.relations[c.name] then
										if cp.relations[c.name] < 20 and math.random(1, cp.relations[c.name]) == 1 then
											c:event(parent, "Intervention on the side of the opposition by "..cp.name)
											cp:event(parent, "Intervened in the "..parent:ordinal(c.civilWars).." "..c.demonym.." civil war on the side of the opposition")
											table.insert(self.opIntervened, cp.name)
										elseif cp.relations[c.name] > 70 and math.random(50, 150-cp.relations[c.name]) == 50 then
											c:event(parent, "Intervention on the side of the government by "..cp.name)
											cp:event(parent, "Intervened in the "..parent:ordinal(c.civilWars).." "..c.demonym.." civil war on the side of the government")
											table.insert(self.govIntervened, cp.name)
										end
									end
								end
							end
						end

						local varistab = parent:strengthFactor(c)

						for i=1,#self.govIntervened do
							local cp = parent.thisWorld.countries[self.govIntervened[i]]
							if cp then
								local extFactor = parent:strengthFactor(cp)
								if extFactor > 0 then varistab = varistab+(extFactor/10) end
							end
						end

						for i=1,#self.opIntervened do
							local cp = parent.thisWorld.countries[self.opIntervened[i]]
							if cp then
								local extFactor = parent:strengthFactor(cp)
								if extFactor < 0 then varistab = varistab-(extFactor/10) end
							end
						end

						self.status = self.status+math.random(math.floor(varistab)-5, math.ceil(varistab)+3)/2
						local statString = ""
						if self.status <= -10 then statString = tostring(math.abs(math.floor(self.status))).."% opposition"
						elseif self.status >= 10 then statString = tostring(math.abs(math.floor(self.status))).."% government"
						else statString = "tossup" end
						if self.status <= -100 then statString = "opposition victory"
						elseif self.status >= 100 then statString = "government victory" end
						self.eString = string.format("%s %s civil war (%s)", parent:ordinal(c.civilWars), c.demonym, statString)

						if self.status <= -100 then return self:endEvent(parent, c) end
						if self.status >= 100 then return self:endEvent(parent, c) end
						return 0
					end,
					endEvent=function(self, parent, c)
						if self.status >= 100 then -- Government victory
							c:event(parent, "End of "..parent:ordinal(c.civilWars).." civil war; victory for "..c.rulers[#c.rulers].title.." "..c.rulers[#c.rulers].name.." "..parent:roman(c.rulers[#c.rulers].number).." of "..c.rulers[#c.rulers].Country)
							for i=1,#self.govIntervened do
								local opC = parent.thisWorld.countries[self.govIntervened[i]]
								if opC then opC:event(parent, "Victory with government forces in the "..parent:ordinal(c.civilWars).." "..c.demonym.." civil war") end
							end
							for i=1,#self.opIntervened do
								local opC = parent.thisWorld.countries[self.opIntervened[i]]
								if opC then opC:event(parent, "Defeat with opposition forces in the "..parent:ordinal(c.civilWars).." "..c.demonym.." civil war") end
							end
						else -- Opposition victory
							if math.random(1, 100) < 51 then -- Executed
								for q=#c.people,1,-1 do if c.people[q] and c.people[q].def and c.people[q].isruler then c:delete(parent, q) end end
							else -- Exiled
								local newC = parent:randomChoice(parent.thisWorld.countries)
								if parent.thisWorld.numCountries > 1 then while newC.name == c.name do newC = parent:randomChoice(parent.thisWorld.countries) end end
								for q, r in pairs(c.people) do if r.isruler then newC:add(parent, r) end end
							end

							for i=1,#self.govIntervened do
								local opC = parent.thisWorld.countries[self.govIntervened[i]]
								if opC then opC:event(parent, "Defeat with government forces in the "..parent:ordinal(c.civilWars).." "..c.demonym.." civil war") end
							end
							for i=1,#self.opIntervened do
								local opC = parent.thisWorld.countries[self.opIntervened[i]]
								if opC then opC:event(parent, "Victory with opposition forces in the "..parent:ordinal(c.civilWars).." "..c.demonym.." civil war") end
							end

							local oldsys = parent.systems[c.system].name
							c.system = math.random(1, #parent.systems)
							if not c.snt[parent.systems[c.system].name] then c.snt[parent.systems[c.system].name] = 0 end
							c.snt[parent.systems[c.system].name] = c.snt[parent.systems[c.system].name]+1
							c:event(parent, "Establishment of the "..parent:ordinal(c.snt[parent.systems[c.system].name]).." "..c.demonym.." "..c.formalities[parent.systems[c.system].name])

							c.hasruler = -1
							c:checkRuler(parent, true)

							local newRuler = nil
							for i=1,#c.people do if c.people[i].isruler then newRuler = c.people[i] end end
							if not newRuler then return -1 end

							local namenum = 0
							local prevtitle = ""
							if newRuler.prevtitle and newRuler.prevtitle ~= "" then prevtitle = newRuler.prevtitle.." " end

							if prevtitle == "Homeless " then prevtitle = "" end
							if prevtitle == "Citizen " then prevtitle = "" end
							if prevtitle == "Mayor " then prevtitle = "" end

							if parent.systems[c.system].dynastic then
								local unisex = 0
								for i=1,#c.rulernames do if c.rulernames[i] == newRuler.rulerName then unisex = 1 end end
								for i=1,#c.frulernames do if c.frulernames[i] == newRuler.rulerName then unisex = unisex == 1 and 2 or 0 end end
								for i=1,#c.rulers do if c.rulers[i].dynastic and c.rulers[i].Country == c.name and tonumber(c.rulers[i].From) >= c.founded and c.rulers[i].name == newRuler.rulerName then if c.rulers[i].title == newRuler.title or unisex then namenum = namenum+1 end end end
								c:event(parent, "End of "..parent:ordinal(c.civilWars).." civil war; victory for "..prevtitle..newRuler.name.." "..newRuler.surname.." of the "..newRuler.party..", now "..newRuler.title.." "..newRuler.rulerName.." "..parent:roman(namenum).." of "..c.name)
							else c:event(parent, "End of "..parent:ordinal(c.civilWars).." civil war; victory for "..prevtitle..newRuler.name.." "..newRuler.surname.." of the "..newRuler.party..", now "..newRuler.title.." of "..c.name) end
						end

						return -1
					end,
					performEvent=function(self, parent, c)
						if math.random(1, 100) < 51 then return -1 end
						for i=1,#c.ongoing-1 do if c.ongoing[i].name == self.name then return -1 end end
						return 0
					end
				},
				{
					name="Conquer",
					chance=3,
					target=nil,
					args=2,
					inverse=true,
					performEvent=function(self, parent, c1, c2, r)
						for i=1,#c1.alliances do if c1.alliances[i] == c2.name or r then return -1 end end
						for i=1,#c2.alliances do if c2.alliances[i] == c1.name or r then return -1 end end

						if r or c1.relations[c2.name] and c1.relations[c2.name] < 21 and c1.strength > c2.strength then
							if not r then
								c1:event(parent, "Conquered "..c2.name)
								c2:event(parent, "Conquered by "..c1.name)
							end

							local newr = Region:new()
							newr.name = c2.name

							for i=#c2.people,1,-1 do c1:add(parent, c2.people[i]) end
							c2.people = nil

							for i, j in pairs(c2.regions) do
								table.insert(newr.subregions, j)
								for k, l in pairs(j.cities) do newr.cities[k] = l end
							end

							for i=1,#parent.thisWorld.planetdefined do
								local x, y, z = table.unpack(parent.thisWorld.planetdefined[i])
								if parent.thisWorld.planet[x][y][z].country == c2.name then
									parent.thisWorld.planet[x][y][z].country = c1.name
									parent.thisWorld.planet[x][y][z].region = c2.name
									table.insert(newr.nodes, {x, y, z})
									table.insert(c1.nodes, {x, y, z})
								end
							end

							c2.nodes = nil

							c1.stability = c1.stability-10
							if c1.stability < 1 then c1.stability = 1 end
							if #c2.rulers > 0 then c2.rulers[#c2.rulers].To = parent.years end

							c1.regions[c2.name] = newr
							parent.thisWorld:delete(parent, c2)
						end

						return -1
					end
				},
				{
					name="Coup d'Etat",
					chance=8,
					target=nil,
					args=1,
					inverse=false,
					eString="",
					performEvent=function(self, parent, c)
						c:event(parent, "Coup d'Etat")

						parent:rseed()
						if math.random(1, 100) < 26 then -- Executed
							for q=#c.people,1,-1 do if c.people[q] and c.people[q].def and c.people[q].isruler then c:delete(parent, q) end end
						else -- Exiled
							local newC = parent:randomChoice(parent.thisWorld.countries)
							if parent.thisWorld.numCountries > 1 then while newC.name == c.name do newC = parent:randomChoice(parent.thisWorld.countries) end end
							for q, r in pairs(c.people) do if r.isruler then newC:add(parent, r) end end
						end

						c.hasruler = -1
						c:checkRuler(parent, true)

						c.stability = c.stability-5
						if c.stability < 1 then c.stability = 1 end

						return -1
					end
				},
				{
					name="Independence",
					chance=3,
					target=nil,
					args=1,
					inverse=false,
					performEvent=function(self, parent, c)
						parent:rseed()

						local values = 0
						for i, j in pairs(c.regions) do values = values+1 end

						if values > 1 then
							local newl = Country:new()
							local nc = parent:randomChoice(c.regions)
							local doSub = math.random(1, 500)
							if doSub < 251 then
								local np = c.regions
								local ni = nc.name
								while nc.subregions and #nc.subregions > 0 do
									np = nc.subregions
									ni = parent:randomChoice(nc.subregions, true)
									nc = np[ni]
								end
								if type(ni) == "number" then table.remove(np, ni) else np[ni] = nil end
							end
							for i, j in pairs(parent.thisWorld.countries) do if j.name == nc.name then return -1 end end

							newl.name = nc.name
							if doSub > 250 then c.regions[nc.name] = nil end

							newl.rulers = {}
							newl.rulernames = {}
							newl.frulernames = {}
							for i=1,#c.rulers do table.insert(newl.rulers, c.rulers[i]) end
							for i=1,#c.rulernames do table.insert(newl.rulernames, c.rulernames[i]) end
							table.remove(newl.rulernames, math.random(1, #newl.rulernames))
							table.insert(newl.rulernames, parent:name(true))
							for i=1,#c.frulernames do table.insert(newl.frulernames, c.frulernames[i]) end
							table.remove(newl.frulernames, math.random(1, #newl.frulernames))
							table.insert(newl.frulernames, parent:name(true))
							for i=1,#nc.nodes do
								local x, y, z = table.unpack(nc.nodes[i])
								parent.thisWorld.planet[x][y][z].country = newl.name
								parent.thisWorld.planet[x][y][z].region = ""
							end

							local retrieved = false

							for i, j in pairs(parent.final) do
								if j.name == newl.name and not retrieved then
									retrieved = true

									newl.events = {}
									newl.rulers = {}
									for k=1,#j.events do table.insert(newl.events, j.events[k]) end
									for k=1,#j.rulers do table.insert(newl.rulers, j.rulers[k]) end

									local found = parent.years
									for k=1,#newl.rulers do if newl.rulers[k].Country == newl.name and newl.rulers[k].From <= found then found = newl.rulers[k].From end end
									newl.founded = found

									newl.snt = j.snt
									newl.dfif = j.dfif
									newl.formalities = j.formalities
									newl.civilWars = j.civilWars
									newl.rulernames = j.rulernames
									newl.frulernames = j.frulernames

									for k, l in pairs(nc.subregions) do newl.regions[l.name] = l end
									for k, l in pairs(newl.regions) do for m, n in pairs(c.regions) do for o, p in pairs(n.cities) do if l.cities[p.name] then n.cities[p.name] = nil end end end end

									parent.final[i] = nil
								end
							end

							newl:event(parent, "Independence from "..c.name)
							c:event(parent, "Granted independence to "..newl.name)

							for i=1,math.floor(#c.people/5) do
								local p = parent:randomChoice(c.people)
								while p.isruler do p = parent:randomChoice(c.people) end
								newl:add(parent, p)
							end

							local pR = nil
							for i=#c.nodes,1,-1 do
								local x, y, z = table.unpack(c.nodes[i])
								if parent.thisWorld.planet[x][y][z].country == c.name and c.regions[parent.thisWorld.planet[x][y][z].region] then
									for j=1,#parent.thisWorld.planet[x][y][z].neighbors do
										local neighbor = parent.thisWorld.planet[x][y][z].neighbors[j]
										local nx, ny, nz = table.unpack(neighbor)
										local nnode = parent.thisWorld.planet[nx][ny][nz]
										if nnode.country == newl.name then
											pR = c.regions[parent.thisWorld.planet[x][y][z].region]
											j = #parent.thisWorld.planet[x][y][z].neighbors
											i = 0
										end
									end
								elseif parent.thisWorld.planet[x][y][z].country == newl.name then table.remove(c.nodes, i) end
							end

							if not pR then pR = parent:randomChoice(c.regions) end
							newl:set(parent)
							newl:setTerritory(parent, c, pR)

							for i, j in pairs(nc.cities) do
								for k, l in pairs(newl.regions) do
									for m=1,#l.nodes do
										local x, y, z = table.unpack(l.nodes[m])
										if parent.thisWorld.planet[x][y][z].city == j.name then
											l.cities[j.name] = j
											nc.cities[j.name] = nil
										elseif x == j.x and y == j.y and z == j.z then
											parent.thisWorld.planet[x][y][z].city = j.name
											l.cities[j.name] = j
											nc.cities[j.name] = nil
										end
									end
								end
							end

							local nrCount = 0
							for i, j in pairs(newl.regions) do nrCount = nrCount+1 end
							for i, j in pairs(newl.regions) do
								local cCount = 0
								for k, l in pairs(j.cities) do cCount = cCount+1 end
								if cCount == 0 then
									local nC = City:new()
									nC:makename(country, parent)

									j.cities[nC.name] = nC
								end
							end

							local nCities = {}
							for i, j in pairs(newl.regions) do for k, l in pairs(j.cities) do table.insert(nCities, k) end end

							for i=#c.people,1,-1 do if c.people[i] and c.people[i].def and not c.people[i].isruler and c.people[i].region and c.people[i].region.name == newl.name then
								local added = false
								for j=1,#nCities do if not added and c.people[i].city == nCities then
									newl:add(parent, c.people[i])
									added = true
								end end
							end end

							parent.thisWorld:add(newl)
							parent:getAlphabetical()

							c.stability = c.stability-math.random(5, 10)
							if c.stability < 1 then c.stability = 1 end

							newl:checkCapital(parent)
							newl:checkRuler(parent, true)
							parent.thisWorld.mapChanged = true

							nc.subregions = nil
							nc.cities = nil
							parent:deepnil(nc)
						end

						return -1
					end
				},
				{
					name="International Scandal",
					chance=14,
					target=nil,
					args=2,
					eString="",
					inverse=true,
					performEvent=function(self, parent, c1, c2)
						local popFactor = (50-c1.rulerPopularity)+(50-c2.rulerPopularity)
						local recovery = math.random(1, 251-popFactor)
						if not c1.relations[c2.name] then c1.relations[c2.name] = 50 end
						if not c2.relations[c1.name] then c2.relations[c1.name] = 50 end
						if recovery < 50 then
							c1.relations[c2.name] = c1.relations[c2.name]-math.random(10, 25)
							c2.relations[c1.name] = c2.relations[c1.name]-math.random(10, 25)
							if c1.relations[c2.name] < 1 then c1.relations[c2.name] = 1 end
							if c2.relations[c1.name] < 1 then c2.relations[c1.name] = 1 end
						else
							c1.relations[c2.name] = c1.relations[c2.name]+math.random(10, 15)
							c2.relations[c1.name] = c2.relations[c1.name]+math.random(10, 15)
							if c1.relations[c2.name] > 100 then c1.relations[c2.name] = 100 end
							if c2.relations[c1.name] > 100 then c2.relations[c1.name] = 100 end
						end

						return -1
					end
				},
				{
					name="Invasion",
					chance=4,
					target=nil,
					args=2,
					inverse=true,
					performEvent=function(self, parent, c1, c2)
						for i=1,#c1.alliances do if c1.alliances[i] == c2.name then return -1 end end
						for i=1,#c2.alliances do if c2.alliances[i] == c1.name then return -1 end end

						if c1.relations[c2.name] and c1.relations[c2.name] < 21 then
							c1:event(parent, "Invaded "..c2.name)
							c2:event(parent, "Invaded by "..c1.name)
							c2.stability = c2.stability-10
							if c1.stability < 1 then c1.stability = 1 end
							if c2.stability < 1 then c2.stability = 1 end
							c1:setPop(parent, math.ceil(c1.population/1.25))
							c2:setPop(parent, math.ceil(c2.population/1.4))

							local rcount = 0
							for q, b in pairs(c2.regions) do if b:borders(parent, c1) > 0 then rcount = rcount+1 end end
							if rcount > 1 and c1.strength > c2.strength+(c2.strength/5) and math.random(1, 30) < 5 then
								local c = parent:randomChoice(c2.regions)
								if reg then
									while reg:borders(parent, c1) == 0 do reg = parent:randomChoice(c2.regions) end
									parent:regionTransfer(c1, c2, reg.name, false)
								end
							end
						end

						return -1
					end
				},
				{
					name="Political Scandal",
					chance=14,
					target=nil,
					args=1,
					eString="",
					inverse=true,
					performEvent=function(self, parent, c)
						local popFactor = (50-c.rulerPopularity)
						local recovery = math.random(1, 151-popFactor)
						if recovery < 50 then c.stability = c.stability-math.random(15, 25)
						else c.stability = c.stability+math.random(5, 10) end

						return -1
					end
				},
				{
					name="Revolution",
					chance=5,
					target=nil,
					args=1,
					eString="",
					inverse=false,
					performEvent=function(self, parent, c)
						for i, j in pairs(c.ongoing) do if j.name == "Civil War" then return -1 end end

						parent:rseed()
						if math.random(1, 100) < 51 then -- Executed
							for q=#c.people,1,-1 do if c.people[q] and c.people[q].def and c.people[q].isruler then c:delete(parent, q) end end
						else -- Exiled
							local newC = parent:randomChoice(parent.thisWorld.countries)
							if parent.thisWorld.numCountries > 1 then while newC.name == c.name do newC = parent:randomChoice(parent.thisWorld.countries) end end
							for q, r in pairs(c.people) do if r.isruler then newC:add(parent, r) end end
						end

						local oldsys = parent.systems[c.system].name
						while parent.systems[c.system].name == oldsys do c.system = math.random(1, #parent.systems) end
						if not c.snt[parent.systems[c.system].name] then c.snt[parent.systems[c.system].name] = 0 end
						c.snt[parent.systems[c.system].name] = c.snt[parent.systems[c.system].name]+1

						c:event(parent, "Revolution: "..oldsys.." to "..parent.systems[c.system].name)
						c:event(parent, "Establishment of the "..parent:ordinal(c.snt[parent.systems[c.system].name]).." "..c.demonym.." "..c.formalities[parent.systems[c.system].name])

						c.hasruler = -1
						c:checkRuler(parent, true)

						c.stability = c.stability-10
						if c.stability < 1 then c.stability = 1 end

						if math.floor(#c.people/10) > 1 then for d=1,math.random(1, math.floor(#c.people/10)) do c:delete(parent, math.random(1, #c.people)) end end

						return -1
					end
				},
				{
					name="War",
					chance=12,
					target=nil,
					args=2,
					status=0,
					eString="",
					inverse=true,
					beginEvent=function(self, parent, c1)
						c1:event(parent, "Declared war on "..self.target.name)
						self.target:event(parent, "War declared by "..c1.name)
						self.status = parent:strengthFactor(c1)-parent:strengthFactor(self.target) -- -100 is victory for the target; 100 is victory for the initiator.
						local statString = ""
						if self.status <= -10 then statString = tostring(math.floor(math.abs(self.status))).."% "..self.target.name
						elseif self.status >= 10 then statString = tostring(math.floor(math.abs(self.status))).."% "..c1.name
						else statString = "tossup" end
						if self.status <= -100 then statString = self.target.demonym.." victory"
						elseif self.status >= 100 then statString = c1.demonym.." victory" end
						self.eString = string.format("%s-%s war (%s)", c1.demonym, self.target.demonym, statString)
					end,
					doStep=function(self, parent, c1)
						if not self.target then return -1 end

						local ao = parent:getAllyOngoing(c1, self.target, self.name)
						local ac = c1.alliances

						for i=1,#ac do
							local c3 = nil
							for j, cp in pairs(parent.thisWorld.countries) do if cp.name == ac[i] then c3 = cp end end
							if c3 then
								local already = false
								for j=1,#ao do if c3.name == ao[j].name then already = true end end
								if not already and math.random(1, 25) == 10 then
									table.insert(c3.allyOngoing, self.name.."?"..c1.name..":"..self.target.name)

									self.target:event(parent, "Intervention by "..c3.name.." on the side of "..c1.name)
									c1:event(parent, "Intervention by "..c3.name.." against "..self.target.name)
									c3:event(parent, "Intervened on the side of "..c1.name.." in war with "..self.target.name)
								end
							end
						end

						ao = parent:getAllyOngoing(self.target, c1, self.name)
						ac = self.target.alliances

						for i=1,#ac do
							local c3 = nil
							for j, cp in pairs(parent.thisWorld.countries) do if cp.name == ac[i] then c3 = cp end end
							if c3 then
								local already = false
								for j=1,#ao do if c3.name == ao[j].name then already = true end end
								if not already and math.random(1, 25) == 10 then
									table.insert(c3.allyOngoing, self.name.."?"..self.target.name..":"..c1.name)

									c1:event(parent, "Intervention by "..c3.name.." on the side of "..self.target.name)
									self.target:event(parent, "Intervention by "..c3.name.." against "..c1.name)
									c3:event(parent, "Intervened on the side of "..self.target.name.." in war with "..c1.name)
								end
							end
						end

						local varistab = parent:strengthFactor(c1)-parent:strengthFactor(self.target)

						ao = parent:getAllyOngoing(c1, self.target, self.name)
						for i=1,#ao do
							local extFactor = parent:strengthFactor(ao[i])
							if extFactor > 0 then varistab = varistab+(extFactor/10) end
						end

						ao = parent:getAllyOngoing(self.target, c1, self.name)
						for i=1,#ao do
							local extFactor = parent:strengthFactor(ao[i])
							if extFactor < 0 then varistab = varistab+(extFactor/10) end
						end

						self.status = self.status+math.random(math.floor(varistab)-5, math.ceil(varistab)+5)/2
						local statString = ""
						if self.status <= -10 then statString = tostring(math.floor(math.abs(self.status))).."% "..self.target.name
						elseif self.status >= 10 then statString = tostring(math.floor(math.abs(self.status))).."% "..c1.name
						else statString = "tossup" end
						if self.status <= -100 then statString = self.target.demonym.." victory"
						elseif self.status >= 100 then statString = c1.demonym.." victory" end
						self.eString = string.format("%s-%s war (%s)", c1.demonym, self.target.demonym, statString)

						if self.status <= -100 then return self:endEvent(parent, c1) end
						if self.status >= 100 then return self:endEvent(parent, c1) end
						return 0
					end,
					endEvent=function(self, parent, c1)
						local c1strength = c1.strength
						local c2strength = self.target.strength

						if self.status >= 100 then
							c1:event(parent, "Victory in war with "..self.target.name)
							self.target:event(parent, "Defeat in war with "..c1.name)

							c1.stability = c1.stability+10
							self.target.stability = self.target.stability-10

							local ao = parent:getAllyOngoing(c1, self.target, self.name)

							for i=1,#ao do
								if ao[i] then
									c1strength = c1strength+ao[i].strength
									ao[i]:event(parent, "Victory with "..c1.name.." in war with "..self.target.name)
								end
							end

							ao = parent:getAllyOngoing(self.target, c1, self.name)

							for i=1,#ao do
								if ao[i] then
									c2strength = c2strength+ao[i].strength
									ao[i]:event(parent, "Defeat with "..self.target.name.." in war with "..c1.name)
								end
							end

							parent:removeAllyOngoing(c1, self.target, self.name)
							parent:removeAllyOngoing(self.target, c1, self.name)

							if c1strength > c2strength+(c2strength/5) then
								local rcount = 0
								for q, b in pairs(self.target.regions) do rcount = rcount+1 end
								if rcount > 1 then
									local rname = parent:randomChoice(self.target.regions).name
									parent:regionTransfer(c1, self.target, rname, false)
								end
							end
						elseif self.status <= -100 then
							c1:event(parent, "Defeat in war with "..self.target.name)
							self.target:event(parent, "Victory in war with "..c1.name)

							c1.stability = c1.stability-20
							self.target.stability = self.target.stability+20

							local ao = parent:getAllyOngoing(c1, self.target, self.name)

							for i=1,#ao do
								c1strength = c1strength+ao[i].strength
								ao[i]:event(parent, "Defeat with "..c1.name.." in war with "..self.target.name)
							end

							ao = parent:getAllyOngoing(self.target, c1, self.name)

							for i=1,#ao do
								c2strength = c2strength+ao[i].strength
								ao[i]:event(parent, "Victory with "..self.target.name.." in war with "..c1.name)
							end

							parent:removeAllyOngoing(c1, self.target, self.name)
							parent:removeAllyOngoing(self.target, c1, self.name)

							if c2strength > c1strength+(c1strength/5) then
								local rcount = 0
								for q, b in pairs(c1.regions) do if b:borders(parent, c2) > 0 then rcount = rcount+1 end end
								if rcount > 1 then
									local reg = parent:randomChoice(c1.regions)
									if reg then
										while reg:borders(parent, c2) == 0 do reg = parent:randomChoice(c1.regions) end
										parent:regionTransfer(self.target, c1, reg.name, false)
									end
								end
							end
						end

						return -1
					end,
					performEvent=function(self, parent, c1, c2)
						for i=1,#c1.ongoing-1 do if c1.ongoing[i].name == self.name and c1.ongoing[i].target.name == c2.name then return -1 end end
						for i=1,#c2.ongoing do if c2.ongoing[i].name == self.name and c2.ongoing[i].target.name == c1.name then return -1 end end
						for i=1,#c1.alliances do if c1.alliances[i] == c2.name then return -1 end end
						for i=1,#c2.alliances do if c2.alliances[i] == c1.name then return -1 end end
						if c1:borders(parent, c2) == 0 then return -1 end

						if not c1.relations[c2.name] then c1.relations[c2.name] = 50 end
						if c1.relations[c2.name] and c1.relations[c2.name] < 30 then
							self.target = c2
							return 0
						end

						return -1
					end
				}
			},
			cIndi = {},
			clrcmd = "",
			consonants = {"b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "w", "y", "z"},
			culledCount = 0,
			dirSeparator = "/",
			disabled = {},
			doMaps = false,
			endgroups = {"land", "ia", "y", "ar", "a", "es", "tria", "tra", "an", "ica", "ria", "ium"},
			fam = {},
			famCount = 0,
			famCulled = {},
			final = {},
			genLimit = 3,
			glyphs = {
				a={{0, 0, 0, 0, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0}},
				b={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 0, 0}},
				c={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0}},
				d={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 0, 0}},
				e={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0}},
				f={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 0, 0, 0, 0}},
				g={{0, 0, 0, 0, 0, 0},
					{0, 0, 1, 1, 1, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 0, 1, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 0, 1, 1, 1, 0}},
				h={{0, 0, 0, 0, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0}},
				i={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 1, 1, 1, 1, 0}},
				j={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 0, 0, 1, 0, 0},
					{0, 0, 0, 1, 0, 0},
					{0, 1, 0, 1, 0, 0},
					{0, 0, 1, 0, 0, 0}},
				k={{0, 0, 0, 0, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 1, 0, 0},
					{0, 1, 1, 0, 0, 0},
					{0, 1, 0, 1, 0, 0},
					{0, 1, 0, 0, 1, 0}},
				l={{0, 0, 0, 0, 0, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0}},
				m={{0, 0, 0, 0, 0, 0},
					{0, 1, 0, 1, 1, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 1, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0}},
				n={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0}},
				o={{0, 0, 0, 0, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 0, 1, 1, 0, 0}},
				p={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 0, 0, 0, 0}},
				q={{0, 0, 0, 0, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 1, 1, 0},
					{0, 0, 1, 1, 1, 0}},
				r={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0}},
				s={{0, 0, 0, 0, 0, 0},
					{0, 0, 1, 1, 1, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 0, 0, 0, 1, 0},
					{0, 1, 1, 1, 0, 0}},
				t={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 0, 1, 1, 0, 0}},
				u={{0, 0, 0, 0, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 1, 0}},
				v={{0, 0, 0, 0, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 0, 1, 1, 0, 0}},
				w={{0, 0, 0, 0, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 0, 1, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 1, 1, 0}},
				x={{0, 0, 0, 0, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0}},
				y={{0, 0, 0, 0, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 0, 1, 1, 1, 0},
					{0, 0, 0, 0, 1, 0},
					{0, 1, 1, 1, 1, 0}},
				z={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 0, 0, 0, 1, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0}},
				[" "]={{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0}},
				["0"]={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 1, 0}},
				["1"]={{0, 0, 0, 0, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 0, 0, 1, 0, 0},
					{0, 0, 0, 1, 0, 0},
					{0, 1, 1, 1, 1, 0}},
				["2"]={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 0, 0, 0, 1, 0},
					{0, 0, 0, 1, 0, 0},
					{0, 0, 1, 0, 0, 0},
					{0, 1, 1, 1, 1, 0}},
				["3"]={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 0, 0, 0, 1, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 0, 0, 0, 1, 0},
					{0, 1, 1, 1, 0, 0}},
				["4"]={{0, 0, 0, 0, 0, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 0, 0, 0, 1, 0},
					{0, 0, 0, 0, 1, 0}},
				["5"]={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 0, 0, 0, 1, 0},
					{0, 1, 1, 1, 0, 0}},
				["6"]={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 1, 0}},
				["7"]={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 0, 0, 0, 1, 0},
					{0, 0, 0, 0, 1, 0},
					{0, 0, 0, 0, 1, 0},
					{0, 0, 0, 0, 1, 0}},
				["8"]={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 1, 0}},
				["9"]={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 1, 0, 0, 1, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 0, 0, 0, 1, 0},
					{0, 1, 1, 1, 1, 0}},
				["-"]={{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 1, 1, 0},
					{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0}},
				["&"]={{0, 0, 0, 0, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 1, 0, 1, 0, 0},
					{0, 1, 1, 0, 0, 0},
					{0, 1, 0, 1, 1, 0},
					{0, 0, 1, 1, 0, 0}},
				["+"]={{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0},
					{0, 0, 1, 0, 0, 0},
					{0, 1, 1, 1, 0, 0},
					{0, 0, 1, 0, 0, 0},
					{0, 0, 0, 0, 0, 0}},
				["'"]={{0, 0, 0, 0, 0, 0},
					{0, 1, 1, 0, 0, 0},
					{0, 1, 1, 0, 0, 0},
					{0, 1, 1, 0, 0, 0},
					{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0}},
				["("]={{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 1, 1, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 0, 1, 0, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 0, 0, 1, 1, 0}},
				[")"]={{0, 0, 0, 0, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 0, 0, 1, 1, 0},
					{0, 0, 0, 0, 1, 0},
					{0, 0, 0, 1, 1, 0},
					{0, 0, 1, 1, 0, 0}},
				["["]={{0, 0, 0, 0, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 0, 1, 0, 0, 0},
					{0, 0, 1, 0, 0, 0},
					{0, 0, 1, 0, 0, 0},
					{0, 0, 1, 1, 0, 0}},
				["]"]={{0, 0, 0, 0, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 0, 0, 1, 0, 0},
					{0, 0, 0, 1, 0, 0},
					{0, 0, 0, 1, 0, 0},
					{0, 0, 1, 1, 0, 0}},
				["."]={{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0},
					{0, 0, 1, 1, 0, 0},
					{0, 0, 1, 1, 0, 0}}
			},
			indi = {},
			indiCount = 0,
			initialgroups = {"Ab", "Ac", "Ad", "Af", "Ag", "Al", "Am", "An", "Ar", "As", "At", "Au", "Av", "Az", "Ba", "Be", "Bh", "Bi", "Bo", "Bu", "Ca", "Ce", "Ch", "Ci", "Cl", "Co", "Cr", "Cu", "Da", "De", "Di", "Do", "Du", "Dr", "Ec", "El", "Er", "Fa", "Fr", "Ga", "Ge", "Go", "Gr", "Gh", "Ha", "He", "Hi", "Ho", "Hu", "Ic", "Id", "In", "Io", "Ir", "Is", "It", "Ja", "Ji", "Jo", "Ka", "Ke", "Ki", "Ko", "Ku", "Kr", "Kh", "La", "Le", "Li", "Lo", "Lu", "Lh", "Ma", "Me", "Mi", "Mo", "Mu", "Na", "Ne", "Ni", "No", "Nu", "Pa", "Pe", "Pi", "Po", "Pr", "Ph", "Ra", "Re", "Ri", "Ro", "Ru", "Rh", "Sa", "Se", "Si", "So", "Su", "Sh", "Ta", "Te", "Ti", "To", "Tu", "Tr", "Th", "Va", "Vi", "Vo", "Wa", "Wi", "Wo", "Wh", "Ya", "Ye", "Yi", "Yo", "Yu", "Za", "Ze", "Zi", "Zo", "Zu", "Zh", "Tha", "Thu", "The", "Thi", "Tho"},
			iSCount = 0,
			iSIndex = 0,
			languages = {},
			middlegroups = {"gar", "rit", "er", "ar", "ir", "ra", "rin", "bri", "o", "em", "nor", "nar", "mar", "mor", "an", "at", "et", "the", "thal", "cri", "ma", "na", "sa", "mit", "nit", "shi", "ssa", "ssi", "ret", "thu", "thus", "thar", "then", "min", "ni", "ius", "us", "es", "ta", "dos", "tho", "tha", "do", "to", "tri"},
			partynames = {
				{"National", "United", "Citizens'", "General", "People's", "Joint", "Workers'", "Free", "New", "Traditional", "Grand", "All", "Loyal"},
				{"National", "United", "Citizens'", "General", "People's", "Joint", "Workers'", "Free", "New", "Traditional", "Grand", "All", "Loyal"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Centrist", "Democratic", "Republican", "Economical", "Moral", "Ethical", "Unionist", "Revivalist", "Monarchist", "Nationalist", "Reformist", "Public", "Patriotic", "Loyalist"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Centrist", "Democratic", "Republican", "Economical", "Moral", "Ethical", "Union", "Unionist", "Revivalist", "Labor", "Monarchist", "Nationalist", "Reformist", "Public", "Freedom", "Security", "Patriotic", "Loyalist", "Liberty"},
				{"Party", "Group", "Front", "Coalition", "Force", "Alliance", "Caucus", "Fellowship", "Conference", "Forum", "Bureau"},
			},
			popCount = 0,
			popLimit = 2000,
			repGroups = {{"aium", "ium"}, {"iusy", "ia"}, {"oium", "ium"}, {"tyan", "tan"}, {"uium", "ium"}, {"aia", "ia"}, {"aie", "a"}, {"aio", "io"}, {"aiu", "a"}, {"ccc", "cc"}, {"dby", "dy"}, {"eia", "ia"}, {"eie", "e"}, {"eio", "io"}, {"eiu", "e"}, {"oia", "ia"}, {"oie", "o"}, {"oio", "io"}, {"oiu", "o"}, {"uia", "ia"}, {"uie", "u"}, {"uio", "io"}, {"uiu", "u"}, {"aa", "a"}, {"ae", "a"}, {"bd", "d"}, {"bp", "b"}, {"bt", "b"}, {"cd", "d"}, {"cg", "c"}, {"cj", "c"}, {"cp", "c"}, {"db", "b"}, {"df", "d"}, {"dg", "g"}, {"dj", "j"}, {"dk", "d"}, {"dl", "l"}, {"dt", "t"}, {"ee", "i"}, {"ei", "i"}, {"eu", "e"}, {"fd", "d"}, {"fh", "f"}, {"fj", "f"}, {"fv", "v"}, {"gc", "g"}, {"gd", "d"}, {"gj", "g"}, {"gk", "g"}, {"gl", "l"}, {"gt", "t"}, {"hc", "c"}, {"hg", "g"}, {"hj", "h"}, {"ie", "i"}, {"ii", "i"}, {"iy", "y"}, {"jb", "b"}, {"jc", "j"}, {"jd", "j"}, {"jg", "j"}, {"jr", "dr"}, {"js", "j"}, {"jt", "t"}, {"jz", "j"}, {"kc", "c"}, {"kd", "d"}, {"kg", "g"}, {"ki", "ci"}, {"kj", "k"}, {"lt", "l"}, {"mj", "m"}, {"mt", "m"}, {"nj", "ng"}, {"oa", "a"}, {"oe", "e"}, {"oi", "i"}, {"oo", "u"}, {"ou", "o"}, {"pb", "b"}, {"pg", "g"}, {"pj", "p"}, {"rz", "z"}, {"sj", "s"}, {"sz", "s"}, {"tb", "t"}, {"tc", "t"}, {"td", "t"}, {"tg", "t"}, {"tj", "t"}, {"tl", "l"}, {"tm", "t"}, {"tn", "t"}, {"tp", "t"}, {"tv", "t"}, {"ua", "a"}, {"ue", "e"}, {"ui", "i"}, {"uo", "o"}, {"uu", "u"}, {"vd", "v"}, {"vf", "f"}, {"vh", "v"}, {"vj", "v"}, {"vt", "t"}, {"wj", "w"}, {"yi", "y"}, {"zs", "z"}, {"zt", "t"}},
			royals = {},
			showinfo = 0,
			startyear = 1,
			systems = {
				{
					name="Democracy",
					ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Minister", "Speaker", "Prime Minister"},
					formalities={"Union", "Democratic Republic", "Free State", "Realm", "Electorate", "State"},
					dynastic=false
				},
				{
					name="Empire",
					ranks={"Homeless", "Citizen", "Mayor", "Lord", "Governor", "Viceroy", "Prince", "Emperor"},
					franks={"Homeless", "Citizen", "Mayor", "Lady", "Governor", "Vicereine", "Princess", "Empress"},
					formalities={"Empire", "Emirate", "Magistracy", "Imperium", "Supreme Crown", "Imperial Crown"},
					dynastic=true
				},
				{
					name="Monarchy",
					ranks={"Homeless", "Citizen", "Mayor", "Knight", "Lord", "Baron", "Viscount", "Earl", "Marquis", "Duke", "Prince", "King"},
					franks={"Homeless", "Citizen", "Mayor", "Dame", "Lady", "Baroness", "Viscountess", "Countess", "Marquess", "Duchess", "Princess", "Queen"},
					formalities={"Kingdom", "Crown", "Lordship", "Dominion", "High Kingship", "Domain"},
					dynastic=true
				},
				{
					name="Oligarchy",
					ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Minister", "Oligarch", "Premier"},
					formalities={"People's Republic", "Premiership", "Patriciate", "Autocracy", "Collective"},
					dynastic=false
				},
				{
					name="Republic",
					ranks={"Homeless", "Citizen", "Commissioner", "Mayor", "Councillor", "Governor", "Judge", "Senator", "Minister", "President"},
					formalities={"Republic", "United Republic", "Nation", "Commonwealth", "Federation", "Federal Republic"},
					dynastic=false
				}
			},
			thisWorld = {},
			vowels = {"a", "e", "i", "o", "u", "y"},
			writeMap = false,
			years = 1,
			yearstorun = 0,

			compLangs = function(self)
				local cArr = {}
				local regs = {}
				local testString = "The quick brown vixen and its master the mouse"
				local wCount = 0
				local _REVIEWING = true

				for x in testString:gmatch("%w+") do wCount = wCount+1 end
				for i, j in pairs(self.thisWorld.countries) do for k, l in pairs(j.regions) do regs[j.name.."!"..l.name] = j.name.."!"..l.name end end
				local rKeys = self:getAlphabetical(regs)

				for i=1,#rKeys do
					local key = regs[rKeys[i]]
					local country = self.thisWorld.countries[key:match("(%w+)!")]
					local region = country.regions[key:match("!(%w+)")]
					if region.language then table.insert(cArr, {country.demonym:upper(), region.language}) end
				end

				while _REVIEWING do
					local lnCount = 0
					UI:clear()
					local lastCountry = ""
					UI:printf(string.format("Translating the text \"%s.\"\n", testString))
					for i=1,#cArr do if lnCount < getLineTolerance(2) then
						local lang = cArr[i][2]
						if lang then
							if cArr[i][1] ~= lastCountry then
								UI:printf(cArr[i][1])
								lnCount = lnCount+1
								lastCountry = cArr[i][1]
							end
							local outString = ""
							local wIndex = 1
							for x in testString:gmatch("%w+") do if lang.wordTable[x:lower()] then
								if wIndex == 1 then
									local initWord = lang.wordTable[x:lower()]:gsub("^(%w)%w+", string.upper)..lang.wordTable[x:lower()]:gsub("^%w(%w+)", "%1")
									outString = outString..initWord:gsub(" ", "")
								else outString = outString..lang.wordTable[x:lower()]:gsub(" ", "") end
								if wIndex < wCount then outString = outString.." " end
								wIndex = wIndex+1
							end end
							UI:printf(string.format("\t%s: \"%s.\"", lang.name:match("%((%w+)%)"), outString))
							lnCount = lnCount+1
						end
					end end
					UI:printf("\nEnter B to return to the previous menu.")
					UI:printp(" > ")
					local datin = UI:readl()
					if datin:lower() == "b" then _REVIEWING = false end
				end
			end,

			deepcopy = function(self, obj)
				local t0 = _time()

				local res = nil
				local t = type(obj)
				local exceptions = {"spouse", "target", "__index"}

				if t == "table" then
					res = {}
					for i, j in pairs(obj) do
						local isexception = false
						for k=1,#exceptions do if exceptions[k] == tostring(i) then isexception = true end end
						if not isexception then res[self:deepcopy(i)] = self:deepcopy(j) end
					end
					if getmetatable(obj) then setmetatable(res, self:deepcopy(getmetatable(obj))) end
				elseif t == "function" then res = self:fncopy(obj)
				else res = obj end

				if _DEBUG then
					if not debugTimes["CCSCommon.deepcopy"] then debugTimes["CCSCommon.deepcopy"] = 0 end
					debugTimes["CCSCommon.deepcopy"] = debugTimes["CCSCommon.deepcopy"]+_time()-t0
				end

				return res
			end,

			deepnil = function(self, obj)
				local t0 = _time()

				if type(obj) == "table" then for i, j in pairs(obj) do
					self:deepnil(j)
					j = nil
				end end

				if _DEBUG then
					if not debugTimes["CCSCommon.deepnil"] then debugTimes["CCSCommon.deepnil"] = 0 end
					debugTimes["CCSCommon.deepnil"] = debugTimes["CCSCommon.deepnil"]+_time()-t0
				end

				obj = nil
			end,

			demonym = function(self, nom)
				if not nom then return "" end
				local dem = ""

				if nom:sub(nom:len(), nom:len()) == "a" then dem = nom.."n"
				elseif nom:sub(nom:len(), nom:len()) == "y" then
					local split = nom:sub(1, nom:len()-1)
					if split:sub(split:len(), split:len()) == "y" then dem = split:sub(1, split:len()-1)
					elseif split:sub(split:len(), split:len()) == "s" then dem = split:sub(1, split:len()-1).."ian"
					elseif split:sub(split:len(), split:len()) == "b" then dem = split.."ian"
					elseif split:sub(split:len(), split:len()) == "d" then dem = split.."ish"
					elseif split:sub(split:len(), split:len()) == "f" then dem = split.."ish"
					elseif split:sub(split:len(), split:len()) == "g" then dem = split.."ian"
					elseif split:sub(split:len(), split:len()) == "h" then dem = split.."ian"
					elseif split:sub(split:len(), split:len()) == "a" then dem = split.."n"
					elseif split:sub(split:len(), split:len()) == "e" then dem = split.."n"
					elseif split:sub(split:len(), split:len()) == "i" then dem = split.."n"
					elseif split:sub(split:len(), split:len()) == "o" then dem = split.."n"
					elseif split:sub(split:len(), split:len()) == "u" then dem = split.."n"
					elseif split:sub(split:len(), split:len()) == "l" then dem = split.."ish"
					elseif split:sub(split:len(), split:len()) == "w" then dem = split.."ian"
					elseif split:sub(split:len(), split:len()) == "k" then dem = split:sub(1, split:len()-1).."cian"
					else dem = split end
				elseif nom:sub(nom:len(), nom:len()) == "e" then dem = nom:sub(1, nom:len()-1).."ish"
				elseif nom:sub(nom:len(), nom:len()) == "c" then dem = nom:sub(1, nom:len()-2).."ian"
				elseif nom:sub(nom:len(), nom:len()) == "s" then
					if nom:sub(nom:len()-2, nom:len()) == "ius" then dem = nom:sub(1, nom:len()-2).."an"
					else dem = nom:sub(1, nom:len()-2).."ian" end
				elseif nom:sub(nom:len(), nom:len()) == "i" then dem = nom.."an"
				elseif nom:sub(nom:len(), nom:len()) == "o" then dem = nom:sub(1, nom:len()-1).."ian"
				elseif nom:sub(nom:len(), nom:len()) == "k" then
					if nom:sub(nom:len()-1, nom:len()-1) == "c" then dem = nom:sub(1, nom:len()-1).."ian"
					else dem = nom:sub(1, nom:len()-1).."cian" end
				elseif nom:sub(nom:len()-3, nom:len()) == "land" then
					local split = nom:sub(1, nom:len()-4)
					if split:sub(split:len(), split:len()) == "a" then dem = split.."n"
					elseif split:sub(split:len(), split:len()) == "y" then dem = split:sub(1, split:len()-1)
					elseif split:sub(split:len(), split:len()) == "c" then dem = split:sub(1, split:len()-1).."ian"
					elseif split:sub(split:len(), split:len()) == "s" then dem = split:sub(1, split:len()-1).."ian"
					elseif split:sub(split:len(), split:len()) == "i" then dem = split.."an"
					elseif split:sub(split:len(), split:len()) == "o" then dem = split:sub(1, split:len()-1).."ian"
					elseif split:sub(split:len(), split:len()) == "g" then dem = split.."lish"
					elseif split:sub(split:len(), split:len()) == "k" then dem = split:sub(1, split:len()-1).."cian"
					else dem = split.."ish" end
				else
					if nom:sub(nom:len()-1, nom:len()) == "ia" then dem = nom.."n"
					elseif nom:sub(nom:len()-2, nom:len()) == "ian" then dem = nom
					elseif nom:sub(nom:len()-1, nom:len()) == "an" then dem = nom.."ese"
					elseif nom:sub(nom:len()-2, nom:len()) == "iar" then dem = nom:sub(1, nom:len()-1).."n"
					elseif nom:sub(nom:len()-1, nom:len()) == "ar" then dem = nom:sub(1, nom:len()-2).."ian"
					elseif nom:sub(nom:len()-2, nom:len()) == "ium" then dem = nom:sub(1, nom:len()-2).."an"
					elseif nom:sub(nom:len()-1, nom:len()) == "um" then dem = nom:sub(1, nom:len()-2).."ian"
					elseif nom:sub(nom:len()-1, nom:len()) == "en" then dem = nom:sub(1, nom:len()-2).."ian"
					elseif nom:sub(nom:len()-1, nom:len()) == "un" then dem = nom:sub(1, nom:len()-2).."ian"
					else dem = nom.."ian" end
				end

				for i=1,2 do for j, k in pairs(self.repGroups) do dem = dem:gsub(k[1], k[2]) end end

				return dem
			end,

			directory = function(self, names)
				if not names or type(names) ~= "table" or #names == 0 then return "" end
				local strOut = ""
				if UI.clrcmd == "clear" then strOut = "."..self.dirSeparator end
				for i=1,#names-1 do strOut = strOut..names[i]..self.dirSeparator end
				strOut = strOut..names[#names]
				return strOut
			end,

			finish = function(self, destroy)
				if destroy then UI:clear() end

				UI:printf("\nPrinting result...")
				local of = io.open(self:directory({self.stamp, "events.txt"}), "w+")

				local cKeys = self:getAlphabetical(self.final)
				for i=1,#cKeys do
					local cp = nil
					for j, k in pairs(self.final) do if k.name == cKeys[i] then cp = k end end
					if cp then
						local newc = false
						local pr = 1
						of:write("Country: "..cp.name.."\nFounded: "..cp.founded..", survived for "..tostring(cp.age).." years\n\n")

						local rWritten = 1
						local rDone = {}

						for k=1,#cp.events do if pr == 1 and cp.events[k].Event:sub(1, 12) == "Independence" and cp.events[k].Year <= cp.founded+1 then
							newc = true
							pr = tonumber(cp.events[k].Year)
						end end

						if newc then
							of:write(self:getRulerString(cp.rulers[1]).."\n")
							local nextFound = false
							for k=1,#cp.rulers do
								if tonumber(cp.rulers[k].From) < pr and cp.rulers[k].Country ~= cp.name and not nextFound then if tostring(cp.rulers[k].To) == "Current" or tonumber(cp.rulers[k].To) and tonumber(cp.rulers[k].To) >= pr then
									nextFound = true
									of:write("...\n")
									of:write(self:getRulerString(cp.rulers[k]).."\n")
									k = #cp.rulers+1
								end end
							end
						end

						for j=1,self.years do
							for k=1,#cp.events do if tonumber(cp.events[k].Year) == j and cp.events[k].Event:sub(1, 10) == "Revolution" then of:write(cp.events[k].Year..": "..cp.events[k].Event.."\n") end end

							for k=1,#cp.rulers do if tonumber(cp.rulers[k].From) == j and cp.rulers[k].Country == cp.name and not rDone[self:getRulerString(cp.rulers[k])] then
								of:write(rWritten..". "..self:getRulerString(cp.rulers[k]).."\n")
								rWritten = rWritten+1
								rDone[self:getRulerString(cp.rulers[k])] = true
							end end

							for k=1,#cp.events do if tonumber(cp.events[k].Year) == j and cp.events[k].Event:sub(1, 10) ~= "Revolution" then of:write(cp.events[k].Year..": "..cp.events[k].Event.."\n") end end
						end

						of:write("\n\n\n")
					end
				end

				of:flush()
				of:close()
				of = nil
			end,

			fncopy = function(self, fn)
				local dumped = string.dump(fn)
				local cloned = loadstring(dumped)
				local i = 1
				while true do
					local name = debug.getupvalue(fn, i)
					if not name then break end
					debug.upvaluejoin(cloned, i, fn, i)
					i = i+1
				end
				return cloned
			end,

			fromFile = function(self, datin)
				UI:printf("Opening data file...")
				local f = assert(io.open(datin, "r"))
				local done = false
				local fc = nil
				local fr = nil
				local sysChange = true
				self.thisWorld = World:new()

				UI:printf("Reading data file...")

				while not done do
					local l = f:read()
					if not l then done = true
					else
						local mat = {}
						for q in l:gmatch("%S+") do table.insert(mat, tostring(q)) end
						if mat[1] == "Year" then
							self.startyear = tonumber(mat[2])
							self.years = tonumber(mat[2])
						elseif mat[1] == "Disable" then
							local sEvent = mat[2]
							for q=3,#mat do sEvent = sEvent.." "..mat[q] end
							self.disabled["!"..sEvent:lower()] = true
						elseif mat[1] == "C" then
							local nl = Country:new()
							nl.name = mat[2]
							for q=3,#mat do nl.name = nl.name.." "..mat[q] end
							for q=1,#self.systems do nl.snt[self.systems[q].name] = 0 end
							nl.system = -1
							self.thisWorld:add(nl)
							fc = nl
						elseif mat[1] == "R" then
							local r = Region:new()
							r.name = mat[2]
							for q=3,#mat do r.name = r.name.." "..mat[q] end
							fc.regions[r.name] = r
							fr = r
						elseif mat[1] == "S" or mat[1] == "P" then
							local s = City:new()
							s.name = mat[2]
							for q=3,#mat do s.name = s.name.." "..mat[q] end
							fr.cities[s.name] = s
							if mat[1] == "P" then
								fc.capitalregion = fr.name
								fc.capitalcity = s.name
							end
						else
							local counter = ""
							local number = 1
							local gend = "M"
							local to = self.years
							local oldsystem = fc.system
							if mat[1] == "Prime" and mat[2] == "Minister" then
								mat[1] = "Prime Minister"
								for i=2,#mat-1 do mat[i] = mat[i+1] end
								mat[#mat] = nil
							end
							if mat[1] == "President" then fc.system = 5
							elseif mat[1] == "Prime Minister" then fc.system = 1
							elseif mat[1] == "Premier" then fc.system = 4
							elseif mat[1] == "King" then
								counter = "Queen"
								fc.system = 3
							elseif mat[1] == "Emperor" then
								counter = "Empress"
								fc.system = 2
							elseif mat[1] == "Queen" then
								counter = "King"
								fc.system = 3
								gend = "F"
							elseif mat[1] == "Empress" then
								counter = "Emperor"
								fc.system = 2
								gend = "F"
							end
							if oldsystem ~= fc.system then fc.snt[self.systems[fc.system].name] = fc.snt[self.systems[fc.system].name]+1 end
							if self.systems[fc.system].dynastic then
								for i=1,#fc.rulers do if fc.rulers[i].dynastic and fc.rulers[i].name == mat[2] then if fc.rulers[i].title == mat[1] or fc.rulers[i].title == counter then number = number+1 end end end
								table.insert(fc.rulers, {dynastic=true, title=mat[1], name=mat[2], number=tostring(number), From=mat[3], To=mat[4], Country=fc.name})

								local found = false
								if gend == "M" then for i, cp in pairs(fc.rulernames) do if cp == mat[2] then found = true end end
								elseif gend == "F" then for i, cp in pairs(fc.frulernames) do if cp == mat[2] then found = true end end end
								if not found then
									if gend == "F" then table.insert(fc.frulernames, mat[2])
									else table.insert(fc.rulernames, mat[2]) end
								end
							else table.insert(fc.rulers, {dynastic=false, title=mat[1], name=mat[2], surname=mat[3], number=mat[3], From=mat[4], To=mat[5], Country=fc.name}) end
						end
					end
				end

				f:close()
				f = nil

				self:getAlphabetical()

				UI:printf("Constructing initial populations...\n")
				self.thisWorld.numCountries = 0
				local cDone = 0

				for i, cp in pairs(self.thisWorld.countries) do if cp then self.thisWorld.numCountries = self.thisWorld.numCountries+1 end end
				for i, cp in pairs(self.thisWorld.countries) do
					if cp then
						if #cp.rulers > 0 then
							cp.founded = tonumber(cp.rulers[1].From)
							cp.age = self.years-cp.founded
						else
							cp.founded = self.years
							cp.age = 0
							cp.system = math.random(1, #self.systems)
							cp.snt[self.systems[cp.system].name] = cp.snt[self.systems[cp.system].name]+1
						end

						cp:makename(self, 3)
						if _DEBUG then cp:setPop(self, 100) else cp:setPop(self, 300) end

						self.final[cp.name] = cp
					end

					cDone = cDone+1
					UI:printl(string.format("Country %d/%d", cDone, self.thisWorld.numCountries))
				end

				self.thisWorld.initialState = false
				self.thisWorld.fromFile = true
			end,

			generationString = function(self, n, gender)
				local msgout = ""

				if n > 1 then
					if n > 2 then
						if n > 3 then
							if n > 4 then msgout = tostring(n-2).."-times-great-grand"
							else msgout = "great-great-grand" end
						else msgout = "great-grand" end
					else msgout = "grand" end
				end

				if gender == "M" then msgout = msgout.."son" else msgout = msgout.."daughter" end
				return msgout
			end,

			getAllyOngoing = function(self, country, target, event)
				local acOut = {}

				local ac = #country.alliances
				for i=1,ac do
					local c3 = nil
					for j, cp in pairs(self.thisWorld.countries) do if cp.name == country.alliances[i] then c3 = cp end end
					if c3 then for j=#c3.allyOngoing,1,-1 do if c3.allyOngoing[j] == event.."?"..country.name..":"..target.name then table.insert(acOut, c3) end end end
				end

				return acOut
			end,

			getAlphabetical = function(self, t)
				local data = t
				if not t then data = self.thisWorld.countries end
				local cKeys = {}
				for i, cp in pairs(data) do
					if #cKeys ~= 0 then
						local found = false
						for j=1,#cKeys do if not found then
							local ind = 1
							local chr1 = string.byte(tostring(cKeys[j]):sub(ind, ind):lower())
							local chr2 = string.byte(tostring(i):sub(ind, ind):lower())
							while chr1 and chr2 and chr2 == chr1 do
								ind = ind+1
								chr1 = string.byte(tostring(cKeys[j]):sub(ind, ind):lower())
								chr2 = string.byte(tostring(i):sub(ind, ind):lower())
							end
							if not chr1 then
								table.insert(cKeys, j+1, i)
								found = true
							elseif not chr2 then
								table.insert(cKeys, j, i)
								found = true
							elseif chr2 < chr1 then
								table.insert(cKeys, j, i)
								found = true
							end
						end end
						if not found then table.insert(cKeys, i) end
					else table.insert(cKeys, i) end
				end

				if not t then self.alpha = cKeys end
				return cKeys
			end,

			getLanguage = function(self, id, nl)
				for i=1,#self.languages do if self.languages[i].name == id then return self.languages[i] end end

				if nl then
					if not nl.language then
						local newLang = Language:new()
						newLang:define(self)
						self:setLanguage(nl, nil, newLang)
					end

					for i, j in pairs(nl.regions) do if not j.language then
						local langID = nl.demonym.." ("..self:demonym(j.name)..")"
						found = false
						for i=1,#self.languages do if not found and self.languages[i].name == langID then
							found = true
							j.language = self.languages[i]
						end end
						if not found then self:setLanguage(nl, j, nl.language:deviate(self, 0.06)) end
					end end

					for i=#self.languages,1,-1 do if self.languages[i].name == id then return self.languages[i] end end
				end

				return nil
			end,

			getRulerString = function(self, data)
				local rString = ""
				if data then
					rString = data.title

					if data.rulerName and data.rulerName ~= "" then rString = rString.." "..data.rulerName else rString = rString.." "..data.name end

					if tonumber(data.number) and tonumber(data.number) ~= 0 then
						rString = rString.." "..self:roman(data.number)
						if data.surname then rString = rString.." ("..data.surname..")" end
					elseif data.surname then rString = rString.." "..data.surname end

					if data.Country then rString = rString.." of "..data.Country.." ("..tostring(data.From).." - "..tostring(data.To)..")"
					else rString = rString.." of "..data.nationality end
				else rString = "None" end

				return rString
			end,

			getRulerStringShort = function(self, data)
				local rString = ""
				if data then
					rString = data.title

					if data.rulerName and data.rulerName ~= "" then rString = rString.." "..data.rulerName else rString = rString.." "..data.name end

					if tonumber(data.number) and tonumber(data.number) ~= 0 then
						rString = rString.." "..self:roman(data.number)
						if data.surname then rString = rString.." ("..data.surname..")" end
					elseif data.surname then rString = rString.." "..data.surname end

					if data.From then rString = rString.." ("..tostring(data.From).." - p.)" end
				else rString = "None" end

				return rString
			end,

			loop = function(self)
				local _running = true
				local remainingYears = 1
				local msg = ""
				local cLimit = 16
				local eLimit = 6

				if UI.clrcmd == "cls" then self.dirSeparator = "\\" end
				local mapDir = self:directory({self.stamp, "maps"})
				os.execute("mkdir "..self:directory({self.stamp}))
				if self.doMaps then os.execute("mkdir "..mapDir) end
				self.thisWorld:mapOutput(self, self:directory({mapDir, "initial"}))

				collectgarbage("collect")

				while _running do
					self.thisWorld:update(self)

					for i, cp in pairs(self.thisWorld.countries) do
						for j, k in pairs(self.final) do if k.name == cp.name then self.final[j] = nil end end
						self.final[cp.name] = cp
					end

					local t0 = _time()
					msg = ("Year %d: %d countries - Global Population %d, Cumulative Total %d - Memory Usage (MB): %d\n\n"):format(self.years, self.thisWorld.numCountries, self.thisWorld.gPop, self.popCount, collectgarbage("count")/1024)

					if self.showinfo == 1 then
						local currentEvents = {}
						local cCount = 0
						local eCount = 0
						local names = {}
						local longestName = -1
						local longestNameN = -1
						local stats = {}
						local longestStat = -1
						local longestStatN = -1
						local rulers = {}

						for i=#self.alpha,1,-1 do
							local cp = self.thisWorld.countries[self.alpha[i]]
							if cp then for j=1,#cp.ongoing do if cp.ongoing[j].eString then table.insert(currentEvents, cp.ongoing[j].eString) end end else table.remove(self.alpha, i) end
						end

						if cursesstatus then
							cLimit = getLineTolerance(#currentEvents+5)
							if #currentEvents == 0 then cLimit = cLimit-1 end
							if cLimit < math.floor(UI.y/2) then cLimit = math.floor(UI.y/2) end
							eLimit = getLineTolerance(cLimit+5)
						end

						for i=1,#self.alpha do
							local cp = self.thisWorld.countries[self.alpha[i]]
							if cCount < cLimit or cCount == self.thisWorld.numCountries then
								local name = ""
								if cp.snt[self.systems[cp.system].name] > 1 then name = name..("%s "):format(self:ordinal(cp.snt[self.systems[cp.system].name])) end
								local sysName = self.systems[cp.system].name
								if cp.dfif[sysName] then name = name..("%s %s"):format(cp.demonym, cp.formalities[self.systems[cp.system].name]) else name = name..("%s of %s"):format(cp.formalities[self.systems[cp.system].name], cp.name) end
								local stat = (" - Pop. %d, Str. %d, Stabil. %d"):format(cp.population, cp.strength, cp.stability)
								local ruler = (" - %s\n"):format(self:getRulerString(cp.rulers[#cp.rulers]))
								table.insert(names, name)
								table.insert(stats, stat)
								table.insert(rulers, ruler)
								cCount = cCount+1
							else i = #self.alpha+1 end
						end

						for i=1,#names do
							if names[i]:len() > longestNameN then
								longestName = i
								longestNameN = names[i]:len()
							end

							if stats[i]:len() > longestStatN then
								longestStat = i
								longestStatN = stats[i]:len()
							end
						end

						for i=1,#names do
							msg = msg..names[i]
							for j=1,longestNameN-names[i]:len() do msg = msg.." " end
							msg = msg..stats[i]
							for j=1,longestStatN-stats[i]:len() do msg = msg.." " end
							msg = msg..rulers[i]
						end

						if cCount < self.thisWorld.numCountries then msg = msg..("[+%d more]\n"):format(self.thisWorld.numCountries-cCount) end

						msg = msg.."\nOngoing events:"

						for i=1,#currentEvents do
							if eCount < eLimit or eCount == #currentEvents then
								msg = msg..("\n%s"):format(currentEvents[i])
								eCount = eCount+1
							end
						end

						if #currentEvents == 0 then msg = msg.."\nNone"
						elseif eCount < #currentEvents then msg = msg..("\n[+%d more]"):format(#currentEvents-eCount) end

						msg = msg.."\n"

						self:deepnil(currentEvents)
						self:deepnil(names)
						self:deepnil(stats)
						self:deepnil(rulers)
					end

					local t1 = _time()

					if self.writeMap then
						self.thisWorld:mapOutput(self, self:directory({self.stamp, "maps", "Year "..tostring(self.years)}))
						local t2 = _time()
						collectgarbage("collect")
						local t3 = _time()
						if _DEBUG then
							if not debugTimes["GARBAGE"] then debugTimes["GARBAGE"] = 0 end
							debugTimes["GARBAGE"] = debugTimes["GARBAGE"]+t3-t2
						end
					end
					self.writeMap = false
					self.thisWorld.mapChanged = false

					if _DEBUG then
						msg = msg.."\n"
						debugTimes["PRINT"] = t1-t0
						debugTimes["TOTAL"] = _time()-t0
						for ln, j in pairs(self:getAlphabetical(debugTimes)) do msg = msg..("%s: %.3f\n"):format(j, debugTimes[j]) end
					end

					UI:clear(true)
					UI:printc(msg)
					UI:refresh()

					self.years = self.years+1
					remainingYears = remainingYears-1

					while remainingYears <= 0 do
						UI:printf("\nEnter a number of years to continue, or:")
						if _DEBUG then UI:printf("E to execute a line of Lua code.") end
						UI:printf("G to record the family and relationship data at this point.")
						UI:printf("L to compare the languages of this world.")
						UI:printf("R to record the event data at this point.")
						UI:printf("Q to exit.")
						UI:printp("\n > ")
						local datin = UI:readl()
						if tonumber(datin) then remainingYears = tonumber(datin)
						elseif datin:lower() == "e" and _DEBUG then debugLine()
						elseif datin:lower() == "g" then self:writeGed()
						elseif datin:lower() == "l" then self:compLangs()
						elseif datin:lower() == "r" then self:finish(false)
						elseif datin:lower() == "q" then
							_running = false
							remainingYears = 1
						end

						if datin:lower() ~= "q" then
							UI:clear(true)
							UI:printc(msg)
							UI:refresh()
						end
					end
				end

				self.thisWorld:mapOutput(self, self:directory({self.stamp, "maps", "final"}))
				self:finish(true)
				self:writeGed()

				UI:printf("\nEnd Simulation!")
			end,

			name = function(self, personal, l, m)
				local t0 = _time()

				local nom = ""
				local length = 0
				length = math.random(m or 1, l or 3)

				nom = self:randomChoice(self.initialgroups)
				local groups = 1
				while groups < length do
					local mid = self:randomChoice(self.middlegroups)

					nom = nom..mid:lower()
					groups = groups+1
				end

				nom = self:namecheck(nom)

				if not personal then
					local ending = self:randomChoice(self.endgroups)
					local oldnom = nom
					local oldend = ending
					local fin = false
					while not fin do
						local lc = nom:sub(nom:len(), nom:len())
						local fc = ending:sub(1, 1)
						if lc == fc then nom = nom:sub(1, nom:len()-1) end
						if ending == "y" then
							lc = nom:sub(nom:len(), nom:len())
							for i=1,#self.vowels do if lc == self.vowels[i] then ending = "ny" end end
						elseif ending == "es" then
							lc = nom:sub(nom:len(), nom:len())
							for i=1,#self.vowels do if lc == self.vowels[i] then ending = "nes" end end
						elseif ending == "tria" then
							lc = nom:sub(nom:len(), nom:len())
							for i=1,#self.consonants do if lc == self.consonants[i] then ending = "itria" end end
						elseif ending == "tra" then
							lc = nom:sub(nom:len(), nom:len())
							for i=1,#self.consonants do if lc == self.consonants[i] then ending = "itra" end end
						end
						fin = true
						if oldnom ~= nom or oldend ~= ending then
							fin = false
							oldnom = nom
							oldend = ending
						end
					end
					nom = nom..ending:lower()
					for i=1,2 do for j, k in pairs(self.repGroups) do nom = nom:gsub(k[1], k[2]) end end
				end

				if _DEBUG then
					if not debugTimes["CCSCommon.name"] then debugTimes["CCSCommon.name"] = 0 end
					debugTimes["CCSCommon.name"] = debugTimes["CCSCommon.name"]+_time()-t0
				end

				return nom
			end,

			namecheck = function(self, nom)
				local t0 = _time()

				local nomin = nom:lower()
				local check = true
				while check do
					check = false
					local nomlower = nomin

					for i=1,nomlower:len()-1 do
						if nomlower:sub(i, i) == nomlower:sub(i+1, i+1) then
							local newnom = ""

							for j=1,i do newnom = newnom..nomlower:sub(j, j) end
							for j=i+2,nomlower:len() do newnom = newnom..nomlower:sub(j, j) end

							nomlower = newnom
						end

						if i < nomlower:len()-1 then
							local hasvowel = false

							for j=i,i+2 do
								for k=1,#self.vowels do if nomlower:sub(j, j) == self.vowels[k] then hasvowel = true end end

								if j > 1 and nomlower:sub(j-1, j-1) == 't' and nomlower:sub(j, j) == 'h' then -- Make an exception for the 'th' group, but only if there's a vowel close by.
									local prev = ""
									local fore = ""
									if j > 2 then prev = nomlower:sub(j-2, j-2) end
									if j < nomlower:len() then fore = nomlower:sub(j+1, j+1) end
									for k=1,#self.vowels do if fore == self.vowels[k] or prev == self.vowels[k] then
										hasvowel = true
										k = #self.vowels
									end end
								end
							end

							if not hasvowel then
								local newnom = nomlower:sub(1, i+1)..self:randomChoice(self.vowels)..nomlower:sub(i+3, nomlower:len())
								nomlower = newnom
							end
						end

						if i < nomlower:len()-2 and nomlower:sub(i, i+1) == nomlower:sub(i+2, i+3) then
							local newnom = nomlower:sub(1, i+1)..nomlower:sub(i+4, nomlower:len())
							nomlower = newnom
						end

						if i < nomlower:len()-4 and nomlower:sub(i, i+2) == nomlower:sub(i+3, i+5) then
							local newnom = nomlower:sub(1, i+2)..nomlower:sub(i+6, nomlower:len())
							nomlower = newnom
						end
					end

					for j=1,#self.consonants do
						if nomlower:sub(1, 1) == self.consonants[j] then
							local n2 = nomlower:sub(2, 2)
							if n2 == "b" then nomlower = nomlower:sub(2, nomlower:len())
							elseif n2 == "c" then nomlower = nomlower:sub(2, nomlower:len())
							elseif n2 == "d" then nomlower = nomlower:sub(2, nomlower:len())
							elseif n2 == "f" then nomlower = nomlower:sub(2, nomlower:len())
							elseif n2 == "g" then nomlower = nomlower:sub(2, nomlower:len())
							elseif n2 == "j" then nomlower = nomlower:sub(2, nomlower:len())
							elseif n2 == "k" then nomlower = nomlower:sub(2, nomlower:len())
							elseif n2 == "m" then nomlower = nomlower:sub(2, nomlower:len())
							elseif n2 == "n" then nomlower = nomlower:sub(2, nomlower:len())
							elseif n2 == "p" then nomlower = nomlower:sub(2, nomlower:len())
							elseif n2 == "s" then nomlower = nomlower:sub(2, nomlower:len())
							elseif n2 == "t" then nomlower = nomlower:sub(2, nomlower:len())
							elseif n2 == "v" then nomlower = nomlower:sub(2, nomlower:len())
							elseif n2 == "z" then nomlower = nomlower:sub(2, nomlower:len()) end
						end

						if nomlower:sub(nomlower:len(), nomlower:len()) == self.consonants[j] then
							local n2 = nomlower:sub(nomlower:len(), nomlower:len())
							if n2 == "b" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "c" and nomlower:sub(nomlower:len(), nomlower:len()) ~= "h" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "d" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "f" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "g" and nomlower:sub(nomlower:len(), nomlower:len()) ~= "h" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "h" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "j" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "k" and nomlower:sub(nomlower:len(), nomlower:len()) ~= "h" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "m" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "n" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "p" and nomlower:sub(nomlower:len(), nomlower:len()) ~= "h" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "s" and nomlower:sub(nomlower:len(), nomlower:len()) ~= "h" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "t" and nomlower:sub(nomlower:len(), nomlower:len()) ~= "h" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "v" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "w" then nomlower = nomlower:sub(1, nomlower:len()-1)
							elseif n2 == "z" and nomlower:sub(nomlower:len(), nomlower:len()) ~= "h" then nomlower = nomlower:sub(1, nomlower:len()-1) end
						end
					end

					if nomlower:sub(nomlower:len(), nomlower:len()) == "j" then nomlower = nomlower:sub(1, nomlower:len()-1)
					elseif nomlower:sub(nomlower:len(), nomlower:len()) == "v" then nomlower = nomlower:sub(1, nomlower:len()-1)
					elseif nomlower:sub(nomlower:len(), nomlower:len()) == "w" then nomlower = nomlower:sub(1, nomlower:len()-1) end

					while nomlower:len() < 3 do nomlower = nomlower..string.lower(self:randomChoice(self:randomChoice({self.consonants, self.vowels}))) end

					for j, k in pairs(self.repGroups) do nomlower = nomlower:gsub(k[1], k[2]) end

					if nomlower ~= nomin then check = true end
					nomin = nomlower
				end

				nomin = nomin:gsub("^%w", string.upper):gsub("%-%w", string.upper)

				if _DEBUG then
					if not debugTimes["CCSCommon.namecheck"] then debugTimes["CCSCommon.namecheck"] = 0 end
					debugTimes["CCSCommon.namecheck"] = debugTimes["CCSCommon.namecheck"]+_time()-t0
				end

				return nomin
			end,

			ordinal = function(self, n)
				local tmp = tonumber(n)
				if not tmp then return n end
				local fin = ""

				local ts = tostring(n)
				if ts:sub(ts:len(), ts:len()) == "1" then
					if ts:sub(ts:len()-1, ts:len()-1) == "1" then fin = ts.."th"
					else fin = ts.."st" end
				elseif ts:sub(ts:len(), ts:len()) == "2" then
					if ts:sub(ts:len()-1, ts:len()-1) == "1" then fin = ts.."th"
					else fin = ts.."nd" end
				elseif ts:sub(ts:len(), ts:len()) == "3" then
					if ts:sub(ts:len()-1, ts:len()-1) == "1" then fin = ts.."th"
					else fin = ts.."rd" end
				else fin = ts.."th" end

				return fin
			end,

			randomChoice = function(self, t, doKeys)
				local t0 = _time()

				local keys = {}
				if t and t[1] then if doKeys then return math.random(1, #t) else return t[math.random(1, #t)] end end
				for key, value in pairs(t) do table.insert(keys, key) end
				if #keys == 0 then return nil
				elseif #keys == 1 then if doKeys then return keys[1] else return t[keys[1]] end end
				local index = keys[math.random(1, #keys)]
				if doKeys then return index else return t[index] end

				if _DEBUG then
					if not debugTimes["CCSCommon.randomChoice"] then debugTimes["CCSCommon.randomChoice"] = 0 end
					debugTimes["CCSCommon.randomChoice"] = debugTimes["CCSCommon.randomChoice"]+_time()-t0
				end
			end,

			regionTransfer = function(self, c1, c2, r, conq)
				if c1 and c2 then
					local rCount = 0
					for i, j in pairs(c2.regions) do rCount = rCount+1 end

					local lim = 1
					if conq then lim = 0 end

					if rCount > lim and c2.regions[r] then
						local rn = c2.regions[r]

						for i=#c2.people,1,-1 do if c2.people[i] and c2.people[i].region and c2.people[i].region.name == rn.name and not c2.people[i].isruler then c1:add(self, c2.people[i]) end end

						c1.regions[rn.name] = rn
						c2.regions[rn.name] = nil

						for i=1,#self.thisWorld.planetdefined do
							local x, y, z = table.unpack(self.thisWorld.planetdefined[i])

							if self.thisWorld.planet[x][y][z].country == c2.name and self.thisWorld.planet[x][y][z].region == rn.name then
								self.thisWorld.planet[x][y][z].country = c1.name
								self.thisWorld.planet[x][y][z].region = rn.name
							end
						end

						for i=#c2.nodes,1,-1 do
							local x, y, z = table.unpack(c2.nodes[i])
							if self.thisWorld.planet[x][y][z].country == c1.name then
								local rn = table.remove(c2.nodes, i)
								rn = nil
							end
						end

						if not conq and c2.capitalregion == rn.name then
							local msg = "Capital moved from "..c2.capitalcity.." to "

							c2.capitalregion = self:randomChoice(c2.regions).name
							c2.capitalcity = self:randomChoice(c2.regions[c2.capitalregion].cities, true)

							msg = msg..c2.capitalcity
							c2:event(self, msg)
						end

						local gainMsg = "Gained the "..rn.name.." region "
						local lossMsg = "Loss of the "..rn.name.." region "

						local cCount = 0
						for i, j in pairs(rn.cities) do cCount = cCount+1 end
						if cCount > 0 then
							gainMsg = gainMsg.."(including the "
							lossMsg = lossMsg.."(including the "

							if cCount > 1 then
								if cCount == 2 then
									gainMsg = gainMsg.."cities of "
									lossMsg = lossMsg.."cities of "
									local index = 1
									for i, j in pairs(rn.cities) do
										if index ~= cCount then
											gainMsg = gainMsg..j.name.." "
											lossMsg = lossMsg..j.name.." "
										end
										index = index+1
									end
									index = 1
									for i, j in pairs(rn.cities) do
										if index == cCount then
											gainMsg = gainMsg.."and "..j.name
											lossMsg = lossMsg.."and "..j.name
										end
										index = index+1
									end
								else
									gainMsg = gainMsg.."cities of "
									lossMsg = lossMsg.."cities of "
									local index = 1
									for i, j in pairs(rn.cities) do
										if index < cCount-1 then
											gainMsg = gainMsg..j.name..", "
											lossMsg = lossMsg..j.name..", "
										end
										index = index+1
									end
									index = 1
									for i, j in pairs(rn.cities) do
										if index == cCount-1 then
											gainMsg = gainMsg..j.name.." "
											lossMsg = lossMsg..j.name.." "
										end
										index = index+1
									end
									index = 1
									for i, j in pairs(rn.cities) do
										if index == cCount then
											gainMsg = gainMsg.."and "..j.name
											lossMsg = lossMsg.."and "..j.name
										end
										index = index+1
									end
								end
							else for i, j in pairs(rn.cities) do
								gainMsg = gainMsg.."city of "..j.name
								lossMsg = lossMsg.."city of "..j.name
							end end

							gainMsg = gainMsg..") "
							lossMsg = lossMsg..") "
						end

						gainMsg = gainMsg.."from "..c2.name
						lossMsg = lossMsg.."to "..c1.name

						c1:event(self, gainMsg)
						c2:event(self, lossMsg)

						self.writeMap = true
						self.thisWorld.mapChanged = true
					end
				end
			end,

			removeAllyOngoing = function(self, country, target, event)
				local ac = #country.alliances
				for i=1,ac do
					local c3 = nil
					for j, cp in pairs(self.thisWorld.countries) do if cp.name == country.alliances[i] then c3 = cp end end
					if c3 then for j=#c3.allyOngoing,1,-1 do if c3.allyOngoing[j] == event.."?"..country.name..":"..target.name then table.remove(c3.allyOngoing, j) end end end
				end
			end,

			roman = function(self, n)
				local tmp = tonumber(n)
				if not tmp then return n end
				local fin = ""

				while tmp-1000 > -1 do
					fin = fin.."M"
					tmp = tmp-1000
				end

				while tmp-900 > -1 do
					fin = fin.."CM"
					tmp = tmp-900
				end

				while tmp-500 > -1 do
					fin = fin.."D"
					tmp = tmp-500
				end

				while tmp-400 > -1 do
					fin = fin.."CD"
					tmp = tmp-400
				end

				while tmp-100 > -1 do
					fin = fin.."C"
					tmp = tmp-100
				end

				while tmp-90 > -1 do
					fin = fin.."XC"
					tmp = tmp-90
				end

				while tmp-50 > -1 do
					fin = fin.."L"
					tmp = tmp-50
				end

				while tmp-40 > -1 do
					fin = fin.."XL"
					tmp = tmp-40
				end

				while tmp-10 > -1 do
					fin = fin.."X"
					tmp = tmp-10
				end

				while tmp-9 > -1 do
					fin = fin.."IX"
					tmp = tmp-9
				end

				while tmp-5 > -1 do
					fin = fin.."V"
					tmp = tmp-5
				end

				while tmp-4 > -1 do
					fin = fin.."IV"
					tmp = tmp-4
				end

				while tmp-1 > -1 do
					fin = fin.."I"
					tmp = tmp-1
				end

				return fin
			end,

			rseed = function(self)
				local t0 = _time()
				local ts = tostring(_stamp()/t0)
				local n = tonumber(ts:reverse())
				if not n then n = tonumber(tostring(t0):reverse()) end
				math.randomseed(n)

				if _DEBUG then
					if not debugTimes["CCSCommon.rseed"] then debugTimes["CCSCommon.rseed"] = 0 end
					debugTimes["CCSCommon.rseed"] = debugTimes["CCSCommon.rseed"]+_time()-t0
				end
			end,

			setDescent = function(self, t, a)
				if t then
					if t.descWrite > -1 then
						if t.descWrite == 0 then t.descWrite = -1 end
						if a == 0 then
							self:setDescent(t.father, 1)
							self:setDescent(t.mother, 1)
							for i, j in pairs(t.children) do self:setDescent(j, -1) end
						elseif a == 1 and not t.descRoyal then
							t.descRoyal = true
							self:setDescent(t.father, 1)
							self:setDescent(t.mother, 1)
						elseif a == -1 and not t.ancRoyal then
							t.ancRoyal = true
							for i, j in pairs(t.children) do self:setDescent(j, -1) end
						end
						if a == 0 or t.ancRoyal and t.descRoyal then if t.descWrite ~= 1 then
							self.culledCount = self.culledCount+1
							t.cIndex = self.culledCount
							self.cIndi[t.cIndex] = t
							t.descWrite = 1
						end end
					end

					if t.descWrite == -1 then t.descWrite = 0 end
				end
			end,

			setGed = function(self, t, p)
				if t then
					if t.writeGed == 0 then
						t.writeGed = -1
						if p then t.writeGed = 1 end
						if t.royalGenerations <= self.genLimit then t.writeGed = 1 end
						if not t.father and not t.mother then if not t.children or #t.children == 0 then t.writeGed = -1 end end
						if t.writeGed == 1 then
							if t.father and t.mother then
								local fKey = t.father.gString..":"..t.mother.gString
								if not self.fam[fKey] then
									self.famCount = self.famCount+1
									self.fam[fKey] = {husb=t.father.gString, wife=t.mother.gString, chil={}, fIndex=self.famCount}
								end
								local found = false
								for i=1,#self.fam[fKey].chil do if self.fam[fKey].chil[i] == t.gString then found = true end end
								if not found then
									local nearest = -1
									for i=1,#self.fam[fKey].chil do if nearest == -1 and t.birth < self.indi[self.fam[fKey].chil[i]].birth then nearest = i end end
									if nearest == -1 then table.insert(self.fam[fKey].chil, t.gString) else table.insert(self.fam[fKey].chil, nearest, t.gString) end
								end
								t.famc = fKey
								found = false
								for i=1,#t.father.fams do if t.father.fams[i] == fKey then found = true end end
								if not found then table.insert(t.father.fams, fKey) end
								found = false
								for i=1,#t.mother.fams do if t.mother.fams[i] == fKey then found = true end end
								if not found then table.insert(t.mother.fams, fKey) end
							end
							if not self.indi[t.gString] then
								self.indiCount = self.indiCount+1
								t.gIndex = self.indiCount
								self.indi[t.gString] = t
							end
							self:setGed(t.father, true)
							self:setGed(t.mother, true)
							for i, j in pairs(t.children) do self:setGed(j, false) end
						end
					end

					if t.writeGed == -1 then t.writeGed = 0 end
				end
			end,

			setGensChildren = function(self, t, v, a)
				if t.royalGenerations >= v then
					t.royalGenerations = v
					t.LastRoyalAncestor = a
				end
				if t.children then for i, j in pairs(t.children) do self:setGensChildren(j, v+1, a) end end
			end,

			setLanguage = function(self, nl, r, l)
				local langName = nl.demonym
				if r and r.name then langName = langName.." ("..self:demonym(r.name)..")" end
				for i=#self.languages,1,-1 do if self.languages[i].name == langName then table.remove(self.languages, i) end end
				l.name = langName
				table.insert(self.languages, l)
				if r then r.language = self:getLanguage(langName, nl) else nl.language = self:getLanguage(langName, nl) end
			end,

			strengthFactor = function(self, c)
				if not c then return 0 end
				local pop = 0
				if c.rulerParty then pop = c.rulerPopularity-50 end
				return (pop+(c.stability-50)+(((c.military/#c.people)*100)-50))
			end,

			writeGed = function(self)
				if #self.royals > 0 then
					of = io.open(self:directory({self.stamp, "families.ged"}), "w+")
					if not of then return end

					local indiSorted = {}
					local famSorted = {}

					UI:printf("Generating GEDCOM data...")
					for i=1,#self.royals do
						self:setGed(self.royals[i], false)
						UI:printl(string.format("%.2f%% done", (i/#self.royals*10000)/100))
					end

					UI:printf("Sorting GEDCOM individual data...")
					for i, j in pairs(self.indi) do indiSorted[j.gIndex] = j end

					UI:printf("Sorting GEDCOM family data...")
					for i, j in pairs(self.fam) do famSorted[j.fIndex] = j end

					of:write("0 HEAD\n1 SOUR CCSim\n2 NAME Compact Country Simulator\n2 VERS 1.0.0\n1 GEDC\n2 VERS 5.5\n2 FORM LINEAGE-LINKED\n1 CHAR UTF-8\n1 LANG English")

					UI:printf("Writing individual data...")
					for i=1,#indiSorted do
						local j = indiSorted[i]
						of:write("\n0 @I"..tostring(j.gIndex).."@ INDI\n1 NAME ")
						if j.rulerName ~= "" then of:write(j.rulerName) else of:write(j.name) end
						of:write(" /"..j.surname:upper().."/")
						if j.number ~= 0 then of:write(" "..self:roman(j.number)) end
						of:write("\n2 SURN "..j.surname:upper().."\n2 GIVN ")
						if j.rulerName ~= "" then of:write(j.rulerName) else of:write(j.name) end
						if j.number ~= 0 then of:write("\n2 NSFX "..self:roman(j.number)) end
						if j.rulerTitle ~= "" then of:write("\n2 NPFX "..tostring(j.rulerTitle)) end
						of:write("\n1 SEX "..j.gender.."\n1 BIRT\n2 DATE "..tostring(math.abs(j.birth)))
						if j.birth < 1 then of:write(" B.C.") end
						of:write("\n2 PLAC "..j.birthplace)
						if j.death and j.death < self.years and j.death ~= 0 then of:write("\n1 DEAT\n2 DATE "..tostring(math.abs(j.death))) if j.death < 1 then of:write(" B.C.") end of:write("\n2 PLAC "..j.deathplace) end
						for k, l in pairs(j.fams) do if self.fam[l] then of:write("\n1 FAMS @F"..self.fam[l].fIndex.."@") end end
						if self.fam[j.famc] then of:write("\n1 FAMC @F"..self.fam[j.famc].fIndex.."@") end
						local nOne = true
						for k, l in pairs(j.ethnicity) do if l >= 0.01 then
							local fStr = ""
							local dStr = tostring(math.fmod(l, 1))
							if not nOne then fStr = "\n2 CONT %"
							else
								fStr = "\n1 NOTE %"
								nOne = false
							end
							if dStr == "0" then fStr = fStr.."d%% %s"
							elseif dStr:len() == 3 and dStr:match("%.") then fStr = fStr..".1f%% %s"
							elseif dStr:len() > 3 and dStr:match("%.") then fStr = fStr..".2f%% %s" end
							of:write(string.format(fStr, l, k))
						end end
						local fStr = ""
						if not nOne then fStr = "\n2 CONT Native language"
						else
							fStr = "\n1 NOTE Native language"
							nOne = false
						end
						if #j.nativeLang > 1 then fStr = fStr.."s: " else fStr = fStr..": " end
						for k=1,#j.nativeLang do
							fStr = fStr..j.nativeLang[k].name
							if k < #j.nativeLang then fStr = fStr..", " end
						end
						of:write(fStr)
						fStr = ""
						if #j.spokenLang > 0 then
							fStr = "\n2 CONT Spoken language"
							if #j.spokenLang > 1 then fStr = fStr.."s: " else fStr = fStr..": " end
							for k=1,#j.spokenLang do
								fStr = fStr..j.spokenLang[k].name
								if k < #j.spokenLang then fStr = fStr..", " end
							end
						end
						of:write(fStr)
						UI:printl(string.format("%.2f%% done", (i/#indiSorted*10000)/100))
					end

					of:flush()
					UI:printf("Writing family data...")
					for i=1,#famSorted do
						local j = famSorted[i]
						if j and j.husb and self.indi[j.husb] and j.wife and self.indi[j.wife] and #j.chil > 0 then
							of:write("\n0 @F"..tostring(j.fIndex).."@ FAM\n1 HUSB @I"..tostring(self.indi[j.husb].gIndex).."@\n1 WIFE @I"..tostring(self.indi[j.wife].gIndex).."@")
							for k=1,#j.chil do if self.indi[j.chil[k]] then of:write("\n1 CHIL @I"..tostring(self.indi[j.chil[k]].gIndex).."@") end end
							of:flush()
						end
						UI:printl(string.format("%.2f%% done", (i/#famSorted*10000)/100))
					end

					of:write("\n0 TRLR")
					of:flush()
					of:close()

					of = io.open(self:directory({self.stamp, "royals.ged"}), "w+")
					if not of then return end

					of:write("0 HEAD\n1 SOUR CCSim\n2 NAME Compact Country Simulator\n2 VERS 1.0.0\n1 GEDC\n2 VERS 5.5\n2 FORM LINEAGE-LINKED\n1 CHAR UTF-8\n1 LANG English")

					UI:printf("Isolating royal descent lines...")
					local cFam = {}
					local cFamCount = 0
					local cFamSort = {}
					for i=1,#self.royals do
						self:setDescent(self.royals[i], 0)
						UI:printl(string.format("%.2f%% done", (i/#self.royals*10000)/100))
					end

					UI:printf("Sorting isolated individuals...")
					for i=1,#self.cIndi do
						self.cIndi[i].cFams = {}
						self.cIndi[i].cFamc = 0
					end
					for i=1,#self.cIndi do
						for j, k in pairs(self.cIndi[i].children) do if k.royalGenerations == 0 or k.ancRoyal and k.descRoyal then
							local fString = ":"
							local fat = false
							local mot = false

							if k.father then if k.father.royalGenerations == 0 or k.surname:match(k.father.surname) or k.father.ancRoyal and k.father.descRoyal then
								fString = k.father.gString..fString
								fat = true
							end end
							if k.mother then if k.mother.royalGenerations == 0 or k.surname:match(k.mother.surname) or k.mother.ancRoyal and k.mother.descRoyal then
								fString = fString..k.mother.gString
								mot = true
							end end

							if not cFam[fString] then
								cFamCount = cFamCount+1
								cFam[fString] = {fIndex=cFamCount, husb=nil, wife=nil, chil={}}
								if fat then
									table.insert(k.father.cFams, cFam[fString].fIndex)
									cFam[fString].husb = k.father.cIndex
								end
								if mot then
									table.insert(k.mother.cFams, cFam[fString].fIndex)
									cFam[fString].wife = k.mother.cIndex
								end
							end

							k.cFamc = cFam[fString].fIndex
							local found = false
							for l=1,#cFam[fString].chil do if cFam[fString].chil[l] == k.cIndex then found = true end end
							if not found then table.insert(cFam[fString].chil, k.cIndex) end
						end end
						UI:printl(string.format("%.2f%% done", (i/#self.cIndi*10000)/100))
					end

					UI:printf("Sorting isolated families...")
					local cfFinished = 0
					for i, j in pairs(cFam) do
						cFamSort[j.fIndex] = j
						cfFinished = cfFinished+1
						UI:printl(string.format("%.2f%% done", (cfFinished/cFamCount*10000)/100))
					end

					UI:printf("Writing individual data...")
					for i=1,#self.cIndi do
						local j = self.cIndi[i]
						of:write("\n0 @I"..tostring(j.cIndex).."@ INDI\n1 NAME ")
						if j.rulerName ~= "" then of:write(j.rulerName) else of:write(j.name) end
						of:write(" /"..j.surname:upper().."/")
						if j.number ~= 0 then of:write(" "..self:roman(j.number)) end
						of:write("\n2 SURN "..j.surname:upper().."\n2 GIVN ")
						if j.rulerName ~= "" then of:write(j.rulerName) else of:write(j.name) end
						if j.number ~= 0 then of:write("\n2 NSFX "..self:roman(j.number)) end
						if j.rulerTitle ~= "" then of:write("\n2 NPFX "..tostring(j.rulerTitle)) end
						of:write("\n1 SEX "..j.gender.."\n1 BIRT\n2 DATE "..tostring(math.abs(j.birth)))
						if j.birth < 1 then of:write(" B.C.") end
						of:write("\n2 PLAC "..j.birthplace)
						if j.death and j.death < self.years and j.death ~= 0 then of:write("\n1 DEAT\n2 DATE "..tostring(math.abs(j.death))) if j.death < 1 then of:write(" B.C.") end of:write("\n2 PLAC "..j.deathplace) end
						for k=1,#j.cFams do if cFamSort[j.cFams[k]] then of:write("\n1 FAMS @F"..cFamSort[j.cFams[k]].fIndex.."@") end end
						if cFamSort[j.cFamc] then of:write("\n1 FAMC @F"..cFamSort[j.cFamc].fIndex.."@") end
						local nOne = true
						for k, l in pairs(j.ethnicity) do if l >= 0.01 then
							local fStr = ""
							local dStr = tostring(math.fmod(l, 1))
							if not nOne then fStr = "\n2 CONT %"
							else
								fStr = "\n1 NOTE %"
								nOne = false
							end
							if dStr == "0" then fStr = fStr.."d%% %s"
							elseif dStr:len() == 3 and dStr:match("%.") then fStr = fStr..".1f%% %s"
							elseif dStr:len() > 3 and dStr:match("%.") then fStr = fStr..".2f%% %s" end
							of:write(string.format(fStr, l, k))
						end end
						local fStr = ""
						if not nOne then fStr = "\n2 CONT Native language"
						else
							fStr = "\n1 NOTE Native language"
							nOne = false
						end
						if #j.nativeLang > 1 then fStr = fStr.."s: " else fStr = fStr..": " end
						for k=1,#j.nativeLang do
							fStr = fStr..j.nativeLang[k].name
							if k < #j.nativeLang then fStr = fStr..", " end
						end
						of:write(fStr)
						fStr = ""
						if #j.spokenLang > 0 then fStr = "\n2 CONT Spoken language" end
						if #j.spokenLang > 1 then fStr = fStr.."s: " else fStr = fStr..": " end
						for k=1,#j.spokenLang do
							fStr = fStr..j.spokenLang[k].name
							if k < #j.spokenLang then fStr = fStr..", " end
						end
						of:write(fStr)
						UI:printl(string.format("%.2f%% done", (i/#self.cIndi*10000)/100))
					end

					of:flush()
					UI:printf("Writing family data...")
					for i=1,#cFamSort do
						local j = cFamSort[i]
						if j then
							of:write("\n0 @F"..tostring(j.fIndex).."@ FAM\n")
							if j.husb and self.cIndi[j.husb] then of:write("1 HUSB @I"..tostring(self.cIndi[j.husb].cIndex).."@\n") end
							if j.wife and self.cIndi[j.wife] then of:write("1 WIFE @I"..tostring(self.cIndi[j.wife].cIndex).."@\n") end
							for k=1,#j.chil do if self.cIndi[j.chil[k]] then of:write("1 CHIL @I"..tostring(self.cIndi[j.chil[k]].cIndex).."@\n") end end
							of:flush()
						end
						UI:printl(string.format("%.2f%% done", (i/#cFamSort*10000)/100))
					end

					of:write("0 TRLR\n")
					of:flush()
					of:close()
					of = nil

					cFam = nil
					cFamCount = nil
					cFamSort = nil
				end
			end
		}

		return CCSCommon
	end
