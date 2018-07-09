Person = require("CCSCommon.Person")()
Party = require("CCSCommon.Party")()
Country = require("CCSCommon.Country")()
World = require("CCSCommon.World")()

return
	function()
		local CCSCommon = {
			numCountries = 0,

			clrcmd = "",
			showinfo = 0,

			maxyears = 0,
			years = 0,
			yearstorun = 0,

			vowels = {"A", "E", "I", "O", "U"},
			consonants = {"B", "C", "D", "F", "G", "H", "L", "M", "N", "P", "R", "S", "T", "V"},

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
				{"National", "United", "Citizens", "General", "People's", "Joint"},
				{"National", "United", "Citizens", "General", "People's", "Joint"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Economical", "Moral", "Union", "Unionist", "Revivalist"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Economical", "Moral", "Union", "Unionist", "Revivalist"},
				{"Party", "Group", "Front", "Coalition", "Force"},
			},

			final = {},
			thisWorld = nil,

			sleep = function(self, t)
				local n = os.clock()
				while os.clock() <= n + t do end
			end,

			rseed = function(self)
				self:sleep(0.003)
				local tc = tonumber((os.clock()/10)*(os.time()/100000))
				local n = tonumber(tostring(tc):reverse())
				math.randomseed(n)
				math.random(1, 500)
				x = math.random(4, 13)
				for i=2,x do
					math.randomseed(tonumber(tostring(math.random(1, math.floor(i*tc))):reverse()))
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

			deepcopy = function(self, dat)
				local final_type = type(dat)
				local copy
				if final_type == "table" then
					copy = {}
					for final_key, final_value in next, dat, nil do
						copy[self:deepcopy(final_key)] = self:deepcopy(final_value)
					end
					setmetatable(copy, self:deepcopy(getmetatable(dat)))
				elseif final_type == "function" then
					copy = self:fncopy(dat)
				else
					copy = dat
				end
				return copy
			end,

			name = function(self)
				local nom = ""

				local nl = math.random(3, 9)
				local nv = 0
				for i=1,nl do
					local vc = math.random(1, 100)
					if vc < math.random(20, 60) then
						local c = math.random(1, #self.consonants)
						if i == 1 then nom = nom..self.consonants[c] else nom = nom..string.lower(self.consonants[c]) end
					else
						local v = math.random(1, #self.vowels)
						if i == 1 then nom = nom..self.vowels[v] else nom = nom..string.lower(self.vowels[v]) end
						nv = nv + 1
					end
				end

				if nv == 0 then
					local v = math.random(1, #self.vowels)
					nom = nom..string.lower(self.vowels[v])
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

			fromFile = function(self, datin)
				local f = assert(io.open(datin, "r"))
				local done = false
				self.thisWorld = World:new()

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
							nl:setPop(self, 1000)
							self.thisWorld:add(nl)
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

				for i=1,#self.thisWorld.countries do
					if self.thisWorld.countries[i] ~= nil then
						self.thisWorld.countries[i].founded = tonumber(self.thisWorld.countries[i].rulers[1].From)
						self.thisWorld.countries[i].age = self.years - self.thisWorld.countries[i].founded
						self.thisWorld.countries[i]:makename(self)
						table.insert(self.final, self.thisWorld.countries[i])
					end
				end
			end,

			loop = function(self)
				local _running = true
				local pause = false
				local oldmsg = ""
				local msg = ""
				
				os.execute(self.clrcmd)

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
								msg = msg..self.thisWorld.countries[i].name.." ("..self.systems[self.thisWorld.countries[i].system].name..") - Population: "..self.thisWorld.countries[i].population.." ("..#self.thisWorld.countries[i].rulers.." rulers)"
								if self.thisWorld.countries[i].rulers ~= nil then
									if self.thisWorld.countries[i].rulers[#self.thisWorld.countries[i].rulers] ~= nil then
										msg = msg.."\nCurrent ruler: "..self:getRulerString(self.thisWorld.countries[i].rulers[#self.thisWorld.countries[i].rulers])..", age "..self.thisWorld.countries[i].rulerage
										for m=1,#self.thisWorld.countries[i].parties do
											if self.thisWorld.countries[i].rulers[#self.thisWorld.countries[i].rulers].Party == self.thisWorld.countries[i].parties[m].name then
												msg = msg.." ["..self.thisWorld.countries[i].parties[m].name..", "..self.thisWorld.countries[i].parties[m].popularity.."% popularity]"
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
												if i > 1 then msg = msg.."," end
												msg = msg.." "..wars[#wars]
											end
										end
									end
									
									if self.thisWorld.countries[i].ongoing[j].Name == "Civil War" then
										table.insert(wars, self.thisWorld.countries[i].name.." (civil)")
										if i > 1 then msg = msg.."," end
										msg = msg.." "..wars[#wars]
									end
								end
							end

							msg = msg.."\n\nAlliances:"

							for i=1,#self.thisWorld.countries do
								for j=1,#self.thisWorld.countries[i].alliances do
									local found = false
									for k=1,#alliances do
										if alliances[k] == self.thisWorld.countries[i].alliances[j].."-"..self.thisWorld.countries[i].name.." " then found = true end
									end
									if found == false then
										table.insert(alliances, self.thisWorld.countries[i].name.."-"..self.thisWorld.countries[i].alliances[j].." ")
										if i > 1 then msg = msg.."," end
										msg = msg.." "..alliances[#alliances]
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

				print("Done!")
			end,

			c_events = {
				{
					Name="Coup d'Etat",
					Chance=13,
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
					Chance=10,
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

						parent.thisWorld.countries[c].stability = parent.thisWorld.countries[c].stability - 15
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
					Chance=7,
					Target=nil,
					Args=1,
					Inverse=false,
					Begin=function(self, parent, c)
						parent.thisWorld.countries[c]:event(parent, "Beginning of civil war")
					end,
					Step=function(self, parent, c)
						local doEnd = math.random(1, 75)
						if doEnd < 5 then return self:End(parent, c) else return 0 end
					end,
					End=function(self, parent, c)
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

							parent.thisWorld.countries[c]:event(parent, "End of civil war; victory for "..prevTitle..parent.thisWorld.countries[c].people[newRuler].prevName.." "..parent.thisWorld.countries[c].people[newRuler].surname.." of the "..parent.thisWorld.countries[c].people[newRuler].party..", now "..parent.thisWorld.countries[c].people[newRuler].title.." "..parent.thisWorld.countries[c].people[newRuler].name.." "..CCSCommon:roman(namenum).." of "..parent.thisWorld.countries[c].name)
						else
							parent.thisWorld.countries[c]:event(parent, "End of civil war; victory for "..prevTitle..parent.thisWorld.countries[c].people[newRuler].prevName.." "..parent.thisWorld.countries[c].people[newRuler].surname.." of the "..parent.thisWorld.countries[c].people[newRuler].party..", now "..parent.thisWorld.countries[c].people[newRuler].title.." "..parent.thisWorld.countries[c].people[newRuler].name.." "..parent.thisWorld.countries[c].people[newRuler].surname.." of "..parent.thisWorld.countries[c].name)
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
					Chance=15,
					Target=nil,
					Args=2,
					Inverse=true,
					Begin=function(self, parent, c1)
						parent.thisWorld.countries[c1]:event(parent, "Declared war on "..parent.thisWorld.countries[self.Target].name)
						parent.thisWorld.countries[self.Target]:event(parent, "War declared by "..parent.thisWorld.countries[c1].name)
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

						local doEnd = math.random(1, 50)
						if doEnd < 5 then return self:End(parent, c1) else return 0 end
					end,
					End=function(self, parent, c1)
						local c1total = parent.thisWorld.countries[c1].strength
						local c2total = parent.thisWorld.countries[self.Target].strength

						local ac = #parent.thisWorld.countries[c1].alliances
						for i=1,ac do
							local c3 = nil
							for j=1,#parent.thisWorld.countries do
								if parent.thisWorld.countries[j].name == parent.thisWorld.countries[c1].alliances[i] then c3 = parent.thisWorld.countries[j] end
							end

							if c3 ~= nil then c1total = c1total + c3.strength end
						end

						ac = #parent.thisWorld.countries[self.Target].alliances
						for i=1,ac do
							local c3 = nil
							for j=1,#parent.thisWorld.countries do
								if parent.thisWorld.countries[j].name == parent.thisWorld.countries[self.Target].alliances[i] then c3 = parent.thisWorld.countries[j] end
							end

							if c3 ~= nil then c2total = c2total + c3.strength end
						end

						if c1total > c2total + 3 then
							parent.thisWorld.countries[c1]:event(parent, "Victory in war with "..parent.thisWorld.countries[self.Target].name)
							parent.thisWorld.countries[self.Target]:event(parent, "Defeat in war with "..parent.thisWorld.countries[c1].name)

							parent.thisWorld.countries[c1].strength = parent.thisWorld.countries[c1].strength + 25
							parent.thisWorld.countries[self.Target].strength = parent.thisWorld.countries[self.Target].strength - 25

							ac = #parent.thisWorld.countries[c1].alliances
							for i=1,ac do
								local c3 = nil
								for j=1,#parent.thisWorld.countries do
									if parent.thisWorld.countries[j].name == parent.thisWorld.countries[c1].alliances[i] then c3 = parent.thisWorld.countries[j] end
								end

								if c3 ~= nil then
									for j=1,#c3.allyOngoing do
										if c3.allyOngoing[j] == self.Name.."?"..parent.thisWorld.countries[c1].name..":"..parent.thisWorld.countries[self.Target].name then
											c3.strength = c3.strength + 5

											c3:event(parent, "Victory with "..parent.thisWorld.countries[c1].name.." against "..parent.thisWorld.countries[self.Target].name)
											table.remove(c3.allyOngoing, j)
											j = #c3.allyOngoing + 1
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
									for j=1,#c3.allyOngoing do
										if c3.allyOngoing[j] == self.Name.."?"..parent.thisWorld.countries[self.Target].name..":"..parent.thisWorld.countries[c1].name then
											c3.strength = c3.strength - 5

											c3:event(parent, "Defeat with "..parent.thisWorld.countries[self.Target].name.." in war with "..parent.thisWorld.countries[c1].name)
											table.remove(c3.allyOngoing, j)
											j = #c3.allyOngoing + 1
										end
									end
								end
							end
						elseif c2total > c1total + 3 then
							parent.thisWorld.countries[c1]:event(parent, "Defeat in war with "..parent.thisWorld.countries[self.Target].name)
							parent.thisWorld.countries[self.Target]:event(parent, "Victory in war with "..parent.thisWorld.countries[c1].name)

							parent.thisWorld.countries[c1].strength = parent.thisWorld.countries[c1].strength - 25
							parent.thisWorld.countries[self.Target].strength = parent.thisWorld.countries[self.Target].strength + 25

							ac = #parent.thisWorld.countries[c1].alliances
							for i=1,ac do
								local c3 = nil
								for j=1,#parent.thisWorld.countries do
									if parent.thisWorld.countries[j].name == parent.thisWorld.countries[c1].alliances[i] then c3 = parent.thisWorld.countries[j] end
								end

								if c3 ~= nil then
									for j=1,#c3.allyOngoing do
										if c3.allyOngoing[j] == self.Name.."?"..parent.thisWorld.countries[c1].name..":"..parent.thisWorld.countries[self.Target].name then
											c3.strength = c3.strength - 5

											c3:event(parent, "Defeat with "..parent.thisWorld.countries[c1].name.." in war with "..parent.thisWorld.countries[self.Target].name)
											table.remove(c3.allyOngoing, j)
											j = #c3.allyOngoing + 1
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
									for j=1,#c3.allyOngoing do
										if c3.allyOngoing[j] == self.Name.."?"..parent.thisWorld.countries[self.Target].name..":"..parent.thisWorld.countries[c1].name then
											c3.strength = c3.strength + 5

											c3:event(parent, "Victory with "..parent.thisWorld.countries[self.Target].name.." against "..parent.thisWorld.countries[c1].name)
											table.remove(c3.allyOngoing, j)
											j = #c3.allyOngoing + 1
										end
									end
								end
							end
						else
							parent.thisWorld.countries[c1]:event(parent, "Treaty in war with "..parent.thisWorld.countries[self.Target].name)
							parent.thisWorld.countries[self.Target]:event(parent, "Treaty in war with "..parent.thisWorld.countries[c1].name)

							ac = #parent.thisWorld.countries[c1].alliances
							for i=1,ac do
								local c3 = nil
								for j=1,#parent.thisWorld.countries do
									if parent.thisWorld.countries[j].name == parent.thisWorld.countries[c1].alliances[i] then c3 = parent.thisWorld.countries[j] end
								end

								if c3 ~= nil then
									for j=1,#c3.allyOngoing do
										if c3.allyOngoing[j] == self.Name.."?"..parent.thisWorld.countries[c1].name..":"..parent.thisWorld.countries[self.Target].name then
											c3:event(parent, "Treaty with "..parent.thisWorld.countries[c1].name.." in war with "..parent.thisWorld.countries[self.Target].name)
											table.remove(c3.allyOngoing, j)
											j = #c3.allyOngoing + 1
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
									for j=1,#c3.allyOngoing do
										if c3.allyOngoing[j] == self.Name.."?"..parent.thisWorld.countries[self.Target].name..":"..parent.thisWorld.countries[c1].name then
											c3:event(parent, "Treaty with "..parent.thisWorld.countries[self.Target].name.." in war with "..parent.thisWorld.countries[c1].name)
											table.remove(c3.allyOngoing, j)
											j = #c3.allyOngoing + 1
										end
									end
								end
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
					Chance=8,
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

						for i=1,#parent.thisWorld.countries[self.Target].alliances do
							if parent.thisWorld.countries[self.Target].alliances[i] == parent.thisWorld.countries[c1].name then
								table.remove(parent.thisWorld.countries[self.Target].alliances, i)
								i = #parent.thisWorld.countries[self.Target].alliances + 1
							end
						end

						for i=1,#parent.thisWorld.countries[c1].alliances do
							if parent.thisWorld.countries[c1].alliances[i] == parent.thisWorld.countries[self.Target].name then
								table.remove(parent.thisWorld.countries[c1].alliances, i)
								i = #parent.thisWorld.countries[c1].alliances + 1
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
					Chance=4,
					Target=nil,
					Args=1,
					Inverse=false,
					Perform=function(self, parent, c)
						local newl = Country:new()
						newl:set(CCSCommon)

						parent.thisWorld.countries[c]:event(parent, "Granted independence to "..newl.name)
						newl:event(parent, "Independence from "..parent.thisWorld.countries[c].name)

						newl.rulers = CCSCommon:deepcopy(parent.thisWorld.countries[c].rulers)
						newl.rulernames = CCSCommon:deepcopy(parent.thisWorld.countries[c].rulernames)

						parent.thisWorld:add(newl)

						parent.thisWorld.countries[c].strength = parent.thisWorld.countries[c].strength - math.random(5, 15)
						if parent.thisWorld.countries[c].strength < 1 then parent.thisWorld.countries[c].strength = 1 end

						parent.thisWorld.countries[c].stability = parent.thisWorld.countries[c].stability - math.random(5, 15)
						if parent.thisWorld.countries[c].stability < 1 then parent.thisWorld.countries[c].stability = 1 end

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
							end
						end

						return -1
					end
				},
				{
					Name="Conquer",
					Chance=4,
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

								parent.thisWorld.countries[c1].strength = parent.thisWorld.countries[c1].strength - parent.thisWorld.countries[c2].strength - 5
								if parent.thisWorld.countries[c1].strength < 1 then parent.thisWorld.countries[c1].strength = 1 end
								parent.thisWorld.countries[c1].stability = parent.thisWorld.countries[c1].stability - parent.thisWorld.countries[c2].stability - 5
								if parent.thisWorld.countries[c1].stability < 1 then parent.thisWorld.countries[c1].stability = 1 end
								parent.thisWorld.countries[c1]:setPop(parent, parent.thisWorld.countries[c1].population + parent.thisWorld.countries[c2].population)
								if #parent.thisWorld.countries[c2].rulers > 0 then
									parent.thisWorld.countries[c2].rulers[#parent.thisWorld.countries[c2].rulers].To = parent.years
								end

								parent.thisWorld:delete(c2)
							end
						end

						return -1
					end
				}
			}
		}

		return CCSCommon
	end
