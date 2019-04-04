return
	function()
		local Person = {
			new = function(self)
				local n = {}
				setmetatable(n, self)

				n.age = 0
				n.birth = 0
				n.birthplace = ""
				n.cbelief = 0
				n.children = {}
				n.city = ""
				n.death = 0
				n.deathplace = ""
				n.def = {} -- A utility variable used to set whether this person has been destroyed.
				n.ebelief = 0
				n.ethnicity = {}
				n.father = nil
				n.gender = ""
				n.genInfo = {}
				n.gensSet = false
				n.gIndex = 0
				n.gString = ""
				n.isruler = false
				n.LastRoyalAncestor = ""
				n.level = 2
				n.maternalLineTimes = math.huge
				n.military = false
				n.militaryTraining = 0
				n.mother = nil
				n.mtname = "Person"
				n.name = ""
				n.nationality = ""
				n.number = 0
				n.parentRuler = false
				n.party = ""
				n.pbelief = 0
				n.pIndex = 0
				n.prevtitle = "Citizen"
				n.recentbirth = false
				n.region = ""
				n.removed = false
				n.royalGenerations = math.huge
				n.royalName = ""
				n.royalSystem = ""
				n.ruledCountry = ""
				n.RulerTitle = ""
				n.spouse = nil
				n.surname = ""
				n.title = "Citizen"

				return n
			end,

			destroy = function(self, parent, nl)
				self.death = parent.years
				self.deathplace = nl.name
				if parent.thisWorld.fromFile and self.royalGenerations == 0 then
					local rf = io.open(parent.stamp.."/"..nl.name..".txt", "a")
					if not rf then rf = io.open(parent.stamp.."/"..nl.name..".txt", "w+") end
					
					rf:write(self.title.." "..self.royalName.." "..parent:roman(self.number).." of "..self.ruledCountry.." (b. "..math.abs(self.birth))
					if self.birth < 0 then rf:write(" B.C.E.") end
					rf:write(", "..self.birthplace)
					if self.death < parent.maxyears then rf:write(" - d. "..self.death..", "..self.deathplace) end
					rf:write(")\n")
					if self.genInfo.royalGenerations < math.huge and self.genInfo.royalGenerations > 0 then rf:write(parent:generationString(self.royalGenerations, self.gender).." of "..self.genInfo.LastRoyalAncestor:gsub(" of "..self.name, "").."\n") end
					rf:write("\n")
					rf:flush()
					rf:close()
					rf = nil
				end
				self.def = nil -- See above.
				self.spouse = nil
			end,

			dobirth = function(self, parent, nl)
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

						if surnames[1] == surnames[2] then nn.surname = surnames[1] else nn.surname = surnames[1].."-"..surnames[2] end
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
					nn.surname = parent:namecheck(nn.surname:gsub(op[o1], op[o2], 1))
				end

				local sys = parent.systems[nl.system]

				nn.birthplace = nl.name
				nn.age = 0

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

				if self.royalName ~= "" then
					if self.gender == "Male" then nn.maternalLineTimes = 0 end
					nn.royalGenerations = 1
					nn.royalSystem = self.royalSystem
					nn.LastRoyalAncestor = string.format(self.title.." "..self.royalName.." "..parent:roman(self.number).." of "..nl.name)
				elseif self.spouse.royalName ~= "" then
					if self.gender == "Female" then nn.maternalLineTimes = 0 end
					nn.royalGenerations = 1
					nn.royalSystem = self.spouse.royalSystem
					nn.LastRoyalAncestor = string.format(self.spouse.title.." "..self.spouse.royalName.." "..parent:roman(self.spouse.number).." of "..nl.name)
				end
				
				if self.isruler or self.spouse.isruler then
					nn.level = self.level-1
					nn.parentRuler = true
				elseif self.level > self.spouse.level then nn.level = self.level else nn.level = self.spouse.level end

				if nn.gender == "Male" or not sys.dynastic then nn.title = sys.ranks[nn.level] else nn.title = sys.franks[nn.level] end

				for i, j in pairs(self.ethnicity) do nn.ethnicity[i] = j end
				for i, j in pairs(self.spouse.ethnicity) do
					if not nn.ethnicity[i] then nn.ethnicity[i] = 0 end
					nn.ethnicity[i] = nn.ethnicity[i]+j
				end
				for i, j in pairs(nn.ethnicity) do nn.ethnicity[i] = nn.ethnicity[i]/2 end

				nn.nationality = nl.name

				if self.gender == "Female" then nn:SetFamily(self.spouse, self, parent)
				else nn:SetFamily(self, self.spouse, parent) end

				nn.gString = nn.name.." "..nn.surname.." "..nn.birth.." "..nn.birthplace.." "..tostring(nn.number)

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
				local f0 = _time()

				self.age = parent.years-self.birth
				if self.birth <= -1 then self.age = self.age-1 end

				if not self.birthplace or self.birthplace == "" then self.birthplace = nl.name end
				if not self.surname or self.surname == "" then self.surname = parent:name(true, 6) end

				local sys = parent.systems[nl.system]

				local rankLim = 2
				if not sys.dynastic then rankLim = 1 end

				if not self.spouse or not self.spouse.def or not self.spouse.spouse or self.spouse.spouse.gString ~= self.gString then self.spouse = nil end

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

				if not self.spouse and self.age > 15 and math.random(1, 8) == 4 then
					local m = parent:randomChoice(nl.people)
					if not m.spouse and self.gender ~= m.gender then
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
				end

				if not self.recentbirth and self.spouse and math.random(1, nl.birthrate) == 2 then
					self:dobirth(parent, nl)
					self.spouse.recentbirth = true
				end

				self.recentbirth = false

				self.pbelief = self.pbelief+math.random(-2, 2)
				self.ebelief = self.ebelief+math.random(-2, 2)
				self.cbelief = self.cbelief+math.random(-2, 2)

				if self.pbelief < -100 then self.pbelief = -100 end
				if self.pbelief > 100 then self.pbelief = 100 end
				if self.ebelief < -100 then self.ebelief = -100 end
				if self.ebelief > 100 then self.ebelief = 100 end
				if self.cbelief < -100 then self.cbelief = -100 end
				if self.cbelief > 100 then self.cbelief = 100 end

				local pmatch = false

				if #nl.parties > 0 then
					for i=1,#nl.parties do if not pmatch then
						pmatch = true
						if math.abs(nl.parties[i].pfreedom-self.pbelief) > 35 then pmatch = false end
						if math.abs(nl.parties[i].efreedom-self.ebelief) > 35 then pmatch = false end
						if math.abs(nl.parties[i].cfreedom-self.cbelief) > 35 then pmatch = false end
					end end
				end

				if not pmatch then
					local newp = Party:new()
					newp:makename(parent, nl)
					newp.cfreedom = self.cbelief
					newp.efreedom = self.ebelief
					newp.pfreedom = self.pbelief
					local belieftotal = newp.cfreedom+newp.efreedom+newp.pfreedom

					if math.abs(belieftotal) > 225 then newp.radical = true end

					self.party = newp.name
					if self.isruler then nl.rulers[#nl.rulers].Party = self.party end

					table.insert(nl.parties, newp)
				end

				if self.party == "" then
					local pi = parent:randomChoice(nl.parties)
					pmatch = true
					if math.abs(pi.pfreedom-self.pbelief) > 35 then pmatch = false end
					if math.abs(pi.efreedom-self.ebelief) > 35 then pmatch = false end
					if math.abs(pi.cfreedom-self.cbelief) > 35 then pmatch = false end
					if pmatch then
						self.party = pi.name
						if self.isruler then nl.rulers[#nl.rulers].Party = self.party end
					end
				else
					for i=1,#nl.parties do
						local pi = nl.parties[i]
						local belieftotal = self.pbelief+self.ebelief+self.cbelief
						local partytotal = pi.pfreedom+pi.efreedom+pi.cfreedom
						local diff = math.abs(belieftotal-partytotal)
						if diff < 165 then pi.popularity = pi.popularity+((100-(diff/3))/#nl.people) end
						if pi.name == self.party then pi.membership = pi.membership+1
						else
							pmatch = true
							if math.abs(pi.pfreedom-self.pbelief) > 50 then pmatch = false end
							if math.abs(pi.efreedom-self.ebelief) > 50 then pmatch = false end
							if math.abs(pi.cfreedom-self.cbelief) > 50 then pmatch = false end
							if pmatch then
								self.party = pi.name
								if self.isruler then nl.rulers[#nl.rulers].Party = self.party end
							end
						end
					end
				end

				if math.random(1, 150) == 12 then self.region = "" end

				if self.region == "" or not nl.regions[self.region] then
					self.region = parent:randomChoice(nl.regions, true)
					self.city = ""
				end

				if self.city == "" or not nl.regions[self.region].cities[self.city] then
					self.city = parent:randomChoice(nl.regions[self.region].cities, true)
					if self.spouse then
						self.spouse.region = self.region
						self.spouse.city = self.city
					end
				end

				nl.regions[self.region].population = nl.regions[self.region].population+1
				nl.regions[self.region].cities[self.city].population = nl.regions[self.region].cities[self.city].population+1

				if self.military then
					self.militaryTraining = self.militaryTraining+1
					nl.strength = nl.strength+self.militaryTraining
				else
					if self.age < 35 then
						local threshold = 5
						for j=1,#nl.ongoing do if nl.ongoing[j].name == "War" then threshold = 25 end end
						if math.random(1, 250) < threshold then
							self.military = true
							self.militaryTraining = 1
						end
					end
				end

				if self.age > 65 then self.military = false end
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
					if not parent.debugTimes["Person:update"] then parent.debugTimes["Person:update"] = {0, 0} end
					parent.debugTimes["Person:update"][1] = parent.debugTimes["Person:update"][1]+_time()-f0
					parent.debugTimes["Person:update"][2] = parent.debugTimes["Person:update"][2]+1
				end
			end
		}

		Person.__index = Person
		Person.__call=function() return Person:new() end

		return Person
	end