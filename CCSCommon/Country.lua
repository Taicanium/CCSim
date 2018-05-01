Country = {}
Country.__index = Country
Country.__call = function() return Country:new() end

function Country:new()
	local nl = {}
	setmetatable(nl, Country)
	
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
	nl.birthrate = 100
	nl.deathrate = 50000
	
	return nl
end

function Country:destroy()
	for i=1,#self.people do
		self.people[i]:destroy()
		self.people[i] = nil
	end
end

function Country:add(n)
	table.insert(self.people, n)
end

function Country:delete(y)
	local b = #self.people
	if b > 0 then
		if self.people[y] ~= nil then
			if self.people[y].spouse ~= nil then
				self.people[y].spouse.spouse = nil
			end
			self.people[y].spouse = nil
			if self.people[y].isruler == true then self.hasruler = -1 end
			local w = table.remove(self.people, y)
			if w ~= nil then
				w:destroy()
				w = nil
			end
		end
	end
end

function Country:makename()
	if self.name == "" or self.name == nil then
		self.name = name()
	end
	
	if #self.rulernames < 1 then
		for k=1,math.random(5,8) do
			table.insert(self.rulernames, name())
		end
		
		for k=1,math.random(5,8) do
			table.insert(self.frulernames, name())
		end
	end
	
	if #self.frulernames < 1 then
		for k=1,math.random(5,8) do
			table.insert(self.frulernames, name())
		end
	end
end

