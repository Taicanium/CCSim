return
	function()
		local World = {
			new = function(self)
				local nm = {}
				setmetatable(nm, {mtname = "World", __index=self, __call=function() return World:new() end})
				
				nm.countries = {}
				nm.planet = {}
				nm.planetdefined = {}
				nm.planetR = 0

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
											if self.countries[i].ongoing[j].Target ~= nil then
												if self.countries[i].ongoing[j].Target == nz then
													table.remove(self.countries[i].ongoing, j)
												elseif self.countries[i].ongoing[j].Target > nz then
													self.countries[i].ongoing[j].Target = self.countries[i].ongoing[j].Target - 1
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
							
							p:destroy()
							p = nil
						end
					end
				end
			end,

			savetable = function(self, parent, t, f)
				local exceptions = {"spouse", "metatables"}
				local types = {["string"]=1, ["number"]=2, ["boolean"]=3, ["table"]=4, ["function"]=5, ["nyx"]=6}
				
				if getmetatable(t) ~= nil then
					f:write(string.len(tostring(string.len(getmetatable(t).mtname))))
					f:write(string.len(getmetatable(t).mtname))
					f:write(getmetatable(t).mtname)
				else
					f:write("15nilmt")
				end
				
				for i, j in pairs(t) do
					local isexception = false
					for k=1,#exceptions do if exceptions[k] == tostring(i) then isexception = true end end
					if isexception == false then
						f:write(types[type(i)])
						if types[type(i)] == nil then print(type(i)) os.execute("pause") end
						f:write(string.len(tostring(string.len(tostring(i)))))
						f:write(string.len(tostring(i)))
						f:write(tostring(i))
						f:write(types[type(j)])
						if types[type(j)] == nil then print(type(j)) os.execute("pause") end
						
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
						nextj = self:loadfunction(parent, nexti, f:read(nextlen))
					elseif typej == "table" then
						nextj = self:loadtable(parent, f)
					end
					
					tableout[nexti] = nextj
					typei = types[tonumber(f:read(1))]
				end
				
				if mt ~= "nilmt" then setmetatable(tableout, parent.metatables[mt]) end
				
				return tableout
			end,
			
			getfunctionvalues = function(self, fnname, fn, t)
				local found = false
			
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
						self:getfunctionvalues(fnname, fn, j)
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
				
				local r = math.random(40, 70)
				self.planetR = r
				
				for x=-r,r do
					self.planet[x] = {}
					for y=-r,r do
						self.planet[x][y] = {}
						for z=-r,r do
							local fsqrt = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
							if math.floor(fsqrt) == r or math.ceil(fsqrt) == r then
								self.planet[x][y][z] = {}
								self.planet[x][y][z].x = x
								self.planet[x][y][z].y = y
								self.planet[x][y][z].z = z
								self.planet[x][y][z].country = ""
								self.planet[x][y][z].countryset = false
								
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
				
				while allDefined == false do
					allDefined = true
					defined = 0
				
					for i=1,#self.planetdefined do
						local x = self.planetdefined[i][1]
						local y = self.planetdefined[i][2]
						local z = self.planetdefined[i][3]
						
						if self.planet[x][y][z].country ~= "" then
							if self.planet[x][y][z].countryset == false then
								defined = defined + 1
								for dx=-2,2 do
									for dy=-2,2 do
										for dz=-2,2 do
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
					
					print(tostring(defined/#self.planetdefined*100).."% done")
				end
				
				print("Defining regional boundaries...")
				
				for i=1,#self.countries do
					self.countries[i]:setTerritory(parent)
				end
				
				self:rOutput(parent)
			end,
			
			rOutput = function(self, parent)
				local r = self.planetR
			
				cns = io.output()
				io.output("data.r")
				io.write("x <- c(")
				for x=-r,r do
					for y=-r,r do
						for z=-r,r do
							if self.planet[x][y][z] ~= nil then
								io.write(tostring(x)..", ")
							end
						end
					end
				end

				io.write("0)\ny <- c(")
				for x=-r,r do
					for y=-r,r do
						for z=-r,r do
							if self.planet[x][y][z] ~= nil then
								io.write(tostring(y)..", ")
							end
						end
					end
				end

				io.write("0)\nz <- c(")
				for x=-r,r do
					for y=-r,r do
						for z=-r,r do
							if self.planet[x][y][z] ~= nil then
								io.write(tostring(z)..", ")
							end
						end
					end
				end
				
				io.write("0)\n")
				
				if #self.countries > 0 then
					io.write("cs <- c(")
					for x=-r,r do
						for y=-r,r do
							for z=-r,r do
								if self.planet[x][y][z] ~= nil then
									io.write("\""..self.planet[x][y][z].country.."\", ")
								end
							end
						end
					end
				end
				
				io.write("\"\")\n")
				
				io.write("library(\"rgl\")\nlibrary(\"car\")\ninpdata <- data.frame(X=x, Y=y, Z=z)\ncsc <- as.numeric(as.factor(cs))\ncsd <- paste(levels(as.factor(cs)))\ncse <- paste(levels(as.factor(csc)))\nscatter3d(x=inpdata[[1]], y=inpdata[[2]], z=inpdata[[3]], pch=19, cex.symbols=1.5, fill=FALSE, grid=FALSE, surface=FALSE, fogtype=\"none\", point.col=csc)\nlegend3d(\"topright\", legend=csd, pch=19, col=cse, cex=1, inset=c(0.02))\nSys.sleep(10000)")

				io.write()
				io.flush()
				io.output(cns)
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
		
		return World
	end