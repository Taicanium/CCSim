Person = require("CCSCommon.Person")()
Party = require("CCSCommon.Party")()
City = require("CCSCommon.City")()
Region = require("CCSCommon.Region")()
Country = require("CCSCommon.Country")()
World = require("CCSCommon.World")()

return
	function()
		local CCSCommon = {
			metatables = {["World"]={mtname = "World", __index=World, __call=function() return World:new() end}, ["Country"]={mtname = "Country", __index=Country, __call=function() return Country:new() end}, ["City"]={mtname = "City", __index=City, __call=function() return City:new() end}, ["Person"]={mtname = "Person", __index=Person, __call=function() return Person:new() end}, ["Party"]={mtname = "Party", __index=Party, __call=function() return Party:new() end}, ["Region"]={mtname = "Region", __index=Region, __call=function() return Region:new() end}},
			
			autosaveDur = 100,
		
			numCountries = 0,

			clrcmd = "",
			showinfo = 0,

			maxyears = 0,
			years = 0,
			yearstorun = 0,

			initialgroups = {"Ab", "Ac", "Af", "Ag", "Al", "Am", "An", "Ar", "As", "At", "Au", "Av", "Ba", "Be", "Bh", "Bi", "Bo", "Bu", "By", "Ca", "Ce", "Ch", "Ci", "Cl", "Co", "Cr", "Cu", "Cy", "Da", "De", "Di", "Do", "Du", "Dr", "Dy", "Ec", "El", "Er", "Fa", "Fr", "Ga", "Ge", "Go", "Gr", "Gh", "Ha", "He", "Hi", "Ho", "Hu", "Ja", "Ji", "Jo", "Ka", "Ke", "Ki", "Ko", "Ku", "Kr", "Kh", "La", "Le", "Li", "Lo", "Lu", "Lh", "Ly", "Ma", "Me", "Mi", "Mo", "Mu", "My", "Na", "Ne", "Ni", "No", "Nu", "Ny", "Pa", "Pe", "Pi", "Po", "Pr", "Ph", "Py", "Ra", "Re", "Ri", "Ro", "Ru", "Rh", "Ry", "Sa", "Se", "Si", "So", "Su", "Sh", "Sy", "Ta", "Te", "Ti", "To", "Tu", "Tr", "Th", "Ty", "Va", "Vi", "Vo", "Wa", "Wi", "Wo", "Wh", "Ya", "Yo", "Yu", "Za", "Ze", "Zi", "Zo", "Zu", "Zh", "Zy", "Tha", "Thu", "The"},
			middlegroups = {"gar", "rit", "er", "ar", "ir", "ra", "rin", "bri", "o", "em", "nor", "nar", "mar", "mor", "an", "at", "et", "the", "thal", "cri", "ma", "na", "sa", "mit", "nit", "shi", "ssa", "ssi", "ret", "thu", "thus", "thar", "then", "min", "ni"},
			endgroups = {"land", "ia", "lia", "gia", "ria", "nia", "cia", "y", "ar", "ich", "a", "us", "es", "is", "ec", "tria", "tra", "rich"},
			
			consonants = {"b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "w", "y", "z"},
			vowels = {"a", "e", "i", "o", "u", "y"},
			
			systems = {
				{
					name="Monarchy",
					ranks={"Homeless", "Citizen", "Mayor", "Knight", "Baron", "Viscount", "Earl", "Marquis", "Lord", "Duke", "Prince", "King"},
					franks={"Homeless", "Citizen", "Mayor", "Dame", "Baroness", "Viscountess", "Countess", "Marquess", "Lady", "Duchess", "Princess", "Queen"},
					dynastic=true
				},
				{
					name="Republic",
					ranks={"Homeless", "Citizen", "Commissioner", "Mayor", "Councillor", "Governor", "Judge", "Senator", "Minister", "President"},
					dynastic=false
				},
				{
					name="Democracy",
					ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Senator", "Speaker", "Chairman"},
					dynastic=false
				},
				{
					name="Oligarchy",
					ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Minister", "Oligarch", "Premier"},
					dynastic=false
				},
				{
					name="Empire",
					ranks={"Homeless", "Citizen", "Mayor", "Lord", "Governor", "Viceroy", "Prince", "Emperor"},
					franks={"Homeless", "Citizen", "Mayor", "Lady", "Governor", "Vicereine", "Princess", "Empress"},
					dynastic=true
				}
			},
			
			partynames = {
				{"National", "United", "Citizens'", "General", "People's", "Joint", "Workers'"},
				{"National", "United", "Citizens'", "General", "People's", "Joint", "Workers'"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Economical", "Moral", "Union", "Unionist", "Revivalist", "Labor"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Economical", "Moral", "Union", "Unionist", "Revivalist", "Labor"},
				{"Party", "Group", "Front", "Coalition", "Force", "Alliance"},
			},

			final = {},
			thisWorld = nil,

			sleep = function(self, t)
				local n = os.clock()
				while os.clock() < n + t do end
			end,

			rseed = function(self)
				self:sleep(0.0005)
				local tc = tonumber((os.clock()/10)*(os.time()/100000))
				local n = tonumber(tostring(tc):reverse())
				math.randomseed(n)
				math.random(1, 500)
				x = math.random(4, 13)
				for i=2,x do
					math.randomseed(math.random(math.floor(n), math.floor(i*n)))
					math.random(1, 500)
				end
				math.random(1, 500)
			end,

			getRulerString = function(self, data)
				return string.format(data.Title.." "..data.Name.." "..self:roman(data.Number).." of "..data.Country.." ("..tostring(data.From).." - "..tostring(data.To)..")")
			end,

			fncopy = function(self, fn)
				local dumped = string.dump(fn)
				local cloned = load(dumped)
				local i = 1
				while true do
					local name = debug.getupvalue(fn, i)
					if not name then
						break
					end
					debug.upvaluejoin(cloned, i, fn, i)
					i = i + 1
				end
				return cloned
			end,

			deepnil = function(self, dat)
				local final_type = type(dat)
				if final_type == "table" then
					for final_key, final_value in next, dat, nil do
						self:deepnil(final_key)
						final_key = nil
						self:deepnil(final_value)
						final_value = nil
					end
					setmetatable(dat, nil)
					dat = nil
				else
					dat = nil
				end
			end,

			name = function(self, personal, l)
				local nom = ""
				if l == nil then length = math.random(4, 7) else length = math.random(l - 2, l) end
				
				local taken = {}
				
				nom = nom..self.initialgroups[math.random(1, #self.initialgroups)]
				table.insert(taken, string.lower(nom))
				
				while string.len(nom) < length do
					local ieic = false -- initial ends in consonant
					local mbwc = false -- middle begins with consonant
					for i=1,#self.consonants do
						if nom:sub(#nom, -1) == self.consonants[i] then ieic = true end
					end
					
					local mid = self.middlegroups[math.random(1, #self.middlegroups)]
					local istaken = false
					
					for i=1,#taken do
						if taken[i] == mid then istaken = true end
					end
					
					for i=1,#self.consonants do
						if mid:sub(1, 1) == self.consonants[i] then mbwc = true end
					end
					
					if istaken == false then
						if ieic == true then
							if mbwc == false then
								nom = nom..mid
								table.insert(taken, mid)
							end
						else
							if mbwc == true then
								nom = nom..mid
								table.insert(taken, mid)
							end
						end
					end
				end
				
				if personal == false then
					local ending = self.endgroups[math.random(1, #self.endgroups)]	
					nom = nom..ending
				end
				
				local check = true
				
				while check == true do
					check = false
					for i=1,string.len(nom)-1 do
						if string.lower(nom:sub(i, i)) == string.lower(nom:sub(i+1, i+1)) then
							check = true
							
							local newnom = ""
							
							for j=1,i do
								newnom = newnom..nom:sub(j, j)
							end
							for j=i+2,string.len(nom) do
								newnom = newnom..nom:sub(j, j)
							end
							
							nom = newnom
						end
					end
					for i=1,string.len(nom)-3 do
						if string.lower(nom:sub(i, i+1)) == string.lower(nom:sub(i+2, i+3)) then
							check = true
							
							local newnom = ""
							
							for j=1,i+1 do
								newnom = newnom..nom:sub(j, j)
							end
							for j=i+4,string.len(nom) do
								newnom = newnom..nom:sub(j, j)
							end
							
							nom = newnom
						end
						if string.lower(nom:sub(i, i)) == string.lower(nom:sub(i+2, i+2)) then
							check = true
							
							local newnom = ""
							
							for j=1,i+1 do
								newnom = newnom..nom:sub(j, j)
							end
							newnom = newnom..self.consonants[math.random(1, #self.consonants)]
							for j=i+3,string.len(nom) do
								newnom = newnom..nom:sub(j, j)
							end
							
							nom = newnom
						end
					end
					for i=1,string.len(nom)-5 do
						if string.lower(nom:sub(i, i+2)) == string.lower(nom:sub(i+3, i+5)) then
							check = true
							
							local newnom = ""
							
							for j=1,i+2 do
								newnom = newnom..nom:sub(j, j)
							end
							for j=i+6,string.len(nom) do
								newnom = newnom..nom:sub(j, j)
							end
							
							nom = newnom
						end
					end
					for i=1,string.len(nom)-2 do
						local hasvowel = false
						for j=i,i+2 do
							for k=1,#self.vowels do
								if string.lower(nom:sub(j, j)) == self.vowels[k] then
									hasvowel = true
								end
							end
							
							if j > i then -- Make an exception for the 'th' group.
								if string.lower(nom:sub(j-1, j-1)) == 't' then
									if string.lower(nom:sub(j, j)) == 'h' then
										hasvowel = true
									end
								end
							end
						end
						
						if hasvowel == false then
							check = true
							
							local newnom = ""
						
							for j=1,i+1 do
								newnom = newnom..nom:sub(j, j)
							end
							newnom = newnom..self.vowels[math.random(1, #self.vowels)]
							for j=i+3,string.len(nom) do
								newnom = newnom..nom:sub(j, j)
							end
							
							nom = newnom
						end
					end
					
					local nomlower = string.lower(nom)
					
					for i=1,2 do						
						nomlower = nomlower:gsub("ee", "i")
						nomlower = nomlower:gsub("yi", "y")
						nomlower = nomlower:gsub("yy", "y")
						nomlower = nomlower:gsub("uu", "u")
						nomlower = nomlower:gsub("ou", "o")
						nomlower = nomlower:gsub("kg", "g")
						nomlower = nomlower:gsub("gk", "g")
						nomlower = nomlower:gsub("sz", "s")
						nomlower = nomlower:gsub("zs", "z")
						nomlower = nomlower:gsub("rz", "z")
						nomlower = nomlower:gsub("y", "t")
						nomlower = nomlower:gsub("dl", "l")
						nomlower = nomlower:gsub("tl", "l")
						nomlower = nomlower:gsub("cg", "c")
						nomlower = nomlower:gsub("gc", "g")
						nomlower = nomlower:gsub("tp", "t")
						nomlower = nomlower:gsub("dt", "t")
						nomlower = nomlower:gsub("ct", "t")
						nomlower = nomlower:gsub("tc", "t")
						nomlower = nomlower:gsub("hc", "c")
						nomlower = nomlower:gsub("fd", "d")
						nomlower = nomlower:gsub("df", "d")
						nomlower = nomlower:gsub("ae", "a")
						nomlower = nomlower:gsub("gl", "l")
						nomlower = nomlower:gsub("bt", "b")
						nomlower = nomlower:gsub("tb", "t")
						nomlower = nomlower:gsub("ua", "a")
						nomlower = nomlower:gsub("oe", "e")
						nomlower = nomlower:gsub("pg", "g")
						nomlower = nomlower:gsub("ui", "i")
						nomlower = nomlower:gsub("mt", "m")
						nomlower = nomlower:gsub("lt", "l")
						nomlower = nomlower:gsub("gj", "g")
						nomlower = nomlower:gsub("tn", "t")
						nomlower = nomlower:gsub("jz", "j")
						nomlower = nomlower:gsub("zt", "t")
						nomlower = nomlower:gsub("gd", "d")
						nomlower = nomlower:gsub("dg", "g")
						nomlower = nomlower:gsub("jg", "j")
						nomlower = nomlower:gsub("jc", "j")
						nomlower = nomlower:gsub("hg", "g")
						nomlower = nomlower:gsub("tm", "t")
						nomlower = nomlower:gsub("oa", "a")
						nomlower = nomlower:gsub("cp", "c")
						nomlower = nomlower:gsub("fh", "f")
						nomlower = nomlower:gsub("uo", "o")
						nomlower = nomlower:gsub("kid", "cid")
						
						for j=1,#self.consonants do
							if nomlower:sub(1, 1) == self.consonants[j] then
								if nomlower:sub(2, 2) == "b" then nomlower = nomlower:sub(2, #nomlower) end
								if nomlower:sub(2, 2) == "c" then nomlower = nomlower:sub(2, #nomlower) end
								if nomlower:sub(2, 2) == "d" then nomlower = nomlower:sub(2, #nomlower) end
								if nomlower:sub(2, 2) == "f" then nomlower = nomlower:sub(2, #nomlower) end
								if nomlower:sub(2, 2) == "g" then nomlower = nomlower:sub(2, #nomlower) end
								if nomlower:sub(2, 2) == "j" then nomlower = nomlower:sub(2, #nomlower) end
								if nomlower:sub(2, 2) == "k" then nomlower = nomlower:sub(2, #nomlower) end
								if nomlower:sub(2, 2) == "m" then nomlower = nomlower:sub(2, #nomlower) end
								if nomlower:sub(2, 2) == "n" then nomlower = nomlower:sub(2, #nomlower) end
								if nomlower:sub(2, 2) == "p" then nomlower = nomlower:sub(2, #nomlower) end
								if nomlower:sub(2, 2) == "s" then nomlower = nomlower:sub(2, #nomlower) end
								if nomlower:sub(2, 2) == "t" then nomlower = nomlower:sub(2, #nomlower) end
								if nomlower:sub(2, 2) == "v" then nomlower = nomlower:sub(2, #nomlower) end
								if nomlower:sub(2, 2) == "z" then nomlower = nomlower:sub(2, #nomlower) end
							end
						end
					end
					
					nom = string.upper(nomlower:sub(1, 1))
					nom = nom..nomlower:sub(2, string.len(nomlower))
				end

				return nom
			end,

			roman = function(self, n)
				local tmp = tonumber(n)
				if tmp == nil then return n end
				local fin = ""

				while tmp - 1000 > -1 do
					fin = fin.."M"
					tmp = tmp - 1000
				end

				while tmp - 900 > -1 do
					fin = fin.."CM"
					tmp = tmp - 900
				end

				while tmp - 500 > -1 do
					fin = fin.."D"
					tmp = tmp - 500
				end

				while tmp - 400 > -1 do
					fin = fin.."CD"
					tmp = tmp - 400
				end

				while tmp - 100 > -1 do
					fin = fin.."C"
					tmp = tmp - 100
				end

				while tmp - 90 > -1 do
					fin = fin.."XC"
					tmp = tmp - 90
				end

				while tmp - 50 > -1 do
					fin = fin.."L"
					tmp = tmp - 50
				end

				while tmp - 40 > -1 do
					fin = fin.."XL"
					tmp = tmp - 40
				end

				while tmp - 10 > -1 do
					fin = fin.."X"
					tmp = tmp - 10
				end

				while tmp - 9 > -1 do
					fin = fin.."IX"
					tmp = tmp - 9
				end

				while tmp - 5 > -1 do
					fin = fin.."V"
					tmp = tmp - 5
				end

				while tmp - 4 > -1 do
					fin = fin.."IV"
					tmp = tmp - 4
				end

				while tmp - 1 > -1 do
					fin = fin.."I"
					tmp = tmp - 1
				end

				return fin
			end,
			
			RegionTransfer = function(self, c1, c2, rm)
				if self.thisWorld.countries[c1] ~= nil and self.thisWorld.countries[c2] ~= nil then
					local r = math.random(1, #self.thisWorld.countries[c2].regions)
					local rm = table.remove(self.thisWorld.countries[c2].regions, r)
					table.insert(self.thisWorld.countries[c1].regions, rm)
					
					for i=#self.thisWorld.countries[c2].people,1,-1 do
						if self.thisWorld.countries[c2].people[i].region == rm.name then
							if self.thisWorld.countries[c2].people[i].isruler == false then
								local pm = table.remove(self.thisWorld.countries[c2].people, i)
								table.insert(self.thisWorld.countries[c1].people, pm)
								i = i - 1
							else
								self.thisWorld.countries[c2].people[i].region = ""
								self.thisWorld.countries[c2].people[i].city = ""
							end
						end
					end
				
					local lossMsg = "Loss of the "..self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].name.." region"
					local gainMsg = "Gained the "..self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].name.." region"
					
					local cCount = #self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities
					if cCount > 1 then
						lossMsg = lossMsg.." (including the cities of "
						gainMsg = gainMsg.." (including the cities of "
					elseif cCount == 1 then
						lossMsg = lossMsg.." (including the city of "
						gainMsg = gainMsg.." (including the city of "
					end
					
					for c=1,#self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities-1 do
						lossMsg = lossMsg..self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities[c].name
						gainMsg = gainMsg..self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities[c].name
						
						if c < #self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities-1 then
							lossMsg = lossMsg..","
							gainMsg = gainMsg..","
						end
						
						lossMsg = lossMsg.." "
						gainMsg = gainMsg.." "
					end
					
					if cCount > 1 then
						lossMsg = lossMsg.."and "..self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities[#self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities].name..")"
						gainMsg = gainMsg.."and "..self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities[#self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities].name..")"
					elseif cCount == 1 then
						lossMsg = lossMsg..self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities[#self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities].name..")"
						gainMsg = gainMsg..self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities[#self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities].name..")"
					end
					
					lossMsg = lossMsg.." to "..self.thisWorld.countries[c1].name
					gainMsg = gainMsg.." from "..self.thisWorld.countries[c2].name
					
					self.thisWorld.countries[c2]:event(self, lossMsg)
					self.thisWorld.countries[c1]:event(self, gainMsg)
				
					local cap = false
					local oldCap = ""
					
					for p=1,#self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities do
						if self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities[p].capital == true then
							cap = true
							self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities[p].capital = false
							oldCap = self.thisWorld.countries[c1].regions[#self.thisWorld.countries[c1].regions].cities[p].name
						end
					end
					
					if cap == true then
						local rc = math.random(1, #self.thisWorld.countries[c2].regions)
						
						if self.thisWorld.countries[c2].regions[rc] ~= nil then
							local cc = math.random(1, #self.thisWorld.countries[c2].regions[rc].cities)
						
							if self.thisWorld.countries[c2].regions[rc].cities[cc] ~= nil then
								self.thisWorld.countries[c2].regions[rc].cities[cc].capital = true
								local msg = "Capital moved "
								if oldCap ~= "" then msg = msg.."from "..oldCap.." " end
								msg = msg.."to "..self.thisWorld.countries[c2].regions[rc].cities[cc].name
								
								self.thisWorld.countries[c2]:event(self, msg)
							end
						end
					end
				end
			end,

			fromFile = function(self, datin)
				print("Opening data file...")
				local f = assert(io.open(datin, "r"))
				local done = false
				self.thisWorld = World:new()

				print("Reading data...")
				
				while done == false do
					local l = f:read()
					if l == nil then done = true
					else
						local mat = {}
						for q in string.gmatch(l, "%S+") do
							table.insert(mat, tostring(q))
						end
						if mat[1] == "Year" then
							self.years = tonumber(mat[2])
							self.maxyears = self.maxyears + self.years
						elseif mat[1] == "C" then
							local nl = Country:new()
							nl.name = mat[2]
							for q=3,#mat do
								nl.name = nl.name.." "..mat[q]
							end
							self.thisWorld:add(nl)
						elseif mat[1] == "R" then
							local r = Region:new()
							r.name = mat[2]
							for q=3,#mat do
								r.name = r.name.." "..mat[q]
							end
							table.insert(self.thisWorld.countries[#self.thisWorld.countries].regions, r)
						elseif mat[1] == "S" then
							local s = City:new()
							s.name = mat[2]
							for q=3,#mat do
								s.name = s.name.." "..mat[q]
							end
							table.insert(self.thisWorld.countries[#self.thisWorld.countries].regions[#self.thisWorld.countries[#self.thisWorld.countries].regions].cities, s)
						elseif mat[1] == "P" then
							local s = City:new()
							s.name = mat[2]
							for q=3,#mat do
								s.name = s.name.." "..mat[q]
							end
							s.capital = true
							table.insert(self.thisWorld.countries[#self.thisWorld.countries].regions[#self.thisWorld.countries[#self.thisWorld.countries].regions].cities, s)
						else
							local dynastic = false
							local number = 1
							local gend = "Male"
							local to = self.years
							if #self.thisWorld.countries[#self.thisWorld.countries].rulers > 0 then
								for i=1,#self.thisWorld.countries[#self.thisWorld.countries].rulers do
									if self.thisWorld.countries[#self.thisWorld.countries].rulers[i].Name == mat[2] then
										if self.thisWorld.countries[#self.thisWorld.countries].rulers[i].Title == mat[1] then
											number = number + 1
										end
									end
								end
							end
							if mat[1] == "King" then dynastic = true end
							if mat[1] == "Emperor" then dynastic = true end
							if mat[1] == "Queen" then dynastic = true end
							if mat[1] == "Empress" then dynastic = true end
							if dynastic == true then
								table.insert(self.thisWorld.countries[#self.thisWorld.countries].rulers, {Title=mat[1], Name=mat[2], Number=tostring(number), Country=self.thisWorld.countries[#self.thisWorld.countries].name, From=mat[3], To=mat[4]})
								if mat[5] == "F" then gend = "Female" end
							else
								table.insert(self.thisWorld.countries[#self.thisWorld.countries].rulers, {Title=mat[1], Name=mat[2], Number=mat[3], Country=self.thisWorld.countries[#self.thisWorld.countries].name, From=mat[4], To=mat[5]})
								if mat[6] == "F" then gend = "Female" end
							end
							if mat[1] == "King" then self.thisWorld.countries[#self.thisWorld.countries].system = 1 end
							if mat[1] == "President" then self.thisWorld.countries[#self.thisWorld.countries].system = 2 end
							if mat[1] == "Speaker" then self.thisWorld.countries[#self.thisWorld.countries].system = 3 end
							if mat[1] == "Premier" then self.thisWorld.countries[#self.thisWorld.countries].system = 4 end
							if mat[1] == "Emperor" then self.thisWorld.countries[#self.thisWorld.countries].system = 5 end
							if mat[1] == "Queen" then
								self.thisWorld.countries[#self.thisWorld.countries].system = 1
								gend = "Female"
							end
							if mat[1] == "Empress" then
								self.thisWorld.countries[#self.thisWorld.countries].system = 5
								gend = "Female"
							end
							local found = false
							for i=1,#self.thisWorld.countries[#self.thisWorld.countries].rulernames do
								if self.thisWorld.countries[#self.thisWorld.countries].rulernames[i] == mat[2] then found = true end
							end
							for i=1,#self.thisWorld.countries[#self.thisWorld.countries].frulernames do
								if self.thisWorld.countries[#self.thisWorld.countries].frulernames[i] == mat[2] then found = true end
							end
							if gend == "Female" then
								if found == false then
									table.insert(self.thisWorld.countries[#self.thisWorld.countries].frulernames, mat[2])
								end
							else
								if found == false then
									table.insert(self.thisWorld.countries[#self.thisWorld.countries].rulernames, mat[2])
								end
							end
						end
					end
				end

				print("Constructing initial populations...")
				
				for i=1,#self.thisWorld.countries do
					if math.fmod(i, 5) == 0 then print(tostring(math.ceil(i/#self.thisWorld.countries*100)).."% done") end 
					if self.thisWorld.countries[i] ~= nil then
						if #self.thisWorld.countries[i].rulers > 0 then
							self.thisWorld.countries[i].founded = tonumber(self.thisWorld.countries[i].rulers[1].From)
							self.thisWorld.countries[i].age = self.years - self.thisWorld.countries[i].founded
						else
							self.thisWorld.countries[i].founded = self.years
							self.thisWorld.countries[i].age = 0
							self.thisWorld.countries[i].system = math.random(1, #self.systems)
						end
						self.thisWorld.countries[i]:makename(self)
						
						self.thisWorld.countries[i]:setPop(self, 1000)
						
						table.insert(self.final, self.thisWorld.countries[i])
					end
				end
			end,

			loop = function(self)
				local _running = true
				local pause = false
				local oldmsg = ""
				local msg = ""
				
				print("\nBegin Simulation!")
				
				while _running do
					self.years = self.years + 1
					self.thisWorld:update(self)
					
					if pause == false then
						os.execute(self.clrcmd)
						msg = "Year "..self.years.." : "..self.numCountries.." countries\n\n"

						for i=1,#self.thisWorld.countries do
							isfinal = true
							for j=1,#self.final do
								if self.final[j].name == self.thisWorld.countries[i].name then isfinal = false end
							end
							if isfinal == true then
								table.insert(self.final, self.thisWorld.countries[i])
							end
							if self.showinfo == 1 then
								msg = msg..self.thisWorld.countries[i].name.." ("..self.systems[self.thisWorld.countries[i].system].name..") - Population: "..self.thisWorld.countries[i].population.." (average age: "..math.ceil(self.thisWorld.countries[i].averageAge)..")"
								msg = msg.."\nCapital: "
								for j=1,#self.thisWorld.countries[i].regions do
									for k=1,#self.thisWorld.countries[i].regions[j].cities do
										if self.thisWorld.countries[i].regions[j].cities[k].capital == true then msg = msg..self.thisWorld.countries[i].regions[j].cities[k].name.." (pop. "..self.thisWorld.countries[i].regions[j].cities[k].population..")" end
									end
								end
								if self.thisWorld.countries[i].rulers ~= nil then
									if self.thisWorld.countries[i].rulers[#self.thisWorld.countries[i].rulers] ~= nil then
										msg = msg.."\nCurrent ruler: "
										if self.thisWorld.countries[i].rulers[#self.thisWorld.countries[i].rulers].To == "Current" then
											msg = msg..self:getRulerString(self.thisWorld.countries[i].rulers[#self.thisWorld.countries[i].rulers])..", age "..self.thisWorld.countries[i].rulerage
											for m=1,#self.thisWorld.countries[i].parties do
												if self.thisWorld.countries[i].rulers[#self.thisWorld.countries[i].rulers].Party == self.thisWorld.countries[i].parties[m].name then
													msg = msg..", of the "..self.thisWorld.countries[i].parties[m].name.." ("..self.thisWorld.countries[i].parties[m].pfreedom.." P, "..self.thisWorld.countries[i].parties[m].efreedom.." E, "..self.thisWorld.countries[i].parties[m].cfreedom.." C), "..self.thisWorld.countries[i].parties[m].popularity.."% popularity"
													if self.thisWorld.countries[i].parties[m].radical == true then msg = msg.." (radical)" end
												end
											end
										else
											msg = msg.."None"
										end
										
										for m=1,#self.thisWorld.countries[i].parties do
											if self.thisWorld.countries[i].parties[m].leading == true then
												msg = msg.."\nRuling party: "..self.thisWorld.countries[i].parties[m].name.." ("..self.thisWorld.countries[i].parties[m].pfreedom.." P, "..self.thisWorld.countries[i].parties[m].efreedom.." E, "..self.thisWorld.countries[i].parties[m].cfreedom.." C), "..self.thisWorld.countries[i].parties[m].popularity.."% popularity"
												if self.thisWorld.countries[i].parties[m].radical == true then msg = msg.." (radical)" end
											end
										end
									end
								end
								msg = msg.."\n\n"
							end
						end

						if self.showinfo == 1 then
							local wars = {}
							local alliances = {}

							msg = msg.."\nWars:"
							local count = 0

							for i=1,#self.thisWorld.countries do
								for j=1,#self.thisWorld.countries[i].ongoing do
									if self.thisWorld.countries[i].ongoing[j].Name == "War" then
										if self.thisWorld.countries[self.thisWorld.countries[i].ongoing[j].Target] ~= nil then
											local found = false
											for k=1,#wars do
												if wars[k] == self.thisWorld.countries[self.thisWorld.countries[i].ongoing[j].Target].name.."-"..self.thisWorld.countries[i].name then found = true end
											end
											if found == false then
												table.insert(wars, self.thisWorld.countries[i].name.."-"..self.thisWorld.countries[self.thisWorld.countries[i].ongoing[j].Target].name)
												if count > 0 then msg = msg.."," end
												msg = msg.." "..wars[#wars]
												count = count + 1
											end
										end
									end
									
									if self.thisWorld.countries[i].ongoing[j].Name == "Civil War" then
										table.insert(wars, self.thisWorld.countries[i].name.." (civil)")
										if count > 0 then msg = msg.."," end
										msg = msg.." "..wars[#wars]
										count = count + 1
									end
								end
							end

							msg = msg.."\n\nAlliances:"
							count = 0

							for i=1,#self.thisWorld.countries do
								for j=1,#self.thisWorld.countries[i].alliances do
									local found = false
									for k=1,#alliances do
										if alliances[k] == self.thisWorld.countries[i].alliances[j].."-"..self.thisWorld.countries[i].name.." " then found = true end
									end
									if found == false then
										table.insert(alliances, self.thisWorld.countries[i].name.."-"..self.thisWorld.countries[i].alliances[j].." ")
										if count > 0 then msg = msg.."," end
										msg = msg.." "..alliances[#alliances]:sub(1, #alliances[#alliances] - 1)
										count = count + 1
									end
								end
							end
						end
						
						print(msg)
						oldmsg = msg
					else
						
					end

					if self.years == self.maxyears then _running = false end
					if #self.thisWorld.countries == 0 then _running = false end
				end
				
				self:finish()
				
				print("\nEnd Simulation!")
			end,

			finish = function(self)
				print("\nPrinting result...")

				cns = io.output()
				io.output("output.txt")

				for i=1,#self.final do
					local newc = false
					local fr = 1
					local pr = 1
					io.write(string.format("Country "..i..": "..self.final[i].name.."\nFounded: "..self.final[i].founded..", survived for "..self.final[i].age.." years\n\n"))

					for k=1,#self.final[i].events do
						if self.final[i].events[k].Event:sub(1, 12) == "Independence" then
							newc = true
							pr = tonumber(self.final[i].events[k].Year)
						end
					end

					if newc == true then
						io.write(string.format("1. "..self.final[i].rulers[1].Title.." "..self.final[i].rulers[1].Name.." "..self:roman(self.final[i].rulers[1].Number).." of "..self.final[i].rulers[1].Country.." ("..tostring(self.final[i].rulers[1].From).." - "..tostring(self.final[i].rulers[1].To)..")").."\n...\n")
						for k=1,#self.final[i].rulers do
							if self.final[i].rulers[k].To ~= "Current" then
								if tonumber(self.final[i].rulers[k].To) >= pr then
									if tonumber(self.final[i].rulers[k].From) < pr then
										io.write(string.format(k..". "..self:getRulerString(self.final[i].rulers[k]).."\n"))
										fr = k + 1
										k = #self.final[i].rulers + 1
									end
								end
							end
						end
					end

					for j=pr,self.maxyears do
						for k=1,#self.final[i].events do
							if tonumber(self.final[i].events[k].Year) == j then
								if self.final[i].events[k].Event:sub(1, 10) == "Revolution" then
									local y = self.final[i].events[k].Year
									io.write(string.format(y..": "..self.final[i].events[k].Event.."\n"))
								end
							end
						end

						for k=fr,#self.final[i].rulers do
							if tonumber(self.final[i].rulers[k].From) == j then
								io.write(string.format(k..". "..self:getRulerString(self.final[i].rulers[k]).."\n"))
							end
						end

						for k=1,#self.final[i].events do
							if tonumber(self.final[i].events[k].Year) == j then
								if self.final[i].events[k].Event:sub(1, 10) ~= "Revolution" then
									local y = self.final[i].events[k].Year
									io.write(string.format(y..": "..self.final[i].events[k].Event.."\n"))
								end
							end
						end
					end

					io.write("\n\n\n")
				end

				io.flush()
				io.output(cns)
			end,
			
			getAllyOngoing = function(self, country, target, event)
				local acOut = {}
			
				ac = #self.thisWorld.countries[country].alliances
				for i=1,ac do
					local c3 = nil
					for j=1,#self.thisWorld.countries do
						if self.thisWorld.countries[j].name == self.thisWorld.countries[country].alliances[i] then c3 = j end
					end

					if c3 ~= nil then
						for j=#self.thisWorld.countries[c3].allyOngoing,1,-1 do
							if self.thisWorld.countries[c3].allyOngoing[j] == event.."?"..self.thisWorld.countries[country].name..":"..self.thisWorld.countries[target].name then
								table.insert(acOut, c3)
								table.remove(self.thisWorld.countries[c3].allyOngoing, j)
								j = 0
							end
						end
					end
				end
				
				return acOut
			end,
			
			checkAutoload = function(self)
				local f = io.open("in_progress.dat", "r")
				if f ~= nil then
					f:close()
					self:deepnil(f)
					f = nil
				
					io.write("\nAn in-progress run was detected. Load from last save point? (y/n) > ")
					local res = io.read()
					
					if res == "y" then
						local savedData = World:autoload(self)
						for i, j in pairs(savedData) do
							if type(j) ~= "function" then
								self:deepnil(self[i])
								self[i] = nil
								self[i] = j
							end
						end
						
						return true
					end
				end
				
				return false
			end,

			c_events = {
				{
					Name="Coup d'Etat",
					Chance=8,
					Target=nil,
					Args=1,
					Inverse=false,
					Perform=function(self, parent, c)
						parent.thisWorld.countries[c]:event(parent, "Coup d'Etat")

						for q=1,#parent.thisWorld.countries[c].people do
							if parent.thisWorld.countries[c].people[q] ~= nil then
								if parent.thisWorld.countries[c].people[q].isruler == true then
									parent.thisWorld.countries[c]:delete(q)
								end
							end
						end

						parent:rseed()

						parent.thisWorld.countries[c].stability = parent.thisWorld.countries[c].stability - 5
						if parent.thisWorld.countries[c].stability < 1 then parent.thisWorld.countries[c].stability = 1 end

						return -1
					end
				},
				{
					Name="Revolution",
					Chance=2,
					Target=nil,
					Args=1,
					Inverse=false,
					Perform=function(self, parent, c)
						for q=1,#parent.thisWorld.countries[c].people do
							if parent.thisWorld.countries[c].people[q] ~= nil then
								if parent.thisWorld.countries[c].people[q].isruler == true then
									parent.thisWorld.countries[c]:delete(q)
								end
							end
						end

						local oldsys = parent.systems[parent.thisWorld.countries[c].system].name

						while parent.systems[parent.thisWorld.countries[c].system].name == oldsys do
							parent.thisWorld.countries[c].system = math.random(1, #parent.systems)
						end

						local ind = 1
						for q=1,#parent.thisWorld.countries do
							if parent.thisWorld.countries[q].name == parent.thisWorld.countries[c].name then
								ind = q
								q = #parent.thisWorld.countries + 1
							end
						end
						parent.thisWorld.countries[c]:checkRuler(parent)

						parent.thisWorld.countries[c]:event(parent, "Revolution: "..oldsys.." to "..parent.systems[parent.thisWorld.countries[c].system].name)

						parent.thisWorld.countries[c].stability = parent.thisWorld.countries[c].stability + 10
						if parent.thisWorld.countries[c].stability < 1 then parent.thisWorld.countries[c].stability = 1 end

						if math.floor(#parent.thisWorld.countries[c].people / 10) > 1 then
							for d=1,math.random(1, math.floor(#parent.thisWorld.countries[c].people / 10)) do
								local z = math.random(1,#parent.thisWorld.countries[c].people)
								parent.thisWorld.countries[c]:delete(z)
							end
						end

						parent:rseed()

						return -1
					end
				},
				{
					Name="Civil War",
					Chance=2,
					Target=nil,
					Args=1,
					Inverse=false,
					Status = 0,
					OpIntervened = {},
					GovIntervened = {},
					Begin=function(self, parent, c)
						parent.thisWorld.countries[c]:event(parent, "Beginning of civil war")
						self.Status = 0 -- -100 is victory for the opposition side; 100 is victory for the present government.
						self.Status = self.Status + (parent.thisWorld.countries[c].stability - 50)
						self.Status = self.Status + (parent.thisWorld.countries[c].strength - 50)
						self.OpIntervened = {}
						self.GovIntervened = {}
					end,
					Step=function(self, parent, c)
						for i=1,#parent.thisWorld.countries do
							for j=1,#self.OpIntervened do if self.OpIntervened[j] == parent.thisWorld.countries[i].name then i = c end end
							for j=1,#self.GovIntervened do if self.GovIntervened[j] == parent.thisWorld.countries[i].name then i = c end end
							if i ~= c then
								if parent.thisWorld.countries[i].relations[parent.thisWorld.countries[c].name] ~= nil then
									if parent.thisWorld.countries[i].relations[parent.thisWorld.countries[c].name] < 50 then
										local intervene = math.random(1, parent.thisWorld.countries[i].relations[parent.thisWorld.countries[c].name]*4)
										if intervene == 1 then
											parent.thisWorld.countries[c]:event(parent, "Intervention on the side of the opposition by "..parent.thisWorld.countries[i].name)
											parent.thisWorld.countries[i]:event(parent, "Intervention in the "..parent.thisWorld.countries[c].name.." civil war on the side of the opposition")
											table.insert(self.OpIntervened, parent.thisWorld.countries[i].name)
										end
									elseif parent.thisWorld.countries[i].relations[parent.thisWorld.countries[c].name] > 50 then
										local intervene = math.random(50, (150-parent.thisWorld.countries[i].relations[parent.thisWorld.countries[c].name])*4)
										if intervene == 50 then
											parent.thisWorld.countries[c]:event(parent, "Intervention on the side of the government by "..parent.thisWorld.countries[i].name)
											parent.thisWorld.countries[i]:event(parent, "Intervention in the "..parent.thisWorld.countries[c].name.." civil war on the side of the government")
											table.insert(self.GovIntervened, parent.thisWorld.countries[i].name)
										end
									end
								end
							end
						end
						
						local varistab = parent.thisWorld.countries[c].stability - 50
						varistab = varistab + parent.thisWorld.countries[c].strength - 50
						
						for i=1,#self.OpIntervened do
							for j=#parent.thisWorld.countries,1,-1 do
								if parent.thisWorld.countries[j].name == self.OpIntervened[i] then
									varistab = varistab - (parent.thisWorld.countries[j].stability - 50)
									varistab = varistab - (parent.thisWorld.countries[j].strength - 50)
									
									j = 1
								end
							end
						end
						
						for i=1,#self.GovIntervened do
							for j=#parent.thisWorld.countries,1,-1 do
								if parent.thisWorld.countries[j].name == self.GovIntervened[i] then
									varistab = varistab + (parent.thisWorld.countries[j].stability - 50)
									varistab = varistab + (parent.thisWorld.countries[j].strength - 50)
									
									j = 1
								end
							end
						end
						
						self.Status = self.Status + math.ceil(math.random(varistab-15,varistab+15)/2)
						
						if self.Status <= -100 then return self:End(parent, c) elseif self.Status >= 100 then return self:End(parent, c) else return 0 end
					end,
					End=function(self, parent, c)
						if self.Status >= 100 then -- Government victory
							parent.thisWorld.countries[c]:event(parent, "End of civil war; victory for "..parent.thisWorld.countries[c].rulers[#parent.thisWorld.countries[c].rulers].Title.." "..parent.thisWorld.countries[c].rulers[#parent.thisWorld.countries[c].rulers].Name.." "..parent:roman(parent.thisWorld.countries[c].rulers[#parent.thisWorld.countries[c].rulers].Number).." of "..parent.thisWorld.countries[c].rulers[#parent.thisWorld.countries[c].rulers].Country)
						else -- Opposition victory
							for q=1,#parent.thisWorld.countries[c].people do
								if parent.thisWorld.countries[c].people[q] ~= nil then
									if parent.thisWorld.countries[c].people[q].isruler == true then
										parent.thisWorld.countries[c]:delete(q)
									end
								end
							end

							local oldsys = parent.systems[parent.thisWorld.countries[c].system].name

							parent.thisWorld.countries[c].system = math.random(1, #parent.systems)

							local ind = 1
							for q=1,#parent.thisWorld.countries do
								if parent.thisWorld.countries[q].name == parent.thisWorld.countries[c].name then
									ind = q
									q = #parent.thisWorld.countries + 1
								end
							end
							parent.thisWorld.countries[c]:checkRuler(parent)

							local newRuler = nil
							for i=1,#parent.thisWorld.countries[c].people do
								if parent.thisWorld.countries[c].people[i].isruler == true then newRuler = i end
							end

							local namenum = 0
							local prevTitle = ""
							if parent.thisWorld.countries[c].people[newRuler].prevTitle ~= nil then prevTitle = parent.thisWorld.countries[c].people[newRuler].prevTitle.." " end

							if prevTitle == "Homeless " then prevTitle = "" end
							if prevTitle == "Citizen " then prevTitle = "" end
							if prevTitle == "Mayor " then prevTitle = "" end

							if parent.systems[parent.thisWorld.countries[c].system].dynastic == true then
								for i=1,#parent.thisWorld.countries[c].rulers do
									if tonumber(parent.thisWorld.countries[c].rulers[i].From) >= parent.thisWorld.countries[c].founded then
										if parent.thisWorld.countries[c].rulers[i].Name == parent.thisWorld.countries[c].people[newRuler].name then
											if parent.thisWorld.countries[c].rulers[i].Title == parent.thisWorld.countries[c].people[newRuler].title then
												namenum = namenum + 1
											end
										end
									end
								end

								parent.thisWorld.countries[c]:event(parent, "End of civil war; victory for "..prevTitle..parent.thisWorld.countries[c].people[newRuler].prevName.." "..parent.thisWorld.countries[c].people[newRuler].surname.." of the "..parent.thisWorld.countries[c].people[newRuler].party..", now "..parent.thisWorld.countries[c].people[newRuler].title.." "..parent.thisWorld.countries[c].people[newRuler].name.." "..parent:roman(namenum).." of "..parent.thisWorld.countries[c].name)
							else
								parent.thisWorld.countries[c]:event(parent, "End of civil war; victory for "..prevTitle..parent.thisWorld.countries[c].people[newRuler].prevName.." "..parent.thisWorld.countries[c].people[newRuler].surname.." of the "..parent.thisWorld.countries[c].people[newRuler].party..", now "..parent.thisWorld.countries[c].people[newRuler].title.." "..parent.thisWorld.countries[c].people[newRuler].name.." "..parent.thisWorld.countries[c].people[newRuler].surname.." of "..parent.thisWorld.countries[c].name)
							end
						end

						return -1
					end,
					Perform=function(self, parent, c)
						for i=1,#parent.thisWorld.countries[c].ongoing - 1 do
							if parent.thisWorld.countries[c].ongoing[i].Name == self.Name then return -1 end
						end
						return 0
					end
				},
				{
					Name="War",
					Chance=12,
					Target=nil,
					Args=2,
					Status = 0,
					Inverse=true,
					Begin=function(self, parent, c1)
						parent.thisWorld.countries[c1]:event(parent, "Declared war on "..parent.thisWorld.countries[self.Target].name)
						parent.thisWorld.countries[self.Target]:event(parent, "War declared by "..parent.thisWorld.countries[c1].name)
						self.Status = 0 -- -100 is victory for the target; 100 is victory for the initiator.
						self.Status = self.Status + (parent.thisWorld.countries[c1].stability - 50)
						self.Status = self.Status + (parent.thisWorld.countries[c1].strength - 50)
					end,
					Step=function(self, parent, c1)
						local ac = #parent.thisWorld.countries[c1].alliances
						for i=1,ac do
							local c3 = nil
							for j=1,#parent.thisWorld.countries do
								if parent.thisWorld.countries[j].name == parent.thisWorld.countries[c1].alliances[i] then c3 = parent.thisWorld.countries[j] end
							end

							if c3 ~= nil then
								local already = false
								for j=1,#c3.allyOngoing do
									if c3.allyOngoing[j] == self.Name.."?"..parent.thisWorld.countries[c1].name..":"..parent.thisWorld.countries[self.Target].name then already = true end
								end

								if already == false then
									local ic = math.random(1, 25)
									if ic == 10 then
										table.insert(c3.allyOngoing, self.Name.."?"..parent.thisWorld.countries[c1].name..":"..parent.thisWorld.countries[self.Target].name)

										parent.thisWorld.countries[c1]:event(parent, "Intervention by "..c3.name.." against "..parent.thisWorld.countries[self.Target].name)
										parent.thisWorld.countries[self.Target]:event(parent, "Intervention by "..c3.name.." on the side of "..parent.thisWorld.countries[c1].name)
										c3:event(parent, "Intervened on the side of "..parent.thisWorld.countries[c1].name.." in war with "..parent.thisWorld.countries[self.Target].name)
									end
								end
							end
						end

						ac = #parent.thisWorld.countries[self.Target].alliances
						for i=1,ac do
							local c3 = nil
							for j=1,#parent.thisWorld.countries do
								if parent.thisWorld.countries[j].name == parent.thisWorld.countries[self.Target].alliances[i] then c3 = parent.thisWorld.countries[j] end
							end

							if c3 ~= nil then
								local already = false
								for j=1,#c3.allyOngoing do
									if c3.allyOngoing[j] == self.Name.."?"..parent.thisWorld.countries[self.Target].name..":"..parent.thisWorld.countries[c1].name then already = true end
								end

								if already == false then
									local ic = math.random(1, 25)
									if ic == 12 then
										table.insert(c3.allyOngoing, self.Name.."?"..parent.thisWorld.countries[self.Target].name..":"..parent.thisWorld.countries[c1].name)

										parent.thisWorld.countries[c1]:event(parent, "Intervention by "..c3.name.." on the side of "..parent.thisWorld.countries[self.Target].name)
										parent.thisWorld.countries[self.Target]:event(parent, "Intervention by "..c3.name.." against "..parent.thisWorld.countries[c1].name)
										c3:event(parent, "Intervened on the side of "..parent.thisWorld.countries[self.Target].name.." in war with "..parent.thisWorld.countries[c1].name)
									end
								end
							end
						end
						
						local varistab = parent.thisWorld.countries[c1].stability - 50
						varistab = varistab + parent.thisWorld.countries[c1].strength - 50
						
						for i=1,#parent:getAllyOngoing(c1, self.Target, self.Name) do
							varistab = varistab + parent.thisWorld.countries[i].stability - 50
							varistab = varistab + parent.thisWorld.countries[i].strength - 50
						end

						for i=1,#parent:getAllyOngoing(self.Target, c1, self.Name) do
							varistab = varistab - parent.thisWorld.countries[i].stability - 50
							varistab = varistab - parent.thisWorld.countries[i].strength - 50
						end
						
						self.Status = self.Status + math.ceil(math.random(varistab-15, varistab+15)/2)
						
						if self.Status <= -100 then return self:End(parent, c1) elseif self.Status >= 100 then return self:End(parent, c1) end
					end,
					End=function(self, parent, c1)
						local c1strength = parent.thisWorld.countries[c1].strength
						local c2strength = parent.thisWorld.countries[self.Target].strength
						
						if self.Status >= 100 then
							parent.thisWorld.countries[c1]:event(parent, "Victory in war with "..parent.thisWorld.countries[self.Target].name)
							parent.thisWorld.countries[self.Target]:event(parent, "Defeat in war with "..parent.thisWorld.countries[c1].name)

							parent.thisWorld.countries[c1].strength = parent.thisWorld.countries[c1].strength + 25
							parent.thisWorld.countries[c1].stability = parent.thisWorld.countries[c1].strength + 10
							parent.thisWorld.countries[self.Target].strength = parent.thisWorld.countries[self.Target].strength - 25
							parent.thisWorld.countries[self.Target].stability = parent.thisWorld.countries[self.Target].stability - 10

							for i=1,#parent:getAllyOngoing(c1, self.Target, self.Name) do
								parent.thisWorld.countries[i]:event(parent, "Victory with "..parent.thisWorld.countries[c1].name.." in war with "..parent.thisWorld.countries[self.Target].name)
								parent.thisWorld.countries[i].strength = parent.thisWorld.countries[i].strength + 10
							end

							for i=1,#parent:getAllyOngoing(self.Target, c1, self.Name) do
								parent.thisWorld.countries[i]:event(parent, "Defeat with "..parent.thisWorld.countries[self.Target].name.." in war with "..parent.thisWorld.countries[c1].name)
								parent.thisWorld.countries[i].strength = parent.thisWorld.countries[i].strength - 10
							end
							
							if c1strength > c2strength + 10 then
								if #parent.thisWorld.countries[self.Target].regions > 1 then
									parent:RegionTransfer(c1, self.Target, rm)
								end
							end
							
							return -1
						elseif self.Status <= -100 then
							parent.thisWorld.countries[c1]:event(parent, "Defeat in war with "..parent.thisWorld.countries[self.Target].name)
							parent.thisWorld.countries[self.Target]:event(parent, "Victory in war with "..parent.thisWorld.countries[c1].name)

							parent.thisWorld.countries[c1].strength = parent.thisWorld.countries[c1].strength - 25
							parent.thisWorld.countries[self.Target].strength = parent.thisWorld.countries[self.Target].strength + 25

							for i=1,#parent:getAllyOngoing(c1, self.Target, self.Name) do
								parent.thisWorld.countries[i]:event(parent, "Defeat with "..parent.thisWorld.countries[c1].name.." in war with "..parent.thisWorld.countries[self.Target].name)
								parent.thisWorld.countries[i].strength = parent.thisWorld.countries[i].strength - 10
							end

							for i=1,#parent:getAllyOngoing(self.Target, c1, self.Name) do
								parent.thisWorld.countries[i]:event(parent, "Victory with "..parent.thisWorld.countries[self.Target].name.." in war with "..parent.thisWorld.countries[c1].name)
								parent.thisWorld.countries[i].strength = parent.thisWorld.countries[i].strength + 10
							end
							
							if c2strength > c1strength + 10 then
								if #parent.thisWorld.countries[c1].regions > 1 then
									parent:RegionTransfer(self.Target, c1, rm)
								end
							end
							
							return -1
						end
						
						return 0
					end,
					Perform=function(self, parent, c1, c2)
						for i=1,#parent.thisWorld.countries[c1].alliances do
							if parent.thisWorld.countries[c1].alliances[i] == parent.thisWorld.countries[c2].name then return -1 end
						end

						for i=1,#parent.thisWorld.countries[c2].alliances do
							if parent.thisWorld.countries[c2].alliances[i] == parent.thisWorld.countries[c1].name then return -1 end
						end

						local already = false
						for i=1,#parent.thisWorld.countries[c1].ongoing - 1 do
							if parent.thisWorld.countries[c1].ongoing[i].Name == self.Name and parent.thisWorld.countries[c1].ongoing[i].Target == c2 then return -1 end
						end
						for i=1,#parent.thisWorld.countries[c2].ongoing - 1 do
							if parent.thisWorld.countries[c2].ongoing[i].Name == self.Name and parent.thisWorld.countries[c2].ongoing[i].Target == c1 then return -1 end
						end
						
						if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[c2].name] ~= nil then
							if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[c2].name] < 20 then
								self.Target = c2
								return 0
							end
						end

						return -1
					end
				},
				{
					Name="Alliance",
					Chance=12,
					Target=nil,
					Args=2,
					Inverse=true,
					Begin=function(self, parent, c1)
						parent.thisWorld.countries[c1]:event(parent, "Entered military alliance with "..parent.thisWorld.countries[self.Target].name)
						parent.thisWorld.countries[self.Target]:event(parent, "Entered military alliance with "..parent.thisWorld.countries[c1].name)
					end,
					Step=function(self, parent, c1)
						if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[self.Target].name] ~= nil then
							if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[self.Target].name] < 40 then
								local doEnd = math.random(1, 50)
								if doEnd < 5 then return self:End(parent, c1) else return 0 end
							end
						end

						local doEnd = math.random(1, 500)
						if doEnd < 5 then return self:End(parent, c1) else return 0 end
					end,
					End=function(self, parent, c1)
						parent.thisWorld.countries[c1]:event(parent, "Military alliance severed with "..parent.thisWorld.countries[self.Target].name)
						parent.thisWorld.countries[self.Target]:event(parent, "Military alliance severed with "..parent.thisWorld.countries[c1].name)

						for i=#parent.thisWorld.countries[self.Target].alliances,1,-1 do
							if parent.thisWorld.countries[self.Target].alliances[i] == parent.thisWorld.countries[c1].name then
								table.remove(parent.thisWorld.countries[self.Target].alliances, i)
								i = 0
							end
						end

						for i=#parent.thisWorld.countries[c1].alliances,1,-1 do
							if parent.thisWorld.countries[c1].alliances[i] == parent.thisWorld.countries[self.Target].name then
								table.remove(parent.thisWorld.countries[c1].alliances, i)
								i = 0
							end
						end

						return -1
					end,
					Perform=function(self, parent, c1, c2)
						for i=1,#parent.thisWorld.countries[c1].alliances do
							if parent.thisWorld.countries[c1].alliances[i] == parent.thisWorld.countries[c2].name then return -1 end
						end
						for i=1,#parent.thisWorld.countries[c2].alliances do
							if parent.thisWorld.countries[c2].alliances[i] == parent.thisWorld.countries[c1].name then return -1 end
						end

						if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[c2].name] ~= nil then
							if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[c2].name] > 80 then
								self.Target = c2
								table.insert(parent.thisWorld.countries[c2].alliances, parent.thisWorld.countries[c1].name)
								table.insert(parent.thisWorld.countries[c1].alliances, parent.thisWorld.countries[c2].name)
								return 0
							end
						end

						return -1
					end
				},
				{
					Name="Independence",
					Chance=3,
					Target=nil,
					Args=1,
					Inverse=false,
					Perform=function(self, parent, c)
						parent:rseed()
					
						if #parent.thisWorld.countries[c].regions > 1 then
							local newl = Country:new()
						
							local nc = table.remove(parent.thisWorld.countries[c].regions, math.random(1, #parent.thisWorld.countries[c].regions))
							
							newl.system = math.random(1, #parent.systems)
							newl.population = math.random(200,1000)
							
							newl:makename(parent)
							newl.name = nc.name
							
							print("Defining country: "..newl.name)
							
							local rCount = math.random(3, 8)
							
							for i=1,rCount do
								local r = Region:new()
								r:makename(newl, parent)
								
								print("Region: "..r.name)
								
								table.insert(newl.regions, r)
							end
							
							local capital = true
							local oldCap = ""
							
							for i=1,#nc.cities do
								local newc = City:new()
								newc.name = nc.cities[i].name
								
								if nc.cities[i].capital == true then
									capital = true
									oldCap = nc.cities[i].name
								end
								
								table.insert(newl.regions[math.random(1, #newl.regions)].cities, newc)
							end
							
							local rc = math.random(1, #newl.regions)
							local cc = math.random(1, #newl.regions[rc].cities)
							newl.regions[rc].cities[cc].capital = true
							
							print("Capital city: "..newl.regions[rc].cities[cc].name.." in the region of "..newl.regions[rc].name)
							print("Constructing initial population with size "..newl.population.."...\n")
							
							for i=1,newl.population do
								local n = Person:new()
								n:makename(parent, newl)
								newl:add(n)
							end
							
							newl.founded = parent.years
							
							parent.thisWorld.countries[c]:event(parent, "Granted independence to "..newl.name)
							newl:event(parent, "Independence from "..parent.thisWorld.countries[c].name)

							newl.rulers = parent.thisWorld.countries[c].rulers
							newl.rulernames = parent.thisWorld.countries[c].rulernames

							parent.thisWorld:add(newl)

							parent.thisWorld.countries[c].strength = parent.thisWorld.countries[c].strength - math.random(5, 15)
							if parent.thisWorld.countries[c].strength < 1 then parent.thisWorld.countries[c].strength = 1 end

							parent.thisWorld.countries[c].stability = parent.thisWorld.countries[c].stability - math.random(5, 15)
							if parent.thisWorld.countries[c].stability < 1 then parent.thisWorld.countries[c].stability = 1 end
							
							if capital == true then
								local regc = math.random(1, #parent.thisWorld.countries[c].regions)
								if #parent.thisWorld.countries[c].regions[regc].cities > 0 then
									local citc = math.random(1, #parent.thisWorld.countries[c].regions[regc].cities)
									parent.thisWorld.countries[c].regions[regc].cities[citc].capital = true
								
									local msg = "Capital moved "
									if oldCap ~= "" then msg = msg.."from "..oldCap end
									msg = msg.."to "..parent.thisWorld.countries[c].regions[regc].cities[citc].name
									parent.thisWorld.countries[c]:event(parent, msg)
								end
							end
						end

						return -1
					end
				},
				{
					Name="Invade",
					Chance=8,
					Target=nil,
					Args=2,
					Inverse=true,
					Perform=function(self, parent, c1, c2)
						for i=1,#parent.thisWorld.countries[c1].alliances do
							if parent.thisWorld.countries[c1].alliances[i] == parent.thisWorld.countries[c2].name then return -1 end
						end

						for i=1,#parent.thisWorld.countries[c2].alliances do
							if parent.thisWorld.countries[c2].alliances[i] == parent.thisWorld.countries[c1].name then return -1 end
						end

						if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[c2].name] ~= nil then
							if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[c2].name] < 11 then
								parent.thisWorld.countries[c1]:event(parent, "Invaded "..parent.thisWorld.countries[c2].name)
								parent.thisWorld.countries[c2]:event(parent, "Invaded by "..parent.thisWorld.countries[c1].name)

								parent.thisWorld.countries[c1].strength = parent.thisWorld.countries[c1].strength - 10
								if parent.thisWorld.countries[c1].strength < 1 then parent.thisWorld.countries[c1].strength = 1 end
								parent.thisWorld.countries[c1].stability = parent.thisWorld.countries[c1].stability - 5
								if parent.thisWorld.countries[c1].stability < 1 then parent.thisWorld.countries[c1].stability = 1 end
								parent.thisWorld.countries[c2].strength = parent.thisWorld.countries[c2].strength - 10
								if parent.thisWorld.countries[c2].strength < 1 then parent.thisWorld.countries[c2].strength = 1 end
								parent.thisWorld.countries[c2].stability = parent.thisWorld.countries[c2].stability - 10
								if parent.thisWorld.countries[c2].stability < 1 then parent.thisWorld.countries[c2].stability = 1 end
								parent.thisWorld.countries[c1]:setPop(parent, math.floor(parent.thisWorld.countries[c1].population / 1.25))
								parent.thisWorld.countries[c2]:setPop(parent, math.floor(parent.thisWorld.countries[c2].population / 1.75))
								
								local rchance = math.random(1, 30)
								if rchance < 5 then
									if #parent.thisWorld.countries[c2].regions > 1 then
										parent:RegionTransfer(c1, c2, rm)
									end
								end
							end
						end

						return -1
					end
				},
				{
					Name="Conquer",
					Chance=3,
					Target=nil,
					Args=2,
					Inverse=true,
					Perform=function(self, parent, c1, c2)
						for i=1,#parent.thisWorld.countries[c1].alliances do
							if parent.thisWorld.countries[c1].alliances[i] == parent.thisWorld.countries[c2].name then return -1 end
						end

						for i=1,#parent.thisWorld.countries[c2].alliances do
							if parent.thisWorld.countries[c2].alliances[i] == parent.thisWorld.countries[c1].name then return -1 end
						end

						if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[c2].name] ~= nil then
							if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[c2].name] < 6 then
								parent.thisWorld.countries[c1]:event(parent, "Conquered "..parent.thisWorld.countries[c2].name)
								parent.thisWorld.countries[c2]:event(parent, "Conquered by "..parent.thisWorld.countries[c1].name)

								parent.thisWorld.countries[c1].strength = parent.thisWorld.countries[c1].strength - parent.thisWorld.countries[c2].strength
								if parent.thisWorld.countries[c1].strength < 1 then parent.thisWorld.countries[c1].strength = 1 end
								parent.thisWorld.countries[c1].stability = parent.thisWorld.countries[c1].stability - 5
								if parent.thisWorld.countries[c1].stability < 1 then parent.thisWorld.countries[c1].stability = 1 end
								parent.thisWorld.countries[c1]:setPop(parent, parent.thisWorld.countries[c1].population + parent.thisWorld.countries[c2].population)
								if #parent.thisWorld.countries[c2].rulers > 0 then
									parent.thisWorld.countries[c2].rulers[#parent.thisWorld.countries[c2].rulers].To = parent.years
								end
								
								for i=1,#parent.thisWorld.countries[c2].regions do
									table.insert(parent.thisWorld.countries[c1].regions, parent.thisWorld.countries[c2].regions[i])
									for j=1,#parent.thisWorld.countries[c1].regions[#parent.thisWorld.countries[c1].regions].cities do
										if parent.thisWorld.countries[c1].regions[#parent.thisWorld.countries[c1].regions].cities[j].capital == true then
											parent.thisWorld.countries[c1].regions[#parent.thisWorld.countries[c1].regions].cities[j].capital = false
										end
									end
								end
								
								for i=1,#parent.thisWorld.countries[c2].regions do
									parent.thisWorld.countries[c2].regions[i] = nil
								end
								
								parent.thisWorld.countries[c2].regions = nil

								parent.thisWorld:delete(c2)
							end
						end

						return -1
					end
				},
				{
					Name="Capital Migration",
					Chance=2,
					Target=nil,
					Args=1,
					Inverse=false,
					Perform=function(self, parent, c)
						if #parent.thisWorld.countries[c].regions > 0 then
							local cCount = 0
							local oldCap = ""
							
							for i=1,#parent.thisWorld.countries[c].regions do
								for j=1,#parent.thisWorld.countries[c].regions[i].cities do
									cCount = cCount + 1
									
									if parent.thisWorld.countries[c].regions[i].cities[j].capital == true then
										oldCap = parent.thisWorld.countries[c].regions[i].cities[j].name
										parent.thisWorld.countries[c].regions[i].cities[j].capital = false
									end
								end
							end
						
							if cCount > 1 then
								local rc = math.random(1, #parent.thisWorld.countries[c].regions)
								if #parent.thisWorld.countries[c].regions[rc].cities > 0 then
									local cc = math.random(1, #parent.thisWorld.countries[c].regions[rc].cities)
								
									if parent.thisWorld.countries[c].regions[rc].cities[cc].name ~= oldCap then
										parent.thisWorld.countries[c]:event(parent, "Capital moved from "..oldCap.." to "..parent.thisWorld.countries[c].regions[rc].cities[cc].name)
										parent.thisWorld.countries[c].regions[rc].cities[cc].capital = true
									end
								end
							end
						end
						
						return -1
					end
				}
			}
		}

		return CCSCommon
	end
