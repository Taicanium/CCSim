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
				nl.system = 0
				nl.snt = {} -- System, number of Times; i.e. 'snt["Monarchy"] = 1' indicates the country has been a monarchy once.
				nl.formalities = {}
				nl.demonym = ""
				nl.dfif = {} -- Demonym First In Formality; i.e. instead of "Republic of China", use "Chinese Republic"
				nl.stability = 50
				nl.strength = 0
				nl.military = 0
				nl.population = 0
				nl.ethnicities = {}
				nl.majority = ""
				nl.birthrate = 3
				nl.regions = {}
				nl.parties = {}
				nl.rulerParty = ""
				nl.nodes = {}
				nl.civilWars = 0
				nl.capitalregion = ""
				nl.capitalcity = ""
				nl.mtname = "Country"

				return nl
			end,

			add = function(self, parent, n)
				if n.nationality ~= self.name then
					if parent.thisWorld.countries[n.nationality] then if parent.thisWorld.countries[n.nationality].people then
						for i=1,#parent.thisWorld.countries[n.nationality].people do parent.thisWorld.countries[n.nationality].people[i].pIndex = i end
						table.remove(parent.thisWorld.countries[n.nationality].people, n.pIndex)
						for i=n.pIndex,#parent.thisWorld.countries[n.nationality].people do parent.thisWorld.countries[n.nationality].people[i].pIndex = i end
					end end
				end
				n.nationality = self.name
				n.region = ""
				n.city = ""
				n.military = false
				n.isruler = false
				n.parentRuler = false
				if n.spouse then
					if n.spouse.nationality ~= self.name then
						if parent.thisWorld.countries[n.spouse.nationality] then if parent.thisWorld.countries[n.spouse.nationality].people then if parent.thisWorld.countries[n.spouse.nationality].people[n.spouse.pIndex] then if parent.thisWorld.countries[n.spouse.nationality].people[n.spouse.pIndex].gString == n.spouse.gString then
							table.remove(parent.thisWorld.countries[n.spouse.nationality].people, n.spouse.pIndex)
							for i=n.spouse.pIndex,#parent.thisWorld.countries[n.spouse.nationality].people do parent.thisWorld.countries[n.spouse.nationality].people[i].pIndex = i end
						end end end end
					end
					n.spouse.nationality = self.name
					n.spouse.region = ""
					n.spouse.city = ""
					n.spouse.military = false
					n.spouse.isruler = false
					table.insert(self.people, n.spouse)
					self.population = self.population + 1
				end
				table.insert(self.people, n)
				self.population = self.population + 1
			end,

			checkRuler = function(self, parent)
				if self.hasruler == -1 then
					if #self.rulers > 0 and self.rulers[#self.rulers].Country == self.name then self.rulers[#self.rulers].To = parent.years end

					if #self.people > 1 then
						while self.hasruler == -1 do
							local sys = parent.systems[self.system]
							if sys.dynastic then
								local child = nil
								for r=#self.rulers,1,-1 do if not child and tonumber(self.rulers[r].number) and self.rulers[r].Country == self.name then if self.rulers[r].title == sys.ranks[#sys.ranks] or self.rulers[r].title == sys.franks[#sys.franks] then child = self:recurseRoyalChildren(self.rulers[r]) end end end

								if not child then
									local possibles = {}
									local closest = nil
									local closestGens = 1000000
									local closestMats = 1000000
									local closestAge = -1

									for i=1,#self.people do
										if self.people[i].royalGenerations > 0 then
											if self.people[i].royalGenerations == 1 then table.insert(possibles, self.people[i])
											elseif self.people[i].age <= self.averageAge + 25 then table.insert(possibles, self.people[i]) end
										end
									end

									for i=1,#possibles do
										local psp = possibles[i]
										if psp then if psp.royalGenerations <= closestGens then
											if psp.maternalLineTimes <= closestMats then
												if psp.age >= closestAge then
													closest = psp
													closestGens = psp.royalGenerations
													closestMats = psp.maternalLineTimes
													closestAge = psp.age
												end
											end
										end end
									end

									if not closest then
										local p = math.random(1, #self.people)
										if self.people[p].age <= self.averageAge + 25 and self.people[p].royalName == "" then self:setRuler(parent, p) end
									else self:setRuler(parent, closest.pIndex) end
								else
									if child.nationality ~= self.name then self:add(parent, child) end
									for i=1,#self.people do self.people[i].pIndex = i end
									self:setRuler(parent, child.pIndex)
								end
							else
								local p = math.random(1, #self.people)
								if self.people[p].age <= self.averageAge + 25 and self.people[p].royalName == "" then self:setRuler(parent, p) end
							end
						end
					end
				end
			end,

			delete = function(self, parent, y)
				if self.people then if #self.people > 0 then
					if self.people[y] then
						self.people[y].death = parent.years
						self.people[y].deathplace = self.name
						table.insert(parent.royals, self.people[y])
						w = table.remove(self.people, y)
						if w then w:destroy() end
						self.population = self.population - 1
					end
				end end
			end,

			destroy = function(self, parent)
				if self.people then
					for i=1,#self.people do self:delete(parent, i) end
					self.people = nil
				end

				for i=#self.ongoing,1,-1 do table.remove(self.ongoing, i) end

				for i, j in pairs(parent.final) do if j.name == self.name then parent.final[i] = nil end end
				table.insert(parent.final, self)
			end,

			event = function(self, parent, e)
				table.insert(self.events, {Event=e:gsub(" of ,", ","):gsub(" of the ,", ","):gsub("  ", " "), Year=parent.years})
			end,

			eventloop = function(self, parent)
				local v = math.floor(math.random(300, 800) * math.floor(self.stability))
				local vi = math.floor(math.random(300, 800) * (100 - math.floor(self.stability)))
				if v < 1 then v = 1 end
				if vi < 1 then vi = 1 end

				if not self.ongoing then self.ongoing = {} end
				if not self.relations then self.relations = {} end

				for i=#self.ongoing,1,-1 do
					if self.ongoing[i] then
						if self.ongoing[i].args > 1 then
							local found = false
							if self.ongoing[i].target and self.ongoing[i].target.name then for j, k in pairs(parent.thisWorld.countries) do if k.name == self.ongoing[i].target.name then found = true end end end
							if not found then table.remove(self.ongoing, i) end
						end
					end
				end

				for i=#self.ongoing,1,-1 do
					if self.ongoing[i] then
						if self.ongoing[i].doStep then
							local r = self.ongoing[i]:doStep(parent, self)
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
					local isDisabled = false
					if parent.disabled[parent.c_events[i].name:lower()] then isDisabled = true end
					if parent.disabled["!"..parent.c_events[i].name:lower()] then isDisabled = true end
					if not isDisabled then
						local chance = math.floor(math.random(1, v))
						if parent.c_events[i].inverse then chance = math.floor(math.random(1, vi)) end
						if chance <= parent.c_events[i].chance then self:triggerEvent(parent, i) end
					end
				end

				local revCount = 0

				for i=1,#self.events do if self.events[i].Year > parent.years - 50 and self.events[i].Event:sub(1, 10) == "Revolution" then revCount = revCount + 1 end end

				if revCount > 6 then
					if self.rulers[#self.rulers].To == "Current" then self.rulers[#self.rulers].To = parent.years end
					self:event(parent, "Collapsed")
					for i=1,#self.people do parent:randomChoice(parent.thisWorld.countries):add(parent, self.people[i]) end
					parent.thisWorld:delete(parent, self)
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
						for i, j in pairs(parent.final) do if j.name == self.name then found = true end end
					end
				end

				if #self.rulernames < 1 then
					for k=1,math.random(5, 9) do table.insert(self.rulernames, parent:name(true)) end
					for k=1,math.random(5, 9) do table.insert(self.frulernames, parent:name(true)) end
				end

				if #self.frulernames < 1 then for k=1,math.random(5, 9) do table.insert(self.frulernames, parent:name(true)) end end

				for i=1,#parent.systems do
					self.formalities[parent.systems[i].name] = parent:randomChoice(parent.systems[i].formalities)
					tf = math.random(1, 100)
					if tf < 51 then self.dfif[parent.systems[i].name] = true else self.dfif[parent.systems[i].name] = false end
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
				elseif self.name:sub(self.name:len(), self.name:len()) == "k" then self.demonym = self.name:sub(1, self.name:len()-1).."cian"
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
				local childrenLiving = {}
				local hasMale = false

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

				local found = false
				local eldestLiving = nil
				for i=1,#childrenByAge do if not found then if childrenByAge[i].def then if not childrenByAge[i].isruler and childrenByAge[i].royalName == "" then
					found = true
					table.insert(childrenLiving, childrenByAge[i])
					if childrenByAge[i].gender == "Male" then hasMale = true end
				end end end end

				if not found then
					for i=1,#childrenByAge do
						if not eldestLiving then
							if not hasMale then
								local nextLevel = self:recurseRoyalChildren(childrenByAge[i])
								if nextLevel then eldestLiving = nextLevel end
							elseif childrenByAge[i].gender == "Male" then
								local nextLevel = self:recurseRoyalChildren(childrenByAge[i])
								if nextLevel then eldestLiving = nextLevel end
							end
						end
					end
				else
					if not hasMale then eldestLiving = childrenLiving[1]
					else
						local mFound = false
						for i=1,#childrenLiving do if not mFound then if childrenLiving[i].gender == "Male" then
							eldestLiving = childrenLiving[i]
							mFound = true
						end end end
					end
				end

				return eldestLiving
			end,

			set = function(self, parent)
				parent:rseed()

				self.system = math.random(1, #parent.systems)
				self:makename(parent, 3)

				if self.population <= 1 then self:setPop(parent, math.random(1000, 2000)) end

				for i=1,#self.people do self.people[i].pIndex = i end

				local rcount = 0
				for i, j in pairs(self.regions) do rcount = rcount + 1 end
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
				self.snt[parent.systems[self.system].name] = self.snt[parent.systems[self.system].name] + 1
				self:event(parent, "Establishment of the "..parent:ordinal(self.snt[parent.systems[self.system].name]).." "..self.demonym.." "..self.formalities[parent.systems[self.system].name])
			end,

			setPop = function(self, parent, u)
				while self.population > u do
					local r = math.random(1, #self.people)
					if #self.people > 1 then while self.people[r].isruler do r = math.random(1, #self.people) end end
					self:delete(parent, r)
				end

				for i=1,u-self.population do
					local n = Person:new()
					n:makename(parent, self)
					n.age = math.random(1, 20)
					n.birth = parent.years - n.age
					if n.birth < 1 then n.birth = n.birth - 1 end
					n.level = 2
					n.title = "Citizen"
					n.ethnicity = {[self.demonym]=100}
					n.birthplace = self.name
					n.gString = n.name.." "..n.surname.." "..n.birth.." "..n.birthplace.." "..tostring(n.number)
					self:add(parent, n)
				end

				for i=1,#self.people do self.people[i].pIndex = i end
			end,

			setRuler = function(self, parent, newRuler)
				for i=1,#self.people do self.people[i].isruler = false end

				self.people[newRuler].prevtitle = self.people[newRuler].title

				self.people[newRuler].level = #parent.systems[self.system].ranks
				self.people[newRuler].title = parent.systems[self.system].ranks[self.people[newRuler].level]

				parent:rseed()

				if self.people[newRuler].gender == "Female" then
					self.people[newRuler].royalName = parent:randomChoice(self.frulernames)

					if parent.systems[self.system].franks then
						self.people[newRuler].level = #parent.systems[self.system].franks
						self.people[newRuler].title = parent.systems[self.system].franks[self.people[newRuler].level]
					end
				else
					self.people[newRuler].royalName = parent:randomChoice(self.rulernames)
				end

				if parent.systems[self.system].dynastic then
					local namenum = 1

					for i=1,#self.rulers do if self.rulers[i].Country == self.name and tonumber(self.rulers[i].From) >= self.founded and self.rulers[i].name == self.people[newRuler].royalName and self.rulers[i].title == self.people[newRuler].title then namenum = namenum + 1 end end

					self.people[newRuler].RoyalTitle = self.people[newRuler].title
					self.people[newRuler].royalGenerations = 0
					self.people[newRuler].maternalLineTimes = 0
					self.people[newRuler].royalSystem = parent.systems[self.system].name
					self.people[newRuler].number = namenum

					table.insert(self.rulers, {name=self.people[newRuler].royalName, title=self.people[newRuler].title, surname=self.people[newRuler].surname, number=tostring(self.people[newRuler].number), children=self.people[newRuler].children, From=parent.years, To="Current", Country=self.name, Party=self.people[newRuler].party})

					self.people[newRuler].gString = self.people[newRuler].name.." "..self.people[newRuler].surname.." "..self.people[newRuler].birth.." "..self.people[newRuler].birthplace.." "..tostring(self.people[newRuler].number)

					for i, j in pairs(self.people[newRuler].children) do parent:setGensChildren(j, 1, string.format(self.people[newRuler].title.." "..self.people[newRuler].royalName.." "..parent:roman(self.people[newRuler].number).." of "..self.name)) end
				else
					table.insert(self.rulers, {name=self.people[newRuler].royalName, title=self.people[newRuler].title, surname=self.people[newRuler].surname, number=self.people[newRuler].surname, children=self.people[newRuler].children, From=parent.years, To="Current", Country=self.name, Party=self.people[newRuler].party})
				end

				self.hasruler = 0
				self.people[newRuler].isruler = true
				self.rulerage = self.people[newRuler].age
				self.rulerParty = self.people[newRuler].party
			end,

			setTerritory = function(self, parent)
				self.nodes = {}

				for i=1,#parent.thisWorld.planetdefined do
					local x = parent.thisWorld.planetdefined[i][1]
					local y = parent.thisWorld.planetdefined[i][2]
					local z = parent.thisWorld.planetdefined[i][3]

					if parent.thisWorld.planet[x][y][z].country == self.name then table.insert(self.nodes, {x, y, z}) end
					parent.thisWorld.planet[x][y][z].region = ""
				end

				local rCount = 0
				for i, j in pairs(self.regions) do rCount = rCount + 1 end

				local maxR = math.ceil(#self.nodes / 35)

				while rCount > maxR do
					local r = parent:randomChoice(self.regions, true)
					self.regions[r] = nil
					rCount = 0
					for l, m in pairs(self.regions) do rCount = rCount + 1 end
				end
				
				for i, j in pairs(self.regions) do
					local found = false
					for k=1,#self.nodes do
						local x = self.nodes[k][1]
						local y = self.nodes[k][2]
						local z = self.nodes[k][3]
						if parent.thisWorld.planet[x][y][z].region == j.name then found = true end
						if found then k = #self.nodes + 1 end
					end
					
					if not found then
						local x = 0
						local y = 0
						local z = 0

						local sFound = false
						while not sFound do
							local pd = parent:randomChoice(self.nodes)
							x = pd[1]
							y = pd[2]
							z = pd[3]
							if parent.thisWorld.planet[x][y][z].region == "" then sFound = true end
						end

						parent.thisWorld.planet[x][y][z].region = j.name
					end
				end

				local allDefined = false

				while not allDefined do
					allDefined = true
					for i=1,#self.nodes do
						local x = self.nodes[i][1]
						local y = self.nodes[i][2]
						local z = self.nodes[i][3]

						if parent.thisWorld.planet[x][y][z].region ~= "" then
							for j=1,#parent.thisWorld.planet[x][y][z].neighbors do
								local neighbor = parent.thisWorld.planet[x][y][z].neighbors[j]
								local nx = neighbor[1]
								local ny = neighbor[2]
								local nz = neighbor[3]
								if parent.thisWorld.planet[nx][ny][nz].region == "" then
									allDefined = false
									if not parent.thisWorld.planet[x][y][z].regionset then
										parent.thisWorld.planet[nx][ny][nz].region = parent.thisWorld.planet[x][y][z].region
										parent.thisWorld.planet[nx][ny][nz].regionset = true
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
				
				for i=#self.nodes,1,-1 do
					local x = self.nodes[i][1]
					local y = self.nodes[i][2]
					local z = self.nodes[i][3]
					
					if parent.thisWorld.planet[x][y][z].region == "" or not self.regions[parent.thisWorld.planet[x][y][z].region] then
						parent.thisWorld.planet[x][y][z].country = ""
						parent.thisWorld.planet[x][y][z].city = ""
						parent.thisWorld.planet[x][y][z].land = false
						table.remove(self.nodes, i)
					else table.insert(self.regions[parent.thisWorld.planet[x][y][z].region].nodes, {x, y, z}) end
				end

				for i, j in pairs(self.regions) do
					local cCount = 0
					for k, l in pairs(j.cities) do cCount = cCount + 1 end

					local maxC = math.ceil(#j.nodes / 25)

					while cCount > maxC do
						local c = parent:randomChoice(j.cities, true)
						local r = j.cities[c]
						local x = r.x
						local y = r.y
						local z = r.z
						if r.x and r.y and r.z then parent.thisWorld.planet[x][y][z].city = "" end
						j.cities[c] = nil
						cCount = 0
						for k, l in pairs(j.cities) do cCount = cCount + 1 end
					end
				end

				for i, j in pairs(self.regions) do
					for k, l in pairs(j.cities) do
						for m=1,#self.nodes do
							local x = self.nodes[m][1]
							local y = self.nodes[m][2]
							local z = self.nodes[m][3]
							
							if parent.thisWorld.planet[x][y][z].city == l.name then
								l.x = x
								l.y = y
								l.z = z
								m = #self.nodes + 1
							end
						end
					
						if not l.x or not l.y or not l.z then
							local pd = parent:randomChoice(j.nodes)
							local x = pd[1]
							local y = pd[2]
							local z = pd[3]

							while parent.thisWorld.planet[x][y][z].city ~= "" do
								pd = parent:randomChoice(j.nodes)
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

			triggerEvent = function(self, parent, i)
				if parent.c_events[i].args == 1 then
					table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
					local newE = self.ongoing[#self.ongoing]

					if newE.performEvent then
						if newE:performEvent(parent, self) == -1 then table.remove(self.ongoing, #self.ongoing)
						else newE:beginEvent(parent, self) end
					else table.remove(self.ongoing, #self.ongoing) end
				elseif parent.c_events[i].args == 2 then
					if parent.numCountries > 1 then
						local other = parent:randomChoice(parent.thisWorld.countries)
						while other.name == self.name do other = parent:randomChoice(parent.thisWorld.countries) end

						table.insert(self.ongoing, parent:deepcopy(parent.c_events[i]))
						local newE = self.ongoing[#self.ongoing]

						if newE.performEvent then
							if newE:performEvent(parent, self, other) == -1 then table.remove(self.ongoing, #self.ongoing)
							else newE:beginEvent(parent, self, other) end
						else table.remove(self.ongoing, #self.ongoing) end
					end
				end
			end,

			update = function(self, parent)
				parent:rseed()

				for i=1,#parent.systems do if not self.snt[parent.systems[i].name] or self.snt[parent.systems[i].name] == -1 then self.snt[parent.systems[i].name] = 0 end end

				self.stability = self.stability + math.random(-100, 100)
				if self.stability > 100 then self.stability = 100 end
				if self.stability < 1 then self.stability = 1 end

				self.averageAge = 0

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

					if not found then
						local ra = table.remove(self.alliances, i)
						ra = nil
					end
				end

				for i, j in pairs(self.relations) do
					local found = false
					for k, cp in pairs(parent.thisWorld.countries) do if cp.name == self.name then found = true end end
					if not found then self.relations[i] = nil end
				end

				for i, cp in pairs(parent.thisWorld.countries) do
					if cp.name ~= self.name then
						if not self.relations[cp.name] then self.relations[cp.name] = 50 end
						local v = math.random(-4, 4)
						self.relations[cp.name] = self.relations[cp.name] + v
						if self.relations[cp.name] < 1 then self.relations[cp.name] = 1 end
						if self.relations[cp.name] > 100 then self.relations[cp.name] = 100 end
					end
				end

				self.population = #self.people
				self.strength = 0
				self.military = 0

				if self.population < parent.popLimit then self.birthrate = 3
				else self.birthrate = 75 end

				while math.floor(#self.people) > math.floor(parent.popLimit * 3) do self:delete(parent, parent:randomChoice(self.people, true)) end

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

				for i, j in pairs(self.ethnicities) do self.ethnicities[i] = 0 end

				self.hasruler = -1

				for i=#self.people,1,-1 do
					local chn = false
					self.people[i]:update(parent, self)

					local age = self.people[i].age
					if age > 100 then
						self:delete(parent, i)
						chn = true
					else
						d = math.random(1, 3000-(age*3))
						if d < age then
							self:delete(parent, i)
							chn = true
						end
					end

					if not chn then if not self.people[i].isruler then
						local mChance = math.random(1, 20000)
						if mChance == 3799 then
							local cp = parent:randomChoice(parent.thisWorld.countries)
							if parent.numCountries > 1 then while cp.name == self.name do cp = parent:randomChoice(parent.thisWorld.countries) end end
							cp:add(parent, self.people[i])
							chn = true
						end
					end end

					if not chn then
						self.averageAge = self.averageAge + self.people[i].age
						if self.people[i].military then self.military = self.military + 1 end
						if self.people[i].isruler then
							self.hasruler = 0
							self.rulerage = self.people[i].age
							self.rulerParty = self.people[i].party
						end
					end
				end
				
				self:checkRuler(parent)

				self.averageAge = self.averageAge / #self.people

				if #self.parties > 0 then
					for i=#self.parties,1,-1 do self.parties[i].popularity = math.floor(self.parties[i].popularity) end

					local largest = -1

					for i=1,#self.parties do
						if largest == -1 then largest = i end
						if self.parties[i].membership > self.parties[largest].membership then largest = i end
					end

					if largest ~= -1 then self.parties[largest].leading = true end
				end

				for i, j in pairs(self.ethnicities) do self.ethnicities[i] = (self.ethnicities[i] / #self.people) * 100 end

				local largest = ""
				local largestN = 0
				for i, j in pairs(self.ethnicities) do if j >= largestN then largest = i end end
				self.majority = largest
				
				self.age = parent.years - self.founded
			end
		}

		Country.__index = Country
		Country.__call = function() return Country:new() end

		return Country
	end