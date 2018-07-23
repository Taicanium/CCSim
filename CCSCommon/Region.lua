return
	function()
		local Region = {
			new = function(self)
				local r = {}
				setmetatable(r, {__index=self, __call=function() return Region:new() end})
				
				r.name = ""
				r.cities = {}
				r.population = 0
				
				return r
			end,
			
			makename = function(self, country, parent)
				self.name = parent:name(false, 7)
				local dup = true
				while dup == true do
					dup = false
					for i=1,#country.regions do
						if self.name == country.regions[i].name then
							self.name = parent:name(false, 7)
							dup = true
						end
					end
				end
				
				local cCount = math.random(2, 4)
				
				for i=1,cCount do
					local c = City:new()
					c:makename(country, parent)
					
					table.insert(self.cities, c)
				end
			end,
		}
		
		return Region
	end