return
	function()
		local World = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.colors = {}
				o.countries = {}
				o.cTriplets = {}
				o.fromFile = false
				o.gPop = 0
				o.initialState = true
				o.landNodes = {}
				o.mapChanged = true
				o.numCountries = 0
				o.planet = {}
				o.planetdefined = {}
				o.planetC = 0
				o.planetD = 0
				o.planetR = 0
				o.stretched = {}
				o.unwrapped = {}
				o.waterBodies = {}

				return o
			end,

			add = function(self, nd)
				if not self.countries[nd.name] then self.numCountries = self.numCountries+1 end
				self.countries[nd.name] = nd
			end,

			constructVoxelPlanet = function(self, parent)
				parent:rseed()
				local t0 = _time()
				local rMin, rMax = _DEBUG and 100 or 185, _DEBUG and 105 or 225
				self.planetR = math.floor(math.random(rMin, rMax))
				local gridVol, rdone = (math.pow((self.planetR*2)+1, 2)*6)/100, 0

				UI:printf(string.format("Constructing voxel planet with radius of %d units...", self.planetR))

				for x=-self.planetR,self.planetR do
					for y=-self.planetR,self.planetR do
						local z = self.planetR
						self.planet[self:getNodeFromCoords(x, y, -z)] = self.planet[self:getNodeFromCoords(x, y, -z)] or { x=x, y=y, z=-z, height=0, continent="", country="", region="", city="", waterNeighbors=0, neighbors={}, waterBody = "", archipelago = "" }
						self.planet[self:getNodeFromCoords(x, y, z)] = self.planet[self:getNodeFromCoords(x, y, z)] or { x=x, y=y, z=z, height=0, continent="", country="", region="", city="", waterNeighbors=0, neighbors={}, waterBody = "", archipelago = "" }
						self.planet[self:getNodeFromCoords(x, -z, y)] = self.planet[self:getNodeFromCoords(x, -z, y)] or { x=x, y=-z, z=y, height=0, continent="", country="", region="", city="", waterNeighbors=0, neighbors={}, waterBody = "", archipelago = "" }
						self.planet[self:getNodeFromCoords(x, z, y)] = self.planet[self:getNodeFromCoords(x, z, y)] or { x=x, y=z, z=y, height=0, continent="", country="", region="", city="", waterNeighbors=0, neighbors={}, waterBody = "", archipelago = "" }
						self.planet[self:getNodeFromCoords(-z, x, y)] = self.planet[self:getNodeFromCoords(-z, x, y)] or { x=-z, y=x, z=y, height=0, continent="", country="", region="", city="", waterNeighbors=0, neighbors={}, waterBody = "", archipelago = "" }
						self.planet[self:getNodeFromCoords(z, x, y)] = self.planet[self:getNodeFromCoords(z, x, y)] or { x=z, y=x, z=y, height=0, continent="", country="", region="", city="", waterNeighbors=0, neighbors={}, waterBody = "", archipelago = "" }
						rdone = rdone+6
					end
					UI:printl(string.format("%.2f%% done", rdone/gridVol))
				end

				UI:printf("Unwrapping planet to data matrix...")
				self:unwrap()

				UI:printf("Distorting data matrix into flat projection...")
				self:mapOutput(parent, "NIL")

				UI:printf("Cross-referencing neighboring points on planet surface...")
				for i=1,#self.stretched do
					for j=1,#self.stretched[i] do
						local xyz = self.stretched[i][j][7]
						for k=-1,1 do for l=-1,1 do if k ~= 0 or l ~= 0 then if self.stretched[i-k] then
							local xi, yi, found = i-k, j-l
							if yi < 1 then yi = yi+#self.stretched[xi] end
							if yi > #self.stretched[xi] then yi = yi-#self.stretched[xi] end
							for m=1,#self.planet[xyz].neighbors do if not found and self.planet[xyz].neighbors[m] == self.stretched[xi][yi][7] then found = true end end
							if not found then
								table.insert(self.planet[xyz].neighbors, self.stretched[xi][yi][7])
								self.planet[xyz].waterNeighbors = self.planet[xyz].waterNeighbors+1
							end
						end end end end
					end
					if math.fmod(i, 10) == 0 then UI:printl(string.format("%.2f%% done", i*100/#self.stretched)) end
				end

				collectgarbage("collect")
				UI:printf("Defining land masses...")
				local planetSize = #self.planetdefined
				local maxLand, continents, scanNodes = math.random(math.floor(planetSize/3.25), math.ceil(planetSize/2.4)), math.random(5, 9), {}
				for i=1,continents do
					local located, cSeed = true, parent:randomChoice(self.planetdefined)
					while self.planet[cSeed].land do cSeed = parent:randomChoice(self.planetdefined) end

					self.planet[cSeed].land, self.planet[cSeed].continent = true, parent:name(true, 2, 2)
					for i=1,#self.planet[cSeed].neighbors do self.planet[self.planet[cSeed].neighbors[i]].waterNeighbors = self.planet[self.planet[cSeed].neighbors[i]].waterNeighbors-1 end
					table.insert(self.landNodes, cSeed)
					table.insert(scanNodes, cSeed)
				end

				while #self.landNodes < maxLand do
					local xyz = -math.huge
					while not scanNodes[xyz] or self.planet[scanNodes[xyz]].waterNeighbors == 0 do
						if scanNodes[xyz] then table.remove(scanNodes, xyz) end
						xyz = math.random(1, #scanNodes)
					end
					local nxyz, iters = self.planet[scanNodes[xyz]].neighbors[math.random(1, #self.planet[scanNodes[xyz]].neighbors)], 0
					while self.planet[nxyz].land do
						nxyz, iters = self.planet[scanNodes[xyz]].neighbors[math.random(1, #self.planet[scanNodes[xyz]].neighbors)], iters+1
						if iters > #self.planet[scanNodes[xyz]].neighbors*4 then
							self.planet[scanNodes[xyz]].waterNeighbors = 0
							table.remove(scanNodes, xyz)
							xyz = math.random(1, #scanNodes)
							nxyz = self.planet[scanNodes[xyz]].neighbors[math.random(1, #self.planet[scanNodes[xyz]].neighbors)]
							iters = 0
						end
					end
					self.planet[nxyz].land = true
					self.planet[nxyz].continent = self.planet[scanNodes[xyz]].continent
					self.planet[nxyz].waterNeighbors = 0
					for i=1,#self.planet[nxyz].neighbors do
						self.planet[self.planet[nxyz].neighbors[i]].waterNeighbors = self.planet[self.planet[nxyz].neighbors[i]].waterNeighbors-1
						if not self.planet[self.planet[nxyz].neighbors[i]].land then self.planet[nxyz].waterNeighbors = self.planet[nxyz].waterNeighbors+1 end
					end
					table.insert(self.landNodes, nxyz)
					if self.planet[nxyz].waterNeighbors > 0 then table.insert(scanNodes, math.random(1, #scanNodes+1), nxyz) end
					if math.fmod(#self.landNodes, 1000) == 0 then UI:printl(string.format("%.2f%% done", (#self.landNodes/maxLand)*100)) end
				end

				parent:deepnil(freeNodes)
				collectgarbage("collect")

				UI:printf("Rooting countries...")
				local ci = 1
				local defined = {}

				for i, cp in pairs(self.countries) do
					UI:printl(string.format("Country %d/%d", ci, self.numCountries))
					ci = ci+1

					local located = true
					local rnd = parent:randomChoice(self.planetdefined)
					while self.planet[rnd].country ~= "" or not self.planet[rnd].land do rnd = parent:randomChoice(self.planetdefined) end

					self.planet[rnd].country = cp.name
					table.insert(defined, rnd)
				end

				UI:printf("Setting territories...")
				local allDefined, totalDefined, prevDefined = false, #defined, #defined
				ci = 1

				while not allDefined do
					for i=#defined,1,-1 do
						local xyz, nDefined = defined[i], true
						if self.planet[xyz].land and self.planet[xyz].country ~= "" and not self.planet[xyz].countrySet and not self.planet[xyz].countryDone then
							for j=1,#self.planet[xyz].neighbors do
								local neighbor = self.planet[xyz].neighbors[j]
								if self.planet[neighbor].land and self.planet[neighbor].continent == self.planet[xyz].continent and self.planet[neighbor].country == "" then
									nDefined = false
									self.planet[neighbor].country = self.planet[xyz].country
									self.planet[neighbor].countrySet = true
									table.insert(defined, neighbor)
									totalDefined = totalDefined+1
								end
							end
							self.planet[xyz].countryDone = true
						end
						if nDefined then table.remove(defined, i) end
					end
					for i=1,#defined do self.planet[defined[i]].countrySet = false end
					if totalDefined == prevDefined then
						allDefined = true
						for i=1,planetSize do if allDefined then
							local xyz = self.planetdefined[i]
							if self.planet[xyz].land and self.planet[xyz].country == "" then
								allDefined = false
								local nl = Country:new()
								nl:set(parent)
								self:add(nl)
								self.planet[xyz].country = nl.name
								table.insert(defined, xyz)
								totalDefined = totalDefined+1
							end
						end end
					end

					prevDefined = totalDefined
					UI:printl(string.format("%.2f%% done", (totalDefined/#self.landNodes)*100))
				end

				parent:getAlphabetical()
				UI:printf("Defining regional boundaries...")

				for i, j in pairs(self.countries) do
					UI:printl(string.format("Country %d/%d", ci, self.numCountries))
					ci = ci+1
					j:setTerritory(parent)
				end

				UI:printf("Populating small islands...")
				local archipelagos = math.random(14, 22)
				for a=1,archipelagos do
					UI:printl(string.format("Group %d/%d", a, archipelagos))
					local archName = parent:demonym(parent:name(false, 2, 2))
					local archCenter = parent:randomChoice(self.planetdefined)
					while self.planet[archCenter].land do archCenter = parent:randomChoice(self.planetdefined) end
					local nearestLand = -1
					local nearestLandDist = math.huge
					for j=1,#self.landNodes do
						local nxyz = self.planet[self.landNodes[j]]
						if nxyz and nxyz.continent ~= "" then
							local mag = math.sqrt(math.pow(nxyz.x-self.planet[archCenter].x, 2)+math.pow(nxyz.y-self.planet[archCenter].y, 2)+math.pow(nxyz.z-self.planet[archCenter].z, 2))
							if mag < nearestLandDist then
								nearestLand = self.landNodes[j]
								nearestLandDist = mag
							end
						end
					end
					local islands = math.random(5, 9)
					local archSize = math.floor(planetSize/math.random(300/islands, 725/islands))
					local archRegion = Region:new()
					archRegion:makename(self.countries[self.planet[nearestLand].country], parent)
					archRegion.name = archName
					archRegion.language = self.countries[self.planet[nearestLand].country].language
					local archNodes = {archCenter}
					local archDefined = 1
					self.countries[self.planet[nearestLand].country].regions[archRegion.name] = archRegion
					self.planet[archCenter].archipelago = archRegion.name
					while archDefined < archSize do
						local nextNode = math.random(1, #archNodes)
						while not archNodes[nextNode] or not self.planet[archNodes[nextNode]] do nextNode = math.random(1, #archNodes) end
						local neighborNodes = false
						for i=1,#self.planet[archNodes[nextNode]].neighbors do
							local nxyz = self.planet[archNodes[nextNode]].neighbors[i]
							if self.planet[nxyz].archipelago ~= archRegion.name then
								neighborNodes = true
								if math.random(1, 3) == math.random(1, 2) then
									table.insert(archNodes, nxyz)
									self.planet[nxyz].archipelago = archRegion.name
									archDefined = archDefined+1
									neighborNodes = true
								end
							end
						end
						if not neighborNodes then table.remove(archNodes, nextNode) end
					end
					for i=1,islands do
						local nSeed = parent:randomChoice(archNodes)
						while self.planet[nSeed].land do nSeed = parent:randomChoice(archNodes) end

						local islandNodes = {}
						table.insert(islandNodes, nSeed)
						local islandSize = math.floor(archSize/math.random(40, 65))
						for j=1,islandSize-1 do if #islandNodes > 0 then
							local nextNode = math.random(1, #islandNodes)
							local iters = 0
							while self.planet[islandNodes[nextNode]].waterNeighbors == 0 do
								nextNode = math.random(1, #islandNodes)
								iters = iters+1
								if iters > #islandNodes*2 then break end
							end
							self.planet[islandNodes[nextNode]].land = true
							self.planet[islandNodes[nextNode]].waterBody = ""
							self.planet[islandNodes[nextNode]].continent = self.planet[nearestLand].continent
							self.planet[islandNodes[nextNode]].country = self.planet[nearestLand].country
							self.planet[islandNodes[nextNode]].region = archRegion.name
							table.insert(self.landNodes, islandNodes[nextNode])
							for k=1,#self.planet[islandNodes[nextNode]].neighbors do
								self.planet[self.planet[islandNodes[nextNode]].neighbors[k]].waterNeighbors = self.planet[self.planet[islandNodes[nextNode]].neighbors[k]].waterNeighbors-1
								if not self.planet[self.planet[islandNodes[nextNode]].neighbors[k]].land then table.insert(islandNodes, self.planet[islandNodes[nextNode]].neighbors[k]) end
							end
							if self.planet[islandNodes[nextNode]].waterNeighbors == 0 then table.remove(islandNodes, nextNode) end
						else j=islandSize-1 end end
					end
				end

				UI:printf("Mapping bodies of water...")
				local wNodes = 0
				local wFinished = 0
				for i=1,planetSize do if not self.planet[self.planetdefined[i]].land then wNodes = wNodes+1 end end

				for i=1,planetSize do if self.planet[self.planetdefined[i]].land or self.planet[self.planetdefined[i]].archipelago ~= "" then for j=1,#self.planet[self.planetdefined[i]].neighbors do
					local nxyz = self.planet[self.planetdefined[i]].neighbors[j]
					local dArchSea = self.planet[self.planetdefined[i]].archipelago == ""
					local nArchSea = self.planet[nxyz].archipelago == ""
					if not self.planet[nxyz].land and dArchSea == nArchSea and self.planet[nxyz].waterBody == "" then
						self.planet[nxyz].waterBody = parent:demonym(parent:name(false, 2, 2))
						while self.waterBodies[self.planet[nxyz].waterBody] do self.planet[nxyz].waterBody = parent:demonym(parent:name(false, 2, 2)) end
						self.waterBodies[self.planet[nxyz].waterBody] = 1
						local waterNodesToTest = {nxyz}
						local tested = {}
						while #waterNodesToTest > 0 do
							if math.fmod(wFinished, 1000) == 0 then UI:printl(string.format("%.2f%% done", (wFinished/wNodes)*100)) end
							if not self.planet[waterNodesToTest[1]].waterTested then
								for j=1,#self.planet[waterNodesToTest[1]].neighbors do
									local mxyz = self.planet[waterNodesToTest[1]].neighbors[j]
									local wArchSea = self.planet[waterNodesToTest[1]].archipelago == ""
									local mArchSea = self.planet[mxyz].archipelago == ""
									if not self.planet[mxyz].land and mArchSea == wArchSea and self.planet[mxyz].waterBody == "" and not self.planet[mxyz].waterTested then
										self.planet[mxyz].waterBody = self.planet[waterNodesToTest[1]].waterBody
										self.waterBodies[self.planet[mxyz].waterBody] = self.waterBodies[self.planet[mxyz].waterBody]+1
										wFinished = wFinished+1
										table.insert(waterNodesToTest, mxyz)
									end
								end
								self.planet[waterNodesToTest[1]].waterTested = true
							end
							table.insert(tested, table.remove(waterNodesToTest, 1))
						end
						for k=1,#tested do self.planet[tested[k]].waterTested = false end
					end
				end end end

				self.mapChanged = true

				for i, j in pairs(parent.c_events) do
					parent.disabled[j.name:lower()] = false
					parent.disabled["!"..j.name:lower()] = false
				end

				collectgarbage("collect")
			end,

			delete = function(self, parent, nz)
				if not nz then return end

				self.cTriplets["\x03"..nz.name] = nil
				self.countries[nz.name] = nil

				nz:destroy(parent)
				self.numCountries = self.numCountries-1
				parent.writeMap = true
				self.mapChanged = true
			end,

			destroy = function(self)
				for i, cp in pairs(self.countries) do
					cp:destroy(parent)
					cp = nil
				end
			end,

			getNodeFromCoords = function(self, x, y, z)
				local xm, ym, zm = self:normalize(x, y, z)
				return (xm*math.pow(self.planetR*2+1, 2))+(ym*(self.planetR*2+1))+zm
			end,

			mapOutput = function(self, parent, label)
				if label ~= "NIL" and not parent.doMaps then return end
				local t0 = _time()
				local planetSize = #self.planetdefined

				for i, cp in pairs(self.countries) do
					if not self.cTriplets["\x03"..cp.name] then
						self.cTriplets["\x03"..cp.name] = nil
						local r = 0
						local g = 0
						local b = 0
						local unique = false
						self.cTriplets["\xFFWATER"] = {22, 22, 170}
						while not unique do
							r = math.random(0, 255)
							g = math.random(0, 255)
							b = math.random(0, 255)
							unique = true
							for k, j in pairs(self.cTriplets) do if math.abs(r-j[1])+math.abs(g-j[2])+math.abs(b-j[3]) < 60 then unique = false end end
							if r > 230 and g > 230 and b > 230 then unique = false end
							if r < 25 and g < 25 and b < 25 then unique = false end
						end
						self.cTriplets["\xFFWATER"] = nil
						self.cTriplets["\x03"..cp.name] = {r, g, b}
					end
				end

				local zeroRGB = {0, 0, 0}
				local maxRGB = {255, 255, 255}
				local waterRGB = {22, 22, 170}
				local columnCount = #self.unwrapped
				self.colors = {["\x01\x01CONTINENTS"]={0, 0, 0}, ["\x02\x01BODIES OF WATER"]={0, 0, 0}, ["\x03\x01COUNTRIES"]={0, 0, 0}}
				local leaders = {["\x01\x01CONTINENTS"]="", ["\x02\x01BODIES OF WATER"]="", ["\x03\x01COUNTRIES"]=""}

				if self.mapChanged then
					self.planetC = 0
					self.stretched = {}
					for i=1,columnCount do
						self.stretched[i] = {}
						local col = self.unwrapped[i]
						if #col > self.planetC then self.planetC = #col end
					end
				end

				for i=1,columnCount do
					local column = self.unwrapped[i]
					local pixelsPerUnit = math.floor(self.planetC/#column)
					local deviation, deviated = math.fmod(self.planetC/#column, 1), 0
					for j=1,#column do
						local exyz = column[j]
						local node = self.planet[exyz]
						local countryStr = node.country
						local cTriplet = self.cTriplets["\x03"..countryStr]
						if not node.land or not cTriplet then cTriplet = waterRGB end
						if self.mapChanged then
							local nextNode = {cTriplet[1], cTriplet[2], cTriplet[3], node.region, node.waterBody, node.continent, exyz}
							for k=1,pixelsPerUnit do
								table.insert(self.stretched[i], nextNode)
								deviated = deviated+deviation
								while deviated >= 1 do
									table.insert(self.stretched[i], nextNode)
									deviated = deviated-1
								end
							end
						end
						cTriplet = self.cTriplets["\x03"..countryStr]
						if node.waterBody ~= "" and not self.colors["\x02"..node.waterBody] and self.waterBodies[node.waterBody] > 160 then
							if not self.cTriplets["\x02"..node.waterBody] then
								local cFound = false
								self.cTriplets["\xFFWATER"] = {22, 22, 170}
								while not cFound do
									cFound = true
									local r, g, b = math.random(0, 255), math.random(0, 255), math.random(0, 255)
									for k, l in pairs(self.cTriplets) do if math.abs(r-l[1])+math.abs(g-l[2])+math.abs(b-l[3]) < 60 then cFound = false end end
									if r > 230 and g > 230 and b > 230 then cFound = false end
									if r < 25 and g < 25 and b < 25 then cFound = false end
									if cFound then
										-- We cheat here a little bit to display water body names and outline colors on the map legend.
										-- Treat them as countries with no ruler string. Also, place a non-printing character at the beginning of their index key that sorts them at the top of an alphabetic list.
										-- We will also assign a similar hidden character to each country, specifically \x03 which will sort them after water bodies; and we will also assign \x01 to continents, which will sort them before.
										self.cTriplets["\x02"..node.waterBody] = {r, g, b}
									end
								end
								self.cTriplets["\xFFWATER"] = nil
							end
							self.colors["\x02"..node.waterBody] = self.cTriplets["\x02"..node.waterBody]
							leaders["\x02"..node.waterBody] = ""
						end
						if node.continent ~= "" and not self.colors["\x01"..node.continent] then
							if not self.cTriplets["\x01"..node.continent] then
								local cFound = false
								self.cTriplets["\xFFWATER"] = {22, 22, 170}
								while not cFound do
									cFound = true
									local r, g, b = math.random(0, 255), math.random(0, 255), math.random(0, 255)
									for k, l in pairs(self.cTriplets) do if math.abs(r-l[1])+math.abs(g-l[2])+math.abs(b-l[3]) < 60 then cFound = false end end
									if r > 230 and g > 230 and b > 230 then cFound = false end
									if r < 25 and g < 25 and b < 25 then cFound = false end
									if cFound then self.cTriplets["\x01"..node.continent] = {r, g, b} end
								end
								self.cTriplets["\xFFWATER"] = nil
							end
							self.colors["\x01"..node.continent] = self.cTriplets["\x01"..node.continent]
							leaders["\x01"..node.continent] = ""
						end
						cTriplet = self.cTriplets["\x03"..countryStr]
						local country = self.countries[countryStr]
						if country then
							local sysName = parent.systems[country.system].name
							local sntVal = country.snt[sysName]
							local legendStr = "\x03"..string.lower(countryStr.." ("..parent:ordinal(sntVal).." "..sysName..")")
							if cTriplet then
								self.colors[legendStr] = {cTriplet[1], cTriplet[2], cTriplet[3]}
								local ruler = country.rulers[#country.rulers]
								if ruler then leaders[legendStr] = parent:getRulerStringShort(ruler) else leaders[legendStr] = "no ruler" end
							end
						elseif cTriplet then
							self.colors["\x03"..countryStr] = {cTriplet[1], cTriplet[2], cTriplet[3]}
							leaders["\x03"..countryStr] = "no ruler"
						end
					end
				end

				if self.mapChanged then
					self.planetC = math.huge
					for i=1,columnCount do self.planetC = math.min(#self.stretched[i], self.planetC) end
					for i=1,columnCount do
						local sCol = #self.stretched[i]
						local diff = sCol-self.planetC
						while diff > 1 do
							local ratio, rate = sCol/diff, 0
							for j=#self.stretched[i],1,-1 do
								rate = rate+1
								if rate >= ratio then
									table.remove(self.stretched[i], j)
									rate = rate-ratio
								end
							end
							sCol = #self.stretched[i]
							diff = sCol-self.planetC
						end
						if diff == 1 then table.remove(self.stretched[i], 1) end
					end
				end

				if label == "NIL" then return end

				local tColCount = 1
				local tCols = {{}}
				local tColWidths = {0}
				local top = 2
				local bottom = 9
				local lineLen = 2
				local colorKeys = parent:getAlphabetical(self.colors)
				for i=1,#colorKeys do
					local cA = colorKeys[i]
					local cR = leaders[cA]
					lineLen = lineLen+20
					if lineLen >= columnCount then
						lineLen = 22
						tColCount = tColCount+1
						table.insert(tCols, {})
						table.insert(tColWidths, 0)
					end
					table.insert(tCols[tColCount], cA)
					local nameLen = cA:len()
					local rulerLen = cR:len()
					tColWidths[tColCount] = math.max(tColWidths[tColCount], nameLen+1, rulerLen+1)
				end

				local borderCol, extCols = -1, {}

				-- Here, we determine the column and row of the map with the most water pixels; we will start writing the map to file at this point, so that there is minimal 'wrapping' of land masses across the edges.
				for i=1,self.planetC do
					extCols[i] = 0
					for j=1,#self.stretched do if self.stretched[j][i] and self.stretched[j][i][1] == 22 and self.stretched[j][i][2] == 22 and self.stretched[j][i][3] == 170 then extCols[i] = extCols[i]+1 end end
					if borderCol == -1 or extCols[i] > extCols[borderCol] then borderCol = i end
				end

				if _DEBUG then
					local distortionMap = {}
					for distRow=1,columnCount do
						local nextPix = 1
						local lastPix = -1
						distortionMap[distRow] = {}
						for distColumn=1,self.planetC do
							if self.stretched[distRow][distColumn][7] ~= lastPix then
								nextPix = nextPix == 0 and 1 or 0
								lastPix = self.stretched[distRow][distColumn][7]
							end
							if nextPix == 1 then distortionMap[distRow][distColumn] = maxRGB
							else distortionMap[distRow][distColumn] = zeroRGB end
						end
					end
					parent:tiffOut("DISTORTION", distortionMap, self.planetC, columnCount)
				end

				local colSum = 2
				local margin = self.planetC+2 -- Our legend has two pixels of horiz. padding from the map.
				for i=1,#tCols do colSum = colSum+20+(tColWidths[i]*6) end -- The total width of all columns of text in the legend is (10 total pixels of padding+the max character length*8 pixels per character) per column.
				local extended = {}
				for row=1,columnCount do
					extended[row] = {}
					local cCol = 1
					local accCol = borderCol
					while cCol <= self.planetC do
						if self.stretched[row] and self.stretched[row][accCol] then
							extended[row][cCol] = {self.stretched[row][accCol][1], self.stretched[row][accCol][2], self.stretched[row][accCol][3]}
							if self.stretched[row][accCol][5] ~= "" and math.fmod(row+cCol, 24) == 0 then extended[row][cCol] = self.colors["\x02"..self.stretched[row][accCol][5]] or extended[row][cCol] end
							if self.stretched[row+1] and self.stretched[row+1][accCol] then
								if self.stretched[row+1][accCol][6] ~= self.stretched[row][accCol][6] then
									extended[row][cCol] = self.colors["\x01"..self.stretched[row][accCol][6]] or extended[row][cCol]
								elseif self.stretched[row+1][accCol][5] ~= "" and math.fmod(row+cCol+1, 24) == 0 then
									extended[row][cCol] = self.colors["\x02"..self.stretched[row][accCol][5]] or extended[row][cCol]
								elseif self.stretched[row+1][accCol][4] ~= self.stretched[row][accCol][4] then
									extended[row][cCol] = zeroRGB
								end
							end
							if self.stretched[row-1] and self.stretched[row-1][accCol] then
								if self.stretched[row-1][accCol][6] ~= self.stretched[row][accCol][6] then
									extended[row][cCol] = self.colors["\x01"..self.stretched[row][accCol][6]] or extended[row][cCol]
								elseif self.stretched[row-1][accCol][5] ~= "" and math.fmod(row+cCol-1, 24) == 0 then
									extended[row][cCol] = self.colors["\x02"..self.stretched[row][accCol][5]] or extended[row][cCol]
								elseif self.stretched[row-1][accCol][4] ~= self.stretched[row][accCol][4] then
									extended[row][cCol] = zeroRGB
								end
							end
							if self.stretched[row][accCol+1] then
								if self.stretched[row][accCol+1][6] ~= self.stretched[row][accCol][6] then
									extended[row][cCol] = self.colors["\x01"..self.stretched[row][accCol][6]] or extended[row][cCol]
								elseif self.stretched[row][accCol+1][5] ~= "" and math.fmod(row+cCol+1, 24) == 0 then
									extended[row][cCol] = self.colors["\x02"..self.stretched[row][accCol][5]] or extended[row][cCol]
								elseif self.stretched[row][accCol+1][4] ~= self.stretched[row][accCol][4] then
									extended[row][cCol] = zeroRGB
								end
							end
							if self.stretched[row][accCol-1] then
								if self.stretched[row][accCol-1][6] ~= self.stretched[row][accCol][6] then
									extended[row][cCol] = self.colors["\x01"..self.stretched[row][accCol][6]] or extended[row][cCol]
								elseif self.stretched[row][accCol-1][5] ~= "" and math.fmod(row+cCol-1, 24) == 0 then
									extended[row][cCol] = self.colors["\x02"..self.stretched[row][accCol][5]] or extended[row][cCol]
								elseif self.stretched[row][accCol-1][4] ~= self.stretched[row][accCol][4] then
									extended[row][cCol] = zeroRGB
								end
							end
						else extended[row][cCol] = zeroRGB end
						cCol = cCol+1
						accCol = accCol+1
						if accCol > self.planetC then accCol = 1 end
					end
					for j=self.planetC+1,self.planetC+colSum do extended[row][j] = zeroRGB end
				end

				for i=1,tColCount do -- For every column of text in the legend...
					local tCol = tCols[i]
					for j=1,#tCol do -- For every country name in this column...
						local colMargin = margin -- Save the value of the current spacing from the left border of the legend.
						local name = tCol[j]
						if name then
							local tColor = self.colors[name]
							if tColor then
								local tRuler = leaders[name]
								if name:sub(1, 1) == "\x02" and name:sub(2, 2) ~= "\x01" then
									if self.waterBodies[name:sub(2, name:len())] > math.ceil(#self.planetdefined/5) then name = name.." OCEAN"
									elseif self.waterBodies[name:sub(2, name:len())] > math.ceil(#self.planetdefined/100) then name = name.." SEA"
									else name = name.." BAY" end
								end
								local nameLen = name:len()
								local rulerLen = tRuler:len()
								for k=margin,margin+7 do for l=top,bottom do -- Define a square of color 8 pixels wide and tall, indicating the color of this country on the map.
									if not extended[l] then extended[l] = {} end
									if name:sub(1, 1) ~= "\x02" or name:sub(2, 2) == "\x01" or l > top+5 then extended[l][k] = {tColor[1], tColor[2], tColor[3]} else extended[l][k] = waterRGB end
								end end
								margin = margin+10 -- Move to the right of this square, leaving 10-8=2 pixels of padding.
								for k=1,nameLen do -- For each character...
									local letter = name:sub(k, k):lower() -- CCSCommon.glyphs has keys in lowercase.
									local glyph = parent.glyphs[letter] or parent.glyphs[" "] -- If there's a character not in our matrix, leave it as a blank space.
									local letterRow = 1
									local letterColumn = 1
									-- The glyph is itself a 2D matrix of monochrome pixel values -- 0 for black, 1 for white.
									-- Our vertical line height is 8 pixels, and each glyph is 6x6 pixels with the first column always empty. With each character's first and last columns overlapping, this leaves two pixels of padding between characters and three pixels between lines (we will later shift ten pixels down when moving lines).
									for l=top+1,bottom-1 do -- Top and bottom will always be 8 pixels apart.
										for m=margin,margin+5 do
											if glyph[letterRow][letterColumn] == 1 then -- White.
												extended[l][m] = maxRGB
											else -- Black.
												extended[l][m] = zeroRGB
											end
											letterColumn = letterColumn+1 -- Move to the right!
										end
										letterColumn = 1 -- Move back to the far left, and then...
										letterRow = letterRow+1 -- Move down. Quite like a CR+LF.
									end
									margin = margin+6 -- Move to the last column of this character. With our one pixel of padding on all sides, this will leave the appropriate space between letters.
								end
								margin = colMargin -- Just like when drawing out a single glyph matrix, here is our CR+LF for the entire line. Revert to the start of the line...
								top = top+10
								bottom = bottom+10 -- And move one line down, leaving two pixels of space.
								for k=margin,margin+7 do for l=top-2,bottom do -- Turn our previous square of color into a two-line-tall rectangle, for the line with this country's current ruler.
									if not extended[l] then extended[l] = {} end
									if name:sub(1, 1) ~= "\x02" or name:sub(2, 2) == "\x01" or l < bottom-5 then extended[l][k] = {tColor[1], tColor[2], tColor[3]} else extended[l][k] = waterRGB end
								end end
								margin = margin+14 -- As before, move to the right, but this time leave 6 pixels of padding for an indent.
								for k=1,rulerLen do
									local letter = tRuler:sub(k, k):lower()
									local glyph = parent.glyphs[letter] or parent.glyphs[" "]
									local letterRow = 1
									local letterColumn = 1
									-- Write out the ruler string the same way we wrote out the country's name.
									for l=top+1,bottom-1 do
										for m=margin,margin+5 do
											if glyph[letterRow][letterColumn] == 1 then extended[l][m] = maxRGB else extended[l][m] = zeroRGB end
											letterColumn = letterColumn+1
										end
										letterColumn = 1
										letterRow = letterRow+1
									end
									margin = margin+6
								end
								margin = colMargin
								top = top+10
								bottom = bottom+10
							end
						end
					end
					margin = margin+20+(tColWidths[i]*6) -- Shift over an entire text column...
					top = 2
					bottom = 9 -- And begin at the top left anew.
				end

				local totalC = margin -- Account for the addition of the legend in our bitmap dimensions.
				self.planetD = columnCount -- Whereas the planet's circumference defines our map's width, its diameter will define its height (since we haven't distorted the height while unwrapping).

				-- parent:bmpOut(label, extended, totalC, self.planetD)
				parent:tiffOut(label, extended, totalC, self.planetD)

				extended = nil
				tCols = nil
				extCols = nil
				colorKeys = nil
				tColWidths = nil
				leaders = nil

				if _DEBUG then
					if not debugTimes["World.mapOutput"] then debugTimes["World.mapOutput"] = 0 end
					debugTimes["World.mapOutput"] = debugTimes["World.mapOutput"]+_time()-t0
				end
			end,

			normalize = function(self, x, y, z)
				local mag = self.planetR/math.sqrt(math.pow(x, 2)+math.pow(y, 2)+math.pow(z, 2))
				return x*mag+self.planetR, y*mag+self.planetR, z*mag+self.planetR
			end,

			unwrap = function(self)
				local t0 = _time()
				local rd = self.planetR
				local finished = false
				local p, q, r, iColumn = 0, 0, -rd, 1
				local ring, ringDone, layer, pr, qr = 1, 0, 0, 1, 0
				while not finished do
					local pqr = self:getNodeFromCoords(p, q, r)
					ringDone = ringDone+1
					if self.planet[pqr] and not self.planet[pqr].mapWritten then
						while not self.unwrapped[iColumn] do table.insert(self.unwrapped, {}) end
						table.insert(self.unwrapped[iColumn], pqr)
						table.insert(self.planetdefined, pqr)
						self.planet[pqr].mapWritten = true
					end

					if p == 0 and q == 0 and r == rd then finished = true else
						if ringDone >= (ring == 1 and 1 or 4*(ring-1)) then
							iColumn = iColumn+1
							ringDone = 0
							if layer == 2 then
								ring = ring-2
								p = 0
								q = math.floor(ring/2)
								r = rd
								pr = 1
								qr = 0
							elseif layer == 1 then
								p = 0
								q = rd
								r = r+1
								pr = 1
								qr = 0
								if r == rd then layer = 2 end
							elseif layer == 0 then
								ring = ring+2
								p = 0
								q = math.floor(ring/2)
								r = -rd
								pr = 1
								qr = 0
								if q == rd then layer = 1 end
							end
						else
							p = p+pr
							if p > math.floor(ring/2) or p > rd then
								p = p-1
								pr = 0
								qr = -1
							elseif p < -math.floor(ring/2) or p < -rd then
								p = p+1
								pr = 0
								qr = 1
							end
							q = q+qr
							if q > math.floor(ring/2) or q > rd then
								q = q-1
								p = p+1
								pr = 1
								qr = 0
							elseif q < -math.floor(ring/2) or q < -rd then
								q = q+1
								p = p-1
								pr = -1
								qr = 0
							end
						end
					end
				end

				if _DEBUG then
					if not debugTimes["World.unwrap"] then debugTimes["World.unwrap"] = 0 end
					debugTimes["World.unwrap"] = debugTimes["World.unwrap"]+_time()-t0
				end
			end,

			update = function(self, parent)
				for i, j in pairs(debugTimes) do
					if j > 0 then priorDebugTimes[i] = j end
					debugTimes[i] = 0
				end
				local t0 = _time()

				self.numCountries = 0
				for i, j in pairs(self.countries) do self.numCountries = self.numCountries+1 end

				self.gPop = 0
				for i, j in pairs(parent.languages) do
					j.l1Speakers = 0
					j.l2Speakers = 0
				end

				if self.initialState then
					parent.iSCount = self.numCountries
					parent.iSIndex = 1
					UI:printf("Constructing initial populations...")
				end

				for i, cp in pairs(self.countries) do if cp then
					if self.initialState then
						UI:printl(string.format("Country %d/%d", parent.iSIndex, parent.iSCount))
						parent.iSIndex = parent.iSIndex+1
					end

					cp:update(parent)

					local defCount = 0
					for j=#cp.events,1,-1 do if cp.events[j].Year >= parent.years-30 and cp.events[j].Event:match("Defeat in war") then defCount = defCount+1 end end
					if defCount > 3 then
						local lastDef = ""
						for j=#cp.events,1,-1 do if lastDef == "" and cp.events[j].Event:match("Defeat in war") then lastDef = cp.events[j].Event:gsub("Defeat in war with ", "") end end
						for j, k in pairs(self.countries) do if k.name == lastDef then for l, m in pairs(parent.c_events) do if m.name == "Conquer" then cp:triggerEvent(parent, l, true, k) end end end end
					end
				end end

				self.initialState = false

				for i, cp in pairs(self.countries) do if cp then cp:eventloop(parent) end end
				for i, cp in pairs(self.countries) do if cp then self.gPop = self.gPop+cp.population end end

				local t1 = _time()-t0

				if parent.years > parent.startyear+1 then
					if _DEBUG then parent.popLimit = 250 else
						if t1 > 1.5 then
							parent.popLimit = math.max(1000, math.floor(parent.popLimit-(50*(t1-0.5))))
							if t1 > 3 then parent.disabled["independence"] = true else parent.disabled["independence"] = false end
						else parent.popLimit = math.min(5000, math.ceil(parent.popLimit+(50*(0.5-t1)))) end
					end
				end

				local t2 = _time()
				if math.fmod(parent.years, 40) == 0 then
					UI:printl("Deviating languages...")
					parent.langEML = parent.langEML+1
					if parent.langEML == 4 then
						parent.langEML = 1
						parent.langPeriod = parent.langPeriod+1
					end
					for i, j in pairs(self.countries) do
						if j.language.name ~= j.demonym then j.language = parent:getLanguage(j, j) else
							for k, l in pairs(j.regions) do l:deviateDialects(j, parent) end
							local newLang = j.language:deviate(parent)
							j.language = newLang
							j.language.name = j.demonym
							table.insert(parent.languages, 1, j.language)
						end
					end
					for i=#parent.languages-1,1,-1 do for j=#parent.languages,i+1,-1 do if i ~= j and parent.languages[i] and parent.languages[j] and parent.languages[i].name == parent.languages[j].name then table.remove(parent.languages, j) end end end
					parent:updateLangFamilies()
					if _DEBUG then parent:compLangs(true) end
				end
				if math.fmod(parent.years, 20) == 0 then
					UI:printl("Collecting garbage...")
					collectgarbage("collect")
				end
				local t3 = _time()
				--[[ if math.fmod(parent.years, 100) == 0 then
					UI:printl("Autosaving..."..string.rep(" ", 12))
					local fb = io.open(parent:directory{parent.stamp, "autosave.dat"}, "w+b")
					if fb then

						fb:flush()
						fb:close()
						fb = nil
					end
				end ]]
				if _DEBUG then
					local t4 = _time()
					if not debugTimes["GARBAGE"] then debugTimes["GARBAGE"] = 0 end
					debugTimes["GARBAGE"] = debugTimes["GARBAGE"]+t3-t2
					if not debugTimes["AUTOSAVE"] then debugTimes["AUTOSAVE"] = 0 end
					debugTimes["AUTOSAVE"] = debugTimes["AUTOSAVE"]+t4-t3
				end
			end
		}

		World.__index = World
		World.__call = function() return World:new() end

		return World
	end
