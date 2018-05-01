World = {}
World.__index = World
World.__call = function() return World:new() end

function World:new()
	local nm = {}
	setmetatable(nm, World)
	
	nm.countries = {}
	nm.cmarked = {}
	
	numCountries = 0
	years = 0

	return nm
end

function World:destroy()
	for i=1,#self.countries do
		self.countries[i]:destroy()
		self.countries[i] = nil
	end
end

function World:add(nd)
	table.insert(self.countries, nd)
end

function World:delete(nz)
	if nz > 0 and nz <= #self.countries then
		if self.countries[nz] ~= nil then
			local p = table.remove(self.countries, nz)
			if p ~= nil then
				p:destroy()
				p = nil
			end
		end
	end
end

function World:update()
	numCountries = #self.countries
	
	self.cmarked = {}
	
	for i=1,#self.countries do
		if self.countries[i] ~= nil then
			self.countries[i]:update()
			
			if self.countries[i] ~= nil then
				if self.countries[i].population < 10 then
					self.countries[i].rulers[#self.countries[i].rulers]["To"] = years
					self.countries[i]:event("Disappeared")
					local found = false
					for j=1,#self.cmarked do
						if self.cmarked[j] == i then found = true end
					end
					if found == false then table.insert(self.cmarked, i) end
				end
			end
		end
	end
	
	for i=1,#self.cmarked do
		self:delete(self.cmarked[i])
		for j=i,#self.cmarked do
			self.cmarked[i] = self.cmarked[i] - 1
		end
	end
end
