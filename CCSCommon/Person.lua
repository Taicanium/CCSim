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
				n.famc = {}
				n.fams = {}
				n.father = nil
				n.gender = ""
				n.gensSet = false
				n.gIndex = 0
				n.gString = ""
				n.isruler = false
				n.LastRoyalAncestor = ""
				n.level = 2
				n.maternalLineTimes = -1
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
				n.royalGenerations = -1
				n.royalName = ""
				n.royalSystem = ""
				n.RoyalTitle = ""
				n.spouse = nil
				n.surname = ""
				n.title = "Citizen"

				return n
			end,

			destroy = function(self)
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

				if self.royalGenerations ~= -1 and self.spouse.royalGenerations ~= -1 then
					if self.royalGenerations < 5 and self.spouse.royalGenerations < 5 then
						if self.surname ~= self.spouse.surname then
							local surnames = {}

							if self.royalGenerations < self.spouse.royalGenerations then surnames = {self.surname:gmatch("%a+")(), self.spouse.surname:gmatch("%a+")()}
							elseif self.royalGenerations > self.spouse.royalGenerations then surnames = {self.spouse.surname:gmatch("%a+")(), self.surname:gmatch("%a+")()}
							else
								if self.gender == "Male" then surnames = {self.surname:gmatch("%a+")(), self.spouse.surname:gmatch("%a+")()}
								else surnames = {self.spouse.surname:gmatch("%a+")(), self.surname:gmatch("%a+")()} end
							end

							nn.surname = surnames[1].."-"..surnames[2]
						end
					end
				end

				if self.royalGenerations >= parent.genLimit and self.spouse.royalGenerations >= parent.genLimit then
					local modChance = math.random(1, 50000)
					if modChance > 999 and modChance < 1106 then
						local ops = {{"d", "b"}, {"t", "d"}, {"th", "t"}, {"s", "th"}, {"p", "b"}, {"a", "e"}, {"e", "i"}, {"e", "o"}, {"sh", "s"}, {"g", "c"}, {"v", "f"}, {"ea", "e"}, {"er", "e"}, {"ei", "e"}, {"z", "s"}}
						local op = parent:randomChoice(ops)
						local o1 = parent:randomChoice(op, true)
						local o2 = 2
						if o1 == 2 then o2 = 1 end
						nn.surname = parent:namecheck(nn.surname:gsub(op[o1], op[o2], 1))
					end
				end

				local sys = parent.systems[nl.system]

				nn.birthplace = nl.name
				nn.age = 0

				if self.royalGenerations ~= -1 then
					if self.spouse.royalGenerations ~= -1 then
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
					else
						nn.royalGenerations = self.royalGenerations+1
						nn.royalSystem = self.royalSystem
						nn.LastRoyalAncestor = self.LastRoyalAncestor
						if self.gender == "Female" then nn.maternalLineTimes = self.maternalLineTimes+1 end
					end
				end

				if self.isruler then
					if self.gender == "Male" then nn.maternalLineTimes = 0 end
					nn.royalSystem = self.royalSystem
					nn.royalGenerations = 1
					nn.LastRoyalAncestor = string.format(self.title.." "..self.royalName.." "..parent:roman(self.number).." of "..nl.name)
				else if self.spouse.isruler then
					if self.gender == "Female" then nn.maternalLineTimes = 0 end
					nn.royalSystem = self.spouse.royalSystem
					nn.royalGenerations = 1
					nn.LastRoyalAncestor = string.format(self.spouse.title.." "..self.spouse.royalName.." "..parent:roman(self.spouse.number).." of "..nl.name)
				end end

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

				local r = math.random(1, 1000)
				if r < 501 then self.gender = "Male" else self.gender = "Female" end

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
				self.age = parent.years-self.birth
				if self.birth <= -1 then self.age = self.age-1 end

				if self.birthplace == "" then self.birthplace = nl.name end
				if not self.surname or self.surname == "" then self.surname = parent:name(true, 6) end

				local sys = parent.systems[nl.system]

				local rankLim = 2
				if not sys.dynastic then rankLim = 1 end

				if self.spouse and not self.spouse.def then self.spouse = nil end

				if self.gender == "Male" or not sys.dynastic then
					if self.title and self.level then
						self.title = sys.ranks[self.level]

						if self.level < #sys.ranks-rankLim then
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
						if self.level >= #sys.ranks-rankLim then self.level = #sys.ranks-rankLim end
						if self.isruler then self.level = #sys.ranks end

						if self.parentRuler and sys.dynastic then self.level = #sys.ranks-1 end
					else self.level = 2 end

					self.title = sys.ranks[self.level]
				else
					if self.title and self.level then
						self.title = sys.franks[self.level]

						if self.level < #sys.franks-rankLim then
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
						if self.level >= #sys.franks-rankLim then self.level = #sys.franks-rankLim end
						if self.isruler then self.level = #sys.franks end

						if self.parentRuler and sys.dynastic then self.level = #sys.franks-1 end
					else self.level = 2 end

					self.title = sys.franks[self.level]
				end

				if not self.spouse then
					if self.age > 15 then
						local c = math.random(1, 8)
						if c == 4 then
							m = math.random(1, #nl.people)
							if not nl.people[m].spouse and self.gender ~= nl.people[m].gender then
								local found = false
								if self.surname == nl.people[m].surname then found = true end
								if not found then for i, j in pairs(self.children) do
									if j.gString == nl.people[m].gString then found = true end
									if j.surname == nl.people[m].surname then found = true end
								end end
								if not found then for i, j in pairs(nl.people[m].children) do
									if j.gString == self.gString then found = true end
									if j.surname == self.surname then found = true end
								end end
								if not found then
									self.spouse = nl.people[m]
									nl.people[m].spouse = self
								end
							end
						end
					end
				end

				if not self.recentbirth then
					if self.spouse then
						local tmp = math.random(1, nl.birthrate)
						if tmp == 2 then
							self:dobirth(parent, nl)
							self.spouse.recentbirth = true
						end
					end
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

				local movechance = math.random(1, 150)
				if movechance == 12 then
					self.region = ""
					self.city = ""
				end

				if self.military then
					self.militaryTraining = self.militaryTraining+1
					nl.strength = nl.strength+self.militaryTraining
				else
					if self.age < 35 then
						local joinChance = math.random(1, 250)
						local threshold = 5
						for j=1,#nl.ongoing do if nl.ongoing[j].name == "War" then threshold = 25 end end
						if joinChance < threshold then
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
				
				for i, j in pairs(self.ethnicity) do if j >= lEthVal then nl.ethnicities[i] = nl.ethnicities[i]+1 end end

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

				if nl.regions[self.region] then
					nl.regions[self.region].population = nl.regions[self.region].population+1
					if nl.regions[self.region].cities[self.city] then
						nl.regions[self.region].cities[self.city].population = nl.regions[self.region].cities[self.city].population+1
					else self.city = "" end
				else self.region = "" end
			end
		}

		Person.__index = Person
		Person.__call=function() return Person:new() end

		return Person
	end