return
	function()
		local Region = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.cities = {}
				o.language = nil
				o.name = ""
				o.nodes = {}
				o.population = 0
				o.subregions = {}

				return o
			end,

			borders = function(self, parent, other, oRegion)
				if not other or not other.nodes or type(other.nodes) ~= "table" then return 0 end
				local otherItem = "country"
				if oRegion then otherItem = "region" end
				local selfWater = {}
				local otherWater = {}

				for i=1,#self.nodes do
					local xyz = self.nodes[i]
					if parent.thisWorld.planet[xyz].region == self.name then
						for j=1,#parent.thisWorld.planet[xyz].neighbors do
							local nxyz = parent.thisWorld.planet[xyz].neighbors[j]
							if parent.thisWorld.planet[nxyz].land and parent.thisWorld.planet[nxyz][otherItem] == other.name then return 1
							elseif not parent.thisWorld.planet[nxyz].land and parent.thisWorld.planet[nxyz].waterBody and parent.thisWorld.planet[nxyz].waterBody ~= "" then selfWater[parent.thisWorld.planet[nxyz].waterBody] = true end
						end
					end
				end

				for i=1,#other.nodes do
					local xyz = other.nodes[i]
					if parent.thisWorld.planet[xyz][otherItem] == other.name then
						for j=1,#parent.thisWorld.planet[xyz].neighbors do
							local nxyz = parent.thisWorld.planet[xyz].neighbors[j]
							if parent.thisWorld.planet[nxyz].land and parent.thisWorld.planet[nxyz].region == self.name then return 1
							elseif not parent.thisWorld.planet[nxyz].land and parent.thisWorld.planet[nxyz].waterBody and parent.thisWorld.planet[nxyz].waterBody ~= "" then otherWater[parent.thisWorld.planet[nxyz].waterBody] = true end
						end
					end
				end

				for i, j in pairs(selfWater) do if selfWater[i] and otherWater[i] then return 1 end end

				return 0
			end,

			makename = function(self, country, parent)
				self.name = parent:name(false)
				local dup = true
				while dup do
					dup = false
					for i, j in pairs(country.regions) do
						if self.name == j.name then
							self.name = parent:name(false)
							dup = true
						end
					end
				end

				local cCount = 0
				for i, j in pairs(self.cities) do cCount = cCount+1 end
				if cCount == 0 then
					cCount = math.random(3, 6)

					for i=1,cCount do
						local c = City:new()
						c:makename(country, parent)

						self.cities[c.name] = c
					end
				end
			end,
		}

		Region.__index = Region
		Region.__call=function() return Region:new() end

		return Region
	end
