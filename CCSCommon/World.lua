torchstatus, torch = pcall(require, "torch")
jsonstatus, json = pcall(require, "cjson")

return
	function()
		local World = {
			new = function(self)
				local nm = {}
				setmetatable(nm, self)

				nm.countries = {}
				nm.cColors = {}
				nm.cTriplets = {}
				nm.fromFile = false
				nm.mtname = "World"
				nm.planet = {}
				nm.planetdefined = {}
				nm.planetR = 0

				return nm
			end,

			destroy = function(self)
				for i, cp in pairs(self.countries) do
					cp:destroy(parent)
					cp = nil
				end
			end,

			add = function(self, nd)
				self.countries[nd.name] = nd
			end,

			constructVoxelPlanet = function(self, parent)
				parent:rseed()

				printf(parent.stdscr, "Benchmarking...")
				local bRad = 175
				local bench = {}

				local t0 = _time()
				local bdone = 0

				for x=-bRad,bRad do
					for y=-bRad,bRad do
						for z=-bRad,bRad do
							fsqrt = math.sqrt(math.pow(x, 2)+math.pow(y, 2)+math.pow(z, 2))
							if fsqrt < bRad+0.5 and fsqrt > bRad-0.5 then
								if not bench[x] then bench[x] = {} end
								if not bench[x][y] then bench[x][y] = {} end
								bench[x][y][z] = {}
							end
							bdone = bdone+1
							if math.fmod(bdone, 10000) == 0 then printl(parent.stdscr, "%.2f%% done", ((bdone/math.pow((bRad*2)+1, 3)*10000)/100)) end
						end
					end
				end

				local benchAdjust = math.floor(_time()-t0)
				if benchAdjust > 50 then benchAdjust = 50 end

				local r = math.floor(math.random(100-benchAdjust, 125-benchAdjust))
				self.planetR = r

				printf(parent.stdscr, "\nConstructing voxel planet with radius of %d units...", r)

				local rdone = 0

				for x=-r,r do
					for y=-r,r do
						for z=-r,r do
							fsqrt = math.sqrt(math.pow(x, 2)+math.pow(y, 2)+math.pow(z, 2))
							if fsqrt < r+0.5 and fsqrt > r-0.5 then
								if not self.planet[x] then self.planet[x] = {} end
								if not self.planet[x][y] then self.planet[x][y] = {} end
								self.planet[x][y][z] = {}
								self.planet[x][y][z].x = x
								self.planet[x][y][z].y = y
								self.planet[x][y][z].z = z
								self.planet[x][y][z].country = ""
								self.planet[x][y][z].countryset = false
								self.planet[x][y][z].region = ""
								self.planet[x][y][z].regionset = false
								self.planet[x][y][z].city = ""
								self.planet[x][y][z].land = false
								self.planet[x][y][z].waterNeighbors = true
								self.planet[x][y][z].neighbors = {}

								table.insert(self.planetdefined, {x, y, z})
							end
							rdone = rdone+1
							if math.fmod(rdone, 10000) == 0 then printl(parent.stdscr, "%.2f%% done", ((rdone/math.pow((r*2)+1, 3)*10000)/100)) end
						end
					end
				end

				local planetSize = #self.planetdefined

				printf(parent.stdscr, "")

				for i=1,planetSize do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]

					for dx=-1,1 do if self.planet[x-dx] then for dy=-1,1 do if self.planet[x-dx][y-dy] then for dz=-1,1 do if dx ~= 0 or dy ~= 0 or dz ~= 0 then if self.planet[x-dx][y-dy][z-dz] then table.insert(self.planet[x][y][z].neighbors, {x-dx, y-dy, z-dz}) end end end end end end end
				end

				printf(parent.stdscr, "Defining land masses...")

				local maxLand = math.random(math.floor(planetSize/2.75), math.ceil(planetSize/2))
				local continents = math.random(10, 15)
				local freeNodes = {}
				for i=1,continents do
					local located = true

					local cSeed = parent:randomChoice(self.planetdefined)

					local x = cSeed[1]
					local y = cSeed[2]
					local z = cSeed[3]

					if self.planet[x][y][z].land then located = false end
					while not located do
						cSeed = parent:randomChoice(self.planetdefined)

						x = cSeed[1]
						y = cSeed[2]
						z = cSeed[3]

						located = true
						if self.planet[x][y][z].land then located = false end
					end

					self.planet[x][y][z].land = true
					table.insert(freeNodes, {x, y, z})
				end
				local doneLand = continents
				while doneLand < maxLand do
					local node = math.random(1, #freeNodes)

					local x = freeNodes[node][1]
					local y = freeNodes[node][2]
					local z = freeNodes[node][3]

					while not self.planet[x][y][z].waterNeighbors do
						table.remove(freeNodes, node)
						
						node = math.random(1, #freeNodes)

						x = freeNodes[node][1]
						y = freeNodes[node][2]
						z = freeNodes[node][3]
					end

					if math.random(1, 10) == math.random(1, 10) then
						for neighbor=1,#self.planet[x][y][z].neighbors do if math.random(1, 4) == 4 then
							local nx = self.planet[x][y][z].neighbors[neighbor][1]
							local ny = self.planet[x][y][z].neighbors[neighbor][2]
							local nz = self.planet[x][y][z].neighbors[neighbor][3]
							if not self.planet[nx][ny][nz].land then
								self.planet[nx][ny][nz].land = true
								doneLand = doneLand+1
								self.planet[nx][ny][nz].waterNeighbors = false
								for i, j in pairs(self.planet[nx][ny][nz].neighbors) do
									local jx = j[1]
									local jy = j[2]
									local jz = j[3]
									if not self.planet[jx][jy][jz].land then self.planet[nx][ny][nz].waterNeighbors = true end
								end
								if self.planet[nx][ny][nz].waterNeighbors then table.insert(freeNodes, {nx, ny, nz}) end
							end
						end end
					end
					
					self.planet[x][y][z].waterNeighbors = false
					for neighbor=1,#self.planet[x][y][z].neighbors do
						local nx = self.planet[x][y][z].neighbors[neighbor][1]
						local ny = self.planet[x][y][z].neighbors[neighbor][2]
						local nz = self.planet[x][y][z].neighbors[neighbor][3]
						if not self.planet[nx][ny][nz].land then self.planet[x][y][z].waterNeighbors = true end
					end

					if math.fmod(doneLand, 100) == 0 then printl(parent.stdscr, "%.2f%% done", ((doneLand/maxLand*10000)/100)) end
				end

				for i=1,planetSize do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]

					self.planet[x][y][z].neighbors = {}

					for dx=-1,1 do if self.planet[x-dx] then for dy=-1,1 do if self.planet[x-dx][y-dy] then for dz=-1,1 do if dx ~= 0 or dy ~= 0 or dz ~= 0 then if self.planet[x-dx][y-dy][z-dz] then table.insert(self.planet[x][y][z].neighbors, {x-dx, y-dy, z-dz}) end end end end end end end
				end

				printf(parent.stdscr, "\nRooting countries...")

				for i, cp in pairs(self.countries) do
					local located = true

					local rnd = parent:randomChoice(self.planetdefined)

					local x = rnd[1]
					local y = rnd[2]
					local z = rnd[3]

					if self.planet[x][y][z].country ~= "" or not self.planet[x][y][z].land then located = false end
					while not located do
						rnd = parent:randomChoice(self.planetdefined)

						x = rnd[1]
						y = rnd[2]
						z = rnd[3]

						located = true
						if self.planet[x][y][z].country ~= "" or not self.planet[x][y][z].land then located = false end
					end

					self.planet[x][y][z].country = cp.name
				end

				printf(parent.stdscr, "Setting territories...")

				local allDefined = false
				local defined = 0

				while not allDefined do
					allDefined = true
					defined = 0

					for i=1,planetSize do
						local x = self.planetdefined[i][1]
						local y = self.planetdefined[i][2]
						local z = self.planetdefined[i][3]

						if self.planet[x][y][z].land then
							if self.planet[x][y][z].country ~= "" then
								if not self.planet[x][y][z].countryset then
									for j=1,#self.planet[x][y][z].neighbors do
										local neighbor = self.planet[x][y][z].neighbors[j]
										local nx = neighbor[1]
										local ny = neighbor[2]
										local nz = neighbor[3]
										if self.planet[nx][ny][nz].land then
											if self.planet[nx][ny][nz].country == "" then
												allDefined = false
												if not self.planet[nx][ny][nz].countryset then
													self.planet[nx][ny][nz].country = self.planet[x][y][z].country
													self.planet[nx][ny][nz].countryset = true
												end
											end
										end
									end
								end
							end
						end
					end

					for i=1,planetSize do
						local x = self.planetdefined[i][1]
						local y = self.planetdefined[i][2]
						local z = self.planetdefined[i][3]

						if self.planet[x][y][z].country ~= "" or not self.planet[x][y][z].land then defined = defined+1 end
						self.planet[x][y][z].countryset = false
					end

					printl(parent.stdscr, "%.2f%% done", (defined/planetSize*10000)/100)
				end

				for i=1,planetSize do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]

					if self.planet[x][y][z].country == "" then self.planet[x][y][z].land = false end
				end

				printf(parent.stdscr, "\nDefining regional boundaries...")

				local ci = 1

				for i, cp in pairs(self.countries) do
					printl(parent.stdscr, "Country %d/%d", ci, parent.numCountries)
					ci = ci+1
					cp:setTerritory(parent)
				end

				self:rOutput(parent, "initial.r")
			end,

			delete = function(self, parent, nz)
				if nz then
					for i, cp in pairs(self.countries) do for j=#cp.ongoing,1 do if cp.target and cp.target.name == nz.name then table.remove(cp.ongoing, j) end end end

					self.cColors[nz.name] = nil
					self.cTriplets[nz.name] = nil
					self.countries[nz.name] = nil

					nz:destroy(parent)

					parent.numCountries = parent.numCountries-1
				end
			end,

			rOutput = function(self, parent, label)
				printf(parent.stdscr, "\nWriting R data...")

				local ci = 1

				local f = io.open(label, "w+")
				f:write("library(\"rgl\")\nlibrary(\"car\")\ncs <- c(")

				local planetSize = #self.planetdefined

				for i=1,planetSize do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]
					f:write("\""..self.planet[x][y][z].country.."\"")
					if i < planetSize then f:write(", ") end
				end

				for i, cp in pairs(self.countries) do
					if not self.cColors[cp.name] then
						local r = math.random(0, 255)
						local g = math.random(0, 255)
						local b = math.random(0, 255)

						local unique = false
						while not unique do
							unique = true
							for k, j in pairs(self.cTriplets) do
								if j[1] > r-25 and j[1] < r+25 then
									if j[2] > g-25 and j[2] < g+25 then
										if j[3] > b-25 and j[3] < b+25 then
											r = math.random(0, 255)
											g = math.random(0, 255)
											b = math.random(0, 255)

											unique = false
										end
									end
								end
							end

							if r > 225 and g > 225 and b > 225 then
								unique = false

								r = math.random(0, 255)
								g = math.random(0, 255)
								b = math.random(0, 255)
							end

							if r < 25 and g < 25 and b < 25 then
								unique = false

								r = math.random(0, 255)
								g = math.random(0, 255)
								b = math.random(0, 255)
							end
						end

						local rh = string.format("%.2x", r)
						local gh = string.format("%.2x", g)
						local bh = string.format("%.2x", b)

						self.cColors[cp.name] = "#"..rh..gh..bh
						self.cTriplets[cp.name] = {r, g, b}
					end
				end

				local cCoords = {}
				local cTexts = {}

				for i, cp in pairs(self.countries) do
					for j, k in pairs(cp.regions) do
						for l, m in pairs(k.cities) do
							table.insert(cCoords, {m.x, m.y, m.z})
							table.insert(cTexts, m.name)
						end
					end
				end
				
				for i=1,planetSize,2000 do
					if i < planetSize-2000 then
						f:write(")\nx <- c(")

						for j=i,i+1999 do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if not self.planet[x][y][z].land then x = x-(math.atan(self.planetdefined[j][1]/self.planetR)*1.65) end
							f:write(x)
							if j < i+1999 then f:write(", ") end
						end

						f:write(")\ny <- c(")

						for j=i,i+1999 do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if not self.planet[x][y][z].land then y = y-(math.atan(self.planetdefined[j][2]/self.planetR)*1.65) end
							f:write(y)
							if j < i+1999 then f:write(", ") end
						end

						f:write(")\nz <- c(")

						for j=i,i+1999 do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if not self.planet[x][y][z].land then z = z-(math.atan(self.planetdefined[j][3]/self.planetR)*1.65) end
							f:write(z)
							if j < i+1999 then f:write(", ") end
						end

						f:write(")\ncsc <- c(")

						for j=i,i+1999 do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							local isCity = false
							for j=1,#cCoords do if x == cCoords[j][1] and y == cCoords[j][2] and z == cCoords[j][3] then isCity = true end end
							if isCity then f:write("\"#888888\"") else
								if self.planet[x][y][z].land then
									if self.planet[x][y][z].country ~= "" and self.cColors[self.planet[x][y][z].country] then f:write("\""..self.cColors[self.planet[x][y][z].country].."\"") else f:write("\"#1616AA\"") end
								else f:write("\"#1616AA\"") end
							end
							if j < i+1999 then f:write(", ") end
						end

						f:write(")\nshapes <- rep(c(cube3d()), times=2000)\ninpdata <- data.frame(SHAPES=shapes, X=x, Y=y, Z=z, CSC=csc)\nshapelist3d(inpdata$SHAPES, x=inpdata$X, y=inpdata$Y, z=inpdata$Z, col=inpdata$CSC, size=0.32, xlab=\"\", ylab=\"\", zlab=\"\", box=FALSE, axes=FALSE, top=TRUE, add=TRUE, plot=FALSE")
					else
						f:write(")\nx <- c(")

						for j=i,planetSize do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if not self.planet[x][y][z].land then x = x-(math.atan(self.planetdefined[j][1]/self.planetR)*1.65) end
							f:write(x)
							if j < planetSize then f:write(", ") end
						end

						f:write(")\ny <- c(")

						for j=i,planetSize do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if not self.planet[x][y][z].land then y = y-(math.atan(self.planetdefined[j][2]/self.planetR)*1.65) end
							f:write(y)
							if j < planetSize then f:write(", ") end
						end

						f:write(")\nz <- c(")

						for j=i,planetSize do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if not self.planet[x][y][z].land then z = z-(math.atan(self.planetdefined[j][3]/self.planetR)*1.65) end
							f:write(z)
							if j < planetSize then f:write(", ") end
						end

						f:write(")\ncsc <- c(")

						for j=i,planetSize do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							local isCity = false
							for j=1,#cCoords do if x == cCoords[j][1] and y == cCoords[j][2] and z == cCoords[j][3] then isCity = true end end
							if isCity then f:write("\"#888888\"") else
								if self.planet[x][y][z].land then
									if self.planet[x][y][z].country ~= "" and self.cColors[self.planet[x][y][z].country] then f:write("\""..self.cColors[self.planet[x][y][z].country].."\"") else f:write("\"#1616AA\"") end
								else f:write("\"#1616AA\"") end
							end
							if j < planetSize then f:write(", ") end
						end
						
						f:write(")\nshapes <- rep(c(cube3d()), times="..planetSize-i+1..")\ninpdata <- data.frame(SHAPES=shapes, X=x, Y=y, Z=z, CSC=csc)\nshapelist3d(inpdata$SHAPES, x=inpdata$X, y=inpdata$Y, z=inpdata$Z, col=inpdata$CSC, size=0.32, xlab=\"\", ylab=\"\", zlab=\"\", box=FALSE, axes=FALSE, top=TRUE, add=TRUE, plot=FALSE")
					end
				end

				f:write(")\ncsd <- c(")

				for i, cp in pairs(self.countries) do
					f:write("\""..cp.name.."\"")
					if ci < parent.numCountries then f:write(", ") end
					ci = ci+1
				end

				ci = 1

				f:write(")\ncityx <- c(")

				for i=1,#cCoords do
					local x = cCoords[i][1]
					local y = cCoords[i][2]
					local z = cCoords[i][3]
					
					local xChange = x
					local yChange = y
					local zChange = z
					
					local ratio = math.sqrt(math.pow(xChange, 2)+math.pow(yChange, 2)+math.pow(zChange, 2))

					while ratio < self.planetR+8 and ratio < self.planetR+8.25 do
						xChange = xChange+math.atan(x/self.planetR)/16
						yChange = yChange+math.atan(y/self.planetR)/16
						zChange = zChange+math.atan(z/self.planetR)/16

						ratio = math.sqrt(math.pow(xChange, 2)+math.pow(yChange, 2)+math.pow(zChange, 2))
					end

					cCoords[i][1] = xChange
					cCoords[i][2] = yChange
					cCoords[i][3] = zChange
					
					f:write(x)
					if i < #cCoords then f:write(", ") end
				end

				f:write(")\ncityy <- c(")

				for i=1,#cCoords do
					local y = cCoords[i][2]
					f:write(y)
					if i < #cCoords then f:write(", ") end
				end

				f:write(")\ncityz <- c(")

				for i=1,#cCoords do
					local z = cCoords[i][3]
					f:write(z)
					if i < #cCoords then f:write(", ") end
				end

				f:write(")\ncitytexts <- c(")

				for i=1,#cTexts do
					local txt = cTexts[i]
					f:write("\""..txt.."\"")
					if i < #cTexts then f:write(", ") end
				end

				f:write(")\ntexts3d(x=cityx, y=cityy, z=cityz, texts=citytexts, color=\"#FFFFFF\", cex=0.75, font=2)")

				for i, cp in pairs(self.countries) do
					local avgX = 0
					local avgY = 0
					local avgZ = 0

					for j=1,#cp.nodes do
						avgX = avgX+cp.nodes[j][1]
						avgY = avgY+cp.nodes[j][2]
						avgZ = avgZ+cp.nodes[j][3]
					end

					avgX = math.floor(avgX/#cp.nodes)
					avgY = math.floor(avgY/#cp.nodes)
					avgZ = math.floor(avgZ/#cp.nodes)

					local xChange = avgX
					local yChange = avgY
					local zChange = avgZ

					local ratio = math.sqrt(math.pow(xChange, 2)+math.pow(yChange, 2)+math.pow(zChange, 2))

					while ratio < self.planetR+24 and ratio < self.planetR+24.25 do
						xChange = xChange+math.atan(avgX/self.planetR)/16
						yChange = yChange+math.atan(avgY/self.planetR)/16
						zChange = zChange+math.atan(avgZ/self.planetR)/16

						ratio = math.sqrt(math.pow(xChange, 2)+math.pow(yChange, 2)+math.pow(zChange, 2))
					end

					f:write("\ntext3d(x="..tostring(xChange)..", y="..tostring(yChange)..", z="..tostring(zChange)..", text=\""..cp.name.."\", color=\""..self.cColors[cp.name].."\", cex=1.1, font=2)")
				end

				f:write("\nif (interactive() == FALSE) { Sys.sleep(10000) }")

				f:flush()
				f:close()
				f = nil
			end,

			update = function(self, parent)
				parent.numCountries = 0
				for i, cp in pairs(self.countries) do parent.numCountries = parent.numCountries+1 end

				local f0 = _time()

				for i, cp in pairs(self.countries) do if cp then
					if cp.population < 10 then
						if cp.rulers[#cp.rulers].To == "Current" then cp.rulers[#cp.rulers].To = parent.years end
						cp:event(parent, "Disappeared")
						for i=#self.people,1,-1 do parent:randomChoice(parent.thisWorld.countries):add(parent, self.people[i]) end
						self:delete(parent, cp)
					end
				end end
				for i, cp in pairs(self.countries) do if cp then cp:update(parent) end end
				for i, cp in pairs(self.countries) do if cp then cp:eventloop(parent) end end

				local f1 = _time()-f0

				if parent.years > parent.startyear+1 then
					if f1 > 0.7 then
						if parent.popLimit > 1500 then parent.popLimit = math.floor(parent.popLimit-(50*(f1*2))) end

						if parent.popLimit < 1500 then parent.popLimit = 1500 end
						if parent.numCountries >= 9 then parent.disabled["independence"] = true else parent.disabled["independence"] = false end
					else
						if parent.popLimit < 3500 then parent.popLimit = math.ceil(parent.popLimit+(50*(f1*2))) end
						if parent.popLimit > 3500 then parent.popLimit = 3500 end
					end
				end
			end
		}

		World.__call = function() return World:new() end
		World.__index = World

		return World
	end