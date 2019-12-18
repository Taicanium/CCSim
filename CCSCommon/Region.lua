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

			borders = function(self, parent, other)
				if not other or not other.nodes or type(other.nodes) ~= "table" then return 0 end
				local selfWater = false
				local otherWater = false

				for i=1,#self.nodes do
					local x, y, z = table.unpack(self.nodes[i])
					if parent.thisWorld.planet[x][y][z].region == self.name then
						if parent.thisWorld.planet[x][y][z].waterNeighbors then selfWater = true end
						for j=1,#parent.thisWorld.planet[x][y][z].neighbors do
							local nx, ny, nz = table.unpack(parent.thisWorld.planet[x][y][z].neighbors[j])
							if parent.thisWorld.planet[nx][ny][nz].country == other.name or parent.thisWorld.planet[nx][ny][nz].region == other.name then return 1 end
						end
					end
				end

				for i=1,#other.nodes do
					local x, y, z = table.unpack(other.nodes[i])
					if parent.thisWorld.planet[x][y][z].country == other.name or parent.thisWorld.planet[x][y][z].region == other.name then
						if parent.thisWorld.planet[x][y][z].waterNeighbors then otherWater = true end
						for j=1,#parent.thisWorld.planet[x][y][z].neighbors do
							local nx, ny, nz = table.unpack(parent.thisWorld.planet[x][y][z].neighbors[j])
							if parent.thisWorld.planet[nx][ny][nz].region == self.name then return 1 end
						end
					end
				end

				if selfWater and otherWater then return 1 end
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
