return
	function()
		local City = {
			new = function(self)
				local c = {}
				setmetatable(c, self)
				
				c.name = ""
				c.capital = false
				c.population = 0
				c.x = 0
				c.y = 0
				c.z = 0
				
				return c
			end,
			
			makename = function(self, country, parent)
				self.name = parent:name(true, 7)
				local dup = true
				while dup == true do
					dup = false
					for i=1,#country.regions do
						for j=1,#country.regions[i].cities do
							if self.name == country.regions[i].cities[j].name then
								self.name = parent:name(false, 7)
								dup = true
							end
						end
					end
				end
			end
		}
		
		City.__index = City
		City.__call = function() return City:new() end
		
		return City
	end