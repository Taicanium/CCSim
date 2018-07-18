return
	function()
		local Country = {
			new = function(self)
				local nl = {}
				setmetatable(nl, {__index=self, __call=function() return Country:new() end})
				
				nl.name = ""
				nl.founded = 0
				nl.age = 0
				nl.average = 1
				nl.hasruler = -1
				nl.people = {}
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
				nl.stability = 50
				nl.strength = 50
				nl.population = 0
				nl.birthrate = 25
				nl.deathrate = 15000
				nl.regions = {}
				nl.parties = {}
				
				return nl
			end,

			destroy = function(self)
				for i=1,#self.people do
					self.people[i]:destroy()
					self.people[i] = nil
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
					self.name = parent:name()
				end
				
				if #self.rulernames < 1 then
					for k=1,math.random(5,9) do
						table.insert(self.rulernames, parent:name())
					end
					
					for k=1,math.random(5,9) do
						table.insert(self.frulernames, parent:name())
					end
				end
				
				if #self.frulernames < 1 then
					for k=1,math.random(5,9) do
						table.insert(self.frulernames, parent:name())
					end
				end
				
				self.population = 1000
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
				
				for i=1,self.population do
					local n = Person:new()
					n:makename(parent, self)
					self:add(n)
				end
				
				local rc = math.random(1, #self.regions)
				local cc = math.random(1, #self.regions[rc].cities)
				self.regions[rc].cities[cc].capital = true
				
				self.founded = parent.years
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
							if self.rulers[i].Name == self.people[newRuler].name then
								if self.rulers[i].Title == self.people[newRuler].title then
									namenum = namenum + 1
								end
							end
						end
					end
					
					self.people[newRuler].isruler = true
					self.hasruler = 0
					
					if parent.systems[self.system].dynastic == true then
						table.insert(self.rulers, {Name=self.people[newRuler].name, Title=self.people[newRuler].title, Number=tostring(namenum), From=parent.years, To="Current", Country=self.name, Party=self.people[newRuler].party})
					else
						table.insert(self.rulers, {Name=self.people[newRuler].name, Title=self.people[newRuler].title, Number=self.people[newRuler].surname, From=parent.years, To="Current", Country=self.name, Party=self.people[newRuler].party})
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
										if self.people[e].age < self.average + 25 then
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
									self:setRuler(parent, z)
								end
							else
								if male == false then
									self:setRuler(parent, chils[1])
								else
									for q=1,#chils do
										if self.people[chils[q]].gender == "Male" and self.people[chils[q]].age < self.average + 25 then
											if self.hasruler == -1 then
												self:setRuler(parent, chils[q])
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

				self.stability = self.stability + math.random(-3, 3)
				if self.stability > 100 then self.stability = 100 end
				if self.stability < 1 then self.stability = 1 end
				
				self.strength = self.strength + math.random(-3, 3)
				if self.strength > 100 then self.strength = 100 end
				if self.strength < 1 then self.strength = 1 end
				
				self.age = self.age + 1
				
				self.hasruler = -1
				self.average = 1
				
				local pcmarked = {}
				
				for i=1,#pcmarked do
					table.remove(self.parties, pcmarked[i])
					for j=i,#pcmarked do
						pcmarked[j] = pcmarked[j] - 1
					end
					
					local par = Party:new()
					par:define(parent, ind)
					table.insert(self.parties, par)
				end
				
				if #self.parties > 0 then
					local largest = 1
					for i=1,#self.parties do
						self.parties[i].leading = false
						if self.parties[i].membership > self.parties[largest].membership then largest = i end
					end
					
					self.parties[largest].leading = true
				else
					local pc = math.random(3, 7)
					for i=1,pc do
						local par = Party:new()
						par:define(parent, ind)
						table.insert(self.parties, par)
					end
				end
				
				local pmarked = {}
				
				for i=1,#self.regions do
					self.regions[i].population = 0
					
					for j=1,#self.regions[i].cities do
						self.regions[i].cities[j].population = 0
					end
				end
				
				for i=1,#self.people do
					if self.people[i] ~= nil then
						if self.people[i].isruler == true then
							self.hasruler = 0
							self.rulerage = self.people[i].age
						end
						
						self.people[i]:update(parent, self)
						
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
							
							table.insert(pmarked, i)
						else
							local d = math.random(1, self.deathrate - math.pow(self.people[i].age, 2))
							if d < 5 then
								if self.people[i].isruler == true then
									self.hasruler = -1
								end
								
								table.insert(pmarked, i)
							else
								self.average = self.average + age
							end
						end
					end
				end
				
				for i=1,#pmarked do
					self:delete(pmarked[i])
					for j=i,#pmarked do
						pmarked[i] = pmarked[i] - 1
					end
				end
				
				if #self.people > 0 then self.average = self.average / #self.people end
				
				if #self.parties > 0 then
					local largest = 1
					for i=1,#self.parties do
						self.parties[i].leading = false
						if self.parties[i].membership > self.parties[largest].membership then largest = i end
					end
					
					self.parties[largest].leading = true
				else
					local pc = math.random(3, 7)
					for i=1,pc do
						local par = Party:new()
						par:define(parent, ind)
						table.insert(self.parties, par)
					end
				end
				
				local largestParty = -1
				local largestPartyMem = -1
				
				for i=1,#self.parties do
					if self.parties[i].membership > largestPartyMem then
						largestParty = i
						largestPartyMem = self.parties[i].membership
					end
					
					self.parties[i].leading = false
				end

				if largestParty ~= -1 then
					self.parties[largestParty].leading = true
				end
				
				for i=1,#self.parties do
					if self.parties[i]:evaluate(self, parent, ind) == -1 then
						table.insert(pcmarked, i)
					end
				end
				
				local omarked = {}
				local amarked = {}
				
				for i=1,#self.ongoing do
					if self.ongoing[i] ~= nil then
						if self.ongoing[i].Target ~= nil then
							local found = false
							local er = parent.thisWorld.countries[self.ongoing[i].Target].name:reverse()
							
							for j=1,#parent.thisWorld.countries do
								local nr = parent.thisWorld.countries[j].name:reverse()
								if string.len(er) >= string.len(nr) then
									if er:sub(1, #nr) == nr then
										found = true
									end
								end
							end
							
							if found == false then
								table.insert(omarked, i)
							end
						end
					end
				end
				
				for i=1,#self.alliances do
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
						table.insert(amarked, i)
					end
				end
				
				for i=1,#omarked do
					table.remove(self.ongoing, omarked[i])
					for j=i,#omarked do
						omarked[j] = omarked[j] - 1
					end
				end
				
				for i=1,#amarked do
					table.remove(self.alliances, amarked[i])
					for j=i,#amarked do
						amarked[j] = amarked[j] - 1
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
				
				if self.population > 2000 then
					self.birthrate = 10000000
				else
					self.birthrate = 25
				end
				
				self:checkRuler(parent)
				
				self:eventloop(parent, ind)
			end,

			event = function(self, parent, e)
				table.insert(self.events, {Event=e, Year=parent.years})
			end,

			eventloop = function(self, parent, ind)
				local v = math.floor(math.random(500, 900) * self.stability)
				local vi = math.floor(math.random(500, 900) * (100 - self.stability))
				if v < 1 then v = 1 end
				if vi < 1 then vi = 1 end
				
				if self.ongoing == nil then self.ongoing = {} end
				if self.relations == nil then self.relations = {} end
				
				local omarked = {}
				
				for i=1,#self.ongoing do
					if self.ongoing[i] ~= nil then
						if self.ongoing[i].Step ~= nil then
							local r = self.ongoing[i]:Step(parent, ind)
							if r == -1 then
								table.insert(omarked, i)
							end
						else
							table.insert(omarked, i)
						end
					end
				end
				
				for i=1,#omarked do
					table.remove(self.ongoing, omarked[i])
					for j=i,#omarked do
						omarked[j] = omarked[j] - 1
					end
				end
				
				for i=1,#parent.c_events do
					if parent.c_events[i].Inverse == false then
						local chance = math.floor(math.random(1, v))
						if chance <= parent.c_events[i].Chance then
							if parent.c_events[i].Args == 1 then
								table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
								if self.ongoing[#self.ongoing]:Perform(parent, ind) == -1 then table.remove(self.ongoing, #self.ongoing)
								else
									self.ongoing[#self.ongoing]:Begin(parent, ind)
								end
							elseif parent.c_events[i].Args == 2 then
								local other = math.random(1, #parent.thisWorld.countries)
								while parent.thisWorld.countries[other].name == self.name do other = math.random(1, #parent.thisWorld.countries) end
								table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
								if self.ongoing[#self.ongoing]:Perform(parent, ind, other) == -1 then table.remove(self.ongoing, #self.ongoing)
								else
									self.ongoing[#self.ongoing]:Begin(parent, ind, other)
								end
							end
						end
					else
						local chance = math.floor(math.random(1, vi))
						if chance <= parent.c_events[i].Chance then
							if parent.c_events[i].Args == 1 then
								table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
								if self.ongoing[#self.ongoing]:Perform(parent, ind) == -1 then table.remove(self.ongoing, #self.ongoing)
								else
									self.ongoing[#self.ongoing]:Begin(parent, ind)
								end
							elseif parent.c_events[i].Args == 2 then
								local other = math.random(1, #parent.thisWorld.countries)
								while parent.thisWorld.countries[other].name == self.name do other = math.random(1, #parent.thisWorld.countries) end
								table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
								if self.ongoing[#self.ongoing]:Perform(parent, ind, other) == -1 then table.remove(self.ongoing, #self.ongoing)
								else
									self.ongoing[#self.ongoing]:Begin(parent, ind, other)
								end
							end
						end
					end
				end
			end
		}
		
		return Country
	end