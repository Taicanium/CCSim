return
	function()
		Country = {
			new = function(self)
				local nl = {}
				setmetatable(nl, self)
				
				nl.name = ""
				nl.founded = 0
				nl.age = 0
				nl.hasruler = -1
				nl.people = {}
				nl.averageAge = 0
				nl.events = {}
				nl.rulerage = 0
				nl.relations = {}
				nl.rulers = {}
				nl.rulernames = {}
				nl.frulernames = {}
				nl.ongoing = {}
				nl.allyOngoing = {}
				nl.alliances = {}
				nl.system = 1
				nl.snt = {} -- System, Number of Times; i.e. 'snt["Monarchy"] = 1' indicates the country has been a monarchy once.
				nl.formalities = {}
				nl.demonym = ""
				nl.dfif = {} -- Demonym First In Formality; i.e. instead of "Republic of China", use "Chinese Republic"
				nl.stability = 50
				nl.strength = 50
				nl.population = 0
				nl.birthrate = 5
				nl.deathrate = 121
				nl.regions = {}
				nl.parties = {}
				nl.nodes = {}
				nl.civilWars = 0
				nl.capitalregion = nil
				nl.capitalcity = nil
				nl.mtName = "Country"
				
				return nl
			end,

			destroy = function(self)
				for i=1,#self.people do
					self.people[i]:destroy()
					self.people[i] = nil
				end
				for i=1,#self.nodes do
					self.nodes[i][1] = nil
					self.nodes[i][2] = nil
					self.nodes[i][3] = nil
					self.nodes[i] = nil
				end
				self.people = nil
				self.nodes = nil
			end,

			add = function(self, n)
				table.insert(self.people, n)
			end,
			
			checkRuler = function(self, parent)
				if self.hasruler == -1 then
					if #self.rulers > 0 then
						self.rulers[#self.rulers].To = parent.years
					end
					
					if #self.people > 1 then			
						while self.hasruler == -1 do
							local possibles = {}
							local closest = -1
							local closestGens = 10000000
							local closestMats = 10000000
							local closestAge = 10000000
							local sys = parent.systems[self.system]
							if sys.dynastic == true then
								for i=1,#self.people do
									if self.people[i].royalSystem == sys.name then
										table.insert(possibles, i)
									end
								end
								
								for i=1,#possibles do
									if self.people[possibles[i]].royalGenerations <= closestGens then
										if self.people[possibles[i]].maternalLineTimes <= closestMats then
											if self.people[possibles[i]].age <= closestAge then
												closest = possibles[i]
												closestGens = self.people[possibles[i]].royalGenerations
												closestMats = self.people[possibles[i]].maternalLineTimes
												closestAge = self.people[possibles[i]].age
											end
										end
									end
								end
								
								if closest == -1 then
									for i=#self.people,1,-1 do
										local chance = math.random(1, 1000)
										if chance == 25 then self:setRuler(parent, i) end
										i = 0
									end
								else
									self:setRuler(parent, closest)
								end
							else
								for i=#self.people,1,-1 do
									local chance = math.random(1, 1000)
									if chance == 25 then self:setRuler(parent, i) end
									i = 0
								end
							end
						end
					end
				end
			end,

			delete = function(self, y)
				local b = #self.people
				if b > 0 then
					if self.people[y] ~= nil then
						if self.people[y].isruler == true then self.hasruler = -1 end
						w = table.remove(self.people, y)
						if w ~= nil then
							w:destroy()
							w = nil
						end
					end
				end
			end,
			
			event = function(self, parent, e)
				table.insert(self.events, {Event=e, Year=parent.years})
			end,

			eventloop = function(self, parent, ind)
				local v = math.floor(math.random(600, 1000) * self.stability)
				local vi = math.floor(math.random(600, 1000) * (100 - self.stability))
				if v < 1 then v = 1 end
				if vi < 1 then vi = 1 end
				
				if self.ongoing == nil then self.ongoing = {} end
				if self.relations == nil then self.relations = {} end
				
				for i=#self.ongoing,1,-1 do
					if self.ongoing[i] ~= nil then
						if self.ongoing[i].doStep ~= nil then
							local r = self.ongoing[i]:doStep(parent, ind)
							if r == -1 then
								local ro = table.remove(self.ongoing, i)
								ro = nil
							end
						else
							local ro = table.remove(self.ongoing, i)
							ro = nil
						end
					end
				end
				
				for i=1,#parent.c_events do
					if parent.c_events[i].inverse == false then
						local chance = math.floor(math.random(1, v))
						if chance <= parent.c_events[i].chance then
							if parent.c_events[i].args == 1 then
								table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
								if self.ongoing[#self.ongoing].performEvent ~= nil then
									if self.ongoing[#self.ongoing]:performEvent(parent, ind) == -1 then table.remove(self.ongoing, #self.ongoing)
									else
										self.ongoing[#self.ongoing]:beginEvent(parent, ind)
									end
								else table.remove(self.ongoing, #self.ongoing) end
							elseif parent.c_events[i].args == 2 then
								local other = math.random(1, #parent.thisWorld.countries)
								while parent.thisWorld.countries[other].name == self.name do other = math.random(1, #parent.thisWorld.countries) end
								table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
								if self.ongoing[#self.ongoing].performEvent ~= nil then
									if self.ongoing[#self.ongoing]:performEvent(parent, ind, other) == -1 then table.remove(self.ongoing, #self.ongoing)
									else
										self.ongoing[#self.ongoing]:beginEvent(parent, ind, other)
									end
								else table.remove(self.ongoing, #self.ongoing) end
							end
						end
					else
						local chance = math.floor(math.random(1, vi))
						if chance <= parent.c_events[i].chance then
							if parent.c_events[i].args == 1 then
								table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
								if self.ongoing[#self.ongoing].performEvent ~= nil then
									if self.ongoing[#self.ongoing]:performEvent(parent, ind) == -1 then table.remove(self.ongoing, #self.ongoing)
									else
										self.ongoing[#self.ongoing]:beginEvent(parent, ind)
									end
								else table.remove(self.ongoing, #self.ongoing) end
							elseif parent.c_events[i].args == 2 then
								if #parent.thisWorld.countries > 1 then
									local other = math.random(1, #parent.thisWorld.countries)
									while parent.thisWorld.countries[other].name == self.name do other = math.random(1, #parent.thisWorld.countries) end
									table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
									if self.ongoing[#self.ongoing].performEvent ~= nil then
										if self.ongoing[#self.ongoing]:performEvent(parent, ind, other) == -1 then table.remove(self.ongoing, #self.ongoing)
										else
											self.ongoing[#self.ongoing]:beginEvent(parent, ind, other)
										end
									else table.remove(self.ongoing, #self.ongoing) end
								end
							end
						end
					end
				end
				
				local revCount = 0
				
				for i=1,#self.events do
					if self.events[i].Year > parent.years - 50 then
						if self.events[i].Event:sub(1, 10) == "Revolution" then revCount = revCount + 1 end
					end
				end
				
				if revCount > 8 then
					self:event(parent, "Collapsed")
					for i=#parent.thisWorld.countries,1,-1 do
						if parent.thisWorld.countries[i].name == self.name then
							parent.thisWorld:delete(parent, i)
						end
					end
				end
			end,

			makename = function(self, parent)
				if self.name == "" or self.name == nil then
					self.name = parent:name(false)
				end
				
				if #self.rulernames < 1 then
					for k=1,math.random(5, 9) do
						table.insert(self.rulernames, parent:name(true, 7))
					end
					
					for k=1,math.random(5, 9) do
						table.insert(self.frulernames, parent:name(true, 7))
					end
				end
				
				if #self.frulernames < 1 then
					for k=1,math.random(5, 9) do
						table.insert(self.frulernames, parent:name(true, 7))
					end
				end
				
				for i=1,#parent.systems do
					self.formalities[parent.systems[i].name] = parent.systems[i].formalities[math.random(1, #parent.systems[i].formalities)]
					tf = math.random(2, 200)
					if math.floor(tf/2) < 51 then self.dfif[parent.systems[i].name] = true else self.dfif[parent.systems[i].name] = false end
				end
				
				if self.name:sub(#self.name, #self.name) == "a" then self.demonym = self.name.."n"
				elseif self.name:sub(#self.name, #self.name) == "y" then self.demonym = self.name:sub(1, #self.name-1)
				elseif self.name:sub(#self.name, #self.name) == "c" then self.demonym = self.name:sub(1, #self.name-2).."ian"
				elseif self.name:sub(#self.name, #self.name) == "s" then
					if self.name:sub(#self.name-2, #self.name) == "ius" then self.demonym = self.name:sub(1, #self.name-2).."an"
					else self.demonym = self.name:sub(1, #self.name-2).."ian" end
				elseif self.name:sub(#self.name, #self.name) == "i" then self.demonym = self.name.."an"
				elseif self.name:sub(#self.name, #self.name) == "o" then self.demonym = self.name.."nian"
				elseif self.name:sub(#self.name, #self.name) == "k" then self.demonym = self.name:sub(1, #self.name-1).."cian"
				elseif self.name:sub(#self.name-3, #self.name) == "land" then
					split = self.name:sub(1, #self.name-4)
					if split:sub(#split, #split) == "a" then self.demonym = split.."n"
					elseif split:sub(#split, #split) == "y" then self.demonym = split:sub(1, #split-1).."ian"
					elseif split:sub(#split, #split) == "c" then self.demonym = split:sub(1, #split-2).."ian"
					elseif split:sub(#split, #split) == "s" then self.demonym = split:sub(1, #split-2).."ian"
					elseif split:sub(#split, #split) == "i" then self.demonym = split.."an"
					elseif split:sub(#split, #split) == "o" then self.demonym = split.."nian"
					elseif split:sub(#split, #split) == "k" then self.demonym = split:sub(1, #split-1).."cian"
					else self.demonym = split.."ian" end
				else
					if self.name:sub(#self.name-1, #self.name) == "an" then self.demonym = self.name:sub(1, #self.name-2).."ian"
					elseif self.name:sub(#self.name-1, #self.name) == "en" then self.demonym = self.name:sub(1, #self.name-2).."ian"
					elseif self.name:sub(#self.name-1, #self.name) == "un" then self.demonym = self.name:sub(1, #self.name-2).."ian"
					elseif self.name:sub(#self.name-2, #self.name) == "iar" then self.demonym = self.name:sub(1, #self.name-3).."ian"
					elseif self.name:sub(#self.name-1, #self.name) == "ar" then self.demonym = self.name:sub(1, #self.name-2).."ian"
					elseif self.name:sub(#self.name-2, #self.name) == "ian" then self.demonym = self.name
					else self.demonym = self.name.."ian" end
				end
				
				self.demonym = parent:namecheck(self.demonym)
			end,
			
			set = function(self, parent)
				parent:rseed()

				self.system = math.random(1, #parent.systems)
				self.population = math.random(500, 1000)
				self:makename(parent)
				
				for i=1,self.population do
					local n = Person:new()
					n:makename(parent, self)
					n.age = math.random(1, 20)
					n.birth = parent.years - n.age
					if n.birth < 1 then n.birth = n.birth - 1 end
					n.level = 2
					n.title = "Citizen"
					self:add(n)
				end
				
				local rcount = math.random(3, 8)
				for i=1,rcount do
					local r = Region:new()
					r:makename(self, parent)
					self.regions[r.name] = r
				end
				
				while self.capitalregion == nil do
					for i, j in pairs(self.regions) do
						local chance = math.random(1, 30)
						if chance == 15 then self.capitalregion = j.name end
					end
				end
				
				while self.capitalcity == nil do
					for i, j in pairs(self.regions[self.capitalregion].cities) do
						local chance = math.random(1, 30)
						if chance == 15 then self.capitalcity = j.name end
					end
				end
				
				self.founded = parent.years
				
				self.snt[parent.systems[self.system].name] = 1
				self:event(parent, "Establishment of the "..parent:ordinal(self.snt[parent.systems[self.system].name]).." "..self.demonym.." "..self.formalities[parent.systems[self.system].name])
			end,
			
			setPop = function(self, parent, u)
				self.population = u
				
				if #self.people > 1 then
					local r = math.random(1, #self.people)
					while self.people[r].isruler == true do
						r = math.random(1, #self.people)
					end
					self:delete(r)
				end
				
				for i=1,self.population do
					local n = Person:new()
					n:makename(parent, self)
					n.level = 2
					n.title = "Citizen"
					self:add(n)
				end
			end,

			setRuler = function(self, parent, newRuler)
				if self.hasruler == -1 then
					self.people[newRuler].prevName = self.people[newRuler].name
					self.people[newRuler].prevTitle = self.people[newRuler].title
				
					self.people[newRuler].level = #parent.systems[self.system].ranks
					self.people[newRuler].title = parent.systems[self.system].ranks[self.people[newRuler].level]
					
					parent:rseed()

					if self.people[newRuler].gender == "Female" then
						self.people[newRuler].name = self.frulernames[math.floor(math.random(1, #self.frulernames))]
						
						if parent.systems[self.system].franks ~= nil then
							self.people[newRuler].level = #parent.systems[self.system].franks
							self.people[newRuler].title = parent.systems[self.system].franks[self.people[newRuler].level]
						end
					else
						self.people[newRuler].name = self.rulernames[math.floor(math.random(1, #self.rulernames))]
					end
					
					local namenum = 1
					
					for i=1,#self.rulers do
						if tonumber(self.rulers[i].From) >= self.founded then
							if self.rulers[i].name == self.people[newRuler].name then
								if self.rulers[i].Title == self.people[newRuler].title then
									namenum = namenum + 1
								end
							end
						end
					end
					
					self.people[newRuler].isruler = true
					self.hasruler = 0
					
					if parent.systems[self.system].dynastic == true then
						self.people[newRuler].royalInfo = {
							Gens=self.people[newRuler].royalGenerations,
							LastAncestor=self.people[newRuler].lastRoyalAncestor
						}
						self.people[newRuler].royal = true
						self.people[newRuler].royalGenerations = 0
						self.people[newRuler].maternalLineTimes = 0
						self.people[newRuler].royalSystem = parent.systems[self.system].name
						self.people[newRuler].number = namenum
						table.insert(self.rulers, {name=self.people[newRuler].name, Title=self.people[newRuler].title, Number=tostring(namenum), From=parent.years, To="Current", Country=self.name, Party=self.people[newRuler].party})
					else
						table.insert(self.rulers, {name=self.people[newRuler].name, Title=self.people[newRuler].title, Number=self.people[newRuler].surname, From=parent.years, To="Current", Country=self.name, Party=self.people[newRuler].party})
					end
					
					self.rulerage = self.people[newRuler].age
				end
			end,
			
			setTerritory = function(self, parent)
				self.nodes = {}
				
				for i=1,#parent.thisWorld.planetdefined do
					local x = parent.thisWorld.planetdefined[i][1]
					local y = parent.thisWorld.planetdefined[i][2]
					local z = parent.thisWorld.planetdefined[i][3]
					
					if parent.thisWorld.planet[x][y][z].country == self.name then table.insert(self.nodes, {x, y, z}) end
				end
				
				for i=1,#self.nodes do
					local x = self.nodes[i][1]
					local y = self.nodes[i][2]
					local z = self.nodes[i][3]
					
					parent.thisWorld.planet[x][y][z].region = ""
					parent.thisWorld.planet[x][y][z].city = ""
				end
				
				local rCount = 0
				for i, j in pairs(self.regions) do rCount = rCount + 1 end
				
				while rCount >= #self.nodes do
					local r = ""
					for j, k in pairs(self.regions) do if r == "" then r = k.name end end
					parent:deepnil(self.regions[r])
					self.regions[r] = nil
					rCount = 0
					for l, m in pairs(self.regions) do rCount = rCount + 1 end
					print(#self.nodes)
					print(rCount)
				end
				
				for i, j in pairs(self.regions) do
					local x = 0
					local y = 0
					local z = 0
				
					local found = false
					while found == false do
						local pd = self.nodes[math.random(1, #self.nodes)]
						x = pd[1]
						y = pd[2]
						z = pd[3]
						if parent.thisWorld.planet[x][y][z].region == "" then found = true end
					end
					
					parent.thisWorld.planet[x][y][z].region = j.name
					table.insert(j.nodes, {x, y, z})
				end
				
				local allDefined = false
				
				while allDefined == false do
					allDefined = true
					for i=1,#self.nodes do
						local x = self.nodes[i][1]
						local y = self.nodes[i][2]
						local z = self.nodes[i][3]
						
						if parent.thisWorld.planet[x][y][z].region == "" then
							for dx=-1,1 do
								if parent.thisWorld.planet[dx+x] ~= nil then
									for dy=-1,1 do
										if parent.thisWorld.planet[dx+x][dy+y] ~= nil then
											for dz=-1,1 do
												if parent.thisWorld.planet[dx+x][dy+y][dz+z] ~= nil then
													if parent.thisWorld.planet[dx+x][dy+y][dz+z].country == self.name then
														if parent.thisWorld.planet[dx+x][dy+y][dz+z].region ~= "" then
															if parent.thisWorld.planet[dx+x][dy+y][dz+z].regionset == false then
																parent.thisWorld.planet[x][y][z].region = parent.thisWorld.planet[dx+x][dy+y][dz+z].region
																for j, k in pairs(self.regions) do
																	if k.name == parent.thisWorld.planet[x][y][z].region then table.insert(k.nodes, {x, y, z}) end
																end
																parent.thisWorld.planet[x][y][z].regionset = true
																allDefined = false
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
					
					for i=1,#self.nodes do
						local x = self.nodes[i][1]
						local y = self.nodes[i][2]
						local z = self.nodes[i][3]
						
						parent.thisWorld.planet[x][y][z].regionset = false
					end
				end
				
				for i, j in pairs(self.regions) do
					local cCount = 0
					for k, l in pairs(j.cities) do cCount = cCount + 1 end
					
					while cCount >= #j.nodes do
						local r = ""
						for k, l in pairs(j.cities) do if r == "" then r = l.name end end
						local x = j.cities[r].x
						local y = j.cities[r].y
						local z = j.cities[r].z
						if j.cities[r].x ~= nil then parent.thisWorld.planet[x][y][z].city = "" end
						parent:deepnil(j.cities[r])
						j.cities[r] = nil
						cCount = 0
						for m, n in pairs(j.cities) do cCount = cCount + 1 end
					end
				end
				
				for i, j in pairs(self.regions) do
					for k=1,#j.nodes do
						local x = j.nodes[k][1]
						local y = j.nodes[k][2]
						local z = j.nodes[k][3]
						
						parent.thisWorld.planet[x][y][z].city = ""
					end
				end
				
				for i, j in pairs(self.regions) do
					for k, l in pairs(j.cities) do
						if l.x == nil or l.y == nil or l.z == nil then
							local pd = j.nodes[math.random(1, #j.nodes)]
							local x = pd[1]
							local y = pd[2]
							local z = pd[3]
							
							while parent.thisWorld.planet[x][y][z].city ~= "" do
								pd = j.nodes[math.random(1, #j.nodes)]
								x = pd[1]
								y = pd[2]
								z = pd[3]
							end
							
							l.x = x
							l.y = y
							l.z = z
						end
						
						parent.thisWorld.planet[l.x][l.y][l.z].city = l.name
					end
				end
			end,

			update = function(self, parent, ind)
				parent:rseed()
				
				for i=1,#parent.systems do
					if self.snt[parent.systems[i].name] == nil then self.snt[parent.systems[i].name] = 0 end
				end

				self.stability = self.stability + math.random(-2, 2)
				if self.stability > 100 then self.stability = 100 end
				if self.stability < 1 then self.stability = 1 end
				
				self.strength = self.strength + math.random(-2, 2)
				if self.strength > 100 then self.strength = 100 end
				if self.strength < 1 then self.strength = 1 end
				
				self.age = self.age + 1
				
				self.hasruler = -1
				self.averageAge = 0
				
				if #self.parties > 0 then
					for i=1,#self.parties do
						self.parties[i].membership = 0
						self.parties[i].popularity = 0
						self.parties[i].leading = false
					end
				end
				
				if #self.parties > 0 then
					for i=#self.parties,1,-1 do
						self.parties[i].popularity = math.floor(self.parties[i].popularity)
					end
					
					local largest = -1
				
					for i=1,#self.parties do
						if largest == -1 then largest = i end
						if self.parties[i].membership > self.parties[largest].membership then largest = i end
					end
					
					if largest ~= -1 then self.parties[largest].leading = true end
				end
				
				for i=#self.ongoing,1,-1 do
					if self.ongoing[i] ~= nil then
						if self.ongoing[i].target ~= nil then
							if parent.thisWorld.countries[self.ongoing[i].target] ~= nil then
								local found = false
								local er = parent.thisWorld.countries[self.ongoing[i].target].name
								
								for j=1,#parent.thisWorld.countries do
									local nr = parent.thisWorld.countries[j].name
									if nr == er then found = true end
								end
								
								if found == false then
									local ro = table.remove(self.ongoing, i)
									ro = nil
								end
							else table.remove(self.ongoing, i) end
						end
					end
				end
				
				for i=#self.alliances,1,-1 do
					local found = false
					local ar = self.alliances[i]
					
					for j=1,#parent.thisWorld.countries do
						local nr = parent.thisWorld.countries[j].name
						if string.len(ar) >= string.len(nr) then
							if ar:sub(1, #nr) == nr then
								found = true
							end
						end
					end
					
					if found == false then
						local ra = table.remove(self.alliances, i)
						ra = nil
					end
				end
				
				for i, l in pairs(self.relations) do
					local found = false
					for j, k in pairs(parent.thisWorld.countries) do
						if k.name == i then found = true end
					end
				
					if found == false then
						self.relations[i] = nil
						i = nil
					end
				end
				
				for i, l in pairs(parent.thisWorld.countries) do
					if l.name ~= self.name then
						if self.relations[l.name] == nil then
							self.relations[l.name] = 40
						end
						local v = math.random(-3, 3)
						self.relations[l.name] = self.relations[l.name] + v
						if self.relations[l.name] < 1 then self.relations[l.name] = 1 end
						if self.relations[l.name] > 100 then self.relations[l.name] = 100 end
					end
				end
				
				self.population = #self.people
				
				if self.population > parent.popLimit then
					self.deathrate = 20
				else
					self.deathrate = 135
				end
				
				if self.capitalregion == nil or self.regions[self.capitalregion] == nil then
					self.capitalregion = nil
					local values = {}
					for i, j in pairs(self.regions) do table.insert(values, j.name) end
					self.capitalregion = values[math.random(1, #values)]
					self.capitalcity = nil
				end
				
				if self.capitalcity == nil or self.regions[self.capitalregion].cities[self.capitalcity] == nil then
					self.capitalcity = nil
					local values = {}
					for i, j in pairs(self.regions[self.capitalregion].cities) do table.insert(values, j.name) end
					self.capitalcity = values[math.random(1, #values)]
				end
				
				for i, j in pairs(self.regions) do
					j.population = 0
					for k, l in pairs(j.cities) do
						l.population = 0
					end
				end
				
				for i=1,#self.people do
					if self.people[i] ~= nil then
						if self.people[i].isruler == true then
							self.hasruler = 0
							self.rulerage = self.people[i].age
						end
						
						local belieftotal = self.people[i].pbelief + self.people[i].ebelief + self.people[i].cbelief
						
						if #self.parties > 0 then
							for j=#self.parties,1,-1 do
								local partytotal = self.parties[j].pfreedom + self.parties[j].efreedom + self.parties[j].cfreedom
								if math.abs(belieftotal - partytotal) < 100 then
									self.parties[j].popularity = self.parties[j].popularity + ((100 - math.abs(belieftotal - partytotal)) / #self.people)
								end
							
								if self.parties[j].revolted == true then
									local pr = table.remove(self.parties, i)
									pr = nil
								else
									if self.people[i].party == self.parties[j].name then
										self.parties[j].membership = self.parties[j].membership + 1
									end
								end
							end
						end
						
						self.people[i]:update(parent, ind)
						
						self.averageAge = self.averageAge + self.people[i].age
						
						age = self.people[i].age
						if age > 120 then
							if self.people[i].isruler == true then
								self.hasruler = -1
							end
							
							self:delete(i)
						else
							d = math.random(1, self.deathrate)
							if d == 3 then
								if self.people[i].isruler == true then
									self.hasruler = -1
								end
								
								self:delete(i)
							end
						end
					end
				end
				
				self.averageAge = self.averageAge / #self.people
				
				for i=#self.parties,1,-1 do
					self.parties[i].popularity = math.ceil(self.parties[i].popularity)
				end
				
				self:checkRuler(parent)
				self:eventloop(parent, ind)
			end
		}
		
		Country.__index = Country
		Country.__call = function() return Country:new() end
		
		return Country
	end