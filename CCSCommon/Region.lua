return
	function()
		local Region = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.cities = {}
				o.language = nil
				o.name = ""
				o.nl = ""
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

			deviateDialects = function(self, country, parent)
				if not self.language or self.language.name ~= parent:demonym(self.name) then self.language = parent:getLanguage(self, country) else
					local newLang = self.language:deviate(parent, 0.06)
					newLang.name = parent:demonym(self.name)
					self.language = newLang
					table.insert(parent.languages, 1, self.language)
				end
				for i, j in pairs(self.subregions) do j:deviateDialects(country, parent) end
			end,

			makename = function(self, country, parent)
				local dup = true
				while dup do
					self.name = parent:name(false, 2, 2)
					dup = false
					for i, j in pairs(parent.final) do if self.name == j.name then dup = true end end
					for i, j in pairs(parent.thisWorld.countries) do if not dup then for k, l in pairs(j.regions) do if j.name == self.name then dup = true end end end end
				end

				local cCount = 0
				for i, j in pairs(self.cities) do cCount = cCount+1 end
				if cCount == 0 then
					cCount = math.random(3, 6)

					for i=1,cCount do
						local c = City:new()
						c:makename(country, parent)
						c.nl = self.name
						self.cities[c.name] = c
					end
				end

				self.nl = country.name
			end,
		}

		Region.__index = Region
		Region.__call=function() return Region:new() end

		return Region
	end
