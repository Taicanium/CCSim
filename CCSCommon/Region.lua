return
	function()
		local Region = {
			new = function(self)
				local r = {}
				setmetatable(r, self)
				
				r.name = ""
				r.cities = {}
				r.population = 0
				r.nodes = {}
				
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
		
		Region.__index = Region
		Region.__call=function() return Region:new() end
		
		return Region
	end