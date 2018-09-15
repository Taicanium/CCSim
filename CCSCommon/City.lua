return
	function()
		local City = {
			new = function(self)
				local c = {}
				setmetatable(c, self)

				c.name = ""
				c.population = 0
				c.x = nil
				c.y = nil
				c.z = nil
				c.mtName = "Party"

				return c
			end,

			makename = function(self, country, parent)
				self.name = parent:name(true, 6)
			end
		}

		City.__index = City
		City.__call = function() return City:new() end

		return City
	end