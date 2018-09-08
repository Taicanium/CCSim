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

				return nm
			end,

			destroy = function(self)
				for i=1,#self.countries do
					self.countries[i]:destroy()
					self.countries[i] = nil
				end
			end,

			add = function(self, nd)
				table.insert(self.countries, nd)
			end,

			autoload = function(self, parent)
				print("Opening data file...")
				local f = io.open("in_progress.dat", "r+b")
				print("Reading data file...")

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

				parent.final = self:loadtable(parent, f)

				self.countries = self:loadtable(parent, f)

				f:close()
				f = nil

				print("File closed.")
			end,

			autosave = function(self, parent)
				parent:sortAscendants(self)

				io.write(string.format("\nAutosaving..."))

				local f = io.open("in_progress.dat", "w+b")

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

				if self.fromFile == true then f:write("1") else f:write("0") end

				if parent.ged == true then f:write("1") else f:write("0") end

				if parent.doR == true then
					f:write("1")
					self:savetable(parent, self.planet, f)
					self:savetable(parent, self.planetdefined, f)
					self:savetable(parent, self.cColors, f)
					self:savetable(parent, self.cTriplets, f)
				else f:write("0") end

				self:savetable(parent, parent.final, f)

				self:savetable(parent, self.countries, f)

				f:flush()
				f:close()
				f = nil
			end,

			constructVoxelPlanet = function(self, parent)
				print("Constructing voxel planet...")

				local r = math.random(65, 80)
				self.planetR = r

				for x=-r,r do
					self.planet[x] = {}
					for y=-r,r do
						self.planet[x][y] = {}
						for z=-r,r do
							fsqrt = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
							if fsqrt < r+0.5 and fsqrt > r-0.5 then
								self.planet[x][y][z] = {}
								self.planet[x][y][z].x = x
								self.planet[x][y][z].y = y
								self.planet[x][y][z].z = z
								self.planet[x][y][z].country = ""
								self.planet[x][y][z].countryset = false
								self.planet[x][y][z].region = ""
								self.planet[x][y][z].regionset = false
								self.planet[x][y][z].city = ""

								table.insert(self.planetdefined, {x, y, z})
							end
						end
					end
				end

				print("Rooting countries...")

				for i=1,#self.countries do
					local located = false

					local rnd = math.random(1, #self.planetdefined)

					local x = self.planetdefined[rnd][1]
					local y = self.planetdefined[rnd][2]
					local z = self.planetdefined[rnd][3]

					while located == false do
						located = true
						if self.planet[x][y][z].country ~= "" then located = false end

						rnd = math.random(1, #self.planetdefined)

						x = self.planetdefined[rnd][1]
						y = self.planetdefined[rnd][2]
						z = self.planetdefined[rnd][3]
					end

					self.planet[x][y][z].country = self.countries[i].name
				end

				print("Setting territories...")

				local allDefined = false
				local defined = 0

				while allDefined == false do
					allDefined = true

					for i=1,#self.planetdefined do
						local x = self.planetdefined[i][1]
						local y = self.planetdefined[i][2]
						local z = self.planetdefined[i][3]

						if self.planet[x][y][z].country ~= "" then
							if self.planet[x][y][z].countryset == false then
								for dx=-1,1 do
									for dy=-1,1 do
										for dz=-1,1 do
											if self.planet[dx+x] ~= nil then
												if self.planet[dx+x][dy+y] ~= nil then
													if self.planet[dx+x][dy+y][dz+z] ~= nil then
														if self.planet[dx+x][dy+y][dz+z].country == "" then
															self.planet[dx+x][dy+y][dz+z].country = self.planet[x][y][z].country
															self.planet[dx+x][dy+y][dz+z].countryset = true
															allDefined = false
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end

					defined = 0

					for i=1,#self.planetdefined do
						local x = self.planetdefined[i][1]
						local y = self.planetdefined[i][2]
						local z = self.planetdefined[i][3]

						if self.planet[x][y][z].country ~= "" then defined = defined + 1 end

						self.planet[x][y][z].countryset = false
					end

					io.write("\r"..tostring(math.floor(defined/#self.planetdefined*10000)/100).."  \t% done")
				end

				print("\nDefining regional boundaries...")

				for i=1,#self.countries do
					print("Country "..tostring(i).."/"..tostring(#self.countries))
					self.countries[i]:setTerritory(parent)
				end

				self:rOutput(parent, "initial.r")
			end,

			delete = function(self, parent, nz)
				if nz > 0 and nz <= #self.countries then
					if self.countries[nz] ~= nil then
						p = table.remove(self.countries, nz)
						if p ~= nil then
							self.cColors[p.name] = nil
							self.cTriplets[p.name] = nil

							p:destroy(parent)
							p = nil
						end
					end
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

				local f = io.open(label, "w+")

				f:write("library(\"rgl\")\nlibrary(\"car\")\nx <- c(")

				for i=1,#self.planetdefined do
					local x = self.planetdefined[i][1]
					f:write(x)
					if i < #self.planetdefined then f:write(", ") end
				end

				f:write(")\ny <- c(")

				for i=1,#self.planetdefined do
					local y = self.planetdefined[i][2]
					f:write(y)
					if i < #self.planetdefined then f:write(", ") end
				end

				f:write(")\nz <- c(")

				for i=1,#self.planetdefined do
					local z = self.planetdefined[i][3]
					f:write(z)
					if i < #self.planetdefined then f:write(", ") end
				end

				f:write(")\ncs <- c(")

				for i=1,#self.planetdefined do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]
					f:write("\""..self.planet[x][y][z].country.."\"")
					if i < #self.planetdefined then f:write(", ") end
				end

				for i=1,#self.countries do
					if self.cColors[self.countries[i].name] == nil then
						local r = math.random(0, 255)
						local g = math.random(0, 255)
						local b = math.random(0, 255)

						local unique = false
						while unique == false do
							unique = true
							for k, j in pairs(self.cTriplets) do
								if j[1] > r-30 and j[1] < r+30 then
									if j[2] > g-30 and j[2] < g+30 then
										if j[3] > b-30 and j[3] < b+30 then
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

							if r < 30 and g > 30 and b > 30 then
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

						self.cColors[self.countries[i].name] = "#"..rh..gh..bh
						self.cTriplets[self.countries[i].name] = {r, g, b}
					end
				end

				local cCoords = {}
				local cTexts = {}

				for i=1,#self.countries do
					for j, k in pairs(self.countries[i].regions) do
						for l, m in pairs(k.cities) do
							table.insert(cCoords, {m.x, m.y, m.z})
							table.insert(cTexts, m.name)
						end
					end
				end

				f:write(")\ncsc <- c(")

				for i=1,#self.planetdefined do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]
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
					if isCity == true then f:write("\"#888888\"") else f:write("\""..self.cColors[self.planet[x][y][z].country].."\"") end
					if i < #self.planetdefined then f:write(", ") end
				end

				f:write(")\ncsd <- c(")

				for i=1,#self.countries do
					f:write("\""..self.countries[i].name.."\"")
					if i < #self.countries then f:write(", ") end
				end

				f:write(")\ncse <- c(")

				for i=1,#self.countries do
					f:write("\""..self.cColors[self.countries[i].name].."\"")
					if i < #self.countries then f:write(", ") end
				end

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
				
				f:write(")\ninpdata <- data.frame(X=x, Y=y, Z=z)\nplot3d(x=inpdata$X, y=inpdata$Y, z=inpdata$Z, col=csc, size=0.35, xlab=\"\", ylab=\"\", zlab=\"\", box=FALSE, axes=FALSE, top=TRUE, type='s')\ntexts3d(x=cityx, y=cityy, z=cityz, texts=citytexts, color=\"#FFFFFF\", cex=0.8, font=2)")
				
				for i=1,#self.countries do
					local avgX = 0
					local avgY = 0
					local avgZ = 0
					
					for j=1,#self.countries[i].nodes do
						avgX = avgX + self.countries[i].nodes[j][1]
					end
					
					for j=1,#self.countries[i].nodes do
						avgY = avgY + self.countries[i].nodes[j][2]
					end
				
					for j=1,#self.countries[i].nodes do
						avgZ = avgZ + self.countries[i].nodes[j][3]
					end
					
					avgX = math.floor(avgX / #self.countries[i].nodes)
					avgY = math.floor(avgY / #self.countries[i].nodes)
					avgZ = math.floor(avgZ / #self.countries[i].nodes)
					
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
					
					local r = 255 - self.cTriplets[self.countries[i].name][1]
					local g = 255 - self.cTriplets[self.countries[i].name][2]
					local b = 255 - self.cTriplets[self.countries[i].name][3]
				
					local rh = string.format("%x", r)
					if string.len(rh) == 1 then rh = "0"..rh end
					local gh = string.format("%x", g)
					if string.len(gh) == 1 then gh = "0"..gh end
					local bh = string.format("%x", b)
					if string.len(bh) == 1 then bh = "0"..bh end
				
					f:write("\ntext3d(x="..tostring(xChange)..", y="..tostring(yChange)..", z="..tostring(zChange)..", text=\""..self.countries[i].name.."\", color=\"#"..rh..gh..bh.."\", cex=1.1, font=2)")
				end
				
				f:write("\nif (interactive() == FALSE) { Sys.sleep(10000) }")

				f:flush()
				f:close()
				f = nil
			end,

			savetable = function(self, parent, t, f)
				local types = {["string"]=1, ["number"]=2, ["boolean"]=3, ["table"]=4, ["function"]=5}
				local exceptions = {"spouse", "__index"}

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
						f:write(tostring(itype))

						f:write(string.len(tostring(string.len(i))))
						f:write(string.len(tostring(i)))
						f:write(tostring(i))

						local jtype = type(j)
						f:write(tostring(types[jtype]))

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
				parent.numCountries = #self.countries

				local f0 = socket.gettime()

				for i=#self.countries,1,-1 do
					if self.countries[i] ~= nil then
						self.countries[i]:update(parent, i)

						if self.countries[i] ~= nil then
							if parent.ged == false then parent:deepnil(self.countries[i].ascendants) end

							if self.countries[i].population < 10 then
								if self.countries[i].rulers[#self.countries[i].rulers].To == "Current" then self.countries[i].rulers[#self.countries[i].rulers].To = parent.years end
								self.countries[i]:event(parent, "Disappeared")
								self:delete(parent, i)
							end
						end
					end
				end

				local f1 = socket.gettime() - f0

				if parent.years > parent.startyear + 1 then
					if f1 > 0.25 then
						if parent.popLimit > 1000 then
							parent.popLimit = math.floor(parent.popLimit - (500 * (f1 / 0.3)))
						end

						if parent.popLimit < 1000 then parent.popLimit = 1000 end
					elseif f1 < 0.125 then
						if parent.popLimit < 50000 then parent.popLimit = math.floor(parent.popLimit + (500 * (0.08 / f1))) end
					end
				end
			end
		}

		World.__index = World
		World.__call = function() return World:new() end

		return World
	end