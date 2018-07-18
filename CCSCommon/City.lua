return
	function()
		local City = {
			new = function(self)
				local c = {}
				setmetatable(c, {__index=self, __call=function() return City:new() end})
				
				c.name = ""
				c.capital = false
				c.population = 0
				
				return c
			end,
			
			makename = function(self, country, parent)
				self.name = parent:name(7)
				local dup = true
				while dup == true do
					dup = false
					for i=1,#country.regions do
						for j=1,#country.regions[i].cities do
							if self.name == country.regions[i].cities[j].name then
								self.name = parent:name()
								dup = true
							end
						end
					end
				end
			end
		}
		
		return City
	end