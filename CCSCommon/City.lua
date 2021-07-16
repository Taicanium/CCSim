return
	function()
		local City = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.name = ""
				o.nl = ""
				o.node = nil
				o.population = 0

				return o
			end,

			makename = function(self, country, parent)
				self.name = parent:name(true)
				self.nl = country.name
			end
		}

		City.__index = City
		City.__call = function() return City:new() end

		return City
	end
