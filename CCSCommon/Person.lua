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
				o.cFamc = 0
				o.cFams = {}
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
				o.gender = ""
				o.gIndex = 0
				o.gString = ""
				o.inSuccession = false
				o.isRuler = false
				o.LastRoyalAncestor = ""
				o.level = 2
				o.maternalLineTimes = math.huge
				o.military = false
				o.militaryTraining = 0
				o.mother = nil
				o.name = ""
				o.nationality = ""
				o.nativeLang = {}
				o.number = 0
				o.numChildren = 0
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

				return o
			end,

			destroy = function(self, parent, nl)
				for i=#nl.lineOfSuccession,1,-1 do if nl.lineOfSuccession[i].gIndex == self.gIndex then table.remove(nl.lineOfSuccession, i) end end
				self.age = nil
				self.cbelief = nil
				self.children = nil
				self.city = nil
				self.death = parent.years
				self.deathplace = nl.name
				parent.gedFile:write(tostring(self.gIndex).." d "..tostring(self.death).."\n")
				parent.gedFile:write(tostring(self.gIndex).." e "..tostring(self.deathplace).."\n")
				self.def = nil -- See above.
				self.ebelief = nil
				parent:deepnil(self.ethnicity)
				self.father = nil
				self.isRuler = nil
				self.level = nil
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
			end,

			dobirth = function(self, parent, nl)
				local t0 = _time()

				if not self.spouse or not self.spouse.def then return nil end

				if self.gender == "M" then if self.age < 14 or self.age > 65 then return nil end
				elseif self.gender == "F" then if self.age < 14 or self.age > 55 then return nil end end

				if self.spouse.gender == "M" then if self.spouse.age < 14 or self.spouse.age > 65 then return nil end
				elseif self.spouse.gender == "F" then if self.spouse.age < 14 or self.spouse.age > 55 then return nil end end

				local nn = Person:new()
				local nFound = true
				while nFound do
					nn:makename(parent, nl)
					nFound = false
					for i, j in pairs(self.children) do if j.name == nn.name then nFound = true end end
					for i, j in pairs(self.spouse.children) do if j.name == nn.name then nFound = true end end
				end

				if self.gender == "M" then
					nn.surname = self.surname
					nn.ancName = self.ancName
				else
					nn.surname = self.spouse.surname
					nn.ancName = self.spouse.ancName
				end

				if self.royalGenerations < 5 and self.spouse.royalGenerations < 5 and self.surname ~= self.spouse.surname then
					local surnames = {}

					if self.royalGenerations < self.spouse.royalGenerations then surnames = {self.surname:gmatch("%a+")(), self.spouse.surname:gmatch("%a+")()}
					elseif self.royalGenerations > self.spouse.royalGenerations then surnames = {self.spouse.surname:gmatch("%a+")(), self.surname:gmatch("%a+")()}
					else
						if self.gender == "M" then surnames = {self.surname:gmatch("%a+")(), self.spouse.surname:gmatch("%a+")()}
						else surnames = {self.spouse.surname:gmatch("%a+")(), self.surname:gmatch("%a+")()} end
					end

					if surnames[1] ~= surnames[2] and self.ancName ~= self.spouse.ancName then nn.surname = surnames[1].."-"..surnames[2] else nn.surname = surnames[1] end
				end

				local modChance = math.random(1, 50000)
				if modChance > 1024 and modChance < 1206 then
					local op = parent:randomChoice({parent.consonants, parent.vowels})
					local o1 = -1
					local o2 = -1
					while o1 == o2 do
						o1 = parent:randomChoice(op, true)
						o2 = parent:randomChoice(op, true)
					end
					local segments = {}
					for x in nn.surname:gmatch("%a+") do table.insert(segments, parent:namecheck(x:gsub(op[o1], op[o2], 1))) end
					nn.surname = ""
					for x=1,#segments-1 do nn.surname = nn.surname..segments[x].."-" end
					nn.surname = nn.surname..segments[#segments]
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

				nn.region = self.region
				nn.city = self.city
				nn.birthplace = nl.name
				nn.age = 0
				nn.gString = nn.gender.." "..nn.name.." "..nn.surname.." "..nn.birth.." "..nn.birthplace
				nn.nationality = nl.name
				nn.gIndex = parent:nextGIndex()

				if self.gender == "F" then nn:SetFamily(self.spouse, self, parent)
				else nn:SetFamily(self, self.spouse, parent) end

				nl:add(parent, nn)

				if self.isRuler or self.spouse.isRuler then
					nn.level = self.level-1
					nn.parentRuler = true
				elseif self.level > self.spouse.level then nn.level = self.level else nn.level = self.spouse.level end

				local selfSucc = math.huge
				local spouseSucc = math.huge
				
				if self.inSuccession then for i=#nl.lineOfSuccession,1,-1 do if selfSucc == math.huge and nl.lineOfSuccession[i].gIndex == self.gIndex then selfSucc = i end end end
				if self.spouse.inSuccession then for i=#nl.lineOfSuccession,1,-1 do if spouseSucc == math.huge and nl.lineOfSuccession[i].gIndex == self.spouse.gIndex then spouseSucc = i end end end
				if self.isRuler then selfSucc = 0 end
				if self.spouse.isRuler then spouseSucc = 0 end
				
				if selfSucc < math.huge then for i=1,#self.children do self.children[i].inSuccession = false end end
				if spouseSucc < math.huge then for i=1,#self.spouse.children do self.spouse.children[i].inSuccession = false end end
				
				if selfSucc < math.huge then
					for i=#nl.lineOfSuccession,1,-1 do
						if nl.lineOfSuccession[i].father and nl.lineOfSuccession[i].father.gIndex == self.gIndex then table.remove(nl.lineOfSuccession, i)
						elseif nl.lineOfSuccession[i].mother and nl.lineOfSuccession[i].mother.gIndex == self.gIndex then table.remove(nl.lineOfSuccession, i) end
					end
					nl:recurseRoyalChildren(self, selfSucc)
				end
				
				if spouseSucc < math.huge then
					for i=#nl.lineOfSuccession,1,-1 do
						if nl.lineOfSuccession[i].father and nl.lineOfSuccession[i].father.gIndex == self.spouse.gIndex then table.remove(nl.lineOfSuccession, i)
						elseif nl.lineOfSuccession[i].mother and nl.lineOfSuccession[i].mother.gIndex == self.spouse.gIndex then table.remove(nl.lineOfSuccession, i) end
					end
					nl:recurseRoyalChildren(self.spouse, spouseSucc)
				end

				parent.gedFile:write(tostring(nn.gIndex).." b "..tostring(parent.years).."\n")
				parent.gedFile:write(tostring(nn.gIndex).." c "..tostring(nn.birthplace).."\n")
				parent.gedFile:write(tostring(nn.gIndex).." g "..tostring(nn.birthplace).."\n")
				parent.gedFile:write(tostring(nn.gIndex).." n "..tostring(nn.name).."\n")
				parent.gedFile:write(tostring(nn.gIndex).." s "..tostring(nn.surname).."\n")

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

			SetFamily = function(self, father, mother, parent)
				table.insert(father.children, self)
				table.insert(mother.children, self)
				self.father = father
				self.mother = mother

				parent.gedFile:write(tostring(self.gIndex).." m "..tostring(mother.gIndex).."\n")
				parent.gedFile:write(tostring(self.gIndex).." f "..tostring(father.gIndex).."\n")

				local natLang = {}
				local spokeLang = {}

				local natLangs = 0
				local spokeLangs = 0

				if father.nativeLang then for i=1,#father.nativeLang do if father.nativeLang[i] and father.nativeLang[i].name ~= self.region.language.name and not natLang[father.nativeLang[i].name] then natLangs = natLangs+1 natLang[father.nativeLang[i].name] = father.nativeLang[i] end end end
				if father.spokenLang then for i=1,#father.spokenLang do if father.spokenLang[i] and father.spokenLang[i].name ~= self.region.language.name and not spokeLang[father.spokenLang[i].name] then spokeLangs = spokeLangs+1 spokeLang[father.spokenLang[i].name] = father.spokenLang[i] end end end
				if mother.nativeLang then for i=1,#mother.nativeLang do if mother.nativeLang[i] and mother.nativeLang[i].name ~= self.region.language.name and not natLang[mother.nativeLang[i].name] then natLangs = natLangs+1 natLang[mother.nativeLang[i].name] = mother.nativeLang[i] end end end
				if mother.spokenLang then for i=1,#mother.spokenLang do if mother.spokenLang[i] and mother.spokenLang[i].name ~= self.region.language.name and not spokeLang[mother.spokenLang[i].name] then spokeLangs = spokeLangs+1 spokeLang[mother.spokenLang[i].name] = mother.spokenLang[i] end end end

				table.insert(self.nativeLang, self.region.language)
				local maxNatLangs = math.random(1, 2)
				if maxNatLangs > natLangs then maxNatLangs = natLangs end
				local maxSpokenLangs = math.random(0, 3-maxNatLangs)
				if maxSpokenLangs > spokeLangs then maxSpokenLangs = spokeLangs end
				local cycles = 0
				while #self.nativeLang < maxNatLangs do
					local choice = parent:randomChoice(natLang)
					if choice and not table.contains(self.nativeLang, choice) and not table.contains(self.spokenLang, choice) then
						local inherit = math.random(1, 100)
						if inherit < 81 then
							inherit = math.random(1, 100)
							if inherit < 21 then
								table.insert(self.spokenLang, choice)
								maxNatLangs = maxNatLangs-1
								natLang[choice.name] = nil
							else
								table.insert(self.nativeLang, choice)
								natLang[choice.name] = nil
							end
						end
					end
					cycles = cycles+1
					if cycles >= 20 then maxNatLangs = -1 end
				end
				cycles = 0
				while #self.spokenLang < maxSpokenLangs do
					local choice = parent:randomChoice(spokeLang)
					if choice and not table.contains(self.nativeLang, choice) and not table.contains(self.spokenLang, choice) then
						local inherit = math.random(1, 100)
						if inherit < 21 then
							inherit = math.random(1, 100)
							if inherit < 51 then
								table.insert(self.nativeLang, choice)
								maxSpokenLangs = maxSpokenLangs-1
								spokeLang[choice.name] = nil
							else
								table.insert(self.spokenLang, choice)
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
				if not self.surname or self.surname == "" then self.surname = parent:name(true, 6) end
				if not self.ancName or self.ancName == "" then self.ancName = self.surname end

				if math.random(1, 150) == 12 then self.region = nil end

				if not self.region then
					self.region = parent:randomChoice(nl.regions)
					self.city = nil
				end

				if self.region and not self.city then
					self.city = parent:randomChoice(self.region.cities)
					if self.spouse then
						self.spouse.region = self.region
						self.spouse.city = self.city
					end
				end

				if self.region then self.region.population = self.region.population+1 end
				if self.city then self.city.population = self.city.population+1 end

				if self.region and not self.region.language then self.region.language = parent:getLanguage(nl.demonym.." ("..parent:demonym(self.region.name)..")", nl) end
				if self.region then if not self.nativeLang or #self.nativeLang == 0 then self.nativeLang = {self.region.language} end end

				if self.nativeLang and #self.nativeLang > 0 then
					local langFound = false
					for i=1,#self.nativeLang do if self.nativeLang[i].name == self.region.language.name then langFound = true end end
					if not langFound then for i=1,#self.spokenLang do if self.spokenLang[i].name == self.region.language.name then langFound = true end end end
					if not langFound then
						local langChance = math.random(1, 10)
						if langChance == 5 then table.insert(self.spokenLang, self.region.language) end
					end
				end

				local sys = parent.systems[nl.system]

				local rankLim = 2
				if not sys.dynastic then rankLim = 1 end

				local ranks = sys.ranks
				if sys.dynastic and self.gender == "F" then ranks = sys.franks end

				if self.title and self.level then
					if self.level < #ranks-rankLim then
						local x = math.random(-100, 100)
						if x < -85 then
							self.prevtitle = self.title
							self.level = self.level-1
						elseif x > 85 then
							self.prevtitle = self.title
							self.level = self.level+1
						end
					end

					if self.level < 1 then self.level = 1 end
					if self.level >= #ranks-rankLim then self.level = #ranks-rankLim end
					if self.isRuler then self.level = #ranks end
					if self.parentRuler and sys.dynastic then self.level = #ranks-1 end
				else self.level = 2 end

				self.title = ranks[self.level]

				if not self.spouse or not self.spouse.def or not self.spouse.spouse or not self.spouse.spouse.def or self.spouse.spouse.gString ~= self.gString then self.spouse = nil end

				if not self.spouse or not self.spouse.def then if self.age > 15 and math.random(1, 8) == 4 then
					local m = parent:randomChoice(nl.people)
					if m.def and m.age > 15 and not m.spouse and self.gender ~= m.gender then
						local found = false
						if self.surname == m.surname then found = true end
						if not found then for i, j in pairs(self.children) do
							if j.gString == m.gString then found = true end
							if j.surname == m.surname then found = true end
						end end
						if not found then for i, j in pairs(m.children) do
							if j.gString == self.gString then found = true end
							if j.surname == self.surname then found = true end
						end end
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

				if not self.party or self.party == "" then
					local pmatch = nil

					for i, j in pairs(nl.parties) do if j and not pmatch then
						pmatch = j
						if math.abs(j.pfreedom-self.pbelief) > 35 then pmatch = nil end
						if math.abs(j.efreedom-self.ebelief) > 35 then pmatch = nil end
						if math.abs(j.cfreedom-self.cbelief) > 35 then pmatch = nil end
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
				end

				if nl.rulerParty then
					local pTotal = nl.rulerParty.pfreedom-self.pbelief
					local eTotal = nl.rulerParty.efreedom-self.ebelief
					local cTotal = nl.rulerParty.cfreedom-self.cbelief
					local diffTotal = math.abs(pTotal)+math.abs(eTotal)+math.abs(cTotal)
					nl.rulerPopularity = nl.rulerPopularity+(300-diffTotal)
				end

				if self.military then
					self.militaryTraining = self.militaryTraining+1
					nl.strength = nl.strength+self.militaryTraining
				else
					if not military and self.age < 35 then
						if math.random(1, 250) < nl.milThreshold then
							self.military = true
							self.militaryTraining = 0
						end
					elseif self.age > 65 then self.military = false end
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

				if _DEBUG then
					if not debugTimes["Person.update"] then debugTimes["Person.update"] = 0 end
					debugTimes["Person.update"] = debugTimes["Person.update"]+_time()-t0
				end
			end
		}

		Person.__index = Person
		Person.__call=function() return Person:new() end

		return Person
	end
