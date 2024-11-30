return
	function()
		local Person = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.addedToPop = false
				o.age = 0
				o.ancName = ""
				o.ancRoyal = false
				o.birth = 0
				o.birthplace = ""
				o.cbelief = 0
				o.children = {}
				o.cIndex = 0
				o.city = nil
				o.death = 0
				o.deathplace = ""
				o.def = true -- A utility variable used to set whether this person has been destroyed.
				o.descRoyal = false
				o.descWrite = 0
				o.ebelief = 0
				o.ethnicity = {}
				o.famc = ""
				o.fams = {}
				o.father = nil
				o.frugality = math.random(5, 85)/100
				o.gender = ""
				o.gIndex = 0
				o.gString = ""
				o.income = 0
				o.isRuler = false
				o.LastRoyalAncestor = ""
				o.level = 2
				o.lines = {}
				o.maternalLineTimes = math.huge
				o.military = false
				o.militaryTraining = 0
				o.mother = nil
				o.name = ""
				o.nationality = ""
				o.nativeLang = {}
				o.number = 0
				o.parentRuler = false
				o.party = ""
				o.pbelief = 0
				o.pIndex = 0
				o.prevtitle = "Citizen"
				o.recentbirth = false
				o.region = nil
				o.royalGenerations = math.huge
				o.royalSystem = ""
				o.ruledCountry = ""
				o.rulerName = ""
				o.rulerTitle = ""
				o.spokenLang = {}
				o.spouse = nil
				o.surname = ""
				o.title = "Citizen"
				o.wealth = 0

				return o
			end,

			destroy = function(self, parent, nl)
				self.age = nil
				self.cbelief = nil
				local chilCount = 0
				for i, j in pairs(self.children) do if j and j.def then chilCount = chilCount+1 end end
				for i, j in pairs(self.children) do if j and j.def then j.wealth = j.wealth+(self.wealth/chilCount) end end
				chilCount = nil
				self.children = nil
				if not self.deathplace or self.deathplace == "" then
					self.deathplace = nl.name
					if self.region and self.region.cities then self.deathplace = self.region.name..", "..self.deathplace end
					if self.city then self.deathplace = self.city.name..", "..self.deathplace end
				end
				for i, j in pairs(self.lines) do if parent.final[j] and parent.final[j].locIndices[self.gString] then
					if parent.final[j].lineOfSuccession[parent.final[j].locIndices[self.gString]] and parent.final[j].lineOfSuccession[parent.final[j].locIndices[self.gString]].gString == self.gString then parent.final[j]:successionRemove(parent, self) end
					parent.final[j].locIndices[self.gString] = nil
				end end
				self.city = nil
				self.death = parent.years
				if not parent.places[self.deathplace] then
					parent.places[self.deathplace] = self.gIndex
					parent.gedFile:write("y "..tostring(self.gIndex).." "..tostring(self.deathplace).."\n")
				end
				parent.gedFile:write(tostring(self.gIndex).." d "..tostring(self.death).."\n")
				parent.gedFile:write("e "..tostring(parent.places[self.deathplace]).."\n")
				parent.gedFile:write("w "..tostring(math.floor(self.wealth*1000)).."\n")
				parent.gedFile:flush()
				self.city = nil
				self.def = nil -- See above.
				self.ebelief = nil
				parent:deepnil(self.ethnicity)
				self.father = nil
				self.frugality = nil
				self.income = nil
				self.isRuler = nil
				self.level = nil
				self.lines = nil
				self.military = nil
				self.militaryTraining = nil
				self.mother = nil
				self.nationality = nil
				self.parentRuler = nil
				self.party = nil
				self.pbelief = nil
				self.prevtitle = nil
				self.recentbirth = nil
				self.region = nil
				self.royalSystem = nil
				self.ruledCountry = nil
				if self.spouse and self.spouse.def then self.spouse.spouse = nil end
				self.spouse = nil
				self.title = nil
				self.wealth = nil
			end,

			dobirth = function(self, parent, nl)
				local t0 = _time()

				if not self.spouse or not self.spouse.def then return nil end

				if self.age < 15 or self.age > (self.gender == "M" and 65 or 55) then return nil end
				if self.spouse.age < 15 or self.spouse.age > (self.spouse.gender == "M" and 65 or 55) then return nil end

				local nn = Person:new()
				local nFound = true
				while nFound do
					nn:makename(parent, nl)
					nFound = false
					for i, j in pairs(self.children) do if j.name == nn.name then nFound = true end end
					for i, j in pairs(self.spouse.children) do if j.name == nn.name then nFound = true end end
				end

				nn.pbelief = (self.pbelief + self.spouse.pbelief) / 2
				nn.ebelief = (self.ebelief + self.spouse.ebelief) / 2
				nn.cbelief = (self.cbelief + self.spouse.cbelief) / 2

				if self.gender == "M" then
					nn.surname = self.surname
					nn.ancName = self.ancName
					self.region = self.spouse.region or self.region
					self.city = self.spouse.city or self.city
					self.spouse.region = self.region or self.spouse.region
					self.spouse.city = self.city or self.spouse.city
					nn.region = self.region
					nn.city = self.city
				else
					nn.surname = self.spouse.surname
					nn.ancName = self.spouse.ancName
					self.spouse.region = self.region or self.spouse.region
					self.spouse.city = self.city or self.spouse.city
					self.region = self.spouse.region or self.region
					self.city = self.spouse.city or self.city
					nn.region = self.spouse.region
					nn.city = self.spouse.city
				end

				if self.royalGenerations < 6 and self.spouse.royalGenerations < 6 and self.surname ~= self.spouse.surname and self.ancName ~= self.spouse.ancName then
					local surnames = {}

					if self.royalGenerations < self.spouse.royalGenerations then surnames = {self.surname:gmatch("%a+")(), self.spouse.surname:gmatch("%a+")()}
					elseif self.royalGenerations > self.spouse.royalGenerations then surnames = {self.spouse.surname:gmatch("%a+")(), self.surname:gmatch("%a+")()}
					else
						if self.gender == "M" then surnames = {self.surname:gmatch("%a+")(), self.spouse.surname:gmatch("%a+")()}
						else surnames = {self.spouse.surname:gmatch("%a+")(), self.surname:gmatch("%a+")()} end
					end

					if surnames[1] ~= surnames[2] then nn.surname = surnames[1].."-"..surnames[2] else nn.surname = surnames[1] end
				end

				local modChance = math.random(1, 50000)
				if modChance > 1024 and modChance < 1206 then
					local op = parent:randomChoice{Language.consonants, Language.vowels}
					local o1, o2 = -1, -1
					while o1 == o2 do
						o1 = parent:randomChoice(op, true)
						o2 = parent:randomChoice(op, true)
					end
					local segments = {}
					for x in nn.surname:gmatch("%a+") do table.insert(segments, parent:namecheck(x:gsub(op[o1], op[o2], 1))) end
					nn.surname = ""
					for x=1,#segments-1 do nn.surname = nn.surname..segments[x].."-" end
					nn.surname = string.stripDiphs(nn.surname..segments[#segments])
				end

				if self.royalGenerations < math.huge or self.spouse.royalGenerations < math.huge then
					if self.spouse.royalGenerations < self.royalGenerations then
						nn.royalGenerations = self.spouse.royalGenerations+1
						nn.royalSystem = self.spouse.royalSystem
						nn.LastRoyalAncestor = self.spouse.LastRoyalAncestor
						if self.spouse.gender == "F" then nn.maternalLineTimes = self.spouse.maternalLineTimes+1 end
					else
						nn.royalGenerations = self.royalGenerations+1
						nn.royalSystem = self.royalSystem
						nn.LastRoyalAncestor = self.LastRoyalAncestor
						if self.gender == "F" then nn.maternalLineTimes = self.maternalLineTimes+1 end
					end
				end

				if self.royalGenerations == 0 then
					if self.gender == "M" then nn.maternalLineTimes = 0 end
					nn.royalGenerations = 1
					nn.royalSystem = self.royalSystem
					nn.LastRoyalAncestor = self.rulerTitle.." "..self.rulerName.." "..parent:roman(self.number).." of "..self.ruledCountry
				elseif self.spouse.royalGenerations == 0 then
					if self.gender == "F" then nn.maternalLineTimes = 0 end
					nn.royalGenerations = 1
					nn.royalSystem = self.spouse.royalSystem
					nn.LastRoyalAncestor = self.spouse.rulerTitle.." "..self.spouse.rulerName.." "..parent:roman(self.spouse.number).." of "..self.spouse.ruledCountry
				end

				local sys = parent.systems[nl.system]
				if nn.gender == "M" or not sys.dynastic then nn.title = sys.ranks[nn.level] else nn.title = sys.franks[nn.level] end

				for i, j in pairs(self.ethnicity) do nn.ethnicity[i] = j end
				for i, j in pairs(self.spouse.ethnicity) do
					if not nn.ethnicity[i] then nn.ethnicity[i] = 0 end
					nn.ethnicity[i] = nn.ethnicity[i]+j
				end
				for i, j in pairs(nn.ethnicity) do nn.ethnicity[i] = nn.ethnicity[i]/2 end

				nn.birthplace = nl.name
				if nn.region then nn.birthplace = nn.region.name..", "..nn.birthplace end
				if nn.city then nn.birthplace = nn.city.name..", "..nn.birthplace end
				nn.age = 0
				nn.gString = nn.gender.." "..nn.name.." "..nn.surname.." "..nn.birth.." "..nn.birthplace
				nn.nationality = nl.name
				nn.gIndex = parent:nextGIndex()

				if self.gender == "F" then nn:SetFamily(self.spouse, self, nl, parent)
				else nn:SetFamily(self, self.spouse, nl, parent) end

				nl:add(parent, nn)

				if self.isRuler or self.spouse.isRuler then
					nn.level = self.level-1
					nn.parentRuler = true
				elseif self.level > self.spouse.level then nn.level = self.level else nn.level = self.spouse.level end

				for i, j in pairs(self.lines) do if parent.final[j] and parent.final[j].locIndices[self.gString] then
					if self.spouse.lines[i] and parent.final[j].locIndices[self.spouse.gString] and parent.final[j].locIndices[self.spouse.gString] < parent.final[j].locIndices[self.gString] then parent.final[j]:recurseRoyalChildren(self.spouse)
					else parent.final[j]:recurseRoyalChildren(self) end
				end end

				if not parent.places[nn.birthplace] then
					parent.places[nn.birthplace] = nn.gIndex
					parent.gedFile:write("y "..tostring(nn.gIndex).." "..tostring(nn.birthplace).."\n")
				end
				parent.gedFile:write(tostring(nn.gIndex).." b "..tostring(parent.years).."\n")
				parent.gedFile:write("c "..tostring(parent.places[nn.birthplace]).."\n")
				parent.gedFile:write("g "..tostring(nn.gender).."\n")
				parent.gedFile:write("n "..tostring(nn.name).."\n")
				parent.gedFile:write("s "..tostring(nn.surname).."\n")
				for i, j in pairs(nn.ethnicity) do
					if not parent.demonyms[i] then
						parent.demonyms[i] = nn.gIndex
						parent.gedFile:write("z "..tostring(nn.gIndex).." "..tostring(i).."\n")
					end
					if j > 0.08 then
						local pct = string.format("%.2f", j)
						for k=1,3 do if pct:sub(pct:len(), pct:len()) == "0" or pct:sub(pct:len(), pct:len()) == "." then pct = pct:sub(1, pct:len()-1) end end
						parent.gedFile:write("l "..pct.."% "..tostring(parent.demonyms[i]).."\n")
					end
				end
				parent.gedFile:flush()

				if _DEBUG then
					if not debugTimes["Person.dobirth"] then debugTimes["Person.dobirth"] = 0 end
					debugTimes["Person.dobirth"] = debugTimes["Person.dobirth"]+_time()-t0
				end
			end,

			makename = function(self, parent, nl)
				local t0 = _time()

				self.name = parent:name(true)
				self.surname = parent:name(true)

				if math.random(1, 1000) < 501 then self.gender = "M" else self.gender = "F" end

				self.pbelief = math.random(1, 100)
				self.ebelief = math.random(1, 100)
				self.cbelief = math.random(1, 100)

				self.birth = parent.years
				if self.title == "" then
					self.level = 2
					self.title = "Citizen"
				end

				if _DEBUG then
					if not debugTimes["Person.makename"] then debugTimes["Person.makename"] = 0 end
					debugTimes["Person.makename"] = debugTimes["Person.makename"]+_time()-t0
				end

			end,

			SetFamily = function(self, father, mother, nl, parent)
				table.insert(father.children, self)
				table.insert(mother.children, self)
				self.father = father
				self.mother = mother

				parent.gedFile:write(tostring(self.gIndex).." m "..tostring(mother.gIndex).."\n")
				parent.gedFile:write("f "..tostring(father.gIndex).."\n")
				parent.gedFile:flush()

				local natLang = {}
				local spokeLang = {}

				local natLangs = 0
				local spokeLangs = 0

				if father.nativeLang then for i=1,#father.nativeLang do if father.nativeLang[i] and not natLang[father.nativeLang[i].name] then natLangs = natLangs+1 natLang[father.nativeLang[i].name] = parent:getLanguage(father.nativeLang[i], nl, true) end end end
				if father.spokenLang then for i=1,#father.spokenLang do if father.spokenLang[i] and not spokeLang[father.spokenLang[i].name] then spokeLangs = spokeLangs+1 spokeLang[father.spokenLang[i].name] = parent:getLanguage(father.spokenLang[i], nl, true) end end end
				if mother.nativeLang then for i=1,#mother.nativeLang do if mother.nativeLang[i] and not natLang[mother.nativeLang[i].name] then natLangs = natLangs+1 natLang[mother.nativeLang[i].name] = parent:getLanguage(mother.nativeLang[i], nl, true) end end end
				if mother.spokenLang then for i=1,#mother.spokenLang do if mother.spokenLang[i] and not spokeLang[mother.spokenLang[i].name] then spokeLangs = spokeLangs+1 spokeLang[mother.spokenLang[i].name] = parent:getLanguage(mother.spokenLang[i], nl, true) end end end

				if self.region then
					local flString = self.region.language.name.." ("..(self.region.language.eml == 1 and "E." or (self.region.language.eml == 2 and "M." or "L.")).."P. "..tostring(self.region.language.period)..")"
					if not parent.fileLangs[flString] then
						local lCount = 0
						for i, j in pairs(parent.fileLangs) do lCount = lCount+1 end
						parent.fileLangs[flString] = lCount+1
						parent.gedFile:write("j "..tostring(parent.fileLangs[flString]).." "..flString.."\n")
					end
					table.insert(self.nativeLang, self.region.language)
					parent.gedFile:write(tostring(self.gIndex).." i "..tostring(parent.fileLangs[flString]).."\n")
				end
				local maxNatLangs = math.min(math.random(1, 2), natLangs)
				local maxSpokenLangs = math.min(math.random(0, 3-maxNatLangs), spokeLangs)
				local cycles = 0
				while #self.nativeLang < maxNatLangs do
					local choice = parent:getLanguage(parent:randomChoice(natLang), nl, true)
					if choice and not table.contains(self.nativeLang, choice) and not table.contains(self.spokenLang, choice) then
						local flString = choice.name.." ("..(choice.eml == 1 and "E." or (choice.eml == 2 and "M." or "L.")).."P. "..tostring(choice.period)..")"
						local inherit = math.random(1, 100)
						if inherit < 81 then
							inherit = math.random(1, 100)
							if inherit < 21 then
								table.insert(self.spokenLang, choice)
								if not parent.fileLangs[flString] then
									local lCount = 0
									for i, j in pairs(parent.fileLangs) do lCount = lCount+1 end
									parent.fileLangs[flString] = lCount+1
									parent.gedFile:write("j "..tostring(parent.fileLangs[flString]).." "..flString.."\n")
								end
								parent.gedFile:write("h "..tostring(parent.fileLangs[flString]).."\n")
								maxNatLangs = maxNatLangs-1
								natLang[choice.name] = nil
							else
								table.insert(self.nativeLang, choice)
								if not parent.fileLangs[flString] then
									local lCount = 0
									for i, j in pairs(parent.fileLangs) do lCount = lCount+1 end
									parent.fileLangs[flString] = lCount+1
									parent.gedFile:write("j "..tostring(parent.fileLangs[flString]).." "..flString.."\n")
								end
								parent.gedFile:write("i "..tostring(parent.fileLangs[flString]).."\n")
								natLang[choice.name] = nil
							end
						end
					end
					cycles = cycles+1
					if cycles >= 20 then maxNatLangs = -1 end
				end
				cycles = 0
				while #self.spokenLang < maxSpokenLangs do
					local choice = parent:getLanguage(parent:randomChoice(spokeLang), nl, true)
					if choice and not table.contains(self.nativeLang, choice) and not table.contains(self.spokenLang, choice) then
						local flString = choice.name.." ("..(choice.eml == 1 and "E." or (choice.eml == 2 and "M." or "L.")).."P. "..tostring(choice.period)..")"
						local inherit = math.random(1, 100)
						if inherit < 21 then
							inherit = math.random(1, 100)
							if inherit < 51 then
								table.insert(self.nativeLang, choice)
								if not parent.fileLangs[flString] then
									local lCount = 0
									for i, j in pairs(parent.fileLangs) do lCount = lCount+1 end
									parent.fileLangs[flString] = lCount+1
									parent.gedFile:write("j "..tostring(parent.fileLangs[flString]).." "..flString.."\n")
								end
								parent.gedFile:write("i "..tostring(parent.fileLangs[flString]).."\n")
								maxSpokenLangs = maxSpokenLangs-1
								spokeLang[choice.name] = nil
							else
								table.insert(self.spokenLang, choice)
								if not parent.fileLangs[flString] then
									local lCount = 0
									for i, j in pairs(parent.fileLangs) do lCount = lCount+1 end
									parent.fileLangs[flString] = lCount+1
									parent.gedFile:write("j "..tostring(parent.fileLangs[flString]).." "..flString.."\n")
								end
								parent.gedFile:write("h "..tostring(parent.fileLangs[flString]).."\n")
								spokeLang[choice.name] = nil
							end
						end
					end
					cycles = cycles+1
					if cycles >= 20 then maxSpokenLangs = -1 end
				end
			end,

			update = function(self, parent, nl)
				local t0 = _time()

				if not self.def then return end

				if not self.addedToPop then
					parent.popCount = parent.popCount+1
					self.addedToPop = true
				end

				self.age = parent.years-self.birth
				if self.birth <= -1 then self.age = self.age-1 end

				if not self.birthplace or self.birthplace == "" then self.birthplace = nl.name end
				self.deathplace = nl.name
				if not self.surname or self.surname == "" then self.surname = parent:name(true) end
				if not self.ancName or self.ancName == "" then self.ancName = self.surname end

				if self.age > 14 then
					if math.random(1, self.age < 28 and 600 or 3200) == 435 then self.city = nil end
					if math.random(1, self.age < 28 and 1800 or 8400) == 435 then self.region = nil end
				end

				if not self.region or not self.region.cities or not self.city then
					self.region = parent:randomChoice(nl.regions)
					self.city = nil
				end

				if self.region then
					if not self.region.language then self.region.language = parent:getLanguage(self.region, nl) end
					
					if not self.nativeLang or #self.nativeLang == 0 then
						self.nativeLang = {self.region.language}
						local flString = self.region.language.name.." ("..(self.region.language.eml == 1 and "E." or (self.region.language.eml == 2 and "M." or "L.")).."P. "..tostring(self.region.language.period)..")"
						if not parent.fileLangs[flString] then
							local lCount = 0
							for i, j in pairs(parent.fileLangs) do lCount = lCount+1 end
							parent.fileLangs[flString] = lCount+1
							parent.gedFile:write("j "..tostring(parent.fileLangs[flString]).." "..flString.."\n")
						end
						parent.gedFile:write(tostring(self.gIndex).." i "..tostring(parent.fileLangs[flString]).."\n")
					end
					
					local langFound = false
					for i=1,#self.nativeLang do if self.nativeLang[i].name == self.region.language.name then langFound = true end end
					if not langFound then for i=1,#self.spokenLang do if self.spokenLang[i].name == self.region.language.name then langFound = true end end end
					if not langFound then
						local langChance = math.random(1, 10)
						if langChance == 5 then
							table.insert(self.spokenLang, self.region.language)
							local flString = self.region.language.name.." ("..(self.region.language.eml == 1 and "E." or (self.region.language.eml == 2 and "M." or "L.")).."P. "..tostring(self.region.language.period)..")"
							if not parent.fileLangs[flString] then
								local lCount = 0
								for i, j in pairs(parent.fileLangs) do lCount = lCount+1 end
								parent.fileLangs[flString] = lCount+1
								parent.gedFile:write("j "..tostring(parent.fileLangs[flString]).." "..flString.."\n")
							end
							parent.gedFile:write(tostring(self.gIndex).." h "..tostring(parent.fileLangs[flString]).."\n")
						end
					end
					
					if not self.city then self.city = parent:randomChoice(self.region.cities) end
					
					self.region.population = self.region.population+1
					self.deathplace = self.region.name..", "..self.deathplace
				end

				if self.city then
					self.city.population = self.city.population+1
					self.deathplace = self.city.name..", "..self.deathplace
					if self.spouse then
						self.spouse.region = self.region
						self.spouse.city = self.city
					end
				end

				if self.isRuler then
					self.region = nl.capitalregion or self.region
					self.city = nl.capitalcity or self.city
					if self.spouse then
						self.spouse.region = self.region
						self.spouse.city = self.city
					end
				end

				local sys = parent.systems[nl.system]

				local rankLim = 2
				if not sys.dynastic then rankLim = 1 end

				local ranks = sys.ranks
				if sys.dynastic and self.gender == "F" then ranks = sys.franks end

				if self.title and self.level then
					if self.level < #ranks-rankLim then
						local x = math.random(-100+#ranks-self.level, 100-self.level)
						if x < -85 then
							self.prevtitle = self.title
							self.level = self.level-1
						elseif x > 85 then
							self.prevtitle = self.title
							self.level = self.level+1
						end
					end

					self.level = math.max(1, self.level)
					if self.level >= #ranks-rankLim then self.level = #ranks-rankLim end
					if self.isRuler then self.level = #ranks end
					if self.parentRuler and sys.dynastic then self.level = #ranks-1 end
				else self.level = 2 end

				self.title = ranks[self.level]
				self.income = (self.level == 1 and 0 or 0.1*(self.level-1))+((nl.oldIncome[self.level-1] or 0)/(nl.oldIncomeLevels[self.level] or 1))
				self.income = self.income*math.random(0.7, 1.3)
				self.wealth = (self.wealth+self.income*(1-nl.taxRate))*self.frugality
				nl.income[self.level] = (nl.income[self.level] or 0)+self.income*nl.taxRate
				nl.incomeLevels[self.level] = (nl.incomeLevels[self.level] or 0)+1

				if not self.spouse or not self.spouse.def or not self.spouse.spouse or not self.spouse.spouse.def or self.spouse.spouse.gString ~= self.gString then if self.age > 15 and math.random(1, 4) == 2 then
					local m = parent:randomChoice(nl.people)
					local levelAdj = math.abs(self.level-m.level)+1
					if m.def and m.age > 15 and not m.spouse and self.gender ~= m.gender and math.random(1, 2*levelAdj) == 1 then
						local found = false
						if self.surname == m.surname then found = true end
						if not found then for i, j in pairs(self.children) do if j.gString == m.gString or j.surname == m.surname then found = true end end end
						if not found then for i, j in pairs(m.children) do if j.gString == self.gString or j.surname == self.surname then found = true end end end
						if not found then
							self.spouse = m
							m.spouse = self
						end
					end
				end end

				if not self.recentbirth and self.spouse and math.random(1, nl.birthrate) == 2 then
					self:dobirth(parent, nl)
					self.spouse.recentbirth = true
				end

				self.recentbirth = false

				self.pbelief = math.min(math.max(self.pbelief + math.random(-5, 5)/10, 1), 100)
				self.ebelief = math.min(math.max(self.ebelief + math.random(-5, 5)/10, 1), 100)
				self.cbelief = math.min(math.max(self.cbelief + math.random(-5, 5)/10, 1), 100)

				if not self.party or self.party == "" then
					local pmatch = nil

					for i, j in pairs(nl.parties) do if j and not pmatch then
						pmatch = j
						if math.abs(j.pfreedom-self.pbelief) > 50 then pmatch = nil end
						if math.abs(j.efreedom-self.ebelief) > 50 then pmatch = nil end
						if math.abs(j.cfreedom-self.cbelief) > 50 then pmatch = nil end
					end end

					if not pmatch then
						local newp = Party:new()
						newp:makename(parent, nl)
						newp.cfreedom = self.cbelief
						newp.efreedom = self.ebelief
						newp.pfreedom = self.pbelief
						local belieftotal = newp.cfreedom+newp.efreedom+newp.pfreedom
						if belieftotal > 200 then newp.radical = true end

						nl.parties[newp.name] = newp
						pmatch = nl.parties[newp.name]
					end

					self.party = pmatch.name
				end

				if self.isRuler then
					nl.rulers[#nl.rulers].party = self.party
					nl.rulerParty = nl.parties[self.party]
					if nl.rulerParty then nl.rulerParty.lastRuled = parent.years end
				end

				for i, j in pairs(nl.parties) do
					local pTotal = math.abs(j.pfreedom-self.pbelief)
					local eTotal = math.abs(j.efreedom-self.ebelief)
					local cTotal = math.abs(j.cfreedom-self.cbelief)
					j.popularity = j.popularity + (pTotal+eTotal+cTotal)/(3*nl.population)
				end

				if nl.rulerParty then
					local pTotal = nl.rulerParty.pfreedom-self.pbelief
					local eTotal = nl.rulerParty.efreedom-self.ebelief
					local cTotal = nl.rulerParty.cfreedom-self.cbelief
					local diffTotal = math.abs(pTotal)+math.abs(eTotal)+math.abs(cTotal)
					nl.rulerPopularity = nl.rulerPopularity+((100-diffTotal)/#nl.people)
				end

				if self.military then
					self.militaryTraining = self.militaryTraining+1
					nl.strength = nl.strength+self.militaryTraining
				else
					if not military and self.age > 14 and self.age < 35 then
						if math.random(1, 250) < nl.milThreshold then
							self.military = true
							self.militaryTraining = 0
						end
					elseif self.age > 55 then self.military = false end
				end

				local lEth = parent:randomChoice(self.ethnicity, true)
				local lEthVal = self.ethnicity[lEth]

				for i, j in pairs(self.ethnicity) do
					if not nl.ethnicities[i] then nl.ethnicities[i] = 0 end
					if j >= lEthVal then
						lEth = i
						lEthVal = j
					end
				end

				nl.ethnicities[lEth] = nl.ethnicities[lEth]+1

				for i, j in pairs(self.nativeLang) do
					j.l1Speakers = j.l1Speakers+1
					for k=1,#parent.languages do if parent.languages[k].name == j.name and parent.languages[k].eml ~= j.eml then parent.languages[k].l1Speakers = parent.languages[k].l1Speakers+1 end end
				end
				for i, j in pairs(self.spokenLang) do
					j.l2Speakers = j.l2Speakers+1
					for k=1,#parent.languages do if parent.languages[k].name == j.name and parent.languages[k].eml ~= j.eml then parent.languages[k].l2Speakers = parent.languages[k].l2Speakers+1 end end
				end

				if _DEBUG then
					if not debugTimes["Person.update"] then debugTimes["Person.update"] = 0 end
					debugTimes["Person.update"] = debugTimes["Person.update"]+_time()-t0
				end
			end
		}

		Person.__index = Person
		Person.__call = function() return Person:new() end

		return Person
	end
