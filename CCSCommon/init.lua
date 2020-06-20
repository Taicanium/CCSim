if _DEBUG then
	if not loadstring then loadstring = load end
	if not debug or not debug.upvaluejoin or not debug.getupvalue or not debug.setupvalue or not loadstring then error("Could not locate the Lua debug library! CCSim debug functions will not operate without it!") return nil end
end

table.contains = function(t, n)
	if not t or not n then return false end
	for i, j in pairs(t) do
		if tostring(n) == tostring(j) then return true end
		if type(n) == "table" and type(j) == "table" then
			if n.name and j.name and j.name == n.name then return true end
			if n.id and j.id and j.id == n.id then return true end
		end
	end
	return false
end

_time = os.clock
_stamp = os.time
if _time() > 15 then _time = os.time end
if _stamp() < 15 then _stamp = os.clock end

return
	function()
		cursesstatus, curses = pcall(require, "curses")

		City = require("CCSCommon.City")()
		Country = require("CCSCommon.Country")()
		Language = require("CCSCommon.Language")()
		Party = require("CCSCommon.Party")()
		Person = require("CCSCommon.Person")()
		Region = require("CCSCommon.Region")()
		UI = require("CCSCommon.UI")()
		World = require("CCSCommon.World")()

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
			local _REVIEWING = true
			local indi = {}
			local fam = {}
			local fami = {}
			local iCount = 0
			local fi = 0
			local reindexed = 1
			local matches = {}
			local plc = {}
			local dms = {}
			local lgs = {}
			UI:printf("Counting objects...")
			local l = f:read("*l")
			while l and l ~= "" do
				local index = l:gmatch("[%w%-]+")()
				if tonumber(index) then iCount = math.max(iCount, tonumber(index)) end
				if math.fmod(iCount, 10000) == 0 then UI:printl(string.format("%d people", iCount)) end
				l = f:read("*l")
			end
			f:seek("set")
			UI:printl(string.format("%d people", iCount))
			UI:printf("\nReading object data...")
			local largestRead = 0
			l = f:read("*l")
			while l and l ~= "" do
				local split = {}
				for x in l:gmatch("[%w%-%.,%']+") do table.insert(split, x) end
				if #split > 0 then
					if tonumber(split[1]) then
						fi = tonumber(split[1])
						largestRead = math.max(fi, largestRead)
						if math.fmod(largestRead, 10000) == 0 then
							UI:printl(string.format("%d/%d people", largestRead, iCount))
							if math.fmod(largestRead, 100000) == 0 then collectgarbage("collect") end
						end
						reindexed = 0
					else reindexed = 1 end
					if cmd ~= "y" and cmd ~= "z" and cmd ~= "j" and not indi[fi] then
						indi[fi] = {}
						indi[fi].gIndex = fi
					end
					local cmd = split[2-reindexed]
					if cmd == "b" then indi[fi].birth = tonumber(split[3-reindexed])
					elseif cmd == "c" then indi[fi].birthplace = plc[split[3-reindexed]]
					elseif cmd == "g" then indi[fi].gender = split[3-reindexed]
					elseif cmd == "h" then
						if not indi[fi].spokeLang then indi[fi].spokeLang = {} end
						table.insert(indi[fi].spokeLang, lgs[split[3-reindexed]])
					elseif cmd == "i" then
						if not indi[fi].natLang then indi[fi].natLang = {} end
						table.insert(indi[fi].natLang, lgs[split[3-reindexed]])
					elseif cmd == "n" then indi[fi].givn = split[3-reindexed]
					elseif cmd == "s" then indi[fi].surn = split[3-reindexed]
					elseif cmd == "t" then
						indi[fi].title = split[3-reindexed]
						if split[4-reindexed] then indi[fi].title = indi[fi].title.." "..split[4-reindexed] end
					elseif cmd == "o" then indi[fi].number = tonumber(split[3-reindexed])
					elseif cmd == "r" then indi[fi].rulerName = split[3-reindexed]
					elseif cmd == "d" then indi[fi].death = tonumber(split[3-reindexed])
					elseif cmd == "e" then indi[fi].deathplace = plc[split[3-reindexed]]
					elseif cmd == "m" then indi[fi].moth = tonumber(split[3-reindexed])
					elseif cmd == "f" then indi[fi].fath = tonumber(split[3-reindexed])
					elseif cmd == "l" then
						if not indi[fi].ethn then indi[fi].ethn = {} end
						table.insert(indi[fi].ethn, split[3-reindexed].."% "..dms[split[4-reindexed]])
					elseif cmd == "y" then
						local inx = split[3-reindexed]
						local loc = split[4-reindexed]
						for q=5-reindexed,#split do loc = loc.." "..split[q] end
						plc[inx] = loc
					elseif cmd == "z" then
						local inx = split[3-reindexed]
						local loc = split[4-reindexed]
						for q=5-reindexed,#split do loc = loc.." "..split[q] end
						dms[inx] = loc
					elseif cmd == "j" then
						local inx = split[3-reindexed]
						local loc = split[4-reindexed]
						for q=5-reindexed,#split do loc = loc.." "..split[q] end
						lgs[inx] = loc
					end
					l = f:read("*l")
				else l = nil end
			end

			UI:printl(string.format("%d/%d people", largestRead, iCount))
			UI:printf("\nLinking family records...")
			local nextInd = 1

			for i=1,#indi do
				local j = indi[i]
				if math.fmod(i, 10000) == 0 then
					UI:printl(string.format("%d/%d people", i, iCount))
					if math.fmod(i, 100000) == 0 then collectgarbage("collect") end
				end
				if j.moth and j.fath then
					local fInd = 0
					local famStr = tostring(j.moth).."-"..tostring(j.fath)
					if not fam[famStr] then
						fInd = nextInd
						fam[famStr] = fInd
						fami[fInd] = {wife=j.moth, husb=j.fath, chil={}}
						indi[j.moth].fams = indi[j.moth].fams or {}
						indi[j.fath].fams = indi[j.fath].fams or {}
						local found = false
						for k=1,#indi[j.moth].fams do if indi[j.moth].fams[k] == fInd then found = true end end
						if not found then table.insert(indi[j.moth].fams, fInd) end
						found = false
						for k=1,#indi[j.fath].fams do if indi[j.fath].fams[k] == fInd then found = true end end
						if not found then table.insert(indi[j.fath].fams, fInd) end
						nextInd = nextInd+1
					else fInd = fam[famStr] end
					table.insert(fami[fInd].chil, i)
					j.famc = fInd
				end
			end

			fi = math.random(1, #indi)

			while _REVIEWING do
				UI:clear()
				local i = indi[fi]
				local gender = i.gender or i.gend
				local title = i.rulerTitle or i.title
				local givn = i.givn or i.name
				local surn = i.surn or i.surname
				local famc = i.famc
				local fams = i.fams
				if givn and title then givn = givn:gsub(title.." ", ""):gsub(title, "") end
				if i.rulerName and title then i.rulerName = i.rulerName:gsub(title.." ", ""):gsub(title, "") end
				if famc and fami[famc] then
					local husb = indi[fami[famc].husb]
					local wife = indi[fami[famc].wife]
					if husb then
						local p1fam = fami[husb.famc]
						if p1fam then
							printIndi(indi[p1fam.husb], 3)
							printIndi(indi[p1fam.wife], 3)
						end
						printIndi(husb, 2)
					end
					if wife then
						local p2fam = fami[wife.famc]
						if p2fam then
							printIndi(indi[p2fam.husb], 3)
							printIndi(indi[p2fam.wife], 3)
						end
						printIndi(wife, 2)
					end
				end

				printIndi(i, 0)

				if fams then for j=1,#fams do
					local fams = fami[fams[j]]
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
				UI:printc("R to select a random person.\n")
				UI:printc("S to view this person's notes.\n")
				UI:printp("\n > ")
				local datin = UI:readl()
				local oldFI = fi
				if datin:lower() == "b" then matches = {} _REVIEWING = false
				elseif datin:lower() == "f" and famc then fi = fami[famc].husb or oldFI
				elseif datin:lower() == "m" and famc then fi = fami[famc].wife or oldFI
				elseif datin:lower() == "n" then
					mi = mi+1
					mi = math.min(mi, #matches)
					if mi == 0 then mi = 1 end
					fi = matches[mi]
				elseif datin:lower() == "p" then
					mi = mi-1
					mi = math.max(mi, 1)
					fi = matches[mi]
				elseif datin:lower() == "e" and _DEBUG then debugLine()
				elseif datin:lower() == "r" then
					matches = {}
					fi = CCSCommon:randomChoice(indi, true)
				elseif datin:lower() == "s" then
					UI:clear()
					printIndi(i, 0)
					UI:printc("\n\n")
					if not i.rulerName and not i.ethn and not i.spokeLang and not i.natLang then UI:printf("This individual has no notes.") end
					if i.rulerName then UI:printf("\nBirth name: "..givn.." "..surn) end
					if i.natLang or i.spokeLang then UI:printc("\n") end
					if i.natLang then
						UI:printc("Native language")
						if #i.natLang > 1 then UI:printc("s") end
						UI:printc(": ")
						for x=1,#i.natLang-1 do UI:printc(i.natLang[x]..", ") end
						UI:printc(i.natLang[#i.natLang].."\n")
					end
					if i.spokeLang then
						UI:printc("Spoken language")
						if #i.spokeLang > 1 then UI:printc("s") end
						UI:printc(": ")
						for x=1,#i.spokeLang-1 do UI:printc(i.spokeLang[x]..", ") end
						UI:printc(i.spokeLang[#i.spokeLang].."\n")
					end
					if i.ethn then
						UI:printf("\n")
						for x=1,#i.ethn do UI:printf(i.ethn[x]) end
					end
					UI:readl()
				elseif datin ~= "" then
					matches = {}
					fi = tonumber(datin) or datin
					if not fi or not indi[fi] then
						local scanned = 0
						for j, k in pairs(indi) do
							local allMatch = true
							local fullName = ""
							local ktitle = k.rulerTitle or k.title
							local kgivn = k.givn or k.name
							local kRulerName = k.rulerName
							local ksurn = k.surn or k.surname
							local knumber = CCSCommon:roman(k.number)
							if ktitle and ktitle ~= "" then fullName = ktitle.." " end
							if kgivn then fullName = fullName..kgivn.." " end
							if kRulerName then fullName = fullName..kRulerName.." " end
							if ksurn then fullName = fullName..ksurn.." " end
							if knumber and k.number ~= 0 then fullName = fullName..knumber end
							fullName = fullName:lower()
							for x in string.gmatch(datin:lower(), "%w+") do if not fullName:match(x) then allMatch = false end end
							if allMatch then table.insert(matches, j) end
							scanned = scanned+1
							if scanned > 1 and math.fmod(scanned, 10000) == 0 then UI:printl(string.format("Scanned %d/%d people...", scanned, iCount)) end
						end
						if #matches > 0 then
							fi = matches[1]
							mi = 1
						end
					end
					collectgarbage("collect")
				end
				if not indi[fi] then fi = oldFI end
				if not indi[fi] then fi = CCSCommon:randomChoice(indi, true) end
			end
		end

		function getLineTolerance(rl) if not rl then return UI.y-1 else return UI.y-rl-1 end end

		function printIndi(i, f)
			if not i then return end
			local gIndex = i.gIndex
			local gender = i.gender or i.gend
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
			if givn and not i.rulerName then sOut = sOut..givn.." "
			elseif i.rulerName then sOut = sOut..i.rulerName.." " end
			if surn then sOut = sOut..surn.." " end
			if number and number ~= 0 then sOut = sOut..CCSCommon:roman(number).." " end
			if birt or deat then sOut = sOut.."(" end
			if birt and ((birt.dat and birt.dat ~= "0") or (birt.plac and birt.plac ~= "")) then
				if not deat or ((not deat.dat or deat.dat == "0") and (not deat.plac or deat.plac == "")) then sOut = sOut.."b. " end
				if birt.dat and birt.dat ~= "0" then sOut = sOut..birt.dat end
				if birt.dat and birt.dat ~= "0" and birt.plac then sOut = sOut..", " end
				if birt.plac and birt.plac ~= "" then sOut = sOut..birt.plac end
				if deat and ((deat.dat and deat.dat ~= "0") or (deat.plac and deat.plac ~= "")) then sOut = sOut.." - " else sOut = sOut..")" end
			end
			if deat and ((deat.dat and deat.dat ~= "0") or (deat.plac and deat.plac ~= "")) then
				if not birt or ((not birt.dat or birt.dat == "0") and (not birt.plac or birt.plac == "")) then sOut = sOut.."d. " end
				if deat.dat and deat.dat ~= "0" then sOut = sOut..deat.dat end
				if deat.dat and deat.dat ~= "0" and deat.plac then sOut = sOut..", " end
				if deat.plac and deat.plac ~= "" then sOut = sOut..deat.plac end
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

			UI:printf("\nDo you want to produce maps of the world at major events (y/n)?")
			UI:printp("Be advised map generation is a disk-intensive task and will greatly slow down the simulation. > ")
			datin = UI:readl()

			CCSCommon.doMaps = false
			if datin:lower() == "y" then CCSCommon.doMaps = true end

			local done = false
			while not done do
				UI:printp("\nData > ")
				datin = UI:readl()
				done = true
				CCSCommon.stamp = tostring(math.floor(_stamp()))
				CCSCommon:checkDirectory(".", CCSCommon.stamp)

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
							local gedFile = false
							local dirSimCmd = "dir "..x.." /b /a-d"
							if UI.clrcmd == "clear" then dirSimCmd = "dir -1 "..x end
							for y in io.popen(dirSimCmd):lines() do if y:match("events.txt") then eventFile = true elseif y:match("ged.dat") then gedFile = true end end
							if eventFile or gedFile then
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
					for x in io.popen(dirSimCmd):lines() do
						if x:match("events.txt") then eventFile = true
						elseif x:match("ged.dat") then gedFile = true end
					end
					UI:clear()

					local _SELECTED = true
					while _SELECTED do
						UI:clear()
						UI:printf(string.format("\nSelected simulation performed %s\n", os.date('%Y-%m-%d %H:%M:%S', dirStamp)))
						local ops = {}
						local thisOp = 1
						-- if eventFile then ops[thisOp] = "events.txt" UI:printf(string.format("%d\t-\t%s", thisOp, "Events and history")) thisOp = thisOp+1 end
						if gedFile then ops[thisOp] = "ged.dat" UI:printf(string.format("%d\t-\t%s", thisOp, "Royal families and relations")) thisOp = thisOp+1 end

						UI:printf("\nEnter a selection, or B to return to the previous menu.\n")
						UI:printp(" > ")
						datin = UI:readl()
						if datin:lower() == "b" then _SELECTED = false elseif tonumber(datin) and ops[tonumber(datin)] then
							local op = ops[tonumber(datin)]
							local f = io.open(CCSCommon:directory({dirStamp, op}))
							if f then
								-- if op == "events.txt" then eventReview(f) end
								if op == "ged.dat" then gedReview(f) end

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
			local zeroRGB = {0, 0, 0}
			local maxRGB = {255, 255, 255}
			for j=1,pad do table.insert(bmp, {}) end
			for j, k in pairs(CCSCommon.glyphs) do
				for l=1,pad do for m=1,pad do table.insert(bmp[l], zeroRGB) end end
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
						if k[letterColumn][letterRow] == 1 then bmp[m][l] = maxRGB
						else bmp[m][l] = zeroRGB end
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

			CCSCommon:bmpOut("glyphs", adjusted, width*2, pad*2)
		end

		function testNames(n)
			local f = io.open("names.txt", "w+")
			if not f then return end
			local c = n or 12
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
						if not c1 or not c1.alliances or not self.target or not self.target.alliances then return -1 end
						if c1.relations[self.target.name] and c1.relations[self.target.name] < 35 and math.random(1, 50) < 5 then return self:endEvent(parent, c1) end
						if math.random(1, 750) < 5 then return self:endEvent(parent, c1) end
						return 0
					end,
					endEvent=function(self, parent, c1)
						if not c1 or not c1.alliances or not self.target or not self.target.alliances then return -1 end
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
					name="Annex",
					chance=3,
					target=nil,
					args=2,
					inverse=true,
					performEvent=function(self, parent, c1, c2)
						local patron = false

						for i=1,#c2.rulers do if c2.rulers[i].Country == c1.name then patron = true end end
						for i=1,#c1.rulers do if c1.rulers[i].Country == c2.name then patron = true end end

						if not patron and c1.majority == c2.majority and c1.relations[c2.name] and c1.relations[c2.name] > 85 then
							c1:event(parent, "Annexed "..c2.name)
							c2:event(parent, "Annexed by "..c1.name)

							local newr = Region:new()
							newr.name = c2.name
							newr.language = c2.language
							table.insert(parent.languages, 1, newr.language)

							for i=#c2.people,1,-1 do
								c2.people[i].region = newr
								c2.people[i].nationality = c1.name
								c2.people[i].military = false
								c2.people[i].isRuler = false
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
								local xyz = parent.thisWorld.planetdefined[i]
								if parent.thisWorld.planet[xyz].country == c2.name then
									parent.thisWorld.planet[xyz].country = c1.name
									parent.thisWorld.planet[xyz].region = c2.name
								end
							end

							c1.stability = math.max(1, c1.stability-8)
							if #c2.rulers > 0 then c2.rulers[#c2.rulers].To = parent.years end

							c1.regions[newr.name] = newr
							parent.thisWorld:delete(parent, c2)
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
						local oldcapName = nil
						if c.capitalcity then oldcapName = c.capitalcity.name end
						for i, j in pairs(c.regions) do for k, l in pairs(j.cities) do if l.name ~= oldcapName and l.name ~= "" then cCount = cCount+1 end end end

						if cCount > 2 then
							local oldreg = c.capitalregion
							local oldcap = c.capitalcity
							c.capitalregion = nil
							c.capitalcity = nil
							local cycles = 0

							while not c.capitalcity do for i, j in pairs(c.regions) do for k, l in pairs(j.cities) do
								cycles = cycles+1
								if l.name ~= oldcapName and not c.capitalcity and math.random(1, 50) == 35 then
									c.capitalregion = j
									c.capitalcity = l

									local msg = "Capital moved"
									if oldcapName then msg = msg.." from "..oldcapName end
									msg = msg.." to "..c.capitalcity.name

									c:event(parent, msg)
								end
								if cycles >= 1000 then
									c.capitalregion = oldreg
									c.capitalcity = oldcap
								end
							end end end
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
					conIndex=0,
					opIntervened = {},
					govIntervened = {},
					beginEvent=function(self, parent, c)
						c.civilWars = c.civilWars+1
						c:event(parent, "Beginning of "..parent:ordinal(c.civilWars).." civil war")
						self.conIndex = parent:insertConflict(c.name)
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
											table.insert(parent.conflicts[self.conIndex], cp.name)
										elseif cp.relations[c.name] > 70 and math.random(50, 150-cp.relations[c.name]) == 50 then
											c:event(parent, "Intervention on the side of the government by "..cp.name)
											cp:event(parent, "Intervened in the "..parent:ordinal(c.civilWars).." "..c.demonym.." civil war on the side of the government")
											table.insert(self.govIntervened, cp.name)
											table.insert(parent.conflicts[self.conIndex], cp.name)
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
								for q=#c.people,1,-1 do if c.people[q] and c.people[q].def and c.people[q].isRuler then c:delete(parent, q) end end
							else -- Exiled
								local newC = parent:randomChoice(parent.thisWorld.countries)
								if parent.thisWorld.numCountries > 1 then while newC.name == c.name do newC = parent:randomChoice(parent.thisWorld.countries) end end
								for q, r in pairs(c.people) do if r.isRuler then newC:add(parent, r) end end
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

							c.hasRuler = -1
							c:checkRuler(parent, true)

							local newRuler = nil
							for i=1,#c.people do if c.people[i].isRuler then newRuler = c.people[i] end end
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

						parent.conflicts[self.conIndex] = nil

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
					chance=4,
					target=nil,
					args=2,
					inverse=true,
					performEvent=function(self, parent, c1, c2, r)
						if not c1 or not c2 or not c1.alliances or not c2.alliances then return -1 end
						for i=1,#c1.alliances do if c1.alliances[i] == c2.name or r then return -1 end end
						for i=1,#c2.alliances do if c2.alliances[i] == c1.name or r then return -1 end end

						if r or c1.relations[c2.name] and c1.relations[c2.name] < 21 and c1.strength > c2.strength then
							if not r then
								c1:event(parent, "Conquered "..c2.name)
								c2:event(parent, "Conquered by "..c1.name)
							end

							local newr = Region:new()
							newr.name = c2.name
							newr.language = c2.language
							table.insert(parent.languages, 1, newr.language)

							for i=#c2.people,1,-1 do c1:add(parent, c2.people[i]) end
							c2.people = nil

							for i, j in pairs(c2.regions) do
								table.insert(newr.subregions, j)
								for k, l in pairs(j.cities) do newr.cities[k] = l end
							end

							for i=1,#parent.thisWorld.planetdefined do
								local xyz = parent.thisWorld.planetdefined[i]
								if parent.thisWorld.planet[xyz].country == c2.name then
									parent.thisWorld.planet[xyz].country = c1.name
									parent.thisWorld.planet[xyz].region = c2.name
								end
							end

							c1.stability = math.max(1, c1.stability-10)
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
							for q=#c.people,1,-1 do if c.people[q] and c.people[q].def and c.people[q].isRuler then c:delete(parent, q) end end
						else -- Exiled
							local newC = parent:randomChoice(parent.thisWorld.countries)
							if parent.thisWorld.numCountries > 1 then while newC.name == c.name do newC = parent:randomChoice(parent.thisWorld.countries) end end
							for q, r in pairs(c.people) do if r.isRuler then newC:add(parent, r) end end
						end

						c.hasRuler = -1
						c:checkRuler(parent, true)

						c.stability = math.max(1, c.stability-5)

						return -1
					end
				},
				{
					name="Independence",
					chance=2,
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
							for i, xyz in pairs(parent.thisWorld.planetdefined) do if parent.thisWorld.planet[xyz].region == newl.name then parent.thisWorld.planet[xyz].country = newl.name end end
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

							for i, j in pairs(newl.regions) do for k=1,#j.nodes do
								local xyz = j.nodes[k]
								if parent.thisWorld.planet[xyz].region == newl.name then parent.thisWorld.planet[xyz].region = j.name end
							end end

							newl:event(parent, "Independence from "..c.name)
							c:event(parent, "Granted independence to "..newl.name)

							newl:set(parent, true)
							newl:setTerritory(parent)
							newl.language = c.language

							for i, j in pairs(newl.regions) do
								local cCount = 0
								for k, l in pairs(j.cities) do cCount = cCount+1 end
								if cCount == 0 then
									local nC = City:new()
									nC:makename(newl, parent)
									nC.nl = newl.name
									nC.node = nil
									while not nC.node or parent.thisWorld.planet[nC.node].region ~= j.name do nC.node = parent:randomChoice(parent.thisWorld.planetdefined) end
									parent.thisWorld.planet[nC.node].city = nC.name
									j.cities[nC.name] = nC
								end
							end

							local nCities = {}
							for i, j in pairs(newl.regions) do for k, l in pairs(j.cities) do table.insert(nCities, k) end end

							parent.thisWorld:add(newl)

							for i=1,math.floor(#c.people/5) do
								local p = parent:randomChoice(c.people)
								while p.isRuler do p = parent:randomChoice(c.people) end
								newl:add(parent, p)
							end

							for i=#c.people,1,-1 do if c.people[i] and c.people[i].def and not c.people[i].isRuler and c.people[i].region and c.people[i].region.name == newl.name then
								local added = false
								for j=1,#nCities do if not added and c.people[i].city == nCities then
									newl:add(parent, c.people[i])
									added = true
								end end
							end end

							parent:getAlphabetical()

							c.stability = math.max(1, c.stability-math.random(5, 10))

							for i, j in pairs(c.regions) do
								j.nl = c.name
								for k, l in pairs(j.cities) do l.nl = c.name end
							end

							for i, j in pairs(newl.regions) do
								j.nl = newl.name
								for k, l in pairs(j.cities) do l.nl = newl.name end
							end

							c:checkCapital(parent)
							parent.writeMap = true
							parent.thisWorld.mapChanged = true

							nc.subregions = nil
							nc.cities = nil

							collectgarbage("collect")
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
							c1.relations[c2.name] = math.max(1, c1.relations[c2.name]-math.random(10, 25))
							c2.relations[c1.name] = math.max(1, c2.relations[c1.name]-math.random(10, 25))
						else
							c1.relations[c2.name] = math.min(100, c1.relations[c2.name]+math.random(10, 15))
							c2.relations[c1.name] = math.min(100, c2.relations[c1.name]+math.random(10, 15))
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
							c2.stability = math.max(1, c2.stability-10)
							c1:setPop(parent, math.ceil(c1.population/1.25))
							c2:setPop(parent, math.ceil(c2.population/1.4))

							local rcount = 0
							for q, b in pairs(c2.regions) do if b:borders(parent, c1, false) == 1 then rcount = rcount+1 end end
							if rcount > 1 and c1.strength > c2.strength+(c2.strength/5) and math.random(1, 30) < 5 then
								local c = parent:randomChoice(c2.regions)
								if reg then
									while reg:borders(parent, c1, false) == 0 do reg = parent:randomChoice(c2.regions) end
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
						if recovery < 50 then c.stability = math.max(1, c.stability-math.random(15, 25))
						else c.stability = math.min(100, c.stability+math.random(5, 10)) end

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
							for q=#c.people,1,-1 do if c.people[q] and c.people[q].def and c.people[q].isRuler then c:delete(parent, q) end end
						else -- Exiled
							local newC = parent:randomChoice(parent.thisWorld.countries)
							if parent.thisWorld.numCountries > 1 then while newC.name == c.name do newC = parent:randomChoice(parent.thisWorld.countries) end end
							for q, r in pairs(c.people) do if r.isRuler then newC:add(parent, r) end end
						end

						local oldsys = parent.systems[c.system].name
						while parent.systems[c.system].name == oldsys do c.system = math.random(1, #parent.systems) end
						if not c.snt[parent.systems[c.system].name] then c.snt[parent.systems[c.system].name] = 0 end
						c.snt[parent.systems[c.system].name] = c.snt[parent.systems[c.system].name]+1

						c:event(parent, "Revolution: "..oldsys.." to "..parent.systems[c.system].name)
						c:event(parent, "Establishment of the "..parent:ordinal(c.snt[parent.systems[c.system].name]).." "..c.demonym.." "..c.formalities[parent.systems[c.system].name])

						c.hasRuler = -1
						c:checkRuler(parent, true)

						c.stability = math.max(1, c.stability-10)

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
					conIndex=0,
					inverse=true,
					beginEvent=function(self, parent, c1)
						c1:event(parent, "Declared war on "..self.target.name)
						self.target:event(parent, "War declared by "..c1.name)
						self.conIndex = parent:insertConflict(c1.name, self.target.name)
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
						if not c1 or not c1.people or #c1.people == 0 then return -1 end
						if not self.target or not self.target.people or #self.target.people == 0 then return -1 end

						local ao1 = parent:getAllyOngoing(c1, self.target, self.name)
						local ao2 = parent:getAllyOngoing(self.target, c1, self.name)
						local ac = c1.alliances or {}

						for i=1,#ac do
							local c3 = nil
							for j, cp in pairs(parent.thisWorld.countries) do if cp.name == ac[i] then c3 = cp end end
							if c3 and not table.contains(ao1, c3) and not table.contains(ao2, c3) and math.random(1, 25) == 10 then
								table.insert(c3.allyOngoing, self.name.."?"..c1.name..":"..self.target.name)
								table.insert(parent.conflicts[self.conIndex], c3.name)

								self.target:event(parent, "Intervention by "..c3.name.." on the side of "..c1.name)
								c1:event(parent, "Intervention by "..c3.name.." against "..self.target.name)
								c3:event(parent, "Intervened on the side of "..c1.name.." in war with "..self.target.name)
							end
						end

						ac = self.target.alliances or {}

						for i=1,#ac do
							local c3 = nil
							for j, cp in pairs(parent.thisWorld.countries) do if cp.name == ac[i] then c3 = cp end end
							if c3 and not table.contains(ao1, c3) and not table.contains(ao2, c3) and math.random(1, 25) == 10 then
								table.insert(c3.allyOngoing, self.name.."?"..self.target.name..":"..c1.name)
								table.insert(parent.conflicts[self.conIndex], c3.name)

								c1:event(parent, "Intervention by "..c3.name.." on the side of "..self.target.name)
								self.target:event(parent, "Intervention by "..c3.name.." against "..c1.name)
								c3:event(parent, "Intervened on the side of "..self.target.name.." in war with "..c1.name)
							end
						end

						local varistab = parent:strengthFactor(c1)-parent:strengthFactor(self.target)

						ao1 = parent:getAllyOngoing(c1, self.target, self.name)
						for i=1,#ao1 do
							local extFactor = parent:strengthFactor(ao1[i])
							if extFactor > 0 then varistab = varistab+(extFactor/10) end
						end

						ao2 = parent:getAllyOngoing(self.target, c1, self.name)
						for i=1,#ao2 do
							local extFactor = parent:strengthFactor(ao2[i])
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

							local ao1 = parent:getAllyOngoing(c1, self.target, self.name)
							local ao2 = parent:getAllyOngoing(self.target, c1, self.name)

							for i=1,#ao1 do if ao1[i] then
									c1strength = c1strength+ao1[i].strength
									ao1[i]:event(parent, "Victory with "..c1.name.." in war with "..self.target.name)
							end end

							for i=1,#ao2 do if ao2[i] then
									c2strength = c2strength+ao2[i].strength
									ao2[i]:event(parent, "Defeat with "..self.target.name.." in war with "..c1.name)
							end end

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

							local ao1 = parent:getAllyOngoing(c1, self.target, self.name)
							local ao2 = parent:getAllyOngoing(self.target, c1, self.name)

							for i=1,#ao1 do
								c1strength = c1strength+ao1[i].strength
								ao1[i]:event(parent, "Defeat with "..c1.name.." in war with "..self.target.name)
							end

							for i=1,#ao2 do
								c2strength = c2strength+ao2[i].strength
								ao2[i]:event(parent, "Victory with "..self.target.name.." in war with "..c1.name)
							end

							parent:removeAllyOngoing(c1, self.target, self.name)
							parent:removeAllyOngoing(self.target, c1, self.name)

							if c2strength > c1strength+(c1strength/5) then
								local rcount = 0
								for q, b in pairs(c1.regions) do if b:borders(parent, c2, false) == 1 then rcount = rcount+1 end end
								if rcount > 1 then
									local reg = parent:randomChoice(c1.regions)
									if reg then
										while reg:borders(parent, c2, false) == 0 do reg = parent:randomChoice(c1.regions) end
										parent:regionTransfer(self.target, c1, reg.name, false)
									end
								end
							end
						end

						parent.conflicts[self.conIndex] = nil

						return -1
					end,
					performEvent=function(self, parent, c1, c2)
						for i=1,#c1.ongoing-1 do if c1.ongoing[i].name == self.name and c1.ongoing[i].target.name == c2.name then return -1 end end
						for i=1,#c2.ongoing do if c2.ongoing[i].name == self.name and c2.ongoing[i].target.name == c1.name then return -1 end end
						for i=1,#c1.alliances do if c1.alliances[i] == c2.name then return -1 end end
						for i=1,#c2.alliances do if c2.alliances[i] == c1.name then return -1 end end
						if c1:borders(parent, c2, false) == 0 then return -1 end

						if not c1.relations[c2.name] then c1.relations[c2.name] = 50 end
						if c1.relations[c2.name] and c1.relations[c2.name] < 30 then
							self.target = c2
							return 0
						end

						return -1
					end
				}
			},
			clrcmd = "",
			conflicts = {},
			consonants = {"b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "w", "y", "z"},
			demonyms = {},
			dirSeparator = "/",
			disabled = {},
			doMaps = false,
			endgroups = {"land", "ia", "y", "ar", "a", "tria", "tra", "an", "ica", "ria", "ium"},
			fileLangs = {},
			final = {},
			gedFile = nil,
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
			langDriftConstant = 0.18,
			langEML = 1, -- 1 for Early, 2 for Middle, 3 for Late.
			langPeriod = 1,
			languages = {},
			maxConflicts = 1,
			middlegroups = {"gar", "rit", "er", "ar", "ir", "ra", "rin", "bri", "o", "em", "nor", "nar", "mar", "mor", "an", "at", "et", "the", "thal", "cri", "ma", "na", "sa", "mit", "nit", "shi", "ssa", "ssi", "ret", "thu", "thus", "thar", "then", "min", "ni", "ius", "us", "es", "ta", "dos", "tho", "tha", "do", "to", "tri", "zi", "za", "zar", "zen", "tar", "la", "li", "len", "lor", "lir"},
			nextPerson = 1,
			partynames = {
				{"National", "United", "Citizens'", "General", "People's", "Joint", "Workers'", "Free", "New", "Traditional", "Grand", "All", "Loyal"},
				{"National", "United", "Citizens'", "General", "People's", "Joint", "Workers'", "Free", "New", "Traditional", "Grand", "All", "Loyal"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Centrist", "Democratic", "Republican", "Economical", "Moral", "Ethical", "Unionist", "Revivalist", "Monarchist", "Nationalist", "Reformist", "Public", "Patriotic", "Loyalist"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Centrist", "Centrism", "Democracy", "Democratic", "Republican", "Economical", "Moral", "Ethical", "Union", "Unionist", "Revival", "Revivalist", "Labor", "Monarchy", "Monarchist", "Nationalist", "Reform", "Reformist", "Public", "Freedom", "Security", "Patriotic", "Loyalist", "Liberty"},
				{"Party", "Group", "Front", "Coalition", "Force", "Alliance", "Caucus", "Fellowship", "Conference", "Forum", "Bureau", "Association"},
			},
			places = {},
			popCount = 0,
			popLimit = 2000,
			repGroups = {{"aium", "ium"}, {"iusy", "ia"}, {"oium", "ium"}, {"tyan", "tan"}, {"uium", "ium"}, {"aia", "ia"}, {"aie", "a"}, {"aio", "io"}, {"aiu", "a"}, {"ccc", "cc"}, {"dby", "dy"}, {"eia", "ia"}, {"eie", "e"}, {"eio", "io"}, {"eiu", "e"}, {"oia", "ia"}, {"oie", "o"}, {"oio", "io"}, {"oiu", "o"}, {"uia", "ia"}, {"uie", "u"}, {"uio", "io"}, {"uiu", "u"}, {"aa", "a"}, {"ae", "a"}, {"bd", "d"}, {"bp", "b"}, {"bt", "b"}, {"cd", "d"}, {"cg", "c"}, {"cj", "c"}, {"cp", "c"}, {"db", "b"}, {"df", "d"}, {"dg", "g"}, {"dj", "j"}, {"dk", "d"}, {"dl", "l"}, {"dt", "t"}, {"ee", "i"}, {"ei", "i"}, {"eu", "e"}, {"fd", "d"}, {"fh", "f"}, {"fj", "f"}, {"fv", "v"}, {"gc", "g"}, {"gd", "d"}, {"gj", "g"}, {"gk", "g"}, {"gl", "l"}, {"gt", "t"}, {"hc", "c"}, {"hg", "g"}, {"hj", "h"}, {"ie", "i"}, {"ii", "i"}, {"iy", "y"}, {"jb", "b"}, {"jc", "j"}, {"jd", "j"}, {"jg", "j"}, {"jr", "dr"}, {"js", "j"}, {"jt", "t"}, {"jz", "j"}, {"kc", "c"}, {"kd", "d"}, {"kg", "g"}, {"ki", "ci"}, {"kj", "k"}, {"lt", "l"}, {"mj", "m"}, {"mt", "m"}, {"nj", "ng"}, {"oa", "a"}, {"oe", "e"}, {"oi", "i"}, {"oo", "u"}, {"ou", "o"}, {"pb", "b"}, {"pg", "g"}, {"pj", "p"}, {"rz", "z"}, {"sj", "s"}, {"sz", "s"}, {"tb", "t"}, {"tc", "t"}, {"td", "t"}, {"tg", "t"}, {"tj", "t"}, {"tl", "l"}, {"tm", "t"}, {"tn", "t"}, {"tp", "t"}, {"tv", "t"}, {"ua", "a"}, {"ue", "e"}, {"ui", "i"}, {"uo", "o"}, {"uu", "u"}, {"vd", "v"}, {"vf", "f"}, {"vh", "v"}, {"vj", "v"}, {"vt", "t"}, {"wj", "w"}, {"yi", "y"}, {"zs", "z"}, {"zt", "t"}, {"hh", "h"}, {"yy", "y"}},
			showinfo = 0,
			stamp = nil,
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
					franks={"Homeless", "Citizen", "Mayor", "Dame", "Lady", "Baroness", "Viscountess", "Countess", "Marchioness", "Duchess", "Princess", "Queen"},
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
			langTestString = "The quick brown vixen and its master the mouse",
			thisWorld = {},
			tiffBitness = 9,
			tiffDict = {},
			tiffNextCode = 0,
			vowels = {"a", "e", "i", "o", "u", "y"},
			writeMap = false,
			years = 1,
			yearstorun = 0,

			bmpOut = function(self, label, data, w, h)
				local bf = io.open(label..".bmp", "w+b")
				local bmpArr = { 0x42, 0x4D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13, 0x0B, 0x00, 0x00, 0x13, 0x0B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }
				local hStringLE = string.format("%.8x", h or 600)
				local wStringLE = string.format("%.8x", w or 800)
				local rStringLE = ""
				local sStringLE = ""
				local hArr = {}
				local wArr = {}
				local rArr = {}
				local sArr = {}
				for x in hStringLE:gmatch("%w%w") do table.insert(hArr, tonumber(x, 16)) end
				for x in wStringLE:gmatch("%w%w") do table.insert(wArr, tonumber(x, 16)) end

				local byteCount = 0
				for y=h,1,-1 do
					local btWritten = w*3
					while math.fmod(btWritten, 4) ~= 0 do btWritten = btWritten+1 end
					byteCount = byteCount+btWritten
				end

				rStringLE = string.format("%.8x", byteCount)
				sStringLE = string.format("%.8x", byteCount+54)
				for x in rStringLE:gmatch("%w%w") do table.insert(rArr, tonumber(x, 16)) end
				for x in sStringLE:gmatch("%w%w") do table.insert(sArr, tonumber(x, 16)) end

				for i=1,4 do bmpArr[i+2] = sArr[5-i] end
				for i=1,4 do bmpArr[i+18] = wArr[5-i] end
				for i=1,4 do bmpArr[i+22] = hArr[5-i] end
				for i=1,4 do bmpArr[i+34] = rArr[5-i] end
				for i=1,#bmpArr do bf:write(string.char(bmpArr[i])) end

				for y=h,1,-1 do -- Bottom-to-top, as required by the BMP format.
					local btWritten = 0
					for x=1,w do
						if data[y] and data[y][x] and data[y][x][3] and data[y][x][2] and data[y][x][1] then
							bf:write(string.char(data[y][x][3]))
							bf:write(string.char(data[y][x][2]))
							bf:write(string.char(data[y][x][1]))
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
				sArr = nil
				wArr = nil
				hArr = nil
				rArr = nil
				bmpArr = nil
			end,

			checkDirectory = function(self, str, dir)
				local dirDotCmd = "dir "..str.." /b /ad"
				if UI.clrcmd == "clear" then dirDotCmd = "dir -1 "..str end
				local found = false
				local count = 0
				for x in io.popen(dirDotCmd):lines() do
					count = count+1
					if x:lower():match(dir) then found = true end
				end
				if not found then os.execute("mkdir "..self:directory({str, dir})) end
			end,

			compLangs = function(self, writeOut)
				local _REVIEWING = true
				local _GLOSSARY = false
				local _DESCENT = nil
				local oldDescent = nil

				while _REVIEWING do
					local cArr = {}
					local regs = {}
					local wCount = 0
					local screens = {{}}
					local screenIndex = 1
					local lnCount = 0
					local lnCorrect = 0
					local lastCountry = ""
					local screen = screens[screenIndex]
					local screenMargins = {}

					if not _GLOSSARY then
						if _DESCENT then
							local mainLang = nil
							for i=1,#self.languages do if self.languages[i].name == _DESCENT then mainLang = self.languages[i] end end
							if not mainLang then _DESCENT = nil else
								if not screenMargins[screenIndex] then screenMargins[screenIndex] = 1 end
								screenMargins[screenIndex] = math.max(screenMargins[screenIndex], mainLang.name:len()+1)
								for i=#mainLang.descentTree,1,-1 do
									if lnCount >= getLineTolerance(8) then
										lnCount = 0
										screenIndex = screenIndex+1
										if not screenMargins[screenIndex] then screenMargins[screenIndex] = 1 end
									end
									screenMargins[screenIndex] = math.max(screenMargins[screenIndex], mainLang.descentTree[i][1]:len()+1)
									lnCount = lnCount+1
								end

								lnCount = 0
								screenIndex = 1
								table.insert(screen, string.format("%s:%s\"%s.\"", mainLang.name, string.rep(" ", screenMargins[screenIndex]-mainLang.name:len()), mainLang.testString))

								for i=#mainLang.descentTree,1,-1 do
									if lnCount >= getLineTolerance(8) then
										lnCount = 0
										screenIndex = screenIndex+1
										screens[screenIndex] = {}
										screen = screens[screenIndex]
									end
									table.insert(screen, string.format("%s:%s\"%s.\"", mainLang.descentTree[i][1], string.rep(" ", screenMargins[screenIndex]-mainLang.descentTree[i][1]:len()), mainLang.descentTree[i][2]))
									lnCount = lnCount+1
								end
							end
						end

						if not _DESCENT then
							local alreadyMatched = {}

							for i, j in pairs(self.thisWorld.countries) do
								regs[j.name.."!".."Standard "..j.demonym] = j.name.."!".."Standard "..j.demonym
								for k, l in pairs(j.regions) do regs[j.name.."!"..l.name] = j.name.."!"..l.name end
							end
							local rKeys = self:getAlphabetical(regs)

							for i=1,#rKeys do
								local key = regs[rKeys[i]]
								local country = self.thisWorld.countries[key:match("(%w+)!")]
								if country then
									local region = country.regions[key:match("!(%w+)")]
									if region and region.language and not alreadyMatched[region.language.name] then
										table.insert(cArr, {country.demonym, region.language, false})
										alreadyMatched[region.language.name] = true
									elseif key:match("Standard") and not alreadyMatched[country.language.name] then
										table.insert(cArr, {country.demonym, country.language, true})
										alreadyMatched[country.language.name] = true
									end
								end
							end

							for i=1,#cArr do
								local lang = cArr[i][2]
								if lang then
									local trueName = (cArr[i][3] and "Standard "..lang.name or lang.name)
									if not writeOut then if (cArr[i][1] ~= lastCountry and lnCount+lnCorrect+1 >= getLineTolerance(8)) or lnCount+lnCorrect >= getLineTolerance(8) then
										lnCount = 0
										lnCorrect = 0
										lastCountry = ""
										screenIndex = screenIndex+1
									end end
									if cArr[i][1] ~= lastCountry then
										lastCountry = cArr[i][1]
										lnCorrect = lnCorrect+1
									end
									if not screenMargins[screenIndex] then screenMargins[screenIndex] = 1 end
									screenMargins[screenIndex] = math.max(screenMargins[screenIndex], trueName:len()+1)
									lnCount = lnCount+1
								end
							end

							screenIndex = 1
							lnCount = 0
							lnCorrect = 0
							lastCountry = ""
							local decimalMargin = (tostring(getLineTolerance(8))):len()

							for i=1,#cArr do
								local lang = cArr[i][2]
								if lang then
									local trueName = (cArr[i][3] and "Standard "..lang.name or lang.name)
									if not writeOut then if (cArr[i][1] ~= lastCountry and lnCount+lnCorrect+1 >= getLineTolerance(8)) or lnCount+lnCorrect >= getLineTolerance(8) then
										lnCount = 0
										lnCorrect = 0
										lastCountry = ""
										screenIndex = screenIndex+1
										screens[screenIndex] = {}
										screen = screens[screenIndex]
									end end
									if cArr[i][1] ~= lastCountry then
										table.insert(screen, cArr[i][1])
										lastCountry = cArr[i][1]
										lnCorrect = lnCorrect+1
									end
									if writeOut or lnCount+lnCorrect < getLineTolerance(8) then table.insert(screen, string.format("\t%d.%s%s:%s\"%s.\"", #screen+1-lnCorrect, string.rep(" ", decimalMargin), trueName, string.rep(" ", screenMargins[screenIndex]-trueName:len()), lang.testString)) end
									lnCount = lnCount+1
								end
							end
						end

						oldDescent = _DESCENT
						screenIndex = 1

						while not _GLOSSARY and _DESCENT == oldDescent do
							screenIndex = screenIndex > 0 and (screenIndex <= #screens and screenIndex or #screens) or 1
							screen = screens[screenIndex]
							if writeOut then
								local f = io.open(self:directory({self.stamp, "langs_"..self.years..".txt"}), "a+")
								for i=1,#screen do f:write(screen[i].."\n") end
								f:flush()
								f:close()
								f = nil
								screenIndex = screenIndex+1
								if screenIndex > #screens then
									_REVIEWING = false
									_GLOSSARY = true
								end
							else
								UI:clear()
								UI:printf(string.format("Translating the text \"%s.\"\n", self.langTestString))
								for i=1,#screen do UI:printf(screen[i]) end
								UI:printf("\nEnter B to return to the previous menu.")
								if not _DESCENT then UI:printf("Enter G to view a list of all languages, historical and living.") end
								if screenIndex < #screens then UI:printf("Enter N to move to the next set of languages.") end
								if screenIndex > 1 then UI:printf("Enter P to move to the previous set of languages.") end
								if not _DESCENT then UI:printf("Enter a number to view the descent tree of a language in this list.") end
								UI:printp(" > ")
								local datin = UI:readl()
								if datin:lower() == "b" then
									if _DESCENT then _DESCENT = nil else
										_REVIEWING = false
										_GLOSSARY = true
									end
								elseif datin:lower() == "g" then _GLOSSARY = true
								elseif datin:lower() == "n" then screenIndex = screenIndex+1
								elseif datin:lower() == "p" then screenIndex = screenIndex-1
								elseif tonumber(datin) then for i=1,#screen do if screen[i]:match("\t"..datin..". ") then
									_DESCENT = screen[i]:match(" (%S+):")
									_DESCENT = _DESCENT:gsub("Standard ", "")
								end end end
							end
						end
					else
						local allLanguages = {}
						for i=1,#self.languages do
							if not allLanguages[self.languages[i].name] then allLanguages[self.languages[i].name] = self.languages[i].testString end
							for j=1,#self.languages[i].descentTree do if not allLanguages[self.languages[i].descentTree[j][1]] then allLanguages[self.languages[i].descentTree[j][1]] = self.languages[i].descentTree[j][2] end end
						end
						local alphaLangs = self:getAlphabetical(allLanguages)

						for i=1,#alphaLangs do
							local key = alphaLangs[i]
							if lnCount+lnCorrect >= getLineTolerance(8) then
								lnCount = 0
								lnCorrect = 0
								lastCountry = ""
								screenIndex = screenIndex+1
							end
							if not key:match("period") then key = key.." (current period)" end
							if not screenMargins[screenIndex] then screenMargins[screenIndex] = 1 end
							screenMargins[screenIndex] = math.max(screenMargins[screenIndex], key:len()+1)
							lnCount = lnCount+1
						end

						screenIndex = 1
						lnCount = 0
						lnCorrect = 0
						lastCountry = ""
						local decimalMargin = (tostring(getLineTolerance(8))):len()

						for i=1,#alphaLangs do
							local key = alphaLangs[i]
							local lang = allLanguages[key]
							if lnCount+lnCorrect >= getLineTolerance(8) then
								lnCount = 0
								lnCorrect = 0
								lastCountry = ""
								screenIndex = screenIndex+1
								screens[screenIndex] = {}
								screen = screens[screenIndex]
							end
							if not key:match("period") then key = key.." (current period)" end
							if not key:gmatch(" ([0-9]+)%)")() or key:gmatch(" ([0-9]+)%)")() ~= tostring(self.langPeriod) then if writeOut or lnCount+lnCorrect < getLineTolerance(8) then table.insert(screen, string.format("%d.%s%s:%s\"%s.\"", #screen+1, string.rep(" ", decimalMargin), key, string.rep(" ", screenMargins[screenIndex]-key:len()), lang)) end end
							lnCount = lnCount+1
						end

						screenIndex = 1

						while _GLOSSARY do
							screenIndex = screenIndex > 0 and (screenIndex <= #screens and screenIndex or #screens) or 1
							screen = screens[screenIndex]
							UI:clear()
							UI:printf(string.format("Translating the text \"%s.\"\n", self.langTestString))
							for i=1,#screen do UI:printf(screen[i]) end
							UI:printf("\nEnter B to return to the previous menu.")
							UI:printf("Enter G to return to viewing living languages only.")
							if screenIndex < #screens then UI:printf("Enter N to move to the next set of languages.") end
							if screenIndex > 1 then UI:printf("Enter P to move to the previous set of languages.") end
							UI:printp(" > ")
							local datin = UI:readl()
							if datin:lower() == "b" then
								_REVIEWING = false
								_GLOSSARY = false
							elseif datin:lower() == "g" then _GLOSSARY = false
							elseif datin:lower() == "n" then screenIndex = screenIndex+1
							elseif datin:lower() == "p" then screenIndex = screenIndex-1 end
						end
					end
				end
			end,

			constructNumber = function(self, n, bitwise)
				nOut = 0
				for i=1,#n do
					if bitwise then nOut = nOut+bit32.lshift(n[i], #n-i)
					else nOut = nOut+bit32.lshift(n[i], (#n-i)*8) end
				end
				return nOut
			end,

			deconstructNumber = function(self, n, bytes)
				if bytes then
					local bytesOut = {}
					local mult = 255
					local res = 0
					local nSub = n
					while nSub > 0 do
						res = res+1
						nSub = bit32.rshift(nSub, 8)
					end
					for i=1,res do
						nSub = bit32.rshift(bit32.band(n, mult), 8*(i-1))
						table.insert(bytesOut, nSub)
						mult = bit32.lshift(mult, 8)
					end
					return bytesOut
				else
					local bitsOut = {}
					local nSub = n
					local power = 0
					local pTmp = 1
					while pTmp < nSub do
						pTmp = pTmp*2
						power = power+1
					end
					for i=1,power do
						table.insert(bitsOut, bit32.rshift(bit32.band(nSub, math.pow(2, power-i)), power-i))
					end
					local tmpBits = #bitsOut
					for i=tmpBits,self.tiffBitness,1 do table.insert(bitsOut, 1, 0) end
					return bitsOut
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
				if UI.clrcmd == "cls" then self.dirSeparator = "\\" else self.dirSeparator = "/" end
				if UI.clrcmd == "clear" then strOut = "."..self.dirSeparator end
				for i=1,#names-1 do
					strOut = strOut..names[i]..self.dirSeparator
				end
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

				if cursesstatus then curses.endwin() end
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
								fc.capitalregion = fr
								fc.capitalcity = s
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
						cp:setPop(self, _DEBUG and 100 or 300)

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
				if not country.alliances then return {} end
				local acOut = {}
				for i=1,#country.alliances do
					local c3 = nil
					for j, cp in pairs(self.thisWorld.countries) do if cp.name == country.alliances[i] then c3 = cp end end
					if c3 then for j=#c3.allyOngoing,1,-1 do if c3.allyOngoing[j] == event.."?"..country.name..":"..target.name then table.insert(acOut, c3) end end end
				end

				return acOut
			end,

			getAlphabetical = function(self, t)
				local data = t or self.thisWorld.countries
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

			getLanguage = function(self, r, nl)
				local id = self:demonym(r.name)
				for i=1,#self.languages do if self.languages[i].name == id then return self.languages[i] end end
				if r.language and r.language.name == id then
					table.insert(self.languages, 1, r.language)
					return r.language
				end

				if nl then
					if not nl.language then
						local newLang = Language:new()
						newLang:define(self)
						newLang.name = self:demonym(nl.name)
						table.insert(self.languages, 1, newLang)
						nl.language = newLang
						r.language = newLang
						return newLang
					end

					local newLang = nl.language:deviate(self)
					newLang.name = id
					r.language = newLang
					table.insert(self.languages, 1, newLang)
					return newLang
				end

				local newLang = Language:new()
				newLang:define(self)
				newLang.name = id
				table.insert(self.languages, 1, newLang)
				return newLang
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

			insertConflict = function(self, c1, c2)
				local i = 0
				for j=self.maxConflicts+1,1,-1 do if not self.conflicts[j] then i = j end end
				self.conflicts[i] = {c1, c2}
				self.maxConflicts = math.max(self.maxConflicts, #self.conflicts)
				return i
			end,

			loop = function(self)
				local _running = true
				local remainingYears = 1
				local msg = ""
				local cLimit = 16
				local eLimit = 6
				local writtenLines = {}

				self.thisWorld:constructVoxelPlanet(self)

				local stampDir = self:directory({self.stamp})
				self:checkDirectory(stampDir, "maps")
				self.thisWorld:mapOutput(self, self:directory({stampDir, "maps", "initial"}))

				collectgarbage("collect")

				self.gedFile = io.open(self:directory({self.stamp, "ged.dat"}), "a+")

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
							if not cp or not cp.ongoing then table.remove(self.alpha, i)
							else for j=1,#cp.ongoing do if cp.ongoing[j].eString then table.insert(currentEvents, cp.ongoing[j].eString) end end end
						end

						cLimit = getLineTolerance(#currentEvents+5)
						if #currentEvents == 0 then cLimit = cLimit-1 end
						cLimit = math.max(cLimit, math.floor(UI.y/2))
						eLimit = getLineTolerance(cLimit+5)

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
						if self.gedFile then
							self.gedFile:flush()
							self.gedFile:close()
							self.gedFile = nil
						end
						UI:printf("\nEnter a number of years to continue, or:")
						if _DEBUG then UI:printf("E to execute a line of Lua code.") end
						UI:printf("G to review family links and genealogical data.")
						UI:printf("L to compare the languages of this world.")
						UI:printf("R to record the event data at this point.")
						UI:printf("Q to exit.")
						UI:printp("\n > ")
						local datin = UI:readl()
						if tonumber(datin) then
							remainingYears = tonumber(datin)
							self.gedFile = io.open(self:directory({self.stamp, "ged.dat"}), "a+")
						elseif datin:lower() == "e" and _DEBUG then debugLine()
						elseif datin:lower() == "g" then
							local gf = io.open(self:directory({self.stamp, "ged.dat"}), "r")
							gedReview(gf)
							gf:close()
							gf = nil
						elseif datin:lower() == "l" then self:compLangs()
						elseif datin:lower() == "r" then self:finish(false)
						elseif datin:lower() == "q" then
							_running = false
							remainingYears = 1
						end

						if datin:lower() ~= "q" then
							UI:clear(true)
							UI:refresh()
							UI:printc(msg)
						end
					end
				end

				self.thisWorld:mapOutput(self, self:directory({self.stamp, "maps", "final"}))
				self:finish(true)

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

			nextGIndex = function(self)
				self.nextPerson = self.nextPerson+1
				return self.nextPerson-1
			end,

			ordinal = function(self, n)
				if not tonumber(n) then return n end
				local fin = ""

				local ts = tostring(n)
				if ts:sub(ts:len()-1, ts:len()-1) == "1" then fin = ts.."th" else
					if ts:sub(ts:len(), ts:len()) == "1" then fin = ts.."st"
					elseif ts:sub(ts:len(), ts:len()) == "2" then fin = ts.."nd"
					elseif ts:sub(ts:len(), ts:len()) == "3" then fin = ts.."rd"
					else fin = ts.."th" end
				end

				return fin
			end,

			randomChoice = function(self, t, doKeys)
				local t0 = _time()
				if not t then return nil end

				local keys = {}
				if t and #t ~= 0 then if doKeys then return math.random(1, #t) else return t[math.random(1, #t)] end end
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
						rn.nl = c1.name
						rn.population = 0
						for i, j in pairs(rn.cities) do j.nl = c1.name end

						c1.regions[rn.name] = rn
						c2.regions[rn.name] = nil

						for i=#c2.people,1,-1 do if c2.people[i] and c2.people[i].region and c2.people[i].region.name == rn.name then
							c2.people[i].region = nil
							c2.people[i].city = nil
							if not c2.people[i].isRuler then c1:add(self, c2.people[i]) end
						end end

						for i=1,#self.thisWorld.planetdefined do
							local xyz = self.thisWorld.planetdefined[i]

							if self.thisWorld.planet[xyz].country == c2.name and self.thisWorld.planet[xyz].region == rn.name then
								self.thisWorld.planet[xyz].country = c1.name
								self.thisWorld.planet[xyz].region = rn.name
							end
						end

						if not conq and c2.capitalregion.name == rn.name then
							local msg = "Capital moved from "..c2.capitalcity.name.." to "

							c2.capitalregion = nil
							c2.capitalcity = nil

							while not c2.capitalregion do c2.capitalregion = self:randomChoice(c2.regions) end
							while not c2.capitalcity do c2.capitalcity = self:randomChoice(c2.capitalregion.cities) end

							msg = msg..c2.capitalcity.name
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
				local n = tonumber(ts:reverse()) or tonumber(tostring(t0):reverse())
				math.randomseed(n)

				if _DEBUG then
					if not debugTimes["CCSCommon.rseed"] then debugTimes["CCSCommon.rseed"] = 0 end
					debugTimes["CCSCommon.rseed"] = debugTimes["CCSCommon.rseed"]+_time()-t0
				end
			end,

			strengthFactor = function(self, c)
				if not c then return 0 end
				local pop = 0
				if c.rulerParty then pop = c.rulerPopularity-50 end
				local involved = 0
				for i=1,self.maxConflicts do if self.conflicts[i] then for j=1,#self.conflicts[i] do if self.conflicts[i][j] == c.name then involved = involved+1 end end end end
				if involved == 0 then involved = 1 end
				involved = (involved == 1 and 1 or (involved*0.75))
				return (pop+(c.stability-50)+((((c.military/#c.people)*100)-50)))/involved
			end,

			tiffCodeFromString = function(self, str)
				if not self.tiffDict[str] then self.tiffNextCode = self.tiffNextCode+1 end
				return self.tiffDict[str] or self.tiffNextCode
			end,

			tiffFormat = function(self, arr, off, num, abs)
				for i=1,4 do if abs then arr[#arr-off+i-1] = num[i] else arr[off+i-1] = num[i] end end
			end,

			tiffInitialize = function(self)
				self.tiffBitness = 9
				self.tiffDict = {}
				for i=0,255 do self.tiffDict[string.char(i)] = i end
				self.tiffNextCode = 257
				return true
			end,

			tiffOut = function(self, label, data, w, h)
				local omega = ""
				local strip = 1
				local strips = {}
				local rowsPerStrip = math.ceil(2048/(w*3))
				local stripsPerImage = math.floor((h+rowsPerStrip-1)/rowsPerStrip)
				local bytesPerStrip = w*3*rowsPerStrip
				local tiffHeader = {0x49, 0x49, 0x2A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00}
				local compressedStrips = {}
				local tiffIFD = {0x0A, 0x00, 
					0x59, 0x02, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, -- Compression
					0x01, 0x01, 0x04, 0x00, 0x01, 0x00, 0x00, 0x00, bit32.band(255, h), bit32.band(255, bit32.rshift(h, 8)), bit32.band(255, bit32.rshift(h, 16)), bit32.band(255, bit32.rshift(h, 24)), -- Height
					0x00, 0x01, 0x04, 0x00, 0x01, 0x00, 0x00, 0x00, bit32.band(255, w), bit32.band(255, bit32.rshift(w, 8)), bit32.band(255, bit32.rshift(w, 16)), bit32.band(255, bit32.rshift(w, 24)), -- Width
					0x06, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, -- PhotometricInterpretation
					0x15, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, -- SamplesPerPixel
					0x1A, 0x01, 0x05, 0x00, 0x01, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, -- XResolution
					0x1B, 0x01, 0x05, 0x00, 0x01, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, -- YResolution
					0x02, 0x01, 0x03, 0x00, 0x03, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, -- BitsPerSample
					0x16, 0x01, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, -- RowsPerStrip
					0x11, 0x01, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, -- StripOffsets
					0x17, 0x01, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, -- StripByteCounts
					0x00, 0x00, 0x00, 0x00
					}
				for i=1,#data do
					if not strips[strip] then strips[strip] = {} end
					for j=1,#data[i] do
						table.insert(strips[strip], data[i][j][1])
						table.insert(strips[strip], data[i][j][2])
						table.insert(strips[strip], data[i][j][3])
					end
					if #strips[strip] >= bytesPerStrip then strip = strip+1 end
				end
				for i=1,#strips do
					local bitsWritten = 0
					local iStrip = strips[i]
					local stripCompressed = {}
					self:tiffInitialize()
					bitsWritten = bitsWritten+self:tiffWrite(stripCompressed, 256)
					for i=1,#iStrip do
						local K = iStrip[i]
						if self.tiffDict[omega..K] then omega = omega..K else
							bitsWritten = bitsWritten+self:tiffWrite(stripCompressed, self:tiffCodeFromString(omega))
							local code = self:tiffCodeFromString(omega..K)
							self.tiffDict[omega..K] = code
							if code >= 510 then self.tiffBitness = 10 end
							if code >= 1022 then self.tiffBitness = 11 end
							if code >= 2046 then self.tiffBitness = 12 end
							if code >= 4094 then return self:tiffInitialize() end
							omega = K
							if self.tiffNextCode == 4094 then bitsWritten = bitsWritten+self:tiffWrite(stripCompressed, self:tiffCodeFromString(omega), 12) end
						end
					end
					bitsWritten = bitsWritten+self:tiffWrite(stripCompressed, self:tiffCodeFromString(omega))
					bitsWritten = bitsWritten+self:tiffWrite(stripCompressed, 257)
					for i=1,8-math.fmod(bitsWritten, 8) do table.insert(stripCompressed, 0) end
					table.insert(compressedStrips, stripCompressed)
					local byteCount = self:deconstructNumber(#stripCompressed/8, true)
					for i=1,4 do table.insert(tiffHeader, byteCount[i] or 0x00) end
				end

				local fd = io.open(label..".tiff", "w+b")
				for i=1,4-math.fmod(#tiffHeader, 4) do table.insert(tiffHeader, 0x00) end
				local offOffset = #tiffHeader
				self:tiffFormat(tiffHeader, 19, self:deconstructNumber(offOffset, true), false)
				for i=1,#compressedStrips do for j=1,4 do table.insert(tiffHeader, 0x00) end end
				local totalOffset = #tiffHeader+#tiffIFD
				totalOffset = totalOffset+(4-math.fmod(totalOffset, 4))
				for i=1,#compressedStrips do
					self:tiffFormat(tiffHeader, offOffset+((i-1)*4), self:deconstructNumber(totalOffset, true), true)
					local adjust = 16-math.fmod(#compressedStrips[i], 16)
					totalOffset = totalOffset+((#compressedStrips[i]+adjust)/8)
					totalOffset = totalOffset+(16-math.fmod(totalOffset, 16))
				end
				local firstOff = self:deconstructNumber(#tiffHeader)
				self:tiffFormat(tiffHeader, 5, firstOff, true)
				for i=1,#tiffHeader do fd:write(string.char(tiffHeader[i] or 0x00)) end
				local stripCount = self:deconstructNumber(#compressedStrips, true)
				self:tiffFormat(tiffIFD, 11, stripCount, false)
				self:tiffFormat(tiffIFD, 23, stripCount, false)
				for i=1,#tiffIFD do fd:write(string.char(tiffIFD[i] or 0x00)) end
				for i=1,#compressedStrips do for j=1,#compressedStrips[i],8 do
					local tmpArr = {}
					for k=1,8 do table.insert(tmpArr, compressedStrips[i][j+k-1] or 0x00) end
					fd:write(string.char(self:constructNumber(tmpArr, true)))
				end end
				fd:flush()
				fd:close()
				fd = nil
			end,

			tiffWrite = function(self, stream, code, bitness)
				if not bitness then bitness = self.tiffBitness end
				local str = self:deconstructNumber(code, false)
				local strTmp = #str
				for i=strTmp,bitness do table.insert(str, 1, 0) end
				for i=1,#str do table.insert(stream, str[i]) end
				return bitness
			end
		}

		return CCSCommon
	end
