return
	function()
		local Region = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.waterBorder = -1
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
				if not other or not other.nodes or type(other.nodes) ~= "table" or #other.nodes == 0 then return 0 end
				local otherWater = -1
				local otherLand = -1
				local identifier = "region"
				if other.events then identifier = "country" end
				
				if self.waterBorder == -1 then
					self.waterBorder = 0
					for i=1,#self.nodes do
						local x, y, z = table.unpack(self.nodes[i])
						if parent.thisWorld.planet[x][y][z].region == self.name then
							for j=1,#parent.thisWorld.planet[x][y][z].neighbors do
								local nx, ny, nz = table.unpack(self.nodes[i])
								if parent.thisWorld.planet[nx][ny][nz].land == false then self.waterBorder = 1
								elseif parent.thisWorld.planet[nx][ny][nz][identifier] == other.name then
									otherLand = 1
									i = #self.nodes
								end
							end
						end
					end
				end
				
				if otherLand == 1 then
					if identifier == "region" then return 4
					elseif identifier == "country" then return 3 end
				end
				
				otherWater = 0
				for i=1,#other.nodes do
					local x, y, z = table.unpack(other.nodes[i])
					if parent.thisWorld.planet[x][y][z][identifier] == other.name then
						for j=1,#parent.thisWorld.planet[x][y][z].neighbors do
							local nx, ny, nz = table.unpack(other.nodes[i])
							if parent.thisWorld.planet[nx][ny][nz].land == false then otherWater = 1
							elseif parent.thisWorld.planet[nx][ny][nz].region == self.name then
								otherLand = 1
								i = #other.nodes
							end
						end
					end
				end
				
				if otherLand == 1 then
					if identifier == "region" then return 4
					elseif identifier == "country" then return 3 end
				elseif otherWater == 1 and self.waterBorder == 1 then
					if identifier == "region" then return 2
					elseif identifier == "country" then return 1 end
				end

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
