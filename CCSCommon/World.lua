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
				o.mapChanged = true
				o.numCountries = 0
				o.planet = {}
				o.planetdefined = {}
				o.planetC = 0
				o.planetD = 0
				o.planetR = 0
				o.stretched = {}
				o.unwrapped = {}

				return o
			end,

			add = function(self, nd)
				if not self.countries[nd.name] then self.numCountries = self.numCountries+1 end
				self.countries[nd.name] = nd
			end,

			constructVoxelPlanet = function(self, parent)
				parent:rseed()
				local t0 = _time()
				local rMin = 180
				local rMax = 225
				self.planetR = math.floor(math.random(rMin, rMax))
				local gridVol = (math.pow((self.planetR*2)+1, 2)*6)/100
				local rdone = 0

				UI:printf(string.format("Constructing voxel planet with radius of %d units...", self.planetR))

				for x=-self.planetR,self.planetR do
					for y=-self.planetR,self.planetR do
						local z = self.planetR
						local mag = z/math.sqrt(math.pow(x, 2)+math.pow(y, 2)+math.pow(z, 2))
						local xm = x*mag
						local ym = y*mag
						local zm = z*mag
						if math.fmod(xm, 1) >= 0.501 then xm = math.ceil(xm) else xm = math.floor(xm) end
						if math.fmod(ym, 1) >= 0.501 then ym = math.ceil(ym) else ym = math.floor(ym) end
						if math.fmod(zm, 1) >= 0.501 then zm = math.ceil(zm) else zm = math.floor(zm) end
						self.planet[self:getNodeFromCoords(xm, ym, -zm)] = { x=xm, y=ym, z=-zm, continent="", country="", countrySet=false, countryDone=false, region="", regionSet=false, regionDone=false, city="", land=false, waterNeighbors=true, mapWritten=false, neighbors={} }
						self.planet[self:getNodeFromCoords(xm, ym, zm)] = { x=xm, y=ym, z=zm, continent="", country="", countrySet=false, countryDone=false, region="", regionSet=false, regionDone=false, city="", land=false, waterNeighbors=true, mapWritten=false, neighbors={} }
						self.planet[self:getNodeFromCoords(xm, -zm, ym)] = { x=xm, y=-zm, z=ym, continent="", country="", countrySet=false, countryDone=false, region="", regionSet=false, regionDone=false, city="", land=false, waterNeighbors=true, mapWritten=false, neighbors={} }
						self.planet[self:getNodeFromCoords(xm, zm, ym)] = { x=xm, y=zm, z=ym, continent="", country="", countrySet=false, countryDone=false, region="", regionSet=false, regionDone=false, city="", land=false, waterNeighbors=true, mapWritten=false, neighbors={} }
						self.planet[self:getNodeFromCoords(-zm, xm, ym)] = { x=-zm, y=xm, z=ym, continent="", country="", countrySet=false, countryDone=false, region="", regionSet=false, regionDone=false, city="", land=false, waterNeighbors=true, mapWritten=false, neighbors={} }
						self.planet[self:getNodeFromCoords(zm, xm, ym)] = { x=zm, y=xm, z=ym, continent="", country="", countrySet=false, countryDone=false, region="", regionSet=false, regionDone=false, city="", land=false, waterNeighbors=true, mapWritten=false, neighbors={} }
						rdone = rdone+6
					end
					UI:printl(string.format("%.2f%% done", (rdone/gridVol)))
				end

				UI:printf("Unwrapping planet to data matrix...")
				self:unwrap()

				UI:printf("Distorting data matrix into flat projection...")
				self:mapOutput(parent, "NIL")

				UI:printf("Cross-referencing neighboring points on planet surface...")
				for i=1,#self.stretched do
					for j=1,#self.stretched[i] do
						local xyz = self.stretched[i][j][6]
						for k=-1,1 do for l=-1,1 do if k ~= 0 or l ~= 0 then if self.stretched[i-k] then
							local xi = i-k
							local yi = j-l
							if yi < 1 then yi = yi+#self.stretched[xi] end
							if yi > #self.stretched[xi] then yi = yi-#self.stretched[xi] end
							local found = false
							for m=1,#self.planet[xyz].neighbors do if not found then
								if self.planet[xyz].neighbors[m] == self.stretched[xi][yi][6] then found = true end
							end end
							if not found then table.insert(self.planet[xyz].neighbors, self.stretched[xi][yi][6]) end
						end end end end
					end
				end

				collectgarbage("collect")

				UI:printf("Defining land masses...")
				local planetSize = #self.planetdefined

				local maxLand = math.random(math.floor(planetSize/2.75), math.ceil(planetSize/2))
				local continents = math.random(5, 9)
				local freeNodes = {}
				for i=1,continents do
					local located = true
					local cSeed = parent:randomChoice(self.planetdefined)

					if self.planet[cSeed].land then located = false end
					while not located do
						cSeed = parent:randomChoice(self.planetdefined)
						located = true
						if self.planet[cSeed].land then located = false end
					end

					self.planet[cSeed].land = true
					self.planet[cSeed].continent = parent:name(true, 3, 2)
					table.insert(freeNodes, cSeed)
				end
				local doneLand = continents
				while doneLand < maxLand do
					local node = math.random(1, #freeNodes)
					local xyz = freeNodes[node]

					while not self.planet[xyz].waterNeighbors do
						table.remove(freeNodes, node)
						node = math.random(1, #freeNodes)
						xyz = freeNodes[node]
					end

					for neighbor=1,#self.planet[xyz].neighbors do
						if math.random(1, 35) == math.random(1, 35) then
							local nxyz = self.planet[xyz].neighbors[neighbor]
							if not self.planet[nxyz].land then
								self.planet[nxyz].continent = self.planet[xyz].continent
								self.planet[nxyz].land = true
								doneLand = doneLand+1
								self.planet[nxyz].waterNeighbors = false
								for i, j in pairs(self.planet[nxyz].neighbors) do
									if not self.planet[j].land then self.planet[nxyz].waterNeighbors = true end
								end
								if self.planet[nxyz].waterNeighbors then table.insert(freeNodes, nxyz) end
							end
						end
					end

					self.planet[xyz].waterNeighbors = false
					for neighbor=1,#self.planet[xyz].neighbors do
						local nxyz = self.planet[xyz].neighbors[neighbor]
						if not self.planet[nxyz].land then self.planet[xyz].waterNeighbors = true end
					end

					if math.fmod(doneLand, 100) == 0 then UI:printl(string.format("%.2f%% done", (doneLand/maxLand)*100)) end
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

				local allDefined = false
				local totalDefined = #defined
				local prevDefined = #defined
				ci = 1

				while not allDefined do
					for i=#defined,1,-1 do
						local xyz = defined[i]
						local nDefined = true

						if self.planet[xyz].land and self.planet[xyz].country ~= "" and not self.planet[xyz].countrySet and not self.planet[xyz].countryDone then
							for j=1,#self.planet[xyz].neighbors do
								local neighbor = self.planet[xyz].neighbors[j]
								if self.planet[neighbor].land and self.planet[neighbor].country == "" then
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

					for i=1,#defined do
						local xyz = defined[i]
						self.planet[xyz].countrySet = false
					end

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
					UI:printl(string.format("%.2f%% done", (totalDefined/doneLand)*100))
				end

				parent:getAlphabetical()
				UI:printf("Defining regional boundaries...")

				for i, j in pairs(self.countries) do
					UI:printl(string.format("Country %d/%d", ci, self.numCountries))
					ci = ci+1
					j:setTerritory(parent)
				end

				self.mapChanged = true

				for i, j in pairs(parent.c_events) do
					parent.disabled[j.name:lower()] = false
					parent.disabled["!"..j.name:lower()] = false
				end

				collectgarbage("collect")
			end,

			delete = function(self, parent, nz)
				if not nz then return end

				self.cTriplets["\x02"..nz.name] = nil
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
				return ((x+self.planetR)*math.pow(self.planetR*2+1, 2))+((y+self.planetR)*(self.planetR*2+1))+(z+self.planetR)+1
			end,

			mapOutput = function(self, parent, label)
				if label ~= "NIL" and not parent.doMaps then return end
				local t0 = _time()

				local planetSize = #self.planetdefined

				for i, cp in pairs(self.countries) do
					if not self.cTriplets["\x02"..cp.name] then
						self.cTriplets["\x02"..cp.name] = nil

						local r = 0
						local g = 0
						local b = 0

						local unique = false
						while not unique do
							unique = true
							for k, j in pairs(self.cTriplets) do
								local unq = math.abs(r-j[1])+math.abs(g-j[2])+math.abs(b-j[3])
								if unq < 55 then unique = false end
							end

							if r > 230 and g > 230 and b > 230 then unique = false end
							if r < 25 and g < 25 and b < 25 then unique = false end

							if not unique then
								r = math.random(0, 255)
								g = math.random(0, 255)
								b = math.random(0, 255)
							end
						end

						self.cTriplets["\x02"..cp.name] = {r, g, b}
					end
				end

				local columnCount = #self.unwrapped
				self.colors = {["\x01\x01CONTINENTS"]={0, 0, 0}, ["\x02\x01COUNTRIES"]={0, 0, 0}}
				local leaders = {["\x01\x01CONTINENTS"]="", ["\x02\x01COUNTRIES"]=""}

				iColumn = 1
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
					local deviation = math.fmod(self.planetC/#column, 1)
					local deviated = 0
					for j=1,#column do
						local exyz = column[j]
						local node = self.planet[exyz]
						local countryStr = node.country
						local cTriplet = self.cTriplets["\x02"..countryStr]
						if not node.land or not cTriplet then cTriplet = {22, 22, 170} end
						if self.mapChanged then
							for k=1,pixelsPerUnit do
								table.insert(self.stretched[i], {cTriplet[1], cTriplet[2], cTriplet[3], node.region, node.continent, exyz})
								deviated = deviated+deviation
								while deviated >= 1 do
									table.insert(self.stretched[i], {cTriplet[1], cTriplet[2], cTriplet[3], node.region, node.continent, exyz})
									deviated = deviated-1
								end
							end
						end
						cTriplet = self.cTriplets["\x02"..countryStr]
						if node.continent ~= "" and not self.colors["\x01"..node.continent] then
							if not self.cTriplets["\x01"..node.continent] then
								local cFound = false
								while not cFound do
									cFound = true
									local r = math.random(0, 255)
									local g = math.random(0, 255)
									local b = math.random(0, 255)
									for k, l in pairs(self.cTriplets) do
										local unq = math.abs(r-l[1])+math.abs(g-l[2])+math.abs(b-l[3])
										if unq < 60 then cFound = false end
										if r > 230 and g > 230 and b > 230 then unq = false end
										if r < 25 and g < 25 and b < 25 then unq = false end
									end
									if cFound then
										-- We cheat here a little bit to display continent names and outline colors on the map legend.
										-- Treat them as countries, but with no ruler string, and with a separate color palette that isn't tied to the one for actual countries. Also, place a hidden character at the beginning of their index key that sorts them at the top of an alphabetic list.
										-- We will also assign a similar hidden character to each country.
										self.cTriplets["\x01"..node.continent] = {r, g, b}
									end
								end
							end
							self.colors["\x01"..node.continent] = self.cTriplets["\x01"..node.continent]
							leaders["\x01"..node.continent] = ""
						end
						local country = self.countries[countryStr]
						if country then
							local sysName = parent.systems[country.system].name
							local sntVal = country.snt[sysName]
							local legendStr = "\x02"..string.lower(countryStr.." ("..parent:ordinal(sntVal).." "..sysName..")")
							if cTriplet then
								self.colors[legendStr] = {cTriplet[1], cTriplet[2], cTriplet[3]}
								local ruler = country.rulers[#country.rulers]
								if ruler then leaders[legendStr] = parent:getRulerStringShort(ruler) else leaders[legendStr] = "no ruler" end
							end
						elseif cTriplet then
							self.colors["\x02"..countryStr] = {cTriplet[1], cTriplet[2], cTriplet[3]}
							leaders["\x02"..countryStr] = "no ruler"
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
							local ratio = sCol/diff
							local rate = 0
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

				local borderCol = -1
				local extCols = {}

				-- Here, we determine the column of the map with the most water pixels; we will start writing the map to file at this point, so that there is minimal 'wrapping' of land masses across the edge.
				for i=1,self.planetC do
					extCols[i] = 0
					for j=1,#self.stretched do if self.stretched[j][i] and self.stretched[j][i][1] == 22 and self.stretched[j][i][2] == 22 and self.stretched[j][i][3] == 170 then extCols[i] = extCols[i]+1 end end
					if borderCol == -1 or extCols[i] > extCols[borderCol] then borderCol = i end
				end

				local colSum = 2
				local margin = self.planetC+2 -- Our legend has two pixels of horiz. padding from the map.
				for i=1,#tCols do colSum = colSum+20+(tColWidths[i]*6) end -- The total width of all columns of text in the legend is (10 total pixels of padding+the max character length*8 pixels per character) per column.
				local extended = {}
				for i=1,columnCount do
					extended[(i*2)-1] = {}
					extended[i*2] = {}
					local cCol = 1
					local accCol = borderCol
					while cCol <= self.planetC do
						if self.stretched[i][accCol] then
							extended[(i*2)-1][(cCol*2)-1] = {self.stretched[i][accCol][1], self.stretched[i][accCol][2], self.stretched[i][accCol][3]}
							extended[(i*2)-1][cCol*2] = {self.stretched[i][accCol][1], self.stretched[i][accCol][2], self.stretched[i][accCol][3]}
							extended[i*2][(cCol*2)-1] = {self.stretched[i][accCol][1], self.stretched[i][accCol][2], self.stretched[i][accCol][3]}
							extended[i*2][cCol*2] = {self.stretched[i][accCol][1], self.stretched[i][accCol][2], self.stretched[i][accCol][3]}
							if self.stretched[i+1] and self.stretched[i+1][accCol] then
								if self.stretched[i+1][accCol][5] ~= self.stretched[i][accCol][5] then
									extended[i*2][(cCol*2)-1] = self.colors["\x01"..self.stretched[i][accCol][5]] or extended[i*2][(cCol*2)-1]
									extended[i*2][cCol*2] = self.colors["\x01"..self.stretched[i][accCol][5]] or extended[i*2][cCol*2]
								elseif self.stretched[i+1][accCol][4] ~= self.stretched[i][accCol][4] then
									extended[i*2][(cCol*2)-1] = {0, 0, 0}
									extended[i*2][cCol*2] = {0, 0, 0}
								end
							end
							if self.stretched[i-1] and self.stretched[i-1][accCol] then
								if self.stretched[i-1][accCol][5] ~= self.stretched[i][accCol][5] then
									extended[(i*2)-1][(cCol*2)-1] = self.colors["\x01"..self.stretched[i][accCol][5]] or extended[(i*2)-1][(cCol*2)-1]
									extended[(i*2)-1][cCol*2] = self.colors["\x01"..self.stretched[i][accCol][5]] or extended[(i*2)-1][cCol*2]
								elseif self.stretched[i-1][accCol][4] ~= self.stretched[i][accCol][4] then
									extended[(i*2)-1][(cCol*2)-1] = {0, 0, 0}
									extended[(i*2)-1][cCol*2] = {0, 0, 0}
								end
							end
							if self.stretched[i][accCol+1] then
								if self.stretched[i][accCol+1][5] ~= self.stretched[i][accCol][5] then
									extended[(i*2)-1][cCol*2] = self.colors["\x01"..self.stretched[i][accCol][5]] or extended[(i*2)-1][cCol*2]
									extended[i*2][cCol*2] = self.colors["\x01"..self.stretched[i][accCol][5]] or extended[i*2][cCol*2]
								elseif self.stretched[i][accCol+1][4] ~= self.stretched[i][accCol][4] then
									extended[(i*2)-1][cCol*2] = {0, 0, 0}
									extended[i*2][cCol*2] = {0, 0, 0}
								end
							end
							if self.stretched[i][accCol-1] then
								if self.stretched[i][accCol-1][5] ~= self.stretched[i][accCol][5] then
									extended[(i*2)-1][(cCol*2)-1] = self.colors["\x01"..self.stretched[i][accCol][5]] or extended[(i*2)-1][(cCol*2)-1]
									extended[i*2][(cCol*2)-1] = self.colors["\x01"..self.stretched[i][accCol][5]] or extended[i*2][(cCol*2)-1]
								elseif self.stretched[i][accCol-1][4] ~= self.stretched[i][accCol][4] then
									extended[(i*2)-1][(cCol*2)-1] = {0, 0, 0}
									extended[i*2][(cCol*2)-1] = {0, 0, 0}
								end
							end
						else
							extended[(i*2)-1][(cCol*2)-1] = {0, 0, 0}
							extended[(i*2)-1][cCol*2] = {0, 0, 0}
							extended[i*2][(cCol*2)-1] = {0, 0, 0}
							extended[i*2][cCol*2] = {0, 0, 0}
						end
						cCol = cCol+1
						accCol = accCol+1
						if accCol > self.planetC then accCol = 1 end
					end
					for j=self.planetC+1,self.planetC+colSum do
						extended[(i*2)-1][(j*2)-1] = {0, 0, 0}
						extended[(i*2)-1][j*2] = {0, 0, 0}
						extended[i*2][(j*2)-1] = {0, 0, 0}
						extended[i*2][j*2] = {0, 0, 0}
					end
				end

				for i=1,tColCount do -- For every column of text in the legend...
					local tCol = tCols[i]
					for j=1,#tCol do -- For every country name in this column...
						local colMargin = margin -- Save the value of the current spacing from the left border of the legend.
						local name = tCol[j]
						if name then
							local tColor = self.colors[name]
							local tRuler = leaders[name]
							name = name:gsub("[^%w %-%&%+%'%(%)%[%]%.]", "")
							tRuler = tRuler:gsub("[^%w %-%&%+%'%(%)%[%]%.]", "")
							local nameLen = name:len()
							local rulerLen = tRuler:len()
							for k=margin,margin+7 do for l=top,bottom do -- Define a square of color 8 pixels wide and tall, indicating the color of this country on the map.
								if not extended[(l*2)-1] then extended[(l*2)-1] = {} end
								if not extended[l*2] then extended[l*2] = {} end
								extended[(l*2)-1][(k*2)-1] = {tColor[1], tColor[2], tColor[3]}
								extended[(l*2)-1][k*2] = {tColor[1], tColor[2], tColor[3]}
								extended[l*2][(k*2)-1] = {tColor[1], tColor[2], tColor[3]}
								extended[l*2][k*2] = {tColor[1], tColor[2], tColor[3]}
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
										if glyph[letterRow][letterColumn] == 1 then
											extended[(l*2)-1][(m*2)-1] = {255, 255, 255} -- White.
											extended[(l*2)-1][m*2] = {255, 255, 255}
											extended[l*2][(m*2)-1] = {255, 255, 255}
											extended[l*2][m*2] = {255, 255, 255}
										else
											extended[(l*2)-1][(m*2)-1] = {0, 0, 0} -- Black.
											extended[(l*2)-1][m*2] = {0, 0, 0}
											extended[l*2][(m*2)-1] = {0, 0, 0}
											extended[l*2][m*2] = {0, 0, 0}
										end
										letterColumn = letterColumn+1 -- Move to the right!
									end
									letterColumn = 1 -- Move back to the far left, and then...
									letterRow = letterRow+1 -- Move down. Quite like a CR+LF.
								end
								margin = margin+6 -- Move to the last pixel of the last character. With our one pixel of padding on all sides, this will leave the appropriate space between letters.
							end
							margin = colMargin -- Just like when drawing out a single glyph matrix, here is our CR+LF for the entire line. Revert to the start of the line...
							top = top+10
							bottom = bottom+10 -- And move one line down, leaving two pixels of space.
							for k=margin,margin+7 do for l=top-2,bottom do -- Turn our previous square of color into a two-line-tall rectangle, for the line with this country's current ruler.
								if not extended[(l*2)-1] then extended[(l*2)-1] = {} end
								if not extended[l*2] then extended[l*2] = {} end
								extended[(l*2)-1][(k*2)-1] = {tColor[1], tColor[2], tColor[3]}
								extended[(l*2)-1][k*2] = {tColor[1], tColor[2], tColor[3]}
								extended[l*2][(k*2)-1] = {tColor[1], tColor[2], tColor[3]}
								extended[l*2][k*2] = {tColor[1], tColor[2], tColor[3]}
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
										if glyph[letterRow][letterColumn] == 1 then
											extended[(l*2)-1][(m*2)-1] = {255, 255, 255}
											extended[(l*2)-1][m*2] = {255, 255, 255}
											extended[l*2][(m*2)-1] = {255, 255, 255}
											extended[l*2][m*2] = {255, 255, 255}
										else
											extended[(l*2)-1][(m*2)-1] = {0, 0, 0}
											extended[(l*2)-1][m*2] = {0, 0, 0}
											extended[l*2][(m*2)-1] = {0, 0, 0}
											extended[l*2][m*2] = {0, 0, 0}
										end
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
					margin = margin+20+(tColWidths[i]*6) -- Shift over an entire column...
					top = 2
					bottom = 9 -- And begin at the top left anew.
				end

				local totalC = margin*2 -- Account for the addition of the legend in our bitmap dimensions.
				self.planetD = columnCount*2 -- Whereas the planet's circumference defines our map's width, its diameter will define its height (since we haven't distorted the height while unwrapping).

				parent:bmpOut(label, extended, totalC, self.planetD)

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

			unwrap = function(self)
				local t0 = _time()

				local rd = self.planetR
				local p = 1
				local q = -rd
				local r = -rd
				local quad = 1
				local iColumn = 1
				local vox = false
				local nextVox = false
				while r <= rd do
					local pqr = self:getNodeFromCoords(p, q, r)
					if self.planet[pqr] and not self.planet[pqr].mapWritten then
						while not self.unwrapped[iColumn] do table.insert(self.unwrapped, {}) end
						table.insert(self.unwrapped[iColumn], pqr)
						table.insert(self.planetdefined, pqr)
						self.planet[pqr].mapWritten = true
						vox = true
					end
					if quad == 1 and p > rd then
						quad = 2
						p = rd
						q = 1
					elseif quad == 2 and q > rd then
						quad = 3
						p = -1
						q = rd
					elseif quad == 3 and p < -rd then
						quad = 4
						p = -rd
						q = -1
					elseif quad == 4 and q < -rd then
						quad = 1
						p = 1
						q = -rd
						r = r+1
						UI:printl(string.format("%.2f%% done", ((r+rd)/((rd*2)+1))*100))
						iColumn = iColumn+1
					else
						if quad == 1 then
							if vox and self.planet[self:getNodeFromCoords(p, q+1, r)] and not self.planet[self:getNodeFromCoords(p, q+1, r)].mapWritten and not self.planet[self:getNodeFromCoords(p+1, q+1, r)] then nextVox = true end
							if nextVox or not vox then
								q = q+1
								if q > 0 then
									q = -rd
									p = p+1
								end
							else p = p+1 end
						elseif quad == 2 then
							if vox and self.planet[self:getNodeFromCoords(p-1, q, r)] and not self.planet[self:getNodeFromCoords(p-1, q, r)].mapWritten and not self.planet[self:getNodeFromCoords(p-1, q+1, r)] then nextVox = true end
							if nextVox or not vox then
								p = p-1
								if p < 0 then
									p = rd
									q = q+1
								end
							else q = q+1 end
						elseif quad == 3 then
							if vox and self.planet[self:getNodeFromCoords(p, q-1, r)] and not self.planet[self:getNodeFromCoords(p, q-1, r)].mapWritten and not self.planet[self:getNodeFromCoords(p-1, q-1, r)] then nextVox = true end
							if nextVox or not vox then
								q = q-1
								if q < 0 then
									q = rd
									p = p-1
								end
							else p = p-1 end
						elseif quad == 4 then
							if vox and self.planet[self:getNodeFromCoords(p+1, q, r)] and not self.planet[self:getNodeFromCoords(p+1, q, r)].mapWritten and not self.planet[self:getNodeFromCoords(p+1, q-1, r)] then nextVox = true end
							if nextVox or not vox then
								p = p+1
								if p > 0 then
									p = -rd
									q = q-1
								end
							else q = q-1 end
						end
					end
					vox = false
					nextVox = false
				end

				if _DEBUG then
					if not debugTimes["World.unwrap"] then debugTimes["World.unwrap"] = 0 end
					debugTimes["World.unwrap"] = debugTimes["World.unwrap"]+_time()-t0
				end
			end,

			update = function(self, parent)
				for i, j in pairs(debugTimes) do debugTimes[i] = 0 end
				local t0 = _time()

				self.numCountries = 0
				for i, j in pairs(self.countries) do self.numCountries = self.numCountries+1 end

				self.gPop = 0

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
					if _DEBUG then parent.popLimit = 250
					else
						if t1 > 0.5 then
							parent.popLimit = math.max(1000, math.floor(parent.popLimit-(50*(t1-0.5))))
							if t1 > 2 then parent.disabled["independence"] = true else parent.disabled["independence"] = false end
						else
							parent.popLimit = math.min(3000, math.ceil(parent.popLimit+(50*(0.5-t1))))
						end
					end
				end

				local t2 = _time()
				if math.fmod(parent.years, 20) == 0 then collectgarbage("collect") end
				local t3 = _time()
				if _DEBUG then
					if not debugTimes["GARBAGE"] then debugTimes["GARBAGE"] = 0 end
					debugTimes["GARBAGE"] = debugTimes["GARBAGE"]+t3-t2
				end
			end
		}

		World.__index = World
		World.__call = function() return World:new() end

		return World
	end
