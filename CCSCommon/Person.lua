return
	function()
		local Person = {
			new = function(self)
				local n = {}
				setmetatable(n, {__index=self, __call=function() return Person:new() end})
				
				n.name = ""
				n.surname = ""
				n.birth = ""
				n.age = 0
				n.gender = ""
				n.level = 2
				n.prevName = ""
				n.prevTitle = "Citizen"
				n.title = "Citizen"
				n.party = ""
				n.region = ""
				n.city = ""
				n.father = nil
				n.mother = nil
				n.spouse = nil
				n.isruler = false
				n.parentRuler = false
				
				return n
			end,

			destroy = function(self)
				self.name = nil
				self.surname = nil
				self.birth = nil
				self.age = nil
				self.gender = nil
				self.level = nil
				self.prevName = nil
				self.prevTitle = nil
				self.title = nil
				self.party = nil
				self.region = nil
				self.city = nil
				self.father = nil
				self.mother = nil
				self.spouse = nil
				self.isruler = nil
				self.parentRuler = nil
				self = nil
			end,

			makename = function(self, parent, nl)
				self.name = parent:name(true, 6)
				self.surname = parent:name(true, 6)
				
				local r = math.random(1, 1000)
				if r < 501 then self.gender = "Male" else self.gender = "Female" end
				
				self.birth = parent.years
				self.age = math.random(1, 30)
				if self.title == "" then
					self.level = 2
					self.title = "Citizen"
				end
				
				if self.region == "" then
					local rc = math.random(1, #nl.regions)
					self.region = nl.regions[rc].name
				end
				
				if self.city == "" then
					local nc = 0
					for i=1,#nl.regions do
						if nl.regions[i].name == self.region then
							nc = i
						end
					end
					local cc = math.random(1, #nl.regions[nc].cities)
					self.city = nl.regions[nc].cities[cc].name
				end
			end,
			
			dobirth = function(self, parent, nl)
				local nn = Person:new()
				nn:makename(parent, nl)
				
				local sys = parent.systems[nl.system]
				
				if self.gender == "Male" then
					nn.father = self
					nn.mother = self.spouse
					nn.surname = self.surname
				else
					nn.father = self.spouse
					nn.mother = self
					nn.surname = self.spouse.surname
				end
				
				nn.age = 0
				
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
				nl:add(nn)
				
				nn.region = self.region
				nn.city = self.city
			end,

			update = function(self, parent, nl)
				self.age = self.age + 1
				
				if self.surname == nil then self.surname = parent:name(true, 6) end
				
				local sys = parent.systems[nl.system]
				
				if self.gender == "Male" or sys.dynastic == false then
					local rankLim = 2
					if sys.dynastic == false then rankLim = 1 end
					if self.title ~= nil and self.level ~= nil then
						if self.title ~= sys.ranks[#sys.ranks] and self.level < #sys.ranks - rankLim then
							local x = math.random(-125, 100)
							if x < -75 then
								self.prevTitle = self.title
								self.level = self.level - 1
							elseif x > 75 then
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
					local rankLim = 2
					if sys.dynastic == false then rankLim = 1 end
					if self.title ~= nil and self.level ~= nil then
						if self.title ~= sys.franks[#sys.franks] and self.level < #sys.franks - rankLim then
							local x = math.random(-125, 100)
							if x < -75 then
								self.prevTitle = self.title
								self.level = self.level - 1
							elseif x > 75 then
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
				
				local cChange = math.random(1, 150)
				if cChange < 5 then
					self.city = ""
					self.region = ""
				end
				
				if self.region == "" or self.region == nil then
					local rc = math.random(1, #nl.regions)
					self.region = nl.regions[rc].name
					self.city = ""
				end
				
				if self.city == "" or self.city == nil then
					local nc = 0
					for i=1,#nl.regions do
						if nl.regions[i].name == self.region then
							nc = i
						end
					end
					local cc = math.random(1, #nl.regions[nc].cities)
					self.city = nl.regions[nc].cities[cc].name
				end
				
				if self.spouse == nil then
					if self.age > 15 then
						local c = math.random(1, 6)
						if c == 2 then
							local m = math.random(1, #nl.people)
							if nl.people[m].spouse == nil then
								if nl.people[m].city == self.city then
									if self.gender ~= nl.people[m].gender then
										self.spouse = nl.people[m]
										nl.people[m].spouse = self
										
										if self.level >= nl.people[m].level then
											nl.people[m].surname = self.surname
										else
											self.surname = nl.people[m].surname
										end
									end
								end
							end
						end
					end
				end
				
				if self.spouse ~= nil then
					if self.age < 65 and self.age > 14 then
						local tmp = math.random(1, nl.birthrate)
						if tmp < 3 then
							self:dobirth(parent, nl)
						end
					end
				end
				
				if #nl.parties > 0 then
					if self.party == "" then
						local pr = math.random(1, #nl.parties)
						self.party = nl.parties[pr].name
						nl.parties[pr].membership = nl.parties[pr].membership + 1
						if self.isruler == true then
							nl.rulers[#nl.rulers].Party = self.party
						end
					else
						local pcr = 1
						local pin = -1
						for i=1,#nl.parties do
							if nl.parties[i].name == self.party then
								pcr = nl.parties[i].popularity
								pin = i
							end
						end
						if pcr > 0 then
							if pcr < 50 then
								local pc = math.random(1, pcr)
								if pc == 15 then
									local pr = math.random(1, #nl.parties)
									if #nl.parties > 1 then while nl.parties[pr].name == self.party do pr = math.random(1, #nl.parties) end end
									self.party = nl.parties[pr].name
									nl.parties[pr].membership = nl.parties[pr].membership + 1
									if pin ~= -1 then nl.parties[pin].membership = nl.parties[pin].membership - 1 end
									if self.isruler == true then
										nl.rulers[#nl.rulers].Party = self.party
									end
								end
							end
						end
					end
				end
			end
		}
		
		return Person
	end