return
	function()
		local Country = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.age = 0
				o.agPrim = false -- Agnatic primogeniture; if true, only a male person may rule this country while under a dynastic system.
				o.alliances = {}
				o.allyOngoing = {}
				o.averageAge = 0
				o.birthrate = 3
				o.capitalcity = ""
				o.capitalregion = ""
				o.civilWars = 0
				o.demonym = ""
				o.dfif = {} -- Demonym First In Formality; i.e. instead of "Republic of China", use "Chinese Republic"
				o.ethnicities = {}
				o.events = {}
				o.formalities = {}
				o.founded = 0
				o.frulernames = {}
				o.hasruler = -1
				o.majority = ""
				o.military = 0
				o.name = ""
				o.nodes = {}
				o.ongoing = {}
				o.parties = {}
				o.people = {}
				o.population = 0
				o.regions = {}
				o.relations = {}
				o.ruler = nil
				o.rulernames = {}
				o.rulerParty = nil
				o.rulerPopularity = 0
				o.rulers = {}
				o.snt = {} -- System, number of Times; i.e. 'snt["Monarchy"] = 1' indicates the country has been a monarchy once, or is presently in its first monarchy.
				o.stability = 50
				o.strength = 0
				o.system = 0

				return o
			end,

			add = function(self, parent, n)
				if not n then return end

				if n.nationality ~= self.name and parent.thisWorld.countries[n.nationality] and parent.thisWorld.countries[n.nationality].people then
					for i=1,#parent.thisWorld.countries[n.nationality].people do parent.thisWorld.countries[n.nationality].people[i].pIndex = i end
					table.remove(parent.thisWorld.countries[n.nationality].people, n.pIndex)
					for i=n.pIndex,#parent.thisWorld.countries[n.nationality].people do parent.thisWorld.countries[n.nationality].people[i].pIndex = i end
				end
				n.nationality = self.name
				n.region = nil
				n.city = nil
				n.level = 2
				n.title = "Citizen"
				n.military = false
				n.isruler = false
				n.parentRuler = false
				if n.spouse then
					if n.spouse.nationality ~= self.name then
						if parent.thisWorld.countries[n.spouse.nationality] and parent.thisWorld.countries[n.spouse.nationality].people and parent.thisWorld.countries[n.spouse.nationality].people[n.spouse.pIndex] and parent.thisWorld.countries[n.spouse.nationality].people[n.spouse.pIndex].gString == n.spouse.gString then
							table.remove(parent.thisWorld.countries[n.spouse.nationality].people, n.spouse.pIndex)
							for i=n.spouse.pIndex,#parent.thisWorld.countries[n.spouse.nationality].people do parent.thisWorld.countries[n.spouse.nationality].people[i].pIndex = i end
						end
					end
					n.spouse.nationality = self.name
					n.spouse.region = nil
					n.spouse.city = nil
					n.spouse.level = 2
					n.spouse.title = "Citizen"
					n.spouse.military = false
					n.spouse.isruler = false
					n.spouse.parentRuler = false
					table.insert(self.people, n.spouse)
					n.spouse.pIndex = #self.people
				end
				table.insert(self.people, n)
				n.pIndex = #self.people
				self.population = #self.people
			end,

			-- [[ 0: No border of any kind.
			--    1: This country borders the specified other country over water.
			--    2: This country borders the specified other country directly.
			borders = function(self, parent, other)
				if not other then return 0 end
				local border = 0
				for i=1,#parent.thisWorld.planetdefined do
					local x, y, z = table.unpack(parent.thisWorld.planetdefined[i])
					local node1 = parent.thisWorld.planet[x][y][z]
					if node1.country == self.name and border < 2 then
						for j=1,#node1.neighbors do
							local x2, y2, z2 = table.unpack(node1.neighbors[j])
							local node2 = parent.thisWorld.planet[x2][y2][z2]
							if node2.country == other.name then return 2 end
							if node2.land == false and border < 1 then border = 1 end
						end
					end
				end
				if border == 1 then
					border = 0
					for i=1,#parent.thisWorld.planetdefined do
						local x, y, z = table.unpack(parent.thisWorld.planetdefined[i])
						local node1 = parent.thisWorld.planet[x][y][z]
						if node1.country == other.name then
							for j=1,#node1.neighbors do
								local x2, y2, z2 = table.unpack(node1.neighbors[j])
								local node2 = parent.thisWorld.planet[x2][y2][z2]
								if node2.land == false then return 1 end
							end
						end
					end
				end

				return 0
			end,

			checkRuler = function(self, parent, enthrone)
				if self.hasruler == -1 then
					self.ruler = nil
					if #self.rulers > 0 and tostring(self.rulers[#self.rulers].To) == "Current" and self.rulers[#self.rulers].Country == self.name then self.rulers[#self.rulers].To = parent.years end

					if #self.people > 1 then
						for i=1,#self.people do if self.people[i] and self.people[i].def then self.people[i].pIndex = i end end

						while self.hasruler == -1 do
							local sys = parent.systems[self.system]
							if sys.dynastic then
								local child = nil
								for r=#self.rulers,1,-1 do if not child and tonumber(self.rulers[r].number) and self.rulers[r].Country == self.name then if self.rulers[r].title == sys.ranks[#sys.ranks] or self.rulers[r].title == sys.franks[#sys.franks] then child = self:recurseRoyalChildren(self.rulers[r]) end end end

								if not child then
									local possibles = {}
									local closest = nil
									local closestGens = math.huge
									local closestMats = math.huge
									local closestAge = -1

									for i=1,#self.people do
										if self.people[i] and self.people[i].def and self.people[i].royalGenerations > 0 then if not self.agPrim or self.people[i].gender == "Male" then
											if self.people[i].royalGenerations == 1 then table.insert(possibles, self.people[i])
											elseif self.people[i].age <= self.averageAge+25 and self.people[i].age >= self.averageAge-25 then table.insert(possibles, self.people[i]) end
										end end
									end

									for i=1,#possibles do
										local psp = possibles[i]
										if psp and psp.royalGenerations < closestGens and psp.maternalLineTimes < closestMats and psp.age > closestAge then if psp.gender == "Male" or not self.agPrim then
											closest = psp
											closestGens = psp.royalGenerations
											closestMats = psp.maternalLineTimes
											closestAge = psp.age
										end end
									end

									if not closest then
										local p = math.random(1, #self.people)
										if self.people[p] and self.people[p].def and self.people[p].age <= self.averageAge+25 and self.people[p].age >= self.averageAge-25 and self.people[p].rulerName == "" then if self.people[p].gender == "Male" or not self.agPrim then self:setRuler(parent, p, enthrone) end end
									else self:setRuler(parent, closest.pIndex, enthrone) end

									possibles = nil
								else
									if child.nationality ~= self.name then self:add(parent, child) end
									self:setRuler(parent, child.pIndex, enthrone)
								end
							else
								local p = math.random(1, #self.people)
								if self.people[p] and self.people[p].def and self.people[p].age <= self.averageAge+25 and self.people[p].age >= self.averageAge-25 and self.people[p].rulerName == "" then self:setRuler(parent, p, enthrone) end
							end
						end
					end
				end
			end,

			delete = function(self, parent, y)
				if self.people and #self.people > 0 and self.people[y] then
					local z = table.remove(self.people, y)
					z:destroy(parent, self)
					self.population = self.population-1
				end
			end,

			destroy = function(self, parent)
				if self.people then for i, j in pairs(self.people) do self:delete(parent, i) end end
				self.people = nil

				if self.parties then for i, j in pairs(self.parties) do j = nil end end
				self.parties = nil

				if self.ongoing then for i=#self.ongoing,1,-1 do self.ongoing[i] = nil end end
				self.ongoing = nil

				parent:deepnil(self.alliances)
				parent:deepnil(self.allyOngoing)
				parent:deepnil(self.ethnicities)
				parent:deepnil(self.relations)
				self.alliances = nil
				self.allyOngoing = nil
				self.ethnicities = nil
				self.relations = nil

				for i, j in pairs(parent.final) do if j.name == self.name then parent.final[i] = nil end end
				table.insert(parent.final, self)
			end,

			event = function(self, parent, e)
				table.insert(self.events, {Event=e:gsub(" of ,", ","):gsub(" of the ,", ","):gsub("  ", " "), Year=parent.years})
			end,

			eventloop = function(self, parent)
				local t0 = _time()

				local v = math.floor(math.random(100, 160)*self.stability)
				local vi = math.floor(math.random(100, 160)*(100-self.stability))
				if v < 1 then v = 1 end
				if vi < 1 then vi = 1 end

				if not self.ongoing then self.ongoing = {} end
				if not self.relations then self.relations = {} end

				for i=#self.ongoing,1,-1 do
					if self.ongoing[i] and self.ongoing[i].args > 1 then
						local found = false
						if self.ongoing[i].target and self.ongoing[i].target.name then for j, k in pairs(parent.thisWorld.countries) do if k.name == self.ongoing[i].target.name then found = true end end end
						if not found then table.remove(self.ongoing, i) end
					end
				end

				for i=#self.ongoing,1,-1 do if not self.ongoing[i] or not self.ongoing[i].doStep or self.ongoing[i]:doStep(parent, self) == -1 then table.remove(self.ongoing, i) end end

				for i=1,#parent.c_events do
					if not parent.disabled[parent.c_events[i].name:lower()] and not parent.disabled["!"..parent.c_events[i].name:lower()] then
						local chance = 0
						if parent.c_events[i].inverse then chance = math.floor(math.random(1, vi)) else chance = math.floor(math.random(1, v)) end
						if chance <= parent.c_events[i].chance then self:triggerEvent(parent, i) end
					end
				end

				if _DEBUG then
					if not debugTimes["Country.eventloop"] then debugTimes["Country.eventloop"] = 0 end
					debugTimes["Country.eventloop"] = debugTimes["Country.eventloop"]+_time()-t0
				end
			end,

			makename = function(self, parent)
				if not self.name or self.name == "" then
					local found = true
					while found do
						self.name = parent:name(false)
						found = false
						for i, j in pairs(parent.final) do if j.name == self.name or j.name:gsub("h", "") == self.name or j.name == self.name:gsub("h", "") then found = true end end
					end
				end

				if #self.rulernames < 1 then
					local rn = math.random(5, 9)
					for k=1,rn do table.insert(self.rulernames, parent:name(true)) end
				end

				if #self.frulernames < 1 then
					local rn = math.random(5, 9)
					for k=1,rn do table.insert(self.frulernames, parent:name(true)) end
				end

				for i=1,#parent.systems do
					self.formalities[parent.systems[i].name] = parent:randomChoice(parent.systems[i].formalities)
					self.dfif[parent.systems[i].name] = parent:randomChoice({true, false})
				end

				self.demonym = parent:demonym(self.name)
			end,

			recurseRoyalChildren = function(self, t)
				if not t.children then return nil end
				if #t.children == 0 then return nil end

				local childrenByAge = {}
				local hasMale = false
				local eldestLiving = nil

				table.insert(childrenByAge, t.children[1])
				for i=2,#t.children do
					local found = false
					for j=1,#childrenByAge do if not found and t.children[i].birth <= childrenByAge[j].birth then
						table.insert(childrenByAge, j, t.children[i])
						found = true
					end end
					if not found then table.insert(childrenByAge, t.children[i]) end
				end

				for i=1,#childrenByAge do if childrenByAge[i].gender == "Male" then hasMale = true end end
				for i=1,#childrenByAge do if not eldestLiving then
					if hasMale then
						if childrenByAge[i].gender == "Male" and not childrenByAge[i].isruler and childrenByAge[i].rulerName == "" then if childrenByAge[i].def then eldestLiving = childrenByAge[i] else eldestLiving = self:recurseRoyalChildren(childrenByAge[i]) end end
					elseif not self.agPrim then
						if not childrenByAge[i].isruler and childrenByAge[i].rulerName == "" then if childrenByAge[i].def then eldestLiving = childrenByAge[i] else eldestLiving = self:recurseRoyalChildren(childrenByAge[i]) end end
					end
				end end

				return eldestLiving
			end,

			set = function(self, parent)
				parent:rseed()

				self.system = math.random(1, #parent.systems)
				self:makename(parent, 3)
				self.agPrim = parent:randomChoice({true, false})

				if self.population <= 1 then if _DEBUG then self:setPop(parent, 150) else self:setPop(parent, math.random(750, 1500)) end end

				local rcount = 0
				for i, j in pairs(self.regions) do rcount = rcount+1 end
				if rcount == 0 then
					rcount = math.random(3, 6)
					for i=1,rcount do
						local r = Region:new()
						r:makename(self, parent)
						self.regions[r.name] = r
					end
				end

				self.capitalregion = parent:randomChoice(self.regions, true)
				self.capitalcity = parent:randomChoice(self.regions[self.capitalregion].cities, true)

				if self.founded == 0 then self.founded = parent.years end

				if not self.snt[parent.systems[self.system].name] or self.snt[parent.systems[self.system].name] == -1 then self.snt[parent.systems[self.system].name] = 0 end
				self.snt[parent.systems[self.system].name] = self.snt[parent.systems[self.system].name]+1
				self:event(parent, "Establishment of the "..parent:ordinal(self.snt[parent.systems[self.system].name]).." "..self.demonym.." "..self.formalities[parent.systems[self.system].name])
			end,

			setPop = function(self, parent, u)
				if u < 100 then return end

				while #self.people > u do
					local r = math.random(1, #self.people)
					if #self.people > 1 then while self.people[r].isruler do r = math.random(1, #self.people) end end
					self:delete(parent, r)
				end

				for i=1,u-#self.people do
					local n = Person:new()
					n:makename(parent, self)
					n.age = math.random(16, 80)
					n.birth = parent.years-n.age
					if n.birth < 1 then n.birth = n.birth-1 end
					n.level = 2
					n.title = "Citizen"
					n.ethnicity = {[self.demonym]=100}
					n.birthplace = self.name
					n.gString = n.gender:sub(1, 1).." "..n.name.." "..n.surname.." "..n.birth.." "..n.birthplace
					self:add(parent, n)
				end
			end,

			setRuler = function(self, parent, newRuler, enthrone)
				for i=1,#self.people do self.people[i].isruler = false end

				self.people[newRuler].prevtitle = self.people[newRuler].title
				self.people[newRuler].level = #parent.systems[self.system].ranks
				self.people[newRuler].title = parent.systems[self.system].ranks[self.people[newRuler].level]
				self.rulerParty = self.parties[self.people[newRuler].party]

				parent:rseed()

				if self.people[newRuler].gender == "Female" then
					if parent.systems[self.system].dynastic then self.people[newRuler].rulerName = parent:randomChoice(self.frulernames) end
					if parent.systems[self.system].franks then
						self.people[newRuler].level = #parent.systems[self.system].franks
						self.people[newRuler].title = parent.systems[self.system].franks[self.people[newRuler].level]
					end
				else if parent.systems[self.system].dynastic then self.people[newRuler].rulerName = parent:randomChoice(self.rulernames) end end

				self.hasruler = 0
				self.ruler = self.people[newRuler]
				self.people[newRuler].isruler = true
				self.people[newRuler].ruledCountry = self.name
				self.people[newRuler].rulerTitle = self.people[newRuler].title

				if parent.systems[self.system].dynastic then
					local namenum = 1
					local unisex = 0
					for i=1,#self.rulernames do if self.rulernames[i] == self.people[newRuler].rulerName then unisex = 1 end end
					for i=1,#self.frulernames do if self.frulernames[i] == self.people[newRuler].rulerName then unisex = unisex == 1 and 2 or 0 end end

					for i=1,#self.rulers do if self.rulers[i].dynastic and self.rulers[i].Country == self.name and self.rulers[i].name == self.people[newRuler].rulerName then if self.rulers[i].title == self.people[newRuler].title or unisex then namenum = namenum+1 end end end

					for i, j in pairs(self.people[newRuler].children) do parent:setGensChildren(j, 1, self.people[newRuler].rulerTitle.." "..self.people[newRuler].rulerName.." "..parent:roman(namenum).." of "..self.name) end

					if enthrone and self.people[newRuler].royalGenerations < math.huge and self.people[newRuler].royalGenerations > 0 then self:event(parent, "Enthronement of "..self.people[newRuler].rulerTitle.." "..self.people[newRuler].rulerName.." "..parent:roman(namenum).." of "..self.name..", "..parent:generationString(self.people[newRuler].royalGenerations, self.people[newRuler].gender).." of "..self.people[newRuler].LastRoyalAncestor) end

					self.people[newRuler].number = namenum
					self.people[newRuler].maternalLineTimes = 0
					self.people[newRuler].royalSystem = parent.systems[self.system].name
					self.people[newRuler].royalGenerations = 0
					self.people[newRuler].LastRoyalAncestor = ""
					self.people[newRuler].gString = self.people[newRuler].gender:sub(1, 1).." "..self.people[newRuler].name.." "..self.people[newRuler].surname.." "..self.people[newRuler].birth.." "..self.people[newRuler].birthplace

					table.insert(self.rulers, {dynastic=true, name=self.people[newRuler].rulerName, title=self.people[newRuler].rulerTitle, surname=self.people[newRuler].surname, number=tostring(self.people[newRuler].number), children=self.people[newRuler].children, From=parent.years, To="Current", Country=self.name, Party=self.people[newRuler].party})
				else
					table.insert(self.rulers, {dynastic=false, name=self.people[newRuler].name, title=self.people[newRuler].rulerTitle, surname=self.people[newRuler].surname, number=self.people[newRuler].surname, children=self.people[newRuler].children, From=parent.years, To="Current", Country=self.name, Party=self.people[newRuler].party})
				end

				parent.writeMap = true
			end,

			setTerritory = function(self, parent, patron, patronRegion)
				parent:deepnil(self.nodes)
				self.nodes = {}

				for i=1,#parent.thisWorld.planetdefined do
					local x, y, z = table.unpack(parent.thisWorld.planetdefined[i])
					if parent.thisWorld.planet[x][y][z].country == self.name then
						table.insert(self.nodes, {x, y, z})
						parent.thisWorld.planet[x][y][z].region = ""
						parent.thisWorld.planet[x][y][z].regionSet = false
						parent.thisWorld.planet[x][y][z].regionDone = false
					end
				end

				local rCount = 0
				local maxR = math.ceil(#self.nodes/35)
				for i, j in pairs(self.regions) do rCount = rCount+1 end

				while rCount > maxR or rCount > #self.nodes do
					local r = parent:randomChoice(self.regions, true)
					self.regions[r] = nil
					rCount = rCount-1
				end

				local defined = 0

				for i, j in pairs(self.regions) do
					local found = false
					for k=1,#self.nodes do
						local x, y, z = table.unpack(self.nodes[k])
						if parent.thisWorld.planet[x][y][z].region == j.name then
							found = true
							defined = defined+1
						end
						if found then k = #self.nodes+1 end
					end

					if not found then
						local sFound = nil
						while not sFound do
							local pd = parent:randomChoice(self.nodes)
							local x, y, z = table.unpack(pd)
							if parent.thisWorld.planet[x][y][z].region == "" or parent.thisWorld.planet[x][y][z].region == j.name then sFound = parent.thisWorld.planet[x][y][z] end
						end

						sFound.region = j.name
						defined = defined+1
					end
				end

				local allDefined = false
				local prevDefined = defined

				while not allDefined do
					for i=1,#self.nodes do
						local x, y, z = table.unpack(self.nodes[i])

						if parent.thisWorld.planet[x][y][z].region ~= "" and not parent.thisWorld.planet[x][y][z].regionSet and not parent.thisWorld.planet[x][y][z].regionDone then
							for j=1,#parent.thisWorld.planet[x][y][z].neighbors do
								local neighbor = parent.thisWorld.planet[x][y][z].neighbors[j]
								local nx, ny, nz = table.unpack(neighbor)
								if parent.thisWorld.planet[nx][ny][nz].country == self.name and parent.thisWorld.planet[nx][ny][nz].region == "" then
									parent.thisWorld.planet[nx][ny][nz].region = parent.thisWorld.planet[x][y][z].region
									parent.thisWorld.planet[nx][ny][nz].regionSet = true
									defined = defined+1
								end
							end
							parent.thisWorld.planet[x][y][z].regionDone = true
						end
					end

					for i=1,#self.nodes do
						local x, y, z = table.unpack(self.nodes[i])
						parent.thisWorld.planet[x][y][z].regionSet = false
					end

					if defined == prevDefined then allDefined = true end
					prevDefined = defined
				end

				for i=#self.nodes,1,-1 do
					local x, y, z = table.unpack(self.nodes[i])

					if parent.thisWorld.planet[x][y][z].region == "" or not self.regions[parent.thisWorld.planet[x][y][z].region] then
						if not patron then
							parent.thisWorld.planet[x][y][z].country = ""
							parent.thisWorld.planet[x][y][z].land = false
						else
							parent.thisWorld.planet[x][y][z].country = patron.name
							parent.thisWorld.planet[x][y][z].region = patronRegion.name
							table.insert(patron.nodes, {x, y, z})
							table.insert(patronRegion.nodes, {x, y, z})
						end
						local rn = table.remove(self.nodes, i)
						parent:deepnil(rn)
					else table.insert(self.regions[parent.thisWorld.planet[x][y][z].region].nodes, {x, y, z}) end
				end

				if not patron then for i, j in pairs(self.regions) do
					local cCount = 0
					local maxC = math.ceil(#j.nodes/25)
					for k, l in pairs(j.cities) do cCount = cCount+1 end

					while cCount > maxC or cCount > #j.nodes do
						local c = parent:randomChoice(j.cities, true)
						local r = j.cities[c]
						local x = r.x
						local y = r.y
						local z = r.z
						if r.x and r.y and r.z then parent.thisWorld.planet[x][y][z].city = "" end
						j.cities[c] = nil
						cCount = cCount-1
					end
				end end

				for i, j in pairs(self.regions) do
					for k, l in pairs(j.cities) do
						if not patron then
							for m=1,#self.nodes do
								local x, y, z = table.unpack(self.nodes[m])
								if parent.thisWorld.planet[x][y][z].city == l.name then
									l.x = x
									l.y = y
									l.z = z
									m = #self.nodes+1
								end
							end

							if not l.x or not l.y or not l.z then
								local pd = parent:randomChoice(j.nodes)
								local x, y, z = table.unpack(pd)
								local cFound = false
								while not cFound do
									pd = parent:randomChoice(j.nodes)
									x, y, z = table.unpack(pd)
									if parent.thisWorld.planet[x][y][z].city == "" or parent.thisWorld.planet[x][y][z].city == l.name then cFound = true end
								end

								l.x = x
								l.y = y
								l.z = z
							end

							parent.thisWorld.planet[l.x][l.y][l.z].city = l.name
						else j.cities[k] = nil end
					end
				end
			end,

			triggerEvent = function(self, parent, i, r, o)
				local newE = parent:deepcopy(parent.c_events[i])
				table.insert(self.ongoing, newE)

				if parent.c_events[i].args == 1 then
					if not newE.performEvent or newE:performEvent(parent, self) == -1 then table.remove(self.ongoing, #self.ongoing)
					else newE:beginEvent(parent, self) end
				elseif parent.c_events[i].args == 2 and parent.numCountries > 1 then
					local other = nil
					if r then other = o else
						other = parent:randomChoice(parent.thisWorld.countries)
						while other.name == self.name do other = parent:randomChoice(parent.thisWorld.countries) end
					end

					if not newE.performEvent or newE:performEvent(parent, self, other, r) == -1 then table.remove(self.ongoing, #self.ongoing)
					else newE:beginEvent(parent, self, other) end
				end
			end,

			update = function(self, parent)
				local t0 = _time()
				parent:rseed()

				for i=1,#parent.systems do if not self.snt[parent.systems[i].name] or self.snt[parent.systems[i].name] == -1 then self.snt[parent.systems[i].name] = 0 end end
				self.stability = self.stability+((math.random()-0.4)/2)+math.random(-2, 2)
				if self.stability > 100 then self.stability = 100 end
				if self.stability < 1 then self.stability = 1 end

				while math.floor(#self.people) > math.floor(parent.popLimit*3) do self:delete(parent, parent:randomChoice(self.people, true)) end

				self.averageAge = 0
				self.population = #self.people
				self.strength = 0
				self.military = 0
				self.hasruler = -1
				self.rulerPopularity = 0
				self.age = parent.years-self.founded
				if self.founded < 1 then self.age = self.age-1 end
				if self.population < parent.popLimit then self.birthrate = 3
				else self.birthrate = 40 end
				for i, j in pairs(self.ethnicities) do self.ethnicities[i] = 0 end

				for i=#self.alliances,1,-1 do
					local found = false
					local ar = self.alliances[i]

					for j, cp in pairs(parent.thisWorld.countries) do
						local nr = cp.name
						if ar:len() >= nr:len() and ar:sub(1, #nr) == nr then found = true end
					end

					if not found then table.remove(self.alliances, i) end
				end

				for i, j in pairs(self.relations) do
					local found = false
					for k, cp in pairs(parent.thisWorld.countries) do if cp.name == self.name then found = true end end
					if not found then self.relations[i] = nil end
				end

				for i, cp in pairs(parent.thisWorld.countries) do if cp.name ~= self.name then
					if not self.relations[cp.name] then self.relations[cp.name] = 50 end
					self.relations[cp.name] = self.relations[cp.name]+((math.random()-0.4)/2)+math.random(-3, 3)
					if self.relations[cp.name] < 1 then self.relations[cp.name] = 1
					elseif self.relations[cp.name] > 100 then self.relations[cp.name] = 100 end
				end end

				local oldcap = nil
				local oldreg = nil

				if not self.regions[self.capitalregion] then
					oldreg = self.capitalregion
					oldcap = self.capitalcity
					self.capitalregion = parent:randomChoice(self.regions, true)
					self.capitalcity = nil
				end

				if self.regions[self.capitalregion] then if not self.capitalcity or not self.regions[self.capitalregion].cities[self.capitalcity] then
					self.capitalcity = parent:randomChoice(self.regions[self.capitalregion].cities, true)
					if oldcap and self.regions[oldreg] and self.regions[oldreg].cities[oldcap] then self:event(parent, "Capital moved from "..oldcap.." to "..self.capitalcity) end
				end end

				for i, j in pairs(self.regions) do
					j.population = 0
					for k, l in pairs(j.cities) do l.population = 0 end
				end

				for i=#self.people,1,-1 do
					local chn = false
					if self.people[i] and self.people[i].def then self.people[i]:update(parent, self) else chn = true end

					if not chn then
						local age = self.people[i].age
						if 35000-math.pow(age, 2) <= 1 or math.random(1, 35000-math.pow(age, 2)) < math.pow(age, 2) then chn = true end
					end

					if not chn and not self.people[i].isruler and math.random(1, 20000) == 3799 then
						local cp = parent:randomChoice(parent.thisWorld.countries)
						if parent.numCountries > 1 then while cp.name == self.name do cp = parent:randomChoice(parent.thisWorld.countries) end end
						cp:add(parent, self.people[i])
						chn = true
					end

					if not chn then
						self.people[i].pIndex = i
						self.averageAge = self.averageAge+self.people[i].age
						if self.people[i].military then self.military = self.military+1 end
						if self.people[i].isruler then
							self.hasruler = 0
							self.ruler = self.people[i]
							self.rulerParty = self.parties[self.people[i].party]
						end
					end

					if chn then self:delete(parent, i) end
				end

				self.averageAge = self.averageAge/#self.people
				self.rulerPopularity = self.rulerPopularity/(3*#self.people)
				self:checkRuler(parent, false)
				local largest = ""
				local largestN = 0
				for i, j in pairs(self.ethnicities) do
					self.ethnicities[i] = (self.ethnicities[i]/#self.people)*100
					if j >= largestN then
						largest = i
						largestN = j
					end
				end
				self.majority = largest

				if _DEBUG then
					if not debugTimes["Country.update"] then debugTimes["Country.update"] = 0 end
					debugTimes["Country.update"] = debugTimes["Country.update"]+_time()-t0
				end
			end
		}

		Country.__index = Country
		Country.__call = function() return Country:new() end

		return Country
	end
