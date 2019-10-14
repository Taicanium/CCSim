return
	function()
		local City = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.name = ""
				o.population = 0
				o.x = nil
				o.y = nil
				o.z = nil

				return o
			end,

			makename = function(self, country, parent)
				self.name = parent:name(true)
			end
		}

		City.__index = City
		City.__call = function() return City:new() end

		return City
	end