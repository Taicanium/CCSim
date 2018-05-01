Person = {}
Person.__index = Person
Person.__call = function() return Person:new() end

function Person:new()
	local n = {}
	setmetatable(n, Person)
	
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
end

function Person:destroy()
	self.name = nil
	self.surname = nil
	self.birth = nil
	self.age = nil
	self.level = nil
	self.title = nil
	self.gender = nil
end

function Person:makename()
	self.name = name()
	self.surname = name()
	
	local r = math.random(1, 100)
	if r < 51 then self.gender = "Male" else self.gender = "Female" end
	
	self.birth = years
	self.age = math.random(5,60)
	if self.title == "" then
		self.level = 2
		self.title = "Citizen"
	end
end

function Person:update(nl)
	self.age = self.age + 1
	
	if self.surname == nil then self.surname = name() end
	
	if self.gender == "Male" or systems[nl.system].dynastic == false then
		if self.title ~= systems[nl.system].ranks[#systems[nl.system].ranks] and self.level < #systems[nl.system].ranks - 1 then
			local x = math.random(-125, 100)
			if x < -75 then
				self.prevTitle = self.title
				self.level = self.level - 1
			elseif x > 75 then
				self.prevTitle = self.title
				self.level = self.level + 1
			end
			
			if self.level < 1 then self.level = 1 end
			if self.level > #systems[nl.system].ranks - 2 then self.level = #systems[nl.system].ranks - 2 end
		end
		
		self.title = systems[nl.system].ranks[self.level]
	else
		if self.title ~= systems[nl.system].franks[#systems[nl.system].franks] and self.level < #systems[nl.system].franks - 1 then
			local x = math.random(-125, 100)
			if x < -75 then
				self.prevTitle = self.title
				self.level = self.level - 1
			elseif x > 75 then
				self.prevTitle = self.title
				self.level = self.level + 1
			end
			
			if self.level < 1 then self.level = 1 end
			if self.level > #systems[nl.system].franks - 2 then self.level = #systems[nl.system].franks - 2 end
		end
		
		self.title = systems[nl.system].franks[self.level]
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
				nn:makename()
				
				if self.gender == "Male" then
					nn.father = self
					nn.surname = self.surname
				else
					nn.mother = self
					nn.surname = self.spouse.surname
				end
				
				nn.age = 0
				
				if systems[nl.system].dynastic == true then
						if self.gender == "Male" then
							if self.title == systems[nl.system].ranks[#systems[nl.system].ranks] then
							nn.level = #systems[nl.system].ranks - 1
						else
							nn.level = self.level
						end
					else
						if self.title == systems[nl.system].franks[#systems[nl.system].franks] then
							nn.level = #systems[nl.system].ranks - 1
						else
							nn.level = self.level
						end
					end
				else
					if self.title == systems[nl.system].ranks[#systems[nl.system].ranks] then
						nn.level = #systems[nl.system].ranks - 1
					else
						nn.level = self.level
					end
				end
				
				if nn.gender == "Male" or systems[nl.system].dynastic == false then nn.title = systems[nl.system].ranks[nn.level] else nn.title = systems[nl.system].franks[nn.level] end
				nl:add(nn)
			end
		end
	end
end
