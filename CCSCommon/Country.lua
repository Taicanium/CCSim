return
	function()
		local Country = {
			new = function(self)
				local nl = {}
				setmetatable(nl, self)

				nl.age = 0
				nl.agPrim = false -- Agnatic primogeniture; if true, only a male person may rule this country while under a dynastic system. 
				nl.alliances = {}
				nl.allyOngoing = {}
				nl.averageAge = 0
				nl.birthrate = 3
				nl.capitalcity = ""
				nl.capitalregion = ""
				nl.civilWars = 0
				nl.demonym = ""
				nl.dfif = {} -- Demonym First In Formality; i.e. instead of "Republic of China", use "Chinese Republic"
				nl.ethnicities = {}
				nl.events = {}
				nl.formalities = {}
				nl.founded = 0
				nl.frulernames = {}
				nl.hasruler = -1
				nl.majority = ""
				nl.military = 0
				nl.mtname = "Country"
				nl.name = ""
				nl.nodes = {}
				nl.ongoing = {}
				nl.parties = {}
				nl.people = {}
				nl.population = 0
				nl.regions = {}
				nl.relations = {}
				nl.rulerage = 0
				nl.rulernames = {}
				nl.rulerParty = ""
				nl.rulers = {}
				nl.snt = {} -- System, number of Times; i.e. 'snt["Monarchy"] = 1' indicates the country has been a monarchy once, or is presently in its first monarchy.
				nl.stability = 50
				nl.strength = 0
				nl.system = 0

				return nl
			end,

			add = function(self, parent, n)
				if not n then return end

				if n.nationality ~= self.name and parent.thisWorld.countries[n.nationality] and parent.thisWorld.countries[n.nationality].people then
					for i=1,#parent.thisWorld.countries[n.nationality].people do parent.thisWorld.countries[n.nationality].people[i].pIndex = i end
					table.remove(parent.thisWorld.countries[n.nationality].people, n.pIndex)
					for i=n.pIndex,#parent.thisWorld.countries[n.nationality].people do parent.thisWorld.countries[n.nationality].people[i].pIndex = i end
				end
				if n.isruler then n.rulerInfo.ruledTo = parent.years end
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
					if n.spouse.isruler then n.spouse.rulerInfo.ruledTo = parent.years end
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

			checkRuler = function(self, parent, enthrone)
				if self.hasruler == -1 then
					if #self.rulers > 0 and tostring(self.rulers[#self.rulers].To) == "Current" and self.rulers[#self.rulers].Country == self.name then self.rulers[#self.rulers].To = parent.years end

					if #self.people > 1 then
						for i=1,#self.people do self.people[i].pIndex = i end

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
										if self.people[i].royalGenerations > 0 then if not self.agPrim or self.people[i].gender == "Male" then
											if self.people[i].royalGenerations == 1 then table.insert(possibles, self.people[i])
											elseif self.people[i].age <= self.averageAge+25 and self.people[i].age >= self.averageAge-25 then table.insert(possibles, self.people[i]) end
										end end
									end

									for i=1,#possibles do
										local psp = possibles[i]
										if psp and psp.royalGenerations < closestGens and psp.maternalLineTimes < closestMats and psp.age > closestAge then
											if psp.gender == "Male" or not self.agPrim then
												closest = psp
												closestGens = psp.royalGenerations
												closestMats = psp.maternalLineTimes
												closestAge = psp.age
											end
										end
									end

									if not closest then
										local p = math.random(1, #self.people)
										if self.people[p].age <= self.averageAge+25 and self.people[p].age >= self.averageAge-25 and self.people[p].rulerName == "" then if self.people[p].gender == "Male" or not self.agPrim then self:setRuler(parent, p, enthrone) end end
									else self:setRuler(parent, closest.pIndex, enthrone) end
								else
									if child.nationality ~= self.name then self:add(parent, child) end
									self:setRuler(parent, child.pIndex, enthrone)
								end
							else
								local p = math.random(1, #self.people)
								if self.people[p].age <= self.averageAge+25 and self.people[p].age >= self.averageAge-25 and self.people[p].rulerName == "" then self:setRuler(parent, p, enthrone) end
							end
						end
					end
				end
			end,

			delete = function(self, parent, y)
				if self.people and #self.people > 0 and self.people[y] then
					table.remove(self.people, y):destroy(parent, self)
					self.population = self.population-1
				end
			end,

			destroy = function(self, parent)
				if self.people then for i=1,#self.people do self:delete(parent, i) end end
				self.people = nil

				for i=#self.ongoing,1,-1 do table.remove(self.ongoing, i) end

				for i, j in pairs(parent.final) do if j.name == self.name then parent.final[i] = nil end end
				table.insert(parent.final, self)
			end,

			event = function(self, parent, e)
				table.insert(self.events, {Event=e:gsub(" of ,", ","):gsub(" of the ,", ","):gsub("  ", " "), Year=parent.years})
			end,

			eventloop = function(self, parent)
				local f0 = _time()

				local rFactor = math.random(175, 375)
				local v = math.floor(rFactor*self.stability)
				local vi = math.floor(rFactor*(100-self.stability))
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

				for i=#self.ongoing,1,-1 do if self.ongoing[i] then if not self.ongoing[i].doStep or self.ongoing[i]:doStep(parent, self) == -1 then table.remove(self.ongoing, i) end end end

				for i=1,#parent.c_events do
					if not parent.disabled[parent.c_events[i].name:lower()] and not parent.disabled["!"..parent.c_events[i].name:lower()] then
						local chance = 0
						if parent.c_events[i].inverse then chance = math.floor(math.random(1, vi)) else chance = math.floor(math.random(1, v)) end
						if chance <= parent.c_events[i].chance then self:triggerEvent(parent, i) end
					end
				end

				local revCount = 0
				for i=1,#self.events do if self.events[i].Year > parent.years-50 and self.events[i].Event:sub(1, 10) == "Revolution" then revCount = revCount+1 end end
				if revCount > 6 then
					self:event(parent, "Collapsed")
					for i=1,#parent.c_events do if parent.c_events[i].name == "Conquer" then self:triggerEvent(parent, i, true) end end
				end

				if _DEBUG then
					if not parent.debugTimes["Country:eventloop"] then parent.debugTimes["Country:eventloop"] = {0, 0} end
					parent.debugTimes["Country:eventloop"][1] = parent.debugTimes["Country:eventloop"][1]+_time()-f0
					parent.debugTimes["Country:eventloop"][2] = parent.debugTimes["Country:eventloop"][2]+1
				end
			end,

			makename = function(self, parent)
				if not self.name or self.name == "" then
					local found = true
					while found do
						self.name = parent:name(false)
						if self.name:sub(self.name:len()-4, self.name:len()) == "sicia" then self.name = self.name:sub(1, self.name:len()-5).."scia" end
						if self.name:sub(self.name:len()-4, self.name:len()) == "shicia" then self.name = self.name:sub(1, self.name:len()-5).."scia" end
						if self.name:sub(self.name:len()-4, self.name:len()) == "zicia" then self.name = self.name:sub(1, self.name:len()-5).."zcia" end
						if self.name:sub(self.name:len()-4, self.name:len()) == "zhicia" then self.name = self.name:sub(1, self.name:len()-5).."zcia" end
						if self.name:sub(self.name:len()-2, self.name:len()) == "lan" then self.name = self.name.."d" end
						if self.name:sub(self.name:len()-1, self.name:len()) == "ay" then self.name = self.name:sub(1, self.name:len()-2).."any" end
						if self.name:sub(self.name:len()-1, self.name:len()) == "ey" then self.name = self.name:sub(1, self.name:len()-2).."eny" end
						if self.name:sub(self.name:len()-1, self.name:len()) == "oy" then self.name = self.name:sub(1, self.name:len()-2).."ony" end
						if self.name:sub(self.name:len()-1, self.name:len()) == "uy" then self.name = self.name:sub(1, self.name:len()-2).."uny" end
						if self.name:sub(self.name:len()-1, self.name:len()) == "ya" then self.name = self.name:sub(1, self.name:len()-2).."ia" end
						if self.name:sub(self.name:len()-1, self.name:len()) == "wy" then self.name = self.name:sub(1, self.name:len()-2).."wia" end
						if self.name:sub(self.name:len(), self.name:len()) == "b" then self.name = self.name.."ia" end
						if self.name:sub(self.name:len(), self.name:len()) == "c" then self.name = self.name.."ia" end
						if self.name:sub(self.name:len(), self.name:len()) == "d" and self.name:sub(self.name:len()-3, self.name:len()) ~= "land" then self.name = self.name.."ia" end
						if self.name:sub(self.name:len(), self.name:len()) == "f" then self.name = self.name.."ia" end
						if self.name:sub(self.name:len(), self.name:len()) == "g" then self.name = self.name.."ia" end
						if self.name:sub(self.name:len(), self.name:len()) == "i" then self.name = self.name.."a" end
						if self.name:sub(self.name:len(), self.name:len()) == "j" then self.name = self.name:sub(1, self.name:len()-1).."ria" end
						if self.name:sub(self.name:len(), self.name:len()) == "k" then self.name = self.name:sub(1, self.name:len()-1).."cia" end
						if self.name:sub(self.name:len(), self.name:len()) == "l" then self.name = self.name.."y" end
						if self.name:sub(self.name:len(), self.name:len()) == "m" then self.name = self.name.."y" end
						if self.name:sub(self.name:len(), self.name:len()) == "n" then self.name = self.name.."y" end
						if self.name:sub(self.name:len(), self.name:len()) == "o" then self.name = self.name.."nia" end
						if self.name:sub(self.name:len(), self.name:len()) == "p" then self.name = self.name.."ia" end
						if self.name:sub(self.name:len(), self.name:len()) == "r" then self.name = self.name.."ia" end
						if self.name:sub(self.name:len(), self.name:len()) == "s" then self.name = self.name.."ia" end
						if self.name:sub(self.name:len(), self.name:len()) == "t" then self.name = self.name.."ia" end
						if self.name:sub(self.name:len(), self.name:len()) == "u" then self.name = self.name.."nia" end
						if self.name:sub(self.name:len(), self.name:len()) == "v" then self.name = self.name.."y" end
						if self.name:sub(self.name:len(), self.name:len()) == "w" then self.name = self.name.."y" end
						if self.name:sub(self.name:len(), self.name:len()) == "z" then self.name = self.name.."ia" end
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
					if math.random(1, 100) < 51 then self.dfif[parent.systems[i].name] = true else self.dfif[parent.systems[i].name] = false end
				end

				if self.name:sub(self.name:len(), self.name:len()) == "a" then self.demonym = self.name:sub(1, self.name:len()-1).."ian"
				elseif self.name:sub(self.name:len(), self.name:len()) == "y" then
					local split = self.name:sub(1, self.name:len()-1)
					if split:sub(split:len(), split:len()) == "y" then self.demonym = split:sub(1, split:len()-1)
					elseif split:sub(split:len(), split:len()) == "s" then self.demonym = split:sub(1, split:len()-1).."ian"
					elseif split:sub(split:len(), split:len()) == "b" then self.demonym = split.."ian"
					elseif split:sub(split:len(), split:len()) == "d" then self.demonym = split.."ish"
					elseif split:sub(split:len(), split:len()) == "f" then self.demonym = split.."ish"
					elseif split:sub(split:len(), split:len()) == "g" then self.demonym = split.."ian"
					elseif split:sub(split:len(), split:len()) == "h" then self.demonym = split.."ian"
					elseif split:sub(split:len(), split:len()) == "a" then self.demonym = split.."n"
					elseif split:sub(split:len(), split:len()) == "e" then self.demonym = split.."n"
					elseif split:sub(split:len(), split:len()) == "i" then self.demonym = split.."n"
					elseif split:sub(split:len(), split:len()) == "o" then self.demonym = split.."n"
					elseif split:sub(split:len(), split:len()) == "u" then self.demonym = split.."n"
					elseif split:sub(split:len(), split:len()) == "l" then self.demonym = split.."ish"
					elseif split:sub(split:len(), split:len()) == "w" then self.demonym = split.."ian"
					elseif split:sub(split:len(), split:len()) == "k" then self.demonym = split:sub(1, split:len()-1).."cian"
					else self.demonym = split end
				elseif self.name:sub(self.name:len(), self.name:len()) == "e" then self.demonym = self.name:sub(1, self.name:len()-1).."ish"
				elseif self.name:sub(self.name:len(), self.name:len()) == "c" then self.demonym = self.name:sub(1, self.name:len()-2).."ian"
				elseif self.name:sub(self.name:len(), self.name:len()) == "s" then
					if self.name:sub(self.name:len()-2, self.name:len()) == "ius" then self.demonym = self.name:sub(1, self.name:len()-2).."an"
					else self.demonym = self.name:sub(1, self.name:len()-2).."ian" end
				elseif self.name:sub(self.name:len(), self.name:len()) == "i" then self.demonym = self.name.."an"
				elseif self.name:sub(self.name:len(), self.name:len()) == "o" then self.demonym = self.name:sub(1, self.name:len()-1).."ian"
				elseif self.name:sub(self.name:len(), self.name:len()) == "k" then if self.name:sub(self.name:len()-1, self.name:len()-1) == "c" then self.demonym = self.name:sub(1, self.name:len()-1).."ian" else self.demonym = self.name:sub(1, self.name:len()-1).."cian" end
				elseif self.name:sub(self.name:len()-3, self.name:len()) == "land" then
					local split = self.name:sub(1, self.name:len()-4)
					if split:sub(split:len(), split:len()) == "a" then self.demonym = split.."n"
					elseif split:sub(split:len(), split:len()) == "y" then self.demonym = split:sub(1, split:len()-1)
					elseif split:sub(split:len(), split:len()) == "c" then self.demonym = split:sub(1, split:len()-1).."ian"
					elseif split:sub(split:len(), split:len()) == "s" then self.demonym = split:sub(1, split:len()-1).."ian"
					elseif split:sub(split:len(), split:len()) == "i" then self.demonym = split.."an"
					elseif split:sub(split:len(), split:len()) == "o" then self.demonym = split:sub(1, split:len()-1).."ian"
					elseif split:sub(split:len(), split:len()) == "g" then self.demonym = split.."lish"
					elseif split:sub(split:len(), split:len()) == "k" then self.demonym = split:sub(1, split:len()-1).."cian"
					else self.demonym = split.."ish" end
				else
					if self.name:sub(self.name:len()-1, self.name:len()) == "ia" then self.demonym = self.name.."n"
					elseif self.name:sub(self.name:len()-2, self.name:len()) == "ian" then self.demonym = self.name
					elseif self.name:sub(self.name:len()-1, self.name:len()) == "an" then self.demonym = self.name.."ese"
					elseif self.name:sub(self.name:len()-2, self.name:len()) == "iar" then self.demonym = self.name:sub(1, self.name:len()-1).."n"
					elseif self.name:sub(self.name:len()-1, self.name:len()) == "ar" then self.demonym = self.name:sub(1, self.name:len()-2).."ian"
					elseif self.name:sub(self.name:len()-2, self.name:len()) == "ium" then self.demonym = self.name:sub(1, self.name:len()-2).."an"
					elseif self.name:sub(self.name:len()-1, self.name:len()) == "um" then self.demonym = self.name:sub(1, self.name:len()-2).."ian"
					elseif self.name:sub(self.name:len()-1, self.name:len()) == "en" then self.demonym = self.name:sub(1, self.name:len()-2).."ian"
					elseif self.name:sub(self.name:len()-1, self.name:len()) == "un" then self.demonym = self.name:sub(1, self.name:len()-2).."ian"
					else self.demonym = self.name.."ian" end
				end

				for i=1,3 do
					self.demonym = self.demonym:gsub("ii", "i")
					self.demonym = self.demonym:gsub("aa", "a")
					self.demonym = self.demonym:gsub("uu", "u")
					self.demonym = self.demonym:gsub("yi", "i")
					self.demonym = self.demonym:gsub("iy", "i")
					self.demonym = self.demonym:gsub("ais", "is")
					self.demonym = self.demonym:gsub("eis", "is")
					self.demonym = self.demonym:gsub("iis", "is")
					self.demonym = self.demonym:gsub("ois", "is")
					self.demonym = self.demonym:gsub("uis", "is")
					self.demonym = self.demonym:gsub("aia", "ia")
					self.demonym = self.demonym:gsub("eia", "ia")
					self.demonym = self.demonym:gsub("iia", "ia")
					self.demonym = self.demonym:gsub("oia", "ia")
					self.demonym = self.demonym:gsub("uia", "ia")
					self.demonym = self.demonym:gsub("dby", "dy")
				end

				local ends = {"ch", "rt", "gh", "ct", "rl", "rn", "rm", "rd", "rs", "lc", "ld", "ln", "lm", "ls", "sc", "nd", "nc", "st", "sh", "ds", "ck", "lg", "lk", "ng"}
				local hasend = false

				while not hasend do
					local cEnd = self.demonym:sub(self.demonym:len()-1, self.demonym:len())
					local cBegin = self.demonym:sub(self.demonym:len()-1, self.demonym:len()-2)
					for i, j in pairs(ends) do if cEnd == j then hasend = true end end
					local c1 = cEnd:sub(1, 1)
					local c2 = cEnd:sub(2, 2)
					for i, j in pairs(parent.vowels) do if c1:lower() == j:lower() then hasend = true elseif c2:lower() == j:lower() then hasend = true end end
					if not hasend then self.demonym = self.demonym.."ian" end
				end
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
					for j=1,#childrenByAge do if not found then
						if t.children[i].birth <= childrenByAge[j].birth then
							table.insert(childrenByAge, j, t.children[i])
							found = true
						end
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

				if self.population <= 1 then self:setPop(parent, math.random(1000, 2000)) end

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

				while self.population > u do
					local r = math.random(1, #self.people)
					if #self.people > 1 then while self.people[r].isruler do r = math.random(1, #self.people) end end
					self:delete(parent, r)
				end

				for i=1,u-self.population do
					local n = Person:new()
					n:makename(parent, self)
					n.age = math.random(16, 80)
					n.birth = parent.years-n.age
					if n.birth < 1 then n.birth = n.birth-1 end
					n.level = 2
					n.title = "Citizen"
					n.ethnicity = {[self.demonym]=100}
					n.birthplace = self.name
					n.gString = n.name.." "..n.surname.." "..n.birth.." "..n.birthplace.." "..tostring(n.number)
					self:add(parent, n)
				end
			end,

			setRuler = function(self, parent, newRuler, enthrone)
				for i=1,#self.people do self.people[i].isruler = false end

				self.people[newRuler].prevtitle = self.people[newRuler].title

				self.people[newRuler].level = #parent.systems[self.system].ranks
				self.people[newRuler].title = parent.systems[self.system].ranks[self.people[newRuler].level]

				parent:rseed()

				if self.people[newRuler].gender == "Female" then
					self.people[newRuler].rulerName = parent:randomChoice(self.frulernames)

					if parent.systems[self.system].franks then
						self.people[newRuler].level = #parent.systems[self.system].franks
						self.people[newRuler].title = parent.systems[self.system].franks[self.people[newRuler].level]
					end
				else
					self.people[newRuler].rulerName = parent:randomChoice(self.rulernames)
				end

				self.people[newRuler].rulerTitle = self.people[newRuler].title

				if parent.systems[self.system].dynastic then
					local namenum = 1

					for i=1,#self.rulers do if self.rulers[i].Country == self.name and self.rulers[i].name == self.people[newRuler].rulerName and self.rulers[i].title == self.people[newRuler].title then namenum = namenum+1 end end
					
					if enthrone and self.people[newRuler].royalGenerations < math.huge and self.people[newRuler].royalGenerations > 0 then self:event(parent, "Enthronement of "..self.people[newRuler].title.." "..self.people[newRuler].rulerName.." "..parent:roman(namenum).." of "..self.name..", "..parent:generationString(self.people[newRuler].royalGenerations, self.people[newRuler].gender).." of "..self.people[newRuler].LastRoyalAncestor) end
					
					self.people[newRuler].rulerInfo = {LastRoyalAncestor=self.people[newRuler].LastRoyalAncestor, royalGenerations=self.people[newRuler].royalGenerations, ruledFrom=parent.years, ruledTo=-1}
					
					self.people[newRuler].number = namenum
					self.people[newRuler].maternalLineTimes = 0
					self.people[newRuler].royalSystem = parent.systems[self.system].name
					self.people[newRuler].royalGenerations = 0
					self.people[newRuler].LastRoyalAncestor = ""
					
					self.people[newRuler].gString = self.people[newRuler].name.." "..self.people[newRuler].surname.." "..self.people[newRuler].birth.." "..self.people[newRuler].birthplace.." "..tostring(self.people[newRuler].number)

					for i, j in pairs(self.people[newRuler].children) do parent:setGensChildren(j, 1, string.format(self.people[newRuler].title.." "..self.people[newRuler].rulerName.." "..parent:roman(self.people[newRuler].number).." of "..self.name)) end

					table.insert(self.rulers, {name=self.people[newRuler].rulerName, title=self.people[newRuler].title, surname=self.people[newRuler].surname, number=tostring(self.people[newRuler].number), children=self.people[newRuler].children, From=parent.years, To="Current", Country=self.name, Party=self.people[newRuler].party})
				else
					table.insert(self.rulers, {name=self.people[newRuler].rulerName, title=self.people[newRuler].title, surname=self.people[newRuler].surname, number=self.people[newRuler].surname, children=self.people[newRuler].children, From=parent.years, To="Current", Country=self.name, Party=self.people[newRuler].party})
				end

				self.hasruler = 0
				self.people[newRuler].isruler = true
				self.people[newRuler].ruledCountry = self.name
				self.rulerage = self.people[newRuler].age
				self.rulerParty = self.people[newRuler].party
			end,

			setTerritory = function(self, parent, patron, patronRegion)
				self.nodes = {}

				for i=1,#parent.thisWorld.planetdefined do
					local x, y, z = table.unpack(parent.thisWorld.planetdefined[i])

					if parent.thisWorld.planet[x][y][z].country == self.name then table.insert(self.nodes, {x, y, z}) end
					parent.thisWorld.planet[x][y][z].region = ""
				end

				local rCount = 0
				for i, j in pairs(self.regions) do rCount = rCount+1 end

				local maxR = math.ceil(#self.nodes/35)

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
						if parent.thisWorld.planet[x][y][z].region == j.name then found = true end
						if found then k = #self.nodes+1 end
					end

					if not found then
						local x = 0
						local y = 0
						local z = 0

						local sFound = false
						while not sFound do
							local pd = parent:randomChoice(self.nodes)
							x, y, z = table.unpack(pd)
							if parent.thisWorld.planet[x][y][z].region == "" or parent.thisWorld.planet[x][y][z].region == j.name then sFound = true end
						end

						parent.thisWorld.planet[x][y][z].region = j.name
						defined = defined+1
					end
				end

				local allDefined = false
				local prevDefined = 0

				while not allDefined do
					for i=1,#self.nodes do
						local x, y, z = table.unpack(self.nodes[i])

						if parent.thisWorld.planet[x][y][z].region ~= "" then
							for j=1,#parent.thisWorld.planet[x][y][z].neighbors do
								local neighbor = parent.thisWorld.planet[x][y][z].neighbors[j]
								local nx, ny, nz = table.unpack(neighbor)
								if parent.thisWorld.planet[nx][ny][nz].region == "" then
									if not parent.thisWorld.planet[x][y][z].regionset then
										parent.thisWorld.planet[nx][ny][nz].region = parent.thisWorld.planet[x][y][z].region
										parent.thisWorld.planet[nx][ny][nz].regionset = true
										defined = defined+1
									end
								end
							end
						end
					end

					if defined == prevDefined then allDefined = true end
					defined = prevDefined

					for i=1,#self.nodes do
						local x, y, z = table.unpack(self.nodes[i])
						parent.thisWorld.planet[x][y][z].regionset = false
					end
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
							table.insert(patron.nodes, self.nodes[i])
							table.insert(patronRegion.nodes, self.nodes[i])
						end
						table.remove(self.nodes, i)
					else table.insert(self.regions[parent.thisWorld.planet[x][y][z].region].nodes, {x, y, z}) end
				end

				if not patron then for i, j in pairs(self.regions) do
					local cCount = 0
					for k, l in pairs(j.cities) do cCount = cCount+1 end

					local maxC = math.ceil(#j.nodes/25)

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

			triggerEvent = function(self, parent, i, r)
				table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
				local newE = self.ongoing[#self.ongoing]

				if parent.c_events[i].args == 1 then
					if not newE.performEvent or newE:performEvent(parent, self, r) == -1 then table.remove(self.ongoing, #self.ongoing)
					else newE:beginEvent(parent, self) end
				elseif parent.c_events[i].args == 2 then
					if parent.numCountries > 1 then
						local other = parent:randomChoice(parent.thisWorld.countries)
						while other.name == self.name do other = parent:randomChoice(parent.thisWorld.countries) end

						if not newE.performEvent or newE:performEvent(parent, self, other, r) == -1 then table.remove(self.ongoing, #self.ongoing)
						else newE:beginEvent(parent, self, other) end
					end
				end
			end,

			update = function(self, parent)
				local f0 = _time()

				parent:rseed()

				for i=1,#parent.systems do if not self.snt[parent.systems[i].name] or self.snt[parent.systems[i].name] == -1 then self.snt[parent.systems[i].name] = 0 end end

				self.stability = self.stability+math.random(-3, 3)
				if self.stability > 100 then self.stability = 100 end
				if self.stability < 1 then self.stability = 1 end

				while math.floor(#self.people) > math.floor(parent.popLimit*3) do self:delete(parent, parent:randomChoice(self.people, true)) end

				self.averageAge = 0
				self.population = #self.people
				self.strength = 0
				self.military = 0
				self.hasruler = -1
				self.age = parent.years-self.founded
				if self.founded < 1 then self.age = self.age-1 end

				if self.population < parent.popLimit then self.birthrate = 3
				else self.birthrate = 75 end

				for i, j in pairs(self.ethnicities) do self.ethnicities[i] = 0 end

				if #self.parties > 0 then
					for i=1,#self.parties do
						self.parties[i].membership = 0
						self.parties[i].popularity = 0
						self.parties[i].leading = false
					end
				end

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
					self.relations[cp.name] = self.relations[cp.name]+math.random(-4, 4)
					if self.relations[cp.name] < 1 then self.relations[cp.name] = 1 end
					if self.relations[cp.name] > 100 then self.relations[cp.name] = 100 end
				end end

				local oldcap = nil
				local oldreg = nil

				if not self.regions[self.capitalregion] then
					oldreg = self.capitalregion
					self.capitalregion = parent:randomChoice(self.regions, true)
					oldcap = self.capitalcity
					self.capitalcity = nil
				end

				if not self.capitalcity or not self.regions[self.capitalregion].cities[self.capitalcity] then
					self.capitalcity = parent:randomChoice(self.regions[self.capitalregion].cities, true)
					if oldcap and self.regions[oldreg] and self.regions[oldreg].cities[oldcap] then self:event(parent, "Capital moved from "..oldcap.." to "..self.capitalcity) end
				end

				for i, j in pairs(self.regions) do
					j.population = 0
					for k, l in pairs(j.cities) do l.population = 0 end
				end

				for i=#self.people,1,-1 do
					local chn = false
					if self.people[i] then self.people[i]:update(parent, self) else chn = true end

					if not chn then
						local age = self.people[i].age
						if age > 100 then
							self:delete(parent, i)
							chn = true
						elseif math.random(1, 30000-math.pow(age, 2)) < math.pow(age, 2) then
							self:delete(parent, i)
							chn = true
						end
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
							self.rulerage = self.people[i].age
							self.rulerParty = self.people[i].party
						end
					end
				end

				self.averageAge = self.averageAge/#self.people

				self:checkRuler(parent, false)

				if #self.parties > 0 then
					for i=#self.parties,1,-1 do self.parties[i].popularity = math.floor(self.parties[i].popularity) end

					local largest = -1

					for i=1,#self.parties do
						if largest == -1 then largest = i end
						if self.parties[i].membership > self.parties[largest].membership then largest = i end
					end

					if largest ~= -1 then self.parties[largest].leading = true end
				end

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
					if not parent.debugTimes["Country:update"] then parent.debugTimes["Country:update"] = {0, 0} end
					parent.debugTimes["Country:update"][1] = parent.debugTimes["Country:update"][1]+_time()-f0
					parent.debugTimes["Country:update"][2] = parent.debugTimes["Country:update"][2]+1
				end
			end
		}

		Country.__call = function() return Country:new() end
		Country.__index = Country

		return Country
	end