function Country:set()
	rseed()

	self:makename()
	
	for i=1,math.random(100,1000) do
		local n = Person:new()
		n:makename()
		self:add(n)
	end
	
	self.system = math.random(1, #systems)
	
	self.founded = years
	self.population = #self.people
end

function Country:setRuler(newRuler)
	if self.hasruler == -1 then
		self.people[newRuler].prevName = self.people[newRuler].name
		self.people[newRuler].prevTitle = self.people[newRuler].title
	
		self.people[newRuler].level = #systems[self.system].ranks
		self.people[newRuler].title = systems[self.system].ranks[self.people[newRuler].level]
		
		rseed()

		if self.people[newRuler].gender == "Female" then
			self.people[newRuler].name = self.frulernames[math.floor(math.random(1, #self.frulernames))]
			
			if systems[self.system].franks ~= nil then
				self.people[newRuler].level = #systems[self.system].franks
				self.people[newRuler].title = systems[self.system].franks[self.people[newRuler].level]
			end
		else
			self.people[newRuler].name = self.rulernames[math.floor(math.random(1, #self.rulernames))]
		end
		
		local namenum = 1
		
		for i=1,#self.rulers do
			if tonumber(self.rulers[i]["From"]) >= self.founded then
				if self.rulers[i]["Name"] == self.people[newRuler].name then
					if self.rulers[i]["Title"] == self.people[newRuler].title then
						namenum = namenum + 1
					end
				end
			end
		end
		
		self.people[newRuler].isruler = true
		self.hasruler = 0
		
		if systems[self.system].dynastic == true then
			table.insert(self.rulers, {["Name"]=self.people[newRuler].name, ["Title"]=self.people[newRuler].title, ["Number"]=tostring(namenum), ["From"]=years, ["To"]="Current", ["Country"]=self.name})
		else
			table.insert(self.rulers, {["Name"]=self.people[newRuler].name, ["Title"]=self.people[newRuler].title, ["Number"]=self.people[newRuler].surname, ["From"]=years, ["To"]="Current", ["Country"]=self.name})
		end
		
		self.rulerage = self.people[newRuler].age
	end
end

function Country:checkRuler()
	if self.hasruler == -1 then
		if #self.rulers > 0 then
			self.rulers[#self.rulers]["To"] = years
		end
		
		if #self.people > 1 then			
			while self.hasruler == -1 do
				local chil = false
				local male = false
				local chils = {}
				
				if systems[self.system].dynastic == true then
					for e=1,#self.people do
						if self.people[e].level == #systems[self.system].ranks - 1 then
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
					if systems[self.system].dynastic == true then
						g = math.random(1,math.floor(5000/(math.pow(self.people[z].level, 2))))
					else
						g = math.random(1,2500)
					end
					if g == 2 then
						self:setRuler(z)
					end
				else
					if male == false then
						self:setRuler(chils[1])
					else
						for q=1,#chils do
							if self.people[chils[q]].gender == "Male" and self.people[chils[q]].age < self.average + 25 then
								if self.hasruler == -1 then
									self:setRuler(chils[q])
								end
							end
						end
					end
				end
			end
		end
	end
end

function Country:setPop(u)
	while u < #self.people do
		if #self.people > 1 then
			local r = math.random(1, #self.people)
			while self.people[r].isruler == true do
				r = math.random(1, #self.people)
			end
			self:delete(r)
		else
			u = #self.people + 1000
		end
	end
	
	while u > #self.people do
		local nn = Person:new()
		nn:makename()
		nn.age = math.random(1, 121)
		nn.level = 2
		nn.title = "Citizen"
		self:add(nn)
	end
	
	self.population = #self.people
end

function Country:update()	
	self.stability = self.stability + math.random(-5, 5)
	if self.stability > 100 then self.stability = 100 end
	if self.stability < 1 then self.stability = 1 end
	
	self.strength = self.strength + math.random(-5, 5)
	if self.strength > 100 then self.strength = 100 end
	if self.strength < 1 then self.strength = 1 end
	
	self.age = self.age + 1
	self.population = #self.people
	
	if self.population < 150 then
		self.birthrate = 5
		self.deathrate = 500000
	elseif self.population > 2500 then
		self.birthrate = 10000
		self.deathrate = 150
	else
		self.birthrate = 35
		self.deathrate = 50000
	end
	
	self.hasruler = -1
	self.average = 1
	
	local pmarked = {}
	
	for i=1,#self.people do
		if self.people[i] ~= nil then
			if self.people[i].isruler == true then
				self.hasruler = 0
				self.rulerage = self.people[i].age
			end
			
			self.people[i]:update(self)
			
			local age = self.people[i].age
			if age >= 122 then
				if self.people[i].isruler == true then
					self.hasruler = -1
				end
				
				table.insert(pmarked, i)
			else
				local d = math.random(1, self.deathrate - self.people[i].age)
				if d == 3 then
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
	
	local omarked = {}
	local amarked = {}
	
	for i=1,#self.ongoing do
		local found = false
		local er = self.ongoing[i]:reverse()
		
		for j=1,#thisWorld.countries do
			local nr = thisWorld.countries[j].name:reverse()
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
	
	for i=1,#self.alliances do
		local found = false
		local ar = self.alliances[i]
		
		for j=1,#thisWorld.countries do
			local nr = thisWorld.countries[j].name
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
		for j, k in pairs(thisWorld.countries) do
			if k.name == i then found = true end
		end
	
		if found == false then
			self.relations[i] = nil
			i = nil
		end
	end
	
	for i, l in pairs(thisWorld.countries) do
		if l.name ~= self.name then
			if self.relations[l.name] == nil then
				self.relations[l.name] = 50
			end
			local v = math.random(-5, 5)
			self.relations[l.name] = self.relations[l.name] + v
			if self.relations[l.name] < 1 then self.relations[l.name] = 1 end
			if self.relations[l.name] > 100 then self.relations[l.name] = 100 end
		end
	end
	
	self:checkRuler()
	
	self:eventloop()
end

function Country:event(e)
	table.insert(self.events, {["Event"]=e, ["Year"]=years})
end

function Country:eventloop()
	local v = math.floor(10000 * self.stability)
	if v < 1 then v = 1 end
	
	if self.ongoing == nil then self.ongoing = {} end
	if self.relations == nil then self.relations = {} end
	
	for i=1,#self.ongoing do
		if self.ongoing[i] ~= nil then
			local ename = nil
			local eind = nil
			
			for j=1,#c_events do
				if #self.ongoing[i] >= #c_events[j].Name then
					if c_events[j].Name == self.ongoing[i]:sub(1, #c_events[j].Name) then
						ename = c_events[j].Name
						eind = j
					end
				end
			end
			
			if ename ~= nil then
				if c_events[eind]["Args"][1] == 1 then
					c_events[eind]:Step(self)
				elseif c_events[eind]["Args"][1] == 2 then
					local other = nil
					for k=1,#thisWorld.countries do
						if self.ongoing[i] == c_events[eind].Name..thisWorld.countries[k].name then
							other = k
							c_events[eind]:Step(self, thisWorld.countries[other])
						end
					end
				end
			end
		end
	end
	
	local delchance = 1
	if numCountries > maxcountries then delchance = 0 end
	if numCountries < mincountries then delchance = 2 end
	
	for i=1,#c_events do
		local chance = math.floor(math.random(1, v))
		if c_events[i].Name == "Independence" or c_events[i].Name == "Fracture" then
			if delchance == 0 then chance = math.floor(math.random(1, 100000000)) end
			if delchance == 2 then chance = math.floor(math.random(1, 500)) end
		elseif c_events[i].Name == "Conquer" then
			if delchance == 0 then chance = math.floor(math.random(1, 500)) end
			if delchance == 2 then chance = math.floor(math.random(1, 100000000)) end
		end
		
		if chance <= c_events[i]["Chance"] then
			if c_events[i]["Args"][1] == 1 then
				c_events[i]:Perform(self)
			elseif c_events[i]["Args"][1] == 2 then
				local other = math.random(1,#thisWorld.countries)
				while thisWorld.countries[other].name == self.name do other = math.random(1,#thisWorld.countries) end
				c_events[i]:Perform(self, thisWorld.countries[other])
			end
		end
	end
end
