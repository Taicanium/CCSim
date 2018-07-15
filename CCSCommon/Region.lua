return
	function()
		local Region = {
			new = function(self)
				local r = {}
				setmetatable(r, {__index=self, __call=function() return Region:new() end})
				
				r.name = ""
				r.cities = {}
				
				return r
			end,
			
			makename = function(self, country, parent)
				self.name = parent:name(7)
				local dup = true
				while dup == true do
					dup = false
					for i=1,#country.regions do
						if self.name == country.regions[i].name then
							self.name = parent:name()
							dup = true
						end
					end
				end
				
				for i=1,math.random(2, 4) do
					local c = City:new()
					c:makename(country, parent)
					
					table.insert(self.cities, c)
				end
			end,
			
			update = function(self, country)
				for i=1,#self.cities do
					self.cities[i]:update(country)
				end
			end
		}
		
		return Region
	end