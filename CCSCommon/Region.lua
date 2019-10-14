return
	function()
		local Region = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.cities = {}
				o.name = ""
				o.nodes = {}
				o.population = 0
				o.subregions = {}

				return o
			end,

			-- [[ 0: No border of any kind.
			--    1: This region borders the specified country over water.
			--    2: This region borders the specified region over water.
			--    3: This region borders the specified country directly.
			--    4: This region borders the specified region directly.
			borders = function(self, parent, other)
				if not other then return 0 end
				local border = 0
				for i=1,#parent.thisWorld.planetdefined do
					local x, y, z = table.unpack(parent.thisWorld.planetdefined[i])
					local node1 = parent.thisWorld.planet[x][y][z]
					if node1.region == self.name then
						for j=1,#node1.neighbors do
							local x2, y2, z2 = table.unpack(node1.neighbors[j])
							local node2 = parent.thisWorld.planet[x2][y2][z2]
							if node2.region == other.name then return 4 end
							if node2.country == other.name then return 3 end
							if node2.land == false and border < 2 then border = 2 end
						end
					end
				end
				if border == 2 then
					for i=1,#parent.thisWorld.planetdefined do
						local x, y, z = table.unpack(parent.thisWorld.planetdefined[i])
						local node1 = parent.thisWorld.planet[x][y][z]
						if node1.region == other.name or node1.country == other.name then
							for j=1,#node1.neighbors do
								local x2, y2, z2 = table.unpack(node1.neighbors[j])
								local node2 = parent.thisWorld.planet[x2][y2][z2]
								if node2.land == false then
									if node1.region == other.name then return 2 end
									if node1.country == other.name then return 1 end
								end
							end
						end
					end
				end

				return 0
			end,
			
			destroy = function(self, parent)
				parent:deepnil(self.nodes)
				self.population = 0
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
