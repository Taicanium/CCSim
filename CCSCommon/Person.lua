return
	function()
		local Person = {
			new = function(self)
				local n = {}
				setmetatable(n, self)

				n.name = ""
				n.surname = ""
				n.birth = 0
				n.age = 0
				n.gender = ""
				n.ethnicity = {}
				n.nationality = ""
				n.level = 2
				n.prevName = ""
				n.prevTitle = "Citizen"
				n.title = "Citizen"
				n.party = ""
				n.region = ""
				n.city = ""
				n.spouse = nil
				n.father = nil
				n.mother = nil
				n.useParents = false
				n.isruler = false
				n.parentRuler = false
				n.royal = false
				n.royalSystem = ""
				n.royalGenerations = -1
				n.birthplace = ""
				n.deathplace = ""
				n.death = 0
				n.maternalLineTimes = -1
				n.lastRoyalAncestor = ""
				n.royalInfo = {Gens=-1, LastAncestor=""}
				n.pbelief = 0
				n.ebelief = 0
				n.cbelief = 0
				n.number = 0
				n.military = false
				n.militaryTraining = 0
				n.recentbirth = false
				n.mtName = "Person"

				return n
			end,

			destroy = function(self)
				self.name = nil
				self.surname = nil
				self.birth = nil
				self.age = nil
				self.gender = nil
				self.ethnicity = nil
				self.nationality = nil
				self.level = nil
				self.prevName = nil
				self.prevTitle = nil
				self.title = nil
				self.party = nil
				self.region = nil
				self.city = nil
				self.spouse = nil
				self.isruler = nil
				self.parentRuler = nil
				self.royal = nil
				self.royalSystem = nil
				self.royalGenerations = nil
				self.maternalLineTimes = nil
				self.lastRoyalAncestor = nil
				self.royalInfo = nil
				self.pbelief = nil
				self.ebelief = nil
				self.cbelief = nil
				self.number = nil
				self.military = nil
				self.militaryTraining = nil
				self.recentbirth = nil
				self.mtName = nil
			end,

			dobirth = function(self, parent, nl)
				local nn = Person:new()

				nn:makename(parent, nl)

				if self.gender == "Male" then
					nn.surname = self.surname
				else
					nn.surname = self.spouse.surname
				end

				local sys = parent.systems[nl.system]

				nn.birthplace = nl.name
				nn.age = 0

				if self.royalGenerations ~= -1 then
					if self.spouse.royalGenerations ~= -1 then
						if self.spouse.royalGenerations < self.royalGenerations then
							nn.royalGenerations = self.spouse.royalGenerations + 1
							nn.royalSystem = self.spouse.royalSystem
							nn.lastRoyalAncestor = self.spouse.lastRoyalAncestor
							if self.spouse.gender == "Female" then nn.maternalLineTimes = self.spouse.maternalLineTimes + 1 end
							if self.gender == "Female" then if parent.ged == true then nn:SetFamily(self.spouse, self) end
							else if parent.ged == true then nn:SetFamily(self, self.spouse) end end
							nn.useParents = true
						else
							nn.royalGenerations = self.royalGenerations + 1
							nn.royalSystem = self.royalSystem
							nn.lastRoyalAncestor = self.lastRoyalAncestor
							if self.gender == "Female" then nn.maternalLineTimes = self.maternalLineTimes + 1 end
							if self.gender == "Female" then if parent.ged == true then nn:SetFamily(self.spouse, self) end
							else if parent.ged == true then nn:SetFamily(self, self.spouse) end end
							nn.useParents = true
						end
					else
						nn.royalGenerations = self.royalGenerations + 1
						nn.royalSystem = self.royalSystem
						nn.lastRoyalAncestor = self.lastRoyalAncestor
						if self.gender == "Female" then nn.maternalLineTimes = self.maternalLineTimes + 1 end
						if self.gender == "Female" then if parent.ged == true then nn:SetFamily(self.spouse, self) end
						else if parent.ged == true then nn:SetFamily(self, self.spouse) end end
						nn.useParents = true
					end
				end

				if self.royal == true then
					nn.maternalLineTimes = 0
					nn.lastRoyalAncestor = string.format(nl.rulers[#nl.rulers].Title.." "..nl.rulers[#nl.rulers].name.." "..parent:roman(nl.rulers[#nl.rulers].Number).." of "..nl.rulers[#nl.rulers].Country)
					nn.royalInfo.Gens=nn.royalGenerations
					nn.royalInfo.LastAncestor=nn.lastRoyalAncestor
				else if self.spouse.royal == true then
					if self.gender == "Female" then nn.maternalLineTimes = 0 end
					nn.royalSystem = self.spouse.royalSystem
					nn.lastRoyalAncestor = string.format(nl.rulers[#nl.rulers].Title.." "..nl.rulers[#nl.rulers].name.." "..parent:roman(nl.rulers[#nl.rulers].Number).." of "..nl.rulers[#nl.rulers].Country)
					nn.royalInfo.Gens=nn.royalGenerations
					nn.royalInfo.LastAncestor=nn.lastRoyalAncestor
				end end

				if self.title == sys.ranks[#sys.ranks] then
					nn.level = self.level - 1
					nn.parentRuler = true
				else
					nn.level = self.level
				end

				if sys.dynastic == true then
					if self.gender == "Female" then
						if self.title == sys.franks[#sys.franks] then
							nn.level = self.level - 1
						end
					end
				end

				if nn.gender == "Male" then nn.title = sys.ranks[nn.level] else if sys.dynastic == true then nn.title = sys.franks[nn.level] else nn.title = sys.ranks[nn.level] end end

				for i, j in pairs(self.ethnicity) do nn[i] = j end

				for i, j in pairs(self.spouse.ethnicity) do
					if nn[i] == nil then nn[i] = 0 end
					nn[i] = nn[i] + j
				end

				for i, j in pairs(nn.ethnicity) do nn[i] = nn[i] / 2 end

				nl:add(nn)
			end,

			makename = function(self, parent, nl)
				self.name = parent:name(true, 6)
				self.surname = parent:name(true, 6)

				local r = math.random(1, 1000)
				if r < 501 then self.gender = "Male" else self.gender = "Female" end

				self.pbelief = math.random(-100, 100)
				self.ebelief = math.random(-100, 100)
				self.cbelief = math.random(-100, 100)

				self.birth = parent.years
				self.age = math.random(1, 30)
				if self.title == "" then
					self.level = 2
					self.title = "Citizen"
				end
			end,

			SetFamily = function(self, father, mother)
				self.father = {Name=father.name, Surname=father.surname, Gender="M", Number=father.number, Birth=father.birth, BirthPlace=father.birthplace, Death=father.death, DeathPlace=father.deathplace, Father=father.father, Mother=father.mother, Title=father.title}
				self.mother = {Name=mother.name, Surname=mother.surname, Gender="F", Number=mother.number, Birth=mother.birth, BirthPlace=mother.birthplace, Death=mother.death, DeathPlace=mother.deathplace, Father=mother.father, Mother=mother.mother, Title=mother.title}
			end,

			update = function(self, parent, nl)
				self.age = self.age + 1

				if self.birthplace == "" then self.birthplace = nl.name end
				if self.surname == nil or self.surname == "" then self.surname = parent:name(true, 6) end

				local sys = parent.systems[nl.system]

				local rankLim = 2
				if sys.dynastic == false then rankLim = 1 end

				if self.gender == "Male" or sys.dynastic == false then
					if self.title ~= nil and self.level ~= nil then
						if self.title ~= sys.ranks[#sys.ranks] and self.level < #sys.ranks - rankLim then
							local x = math.random(-100, 100)
							if x < -85 then
								self.prevTitle = self.title
								self.level = self.level - 1
							elseif x > 85 then
								self.prevTitle = self.title
								self.level = self.level + 1
							end
						end

						if self.level < 1 then self.level = 1 end
						if self.level >= #sys.ranks - rankLim then self.level = #sys.ranks - rankLim end

						if self.parentRuler == true and sys.dynastic == true then self.level = #sys.ranks - 1 end

						self.title = sys.ranks[self.level]
					else
						self.level = 2
						self.title = "Citizen"
					end
				else
					if self.title ~= nil and self.level ~= nil then
						if self.title ~= sys.franks[#sys.franks] and self.level < #sys.franks - rankLim then
							local x = math.random(-100, 100)
							if x < -85 then
								self.prevTitle = self.title
								self.level = self.level - 1
							elseif x > 85 then
								self.prevTitle = self.title
								self.level = self.level + 1
							end
						end

						if self.level < 1 then self.level = 1 end
						if self.level >= #sys.franks - rankLim then self.level = #sys.franks - rankLim end

						if self.parentRuler == true and sys.dynastic == true then self.level = #sys.ranks - 1 end

						self.title = sys.franks[self.level]
					else
						self.level = 2
						self.title = "Citizen"
					end
				end

				if self.spouse ~= nil then
					if self.spouse.name == nil then self.spouse = nil end
				end

				if self.spouse == nil then
					if self.age > 15 then
						local c = math.random(1, 8)
						if c == 2 then
							m = math.random(1, #nl.people)
							if nl.people[m].spouse == nil then
								if self.gender ~= nl.people[m].gender then
									self.spouse = nl.people[m]
									self.spouse.spouse = self
								end
							end
						end
					end
				end

				if self.recentbirth == false then
					if self.spouse ~= nil then
						if self.gender == "Female" then
							if self.age < 60 then
								if self.age > 14 then
									if self.spouse.age < 75 then
										if self.spouse.age > 14 then
											local tmp = math.random(1, nl.birthrate)
											if tmp == 2 then
												self:dobirth(parent, nl)
												self.spouse.recentbirth = true
											end
										end
									end
								end
							end
						else
							if self.age < 75 then
								if self.age > 14 then
									if self.spouse.age < 60 then
										if self.spouse.age > 14 then
											local tmp = math.random(1, nl.birthrate)
											if tmp == 2 then
												self:dobirth(parent, nl)
												self.spouse.recentbirth = true
											end
										end
									end
								end
							end
						end
					end
				end

				self.recentbirth = false

				local belieftotal = self.pbelief + self.ebelief + self.cbelief

				if #nl.parties > 0 then
					local pmatch = false

					for i=1,#nl.parties do
						local ptotal = nl.parties[i].cfreedom + nl.parties[i].pfreedom + nl.parties[i].efreedom
						if math.abs(belieftotal - ptotal) < 125 then pmatch = true end
					end

					if pmatch == false then
						local newp = Party:new()
						local ni = nil
						for i, cp in pairs(parent.thisWorld.countries) do if cp.name == nl.name then ni = cp end end
						newp:makename(parent, ni)
						newp.cfreedom = self.cbelief
						newp.efreedom = self.ebelief
						newp.pfreedom = self.pbelief

						if math.abs(belieftotal) > 200 then newp.radical = true end

						self.party = newp.name
						newp.membership = 1

						if self.isruler == true then
							nl.rulers[#nl.rulers].Party = self.party
						end

						table.insert(nl.parties, newp)
					end

					if self.party == "" then
						local pr = math.random(1, #nl.parties)
						local partytotal = nl.parties[pr].pfreedom + nl.parties[pr].efreedom + nl.parties[pr].cfreedom
						if math.abs(belieftotal - partytotal) < 125 then
							self.party = nl.parties[pr].name
							nl.parties[pr].membership = nl.parties[pr].membership + 1
							if self.isruler == true then
								nl.rulers[#nl.rulers].Party = self.party
							end
						end
					else
						local pi = 0
						for i=1,#nl.parties do if nl.parties[i].name == self.party then pi = i end end
						if pi ~= 0 then
							local cc = math.random(1, 100 * nl.parties[pi].popularity + 1)
							if cc == 10 then
								nl.parties[pi].membership = nl.parties[pi].membership - 1

								local pr = math.random(1, #nl.parties)
								local partytotal = nl.parties[pr].pfreedom + nl.parties[pr].efreedom + nl.parties[pr].cfreedom
								if math.abs(belieftotal - partytotal) < 125 then
									self.party = nl.parties[pr].name
									nl.parties[pr].membership = nl.parties[pr].membership + 1
									if self.isruler == true then
										nl.rulers[#nl.rulers].Party = self.party
									end
								end
							end
						end
					end
				else
					local newp = Party:new()
					local ni = nil
					for i, cp in pairs(parent.thisWorld.countries) do if cp.name == nl.name then ni = cp end end
					newp:makename(parent, ni)
					newp.cfreedom = self.cbelief
					newp.efreedom = self.ebelief
					newp.pfreedom = self.pbelief

					if math.abs(belieftotal) > 200 then newp.radical = true end

					self.party = newp.name
					newp.membership = 1

					table.insert(nl.parties, newp)
				end

				local movechance = math.random(1, 25)
				if movechance == 12 then
					self.region = ""
					self.city = ""
				end

				for i, cp in pairs(parent.thisWorld.countries) do
					if cp.name ~= nl.name then
						local movechance = math.random(1, 1000)
						if movechance < 6 then
							for j=#nl.people,1,-1 do
								if nl.people[j].name == self.name and nl.people[j].surname == self.surname and nl.people[j].birth == self.birth and nl.people[j].level == self.level then
									local k = table.remove(nl.people, j)
									table.insert(nl.people, k)
								end

								if self.spouse ~= nil then
									self.spouse = nil
								end
							end

							self.region = ""
							self.city = ""
							self.military = false
							self.nationality = nl.name
						end
					end
				end

				if self.military == true then
					self.militaryTraining = self.militaryTraining + 1
					nl.strength = nl.strength + self.militaryTraining
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
				
				for i, j in pairs(self.ethnicity) do
					if nl.ethnicities[i] == nil then nl.ethnicities[i] = 0 end
					if self.ethnicity[i] >= 50 then nl.ethnicities[i] = nl.ethnicities[i] + 1 end
				end

				if self.region == "" or nl.regions[self.region] == nil then
					local values = {}
					for i, j in pairs(nl.regions) do table.insert(values, j.name) end
					self.region = values[math.random(1, #values)]
					self.city = ""
				end

				if self.city == "" or nl.regions[self.region].cities[self.city] then
					local values = {}
					for i, j in pairs(nl.regions[self.region].cities) do table.insert(values, j.name) end
					self.city = values[math.random(1, #values)]
				end

				if nl.regions[self.region] ~= nil then
					nl.regions[self.region].population = nl.regions[self.region].population + 1
					if nl.regions[self.region].cities[self.city] ~= nil then
						nl.regions[self.region].cities[self.city].population = nl.regions[self.region].cities[self.city].population + 1
					else self.city = "" end
				else self.region = "" end
			end
		}

		Person.__index = Person
		Person.__call=function() return Person:new() end

		return Person
	end