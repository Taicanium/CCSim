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
		City.__tostring = function(self)
			local sOut, brk = "<City", 0
			for i, j in pairs(self) do brk = brk+1 if brk < 4 then sOut = sOut.."\n\t"..tostring(i)..": "..tostring(j) else return sOut.."\n\t...>" end end
		end

		return City
	end
