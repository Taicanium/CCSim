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
				nm.gPop = 0
				nm.mtname = "World"
				nm.planet = {}
				nm.planetdefined = {}
				nm.planetR = 0

				return nm
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
							local fsqrt = math.sqrt(math.pow(x, 2)+math.pow(y, 2)+math.pow(z, 2))
							if fsqrt < bRad+0.5 and fsqrt > bRad-0.5 then
								if not bench[x] then bench[x] = {} end
								if not bench[x][y] then bench[x][y] = {} end
								bench[x][y][z] = {}
							end
							bdone = bdone+1
							if math.fmod(bdone, 10000) == 0 then printl(parent.stdscr, "%.2f%% done", (bdone/math.pow((bRad*2)+1, 3)*10000)/100) end
						end
					end
				end

				local benchAdjust = math.floor(_time()-t0)
				if benchAdjust > 50 then benchAdjust = 50 end

				self.planetR = math.floor(math.random(100-benchAdjust, 125-benchAdjust))

				printf(parent.stdscr, "Constructing voxel planet with radius of %d units...", self.planetR)

				local rdone = 0

				for x=-self.planetR,self.planetR do
					for y=-self.planetR,self.planetR do
						for z=-self.planetR,self.planetR do
							local fsqrt = math.sqrt(math.pow(x, 2)+math.pow(y, 2)+math.pow(z, 2))
							if fsqrt < self.planetR+0.5 and fsqrt > self.planetR-0.5 then
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
							if math.fmod(rdone, 10000) == 0 then printl(parent.stdscr, "%.2f%% done", (rdone/math.pow((self.planetR*2)+1, 3)*10000)/100) end
						end
					end
				end

				local planetSize = #self.planetdefined

				for i=1,planetSize do
					local x, y, z = table.unpack(self.planetdefined[i])

					for dx=-1,1 do if self.planet[x-dx] then for dy=-1,1 do if self.planet[x-dx][y-dy] then for dz=-1,1 do if dx ~= 0 or dy ~= 0 or dz ~= 0 then if self.planet[x-dx][y-dy][z-dz] then table.insert(self.planet[x][y][z].neighbors, {x-dx, y-dy, z-dz}) end end end end end end end
				end

				printf(parent.stdscr, "Defining land masses...")

				local maxLand = math.random(math.floor(planetSize/2.85), math.ceil(planetSize/2))
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
							if not self.planet[nx][ny][nz].land and math.random(1, 14) == math.random(1, 14) then
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

					if math.fmod(doneLand, 100) == 0 then printl(parent.stdscr, "%.2f%% done", (doneLand/maxLand*10000)/100) end
				end

				for i=1,planetSize do
					local x, y, z = table.unpack(self.planetdefined[i])

					self.planet[x][y][z].neighbors = {}

					for dx=-1,1 do if self.planet[x-dx] then for dy=-1,1 do if self.planet[x-dx][y-dy] then for dz=-1,1 do if dx ~= 0 or dy ~= 0 or dz ~= 0 then if self.planet[x-dx][y-dy][z-dz] then table.insert(self.planet[x][y][z].neighbors, {x-dx, y-dy, z-dz}) end end end end end end end
				end

				printf(parent.stdscr, "Rooting countries...")
				local ci = 1

				for i, cp in pairs(self.countries) do
					printl(parent.stdscr, "Country %d/%d", ci, parent.numCountries)
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
				end

				printf(parent.stdscr, "Setting territories...")

				local allDefined = false
				local defined = 0
				local prevDefined = 0
				ci = 1

				while not allDefined do
					allDefined = true
					defined = 0

					for i=1,planetSize do
						local x, y, z = table.unpack(self.planetdefined[i])

						if self.planet[x][y][z].land and self.planet[x][y][z].country ~= "" and not self.planet[x][y][z].countryset then
							for j=1,#self.planet[x][y][z].neighbors do
								local neighbor = self.planet[x][y][z].neighbors[j]
								local nx, ny, nz = table.unpack(neighbor)
								if self.planet[nx][ny][nz].land and self.planet[nx][ny][nz].country == "" then
									if not self.planet[nx][ny][nz].countryset then
										self.planet[nx][ny][nz].country = self.planet[x][y][z].country
										self.planet[nx][ny][nz].countryset = true
									end
								end
							end
						end
					end

					for i=1,planetSize do
						local x, y, z = table.unpack(self.planetdefined[i])

						if self.planet[x][y][z].country ~= "" or not self.planet[x][y][z].land then defined = defined+1 else allDefined = false end
						self.planet[x][y][z].countryset = false
					end

					if defined == prevDefined then allDefined = true end
					prevDefined = defined

					printl(parent.stdscr, "%.2f%% done", (defined/planetSize*10000)/100)
				end

				for i=1,planetSize do
					local x, y, z = table.unpack(self.planetdefined[i])

					if self.planet[x][y][z].country == "" then self.planet[x][y][z].land = false end
				end

				printf(parent.stdscr, "Defining regional boundaries...")

				for i, cp in pairs(self.countries) do
					printl(parent.stdscr, "Country %d/%d", ci, parent.numCountries)
					ci = ci+1
					cp:setTerritory(parent)
				end
				
				parent.stamp = tostring(math.floor(_time()))

				for i, j in pairs(parent.c_events) do
					parent.disabled[j.name:lower()] = false
					parent.disabled["!"..j.name:lower()] = false
				end
				
				if parent.clrcmd == "cls" then parent.dirSeparator = "\\" end
				local mapDir = parent:directory({parent.stamp, "maps"})
				
				if lfsstatus then
					lfs.mkdir(parent.stamp)
					if parent.doMaps then lfs.mkdir(mapDir) end
				else
					os.execute("mkdir "..parent.stamp)
					if parent.doMaps then os.execute("mkdir "..mapDir) end
				end

				self:rOutput(parent, parent:directory({mapDir, "initial"}))
			end,

			delete = function(self, parent, nz)
				if not nz then return end

				self.cColors[nz.name] = nil
				self.cTriplets[nz.name] = nil
				self.countries[nz.name] = nil

				nz:destroy(parent)

				parent.numCountries = parent.numCountries-1
			end,

			destroy = function(self)
				for i, cp in pairs(self.countries) do
					cp:destroy(parent)
					cp = nil
				end
			end,

			rOutput = function(self, parent, label)
				printf(parent.stdscr, "Writing R data...")

				local f = io.open(label..".r", "w+")
				if not f then return end
				f:write("library(\"rgl\")\nlibrary(\"car\")\ncs <- c(")

				local planetSize = #self.planetdefined

				for i=1,planetSize do
					local x, y, z = table.unpack(self.planetdefined[i])
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
						for l, m in pairs(k.cities) do if m.name == cp.capitalcity and m.x and m.y and m.z then
							table.insert(cCoords, {m.x, m.y, m.z})
							table.insert(cTexts, m.name)
						end end
					end
				end

				for i=1,planetSize,2000 do
					if i < planetSize-2000 then
						f:write(")\nx <- c(")

						for j=i,i+1999 do
							local x, y, z = table.unpack(self.planetdefined[j])
							if not self.planet[x][y][z].land then x = x-(math.sin(math.rad((self.planetdefined[j][1]/self.planetR)*90))*1.4) end
							f:write(x)
							if j < i+1999 then f:write(", ") end
						end

						f:write(")\ny <- c(")

						for j=i,i+1999 do
							local x, y, z = table.unpack(self.planetdefined[j])
							if not self.planet[x][y][z].land then y = y-(math.sin(math.rad((self.planetdefined[j][2]/self.planetR)*90))*1.4) end
							f:write(y)
							if j < i+1999 then f:write(", ") end
						end

						f:write(")\nz <- c(")

						for j=i,i+1999 do
							local x, y, z = table.unpack(self.planetdefined[j])
							if not self.planet[x][y][z].land then z = z-(math.sin(math.rad((self.planetdefined[j][3]/self.planetR)*90))*1.4) end
							f:write(z)
							if j < i+1999 then f:write(", ") end
						end

						f:write(")\ncsc <- c(")

						for j=i,i+1999 do
							local x, y, z = table.unpack(self.planetdefined[j])
							local isCity = false
							for j=1,#cCoords do if x == cCoords[j][1] and y == cCoords[j][2] and z == cCoords[j][3] then isCity = true end end
							if isCity then f:write("\"#888888\"") else
								if self.planet[x][y][z].land then
									if self.planet[x][y][z].country ~= "" and self.cColors[self.planet[x][y][z].country] then f:write("\""..self.cColors[self.planet[x][y][z].country].."\"") else f:write("\"#1616AA\"") end
								else f:write("\"#1616AA\"") end
							end
							if j < i+1999 then f:write(", ") end
						end
					else
						f:write(")\nx <- c(")

						for j=i,planetSize do
							local x, y, z = table.unpack(self.planetdefined[j])
							if not self.planet[x][y][z].land then x = x-(math.sin(math.rad((self.planetdefined[j][1]/self.planetR)*90))*1.4) end
							f:write(x)
							if j < planetSize then f:write(", ") end
						end

						f:write(")\ny <- c(")

						for j=i,planetSize do
							local x, y, z = table.unpack(self.planetdefined[j])
							if not self.planet[x][y][z].land then y = y-(math.sin(math.rad((self.planetdefined[j][2]/self.planetR)*90))*1.4) end
							f:write(y)
							if j < planetSize then f:write(", ") end
						end

						f:write(")\nz <- c(")

						for j=i,planetSize do
							local x, y, z = table.unpack(self.planetdefined[j])
							if not self.planet[x][y][z].land then z = z-(math.sin(math.rad((self.planetdefined[j][3]/self.planetR)*90))*1.4) end
							f:write(z)
							if j < planetSize then f:write(", ") end
						end

						f:write(")\ncsc <- c(")

						for j=i,planetSize do
							local x, y, z = table.unpack(self.planetdefined[j])
							local isCity = false
							for j=1,#cCoords do if x == cCoords[j][1] and y == cCoords[j][2] and z == cCoords[j][3] then isCity = true end end
							if isCity then f:write("\"#888888\"") else
								if self.planet[x][y][z].land then
									if self.planet[x][y][z].country ~= "" and self.cColors[self.planet[x][y][z].country] then f:write("\""..self.cColors[self.planet[x][y][z].country].."\"") else f:write("\"#1616AA\"") end
								else f:write("\"#1616AA\"") end
							end
							if j < planetSize then f:write(", ") end
						end
					end

					f:write(")\nspheres3d(x=x, y=y, z=z, col=csc, size=0.4, xlab=\"\", ylab=\"\", zlab=\"\", box=FALSE, axes=FALSE, top=TRUE, add=TRUE, plot=FALSE")
				end

				f:write(")\ncityx <- c(")

				for i=1,#cCoords do
					local x, y, z = table.unpack(cCoords[i])

					local xChange = x
					local yChange = y
					local zChange = z

					local ratio = math.sqrt(math.pow(xChange, 2)+math.pow(yChange, 2)+math.pow(zChange, 2))

					while ratio < self.planetR+12 do
						xChange = xChange+(x*0.001)
						yChange = yChange+(y*0.001)
						zChange = zChange+(z*0.001)

						ratio = math.sqrt(math.pow(xChange, 2)+math.pow(yChange, 2)+math.pow(zChange, 2))
					end

					cCoords[i][1] = xChange-math.fmod(xChange, 0.001)
					cCoords[i][2] = yChange-math.fmod(yChange, 0.001)
					cCoords[i][3] = zChange-math.fmod(zChange, 0.001)

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

				f:write(")\ntexts3d(x=cityx, y=cityy, z=cityz, texts=citytexts, color=\"#FFFFFF\", cex=0.75, font=1)\n")

				local ccs = {}
				local css = {}
				local cst = {}
				local csx = {}
				local csy = {}
				local csz = {}

				for i, cp in pairs(self.countries) do
					local avgX = 0
					local avgY = 0
					local avgZ = 0

					for j=1,#cp.nodes do
						avgX = avgX+cp.nodes[j][1]
						avgY = avgY+cp.nodes[j][2]
						avgZ = avgZ+cp.nodes[j][3]
					end

					avgX = avgX/#cp.nodes
					avgY = avgY/#cp.nodes
					avgZ = avgZ/#cp.nodes

					local xChange = avgX
					local yChange = avgY
					local zChange = avgZ

					local ratio = math.sqrt(math.pow(xChange, 2)+math.pow(yChange, 2)+math.pow(zChange, 2))

					while ratio < self.planetR+24 do
						xChange = xChange+(avgX*0.001)
						yChange = yChange+(avgY*0.001)
						zChange = zChange+(avgZ*0.001)

						ratio = math.sqrt(math.pow(xChange, 2)+math.pow(yChange, 2)+math.pow(zChange, 2))
					end

					local rh = 255-self.cTriplets[cp.name][1]
					local gh = 255-self.cTriplets[cp.name][2]
					local bh = 255-self.cTriplets[cp.name][3]
					local invTrip = string.format("#%.2x%.2x%.2x", rh, gh, bh)

					local cex = 0.5 + (#cp.nodes/8000)
					cex = cex - math.fmod(cex, 0.1)

					table.insert(cst, cp.name)
					table.insert(ccs, invTrip)
					table.insert(css, cex)
					table.insert(csx, xChange-math.fmod(xChange, 0.001))
					table.insert(csy, yChange-math.fmod(yChange, 0.001))
					table.insert(csz, zChange-math.fmod(zChange, 0.001))
				end

				f:write("cst <- c(")

				for i=1,#cst do
					f:write("\""..cst[i].."\"")
					if i < #cst then f:write(", ") end
				end

				f:write(")\nccs <- c(")

				for i=1,#ccs do
					f:write("\""..ccs[i].."\"")
					if i < #ccs then f:write(", ") end
				end

				f:write(")\ncss <- c(")

				for i=1,#css do
					f:write(css[i])
					if i < #css then f:write(", ") end
				end

				f:write(")\ncsx <- c(")

				for i=1,#csx do
					f:write(csx[i])
					if i < #csx then f:write(", ") end
				end

				f:write(")\ncsy <- c(")

				for i=1,#csy do
					f:write(csy[i])
					if i < #csy then f:write(", ") end
				end

				f:write(")\ncsz <- c(")

				for i=1,#csz do
					f:write(csz[i])
					if i < #csz then f:write(", ") end
				end

				f:write(")\ntexts3d(x=csx, y=csy, z=csz, texts=cst, color=ccs, cex=css, font=2)\nif (interactive() == FALSE) { Sys.sleep(10000) }")

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
						cp:event(parent, "Disappeared")
						for j=1,#parent.c_events do if parent.c_events[j].name == "Conquer" then cp:triggerEvent(parent, j, true) end end
					end
				end end

				self.gPop = 0

				for i, cp in pairs(self.countries) do if cp then cp:update(parent) end end
				for i, cp in pairs(self.countries) do if cp then cp:eventloop(parent) end end
				for i, cp in pairs(self.countries) do if cp then self.gPop = self.gPop+cp.population end end

				local f1 = _time()-f0

				if parent.years > parent.startyear+1 then
					if f1 > 0.7 then
						if parent.popLimit > 1500 then parent.popLimit = math.floor(parent.popLimit-(50*(f1*2))) end

						if parent.popLimit < 1500 then parent.popLimit = 1500 end
						if f1 > 1.4 then parent.disabled["independence"] = true else parent.disabled["independence"] = false end
					else
						if parent.popLimit < 3500 then parent.popLimit = math.ceil(parent.popLimit+(50*(f1*2))) end
						if parent.popLimit > 3500 then parent.popLimit = 3500 end
					end
				end

				parent.debugTimes["TOTAL"] = {f1, 1}
			end
		}

		World.__index = World
		World.__call = function() return World:new() end

		return World
	end