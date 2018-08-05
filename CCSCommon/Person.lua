return
	function()
		local Person = {
			new = function(self)
				local n = {}
				setmetatable(n, self)
				
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
				n.spouse = nil
				n.isruler = false
				n.parentRuler = false
				n.pbelief = 0
				n.ebelief = 0
				n.cbelief = 0
				
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
				self.spouse = nil
				self.isruler = nil
				self.parentRuler = nil
				self.pbelief = nil
				self.ebelief = nil
				self.cbelief = nil
				self = nil
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
				
				if self.region == "" then
					local rc = math.random(1, #nl.regions)
					if nl.regions[rc] ~= nil then
						self.region = nl.regions[rc].name
					end
				end
				
				if self.city == "" then
					local nc = 0
					for i=1,#nl.regions do
						if nl.regions[i].name == self.region then
							nc = i
						end
					end
					if nl.regions[nc] ~= nil then
						if nl.regions[nc].cities[cc] ~= nil then
							local cc = math.random(1, #nl.regions[nc].cities)
							self.city = nl.regions[nc].cities[cc].name
						end
					end
				end
			end,
			
			dobirth = function(self, parent, nl)
				local nn = Person:new()
			
				if self.gender == "Male" then
					nn.surname = self.surname
				else
					nn.surname = self.spouse.surname
				end
			
				nn:makename(parent, nl)
				
				local sys = parent.systems[nl.system]
				
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
							local x = math.random(-100, 100)
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
							local x = math.random(-100, 100)
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
				if cChange == 5 then
					self.city = ""
					self.region = ""
				end
				
				if self.region == "" or self.region == nil then
					local rc = math.random(1, #nl.regions)
					if nl.regions[rc] ~= nil then
						self.region = nl.regions[rc].name
						self.city = ""
					end
				end
				
				if self.city == "" or self.city == nil then
					local nc = 0
					for i=1,#nl.regions do
						if nl.regions[i].name == self.region then
							nc = i
						end
					end
					if nc ~= 0 then
						if #nl.regions[nc].cities > 0 then
							local cc = math.random(1, #nl.regions[nc].cities)
							if nl.regions[nc] ~= nil then
								if nl.regions[nc].cities[cc] ~= nil then
									local cc = math.random(1, #nl.regions[nc].cities)
									self.city = nl.regions[nc].cities[cc].name
									
									if self.spouse ~= nil then
										self.spouse.city = self.city
										self.spouse.region = self.region
									end
								end
							end
						end
					end
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
					local tmp = math.random(1, nl.birthrate)
					if tmp == 1 then
						self:dobirth(parent, nl)
					end
				end
				
				local belieftotal = self.pbelief + self.ebelief + self.cbelief
				
				if #nl.parties > 0 then
					local pmatch = false
					
					for i=1,#nl.parties do
						local ptotal = nl.parties[i].cfreedom + nl.parties[i].pfreedom + nl.parties[i].efreedom
						if math.abs(belieftotal - ptotal) < 125 then pmatch = true end
					end
					
					if pmatch == false then
						local newp = Party:new()
						local ni = 0
						for i=1,#parent.thisWorld.countries do if parent.thisWorld.countries[i].name == nl.name then ni = i end end
						newp:makename(parent, ni)
						newp.cfreedom = self.cbelief
						newp.efreedom = self.ebelief
						newp.pfreedom = self.pbelief
						
						if math.abs(belieftotal) > 225 then newp.radical = true end
						
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
							local cc = math.random(1, 100 * nl.parties[pi].popularity)
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
					local ni = 0
					for i=1,#parent.thisWorld.countries do if parent.thisWorld.countries[i].name == nl.name then ni = i end end
					newp:makename(parent, ni)
					newp.cfreedom = self.cbelief
					newp.efreedom = self.ebelief
					newp.pfreedom = self.pbelief
					
					if math.abs(belieftotal) > 225 then newp.radical = true end
					
					self.party = newp.name
					newp.membership = 1
					
					table.insert(nl.parties, newp)
				end
				
				if self.isruler == true then
					if self.age > 80 then
						local retirechance = math.random(1, 10)
						if retirechance == 1 then
							nl.hasruler = -1
							self.isruler = false
							self.level = #parent.systems[nl.system].ranks - 2
						end
					end
				end
			end
		}
		
		Person.__index = Person
		Person.__call=function() return Person:new() end
		
		return Person
	end