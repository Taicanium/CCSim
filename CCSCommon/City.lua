return
	function()
		local City = {
			new = function(self)
				local c = {}
				setmetatable(c, self)

				c.mtname = "City"
				c.name = ""
				c.population = 0
				c.x = nil
				c.y = nil
				c.z = nil

				return c
			end,

			makename = function(self, country, parent)
				self.name = parent:name(true)
			end
		}

		City.__call = function() return City:new() end
		City.__index = City

		return City
	end