return
	function()
		local Person = {
			new = function(self)
				local n = {}
				setmetatable(n, self)

				n.def = {} -- A utility variable used to set whether this person has been destroyed.
				n.chn = false -- Another utility variable which indicates whether this person's position in the country 'people' array has changed since their last update.
				n.name = ""
				n.royalName = ""
				n.surname = ""
				n.birth = 0
				n.age = 0
				n.gender = ""
				n.ethnicity = {}
				n.nationality = ""
				n.level = 2
				n.prevtitle = "Citizen"
				n.title = "Citizen"
				n.party = ""
				n.region = ""
				n.city = ""
				n.spouse = nil
				n.father = nil
				n.mother = nil
				n.children = {}
				n.isruler = false
				n.parentRuler = false
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
				n.mtname = "Person"

				return n
			end,

			destroy = function(self)
				self.def = nil -- See above.
				self.spouse = nil
			end,

			dobirth = function(self, parent, nl)
				local nn = Person:new()

				nn:makename(parent, nl)

				if self.gender == "Male" then
					nn.surname = self.surname
				else
					nn.surname = self.spouse.surname
				end

				if self.royalGenerations ~= -1 and self.spouse.royalGenerations ~= -1 then
					if self.royalGenerations < 5 and self.spouse.royalGenerations < 5 then
						if self.surname ~= self.spouse.surname then
							if self.royalGenerations > self.spouse.royalGenerations then nn.surname = self.surname.."-"..self.spouse.surname
							elseif self.royalGenerations < self.spouse.royalGenerations then nn.surname = self.spouse.surname.."-"..self.surname
							else
								if self.gender == "Male" then nn.surname = self.surname.."-"..self.spouse.surname
								else nn.surname = self.spouse.surname.."-"..self.surname end
							end

							local cnt = 0
							for dash in nn.surname:gmatch("%-") do cnt = cnt + 1 end
							if cnt > 1 then
								local ind = 1
								local nsurn = ""
								for x in nn.surname:gmatch("%a+%-") do
									if ind == 2 then nsurn = nsurn.."-"..x ind = ind + 1 end
									if ind == 1 then nsurn = nsurn..x ind = ind + 1 end
								end
								nn.surname = nsurn
							end
						end
					end
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
						else
							nn.royalGenerations = self.royalGenerations + 1
							nn.royalSystem = self.royalSystem
							nn.lastRoyalAncestor = self.lastRoyalAncestor
							if self.gender == "Female" then nn.maternalLineTimes = self.maternalLineTimes + 1 end
						end
					else
						nn.royalGenerations = self.royalGenerations + 1
						nn.royalSystem = self.royalSystem
						nn.lastRoyalAncestor = self.lastRoyalAncestor
						if self.gender == "Female" then nn.maternalLineTimes = self.maternalLineTimes + 1 end
					end
				end

				if self.isruler == true then
					if self.gender == "Male" then nn.maternalLineTimes = 0 end
					nn.royalSystem = self.royalSystem
					local title = self.title
					nn.lastRoyalAncestor = string.format(title.." "..self.name.." "..parent:roman(self.number).." of "..nl.name)
					nn.royalInfo.Gens=nn.royalGenerations
					nn.royalInfo.LastAncestor=nn.lastRoyalAncestor
				else if self.spouse.isruler == true then
					if self.gender == "Female" then nn.maternalLineTimes = 0 end
					nn.royalSystem = self.spouse.royalSystem
					local title = self.spouse.title
					nn.lastRoyalAncestor = string.format(title.." "..self.spouse.name.." "..parent:roman(self.spouse.number).." of "..nl.name)
					nn.royalInfo.Gens=nn.royalGenerations
					nn.royalInfo.LastAncestor=nn.lastRoyalAncestor
				end end

				if self.isruler == true or self.spouse.isruler == true then
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

				for i, j in pairs(self.ethnicity) do nn.ethnicity[i] = j end

				for i, j in pairs(self.spouse.ethnicity) do
					if nn.ethnicity[i] == nil then nn.ethnicity[i] = 0 end
					nn.ethnicity[i] = nn.ethnicity[i] + j
				end

				for i, j in pairs(nn.ethnicity) do nn.ethnicity[i] = nn.ethnicity[i] / 2 end
				nn.nationality = nl.name

				if self.gender == "Female" then nn:SetFamily(self.spouse, self, parent)
				else nn:SetFamily(self, self.spouse, parent) end

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

			SetFamily = function(self, father, mother, parent)
				table.insert(father.children, self)
				table.insert(mother.children, self)
				self.father = parent:makeAscendant(father)
				self.mother = parent:makeAscendant(mother)
			end,

			update = function(self, parent, nl)
				self.age = self.age + 1

				if self.birthplace == "" then self.birthplace = nl.name end
				if self.surname == nil or self.surname == "" then self.surname = parent:name(true, 6) end

				local sys = parent.systems[nl.system]

				local rankLim = 2
				if sys.dynastic == false then rankLim = 1 end

				if self.spouse then if self.spouse.def == nil then self.spouse = nil end end

				if self.gender == "Male" or sys.dynastic == false then
					if self.title ~= nil and self.level ~= nil then
						self.title = sys.ranks[self.level]

						if self.level < #sys.ranks - rankLim then
							local x = math.random(-100, 100)
							if x < -85 then
								self.prevtitle = self.title
								self.level = self.level - 1
							elseif x > 85 then
								self.prevtitle = self.title
								self.level = self.level + 1
							end
						end

						if self.level < 1 then self.level = 1 end
						if self.level >= #sys.ranks - rankLim then self.level = #sys.ranks - rankLim end
						if self.isruler == true then self.level = #sys.ranks end

						if self.parentRuler == true and sys.dynastic == true then self.level = #sys.ranks - 1 end
					else
						self.level = 2
					end

					self.title = sys.ranks[self.level]
				else
					if self.title ~= nil and self.level ~= nil then
						self.title = sys.franks[self.level]

						if self.level < #sys.franks - rankLim then
							local x = math.random(-100, 100)
							if x < -85 then
								self.prevtitle = self.title
								self.level = self.level - 1
							elseif x > 85 then
								self.prevtitle = self.title
								self.level = self.level + 1
							end
						end

						if self.level < 1 then self.level = 1 end
						if self.level >= #sys.franks - rankLim then self.level = #sys.franks - rankLim end
						if self.isruler == true then self.level = #sys.franks end

						if self.parentRuler == true and sys.dynastic == true then self.level = #sys.franks - 1 end
					else
						self.level = 2
					end

					self.title = sys.franks[self.level]
				end

				if self.spouse ~= nil then
					if self.spouse.name == nil then self.spouse = nil end
				end

				if self.spouse == nil then
					if self.age > 15 then
						local c = math.random(1, 8)
						if c == 4 then
							m = math.random(1, #nl.people)
							if nl.people[m].spouse == nil then
								if self.gender ~= nl.people[m].gender then
									self.spouse = nl.people[m]
									nl.people[m].spouse = self
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
											if tmp == 5 then
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

				self.pbelief = self.pbelief + math.random(-2, 2)
				self.ebelief = self.ebelief + math.random(-2, 2)
				self.cbelief = self.cbelief + math.random(-2, 2)

				if self.pbelief < -100 then self.pbelief = -100 end
				if self.pbelief > 100 then self.pbelief = 100 end
				if self.ebelief < -100 then self.ebelief = -100 end
				if self.ebelief > 100 then self.ebelief = 100 end
				if self.cbelief < -100 then self.cbelief = -100 end
				if self.cbelief > 100 then self.cbelief = 100 end

				local pmatch = false
				
				if #nl.parties > 0 then
					for i=1,#nl.parties do if pmatch == false then
						pmatch = true
						if math.abs(nl.parties[i].pfreedom - self.pbelief) > 35 then pmatch = false end
						if math.abs(nl.parties[i].efreedom - self.ebelief) > 35 then pmatch = false end
						if math.abs(nl.parties[i].cfreedom - self.cbelief) > 35 then pmatch = false end
					end end
				end

				if pmatch == false then
					local newp = Party:new()
					newp:makename(parent, nl)
					newp.cfreedom = self.cbelief
					newp.efreedom = self.ebelief
					newp.pfreedom = self.pbelief
					local belieftotal = newp.cfreedom + newp.efreedom + newp.pfreedom

					if math.abs(belieftotal) > 225 then newp.radical = true end

					self.party = newp.name
					if self.isruler == true then nl.rulers[#nl.rulers].Party = self.party end

					table.insert(nl.parties, newp)
				end

				if self.party == "" then
					local pi = parent:randomChoice(nl.parties)
					pmatch = true
					if math.abs(pi.pfreedom - self.pbelief) > 35 then pmatch = false end
					if math.abs(pi.efreedom - self.ebelief) > 35 then pmatch = false end
					if math.abs(pi.cfreedom - self.cbelief) > 35 then pmatch = false end
					if pmatch == true then
						self.party = pi.name
						if self.isruler == true then nl.rulers[#nl.rulers].Party = self.party end
					end
				else
					for i=1,#nl.parties do
						local pi = nl.parties[i]
						local belieftotal = self.pbelief + self.ebelief + self.cbelief
						local partytotal = pi.pfreedom + pi.efreedom + pi.cfreedom
						local diff = math.abs(belieftotal - partytotal)
						if diff < 165 then pi.popularity = pi.popularity + ((100 - (diff / 3)) / #nl.people) end
						if pi.name == self.party then pi.membership = pi.membership + 1
						else
							pmatch = true
							if math.abs(pi.pfreedom - self.pbelief) > 50 then pmatch = false end
							if math.abs(pi.efreedom - self.ebelief) > 50 then pmatch = false end
							if math.abs(pi.cfreedom - self.cbelief) > 50 then pmatch = false end
							if pmatch == true then
								self.party = pi.name
								if self.isruler == true then nl.rulers[#nl.rulers].Party = self.party end
							end
						end
					end
				end

				local movechance = math.random(1, 150)
				if movechance == 12 then
					self.region = ""
					self.city = ""
				end

				if self.military == true then
					self.militaryTraining = self.militaryTraining + 1
					nl.strength = nl.strength + self.militaryTraining
				else
					if self.age < 32 then
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
					self.region = parent:randomChoice(nl.regions).name
					self.city = ""
				end

				if self.city == "" or nl.regions[self.region].cities[self.city] then
					self.city = parent:randomChoice(nl.regions[self.region].cities).name
					if self.spouse then
						self.spouse.region = self.region
						self.spouse.city = self.city
					end
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