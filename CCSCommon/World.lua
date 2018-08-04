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

			delete = function(self, nz)
				if nz > 0 and nz <= #self.countries then
					if self.countries[nz] ~= nil then
						local p = table.remove(self.countries, nz)
						if p ~= nil then
							for i=#self.countries,1,-1 do
								if self.countries[i] ~= nil then
									for j=#self.countries[i].ongoing,1,-1 do
										if self.countries[i].ongoing[j] ~= nil then
											if self.countries[i].ongoing[j].target ~= nil then
												if self.countries[i].ongoing[j].target == nz then
													table.remove(self.countries[i].ongoing, j)
												elseif self.countries[i].ongoing[j].target > nz then
													self.countries[i].ongoing[j].target = self.countries[i].ongoing[j].target - 1
												end
											end
										end
									end
									for j=#self.countries[i].allyOngoing,1,-1 do
										if self.countries[i].allyOngoing[j] ~= nil then
											if self.countries[i].allyOngoing[j]:find(p.name) then
												table.remove(self.countries[i].allyOngoing, j)
											end
										end
									end
									for j=#self.countries[i].alliances,1,-1 do
										if self.countries[i].alliances[j] ~= nil then
											if self.countries[i].alliances[j] == p.name then
												table.remove(self.countries[i].alliances, j)
											end
										end
									end
								end
							end
							
							self.cColors[p.name] = nil
							self.cTriplets[p.name] = nil
							
							p:destroy()
							p = nil
						end
					end
				end
			end,

			savetable = function(self, parent, t, f)
				local exceptions = {"spouse", "metatables", "__index", "__call", "autoload", "savetable", "loadtable", "getfunctionvalues", "loadfunction", "savefunction", "constructVoxelPlanet", "destroy", "add", "delete", "update", "makename", "name"}
				local types = {["string"]=1, ["number"]=2, ["boolean"]=3, ["table"]=4, ["function"]=5, ["nyx"]=6}
				
				if getmetatable(t) ~= nil then
					for i=1,#parent.metatables do
						if parent.metatables[i][1] == getmetatable(t) then
							f:write(string.len(tostring(string.len(parent.metatables[i][2]))))
							f:write(string.len(parent.metatables[i][2]))
							f:write(parent.metatables[i][2])
						end
					end
				else
					f:write("15nilmt")
				end
				
				for i, j in pairs(t) do
					local isexception = false
					for k=1,#exceptions do if exceptions[k] == tostring(i) then isexception = true end end
					if isexception == false then
						f:write(types[type(i)])
						f:write(string.len(tostring(string.len(tostring(i)))))
						f:write(string.len(tostring(i)))
						f:write(tostring(i))
						f:write(types[type(j)])
						
						if type(j) == "function" then
							local data = string.dump(j)
							
							f:write(string.len(tostring(string.len(data))))
							f:write(string.len(data))
							f:write(data)
						elseif type(j) == "table" then
							self:savetable(parent, j, f)
						else
							f:write(string.len(tostring(string.len(tostring(j)))))
							f:write(string.len(tostring(j)))
							f:write(tostring(j))
						end
					end
				end
				
				f:write("6")
			end,
			
			autosave = function(self, parent)
				local f = io.open("in_progress.dat", "w+b")
			
				self:savetable(parent, parent, f)
				
				f:flush()
				f:close()
				
				parent:deepnil(f)
				f = nil
			end,
			
			loadtable = function(self, parent, f)
				local tableout = {}
				
				local types = {"string", "number", "boolean", "table", "function", "nyx"}
				
				local nextlen = tonumber(f:read(1))
				nextlen = tonumber(f:read(nextlen))
				local mt = f:read(nextlen)
				
				local typei = types[tonumber(f:read(1))]
				
				while typei ~= "nyx" do
					nextlen = tonumber(f:read(1))
					nextlen = tonumber(f:read(nextlen))
					local nexti = f:read(nextlen)
					if typei == "string" then nexti = tostring(nexti)
					elseif typei == "number" then nexti = tonumber(nexti) end
					
					local typej = types[tonumber(f:read(1))]
					
					local nextj = nil
					
					if typej == "string" then
						nextlen = tonumber(f:read(1))
						nextlen = tonumber(f:read(nextlen))
						nextj = tostring(f:read(nextlen))
					elseif typej == "number" then
						nextlen = tonumber(f:read(1))
						nextlen = tonumber(f:read(nextlen))
						nextj = tonumber(f:read(nextlen))
					elseif typej == "boolean" then
						nextlen = tonumber(f:read(1))
						nextlen = tonumber(f:read(nextlen))
						local b = f:read(nextlen)
						if b == "false" then nextj = false else nextj = true end
					elseif typej == "function" then
						nextlen = tonumber(f:read(1))
						nextlen = tonumber(f:read(nextlen))
						local fndata = f:read(nextlen)
						nextj = self:loadfunction(parent, nexti, fndata)
					elseif typej == "table" then
						nextj = self:loadtable(parent, f)
					end
					
					tableout[nexti] = nextj
					typei = types[tonumber(f:read(1))]
				end
				
				if mt ~= "nilmt" then
					for i=1,#parent.metatables do
						if parent.metatables[i][2] == mt then setmetatable(tableout, parent.metatables[i][1]) end
					end
				end
				
				return tableout
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
				local fn = load(fndata)
				
				self:getfunctionvalues(fnname, fn, self)
				
				return fn
			end,
			
			autoload = function(self, parent)
				print("Opening data file...")
				local f = io.open("in_progress.dat", "r+b")
				print("Reading data file...")
				
				local newParent = self:loadtable(parent, f)
				
				f:close()
				parent:deepnil(f)
				f = nil
				
				print("File closed.")
				
				return newParent
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
							local fsqrt = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
							if fsqrt > r-0.5 and fsqrt < r+0.5 then
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
				
					local x = 1
					local y = 1
					local z = 1
				
					while located == false do
						located = true
						
						local rnd = math.random(1, #self.planetdefined)
				
						x = self.planetdefined[rnd][1]
						y = self.planetdefined[rnd][2]
						z = self.planetdefined[rnd][3]
						
						if self.planet[x][y][z].country ~= "" then located = false end
					end
					
					self.planet[x][y][z].country = self.countries[i].name
				end
				
				print("Setting territories...")
				
				local allDefined = false
				local defined = 0
				local passes = 0
				
				while allDefined == false do
					allDefined = true
					defined = 0
					passes = passes + 1
				
					for i=1,#self.planetdefined do
						local x = self.planetdefined[i][1]
						local y = self.planetdefined[i][2]
						local z = self.planetdefined[i][3]
						
						if self.planet[x][y][z].country ~= "" then
							defined = defined + 1
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
															defined = defined + 1
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
					
					for i=1,#self.planetdefined do
						local x = self.planetdefined[i][1]
						local y = self.planetdefined[i][2]
						local z = self.planetdefined[i][3]
						
						self.planet[x][y][z].countryset = false
					end
					
					if math.fmod(passes, 10) == 0 then print(tostring(math.floor(defined/#self.planetdefined*100)).."% done") end
				end
				
				print("Defining regional boundaries...")
				
				for i=1,#self.countries do
					print("Country "..tostring(i).."/"..tostring(#self.countries))
					self.countries[i]:setTerritory(parent)
				end
				
				self:rOutput(parent, "initial.r")
			end,
			
			rOutput = function(self, parent, label)
				print("Writing R data...")
			
				while allDefined == false do
					allDefined = true
					for i=1,#self.planetdefined do
						local x = self.planetdefined[i][1]
						local y = self.planetdefined[i][2]
						local z = self.planetdefined[i][3]
						local cnt = self.planet[x][y][z].country
						local found = false
						for j=1,#self.countries do
							if self.countries[j].name == cnt then found = true end
							for k=1,#self.countries[j].regions do
								if self.planet[x][y][z].region == self.countries[j].regions[k] then
									self.planet[x][y][z].country = self.countries[j].name
									found = true
								end
							end
						end
						if found == false then
							self.planet[x][y][z].country = ""
							allDefined = false
						end
					end
				end
			
				local allDefined = false
			
				while allDefined == false do
					allDefined = true
					for i=1,#self.planetdefined do
						local x = self.planetdefined[i][1]
						local y = self.planetdefined[i][2]
						local z = self.planetdefined[i][3]
						local cnt = self.planet[x][y][z].country
						local found = false
						for j=1,#self.countries do
							if self.countries[j].name == cnt then found = true end
						end
						if found == false then
							allDefined = false
							local ct = {}
							for dx=-1,1 do
								 for dy=-1,1 do
									for dz=-1,1 do
										if self.planet[dx+x] ~= nil then
											if self.planet[dx+x][dy+y] ~= nil then
												if self.planet[dx+x][dy+y][dz+z] ~= nil then
													if self.planet[dx+x][dy+y][dz+z].country ~= "" then
														if self.planet[dx+x][dy+y][dz+z].countryset == false then
															table.insert(ct, {dx+x, dy+y, dz+z})
														end
													end
												end
											end
										end
									end
								end
							end
							
							local c = math.random(1, #ct)
							self.planet[x][y][z].country = self.planet[ct[c][1]][ct[c][2]][ct[c][3]].country
						end
					end
					
					for i=1,#self.planetdefined do
						local x = self.planetdefined[i][1]
						local y = self.planetdefined[i][2]
						local z = self.planetdefined[i][3]
						
						self.planet[x][y][z].countryset = false
					end
				end
			
				local f = io.open(label, "w+")
				
				f:write("library(\"rgl\")\nlibrary(\"car\")\nx <- c(")
				
				for i=1,#self.planetdefined do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]
					f:write(self.planet[x][y][z].x)
					if i < #self.planetdefined then f:write(", ") end
				end
				
				f:write(")\ny <- c(")
				
				for i=1,#self.planetdefined do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]
					f:write(self.planet[x][y][z].y)
					if i < #self.planetdefined then f:write(", ") end
				end
				
				f:write(")\nz <- c(")
				
				for i=1,#self.planetdefined do
					local x = self.planetdefined[i][1]
					local y = self.planetdefined[i][2]
					local z = self.planetdefined[i][3]
					f:write(self.planet[x][y][z].z)
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
							local found = false
							for k, j in pairs(self.cTriplets) do
								if j[1] > r-30 and j[1] < r+30 then
									if j[2] > g-30 and j[2] < g+30 then
										if j[3] > b-30 and j[3] < b+30 then
											r = math.random(0, 255)
											g = math.random(0, 255)
											b = math.random(0, 255)
											
											found = true
										end
									end
								end
							end
							if found == false then unique = true end
							
							if r > 225 and g > 225 and b > 225 then
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
					for j=1,#self.countries[i].regions do
						for k=1,#self.countries[i].regions[j].cities do
							table.insert(cCoords, {self.countries[i].regions[j].cities[k].x, self.countries[i].regions[j].cities[k].y, self.countries[i].regions[j].cities[k].z})
							table.insert(cTexts, self.countries[i].regions[j].cities[k].name)
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
					if x < 0 then x = x - 3 end
					if x > 0 then x = x + 3 end
					f:write(x)
					if i < #cCoords then f:write(", ") end
				end
				
				f:write(")\ncityy <- c(")
				
				for i=1,#cCoords do
					local y = cCoords[i][2]
					if y < 0 then y = y - 3 end
					if y > 0 then y = y + 3 end
					f:write(y)
					if i < #cCoords then f:write(", ") end
				end
				
				f:write(")\ncityz <- c(")
				
				for i=1,#cCoords do
					local z = cCoords[i][3]
					if z < 0 then z = z - 3 end
					if z > 0 then z = z + 3 end
					f:write(z)
					if i < #cCoords then f:write(", ") end
				end
				
				f:write(")\ncitytexts <- c(")
				
				for i=1,#cTexts do
					local txt = cTexts[i]
					f:write("\""..txt.."\"")
					if i < #cTexts then f:write(", ") end
				end
				
				f:write(")\ninpdata <- data.frame(X=x, Y=y, Z=z)\nplot3d(x=inpdata$X, y=inpdata$Y, z=inpdata$Z, col=csc, size=0.35, xlab=\"\", ylab=\"\", zlab=\"\", box=FALSE, axes=FALSE, top=TRUE, type='s')\nSys.sleep(5)\ntexts3d(x=cityx, y=cityy, z=cityz, texts=citytexts, color=\"#FFFFFF\", cex=0.8)\nSys.sleep(5)\nlegend3d(\"topright\", legend=csd, pch=19, col=cse, cex=2, inset=c(0.02))\nSys.sleep(10000)")

				f:flush()
				f:close()
				f = nil
			end,
			
			update = function(self, parent)
				parent.numCountries = #self.countries
				
				for i=1,#self.countries do
					if self.countries[i] ~= nil then
						self.countries[i]:update(parent, i)
						
						if self.countries[i] ~= nil then
							if self.countries[i].population < 10 then
								if self.countries[i].rulers[#self.countries[i].rulers].To == "Current" then self.countries[i].rulers[#self.countries[i].rulers].To = parent.years end
								self.countries[i]:event(parent, "Disappeared")
								self:delete(i)
							end
						end
					end
				end
				
				if parent.autosaveDur > 0 then
					if math.fmod(parent.years, parent.autosaveDur) == 0 then
						self:autosave(parent)
					end
				end
			end
		}
		
		World.__index = World
		World.__call = function() return World:new() end
		
		return World
	end