threadsstatus, threads = pcall(require, "threads")
threadpool = nil

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
				nm.mtName = "World"
				nm.threadsDone = {}

				return nm
			end,

			destroy = function(self)
				for i, cp in pairs(self.countries) do
					cp:destroy()
					cp = nil
				end
			end,

			add = function(self, nd)
				self.countries[nd.name] = nd
			end,

			autoload = function(self, parent)
				print("Opening data file...")
				local f = io.open("in_progress.dat", "r+b")
				print("Reading data file...")
				
				if jsonstatus then
					local jTable = json.decode(f:read("*all"))
					
					parent.autosaveDur = tonumber(jTable[1])
					parent.numCountries = tonumber(jTable[2])
					parent.popLimit = tonumber(jTable[3])
					parent.showinfo = tonumber(jTable[4])
					parent.startyear = tonumber(jTable[5])
					parent.maxyears = tonumber(jTable[6])
					parent.years = tonumber(jTable[7])
					parent.yearstorun = tonumber(jTable[8])
					parent.final = jTable[9]
					self.countries = jTable[10]
					self.fromFile = jTable[11]
					parent.ged = jTable[12]
					parent.doR = jTable[13]
					if parent.doR == true then
						self.planet = jTable[14]
						self.planetdefined = jTable[15]
						self.cColors = jTable[16]
						self.cTriplets = jTable[17]
					end
					
					for i, j in pairs(self.countries) do
						setmetatable(j, Country)
						for k, l in pairs(j.people) do
							setmetatable(l, Person)
						end
						for k, l in pairs(j.parties) do
							setmetatable(l, Party)
						end
						for k, l in pairs(j.regions) do
							setmetatable(l, Region)
							for m, n in pairs(l.cities) do
								setmetatable(n, City)
							end
						end
					end
				else
					local datin = f:read(1)
					parent.autosaveDur = tonumber(f:read(tonumber(datin)))

					datin = f:read(1)
					parent.numCountries = tonumber(f:read(tonumber(datin)))

					datin = f:read(1)
					parent.popLimit = tonumber(f:read(tonumber(datin)))

					datin = f:read(1)
					parent.showinfo = tonumber(f:read(tonumber(datin)))

					datin = f:read(1)
					parent.startyear = tonumber(f:read(tonumber(datin)))

					datin = f:read(1)
					parent.maxyears = tonumber(f:read(tonumber(datin)))

					datin = f:read(1)
					parent.years = tonumber(f:read(tonumber(datin)))

					datin = f:read(1)
					parent.yearstorun = tonumber(f:read(tonumber(datin)))
					
					parent.final = self:loadtable(parent, f)

					self.countries = self:loadtable(parent, f)

					datin = f:read(1)
					if datin == "0" then self.fromFile = false else self.fromFile = true end

					datin = f:read(1)
					if datin == "0" then parent.ged = false else parent.ged = true end

					datin = f:read(1)
					if datin == "0" then parent.doR = false else
						parent.doR = true
						self.planet = self:loadtable(parent, f)
						self.planetdefined = self:loadtable(parent, f)
						self.cColors = self:loadtable(parent, f)
						self.cTriplets = self:loadtable(parent, f)
					end
				end
				
				f:close()
				f = nil
				
				for i, j in pairs(self.countries) do if j.people then
					for k, l in pairs(j.people) do if l.spouse then
						for m, n in pairs(j.people) do if n.spouse then
							if type(l.spouse) == "number" then
								l.spouse = j.people[l.spouse]
							end
						end end
					end end
				end end
				
				for i, j in pairs(parent.final) do if j.people then
					for k, l in pairs(j.people) do if l.spouse then
						for m, n in pairs(j.people) do if n.spouse then
							if type(l.spouse) == "number" then
								l.spouse = j.people[l.spouse]
							end
						end end
					end end
				end end

				for i, j in pairs(self.countries) do
					for k, l in pairs(j.ongoing) do
						for m, n in pairs(l) do
							if type(n) == "string" then
								local fn = self:loadfunction(parent, m, l[m])
								l[m] = fn
							end
						end
					end
				end

				print("File closed.")
			end,

			autosave = function(self, parent)
				io.write(string.format("\nAutosaving..."))

				local f = io.open("in_progress.dat", "w+b")
				
				for i, j in pairs(self.countries) do if j.people then
					for k, l in pairs(j.people) do if l.spouse then
						for m, n in pairs(j.people) do if n.spouse then
							if type(l.spouse) == "table" then
								if l.spouse.name == n.name then
									if l.spouse.surname == n.surname then
										if l.spouse.birth == n.birth then
											if l.spouse.birthplace == n.birthplace then
												if l.spouse.level == n.level then
													l.spouse = m
												end
											end
										end
									end
								end
							end
						end end
					end end
				end end
				
				for i, j in pairs(parent.final) do if j.people then
					for k, l in pairs(j.people) do if l.spouse then
						for m, n in pairs(j.people) do if n.spouse then
							if type(l.spouse) == "table" then
								if l.spouse.name == n.name then
									if l.spouse.surname == n.surname then
										if l.spouse.birth == n.birth then
											if l.spouse.birthplace == n.birthplace then
												if l.spouse.level == n.level then
													l.spouse = m
												end
											end
										end
									end
								end
							end
						end end
					end end
				end end
				
				for i, j in pairs(self.countries) do
					for k, l in pairs(j.ongoing) do
						for m, n in pairs(l) do
							if type(n) == "function" then
								l[m] = tostring(string.dump(n))
							end
						end
					end
				end
				
				if jsonstatus then
					local jTable = {parent.autosaveDur, parent.numCountries, parent.popLimit, parent.showinfo, parent.startyear, parent.maxyears, parent.years, parent.yearstorun, parent.final, self.countries, self.fromFile, parent.ged, parent.doR}
					
					if parent.doR == true then
						table.insert(jTable, self.planet)
						table.insert(jTable, self.planetdefined)
						table.insert(jTable, self.cColors)
						table.insert(jTable, self.cTriplets)
					end
				
					local stat, jData = pcall(json.encode, jTable)
					if stat then f:write(jData) end
				else
					f:write(string.len(tostring(parent.autosaveDur)))
					f:write(parent.autosaveDur)

					f:write(string.len(tostring(parent.numCountries)))
					f:write(parent.numCountries)

					f:write(string.len(tostring(parent.popLimit)))
					f:write(parent.popLimit)

					f:write(string.len(tostring(parent.showinfo)))
					f:write(parent.showinfo)

					f:write(string.len(tostring(parent.startyear)))
					f:write(parent.startyear)

					f:write(string.len(tostring(parent.maxyears)))
					f:write(parent.maxyears)

					f:write(string.len(tostring(parent.years)))
					f:write(parent.years)

					f:write(string.len(tostring(parent.yearstorun)))
					f:write(parent.yearstorun)
					
					self:savetable(parent, parent.final, f)

					self:savetable(parent, self.countries, f)
					
					if self.fromFile == true then f:write("1") else f:write("0") end

					if parent.ged == true then f:write("1") else f:write("0") end

					if parent.doR == true then
						f:write("1")
						self:savetable(parent, self.planet, f)
						self:savetable(parent, self.planetdefined, f)
						self:savetable(parent, self.cColors, f)
						self:savetable(parent, self.cTriplets, f)
					else f:write("0") end
				end
				
				f:flush()
				f:close()
				f = nil
					
				for i, j in pairs(self.countries) do if j.people then
					for k, l in pairs(j.people) do if l.spouse then
						for m, n in pairs(j.people) do if n.spouse then
							if type(l.spouse) == "number" then
								l.spouse = j.people[l.spouse]
							end
						end end
					end end
				end end
				
				for i, j in pairs(parent.final) do if j.people then
					for k, l in pairs(j.people) do if l.spouse then
						for m, n in pairs(j.people) do if n.spouse then
							if type(l.spouse) == "number" then
								l.spouse = j.people[l.spouse]
							end
						end end
					end end
				end end
				
				for i, j in pairs(self.countries) do
					for k, l in pairs(j.ongoing) do
						for m, n in pairs(l) do
							if type(n) == "string" then
								local fn = self:loadfunction(parent, m, l[m])
								l[m] = fn
							end
						end
					end
				end
			end,

			constructVoxelPlanet = function(self, parent)
				parent:rseed()

				print("Constructing voxel planet...")

				local r = math.random(100, 150)
				self.planetR = r
				
				local rdone = 0

				for x=-r,r do
					for y=-r,r do
						for z=-r,r do
							fsqrt = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
							if fsqrt < r+0.5 and fsqrt > r-0.5 then
								if self.planet[x] == nil then self.planet[x] = {} end
								if self.planet[x][y] == nil then self.planet[x][y] = {} end
								self.planet[x][y][z] = {}
								self.planet[x][y][z].x = x
								self.planet[x][y][z].y = y
								self.planet[x][y][z].z = z
								self.planet[x][y][z].country = ""
								self.planet[x][y][z].countryset = false
								self.planet[x][y][z].region = ""
								self.planet[x][y][z].regionset = false
								self.planet[x][y][z].city = ""
								self.planet[x][y][z].land = true -- if false, this node is water.
								self.planet[x][y][z].neighbors = {}

								table.insert(self.planetdefined, {x, y, z})
							end
							rdone = rdone + 1
							if math.fmod(rdone, 5000) == 0 then io.write("\r"..tostring(rdone).."/"..tostring(math.pow(r*2, 3))) end
						end
					end
				end
				
				print("")

				for i=1,#self.planetdefined do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]

					for dx=-1,1 do
						if self.planet[x-dx] ~= nil then
							for dy=-1,1 do
								if self.planet[x-dx][y-dy] ~= nil then
									for dz=-1,1 do
										if self.planet[x-dx][y-dy][z-dz] ~= nil then
											if x ~= dx or y ~= dy or z ~= dz then
												table.insert(self.planet[x][y][z].neighbors, {x-dx, y-dy, z-dz})
											end
										end
									end
								end
							end
						end
					end
				end

				print("Defining bodies of water...")

				local bodyCount = math.random(20, 35)
				local wNodeCount = 0
				local maxWNodes = math.random(math.floor(#self.planetdefined / 1.65), math.ceil(#self.planetdefined / 1.425))

				for i=1,bodyCount do
					parent:rseed()
					
					local located = false

					local rnd = math.random(1, #self.planetdefined)

					local x = self.planetdefined[rnd][1]
					local y = self.planetdefined[rnd][2]
					local z = self.planetdefined[rnd][3]

					while located == false do
						rnd = math.random(1, #self.planetdefined)

						x = self.planetdefined[rnd][1]
						y = self.planetdefined[rnd][2]
						z = self.planetdefined[rnd][3]

						located = true
						if self.planet[x][y][z].country ~= "" or self.planet[x][y][z].land == false then located = false end
					end

					self.planet[x][y][z].land = false

					local stop = false
					local oceanNodes = {{x, y, z}}
					wNodeCount = wNodeCount + 1
					local maxsize = math.random(math.ceil(#self.planetdefined / 75), math.floor(#self.planetdefined / math.random(50, 7.5)))
					if wNodeCount >= maxWNodes then stop = true else print("\nBody "..tostring(i).."/"..tostring(bodyCount)) end
					while stop == false do
						parent:rseed()
						for j=1,#oceanNodes do
							local ox = oceanNodes[j][1]
							local oy = oceanNodes[j][2]
							local oz = oceanNodes[j][3]
							local chance = math.random(10, math.random(500, math.random(750, 1250)))
							if chance > 750 then
								local neighbors = self.planet[ox][oy][oz].neighbors

								if #neighbors > 0 then
									local nr = math.random(1, #neighbors)
									local nx = neighbors[nr][1]
									local ny = neighbors[nr][2]
									local nz = neighbors[nr][3]
									if self.planet[nx][ny][nz].land == true then
										table.insert(oceanNodes, neighbors[nr])
										wNodeCount = wNodeCount + 1
									end
									self.planet[nx][ny][nz].land = false
								end
							end
						end

						if #oceanNodes >= maxsize then stop = true end
						if wNodeCount >= maxWNodes then stop = true end
						io.write("\r"..tostring(#oceanNodes).."/"..tostring(maxsize)..", max "..tostring(maxWNodes))
					end
				end

				print("\nRooting countries...")

				for i, cp in pairs(self.countries) do
					local located = false

					local rnd = math.random(1, #self.planetdefined)

					local x = self.planetdefined[rnd][1]
					local y = self.planetdefined[rnd][2]
					local z = self.planetdefined[rnd][3]

					while located == false do
						rnd = math.random(1, #self.planetdefined)

						x = self.planetdefined[rnd][1]
						y = self.planetdefined[rnd][2]
						z = self.planetdefined[rnd][3]

						located = true
						if self.planet[x][y][z].country ~= "" or self.planet[x][y][z].land == false then located = false end
					end

					self.planet[x][y][z].country = cp.name
				end

				print("Setting territories...")

				local allDefined = false
				local defined = 0

				while allDefined == false do
					allDefined = true
					defined = 0

					for i=1,#self.planetdefined do
						local x = self.planetdefined[i][1]
						local y = self.planetdefined[i][2]
						local z = self.planetdefined[i][3]

						if self.planet[x][y][z].land == true then
							if self.planet[x][y][z].country ~= "" then
								if self.planet[x][y][z].countryset == false then
									for j=1,#self.planet[x][y][z].neighbors do
										local neighbor = self.planet[x][y][z].neighbors[j]
										local nx = neighbor[1]
										local ny = neighbor[2]
										local nz = neighbor[3]
										if self.planet[nx][ny][nz].land == true then
											if self.planet[nx][ny][nz].country == "" then
												if self.planet[nx][ny][nz].countryset == false then
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

					for i=1,#self.planetdefined do
						local x = self.planetdefined[i][1]
						local y = self.planetdefined[i][2]
						local z = self.planetdefined[i][3]

						if self.planet[x][y][z].country ~= "" or self.planet[x][y][z].land == false then defined = defined + 1 end
						self.planet[x][y][z].countryset = false
					end

					io.write("\r"..tostring(math.floor(defined/#self.planetdefined*10000)/100).."   \t% done")
				end

				for i=1,#self.planetdefined do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]

					if self.planet[x][y][z].country == "" then self.planet[x][y][z].land = false end
				end

				print("\nDefining regional boundaries...")

				local ci = 1

				for i, cp in pairs(self.countries) do
					print("Country "..tostring(ci).."/"..tostring(parent.numCountries))
					ci = ci + 1
					cp:setTerritory(parent)
				end

				self:rOutput(parent, "initial.r")
			end,

			delete = function(self, parent, nz)
				if nz ~= nil then
					for i, cp in pairs(self.countries) do
						for j=#cp.ongoing,1,-1 do if cp.target ~= nil then if cp.target.name == nz.name then table.remove(cp.ongoing, j) end end end
					end
				
					self.cColors[nz.name] = nil
					self.cTriplets[nz.name] = nil
					self.countries[nz.name] = nil

					nz:destroy(parent)
					nz = nil
				end
			end,

			getfunctionvalues = function(self, fnname, fn, t)
				local found = false
				local exceptions = {"__index"}

				for i, j in pairs(t) do
					if type(j) == "function" then
						if string.dump(fn) == string.dump(j) then
							local q = 1
							while true do
								local name = debug.getupvalue(j, q)
								if not name then
									break
								end
								debug.upvaluejoin(fn, q, j, q)
								q = q + 1
							end
						end
					elseif type(j) == "table" then
						local isexception = false
						for q=1,#exceptions do if exceptions[q] == i then isexception = true end end
						if isexception == false then self:getfunctionvalues(fnname, fn, j) end
					end
				end
			end,

			loadfunction = function(self, parent, fnname, fndata)
				local fn = loadstring(fndata)

				self:getfunctionvalues(fnname, fn, self)

				return fn
			end,

			loadtable = function(self, parent, f)
				local tableout = {}
				local types = {"string", "number", "boolean", "table", "function"}

				local slen = f:read(1)
				local mt = f:read(tonumber(slen))

				if mt ~= "nilmt" then
					if mt == "World" then
						setmetatable(tableout, World)
					elseif mt == "Country" then
						setmetatable(tableout, Country)
					elseif mt == "Region" then
						setmetatable(tableout, Region)
					elseif mt == "City" then
						setmetatable(tableout, City)
					elseif mt == "Person" then
						setmetatable(tableout, Person)
					elseif mt == "Party" then
						setmetatable(tableout, Party)
					end
				end

				slen = f:read(1)
				local iCount = f:read(tonumber(slen))

				for i=1,iCount do
					local itype = types[tonumber(f:read(1))]

					slen = f:read(1)
					slen = f:read(tonumber(slen))
					local idata = f:read(tonumber(slen))

					if itype == "number" then idata = tonumber(idata) end

					local jtype = types[tonumber(f:read(1))]

					if jtype == "table" then
						tableout[idata] = self:loadtable(parent, f)
					elseif jtype == "function" then
						slen = f:read(1)
						slen = f:read(tonumber(slen))
						local fndata = f:read(tonumber(slen))
						tableout[idata] = self:loadfunction(parent, idata, fndata)
					elseif jtype == "boolean" then
						local booldata = tonumber(f:read(1))
						if booldata == 0 then tableout[idata] = false else tableout[idata] = true end
					elseif jtype == "number" then
						slen = f:read(1)
						slen = f:read(tonumber(slen))
						tableout[idata] = tonumber(f:read(tonumber(slen)))
					else
						slen = f:read(1)
						slen = f:read(tonumber(slen))
						tableout[idata] = f:read(tonumber(slen))
					end
				end

				return tableout
			end,

			rOutput = function(self, parent, label)
				print("Writing R data...")

				local ci = 1

				local f = io.open(label, "w+")

				f:write("library(\"rgl\")\nlibrary(\"car\")\ncs <- c(")

				for i=1,#self.planetdefined do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]
					f:write("\""..self.planet[x][y][z].country.."\"")
					if i < #self.planetdefined then f:write(", ") end
				end

				for i, cp in pairs(self.countries) do
					if self.cColors[cp.name] == nil then
						local r = math.random(0, 255)
						local g = math.random(0, 255)
						local b = math.random(0, 255)

						local unique = false
						while unique == false do
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
						if string.len(rh) == 1 then rh = "0"..rh end
						local gh = string.format("%x", g)
						if string.len(gh) == 1 then gh = "0"..gh end
						local bh = string.format("%x", b)
						if string.len(bh) == 1 then bh = "0"..bh end

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

				for i=1,#self.planetdefined,500 do
					if i+499 <= #self.planetdefined then
						f:write(")\nx <- c(")

						for j=i,i+499 do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if self.planet[x][y][z].land == false then
								x = x - (math.atan(self.planetdefined[j][1] / self.planetR) * 1.5)
							end
							f:write(x)
							if j < i+499 then f:write(", ") end
						end

						f:write(")\ny <- c(")

						for j=i,i+499 do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if self.planet[x][y][z].land == false then
								y = y - (math.atan(self.planetdefined[j][2] / self.planetR) * 1.5)
							end
							f:write(y)
							if j < i+499 then f:write(", ") end
						end

						f:write(")\nz <- c(")

						for j=i,i+499 do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if self.planet[x][y][z].land == false then
								z = z - (math.atan(self.planetdefined[j][3] / self.planetR) * 1.5)
							end
							f:write(z)
							if j < i+499 then f:write(", ") end
						end
						
						f:write(")\ncsc <- c(")

						for j=i,i+499 do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							local isCity = false
							for j=1,#cCoords do
								if x == cCoords[j][1] then
									if y == cCoords[j][2] then
										if z == cCoords[j][3] then
											isCity = true
										end
									end
								end
							end
							if isCity == true then f:write("\"#888888\"") else
								if self.planet[x][y][z].land == true then
									if self.planet[x][y][z].country ~= "" then if self.cColors[self.planet[x][y][z].country] then f:write("\""..self.cColors[self.planet[x][y][z].country].."\"") else f:write("\"#1616AA\"") end
									else f:write("\"#1616AA\"") end
								else f:write("\"#1616AA\"") end
							end
							if j < i+499 then f:write(", ") end
						end
						
						f:write(")\ninpdata <- data.frame(X=x, Y=y, Z=z, CSC=csc)\nspheres3d(x=inpdata$X, y=inpdata$Y, z=inpdata$Z, col=inpdata$CSC, size=0.4, xlab=\"\", ylab=\"\", zlab=\"\", box=FALSE, axes=FALSE, top=TRUE, add=TRUE, plot=FALSE)")
					else
						f:write("\nx <- c(")

						for j=i,#self.planetdefined do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if self.planet[x][y][z].land == false then
								x = x - (math.atan(self.planetdefined[j][1] / self.planetR) * 1.5)
							end
							f:write(x)
							if j < #self.planetdefined then f:write(", ") end
						end

						f:write(")\ny <- c(")

						for j=i,#self.planetdefined do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if self.planet[x][y][z].land == false then
								y = y - (math.atan(self.planetdefined[j][2] / self.planetR) * 1.5)
							end
							f:write(y)
							if j < #self.planetdefined then f:write(", ") end
						end

						f:write(")\nz <- c(")

						for j=i,#self.planetdefined do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							if self.planet[x][y][z].land == false then
								z = z - (math.atan(self.planetdefined[j][3] / self.planetR) * 1.5)
							end
							f:write(z)
							if j < #self.planetdefined then f:write(", ") end
						end
						
						f:write(")\ncsc <- c(")

						for j=i,#self.planetdefined do
							local x = self.planetdefined[j][1]
							local y = self.planetdefined[j][2]
							local z = self.planetdefined[j][3]
							local isCity = false
							for j=1,#cCoords do
								if x == cCoords[j][1] then
									if y == cCoords[j][2] then
										if z == cCoords[j][3] then
											isCity = true
										end
									end
								end
							end
							if isCity == true then f:write("\"#888888\"") else
								if self.planet[x][y][z].land == true then
									if self.planet[x][y][z].country ~= "" then f:write("\""..self.cColors[self.planet[x][y][z].country].."\"")
									else f:write("\"#1616AA\"") end
								else f:write("\"#1616AA\"") end
							end
							if j < #self.planetdefined then f:write(", ") end
						end
						
						f:write(")\ninpdata <- data.frame(X=x, Y=y, Z=z, CSC=csc)\nspheres3d(x=inpdata$X, y=inpdata$Y, z=inpdata$Z, col=inpdata$CSC, size=0.4, xlab=\"\", ylab=\"\", zlab=\"\", box=FALSE, axes=FALSE, top=TRUE, add=TRUE, plot=FALSE)")
					end
				end
				
				f:write("\ncsd <- c(")

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

					for j=1,#cp.nodes do
						avgX = avgX + cp.nodes[j][1]
					end

					for j=1,#cp.nodes do
						avgY = avgY + cp.nodes[j][2]
					end

					for j=1,#cp.nodes do
						avgZ = avgZ + cp.nodes[j][3]
					end

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
					if string.len(rh) == 1 then rh = "0"..rh end
					local gh = string.format("%x", g)
					if string.len(gh) == 1 then gh = "0"..gh end
					local bh = string.format("%x", b)
					if string.len(bh) == 1 then bh = "0"..bh end

					f:write("\ntext3d(x="..tostring(xChange)..", y="..tostring(yChange)..", z="..tostring(zChange)..", text=\""..cp.name.."\", color=\"#"..rh..gh..bh.."\", cex=1.1, font=2)")
				end

				f:write("\nif (interactive() == FALSE) { Sys.sleep(10000) }")

				f:flush()
				f:close()
				f = nil
			end,

			savetable = function(self, parent, t, f)
				local types = {["string"]=1, ["number"]=2, ["boolean"]=3, ["table"]=4, ["function"]=5}
				local exceptions = {"__index"}

				if t.mtName == nil then f:write("5nilmt") else
					f:write(string.len(t.mtName))
					f:write(t.mtName)
				end

				local iCount = 0
				for i, j in pairs(t) do
					found = false
					for k=1,#exceptions do if exceptions[k] == tostring(i) then found = true end end
					if found == false then iCount = iCount + 1 end
				end

				f:write(string.len(tostring(iCount)))
				f:write(tostring(iCount))

				for i, j in pairs(t) do
					local found = false
					for k=1,#exceptions do if exceptions[k] == tostring(i) then found = true end end
					if found == false then 
						local itype = types[type(i)]
						f:write(itype)

						f:write(string.len(tostring(string.len(i))))
						f:write(string.len(tostring(i)))
						f:write(tostring(i))

						local jtype = type(j)
						f:write(types[jtype])

						if jtype == "table" then
							self:savetable(parent, j, f)
						elseif jtype == "function" then
							fndata = string.dump(j)
							f:write(string.len(tostring(string.len(fndata))))
							f:write(string.len(fndata))
							f:write(fndata)
						elseif jtype == "boolean" then
							if j == false then f:write("0") else f:write("1") end
						else
							f:write(string.len(tostring(string.len(tostring(j)))))
							f:write(string.len(tostring(j)))
							f:write(tostring(j))
						end
					end
				end
			end,

			update = function(self, parent)
				parent.numCountries = 0
				for i, cp in pairs(self.countries) do parent.numCountries = parent.numCountries + 1 end

				local f0 = _time()

				if threadsstatus then
					if threadpool == nil then
						if torchstatus then threadpool = threads.Threads(torch.getnumthreads()) else threadpool = threads.Threads(4) end
					end

					for i, cp in pairs(self.countries) do
						self.threadsDone[i] = 1
					end

					for i, cp in pairs(self.countries) do
						if cp ~= nil then
							if cp.update ~= nil then
								threadpool:addjob(
									function() cp:update(parent, i) end,

									function() parent.thisWorld.threadsDone[i] = 1 end
								)
								self.threadsDone[i] = 0
							end
						end
					end

					threadpool:synchronize()

					local allfinished = false
					while allfinished == false do
						allfinished = true
						for i=1,#self.threadsDone do if self.threadsDone[i] == 0 then allfinished = false end end
					end
				else
					for i, cp in pairs(self.countries) do
						if cp ~= nil then
							cp:update(parent)
						end
					end
				end

				for i, cp in pairs(self.countries) do
					if cp ~= nil then
						cp:eventloop(parent)
					end

					if cp ~= nil then
						if parent.ged == false then parent:deepnil(cp.ascendants) end

						if cp.population < 10 then
							if cp.rulers[#cp.rulers].To == "Current" then cp.rulers[#cp.rulers].To = parent.years end
							cp:event(parent, "Disappeared")
							self:delete(parent, cp)
						end
					end
				end

				local f1 = _time() - f0

				if parent.years > parent.startyear + 1 then
					if f1 > 0.75 then
						if parent.popLimit > 1000 then
							parent.popLimit = math.floor(parent.popLimit - (500 * (f1 / 0.3)))
						end

						if parent.popLimit < 1000 then parent.popLimit = 1000 end
					elseif f1 < 0.35 then
						if parent.popLimit < 50000 then parent.popLimit = math.floor(parent.popLimit + (500 * (0.08 / f1))) end
					end
				end
			end
		}

		World.__index = World
		World.__call = function() return World:new() end

		return World
	end