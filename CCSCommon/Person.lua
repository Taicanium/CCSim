return
	function()
		local Person = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.age = 0
				o.birth = 0
				o.birthplace = ""
				o.cbelief = 0
				o.children = {}
				o.city = nil
				o.death = 0
				o.deathplace = ""
				o.def = true -- A utility variable used to set whether this person has been destroyed.
				o.ebelief = 0
				o.ethnicity = {}
				o.famc = ""
				o.fams = {}
				o.father = nil
				o.gender = ""
				o.gIndex = 0
				o.gString = ""
				o.isruler = false
				o.LastRoyalAncestor = ""
				o.level = 2
				o.maternalLineTimes = math.huge
				o.military = false
				o.militaryTraining = 0
				o.mother = nil
				o.mtname = "Person"
				o.name = ""
				o.nationality = ""
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
				o.spouse = nil
				o.surname = ""
				o.title = "Citizen"
				o.writeGed = 0

				return o
			end,

			destroy = function(self, parent, nl)
				self.age = nil
				self.cbelief = nil
				self.city = nil
				self.death = parent.years
				self.deathplace = nl.name
				self.def = nil -- See above.
				self.ebelief = nil
				self.isruler = nil
				self.level = nil
				self.military = nil
				self.militaryTraining = nil
				self.nationality = nil
				self.parentRuler = nil
				self.party = nil
				self.pbelief = nil
				self.prevtitle = nil
				self.recentbirth = nil
				self.region = nil
				if self.spouse then self.spouse.spouse = nil end
				self.spouse = nil
				if self.royalGenerations == 0 then table.insert(parent.royals, self) end
			end,

			dobirth = function(self, parent, nl)
				if not self.spouse or not self.spouse.def then return nil end
			
				if self.gender == "Male" then if self.age < 14 or self.age > 65 then return nil end
				elseif self.gender == "Female" then if self.age < 14 or self.age > 55 then return nil end end

				if self.spouse.gender == "Male" then if self.spouse.age < 14 or self.spouse.age > 65 then return nil end
				elseif self.spouse.gender == "Female" then if self.spouse.age < 14 or self.spouse.age > 55 then return nil end end

				local nn = Person:new()
				nn:makename(parent, nl)

				if self.gender == "Male" then nn.surname = self.surname
				else nn.surname = self.spouse.surname end

				if self.royalGenerations < 5 and self.spouse.royalGenerations < 5 then
					if self.surname ~= self.spouse.surname then
						local surnames = {}

						if self.royalGenerations < self.spouse.royalGenerations then surnames = {self.surname:gmatch("%a+")(), self.spouse.surname:gmatch("%a+")()}
						elseif self.royalGenerations > self.spouse.royalGenerations then surnames = {self.spouse.surname:gmatch("%a+")(), self.surname:gmatch("%a+")()}
						else
							if self.gender == "Male" then surnames = {self.surname:gmatch("%a+")(), self.spouse.surname:gmatch("%a+")()}
							else surnames = {self.spouse.surname:gmatch("%a+")(), self.surname:gmatch("%a+")()} end
						end

						if surnames[1] == surnames[2] then nn.surname = surnames[1] else
							local lastAnc = self
							local thisAnc = self.father
							while thisAnc do
								lastAnc = thisAnc
								thisAnc = lastAnc.father
							end
							local anc1 = lastAnc
							lastAnc = self.spouse
							thisAnc = self.spouse.father
							while thisAnc do
								lastAnc = thisAnc
								thisAnc = lastAnc.father
							end
							local anc2 = lastAnc
							if anc1.surname ~= anc2.surname then nn.surname = surnames[1].."-"..surnames[2] else nn.surname = surnames[1] end
						end
					end
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
						if self.spouse.gender == "Female" then nn.maternalLineTimes = self.spouse.maternalLineTimes+1 end
					else
						nn.royalGenerations = self.royalGenerations+1
						nn.royalSystem = self.royalSystem
						nn.LastRoyalAncestor = self.LastRoyalAncestor
						if self.gender == "Female" then nn.maternalLineTimes = self.maternalLineTimes+1 end
					end
				end

				if self.royalGenerations == 0 then
					if self.gender == "Male" then nn.maternalLineTimes = 0 end
					nn.royalGenerations = 1
					nn.royalSystem = self.royalSystem
					nn.LastRoyalAncestor = self.rulerTitle.." "..self.rulerName.." "..parent:roman(self.number).." of "..self.ruledCountry
				elseif self.spouse.royalGenerations == 0 then
					if self.gender == "Female" then nn.maternalLineTimes = 0 end
					nn.royalGenerations = 1
					nn.royalSystem = self.spouse.royalSystem
					nn.LastRoyalAncestor = self.spouse.rulerTitle.." "..self.spouse.rulerName.." "..parent:roman(self.spouse.number).." of "..self.spouse.ruledCountry
				end

				if self.isruler or self.spouse.isruler then
					nn.level = self.level-1
					nn.parentRuler = true
				elseif self.level > self.spouse.level then nn.level = self.level else nn.level = self.spouse.level end

				local sys = parent.systems[nl.system]
				if nn.gender == "Male" or not sys.dynastic then nn.title = sys.ranks[nn.level] else nn.title = sys.franks[nn.level] end

				for i, j in pairs(self.ethnicity) do nn.ethnicity[i] = j end
				for i, j in pairs(self.spouse.ethnicity) do
					if not nn.ethnicity[i] then nn.ethnicity[i] = 0 end
					nn.ethnicity[i] = nn.ethnicity[i]+j
				end
				for i, j in pairs(nn.ethnicity) do nn.ethnicity[i] = nn.ethnicity[i]/2 end

				if self.gender == "Female" then nn:SetFamily(self.spouse, self, parent)
				else nn:SetFamily(self, self.spouse, parent) end

				nn.birthplace = nl.name
				nn.age = 0
				nn.gString = nn.gender.." "..nn.name.." "..nn.surname.." "..nn.birth.." "..nn.birthplace
				nn.nationality = nl.name

				nl:add(parent, nn)
			end,

			makename = function(self, parent, nl)
				self.name = parent:name(true)
				self.surname = parent:name(true)

				if math.random(1, 1000) < 501 then self.gender = "Male" else self.gender = "Female" end

				self.pbelief = math.random(-100, 100)
				self.ebelief = math.random(-100, 100)
				self.cbelief = math.random(-100, 100)

				self.birth = parent.years
				if self.title == "" then
					self.level = 2
					self.title = "Citizen"
				end
			end,

			SetFamily = function(self, father, mother, parent)
				table.insert(father.children, self)
				table.insert(mother.children, self)
				self.father = father
				self.mother = mother
			end,

			update = function(self, parent, nl)
				if not self.def then return end
				
				local f0 = _time()

				self.age = parent.years-self.birth
				if self.birth <= -1 then self.age = self.age-1 end

				if not self.birthplace or self.birthplace == "" then self.birthplace = nl.name end
				if not self.surname or self.surname == "" then self.surname = parent:name(true, 6) end

				local sys = parent.systems[nl.system]

				local rankLim = 2
				if not sys.dynastic then rankLim = 1 end

				if not self.spouse or not self.spouse.def or not self.spouse.spouse or not self.spouse.spouse.def or self.spouse.spouse.gString ~= self.gString then self.spouse = nil end

				local ranks = sys.ranks
				if sys.dynastic and self.gender == "Female" then ranks = sys.franks end

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
					if self.isruler then self.level = #ranks end
					if self.parentRuler and sys.dynastic then self.level = #ranks-1 end
				else self.level = 2 end

				self.title = ranks[self.level]

				if not self.spouse or not self.spouse.def then if self.age > 15 and math.random(1, 8) == 4 then
					local m = parent:randomChoice(nl.people)
					if m.def and not m.spouse and self.gender ~= m.gender then
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
						if math.abs(belieftotal) > 225 then newp.radical = true end

						nl.parties[newp.name] = newp
						pmatch = nl.parties[newp.name]
					end

					self.party = pmatch.name
				end
				
				if self.isruler then nl.rulers[#nl.rulers].party = self.party end

				if nl.rulerParty then
					local belieftotal = self.pbelief+self.ebelief+self.cbelief
					local partytotal = nl.rulerParty.pfreedom+nl.rulerParty.efreedom+nl.rulerParty.cfreedom
					local diff = math.abs(belieftotal-partytotal)
					if diff < 175 then nl.rulerPopularity = nl.rulerPopularity+diff end
				end

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

				if self.military then
					self.militaryTraining = self.militaryTraining+1
					nl.strength = nl.strength+self.militaryTraining
				else
					if self.age < 35 then
						local threshold = 5
						for j=1,#nl.ongoing do if nl.ongoing[j].name == "War" then threshold = 25 end end
						if math.random(1, 250) < threshold then
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
					if not parent.debugTimes["Person:update"] then parent.debugTimes["Person:update"] = 0 end
					parent.debugTimes["Person:update"] = parent.debugTimes["Person:update"]+_time()-f0
				end
			end
		}

		Person.__index = Person
		Person.__call=function() return Person:new() end

		return Person
	end
