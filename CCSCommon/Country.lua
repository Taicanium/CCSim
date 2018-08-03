return
	function()
		local Country = {
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
				nl.deathrate = 2662
				nl.regions = {}
				nl.parties = {}
				nl.nodes = {}
				nl.civilWars = 0
				
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
			end,

			add = function(self, n)
				table.insert(self.people, n)
			end,

			delete = function(self, y)
				local b = #self.people
				if b > 0 then
					if self.people[y] ~= nil then
						if self.people[y].isruler == true then self.hasruler = -1 end
						local w = table.remove(self.people, y)
						if w ~= nil then
							for i=1,#self.regions do
								if self.regions[i].name == w.name then
									for j=1,#self.regions[i].cities do
										if self.regions[i].cities[j].name == w.city then
											self.regions[i].cities[j].population = self.regions[i].cities[j].population - 1
										end
									end
								end
							end
							w:destroy()
							w = nil
						end
					end
				end
			end,

			makename = function(self, parent)
				if self.name == "" or self.name == nil then
					self.name = parent:name(false)
				end
				
				if #self.rulernames < 1 then
					for k=1,math.random(5,9) do
						table.insert(self.rulernames, parent:name(true, 7))
					end
					
					for k=1,math.random(5,9) do
						table.insert(self.frulernames, parent:name(true, 7))
					end
				end
				
				if #self.frulernames < 1 then
					for k=1,math.random(5,9) do
						table.insert(self.frulernames, parent:name(true, 7))
					end
				end
				
				for i=1,#parent.systems do
					self.formalities[parent.systems[i].name] = parent.systems[i].formalities[math.random(1, #parent.systems[i].formalities)]
					local tf = math.random(2, 200)
					if math.floor(tf/2) < 51 then self.dfif[parent.systems[i].name] = true else self.dfif[parent.systems[i].name] = false end
				end
				
				if self.name:sub(#self.name, #self.name) == "a" then self.demonym = self.name.."n"
				elseif self.name:sub(#self.name, #self.name) == "y" then self.demonym = self.name:sub(1, #self.name-1).."ian"
				elseif self.name:sub(#self.name, #self.name) == "c" then self.demonym = self.name:sub(1, #self.name-2).."ian"
				elseif self.name:sub(#self.name, #self.name) == "s" then self.demonym = self.name:sub(1, #self.name-2).."ian"
				elseif self.name:sub(#self.name, #self.name) == "i" then self.demonym = self.name.."an"
				elseif self.name:sub(#self.name, #self.name) == "o" then self.demonym = self.name.."nian"
				elseif self.name:sub(#self.name, #self.name) == "k" then self.demonym = self.name:sub(1, #self.name-1).."cian"
				elseif self.name:sub(#self.name-3, #self.name) == "land" then
					local split = self.name:sub(1, #self.name-4)
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
				
				self.population = 1000
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
				end
			
				if #self.regions > #self.nodes then
					for i=#self.regions,#self.nodes+1,-1 do
						rm = table.remove(self.regions, i)
						parent:deepnil(rm)
						rm = nil
					end
				end
			
				for i=1,#self.regions do
					local located = false
				
					while located == false do
						local j = math.random(1, #self.nodes)
						
						local x = self.nodes[j][1]
						local y = self.nodes[j][2]
						local z = self.nodes[j][3]
						
						if parent.thisWorld.planet[x][y][z].region == "" then
							parent.thisWorld.planet[x][y][z].region = self.regions[i].name
							located = true
						end
					end
				end
				
				local allDefined = false
				local defined = 0
				local passes = 0
				
				while allDefined == false do
					allDefined = true
					defined = 0
					passes = passes + 1
					
					local regIndex = 1
					
					for i=1,#self.nodes do
						local x = self.nodes[i][1]
						local y = self.nodes[i][2]
						local z = self.nodes[i][3]
					
						if parent.thisWorld.planet[x][y][z].region ~= "" then
							defined = defined + 1
							if parent.thisWorld.planet[x][y][z].regionset == false then
								for dx=-1,1 do
									for dy=-1,1 do
										for dz=-1,1 do
											if parent.thisWorld.planet[dx+x] ~= nil then
												if parent.thisWorld.planet[dx+x][dy+y] ~= nil then
													if parent.thisWorld.planet[dx+x][dy+y][dz+z] ~= nil then
														if parent.thisWorld.planet[dx+x][dy+y][dz+z].country == parent.thisWorld.planet[x][y][z].country then
															if parent.thisWorld.planet[dx+x][dy+y][dz+z].region == "" then
																parent.thisWorld.planet[dx+x][dy+y][dz+z].region = parent.thisWorld.planet[x][y][z].region
																for m=1,#self.regions do if self.regions[m].name == parent.thisWorld.planet[x][y][z].region then regIndex = m end end
																parent.thisWorld.planet[dx+x][dy+y][dz+z].regionset = true
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
				
				for i=1,#self.nodes do
					local x = self.nodes[i][1]
					local y = self.nodes[i][2]
					local z = self.nodes[i][3]
					for j=#self.regions,1,-1 do
						if parent.thisWorld.planet[x][y][z].region == self.regions[j].name then table.insert(self.regions[j].nodes, {x, y, z}) end
					end
				end
				
				for i=1,#self.regions do
					if #self.regions[i].cities > #self.regions[i].nodes then
						for j=#self.regions[i].cities,#self.regions[i].nodes+1,-1 do
							local cm = table.remove(self.regions[i].cities, j)
							parent:deepnil(cm)
							cm = nil
						end
					end
					
					for j=1,#self.regions[i].cities do
						local rnd = math.random(1, #self.regions[i].nodes)
						local x = self.regions[i].nodes[rnd][1]
						local y = self.regions[i].nodes[rnd][2]
						local z = self.regions[i].nodes[rnd][3]
						
						while parent.thisWorld.planet[x][y][z].city ~= "" do
							rnd = math.random(1, #self.regions[i].nodes)
							x = self.regions[i].nodes[rnd][1]
							y = self.regions[i].nodes[rnd][2]
							z = self.regions[i].nodes[rnd][3]
						end
						
						self.regions[i].cities[j].x = x
						self.regions[i].cities[j].y = y
						self.regions[i].cities[j].z = z
						parent.thisWorld.planet[x][y][z].city = self.regions[i].cities[j].name
					end
				end
			end,

			set = function(self, parent)
				parent:rseed()

				self.system = math.random(1, #parent.systems)
				self.population = math.random(200,1000)
				self:makename(parent)
				
				local rCount = math.random(3, 8)
				
				for i=1,rCount do
					local r = Region:new()
					r:makename(self, parent)
					
					table.insert(self.regions, r)
				end
				
				local rc = math.random(1, #self.regions)
				local cc = math.random(1, #self.regions[rc].cities)
				self.regions[rc].cities[cc].capital = true
				
				for i=1,self.population do
					local n = Person:new()
					n:makename(parent, self)
					self:add(n)
				end
				
				self.founded = parent.years
				
				self.snt[parent.systems[self.system].name] = 1
				self:event(parent, "Establishment of the "..parent:ordinal(self.snt[parent.systems[self.system].name]).." "..self.demonym.." "..self.formalities[parent.systems[self.system].name])
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
						table.insert(self.rulers, {name=self.people[newRuler].name, Title=self.people[newRuler].title, Number=tostring(namenum), From=parent.years, To="Current", Country=self.name, Party=self.people[newRuler].party})
					else
						table.insert(self.rulers, {name=self.people[newRuler].name, Title=self.people[newRuler].title, Number=self.people[newRuler].surname, From=parent.years, To="Current", Country=self.name, Party=self.people[newRuler].party})
					end
					
					self.rulerage = self.people[newRuler].age
				end
			end,

			checkRuler = function(self, parent)
				if self.hasruler == -1 then
					if #self.rulers > 0 then
						self.rulers[#self.rulers].To = parent.years
					end
					
					if #self.people > 1 then			
						while self.hasruler == -1 do
							local chil = false
							local male = false
							local chils = {}
							
							if parent.systems[self.system].dynastic == true then
								for e=1,#self.people do
									if self.people[e].level == #parent.systems[self.system].ranks - 1 then
										if self.people[e].age < self.averageAge + 20 then
											chil = true
											table.insert(chils, e)
											if self.people[e].gender == "Male" then male = true end
										end
									end
								end
							end
							
							if chil == false then
								local z = math.random(1,#self.people)
								local g = 0
								if parent.systems[self.system].dynastic == true then
									g = math.random(1,math.floor(5000/(math.pow(self.people[z].level, 2))))
								else
									g = math.random(1,2500)
								end
								if g == 2 then
									if self.people[z].age < self.averageAge + 20 then
										self:setRuler(parent, z)
									end
								end
							else
								if male == false then
									self:setRuler(parent, chils[1])
								else
									for q=1,#chils do
										if self.people[chils[q]].gender == "Male" and self.people[chils[q]].age < self.averageAge + 20 then
											if self.hasruler == -1 then
												self:setRuler(parent, chils[q])
												q = #chils + 1
											end
										end
									end
								end
							end
						end
					end
				end
			end,

			setPop = function(self, parent, u)
				self.population = u
			
				for i=1,#self.regions do
					self.regions[i].population = math.ceil(self.population / #self.regions)
				end
				
				self.population = 0
				
				for i=1,#self.regions do
					self.population = self.population + self.regions[i].population
				end
				
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
					n.age = math.random(1, 30)
					n.level = 2
					n.title = "Citizen"
					self:add(n)
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
				
				for i=1,#self.regions do
					self.regions[i].population = 0
					
					for j=1,#self.regions[i].cities do
						self.regions[i].cities[j].population = 0
					end
				end
				
				self.averageAge = 0
				
				if #self.parties > 0 then
					for i=1,#self.parties do
						self.parties[i].membership = 0
						self.parties[i].popularity = 0
						self.parties[i].leading = false
					end
				end
				
				for i=1,#self.people do
					if self.people[i] ~= nil then
						if self.people[i].isruler == true then
							self.hasruler = 0
							self.rulerage = self.people[i].age
						end
						
						self.people[i]:update(parent, self)
						
						local belieftotal = self.people[i].pbelief + self.people[i].ebelief + self.people[i].cbelief
						
						if #self.parties > 0 then
							for i=#self.parties,1,-1 do
								local partytotal = self.parties[i].pfreedom + self.parties[i].efreedom + self.parties[i].cfreedom
								if math.abs(belieftotal - partytotal) < 100 then
									self.parties[i].popularity = self.parties[i].popularity + ((100 - math.abs(belieftotal - partytotal)) / #self.people)
								end
							
								if self.parties[i].revolted == true then
									local pr = table.remove(self.parties, i)
									pr = nil
								else
									if self.people[i].party == self.parties[i].name then
										self.parties[i].membership = self.parties[i].membership + 1
									end
								end
							end
						end
						
						self.averageAge = self.averageAge + self.people[i].age
						
						for j=1,#self.regions do
							if self.regions[j].name == self.people[i].region then
								for k=1,#self.regions[j].cities do
									if self.regions[j].cities[k].name == self.people[i].city then
										self.regions[j].population = self.regions[j].population + 1
										self.regions[j].cities[k].population = self.regions[j].cities[k].population + 1
									end
								end
							end
						end
						
						local age = self.people[i].age
						if age > 121 then
							if self.people[i].isruler == true then
								self.hasruler = -1
							end
							
							self:delete(i)
						else
							local d = math.random(1, math.ceil(self.deathrate - (self.people[i].age * math.sqrt(self.people[i].age))))
							if d < 5 then
								if self.people[i].isruler == true then
									self.hasruler = -1
								end
								
								self:delete(i)
							end
						end
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
				
				self.averageAge = self.averageAge / #self.people
				
				for i=#self.ongoing,1,-1 do
					if self.ongoing[i] ~= nil then
						if self.ongoing[i].target ~= nil then
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
				
				if self.population > 1000 then
					self.birthrate = 15000
				else
					self.birthrate = 5
				end
				
				local capfound = false
				local indicator = false
				
				for i=1,#self.regions do
					for j=1,#self.regions[i].cities do
						if self.regions[i].cities[j].capital == true then
							if capfound == false then
								indicator = true
							else
								self.regions[i].cities[j].capital = false
							end
							
							if indicator == true then capfound = true end
						end
					end
				end
				
				if #self.regions > 1 then
					for i=#self.regions,2,-1 do
						if #self.regions[i].nodes < 6 then
							local j = math.random(1, #self.regions)
							while j == i do j = math.random(1, #self.regions) end
							
							for k=1,#self.regions[i].nodes do
								local x = self.regions[i].nodes[k][1]
								local y = self.regions[i].nodes[k][2]
								local z = self.regions[i].nodes[k][3]
								parent.thisWorld.planet[x][y][z].region = self.regions[j].name
								table.insert(self.regions[j].nodes, {x, y, z})
							end
							
							local rm = table.remove(self.regions, i)
							parent:deepnil(rm)
							rm = nil
						end
					end
				end
				
				self:checkRuler(parent)
				
				self:eventloop(parent, ind)
			end,

			event = function(self, parent, e)
				table.insert(self.events, {Event=e:gsub("of the ,", ","):gsub(" ,", ","):gsub(" \\.", "."):gsub("from  to", "to"), Year=parent.years})
			end,

			eventloop = function(self, parent, ind)
				local v = math.floor(math.random(500, 900) * self.stability)
				local vi = math.floor(math.random(500, 900) * (100 - self.stability))
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
								if self.ongoing[#self.ongoing]:performEvent(parent, ind) == -1 then table.remove(self.ongoing, #self.ongoing)
								else
									self.ongoing[#self.ongoing]:beginEvent(parent, ind)
								end
							elseif parent.c_events[i].args == 2 then
								local other = math.random(1, #parent.thisWorld.countries)
								while parent.thisWorld.countries[other].name == self.name do other = math.random(1, #parent.thisWorld.countries) end
								table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
								if self.ongoing[#self.ongoing]:performEvent(parent, ind, other) == -1 then table.remove(self.ongoing, #self.ongoing)
								else
									self.ongoing[#self.ongoing]:beginEvent(parent, ind, other)
								end
							end
						end
					else
						local chance = math.floor(math.random(1, vi))
						if chance <= parent.c_events[i].chance then
							if parent.c_events[i].args == 1 then
								table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
								if self.ongoing[#self.ongoing]:performEvent(parent, ind) == -1 then table.remove(self.ongoing, #self.ongoing)
								else
									self.ongoing[#self.ongoing]:beginEvent(parent, ind)
								end
							elseif parent.c_events[i].args == 2 then
								if #parent.thisWorld.countries > 1 then
									local other = math.random(1, #parent.thisWorld.countries)
									while parent.thisWorld.countries[other].name == self.name do other = math.random(1, #parent.thisWorld.countries) end
									table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
									if self.ongoing[#self.ongoing]:performEvent(parent, ind, other) == -1 then table.remove(self.ongoing, #self.ongoing)
									else
										self.ongoing[#self.ongoing]:beginEvent(parent, ind, other)
									end
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
							parent.thisWorld:delete(i)
						end
					end
				end
			end
		}
		
		Country.__index = Country
		Country.__call = function() return Country:new() end
		
		return Country
	end