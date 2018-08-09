Person = require("CCSCommon.Person")()
Party = require("CCSCommon.Party")()
City = require("CCSCommon.City")()
Region = require("CCSCommon.Region")()
Country = require("CCSCommon.Country")()
World = require("CCSCommon.World")()

return
	function()
		CCSCommon = {
			metatables = {{World, "World"}, {Country, "Country"}, {Region, "Region"}, {City, "City"}, {Person, "Person"}, {Party, "Party"}},
			
			autosaveDur = 100,
			doR = false,
		
			numCountries = 0,
			popLimit = 10000,

			clrcmd = "",
			showinfo = 0,

			startyear = 1,
			maxyears = 1,
			years = 1,
			yearstorun = 0,

			initialgroups = {"Ab", "Ac", "Af", "Ag", "Al", "Am", "An", "Ar", "As", "At", "Au", "Av", "Ba", "Be", "Bh", "Bi", "Bo", "Bu", "Ca", "Ce", "Ch", "Ci", "Cl", "Co", "Cr", "Cu", "Da", "De", "Di", "Do", "Du", "Dr", "Ec", "El", "Er", "Fa", "Fr", "Ga", "Ge", "Go", "Gr", "Gh", "Ha", "He", "Hi", "Ho", "Hu", "Ja", "Ji", "Jo", "Ka", "Ke", "Ki", "Ko", "Ku", "Kr", "Kh", "La", "Le", "Li", "Lo", "Lu", "Lh", "Ma", "Me", "Mi", "Mo", "Mu", "Na", "Ne", "Ni", "No", "Nu", "Pa", "Pe", "Pi", "Po", "Pr", "Ph", "Ra", "Re", "Ri", "Ro", "Ru", "Rh", "Sa", "Se", "Si", "So", "Su", "Sh", "Ta", "Te", "Ti", "To", "Tu", "Tr", "Th", "Va", "Vi", "Vo", "Wa", "Wi", "Wo", "Wh", "Za", "Ze", "Zi", "Zo", "Zu", "Zh", "Tha", "Thu", "The"},
			middlegroups = {"gar", "rit", "er", "ar", "ir", "ra", "rin", "bri", "o", "em", "nor", "nar", "mar", "mor", "an", "at", "et", "the", "thal", "cri", "ma", "na", "sa", "mit", "nit", "shi", "ssa", "ssi", "ret", "thu", "thus", "thar", "then", "min", "ni", "ius", "us", "es", "dos"},
			endgroups = {"land", "ia", "lia", "gia", "ria", "nia", "cia", "y", "ar", "ic", "a", "us", "es", "is", "ec", "tria", "tra", "ric"},
			
			consonants = {"b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "w", "z"},
			vowels = {"a", "e", "i", "o", "u"},
			
			systems = {
				{
					name="Monarchy",
					ranks={"Homeless", "Citizen", "Mayor", "Knight", "Baron", "Viscount", "Earl", "Marquis", "Lord", "Duke", "Prince", "King"},
					franks={"Homeless", "Citizen", "Mayor", "Dame", "Baroness", "Viscountess", "Countess", "Marquess", "Lady", "Duchess", "Princess", "Queen"},
					formalities={"Kingdom", "Crown", "Lordship", "Autocracy", "Dominion"},
					dynastic=true
				},
				{
					name="Republic",
					ranks={"Homeless", "Citizen", "Commissioner", "Mayor", "Councillor", "Governor", "Judge", "Senator", "Minister", "President"},
					formalities={"Republic", "United Republic", "Nation", "Commonwealth", "Federation"},
					dynastic=false
				},
				{
					name="Democracy",
					ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Senator", "Speaker", "Chairman"},
					formalities={"Union", "Democratic Republic", "Free State", "Realm"},
					dynastic=false
				},
				{
					name="Oligarchy",
					ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Minister", "Oligarch", "Premier"},
					formalities={"People's Republic", "Premiership", "Patriciate"},
					dynastic=false
				},
				{
					name="Empire",
					ranks={"Homeless", "Citizen", "Mayor", "Lord", "Governor", "Viceroy", "Prince", "Emperor"},
					franks={"Homeless", "Citizen", "Mayor", "Lady", "Governor", "Vicereine", "Princess", "Empress"},
					formalities={"Empire", "Emirate", "Magistrate", "Imperium"},
					dynastic=true
				}
			},
			
			partynames = {
				{"National", "United", "Citizens'", "General", "People's", "Joint", "Workers'", "Free", "New"},
				{"National", "United", "Citizens'", "General", "People's", "Joint", "Workers'", "Free", "New"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Democratic", "Republican", "Economical", "Moral", "Ethical", "Union", "Unionist", "Revivalist", "Labor", "Monarchist", "Nationalist", "Reformist"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Democratic", "Republican", "Economical", "Moral", "Ethical", "Union", "Unionist", "Revivalist", "Labor", "Monarchist", "Nationalist", "Reformist"},
				{"Party", "Group", "Front", "Coalition", "Force", "Alliance", "Caucus", "Fellowship"},
			},

			final = {},
			thisWorld = nil,

			sleep = function(self, t)
				n = os.clock()
				while os.clock() < n + t do end
			end,

			rseed = function(self)
				self:sleep(0.0005)
				tc = tonumber((os.clock()/10)*(os.time()/100000))
				n = tonumber(tostring(tc):reverse())
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
				return string.format(data.Title.." "..data.name.." "..self:roman(data.Number).." of "..data.Country.." ("..tostring(data.From).." - "..tostring(data.To)..")")
			end,

			fncopy = function(self, fn)
				dumped = string.dump(fn)
				cloned = load(dumped)
				i = 1
				while true do
					name = debug.getupvalue(fn, i)
					if not name then
						break
					end
					debug.upvaluejoin(cloned, i, fn, i)
					i = i + 1
				end
				return cloned
			end,

			deepnil = function(self, dat)
				final_type = type(dat)
				if final_type == "table" then
					for final_key, final_value in pairs(dat) do
						self:deepnil(dat[final_key])
					end
					dat = nil
				else dat = nil end
			end,
			
			deepcopy = function(self, obj, seen)
				if type(obj) == "function" then return self:fncopy(obj)
				else if type(obj) ~= "table" then return obj end end
				if seen == nil then seen = {} end
				if seen and seen[obj] then return seen[obj] end

				s = seen or {}
				res = setmetatable({}, getmetatable(obj))
				s[obj] = res
				for k, v in pairs(obj) do res[self:deepcopy(k, s)] = self:deepcopy(v, s) end
				return res
			end,

			name = function(self, personal, l)
				nom = ""
				if l == nil then length = math.random(4, 7) else length = math.random(l - 2, l) end
				
				taken = {}
				
				nom = nom..self.initialgroups[math.random(1, #self.initialgroups)]
				table.insert(taken, string.lower(nom))
				
				while string.len(nom) < length do
					ieic = false -- initial ends in consonant
					mbwc = false -- middle begins with consonant
					for i=1,#self.consonants do
						if nom:sub(#nom, -1) == self.consonants[i] then ieic = true end
					end
					
					mid = self.middlegroups[math.random(1, #self.middlegroups)]
					istaken = false
					
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
					ending = self.endgroups[math.random(1, #self.endgroups)]	
					nom = nom..ending
				end
				
				check = true
				
				while check == true do
					check = false
					for i=1,string.len(nom)-1 do
						if string.lower(nom:sub(i, i)) == string.lower(nom:sub(i+1, i+1)) then
							check = true
							
							newnom = ""
							
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
							
							newnom = ""
							
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
							
							newnom = ""
							
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
							
							newnom = ""
							
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
						hasvowel = false
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
							
							newnom = ""
						
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
					
					nomlower = string.lower(nom)
					
					nomlower = nomlower:gsub("aa", "a")
					nomlower = nomlower:gsub("ee", "i")
					nomlower = nomlower:gsub("ii", "i")
					nomlower = nomlower:gsub("oo", "u")
					nomlower = nomlower:gsub("uu", "u")
					nomlower = nomlower:gsub("ou", "o")
					nomlower = nomlower:gsub("kg", "g")
					nomlower = nomlower:gsub("gk", "g")
					nomlower = nomlower:gsub("sz", "s")
					nomlower = nomlower:gsub("ue", "e")
					nomlower = nomlower:gsub("zs", "z")
					nomlower = nomlower:gsub("rz", "z")
					nomlower = nomlower:gsub("dl", "l")
					nomlower = nomlower:gsub("tl", "l")
					nomlower = nomlower:gsub("cg", "c")
					nomlower = nomlower:gsub("gc", "g")
					nomlower = nomlower:gsub("tp", "t")
					nomlower = nomlower:gsub("dt", "t")
					nomlower = nomlower:gsub("td", "t")
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
					nomlower = nomlower:gsub("pb", "b")
					nomlower = nomlower:gsub("tg", "t")
					nomlower = nomlower:gsub("bp", "b")
					nomlower = nomlower:gsub("iy", "y")
					nomlower = nomlower:gsub("fh", "f")
					nomlower = nomlower:gsub("uo", "o")
					nomlower = nomlower:gsub("vh", "v")
					nomlower = nomlower:gsub("vd", "v")
					nomlower = nomlower:gsub("ki", "ci")
					nomlower = nomlower:gsub("fv", "v")
					nomlower = nomlower:gsub("vf", "f")
					nomlower = nomlower:gsub("vt", "t")
					nomlower = nomlower:gsub("aia", "ia")
					nomlower = nomlower:gsub("eia", "ia")
					nomlower = nomlower:gsub("oia", "ia")
					nomlower = nomlower:gsub("uia", "ia")
					
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
							if nomlower:sub(2, 2) == "r" then nomlower = nomlower:sub(2, #nomlower) end
							if nomlower:sub(2, 2) == "s" then nomlower = nomlower:sub(2, #nomlower) end
							if nomlower:sub(2, 2) == "t" then nomlower = nomlower:sub(2, #nomlower) end
							if nomlower:sub(2, 2) == "v" then nomlower = nomlower:sub(2, #nomlower) end
							if nomlower:sub(2, 2) == "z" then nomlower = nomlower:sub(2, #nomlower) end
						end
						
						if nomlower:sub(#nomlower, #nomlower) == self.consonants[j] then
							if nomlower:sub(#nomlower-1, #nomlower-1) == "b" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "c" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "d" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "f" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "g" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "h" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "j" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "k" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "m" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "n" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "p" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "r" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "s" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "t" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "v" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "w" then nomlower = nomlower:sub(1, #nomlower-1) end
							if nomlower:sub(#nomlower-1, #nomlower-1) == "z" then nomlower = nomlower:sub(1, #nomlower-1) end
						end
					end
					
					if nomlower ~= string.lower(nom) then check = true end
					
					nom = string.upper(nomlower:sub(1, 1))
					nom = nom..nomlower:sub(2, string.len(nomlower))
				end
				
				if string.len(nom) == 1 then
					nom = nom..string.lower(self.vowels[math.random(1, #self.vowels)])
				end
				
				return nom
			end,

			roman = function(self, n)
				tmp = tonumber(n)
				if tmp == nil then return n end
				fin = ""

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
			
			ordinal = function(self, n)
				tmp = tonumber(n)
				if tmp == nil then return n end
				fin = ""
				
				ts = tostring(n)
				if ts:sub(#ts, #ts) == "1" then
					if ts:sub(#ts-1, #ts-1) == "1" then fin = ts.."th"
					else fin = ts.."st" end
				elseif ts:sub(#ts, #ts) == "2" then
					if ts:sub(#ts-1, #ts-1) == "1" then fin = ts.."th"
					else fin = ts.."nd" end
				elseif ts:sub(#ts, #ts) == "3" then
					if ts:sub(#ts-1, #ts-1) == "1" then fin = ts.."th"
					else fin = ts.."rd" end
				else fin = ts.."th" end
				
				return fin
			end,
			
			RegionTransfer = function(self, c1, c2, r, cont)
				if self.thisWorld.countries[c1] ~= nil and self.thisWorld.countries[c2] ~= nil then
					local rCount = 0
					for i, j in pairs(self.thisWorld.countries[c2].regions) do
						rCount = rCount + 1
					end
					
					local lim = 1
					if cont == false then lim = 0 end
					
					if rCount > lim then
						local rm = self.thisWorld.countries[c2].regions[r]
						
						if rm ~= nil then
							local rn = Region:new()
							
							rn.name = rm.name
							rn.population = rm.population
							for i=1,#rm.nodes do
								table.insert(rn.nodes, self:deepcopy(rm.nodes[i]))
								self:deepnil(rm.nodes[i])
								rm.nodes[i] = nil
							end
							
							rm.nodes = nil
							
							for i, j in pairs(rm.cities) do
								table.insert(rn.cities, self:deepcopy(j))
							end
							
							self:deepnil(rm.cities)
							rm.cities = nil
							
							for i=1,#self.thisWorld.countries[c2].people do
								if self.thisWorld.countries[c2].people[i] ~= nil then
									if self.thisWorld.countries[c2].people[i].region == rn.name then
										local p = table.remove(self.thisWorld.countries[c2].people, i)
										table.insert(self.thisWorld.countries[c1].people, p)
									end
								end
							end
							
							self:deepnil(self.thisWorld.countries[c2].regions[rn.name])
							self.thisWorld.countries[c2].regions[rn.name] = nil
							
							if cont == true then
								if self.thisWorld.countries[c2].capitalregion == rn.name then
									local msg = "Capital moved from "..self.thisWorld.countries[c2].capitalcity.." to "
								
									self.thisWorld.countries[c2].capitalregion = nil
									self.thisWorld.countries[c2].capitalcity = nil
								
									while self.thisWorld.countries[c2].capitalregion == nil do
										for i, j in pairs(self.thisWorld.countries[c2].regions) do
											local chance = math.random(1, 10)
											if chance == 5 then self.thisWorld.countries[c2].capitalregion = j.name end
										end
									end
									
									while self.thisWorld.countries[c2].capitalcity == nil do
										for i, j in pairs(self.thisWorld.countries[c2].regions[self.thisWorld.countries[c2].capitalregion].cities) do
											local chance = math.random(1, 25)
											if chance == 12 then self.thisWorld.countries[c2].capitalcity = j.name end
										end
									end
									
									msg = msg..self.thisWorld.countries[c2].capitalcity
									self.thisWorld.countries[c2]:event(self, msg)
								end
							end
							
							self.thisWorld.countries[c1].regions[rn.name] = rn
						end
					end
				end
			end,

			fromFile = function(self, datin)
				print("Opening data file...")
				f = assert(io.open(datin, "r"))
				done = false
				self.thisWorld = World:new()

				print("Reading data...")
				
				while done == false do
					l = f:read()
					if l == nil then done = true
					else
						fc = 0
						fr = 0
						mat = {}
						for q in string.gmatch(l, "%S+") do
							table.insert(mat, tostring(q))
						end
						if mat[1] == "Year" then
							self.startyear = tonumber(mat[2])
							self.years = tonumber(mat[2])
							self.maxyears = self.maxyears + self.startyear
						elseif mat[1] == "C" then
							nl = Country:new()
							nl.name = mat[2]
							for q=3,#mat do
								nl.name = nl.name.." "..mat[q]
							end
							self.thisWorld:add(nl)
							fc = #self.thisWorld.countries
						elseif mat[1] == "R" then
							r = Region:new()
							r.name = mat[2]
							for q=3,#mat do
								r.name = r.name.." "..mat[q]
							end
							self.thisWorld.countries[fc].regions[r.name] = r
							fr = r.name
						elseif mat[1] == "S" then
							s = City:new()
							s.name = mat[2]
							for q=3,#mat do
								s.name = s.name.." "..mat[q]
							end
							self.thisWorld.countries[fc].regions[fr].cities[s.name] = s
						elseif mat[1] == "P" then
							s = City:new()
							s.name = mat[2]
							for q=3,#mat do
								s.name = s.name.." "..mat[q]
							end
							self.thisWorld.countries[fc].capitalregion = fr
							self.thisWorld.countries[fc].capitalcity = s.name
							self.thisWorld.countries[fc].regions[fr].cities[s.name] = s
						else
							dynastic = false
							number = 1
							gend = "Male"
							to = self.years
							if #self.thisWorld.countries[fc].rulers > 0 then
								for i=1,#self.thisWorld.countries[fc].rulers do
									if self.thisWorld.countries[fc].rulers[i].name == mat[2] then
										if self.thisWorld.countries[fc].rulers[i].Title == mat[1] then
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
								table.insert(self.thisWorld.countries[fc].rulers, {Title=mat[1], name=mat[2], Number=tostring(number), Country=self.thisWorld.countries[fc].name, From=mat[3], To=mat[4]})
								if mat[5] == "F" then gend = "Female" end
							else
								table.insert(self.thisWorld.countries[fc].rulers, {Title=mat[1], name=mat[2], Number=mat[3], Country=self.thisWorld.countries[fc].name, From=mat[4], To=mat[5]})
								if mat[6] == "F" then gend = "Female" end
							end
							if mat[1] == "King" then self.thisWorld.countries[fc].system = 1 end
							if mat[1] == "President" then self.thisWorld.countries[fc].system = 2 end
							if mat[1] == "Speaker" then self.thisWorld.countries[fc].system = 3 end
							if mat[1] == "Premier" then self.thisWorld.countries[fc].system = 4 end
							if mat[1] == "Emperor" then self.thisWorld.countries[fc].system = 5 end
							if mat[1] == "Queen" then
								self.thisWorld.countries[fc].system = 1
								gend = "Female"
							end
							if mat[1] == "Empress" then
								self.thisWorld.countries[fc].system = 5
								gend = "Female"
							end
							found = false
							for i=1,#self.thisWorld.countries[fc].rulernames do
								if self.thisWorld.countries[fc].rulernames[i] == mat[2] then found = true end
							end
							for i=1,#self.thisWorld.countries[fc].frulernames do
								if self.thisWorld.countries[fc].frulernames[i] == mat[2] then found = true end
							end
							if gend == "Female" then
								if found == false then
									table.insert(self.thisWorld.countries[fc].frulernames, mat[2])
								end
							else
								if found == false then
									table.insert(self.thisWorld.countries[fc].rulernames, mat[2])
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
						self.thisWorld.countries[i]:setPop(self, self.popLimit)
						
						table.insert(self.final, self.thisWorld.countries[i])
					end
				end
				
				self.thisWorld.fromFile = true
			end,

			loop = function(self)
				_running = true
				oldmsg = ""
				msg = ""
				
				print("\nBegin Simulation!")
				
				while _running do
					self.thisWorld:update(self)
					
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
					end
					
					if self.showinfo == 1 then
						wars = {}
						alliances = {}
						
						for i=1,#self.thisWorld.countries do
							if self.thisWorld.countries[i].dfif[self.systems[self.thisWorld.countries[i].system].name] == true then msg = msg..self.thisWorld.countries[i].demonym.." "..self.thisWorld.countries[i].formalities[self.systems[self.thisWorld.countries[i].system].name]
							else msg = msg..self.thisWorld.countries[i].formalities[self.systems[self.thisWorld.countries[i].system].name].." of "..self.thisWorld.countries[i].name end
							msg = msg.." - Population: "..self.thisWorld.countries[i].population.." (average age: "..math.ceil(self.thisWorld.countries[i].averageAge)..")"
							if self.thisWorld.countries[i].capitalregion ~= nil then
								if self.thisWorld.countries[i].capitalcity ~= nil then
									if self.thisWorld.countries[i].regions[self.thisWorld.countries[i].capitalregion] ~= nil then
										if self.thisWorld.countries[i].regions[self.thisWorld.countries[i].capitalregion].cities[self.thisWorld.countries[i].capitalcity] ~= nil then
											msg = msg.."\nCapital: "..self.thisWorld.countries[i].capitalcity.." (pop. "..self.thisWorld.countries[i].regions[self.thisWorld.countries[i].capitalregion].cities[self.thisWorld.countries[i].capitalcity].population..")"
										else msg = msg.."\nCapital: None" end
									else msg = msg.."\nCapital: None" end
								else msg = msg.."\nCapital: None" end
							else msg = msg.."\nCapital: None" end
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

						msg = msg.."\nWars:"
						count = 0
						
						for i=1,#self.thisWorld.countries do
							for j=1,#self.thisWorld.countries[i].ongoing do
								if self.thisWorld.countries[i].ongoing[j].name == "War" then
									if self.thisWorld.countries[self.thisWorld.countries[i].ongoing[j].target] ~= nil then
										found = false
										for k=1,#wars do
											if wars[k] == self.thisWorld.countries[self.thisWorld.countries[i].ongoing[j].target].name.."-"..self.thisWorld.countries[i].name then found = true end
										end
										if found == false then
											table.insert(wars, self.thisWorld.countries[i].name.."-"..self.thisWorld.countries[self.thisWorld.countries[i].ongoing[j].target].name)
											if count > 0 then msg = msg.."," end
											msg = msg.." "..wars[#wars]
											count = count + 1
										end
									end
								end
								
								if self.thisWorld.countries[i].ongoing[j].name == "Civil War" then
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
								found = false
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

					if self.years >= self.maxyears then
						_running = false
						if self.doR == true then self.thisWorld:rOutput(self, "final.r") end
					end
					
					if #self.thisWorld.countries == 0 then
						_running = false
					end
					
					self.years = self.years + 1
				end
				
				self:finish()
				
				print("\nEnd Simulation!")
			end,

			finish = function(self)
				os.remove("in_progress.dat")
				os.remove("in_progress.r")
			
				print("\nPrinting result...")

				f = io.open("output.txt", "w+")

				for i=1,#self.final do
					newc = false
					fr = 1
					pr = 1
					f:write(string.format("Country "..i..": "..self.final[i].name.."\nFounded: "..self.final[i].founded..", survived for "..self.final[i].age.." years\n\n"))

					for k=1,#self.final[i].events do
						if self.final[i].events[k].Event:sub(1, 12) == "Independence" then
							newc = true
							pr = tonumber(self.final[i].events[k].Year)
						end
					end

					if newc == true then
						f:write(string.format("1. "..self.final[i].rulers[1].Title.." "..self.final[i].rulers[1].name.." "..self:roman(self.final[i].rulers[1].Number).." of "..self.final[i].rulers[1].Country.." ("..tostring(self.final[i].rulers[1].From).." - "..tostring(self.final[i].rulers[1].To)..")").."\n...\n")
						for k=1,#self.final[i].rulers do
							if self.final[i].rulers[k].To ~= "Current" then
								if tonumber(self.final[i].rulers[k].To) >= pr then
									if tonumber(self.final[i].rulers[k].From) < pr then
										f:write(string.format(k..". "..self:getRulerString(self.final[i].rulers[k]).."\n"))
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
									y = self.final[i].events[k].Year
									f:write(string.format(y..": "..self.final[i].events[k].Event.."\n"))
								end
							end
						end

						for k=fr,#self.final[i].rulers do
							if tonumber(self.final[i].rulers[k].From) == j then
								f:write(string.format(k..". "..self:getRulerString(self.final[i].rulers[k]).."\n"))
							end
						end

						for k=1,#self.final[i].events do
							if tonumber(self.final[i].events[k].Year) == j then
								if self.final[i].events[k].Event:sub(1, 10) ~= "Revolution" then
									y = self.final[i].events[k].Year
									f:write(string.format(y..": "..self.final[i].events[k].Event.."\n"))
								end
							end
						end
					end

					f:write("\n\n\n")
				end

				f:flush()
				f:close()
				f = nil
			end,
			
			getAllyOngoing = function(self, country, target, event)
				acOut = {}
			
				ac = #self.thisWorld.countries[country].alliances
				for i=1,ac do
					c3 = nil
					for j=1,#self.thisWorld.countries do
						if self.thisWorld.countries[j].name == self.thisWorld.countries[country].alliances[i] then c3 = j end
					end

					if c3 ~= nil then
						for j=#self.thisWorld.countries[c3].allyOngoing,1,-1 do
							if self.thisWorld.countries[c3].allyOngoing[j] == event.."?"..self.thisWorld.countries[country].name..":"..self.thisWorld.countries[target].name then
								table.insert(acOut, c3)
							end
						end
					end
				end
				
				return acOut
			end,
			
			removeAllyOngoing = function(self, country, target, event)
				ac = #self.thisWorld.countries[country].alliances
				for i=1,ac do
					c3 = nil
					for j=1,#self.thisWorld.countries do
						if self.thisWorld.countries[j].name == self.thisWorld.countries[country].alliances[i] then c3 = j end
					end

					if c3 ~= nil then
						for j=#self.thisWorld.countries[c3].allyOngoing,1,-1 do
							if self.thisWorld.countries[c3].allyOngoing[j] == event.."?"..self.thisWorld.countries[country].name..":"..self.thisWorld.countries[target].name then
								table.remove(self.thisWorld.countries[c3].allyOngoing, j)
							end
						end
					end
				end
			end,
			
			checkAutoload = function(self)
				f = io.open("in_progress.dat", "r")
				if f ~= nil then
					f:close()
					f = nil
				
					io.write("\nAn in-progress run was detected. Load from last save point? (y/n) > ")
					res = io.read()
					
					if res == "y" then
						self.thisWorld:autoload(self)
						return true
					end
				end
				
				return false
			end,

			c_events = {
				{
					name="Coup d'Etat",
					chance=8,
					target=nil,
					args=1,
					inverse=false,
					performEvent=function(self, parent, c)
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
					name="Revolution",
					chance=2,
					target=nil,
					args=1,
					inverse=false,
					performEvent=function(self, parent, c)
						for q=1,#parent.thisWorld.countries[c].people do
							if parent.thisWorld.countries[c].people[q] ~= nil then
								if parent.thisWorld.countries[c].people[q].isruler == true then
									parent.thisWorld.countries[c]:delete(q)
								end
							end
						end

						oldsys = parent.systems[parent.thisWorld.countries[c].system].name

						while parent.systems[parent.thisWorld.countries[c].system].name == oldsys do
							parent.thisWorld.countries[c].system = math.random(1, #parent.systems)
						end

						ind = 1
						for q=1,#parent.thisWorld.countries do
							if parent.thisWorld.countries[q].name == parent.thisWorld.countries[c].name then
								ind = q
								q = #parent.thisWorld.countries + 1
							end
						end
						parent.thisWorld.countries[c]:checkRuler(parent)

						parent.thisWorld.countries[c]:event(parent, "Revolution: "..oldsys.." to "..parent.systems[parent.thisWorld.countries[c].system].name)
						parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name] = parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name] + 1
						if parent.thisWorld.fromFile == false then parent.thisWorld.countries[c]:event(parent, "Establishment of the "..parent:ordinal(parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name]).." "..parent.thisWorld.countries[c].demonym.." "..parent.thisWorld.countries[c].formalities[parent.systems[parent.thisWorld.countries[c].system].name]) end
						
						parent.thisWorld.countries[c].stability = parent.thisWorld.countries[c].stability + 10
						if parent.thisWorld.countries[c].stability < 1 then parent.thisWorld.countries[c].stability = 1 end

						if math.floor(#parent.thisWorld.countries[c].people / 10) > 1 then
							for d=1,math.random(1, math.floor(#parent.thisWorld.countries[c].people / 10)) do
								z = math.random(1, #parent.thisWorld.countries[c].people)
								parent.thisWorld.countries[c]:delete(z)
							end
						end

						parent:rseed()

						
						return -1
					end
				},
				{
					name="Civil War",
					chance=2,
					target=nil,
					args=1,
					inverse=false,
					status = 0,
					opIntervened = {},
					govIntervened = {},
					beginEvent=function(self, parent, c)
						parent.thisWorld.countries[c].civilWars = parent.thisWorld.countries[c].civilWars + 1
						parent.thisWorld.countries[c]:event(parent, "Beginning of "..parent:ordinal(parent.thisWorld.countries[c].civilWars).." civil war")
						self.status = 0 -- -100 is victory for the opposition side; 100 is victory for the present government.
						self.status = self.status + (parent.thisWorld.countries[c].stability - 50)
						self.status = self.status + (parent.thisWorld.countries[c].strength - 50)
						self.opIntervened = {}
						self.govIntervened = {}
					end,
					doStep=function(self, parent, c)
						for i=1,#parent.thisWorld.countries do
							for j=1,#self.opIntervened do if self.opIntervened[j] == parent.thisWorld.countries[i].name then i = c end end
							for j=1,#self.govIntervened do if self.govIntervened[j] == parent.thisWorld.countries[i].name then i = c end end
							if i ~= c then
								if parent.thisWorld.countries[i].relations[parent.thisWorld.countries[c].name] ~= nil then
									if parent.thisWorld.countries[i].relations[parent.thisWorld.countries[c].name] < 50 then
										intervene = math.random(1, parent.thisWorld.countries[i].relations[parent.thisWorld.countries[c].name]*4)
										if intervene == 1 then
											parent.thisWorld.countries[c]:event(parent, "Intervention on the side of the opposition by "..parent.thisWorld.countries[i].name)
											parent.thisWorld.countries[i]:event(parent, "Intervention in the "..parent:ordinal(parent.thisWorld.countries[c].civilWars).." "..parent.thisWorld.countries[c].demonym.." civil war on the side of the opposition")
											table.insert(self.opIntervened, parent.thisWorld.countries[i].name)
										end
									elseif parent.thisWorld.countries[i].relations[parent.thisWorld.countries[c].name] > 50 then
										intervene = math.random(50, (150-parent.thisWorld.countries[i].relations[parent.thisWorld.countries[c].name])*4)
										if intervene == 50 then
											parent.thisWorld.countries[c]:event(parent, "Intervention on the side of the government by "..parent.thisWorld.countries[i].name)
											parent.thisWorld.countries[i]:event(parent, "Intervention in the "..parent:ordinal(parent.thisWorld.countries[c].civilWars).." "..parent.thisWorld.countries[c].demonym.." civil war on the side of the government")
											table.insert(self.govIntervened, parent.thisWorld.countries[i].name)
										end
									end
								end
							end
						end
						
						varistab = parent.thisWorld.countries[c].stability - 50
						varistab = varistab + parent.thisWorld.countries[c].strength - 50
						
						for i=1,#self.opIntervened do
							for j=#parent.thisWorld.countries,1,-1 do
								if parent.thisWorld.countries[j].name == self.opIntervened[i] then
									varistab = varistab - (parent.thisWorld.countries[j].stability - 50)
									varistab = varistab - (parent.thisWorld.countries[j].strength - 50)
									
									j = 1
								end
							end
						end
						
						for i=1,#self.govIntervened do
							for j=#parent.thisWorld.countries,1,-1 do
								if parent.thisWorld.countries[j].name == self.govIntervened[i] then
									varistab = varistab + (parent.thisWorld.countries[j].stability - 50)
									varistab = varistab + (parent.thisWorld.countries[j].strength - 50)
									
									j = 1
								end
							end
						end
						
						self.status = self.status + math.ceil(math.random(varistab-15,varistab+15)/2)
						
						if self.status <= -100 then return self:endEvent(parent, c) elseif self.status >= 100 then return self:endEvent(parent, c) else return 0 end
					end,
					endEvent=function(self, parent, c)
						if self.status >= 100 then -- Government victory
							parent.thisWorld.countries[c]:event(parent, "End of civil war; victory for "..parent.thisWorld.countries[c].rulers[#parent.thisWorld.countries[c].rulers].Title.." "..parent.thisWorld.countries[c].rulers[#parent.thisWorld.countries[c].rulers].name.." "..parent:roman(parent.thisWorld.countries[c].rulers[#parent.thisWorld.countries[c].rulers].Number).." of "..parent.thisWorld.countries[c].rulers[#parent.thisWorld.countries[c].rulers].Country)
						else -- Opposition victory
							for q=1,#parent.thisWorld.countries[c].people do
								if parent.thisWorld.countries[c].people[q] ~= nil then
									if parent.thisWorld.countries[c].people[q].isruler == true then
										parent.thisWorld.countries[c]:delete(q)
									end
								end
							end

							oldsys = parent.systems[parent.thisWorld.countries[c].system].name

							parent.thisWorld.countries[c].system = math.random(1, #parent.systems)

							ind = 1
							for q=1,#parent.thisWorld.countries do
								if parent.thisWorld.countries[q].name == parent.thisWorld.countries[c].name then
									ind = q
									q = #parent.thisWorld.countries + 1
								end
							end
							parent.thisWorld.countries[c]:checkRuler(parent)

							newRuler = nil
							for i=1,#parent.thisWorld.countries[c].people do
								if parent.thisWorld.countries[c].people[i].isruler == true then newRuler = i end
							end

							namenum = 0
							prevTitle = ""
							if parent.thisWorld.countries[c].people[newRuler].prevTitle ~= nil then prevTitle = parent.thisWorld.countries[c].people[newRuler].prevTitle.." " end

							if prevTitle == "Homeless " then prevTitle = "" end
							if prevTitle == "Citizen " then prevTitle = "" end
							if prevTitle == "Mayor " then prevTitle = "" end

							if parent.systems[parent.thisWorld.countries[c].system].dynastic == true then
								for i=1,#parent.thisWorld.countries[c].rulers do
									if tonumber(parent.thisWorld.countries[c].rulers[i].From) >= parent.thisWorld.countries[c].founded then
										if parent.thisWorld.countries[c].rulers[i].name == parent.thisWorld.countries[c].people[newRuler].name then
											if parent.thisWorld.countries[c].rulers[i].Title == parent.thisWorld.countries[c].people[newRuler].title then
												namenum = namenum + 1
											end
										end
									end
								end

								parent.thisWorld.countries[c]:event(parent, "End of civil war; victory for "..prevTitle..parent.thisWorld.countries[c].people[newRuler].prevName.." "..parent.thisWorld.countries[c].people[newRuler].surname.." of the "..parent.thisWorld.countries[c].people[newRuler].party..", now "..parent.thisWorld.countries[c].people[newRuler].title.." "..parent.thisWorld.countries[c].people[newRuler].name.." "..parent:roman(namenum).." of "..parent.thisWorld.countries[c].name)
								parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name] = parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name] + 1
								if parent.thisWorld.fromFile == false then parent.thisWorld.countries[c]:event(parent, "Establishment of the "..parent:ordinal(parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name]).." "..parent.thisWorld.countries[c].demonym.." "..parent.thisWorld.countries[c].formalities[parent.systems[parent.thisWorld.countries[c].system].name]) end
							else
								parent.thisWorld.countries[c]:event(parent, "End of civil war; victory for "..prevTitle..parent.thisWorld.countries[c].people[newRuler].prevName.." "..parent.thisWorld.countries[c].people[newRuler].surname.." of the "..parent.thisWorld.countries[c].people[newRuler].party..", now "..parent.thisWorld.countries[c].people[newRuler].title.." "..parent.thisWorld.countries[c].people[newRuler].name.." "..parent.thisWorld.countries[c].people[newRuler].surname.." of "..parent.thisWorld.countries[c].name)
								parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name] = parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name] + 1
								if parent.thisWorld.fromFile == false then parent.thisWorld.countries[c]:event(parent, "Establishment of the "..parent:ordinal(parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name]).." "..parent.thisWorld.countries[c].demonym.." "..parent.thisWorld.countries[c].formalities[parent.systems[parent.thisWorld.countries[c].system].name]) end
							end
						end

						return -1
					end,
					performEvent=function(self, parent, c)
						for i=1,#parent.thisWorld.countries[c].ongoing - 1 do
							if parent.thisWorld.countries[c].ongoing[i].name == self.name then return -1 end
						end
						return 0
					end
				},
				{
					name="War",
					chance=10,
					target=nil,
					args=2,
					status = 0,
					inverse=true,
					beginEvent=function(self, parent, c1)
						parent.thisWorld.countries[c1]:event(parent, "Declared war on "..parent.thisWorld.countries[self.target].name)
						parent.thisWorld.countries[self.target]:event(parent, "War declared by "..parent.thisWorld.countries[c1].name)
						self.status = 0 -- -100 is victory for the target; 100 is victory for the initiator.
						self.status = self.status + (parent.thisWorld.countries[c1].stability - 50)
						self.status = self.status + (parent.thisWorld.countries[c1].strength - 50)
					end,
					doStep=function(self, parent, c1)
						ao = parent:getAllyOngoing(c1, self.target, self.name)
						ac = parent.thisWorld.countries[c1].alliances
						
						for i=1,#ac do
							c3 = 1
							for j=1,#parent.thisWorld.countries do if parent.thisWorld.countries[j].name == ac[i] then c3 = j end end
							already = false
							for j=1,#ao do if parent.thisWorld.countries[c3].name == parent.thisWorld.countries[ao[j]].name then already = true end end
							if already == false then
								ic = math.random(1, 25)
								if ic == 10 then
									table.insert(parent.thisWorld.countries[c3].allyOngoing, self.name.."?"..parent.thisWorld.countries[c1].name..":"..parent.thisWorld.countries[self.target].name)

									parent.thisWorld.countries[self.target]:event(parent, "Intervention by "..parent.thisWorld.countries[c3].name.." on the side of "..parent.thisWorld.countries[c1].name)
									parent.thisWorld.countries[c1]:event(parent, "Intervention by "..parent.thisWorld.countries[c3].name.." against "..parent.thisWorld.countries[self.target].name)
									parent.thisWorld.countries[c3]:event(parent, "Intervened on the side of "..parent.thisWorld.countries[c1].name.." in war with "..parent.thisWorld.countries[self.target].name)
								end
							end
						end

						ao = parent:getAllyOngoing(self.target, c1, self.name)
						ac = parent.thisWorld.countries[self.target].alliances
						
						for i=1,#ac do
							c3 = 1
							for j=1,#parent.thisWorld.countries do if parent.thisWorld.countries[j].name == ac[i] then c3 = j end end
							already = false
							for j=1,#ao do if parent.thisWorld.countries[c3].name == parent.thisWorld.countries[ao[j]].name then already = true end end
							if already == false then
								ic = math.random(1, 25)
								if ic == 10 then
									table.insert(parent.thisWorld.countries[c3].allyOngoing, self.name.."?"..parent.thisWorld.countries[self.target].name..":"..parent.thisWorld.countries[c1].name)

									parent.thisWorld.countries[c1]:event(parent, "Intervention by "..parent.thisWorld.countries[c3].name.." on the side of "..parent.thisWorld.countries[self.target].name)
									parent.thisWorld.countries[self.target]:event(parent, "Intervention by "..parent.thisWorld.countries[c3].name.." against "..parent.thisWorld.countries[c1].name)
									parent.thisWorld.countries[c3]:event(parent, "Intervened on the side of "..parent.thisWorld.countries[self.target].name.." in war with "..parent.thisWorld.countries[c1].name)
								end
							end
						end
						
						varistab = parent.thisWorld.countries[c1].stability - 50
						varistab = varistab + parent.thisWorld.countries[c1].strength - 50
						
						ao = parent:getAllyOngoing(c1, self.target, self.name)
						
						for i=1,#ao do
							varistab = varistab + parent.thisWorld.countries[ao[i]].stability - 50
							varistab = varistab + parent.thisWorld.countries[ao[i]].strength - 50
						end
						
						ao = parent:getAllyOngoing(self.target, c1, self.name)

						for i=1,#ao do
							varistab = varistab - parent.thisWorld.countries[ao[i]].stability - 50
							varistab = varistab - parent.thisWorld.countries[ao[i]].strength - 50
						end
						
						self.status = self.status + math.ceil(math.random(varistab-15, varistab+15)/2)
						
						if self.status <= -100 then return self:endEvent(parent, c1) end
					end,
					endEvent=function(self, parent, c1)
						c1strength = parent.thisWorld.countries[c1].strength
						c2strength = parent.thisWorld.countries[self.target].strength
						
						if self.status >= 100 then
							parent.thisWorld.countries[c1]:event(parent, "Victory in war with "..parent.thisWorld.countries[self.target].name)
							parent.thisWorld.countries[self.target]:event(parent, "Defeat in war with "..parent.thisWorld.countries[c1].name)

							parent.thisWorld.countries[c1].strength = parent.thisWorld.countries[c1].strength + 25
							parent.thisWorld.countries[c1].stability = parent.thisWorld.countries[c1].strength + 10
							parent.thisWorld.countries[self.target].strength = parent.thisWorld.countries[self.target].strength - 25
							parent.thisWorld.countries[self.target].stability = parent.thisWorld.countries[self.target].stability - 10

							ao = parent:getAllyOngoing(c1, self.target, self.name)
							
							for i=1,#ao do
								parent.thisWorld.countries[ao[i]]:event(parent, "Victory with "..parent.thisWorld.countries[c1].name.." in war with "..parent.thisWorld.countries[self.target].name)
								parent.thisWorld.countries[ao[i]].strength = parent.thisWorld.countries[ao[i]].strength + 10
							end
							
							ao = parent:getAllyOngoing(self.target, c1, self.name)

							for i=1,#ao do
								parent.thisWorld.countries[ao[i]]:event(parent, "Defeat with "..parent.thisWorld.countries[self.target].name.." in war with "..parent.thisWorld.countries[c1].name)
								parent.thisWorld.countries[ao[i]].strength = parent.thisWorld.countries[ao[i]].strength - 10
							end
							
							parent:removeAllyOngoing(c1, self.target, self.name)
							parent:removeAllyOngoing(self.target, c1, self.name)
							
							if c1strength > c2strength + 10 then
								local rname = ""
								while rname == nil do
									for q, b in pairs(parent.thisWorld.countries[c2].regions) do
										local chance = math.random(1, 25)
										if chance == 12 then rname = b.name end
									end
								end
								parent:RegionTransfer(c1, self.target, rname, true)
							end
						elseif self.status <= -100 then
							parent.thisWorld.countries[c1]:event(parent, "Defeat in war with "..parent.thisWorld.countries[self.target].name)
							parent.thisWorld.countries[self.target]:event(parent, "Victory in war with "..parent.thisWorld.countries[c1].name)

							parent.thisWorld.countries[c1].strength = parent.thisWorld.countries[c1].strength - 25
							parent.thisWorld.countries[self.target].strength = parent.thisWorld.countries[self.target].strength + 25

							ao = parent:getAllyOngoing(c1, self.target, self.name)
							
							for i=1,#ao do
								parent.thisWorld.countries[ao[i]]:event(parent, "Defeat with "..parent.thisWorld.countries[c1].name.." in war with "..parent.thisWorld.countries[self.target].name)
								parent.thisWorld.countries[ao[i]].strength = parent.thisWorld.countries[ao[i]].strength - 10
							end
							
							ao = parent:getAllyOngoing(self.target, c1, self.name)

							for i=1,#ao do
								parent.thisWorld.countries[ao[i]]:event(parent, "Victory with "..parent.thisWorld.countries[self.target].name.." in war with "..parent.thisWorld.countries[c1].name)
								parent.thisWorld.countries[ao[i]].strength = parent.thisWorld.countries[ao[i]].strength + 10
							end
							
							parent:removeAllyOngoing(c1, self.target, self.name)
							parent:removeAllyOngoing(self.target, c1, self.name)
							
							if c2strength > c1strength + 10 then
								local rname = ""
								while rname == nil do
									for q, b in pairs(parent.thisWorld.countries[c1].regions) do
										local chance = math.random(1, 25)
										if chance == 12 then rname = b.name end
									end
								end
								parent:RegionTransfer(self.target, c1, rname, true)
							end
						end
						
						return -1
					end,
					performEvent=function(self, parent, c1, c2)
						for i=1,#parent.thisWorld.countries[c1].alliances do
							if parent.thisWorld.countries[c1].alliances[i] == parent.thisWorld.countries[c2].name then return -1 end
						end

						for i=1,#parent.thisWorld.countries[c2].alliances do
							if parent.thisWorld.countries[c2].alliances[i] == parent.thisWorld.countries[c1].name then return -1 end
						end

						already = false
						for i=1,#parent.thisWorld.countries[c1].ongoing - 1 do
							if parent.thisWorld.countries[c1].ongoing[i].name == self.name and parent.thisWorld.countries[c1].ongoing[i].target == c2 then return -1 end
						end
						for i=1,#parent.thisWorld.countries[c2].ongoing - 1 do
							if parent.thisWorld.countries[c2].ongoing[i].name == self.name and parent.thisWorld.countries[c2].ongoing[i].target == c1 then return -1 end
						end
						
						if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[c2].name] ~= nil then
							if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[c2].name] < 20 then
								self.target = c2
								return 0
							end
						end
						

						return -1
					end
				},
				{
					name="Alliance",
					chance=12,
					target=nil,
					args=2,
					inverse=true,
					beginEvent=function(self, parent, c1)
						parent.thisWorld.countries[c1]:event(parent, "Entered military alliance with "..parent.thisWorld.countries[self.target].name)
						parent.thisWorld.countries[self.target]:event(parent, "Entered military alliance with "..parent.thisWorld.countries[c1].name)
					end,
					doStep=function(self, parent, c1)
						if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[self.target].name] ~= nil then
							if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[self.target].name] < 40 then
								doEnd = math.random(1, 50)
								if doEnd < 5 then return 0 end
							end
						end

						doEnd = math.random(1, 500)
						if doEnd < 5 then return 0 end
					end,
					endEvent=function(self, parent, c1)
						parent.thisWorld.countries[c1]:event(parent, "Military alliance severed with "..parent.thisWorld.countries[self.target].name)
						parent.thisWorld.countries[self.target]:event(parent, "Military alliance severed with "..parent.thisWorld.countries[c1].name)

						for i=#parent.thisWorld.countries[self.target].alliances,1,-1 do
							if parent.thisWorld.countries[self.target].alliances[i] == parent.thisWorld.countries[c1].name then
								table.remove(parent.thisWorld.countries[self.target].alliances, i)
								i = 0
							end
						end

						for i=#parent.thisWorld.countries[c1].alliances,1,-1 do
							if parent.thisWorld.countries[c1].alliances[i] == parent.thisWorld.countries[self.target].name then
								table.remove(parent.thisWorld.countries[c1].alliances, i)
								i = 0
							end
						end

						
						return -1
					end,
					performEvent=function(self, parent, c1, c2)
						for i=1,#parent.thisWorld.countries[c1].alliances do
							if parent.thisWorld.countries[c1].alliances[i] == parent.thisWorld.countries[c2].name then return -1 end
						end
						for i=1,#parent.thisWorld.countries[c2].alliances do
							if parent.thisWorld.countries[c2].alliances[i] == parent.thisWorld.countries[c1].name then return -1 end
						end

						if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[c2].name] ~= nil then
							if parent.thisWorld.countries[c1].relations[parent.thisWorld.countries[c2].name] > 80 then
								self.target = c2
								table.insert(parent.thisWorld.countries[c2].alliances, parent.thisWorld.countries[c1].name)
								table.insert(parent.thisWorld.countries[c1].alliances, parent.thisWorld.countries[c2].name)
								return 0
							end
						end

						return -1
					end
				},
				{
					name="Independence",
					chance=3,
					target=nil,
					args=1,
					inverse=false,
					performEvent=function(self, parent, c)
						parent:rseed()
					
						local values = {}
						
						for i, j in pairs(parent.thisWorld.countries[c].regions) do
							table.insert(values, j.name)
						end
						
						if #values > 1 then
							local v = values[math.random(1, #values)]
						
							newl = Country:new()
							nc = parent.thisWorld.countries[c].regions[v]
							
							newl.name = nc.name
							
							parent.thisWorld.countries[c]:event(parent, "Granted independence to "..newl.name)
							newl:event(parent, "Independence from "..parent.thisWorld.countries[c].name)
							
							newl:set(parent)
							for i=1,#nc.nodes do
								x = nc.nodes[i][1]
								y = nc.nodes[i][2]
								z = nc.nodes[i][3]
								
								parent.thisWorld.planet[x][y][z].country = newl.name
								parent.thisWorld.planet[x][y][z].region = ""
								parent.thisWorld.planet[x][y][z].city = ""
							end
							
							if parent.doR == true then newl:setTerritory(parent) end
							
							newl.rulers = parent:deepcopy(parent.thisWorld.countries[c].rulers)
							newl.rulernames = parent:deepcopy(parent.thisWorld.countries[c].rulernames)
							
							parent.thisWorld:add(newl)

							parent.thisWorld.countries[c].strength = parent.thisWorld.countries[c].strength - math.random(5, 10)
							if parent.thisWorld.countries[c].strength < 1 then parent.thisWorld.countries[c].strength = 1 end

							parent.thisWorld.countries[c].stability = parent.thisWorld.countries[c].stability - math.random(5, 10)
							if parent.thisWorld.countries[c].stability < 1 then parent.thisWorld.countries[c].stability = 1 end
							
							parent:deepnil(parent.thisWorld.countries[c].regions[v])
							parent.thisWorld.countries[c].regions[v] = nil
						end

						return -1
					end
				},
				{
					name="Invade",
					chance=6,
					target=nil,
					args=2,
					inverse=true,
					performEvent=function(self, parent, c1, c2)
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
								
								rchance = math.random(1, 30)
								if rchance < 5 then
									local rname = ""
									while rname == nil do
										for q, b in pairs(parent.thisWorld.countries[c2].regions) do
											local chance = math.random(1, 25)
											if chance == 12 then rname = b.name end
										end
									end
									parent:RegionTransfer(c1, c2, rname, true)
								end
							end
						end
						

						return -1
					end
				},
				{
					name="Conquer",
					chance=2,
					target=nil,
					args=2,
					inverse=true,
					performEvent=function(self, parent, c1, c2)
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

								for i=#parent.thisWorld.countries[c2].nodes,1,-1 do
									x = parent.thisWorld.countries[c2].nodes[i][1]
									y = parent.thisWorld.countries[c2].nodes[i][2]
									z = parent.thisWorld.countries[c2].nodes[i][3]
									
									parent.thisWorld.planet[x][y][z].country = parent.thisWorld.countries[c1].name
									table.insert(parent.thisWorld.countries[c1].nodes, {x, y, z})
								end
								
								parent.thisWorld.countries[c1].strength = parent.thisWorld.countries[c1].strength - parent.thisWorld.countries[c2].strength
								if parent.thisWorld.countries[c1].strength < 1 then parent.thisWorld.countries[c1].strength = 1 end
								parent.thisWorld.countries[c1].stability = parent.thisWorld.countries[c1].stability - 5
								if parent.thisWorld.countries[c1].stability < 1 then parent.thisWorld.countries[c1].stability = 1 end
								parent.thisWorld.countries[c1]:setPop(parent, parent.thisWorld.countries[c1].population + parent.thisWorld.countries[c2].population)
								if #parent.thisWorld.countries[c2].rulers > 0 then
									parent.thisWorld.countries[c2].rulers[#parent.thisWorld.countries[c2].rulers].To = parent.years
								end
								
								for i, j in pairs(parent.thisWorld.countries[c2].regions) do
									parent:RegionTransfer(c1, c2, j.name, false)
								end
								
								parent.thisWorld:delete(c2)
							end
						end

						return -1
					end
				},
				{
					name="Capital Migration",
					chance=3,
					target=nil,
					args=1,
					inverse=false,
					performEvent=function(self, parent, c)
						local oldcap = parent.thisWorld.countries[c].capitalcity
						if oldcap == nil then oldcap = "" end
						parent.thisWorld.countries[c].capitalregion = nil
						parent.thisWorld.countries[c].capitalcity = nil
						
						while parent.thisWorld.countries[c].capitalcity == nil do
							for i, j in pairs(parent.thisWorld.countries[c].regions) do
								for k, l in pairs(j.cities) do
									if l.name ~= oldcap then
										local chance = math.random(1, 50)
										if chance == 25 then
											parent.thisWorld.countries[c].capitalregion = j.name
											parent.thisWorld.countries[c].capitalcity = l.name
											
											local msg = "Capital moved"
											if oldcap ~= "" then msg = msg.." from "..oldcap end
											msg = msg.." to "..parent.thisWorld.countries[c].capitalcity
											
											parent.thisWorld.countries[c]:event(parent, msg)
										end
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
