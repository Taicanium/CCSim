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
				self.countries[nd.name] = nd
			end,

			constructVoxelPlanet = function(self, parent)
				parent:rseed()

				UI:printf("Benchmarking...")
				local bRad = 175
				local bVol = math.pow((bRad*2)+1, 3)/100
				local bench = {}

				local t0 = _time()
				local bdone = 0

				if not _DEBUG then for x=-bRad,bRad do
					for y=-bRad,bRad do
						for z=-bRad,bRad do
							local fsqrt = math.sqrt(math.pow(x, 2)+math.pow(y, 2)+math.pow(z, 2))
							if fsqrt < bRad+0.5 and fsqrt > bRad-0.5 then
								if not bench[x] then bench[x] = {} end
								if not bench[x][y] then bench[x][y] = {} end
								bench[x][y][z] = {}
							end
							bdone = bdone+1
						end
					end
					UI:printl(string.format("%.2f%% done", (bdone/bVol)))
				end end

				local benchAdjust = math.floor(_time()-t0)
				if benchAdjust > 100 or _DEBUG then benchAdjust = 100 end

				local rMin = 130
				local rMax = 175
				self.planetR = math.floor(math.random(rMin-benchAdjust, rMax-benchAdjust))
				local gridVol = math.pow((self.planetR*2)+1, 3)/100
				parent:deepnil(bench)

				UI:printf(string.format("Constructing voxel planet with radius of %d units...", self.planetR))

				local rdone = 0

				for x=-self.planetR,self.planetR do
					for y=-self.planetR,self.planetR do
						for z=-self.planetR,self.planetR do
							local fsqrt = math.sqrt(math.pow(x, 2)+math.pow(y, 2)+math.pow(z, 2))
							if fsqrt < self.planetR+0.5 and fsqrt > self.planetR-0.5 then
								if not self.planet[x] then self.planet[x] = {} end
								if not self.planet[x][y] then self.planet[x][y] = {} end
								self.planet[x][y][z] = {
									x=x,
									y=y,
									z=z,
									country="",
									countrySet=false,
									countryDone=false,
									region="",
									regionSet=false,
									regionDone=false,
									city="",
									land=false,
									waterNeighbors=true,
									mapWritten=false,
									neighbors={}
								}
								table.insert(self.planetdefined, {x, y, z})
							end
							rdone = rdone+1
						end
					end
					UI:printl(string.format("%.2f%% done", (rdone/gridVol)))
				end

				local planetSize = #self.planetdefined

				for i=1,planetSize do
					local x, y, z = table.unpack(self.planetdefined[i])
					for dx=-1,1 do for dy=-1,1 do for dz=-1,1 do if dx ~= 0 or dy ~= 0 or dz ~= 0 then if self.planet[x-dx] and self.planet[x-dx][y-dy] and self.planet[x-dx][y-dy][z-dz] then table.insert(self.planet[x][y][z].neighbors, {x-dx, y-dy, z-dz}) end end end end end
				end

				UI:printf("Defining land masses...")

				local maxLand = math.random(math.floor(planetSize/2.75), math.ceil(planetSize/2))
				local continents = math.random(10, 15)
				local freeNodes = {}
				for i=1,continents do
					local located = true
					local cSeed = parent:randomChoice(self.planetdefined)
					local x, y, z = table.unpack(cSeed)

					if self.planet[x][y][z].land then located = false end
					while not located do
						cSeed = parent:randomChoice(self.planetdefined)
						x, y, z = table.unpack(cSeed)
						located = true
						if self.planet[x][y][z].land then located = false end
					end

					self.planet[x][y][z].land = true
					table.insert(freeNodes, {x, y, z})
				end
				local doneLand = continents
				while doneLand < maxLand do
					local node = math.random(1, #freeNodes)
					local x, y, z = table.unpack(freeNodes[node])

					while not self.planet[x][y][z].waterNeighbors do
						table.remove(freeNodes, node)
						node = math.random(1, #freeNodes)
						x, y, z = table.unpack(freeNodes[node])
					end

					if math.random(1, 10) == math.random(1, 10) then
						for neighbor=1,#self.planet[x][y][z].neighbors do
							local nx, ny, nz = table.unpack(self.planet[x][y][z].neighbors[neighbor])
							if not self.planet[nx][ny][nz].land and math.random(1, 10) == math.random(1, 10) then
								self.planet[nx][ny][nz].land = true
								doneLand = doneLand+1
								self.planet[nx][ny][nz].waterNeighbors = false
								for i, j in pairs(self.planet[nx][ny][nz].neighbors) do
									local jx, jy, jz = table.unpack(j)
									if not self.planet[jx][jy][jz].land then self.planet[nx][ny][nz].waterNeighbors = true end
								end
								if self.planet[nx][ny][nz].waterNeighbors then table.insert(freeNodes, {nx, ny, nz}) end
							end
						end
					end

					self.planet[x][y][z].waterNeighbors = false
					for neighbor=1,#self.planet[x][y][z].neighbors do
						local nx, ny, nz = table.unpack(self.planet[x][y][z].neighbors[neighbor])
						if not self.planet[nx][ny][nz].land then self.planet[x][y][z].waterNeighbors = true end
					end

					if math.fmod(doneLand, 100) == 0 then UI:printl(string.format("%.2f%% done", (doneLand/maxLand)*100)) end
				end

				parent:deepnil(freeNodes)

				for i=1,planetSize do
					local x, y, z = table.unpack(self.planetdefined[i])
					self.planet[x][y][z].neighbors = {}
					for dx=-1,1 do if self.planet[x-dx] then for dy=-1,1 do if self.planet[x-dx][y-dy] then for dz=-1,1 do if dx ~= 0 or dy ~= 0 or dz ~= 0 then if self.planet[x-dx][y-dy][z-dz] then table.insert(self.planet[x][y][z].neighbors, {x-dx, y-dy, z-dz}) end end end end end end end
				end

				UI:printf("Rooting countries...")
				local ci = 1
				local defined = 0

				for i, cp in pairs(self.countries) do
					UI:printl(string.format("Country %d/%d", ci, parent.numCountries))
					ci = ci+1

					local located = true
					local rnd = parent:randomChoice(self.planetdefined)
					local x, y, z = table.unpack(rnd)

					if self.planet[x][y][z].country ~= "" or not self.planet[x][y][z].land then located = false end
					while not located do
						rnd = parent:randomChoice(self.planetdefined)
						x, y, z = table.unpack(rnd)
						located = true
						if self.planet[x][y][z].country ~= "" or not self.planet[x][y][z].land then located = false end
					end

					self.planet[x][y][z].country = cp.name
					defined = defined+1
				end

				UI:printf("Setting territories...")

				local allDefined = false
				local prevDefined = defined
				ci = 1

				while not allDefined do
					for i=1,planetSize do
						local x, y, z = table.unpack(self.planetdefined[i])

						if self.planet[x][y][z].land and self.planet[x][y][z].country ~= "" and not self.planet[x][y][z].countrySet and not self.planet[x][y][z].countryDone then
							for j=1,#self.planet[x][y][z].neighbors do
								local neighbor = self.planet[x][y][z].neighbors[j]
								local nx, ny, nz = table.unpack(neighbor)
								if self.planet[nx][ny][nz].land and self.planet[nx][ny][nz].country == "" then
									self.planet[nx][ny][nz].country = self.planet[x][y][z].country
									self.planet[nx][ny][nz].countrySet = true
									defined = defined+1
								end
							end
							self.planet[x][y][z].countryDone = true
						end
					end

					for i=1,planetSize do
						local x, y, z = table.unpack(self.planetdefined[i])
						self.planet[x][y][z].countrySet = false
					end

					if defined == prevDefined then allDefined = true end
					prevDefined = defined

					UI:printl(string.format("%.2f%% done", (defined/doneLand)*100))
				end

				for i=1,planetSize do
					local x, y, z = table.unpack(self.planetdefined[i])
					if self.planet[x][y][z].country == "" then self.planet[x][y][z].land = false end
				end

				UI:printf("Defining regional boundaries...")

				for i, cp in pairs(self.countries) do
					UI:printl(string.format("Country %d/%d", ci, parent.numCountries))
					ci = ci+1
					cp:setTerritory(parent)
				end

				parent.stamp = tostring(math.floor(_stamp()))

				for i, j in pairs(parent.c_events) do
					parent.disabled[j.name:lower()] = false
					parent.disabled["!"..j.name:lower()] = false
				end
			end,

			delete = function(self, parent, nz)
				if not nz then return end

				self.cTriplets[nz.name] = nil
				self.countries[nz.name] = nil

				nz:destroy(parent)
				parent.numCountries = parent.numCountries-1
				parent.writeMap = true
				self.mapChanged = true
			end,

			destroy = function(self)
				for i, cp in pairs(self.countries) do
					cp:destroy(parent)
					cp = nil
				end
			end,

			mapOutput = function(self, parent, label)
				if not parent.doMaps then return end
				UI:printf("Writing map data...")

				local planetSize = #self.planetdefined

				for i, cp in pairs(self.countries) do
					if not self.cTriplets[cp.name] then
						self.cTriplets[cp.name] = nil

						local r = 0
						local g = 0
						local b = 0

						local unique = false
						while not unique do
							unique = true
							for k, j in pairs(self.cTriplets) do
								local unq = (math.abs(r-j[1]))+(math.abs(g-j[2]))+(math.abs(b-j[3]))
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

						self.cTriplets[cp.name] = {r, g, b}
					end
				end

				if #self.unwrapped == 0 then self:unwrap() end
				local columnCount = #self.unwrapped
				self.colors = {}
				local leaders = {}

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
						local entry = column[j]
						local node = self.planet[entry[1]][entry[2]][entry[3]]
						local countryStr = node.country
						local cTriplet = self.cTriplets[countryStr]
						if self.mapChanged then
							for k=1,pixelsPerUnit do
								if node.land and cTriplet then table.insert(self.stretched[i], {cTriplet[1], cTriplet[2], cTriplet[3]}) else table.insert(self.stretched[i], {22, 22, 170}) end
								deviated = deviated+deviation
								while deviated >= 1 do
									if node.land and cTriplet then table.insert(self.stretched[i], {cTriplet[1], cTriplet[2], cTriplet[3]}) else table.insert(self.stretched[i], {22, 22, 170}) end
									deviated = deviated-1
								end
							end
						end
						local country = self.countries[countryStr]
						if country then
							local sysName = parent.systems[country.system].name
							local sntVal = country.snt[sysName]
							local legendStr = string.lower(countryStr.." ("..parent:ordinal(sntVal).." "..sysName..")")
							if cTriplet then
								self.colors[legendStr] = {cTriplet[1], cTriplet[2], cTriplet[3]}
								local ruler = country.rulers[#country.rulers]
								if ruler then leaders[legendStr] = parent:getRulerStringShort(ruler) else leaders[legendStr] = "no ruler" end
							end
						elseif cTriplet then
							self.colors[countryStr] = {cTriplet[1], cTriplet[2], cTriplet[3]}
							leaders[countryStr] = "no ruler"
						end
					end
				end

				if self.mapChanged then
					self.planetC = math.huge
					for i=1,columnCount do
						local col = self.stretched[i]
						if #col < self.planetC then self.planetC = #col end
					end
					for i=1,columnCount do
						local col = self.stretched[i]
						local sCol = #col
						local diff = sCol-self.planetC
						while diff > 1 do
							local ratio = sCol/diff
							local rate = 0
							for j=#col,1,-1 do
								if rate >= ratio then
									table.remove(col, j)
									diff = diff-1
									rate = rate-ratio
								end
								rate = rate+1
							end
							sCol = #col
							diff = sCol-self.planetC
						end
						if diff == 1 then table.remove(col, #col) end
					end
				end

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
					if nameLen+1 > tColWidths[tColCount] then tColWidths[tColCount] = nameLen+1 end
					if rulerLen+1 > tColWidths[tColCount] then tColWidths[tColCount] = rulerLen+1 end
				end
				local colSum = 2
				local margin = self.planetC+2 -- Our legend has two pixels of horiz. padding from the map.
				for i=1,#tCols do colSum = colSum+20+(tColWidths[i]*6) end -- The total width of all columns of text in the legend is (10 total pixels of padding+the max character length*8 pixels per character) per column.
				local extended = {}
				for i=1,columnCount do
					extended[(i*2)-1] = {}
					extended[i*2] = {}
					for j=1,self.planetC+colSum do if self.stretched[i][j] then
						extended[(i*2)-1][(j*2)-1] = {self.stretched[i][j][1], self.stretched[i][j][2], self.stretched[i][j][3]}
						extended[(i*2)-1][j*2] = {self.stretched[i][j][1], self.stretched[i][j][2], self.stretched[i][j][3]}
						extended[i*2][(j*2)-1] = {self.stretched[i][j][1], self.stretched[i][j][2], self.stretched[i][j][3]}
						extended[i*2][j*2] = {self.stretched[i][j][1], self.stretched[i][j][2], self.stretched[i][j][3]}
					else
						extended[(i*2)-1][(j*2)-1] = {0, 0, 0}
						extended[(i*2)-1][j*2] = {0, 0, 0}
						extended[i*2][(j*2)-1] = {0, 0, 0}
						extended[i*2][j*2] = {0, 0, 0}
					end end
				end
				local cAdded = 2
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
							for k=margin,margin+7 do for l=top,bottom do
								if not extended[(l*2)-1] then extended[(l*2)-1] = {} end
								if not extended[l*2] then extended[l*2] = {} end
								extended[(l*2)-1][(k*2)-1] = {tColor[1], tColor[2], tColor[3]}
								extended[(l*2)-1][k*2] = {tColor[1], tColor[2], tColor[3]}
								extended[l*2][(k*2)-1] = {tColor[1], tColor[2], tColor[3]}
								extended[l*2][k*2] = {tColor[1], tColor[2], tColor[3]}
							end end -- Define a square of color 8 pixels wide and tall, indicating the color of this country on the map.
							margin = margin+10 -- Move to the right of this square, leaving 10-8=2 pixels of padding.
							for k=1,nameLen do -- For each character...
								local letter = name:sub(k, k):lower() -- CCSCommon.glyphs has keys in lowercase.
								local glyph = parent.glyphs[letter]
								if not glyph then glyph = parent.glyphs[" "] end -- If there's a character not in our array, leave it as a blank space. Better than a nil exception.
								local letterRow = 1
								local letterColumn = 1
								-- The glyph is itself a 2D matrix of monochrome pixel values-0 for black, 1 for white.
								-- Our vertical line height is 8 pixels, and each glyph is 6x6 pixels for a single pixel of padding between characters and three pixels between lines (we will later shift ten pixels down when moving lines).
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
									letterColumn = 1 -- Move back to the far left.
									letterRow = letterRow+1 -- Move down. Quite like a CR+LF.
								end
								margin = margin+6 -- Move to the last pixel of the last character. With our one pixel of padding on all sides, this will leave the appropriate space between letters.
							end
							margin = colMargin -- Just like when writing a single glyph matrix, here is our CR+LF for the entire line. Revert to the start of the line...
							top = top+10
							bottom = bottom+10 -- And move one line down, leaving two pixels of space.
							for k=margin,margin+7 do for l=top-2,bottom do
								if not extended[(l*2)-1] then extended[(l*2)-1] = {} end
								if not extended[l*2] then extended[l*2] = {} end
								extended[(l*2)-1][(k*2)-1] = {tColor[1], tColor[2], tColor[3]}
								extended[(l*2)-1][k*2] = {tColor[1], tColor[2], tColor[3]}
								extended[l*2][(k*2)-1] = {tColor[1], tColor[2], tColor[3]}
								extended[l*2][k*2] = {tColor[1], tColor[2], tColor[3]}
							end end -- Turn our previous square of color into a two-line-tall rectangle, for the line with this country's current ruler.
							margin = margin+14 -- As before, move to the right, but this time leave 6 pixels of padding for an indent.
							for k=1,rulerLen do
								local letter = tRuler:sub(k, k):lower()
								local glyph = parent.glyphs[letter]
								if not glyph then glyph = parent.glyphs[" "] end
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
					cAdded = cAdded+20+(tColWidths[i]*6)
					top = 2
					bottom = 9 -- And begin at the top left anew.
				end

				local totalC = (self.planetC+cAdded)*2 -- Account for the addition of the legend in our bitmap dimensions.
				self.planetD = columnCount*2 -- Whereas the planet's circumference defines our map's width, its diameter will define its height (since we don't need to distort the height when unwrapping).

				local bf = io.open(label..".bmp", "w+b")
				local bmpArr = { 0x42, 0x4D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13, 0x0B, 0x00, 0x00, 0x13, 0x0B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }
				local hStringLE = string.format("%.8x", self.planetD)
				local wStringLE = string.format("%.8x", totalC)
				local rStringLE = ""
				local sStringLE = ""
				local hArr = {}
				local wArr = {}
				local rArr = {}
				local sArr = {}
				for x in hStringLE:gmatch("%w%w") do table.insert(hArr, tonumber(x, 16)) end
				for x in wStringLE:gmatch("%w%w") do table.insert(wArr, tonumber(x, 16)) end

				local byteCount = 0
				for y=self.planetD,1,-1 do
					local btWritten = 0
					for x=1,totalC do
						btWritten = btWritten+3
						byteCount = byteCount+3
					end
					while math.fmod(btWritten, 4) ~= 0 do
						btWritten = btWritten+1
						byteCount = byteCount+1
					end
				end

				rStringLE = string.format("%.8x", byteCount)
				sStringLE = string.format("%.8x", byteCount+54)
				for x in rStringLE:gmatch("%w%w") do table.insert(rArr, tonumber(x, 16)) end
				for x in sStringLE:gmatch("%w%w") do table.insert(sArr, tonumber(x, 16)) end
				
				for i=1,4 do bmpArr[i+2] = sArr[5-i] end
				for i=1,4 do bmpArr[i+18] = wArr[5-i] end
				for i=1,4 do bmpArr[i+22] = hArr[5-i] end
				for i=1,4 do bmpArr[i+34] = rArr[5-i] end
				for i=1,#bmpArr do bf:write(string.char(bmpArr[i])) end

				for y=self.planetD,1,-1 do
					local btWritten = 0
					for x=1,totalC do
						if extended[y] and extended[y][x] then
							if extended[y][x][3] then bf:write(string.char(extended[y][x][3])) else bf:write(string.char(0)) end
							if extended[y][x][2] then bf:write(string.char(extended[y][x][2])) else bf:write(string.char(0)) end
							if extended[y][x][1] then bf:write(string.char(extended[y][x][1])) else bf:write(string.char(0)) end
						else
							bf:write(string.char(0))
							bf:write(string.char(0))
							bf:write(string.char(0))
						end
						btWritten = btWritten+3
					end
					while math.fmod(btWritten, 4) ~= 0 do
						bf:write(string.char(0))
						btWritten = btWritten+1
					end
					bf:flush()
				end

				bf:close()
				bf = nil
				
				parent:deepnil(sArr)
				parent:deepnil(wArr)
				parent:deepnil(hArr)
				parent:deepnil(rArr)
				parent:deepnil(bmpArr)
				parent:deepnil(colors)
				parent:deepnil(colorKeys)
				parent:deepnil(extended)
				parent:deepnil(tCols)
				parent:deepnil(tColWidths)
				parent:deepnil(bmpString)
				parent:deepnil(bmpDataString)
			end,

			
			unwrap = function(self)
				local p = 1
				local q = -self.planetR
				local r = -self.planetR
				local quad = 1
				local vox = false
				local iColumn = 1
				while r <= self.planetR do
					if self.planet[p] and self.planet[p][q] and self.planet[p][q][r] and not self.planet[p][q][r].mapWritten then
						while not self.unwrapped[iColumn] do table.insert(self.unwrapped, {}) end
						table.insert(self.unwrapped[iColumn], {p, q, r})
						self.planet[p][q][r].mapWritten = true
						vox = true
					end
					if quad == 1 then
						q = q+1
						if q > 0 then
							q = -self.planetR
							p = p+1
						end
					elseif quad == 2 then
						p = p-1
						if p < 0 then
							p = self.planetR
							q = q+1
						end
					elseif quad == 3 then
						q = q-1
						if q < 0 then
							q = self.planetR
							p = p-1
						end
					elseif quad == 4 then
						p = p+1
						if p > 0 then
							p = -self.planetR
							q = q-1
						end
					end
					vox = false
					if quad == 1 and p > self.planetR then
						quad = 2
						p = self.planetR
						q = 1
					elseif quad == 2 and q > self.planetR then
						quad = 3
						p = -1
						q = self.planetR
					elseif quad == 3 and p < -self.planetR then
						quad = 4
						p = -self.planetR
						q = -1
					elseif quad == 4 and q < -self.planetR then
						quad = 1
						p = 1
						q = -self.planetR
						r = r+1
						iColumn = iColumn+1
					end
				end

				for i=-self.planetR,self.planetR,1 do if self.planet[i] then for j=-self.planetR,self.planetR,1 do if self.planet[i][j] then for k=-self.planetR,self.planetR,1 do if self.planet[i][j][k] then self.planet[i][j][k].mapWritten = false end end end end end end
			end,

			update = function(self, parent)
				parent.numCountries = 0
				for i, j in pairs(self.countries) do parent.numCountries = parent.numCountries+1 end
				for i, j in pairs(parent.debugTimes) do parent.debugTimes[i] = 0 end

				local f0 = _time()

				self.gPop = 0

				if self.initialState then
					parent.iSCount = parent.numCountries
					parent.iSIndex = 1
					UI:printf("Constructing initial populations...")
				end

				for i, cp in pairs(self.countries) do if cp then
					if self.initialState then
						UI:printl(string.format("Country %d/%d", parent.iSIndex, parent.iSCount))
						parent.iSIndex = parent.iSIndex+1
					end
					cp:update(parent)

					if cp.population < 20 then
						cp:event(parent, "Disappeared")
						for j=1,#parent.c_events do if parent.c_events[j].name == "Conquer" then cp:triggerEvent(parent, j, true) end end
					end

					local defCount = 0
					for j=#cp.events,1,-1 do if cp.events[j].Year >= parent.years-20 and cp.events[j].Event:match("Defeat in war") then defCount = defCount+1 end end
					if defCount > 3 then
						local lastDef = ""
						for j=1,#cp.events do if cp.events[j].Event:match("Defeat in war") then lastDef = cp.events[j].Event:gsub("Defeat in war with ", "") end end
						for j, k in pairs(self.countries) do if k.name == lastDef then for j=1,#parent.c_events do if parent.c_events[j].name == "Conquer" then cp:triggerEvent(parent, j) end end end end
					end
				end end

				self.initialState = false

				for i, cp in pairs(self.countries) do if cp then cp:eventloop(parent) end end
				for i, cp in pairs(self.countries) do if cp then self.gPop = self.gPop+cp.population end end

				local f1 = _time()-f0

				if parent.years > parent.startyear+1 then
					if _DEBUG then parent.popLimit = 150
					else
						if f1 > 0.5 then
							if parent.popLimit > 1500 then parent.popLimit = math.floor(parent.popLimit-(50*(f1-0.5))) end

							if parent.popLimit < 1500 then parent.popLimit = 1500 end
							if f1 > 2 then parent.disabled["independence"] = true else parent.disabled["independence"] = false end
						else
							if parent.popLimit < 3500 then parent.popLimit = math.ceil(parent.popLimit+(50*(0.5-f1))) end
							if parent.popLimit > 3500 then parent.popLimit = 3500 end
						end
					end
				end

				local f2 = _time()
				if math.fmod(parent.years, 35) == 0 then collectgarbage() end
				local f3 = _time()
				parent.debugTimes["GARBAGE"] = f3-f2
				parent.debugTimes["TOTAL"] = f3-f0
			end
		}

		World.__index = World
		World.__call = function() return World:new() end

		return World
	end
