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
				nm.planet = {}
				nm.planetdefined = {}
				nm.planetR = 0
				nm.fromFile = false
				nm.mtname = "World"

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
							fsqrt = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
							if fsqrt < bRad+0.5 and fsqrt > bRad-0.5 then
								if not bench[x] then bench[x] = {} end
								if not bench[x][y] then bench[x][y] = {} end
								bench[x][y][z] = {}
							end
							bdone = bdone + 1
							if math.fmod(bdone, 10000) == 0 then printl(parent.stdscr, "%d/%d", bDone, math.pow((bRad*2)+1, 3)) end
						end
					end
				end

				local t1 = math.floor(_time() - t0)
				local benchAdjust = -25
				benchAdjust = t1

				if benchAdjust > 50 then benchAdjust = 50 end

				local r = math.floor(math.random(125-benchAdjust, 225-benchAdjust))
				self.planetR = r

				printf(parent.stdscr, "\nConstructing voxel planet with radius of %d units...", r)

				local rdone = 0

				for x=-r,r do
					for y=-r,r do
						for z=-r,r do
							fsqrt = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
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
								self.planet[x][y][z].neighbors = {}

								table.insert(self.planetdefined, {x, y, z})
							end
							rdone = rdone + 1
							if math.fmod(rdone, 10000) == 0 then printl(parent.stdscr, "%d/%d", rdone, math.pow((r*2)+1, 3)) end
						end
					end
				end

				local planetSize = #self.planetdefined

				printf(parent.stdscr, "")

				for i=1,planetSize do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]

					for dx=-1,1 do if self.planet[x-dx] then for dy=-1,1 do if self.planet[x-dx][y-dy] then for dz=-1,1 do if self.planet[x-dx][y-dy][z-dz] then if x ~= dx or y ~= dy or z ~= dz then table.insert(self.planet[x][y][z].neighbors, {x-dx, y-dy, z-dz}) end end end end end end end
				end

				printf(parent.stdscr, "Defining land masses...")

				local maxLand = math.random(math.floor(planetSize/2), math.ceil(planetSize/1.75))
				local continents = math.random(10, 15)
				local doneNodes = {}
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
					table.insert(doneNodes, cSeed)
					table.insert(freeNodes, cSeed)
				end
				local doneLand = continents
				while doneLand < maxLand do
					local node = parent:randomChoice(freeNodes, true)

					local x = freeNodes[node][1]
					local y = freeNodes[node][2]
					local z = freeNodes[node][3]

					if #self.planet[x][y][z].neighbors > 0 then
						if math.random(1, 10) == math.random(1, 10) then
							local neighbor = parent:randomChoice(self.planet[x][y][z].neighbors, true)
							local nx = self.planet[x][y][z].neighbors[neighbor][1]
							local ny = self.planet[x][y][z].neighbors[neighbor][2]
							local nz = self.planet[x][y][z].neighbors[neighbor][3]
							self.planet[nx][ny][nz].land = true
							doneLand = doneLand + 1
							table.insert(doneNodes, self.planet[x][y][z].neighbors[neighbor])
							local found = false
							for i, j in pairs(self.planet[nx][ny][nz].neighbors) do if not self.planet[j[1]][j[2]][j[3]].land then found = true end end
							if found then table.insert(freeNodes, self.planet[x][y][z].neighbors[neighbor]) end
							table.remove(self.planet[x][y][z].neighbors, neighbor)
						end
					end

					if #self.planet[x][y][z].neighbors == 0 then table.remove(freeNodes, node)
					else
						local found = false
						for i, j in pairs(self.planet[x][y][z].neighbors) do if not self.planet[j[1]][j[2]][j[3]].land then found = true end end
						if not found then table.remove(freeNodes, node) end
					end

					printl(parent.stdscr, "%d/%d", doneLand, maxLand)
				end

				for i=1,planetSize do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]

					self.planet[x][y][z].neighbors = {}

					for dx=-1,1 do if self.planet[x-dx] then for dy=-1,1 do if self.planet[x-dx][y-dy] then for dz=-1,1 do if self.planet[x-dx][y-dy][z-dz] then if x ~= dx or y ~= dy or z ~= dz then table.insert(self.planet[x][y][z].neighbors, {x-dx, y-dy, z-dz}) end end end end end end end
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
												if not self.planet[nx][ny][nz].countryset then
													self.planet[nx][ny][nz].country = self.planet[x][y][z].country
													self.planet[nx][ny][nz].countryset = true
													allDefined = false
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

						if self.planet[x][y][z].country ~= "" or not self.planet[x][y][z].land then defined = defined + 1 end
						self.planet[x][y][z].countryset = false
					end

					printl(parent.stdscr, "%d%% done", math.floor(defined/planetSize*10000)/100)
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
					printf(parent.stdscr, "Country %d/%d", ci, parent.numCountries)
					ci = ci + 1
					cp:setTerritory(parent)
				end

				self:rOutput(parent, "initial.r")
			end,

			delete = function(self, parent, nz)
				if nz then
					for i, cp in pairs(self.countries) do for j=#cp.ongoing,1,-1 do if cp.target then if cp.target.name == nz.name then table.remove(cp.ongoing, j) end end end end

					self.cColors[nz.name] = nil
					self.cTriplets[nz.name] = nil
					self.countries[nz.name] = nil

					nz:destroy(parent)
					nz = nil

					parent.numCountries = parent.numCountries - 1
				end
			end,

			rOutput = function(self, parent, label)
				printf(parent.stdscr, "Writing R data...")

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

						local rh = string.format("%x", r)
						if rh:len() == 1 then rh = "0"..rh end
						local gh = string.format("%x", g)
						if gh:len() == 1 then gh = "0"..gh end
						local bh = string.format("%x", b)
						if bh:len() == 1 then bh = "0"..bh end

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

				for i=1,planetSize,250 do
					if i+249 <= planetSize then
						f:write(")\nx <- c(")

						for j=i,i+249 do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if not self.planet[x][y][z].land then x = x - (math.atan(self.planetdefined[j][1] / self.planetR) * 1.5) end
							f:write(x)
							if j < i+249 then f:write(", ") end
						end

						f:write(")\ny <- c(")

						for j=i,i+249 do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if not self.planet[x][y][z].land then y = y - (math.atan(self.planetdefined[j][2] / self.planetR) * 1.5) end
							f:write(y)
							if j < i+249 then f:write(", ") end
						end

						f:write(")\nz <- c(")

						for j=i,i+249 do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if not self.planet[x][y][z].land then z = z - (math.atan(self.planetdefined[j][3] / self.planetR) * 1.5) end
							f:write(z)
							if j < i+249 then f:write(", ") end
						end

						f:write(")\ncsc <- c(")

						for j=i,i+249 do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							local isCity = false
							for j=1,#cCoords do if x == cCoords[j][1] then if y == cCoords[j][2] then if z == cCoords[j][3] then isCity = true end end end end
							if isCity then f:write("\"#888888\"") else
								if self.planet[x][y][z].land then
									if self.planet[x][y][z].country ~= "" then if self.cColors[self.planet[x][y][z].country] then f:write("\""..self.cColors[self.planet[x][y][z].country].."\"") else f:write("\"#1616AA\"") end
									else f:write("\"#1616AA\"") end
								else f:write("\"#1616AA\"") end
							end
							if j < i+249 then f:write(", ") end
						end

						f:write(")\ninpdata <- data.frame(X=x, Y=y, Z=z, CSC=csc)\nspheres3d(x=inpdata$X, y=inpdata$Y, z=inpdata$Z, col=inpdata$CSC, size=0.4, xlab=\"\", ylab=\"\", zlab=\"\", box=FALSE, axes=FALSE, top=TRUE, add=TRUE, plot=FALSE")
					else
						f:write(")\nx <- c(")

						for j=i,planetSize do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if not self.planet[x][y][z].land then x = x - (math.atan(self.planetdefined[j][1] / self.planetR) * 1.5) end
							f:write(x)
							if j < planetSize then f:write(", ") end
						end

						f:write(")\ny <- c(")

						for j=i,planetSize do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if not self.planet[x][y][z].land then y = y - (math.atan(self.planetdefined[j][2] / self.planetR) * 1.5) end
							f:write(y)
							if j < planetSize then f:write(", ") end
						end

						f:write(")\nz <- c(")

						for j=i,planetSize do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if not self.planet[x][y][z].land then z = z - (math.atan(self.planetdefined[j][3] / self.planetR) * 1.5) end
							f:write(z)
							if j < planetSize then f:write(", ") end
						end

						f:write(")\ncsc <- c(")

						for j=i,planetSize do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							local isCity = false
							for j=1,#cCoords do if x == cCoords[j][1] then if y == cCoords[j][2] then if z == cCoords[j][3] then isCity = true end end end end
							if isCity then f:write("\"#888888\"") else
								if self.planet[x][y][z].land then
									if self.planet[x][y][z].country ~= "" then f:write("\""..self.cColors[self.planet[x][y][z].country].."\"")
									else f:write("\"#1616AA\"") end
								else f:write("\"#1616AA\"") end
							end
							if j < planetSize then f:write(", ") end
						end

						f:write(")\ninpdata <- data.frame(X=x, Y=y, Z=z, CSC=csc)\nspheres3d(x=inpdata$X, y=inpdata$Y, z=inpdata$Z, col=inpdata$CSC, size=0.4, xlab=\"\", ylab=\"\", zlab=\"\", box=FALSE, axes=FALSE, top=TRUE, add=TRUE, plot=FALSE")
					end
				end

				f:write(")\ncsd <- c(")

				for i, cp in pairs(self.countries) do
					f:write("\""..cp.name.."\"")
					if ci < parent.numCountries then f:write(", ") end
					ci = ci + 1
				end

				ci = 1

				f:write(")\ncse <- c(")

				for i, cp in pairs(self.countries) do
					f:write("\""..self.cColors[cp.name].."\"")
					if ci < parent.numCountries then f:write(", ") end
					ci = ci + 1
				end

				ci = 1

				f:write(")\ncityx <- c(")

				for i=1,#cCoords do
					local x = cCoords[i][1]
					local y = cCoords[i][2]
					local z = cCoords[i][3]

					x = x + (math.atan(x / self.planetR) * 12)
					y = y + (math.atan(y / self.planetR) * 12)
					z = z + (math.atan(z / self.planetR) * 12)

					cCoords[i][1] = x
					cCoords[i][2] = y
					cCoords[i][3] = z
					f:write(x)
					if i < #cCoords then f:write(", ") end
				end

				f:write(")\ncityy <- c(")

				for i=1,#cCoords do
					local x = cCoords[i][1]
					local y = cCoords[i][2]
					local z = cCoords[i][3]
					f:write(y)
					if i < #cCoords then f:write(", ") end
				end

				f:write(")\ncityz <- c(")

				for i=1,#cCoords do
					local x = cCoords[i][1]
					local y = cCoords[i][2]
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

					for j=1,#cp.nodes do avgX = avgX + cp.nodes[j][1] end

					for j=1,#cp.nodes do avgY = avgY + cp.nodes[j][2] end

					for j=1,#cp.nodes do avgZ = avgZ + cp.nodes[j][3] end

					avgX = math.floor(avgX / #cp.nodes)
					avgY = math.floor(avgY / #cp.nodes)
					avgZ = math.floor(avgZ / #cp.nodes)

					local xChange = avgX - math.pi
					local yChange = avgY - math.pi
					local zChange = avgZ - math.pi

					if avgX < 0 then xChange = xChange + math.pi * 2 end
					if avgY < 0 then yChange = yChange + math.pi * 2 end
					if avgZ < 0 then zChange = zChange + math.pi * 2 end

					local ratio = math.sqrt(math.pow(xChange, 2) + math.pow(yChange, 2) + math.pow(zChange, 2))

					while ratio < self.planetR-0.1 and ratio > self.planetR+0.1 do
						xChange = xChange + math.atan(avgX / self.planetR) / 16
						yChange = yChange + math.atan(avgY / self.planetR) / 16
						zChange = zChange + math.atan(avgZ / self.planetR) / 16

						ratio = math.sqrt(math.pow(xChange, 2) + math.pow(yChange, 2) + math.pow(zChange, 2))
					end

					xChange = xChange + (math.atan(avgX / self.planetR) * 36)
					yChange = yChange + (math.atan(avgY / self.planetR) * 36)
					zChange = zChange + (math.atan(avgZ / self.planetR) * 36)

					local r = 255 - self.cTriplets[cp.name][1]
					local g = 255 - self.cTriplets[cp.name][2]
					local b = 255 - self.cTriplets[cp.name][3]

					local rh = string.format("%x", r)
					if rh:len() == 1 then rh = "0"..rh end
					local gh = string.format("%x", g)
					if gh:len() == 1 then gh = "0"..gh end
					local bh = string.format("%x", b)
					if bh:len() == 1 then bh = "0"..bh end

					f:write("\ntext3d(x="..tostring(xChange)..", y="..tostring(yChange)..", z="..tostring(zChange)..", text=\""..cp.name.."\", color=\"#"..rh..gh..bh.."\", cex=1.1, font=2)")
				end

				f:write("\nif (interactive() == FALSE) { Sys.sleep(10000) }")

				f:flush()
				f:close()
				f = nil
			end,

			update = function(self, parent)
				parent.numCountries = 0
				for i, cp in pairs(self.countries) do parent.numCountries = parent.numCountries + 1 end

				local f0 = _time()

				for i, cp in pairs(self.countries) do if cp then
					if cp.population < 10 then
						if cp.rulers[#cp.rulers].To == "Current" then cp.rulers[#cp.rulers].To = parent.years end
						cp:event(parent, "Disappeared")
						self:delete(parent, cp)
					end
				end end
				for i, cp in pairs(self.countries) do if cp then cp:update(parent) end end
				for i, cp in pairs(self.countries) do if cp then cp:eventloop(parent) end end

				local f1 = _time() - f0

				if parent.years > parent.startyear + 1 then
					if f1 > 0.75 then
						if parent.popLimit > 1500 then parent.popLimit = math.floor(parent.popLimit - (50 * (f1 * 2))) end

						if parent.popLimit < 1500 then parent.popLimit = 1500 end
						if parent.numCountries >= 9 then parent.disabled["independence"] = true else parent.disabled["independence"] = false end
					elseif f1 < 0.5 then
						if parent.popLimit < 3500 then parent.popLimit = math.ceil(parent.popLimit + (150 * (0.08 / f1))) end
						if parent.popLimit > 3500 then parent.popLimit = 3500 end
					end
				end
			end
		}

		World.__index = World
		World.__call = function() return World:new() end

		return World
	end