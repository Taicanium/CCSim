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
				r.mtName = "Region"

				return r
			end,

			makename = function(self, country, parent)
				self.name = parent:name(false, 7)
				local dup = true
				while dup == true do
					dup = false
					for i, j in pairs(country.regions) do
						if self.name == j.name then
							self.name = parent:name(false, 7)
							dup = true
						end
					end
				end

				local cCount = math.random(3, 6)

				for i=1,cCount do
					c = City:new()
					c:makename(country, parent)

					self.cities[c.name] = c
				end
			end,
		}

		Region.__index = Region
		Region.__call=function() return Region:new() end

		return Region
	end