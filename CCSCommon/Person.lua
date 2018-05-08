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
				n.level = 2
				n.prevName = ""
				n.prevTitle = "Citizen"
				n.title = "Citizen"
				n.gender = ""
				n.father = nil
				n.mother = nil
				n.spouse = nil
				
				return n
			end,

			destroy = function(self)
				self.name = nil
				self.surname = nil
				self.birth = nil
				self.age = nil
				self.level = nil
				self.title = nil
				self.gender = nil
			end,

			makename = function(self, parent)
				self.name = parent:name()
				self.surname = parent:name()
				
				local r = math.random(1, 100)
				if r < 51 then self.gender = "Male" else self.gender = "Female" end
				
				self.birth = parent.years
				self.age = math.random(5,60)
				if self.title == "" then
					self.level = 2
					self.title = "Citizen"
				end
			end,

			update = function(self, parent, nl)
				self.age = self.age + 1
				
				if self.surname == nil then self.surname = parent:name() end
				
				local sys = parent.systems[nl.system]
				
				if self.gender == "Male" or sys.dynastic == false then
					if self.title ~= sys.ranks[#sys.ranks] and self.level < #sys.ranks - 1 then
						local x = math.random(-125, 100)
						if x < -75 then
							self.prevTitle = self.title
							self.level = self.level - 1
						elseif x > 75 then
							self.prevTitle = self.title
							self.level = self.level + 1
						end
						
						if self.level < 1 then self.level = 1 end
						if self.level > #sys.ranks - 2 then self.level = #sys.ranks - 2 end
					end
					
					self.title = sys.ranks[self.level]
				else
					if self.title ~= sys.franks[#sys.franks] and self.level < #sys.franks - 1 then
						local x = math.random(-125, 100)
						if x < -75 then
							self.prevTitle = self.title
							self.level = self.level - 1
						elseif x > 75 then
							self.prevTitle = self.title
							self.level = self.level + 1
						end
						
						if self.level < 1 then self.level = 1 end
						if self.level > #sys.franks - 2 then self.level = #sys.franks - 2 end
					end
					
					self.title = sys.franks[self.level]
				end
				
				if self.spouse == nil then
					local m = math.random(1, #nl.people)
					if nl.people[m].spouse == nil then
						if self.gender ~= nl.people[m].gender then
							self.spouse = nl.people[m]
							nl.people[m].spouse = self
							
							if self.level >= nl.people[m].level then
								nl.people[m].surname = self.surname
								nl.people[m].level = self.level
							else
								self.surname = nl.people[m].surname
								self.level = nl.people[m].level
							end
						end
					end
				end
				
				if self.spouse ~= nil then
					if self.age < 65 and self.age > 14 then
						local tmp = math.random(1, nl.birthrate)
						if tmp < 4 then
							local nn = Person:new()
							nn:makename(parent)
							
							if self.gender == "Male" then
								nn.father = self
								nn.surname = self.surname
							else
								nn.mother = self
								nn.surname = self.spouse.surname
							end
							
							nn.age = 0
							
							if self.title == sys.ranks[#sys.ranks] then
								nn.level = #sys.ranks - 1
							else
								nn.level = self.level
							end
							
							if sys.dynastic == true then
								if self.gender == "Female" then
									if self.title == sys.franks[#sys.franks] then
										nn.level = #sys.ranks - 1
									end
								end
							end
							
							if nn.gender == "Male" or sys.dynastic == false then nn.title = sys.ranks[nn.level] else nn.title = sys.franks[nn.level] end
							nl:add(nn)
						end
					end
				end
			end
		}
		
		return Person
	end