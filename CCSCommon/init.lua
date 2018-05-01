Person = require 'CCSCommon.Person'
Country = require 'CCSCommon.Country'
World = require 'CCSCommon.World'

CCSCommon = {
	mincountries = 3,
	maxcountries = 8,
	numCountries = 0,
	
	clrcmd = "",
	showinfo = 0,
	
	maxyears = 0,
	years = 0,
	yearstorun = 0,
	
	vowels = {"A", "E", "I", "O", "U"},
	consonants = {"B", "C", "D", "F", "G", "H", "L", "M", "N", "P", "R", "S", "T", "V"},
	
	MONARCHY = {name="Monarchy", ranks={"Homeless", "Citizen", "Mayor", "Knight", "Baron", "Viscount", "Earl", "Marquis", "Lord", "Duke", "Prince", "King"}, franks={"Homeless", "Citizen", "Mayor", "Dame", "Baroness", "Viscountess", "Countess", "Marquess", "Lady", "Duchess", "Princess", "Queen"}, dynastic=true},
	REPUBLIC = {name="Republic", ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Judge", "Senator", "Prime Minister", "President"}, dynastic=false},
	DEMOCRACY = {name="Democracy", ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Senator", "Speaker"}, dynastic=false},
	OLIGARCHY = {name="Oligarchy", ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Minister", "Oligarch", "Premier"}, dynastic=false},
	EMPIRE = {name="Empire", ranks={"Homeless", "Citizen", "Mayor", "Lord", "Governor", "Viceroy", "Prince", "Emperor"}, franks={"Homeless", "Citizen", "Mayor", "Lady", "Governor", "Vicereine", "Princess", "Empress"}, dynastic=true},
	
	final = {},
	thisWorld = nil,
	
	sleep = function(self, v)
		local b = os.clock()
		local e = os.clock()
		while e < b + v do
			e = os.clock()
		end
	end,

	rseed = function(self)
		local tc = tonumber(os.clock()*os.time())/1000
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
		CCSCommon.thisWorld = World:new()
		
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
					self.maxyears = self.years + self.yearstorun
				elseif mat[1] == "C" then
					local nl = Country:new()
					nl.name = mat[2]
					for q=3,#mat do
						nl.name = nl.name.." "..mat[q]
					end
					nl:setPop(1000)
					CCSCommon.thisWorld:add(nl)
				else
					local dynastic = false
					local number = 1
					local gend = "Male"
					local to = self.years
					if #CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].rulers > 0 then
						for i=1,#CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].rulers do
							if CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].rulers[i].Name == mat[2] then
								if CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].rulers[i].Title == mat[1] then
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
						table.insert(CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].rulers, {Title=mat[1], Name=mat[2], Number=tostring(number), Country=CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].name, From=mat[3], To=mat[4]})
						if mat[5] == "F" then gend = "Female" end
					else
						table.insert(CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].rulers, {Title=mat[1], Name=mat[2], Number=mat[3], Country=CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].name, From=mat[4], To=mat[5]})
						if mat[6] == "F" then gend = "Female" end
					end
					if mat[1] == "King" then CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].system = 1 end
					if mat[1] == "President" then CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].system = 2 end
					if mat[1] == "Speaker" then CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].system = 3 end
					if mat[1] == "Premier" then CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].system = 4 end
					if mat[1] == "Emperor" then CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].system = 5 end
					if mat[1] == "Queen" then
						CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].system = 1
						gend = "Female"
					end
					if mat[1] == "Empress" then
						CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].system = 5
						gend = "Female"
					end
					local found = false
					for i=1,#CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].rulernames do
						if CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].rulernames[i] == mat[2] then found = true end
					end
					for i=1,#CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].frulernames do
						if CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].frulernames[i] == mat[2] then found = true end
					end
					if gend == "Female" then
						if found == false then
							table.insert(CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].frulernames, mat[2])
						end
					else
						if found == false then
							table.insert(CCSCommon.thisWorld.countries[#CCSCommon.thisWorld.countries].rulernames, mat[2])
						end 
					end
				end
			end
		end
		
		for i=1,#CCSCommon.thisWorld.countries do
			if CCSCommon.thisWorld.countries[i] ~= nil then
				CCSCommon.thisWorld.countries[i].founded = tonumber(CCSCommon.thisWorld.countries[i].rulers[1].From)
				CCSCommon.thisWorld.countries[i].age = self.years - CCSCommon.thisWorld.countries[i].founded
				CCSCommon.thisWorld.countries[i]:makename()
				table.insert(self.final, CCSCommon.thisWorld.countries[i])
			end
		end
	end,

	loop = function(self)
		local _running = true
		
		while _running do
			self.years = self.years + 1
			CCSCommon.thisWorld:update()
			os.execute(self.clrcmd)
			print("Year "..self.years.." : "..self.numCountries.." countries\n")
			
			for i=1,#CCSCommon.thisWorld.countries do
				isfinal = true
				for j=1,#self.final do
					if self.final[j].name == CCSCommon.thisWorld.countries[i].name then isfinal = false end
				end
				if isfinal == true then
					table.insert(self.final, CCSCommon.thisWorld.countries[i])
				end
				if self.showinfo == 1 then
					local msg = CCSCommon.thisWorld.countries[i].name.." ("..self.systems[CCSCommon.thisWorld.countries[i].system].name.."): Population "..CCSCommon.thisWorld.countries[i].population.." ("..#CCSCommon.thisWorld.countries[i].rulers..")"
					if CCSCommon.thisWorld.countries[i].rulers ~= nil then
						if CCSCommon.thisWorld.countries[i].rulers[#CCSCommon.thisWorld.countries[i].rulers] ~= nil then
							msg = msg.." - Current ruler: "..self:getRulerString(CCSCommon.thisWorld.countries[i].rulers[#CCSCommon.thisWorld.countries[i].rulers]).." (age "..CCSCommon.thisWorld.countries[i].rulerage..")"
						end
					end
					print(msg)
				end
			end
			
			if self.showinfo == 1 then
				local wars = {}
				local alliances = {}
			
				local msg = "\nWars:"
			
				for i=1,#CCSCommon.thisWorld.countries do
					for j=1,#CCSCommon.thisWorld.countries[i].ongoing do
						if CCSCommon.thisWorld.countries[i].ongoing[j].Name == "War" then
							if CCSCommon.thisWorld.countries[CCSCommon.thisWorld.countries[i].ongoing[j].Target] ~= nil then
								local found = false
								for k=1,#wars do
									if wars[k] == CCSCommon.thisWorld.countries[CCSCommon.thisWorld.countries[i].ongoing[j].Target].name.."-"..CCSCommon.thisWorld.countries[i].name then found = true end
								end
								if found == false then
									table.insert(wars, CCSCommon.thisWorld.countries[i].name.."-"..CCSCommon.thisWorld.countries[CCSCommon.thisWorld.countries[i].ongoing[j].Target].name)
									msg = msg.." "..wars[#wars]
								end
							end
						end
					end
				end
				
				print(msg)
				
				msg = "\nAlliances:"
			
				for i=1,#CCSCommon.thisWorld.countries do
					for j=1,#CCSCommon.thisWorld.countries[i].alliances do
						local found = false
						for k=1,#alliances do
							if alliances[k] == CCSCommon.thisWorld.countries[i].alliances[j].."-"..CCSCommon.thisWorld.countries[i].name.." " then found = true end
						end
						if found == false then
							table.insert(alliances, CCSCommon.thisWorld.countries[i].name.."-"..CCSCommon.thisWorld.countries[i].alliances[j].." ")
							msg = msg.." "..alliances[#alliances]
						end
					end
				end
				
				print(msg)
			end
			
			if self.years == self.maxyears then _running = false end
		end
	end,

	finish = function(self)
		print("Printing result...")

		cns = io.output()
		io.output("output.txt")
		
		for i=1,#self.final do
			local newc = false
			local fr = 1
			local pr = 1
			io.write(string.format("Country "..i..": "..self.final[i].name.."\nFounded: "..self.final[i].founded..", survived for "..self.final[i].age.." self.years\n\n"))
			
			for k=1,#self.final[i].events do
				if self.final[i].events[k].Event:sub(1, 14) == "Fractured from" or self.final[i].events[k].Event:sub(1, 12) == "Independence" then
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
				for k=fr,#self.final[i].rulers do
					if tonumber(self.final[i].rulers[k].From) == j then
						if self.final[i].rulers[k].Title == nil then print("Title NIL") end
						if self.final[i].rulers[k].Name == nil then print("Name NIL") end
						if self.final[i].rulers[k].Number == nil then print("Number NIL") end
						if self.final[i].rulers[k].Country == nil then print("Country NIL") end
						if self.final[i].rulers[k].From == nil then print("From NIL") end
						if self.final[i].rulers[k].To == nil then print("To NIL") end
						io.write(string.format(k..". "..self:getRulerString(self.final[i].rulers[k]).."\n"))
					end
				end
				
				for k=1,#self.final[i].events do
					if tonumber(self.final[i].events[k].Year) == j then
						local y = self.final[i].events[k].Year
						io.write(string.format(y..": "..self.final[i].events[k].Event.."\n"))
					end
				end
			end
			
			io.write("\n\n\n")
		end
		
		io.flush()
		io.output(cns)
	end,

	c_events = {
		{
			Name="Coup d'Etat",
			Chance=12,
			Target=nil,
			Args=1,
			Perform=function(self, c)
				CCSCommon.thisWorld.countries[c]:event("Coup d'Etat")

				for q=1,#CCSCommon.thisWorld.countries[c].people do
					if CCSCommon.thisWorld.countries[c].people[q] ~= nil then
						if CCSCommon.thisWorld.countries[c].people[q].isruler == true then
							CCSCommon.thisWorld.countries[c]:delete(q)
						end
					end
				end
			
				CCSCommon:rseed()
			
				CCSCommon.thisWorld.countries[c].stability = CCSCommon.thisWorld.countries[c].stability - 5
				if CCSCommon.thisWorld.countries[c].stability < 1 then CCSCommon.thisWorld.countries[c].stability = 1 end
			end
		},
		{
			Name="Revolution",
			Chance=8,
			Target=nil,
			Args=1,
			Perform=function(self, c)
				for q=1,#CCSCommon.thisWorld.countries[c].people do
					if CCSCommon.thisWorld.countries[c].people[q] ~= nil then
						if CCSCommon.thisWorld.countries[c].people[q].isruler == true then
							CCSCommon.thisWorld.countries[c]:delete(q)
						end
					end
				end
			
				local oldsys = CCSCommon.systems[CCSCommon.thisWorld.countries[c].system].name
			
				while CCSCommon.systems[CCSCommon.thisWorld.countries[c].system].name == oldsys do
					CCSCommon.thisWorld.countries[c].system = math.random(1, #CCSCommon.systems)
				end
				
				local ind = 1
				for q=1,#CCSCommon.thisWorld.countries do
					if CCSCommon.thisWorld.countries[q].name == CCSCommon.thisWorld.countries[c].name then
						ind = q
						q = #CCSCommon.thisWorld.countries + 1
					end
				end
				CCSCommon.thisWorld.countries[c]:checkRuler()
				
				CCSCommon.thisWorld.countries[c]:event("Revolution: "..oldsys.." to "..CCSCommon.systems[CCSCommon.thisWorld.countries[c].system].name)
			
				CCSCommon.thisWorld.countries[c].stability = CCSCommon.thisWorld.countries[c].stability - 15
				if CCSCommon.thisWorld.countries[c].stability < 1 then CCSCommon.thisWorld.countries[c].stability = 1 end
			
				if math.floor(#CCSCommon.thisWorld.countries[c].people / 10) > 1 then
					for d=1,math.random(1, math.floor(#CCSCommon.thisWorld.countries[c].people / 10)) do
						local z = math.random(1,#CCSCommon.thisWorld.countries[c].people)
						CCSCommon.thisWorld.countries[c]:delete(z)
					end
				end

				CCSCommon:rseed()
			end
		},
		{
			Name="Fracture",
			Chance=4,
			Target=nil,
			Args=1,
			Perform=function(self, c)
				local ns = math.random(2,6)
				local pp = CCSCommon.thisWorld.countries[c].population

				CCSCommon.thisWorld.countries[c]:event("Fractured")
				CCSCommon.thisWorld.countries[c].rulers[#CCSCommon.thisWorld.countries[c].rulers].To = CCSCommon.years

				for i=1,#CCSCommon.thisWorld.countries do
					for j=1,#CCSCommon.thisWorld.countries[i].ongoing do
						if CCSCommon.thisWorld.countries[i].ongoing[j] ~= nil then
							if CCSCommon.thisWorld.countries[i].ongoing[j].Target == c then
								table.remove(CCSCommon.thisWorld.countries[i].ongoing, j)
								j = j - 1
							end
						end
					end
				end
				
				for i=1,#CCSCommon.thisWorld.countries do
					for j=1,#CCSCommon.thisWorld.countries[i].alliances do
						if CCSCommon.thisWorld.countries[i].alliances[j] ~= nil then
							if CCSCommon.thisWorld.countries[i].alliances[j] == CCSCommon.thisWorld.countries[c].name then
								table.remove(CCSCommon.thisWorld.countries[i].alliances, j)
								j = j - 1
							end
						end
					end
				end
				
				for i=1,ns do
					CCSCommon:rseed()
					local s = CCSCommon.thisWorld.countries[c]:new()
					s:set()
					s:event("Fractured from "..CCSCommon.thisWorld.countries[c].name)
					s.rulers = CCSCommon:deepcopy(CCSCommon.thisWorld.countries[c].rulers)
					s.rulernames = CCSCommon:deepcopy(CCSCommon.thisWorld.countries[c].rulernames)
					s.strength = math.floor(CCSCommon.thisWorld.countries[c].strength / ns)
					s.stability = math.floor(CCSCommon.thisWorld.countries[c].stability / ns)

					local tmp = math.random(math.floor(math.floor(pp/ns) / 3), math.floor(pp/ns))
					if tmp < 1 then tmp = 1 end
					s:setPop(math.random(1, tmp))
					s.age = 0
					
					CCSCommon.thisWorld:add(s)
				end
				
				for i=1,#CCSCommon.thisWorld.countries do
					if CCSCommon.thisWorld.countries[i] ~= nil then
						if CCSCommon.thisWorld.countries[i].name == CCSCommon.thisWorld.countries[c].name then
							CCSCommon.thisWorld:delete(i)
							i = #CCSCommon.thisWorld.countries + 1
						end
					end
				end
			end
		},
		{
			Name="Civil War",
			Chance=10,
			Target=nil,
			Args=1,
			Begin=function(self, c)
				CCSCommon.thisWorld.countries[c]:event("Beginning of civil war")
			end,
			Step=function(self, c)
				local chance = 40
				
				local doEnd = math.random(1, chance)
				if doEnd < 5 then return self:End(c) end
				
				return 0
			end,
			End=function(self, c)
				for q=1,#CCSCommon.thisWorld.countries[c].people do
					if CCSCommon.thisWorld.countries[c].people[q] ~= nil then
						if CCSCommon.thisWorld.countries[c].people[q].isruler == true then
							CCSCommon.thisWorld.countries[c]:delete(q)
						end
					end
				end
				
				local oldsys = CCSCommon.systems[CCSCommon.thisWorld.countries[c].system].name
			
				CCSCommon.thisWorld.countries[c].system = math.random(1, #CCSCommon.systems)
				
				local ind = 1
				for q=1,#CCSCommon.thisWorld.countries do
					if CCSCommon.thisWorld.countries[q].name == CCSCommon.thisWorld.countries[c].name then
						ind = q
						q = #CCSCommon.thisWorld.countries + 1
					end
				end
				CCSCommon.thisWorld.countries[c]:checkRuler()
				
				local newRuler = nil
				for i=1,#CCSCommon.thisWorld.countries[c].people do
					if CCSCommon.thisWorld.countries[c].people[i].isruler == true then newRuler = i end
				end
				
				local namenum = 0
				local prevTitle = ""
				if CCSCommon.thisWorld.countries[c].people[newRuler].prevTitle ~= nil then prevTitle = CCSCommon.thisWorld.countries[c].people[newRuler].prevTitle.." " end
				
				if prevTitle == "Homeless " then prevTitle = "" end
				if prevTitle == "Citizen " then prevTitle = "" end
				if prevTitle == "Mayor " then prevTitle = "" end

				if CCSCommon.systems[CCSCommon.thisWorld.countries[c].system].dynastic == true then
					for i=1,#CCSCommon.thisWorld.countries[c].rulers do
						if tonumber(CCSCommon.thisWorld.countries[c].rulers[i].From) >= CCSCommon.thisWorld.countries[c].founded then
							if CCSCommon.thisWorld.countries[c].rulers[i].Name == CCSCommon.thisWorld.countries[c].people[newRuler].name then
								if CCSCommon.thisWorld.countries[c].rulers[i].Title == CCSCommon.thisWorld.countries[c].people[newRuler].title then
									namenum = namenum + 1
								end
							end
						end
					end
					
					CCSCommon.thisWorld.countries[c]:event("End of civil war; victory for "..prevTitle..CCSCommon.thisWorld.countries[c].people[newRuler].prevName.." "..CCSCommon.thisWorld.countries[c].people[newRuler].surname..", now "..CCSCommon.thisWorld.countries[c].people[newRuler].title.." "..CCSCommon.thisWorld.countries[c].people[newRuler].name.." "..CCSCommon:roman(namenum).." of "..CCSCommon.thisWorld.countries[c].name)
				else
					CCSCommon.thisWorld.countries[c]:event("End of civil war; victory for "..prevTitle..CCSCommon.thisWorld.countries[c].people[newRuler].prevName.." "..CCSCommon.thisWorld.countries[c].people[newRuler].surname..", now "..CCSCommon.thisWorld.countries[c].people[newRuler].title.." "..CCSCommon.thisWorld.countries[c].people[newRuler].name.." "..CCSCommon.thisWorld.countries[c].people[newRuler].surname.." of "..CCSCommon.thisWorld.countries[c].name)
				end
				
				return -1
			end,
			Perform=function(self, c)
				local already = false
				for i=1,#CCSCommon.thisWorld.countries[c].ongoing do
					if CCSCommon.thisWorld.countries[c].ongoing[i].Name == self.Name then already = true end
				end
				if already == false then self:Begin(c) else return -1 end
				return 0
			end
		},
		{
			Name="War",
			Chance=35,
			Target=nil,
			Args=2,
			Begin=function(self, c1)
				CCSCommon.thisWorld.countries[c1]:event("Declared war on "..CCSCommon.thisWorld.countries[self.Target].name)
				CCSCommon.thisWorld.countries[self.Target]:event("War declared by "..CCSCommon.thisWorld.countries[c1].name)
			end,
			Step=function(self, c1)
				local ac = #CCSCommon.thisWorld.countries[c1].alliances
				for i=1,ac do
					local c3 = nil
					for j=1,#CCSCommon.thisWorld.countries do
						if CCSCommon.thisWorld.countries[j].name == CCSCommon.thisWorld.countries[c1].alliances[i] then c3 = CCSCommon.thisWorld.countries[j] end
					end
				
					if c3 ~= nil then
						local already = false
						for j=1,#c3.allyOngoing do
							if c3.allyOngoing[j] == self.Name.."?"..CCSCommon.thisWorld.countries[c1].name..":"..CCSCommon.thisWorld.countries[self.Target].name then already = true end
						end
						
						if already == false then
							local ic = math.random(1, 25)
							if ic == 12 then
								table.insert(c3.allyOngoing, self.Name.."?"..CCSCommon.thisWorld.countries[c1].name..":"..CCSCommon.thisWorld.countries[self.Target].name)
								
								CCSCommon.thisWorld.countries[c1]:event("Intervention by "..c3.name.." against "..CCSCommon.thisWorld.countries[self.Target].name)
								CCSCommon.thisWorld.countries[self.Target]:event("Intervention by "..c3.name.." on the side of "..CCSCommon.thisWorld.countries[c1].name)
								c3:event("Intervened on the side of "..CCSCommon.thisWorld.countries[c1].name.." in war with "..CCSCommon.thisWorld.countries[self.Target].name)
							end
						end
					end
				end
				
				ac = #CCSCommon.thisWorld.countries[self.Target].alliances
				for i=1,ac do
					local c3 = nil
					for j=1,#CCSCommon.thisWorld.countries do
						if CCSCommon.thisWorld.countries[j].name == CCSCommon.thisWorld.countries[self.Target].alliances[i] then c3 = CCSCommon.thisWorld.countries[j] end
					end
				
					if c3 ~= nil then
						local already = false
						for j=1,#c3.allyOngoing do
							if c3.allyOngoing[j] == self.Name.."?"..CCSCommon.thisWorld.countries[self.Target].name..":"..CCSCommon.thisWorld.countries[c1].name then already = true end
						end
						
						if already == false then
							local ic = math.random(1, 25)
							if ic == 12 then
								table.insert(c3.allyOngoing, self.Name.."?"..CCSCommon.thisWorld.countries[self.Target].name..":"..CCSCommon.thisWorld.countries[c1].name)
								
								CCSCommon.thisWorld.countries[c1]:event("Intervention by "..c3.name.." on the side of "..CCSCommon.thisWorld.countries[self.Target].name)
								CCSCommon.thisWorld.countries[self.Target]:event("Intervention by "..c3.name.." against "..CCSCommon.thisWorld.countries[c1].name)
								c3:event("Intervened on the side of "..CCSCommon.thisWorld.countries[self.Target].name.." in war with "..CCSCommon.thisWorld.countries[c1].name)
							end
						end
					end
				end
				
				local chance = 35
				
				local doEnd = math.random(1, chance)
				if doEnd == 5 then return self:End(c1) end
				
				return 0
			end,
			End=function(self, c1)
				local c1total = CCSCommon.thisWorld.countries[c1].strength
				local c2total = CCSCommon.thisWorld.countries[self.Target].strength
			
				local ac = #CCSCommon.thisWorld.countries[c1].alliances
				for i=1,ac do
					local c3 = nil
					for j=1,#CCSCommon.thisWorld.countries do
						if CCSCommon.thisWorld.countries[j].name == CCSCommon.thisWorld.countries[c1].alliances[i] then c3 = CCSCommon.thisWorld.countries[j] end
					end
					
					if c3 ~= nil then c1total = c1total + c3.strength end
				end
			
				ac = #CCSCommon.thisWorld.countries[self.Target].alliances
				for i=1,ac do
					local c3 = nil
					for j=1,#CCSCommon.thisWorld.countries do
						if CCSCommon.thisWorld.countries[j].name == CCSCommon.thisWorld.countries[self.Target].alliances[i] then c3 = CCSCommon.thisWorld.countries[j] end
					end
					
					if c3 ~= nil then c2total = c2total + c3.strength end
				end
			
				if c1total > c2total + 5 then
					CCSCommon.thisWorld.countries[c1]:event("Victory in war with "..CCSCommon.thisWorld.countries[self.Target].name)
					CCSCommon.thisWorld.countries[self.Target]:event("Defeat in war with "..CCSCommon.thisWorld.countries[c1].name)
					
					CCSCommon.thisWorld.countries[c1].strength = CCSCommon.thisWorld.countries[c1].strength + 20
					CCSCommon.thisWorld.countries[self.Target].strength = CCSCommon.thisWorld.countries[self.Target].strength - 20
					
					ac = #CCSCommon.thisWorld.countries[c1].alliances
					for i=1,ac do
						local c3 = nil
						for j=1,#CCSCommon.thisWorld.countries do
							if CCSCommon.thisWorld.countries[j].name == CCSCommon.thisWorld.countries[c1].alliances[i] then c3 = CCSCommon.thisWorld.countries[j] end
						end
						
						if c3 ~= nil then
							for j=1,#c3.allyOngoing do
								if c3.allyOngoing[j] == self.Name.."?"..CCSCommon.thisWorld.countries[c1].name..":"..CCSCommon.thisWorld.countries[self.Target].name then
									c3.strength = c3.strength + 5
									
									c3:event("Victory with "..CCSCommon.thisWorld.countries[c1].name.." against "..CCSCommon.thisWorld.countries[self.Target].name)
									table.remove(c3.allyOngoing, j)
									j = #c3.allyOngoing + 1
								end
							end
						end
					end
					
					ac = #CCSCommon.thisWorld.countries[self.Target].alliances
					for i=1,ac do
						local c3 = nil
						for j=1,#CCSCommon.thisWorld.countries do
							if CCSCommon.thisWorld.countries[j].name == CCSCommon.thisWorld.countries[self.Target].alliances[i] then c3 = CCSCommon.thisWorld.countries[j] end
						end
						
						if c3 ~= nil then
							for j=1,#c3.allyOngoing do
								if c3.allyOngoing[j] == self.Name.."?"..CCSCommon.thisWorld.countries[self.Target].name..":"..CCSCommon.thisWorld.countries[c1].name then
									c3.strength = c3.strength - 5
									
									c3:event("Defeat with "..CCSCommon.thisWorld.countries[self.Target].name.." in war with "..CCSCommon.thisWorld.countries[c1].name)
									table.remove(c3.allyOngoing, j)
									j = #c3.allyOngoing + 1
								end
							end
						end
					end
				elseif c2total > c1total + 5 then
					CCSCommon.thisWorld.countries[c1]:event("Defeat in war with "..CCSCommon.thisWorld.countries[self.Target].name)
					CCSCommon.thisWorld.countries[self.Target]:event("Victory in war with "..CCSCommon.thisWorld.countries[c1].name)
					
					CCSCommon.thisWorld.countries[c1].strength = CCSCommon.thisWorld.countries[c1].strength - 20
					CCSCommon.thisWorld.countries[self.Target].strength = CCSCommon.thisWorld.countries[self.Target].strength + 20
					
					ac = #CCSCommon.thisWorld.countries[c1].alliances
					for i=1,ac do
						local c3 = nil
						for j=1,#CCSCommon.thisWorld.countries do
							if CCSCommon.thisWorld.countries[j].name == CCSCommon.thisWorld.countries[c1].alliances[i] then c3 = CCSCommon.thisWorld.countries[j] end
						end
						
						if c3 ~= nil then
							for j=1,#c3.allyOngoing do
								if c3.allyOngoing[j] == self.Name.."?"..CCSCommon.thisWorld.countries[c1].name..":"..CCSCommon.thisWorld.countries[self.Target].name then
									c3.strength = c3.strength - 5
									
									c3:event("Defeat with "..CCSCommon.thisWorld.countries[c1].name.." in war with "..CCSCommon.thisWorld.countries[self.Target].name)
									table.remove(c3.allyOngoing, j)
									j = #c3.allyOngoing + 1
								end
							end
						end
					end
					
					ac = #CCSCommon.thisWorld.countries[self.Target].alliances
					for i=1,ac do
						local c3 = nil
						for j=1,#CCSCommon.thisWorld.countries do
							if CCSCommon.thisWorld.countries[j].name == CCSCommon.thisWorld.countries[self.Target].alliances[i] then c3 = CCSCommon.thisWorld.countries[j] end
						end
						
						if c3 ~= nil then
							for j=1,#c3.allyOngoing do
								if c3.allyOngoing[j] == self.Name.."?"..CCSCommon.thisWorld.countries[self.Target].name..":"..CCSCommon.thisWorld.countries[c1].name then
									c3.strength = c3.strength + 5
									
									c3:event("Victory with "..CCSCommon.thisWorld.countries[self.Target].name.." against "..CCSCommon.thisWorld.countries[c1].name)
									table.remove(c3.allyOngoing, j)
									j = #c3.allyOngoing + 1
								end
							end
						end
					end
				else
					CCSCommon.thisWorld.countries[c1]:event("Treaty in war with "..CCSCommon.thisWorld.countries[self.Target].name)
					CCSCommon.thisWorld.countries[self.Target]:event("Treaty in war with "..CCSCommon.thisWorld.countries[c1].name)
					
					ac = #CCSCommon.thisWorld.countries[c1].alliances
					for i=1,ac do
						local c3 = nil
						for j=1,#CCSCommon.thisWorld.countries do
							if CCSCommon.thisWorld.countries[j].name == CCSCommon.thisWorld.countries[c1].alliances[i] then c3 = CCSCommon.thisWorld.countries[j] end
						end
						
						if c3 ~= nil then
							for j=1,#c3.allyOngoing do
								if c3.allyOngoing[j] == self.Name.."?"..CCSCommon.thisWorld.countries[c1].name..":"..CCSCommon.thisWorld.countries[self.Target].name then
									c3:event("Treaty with "..CCSCommon.thisWorld.countries[c1].name.." in war with "..CCSCommon.thisWorld.countries[self.Target].name)
									table.remove(c3.allyOngoing, j)
									j = #c3.allyOngoing + 1
								end
							end
						end
					end
					
					ac = #CCSCommon.thisWorld.countries[self.Target].alliances
					for i=1,ac do
						local c3 = nil
						for j=1,#CCSCommon.thisWorld.countries do
							if CCSCommon.thisWorld.countries[j].name == CCSCommon.thisWorld.countries[self.Target].alliances[i] then c3 = CCSCommon.thisWorld.countries[j] end
						end
						
						if c3 ~= nil then
							for j=1,#c3.allyOngoing do
								if c3.allyOngoing[j] == self.Name.."?"..CCSCommon.thisWorld.countries[self.Target].name..":"..CCSCommon.thisWorld.countries[c1].name then
									c3:event("Treaty with "..CCSCommon.thisWorld.countries[self.Target].name.." in war with "..CCSCommon.thisWorld.countries[c1].name)
									table.remove(c3.allyOngoing, j)
									j = #c3.allyOngoing + 1
								end
							end
						end
					end
				end
				
				return -1
			end,
			Perform=function(self, c1, c2)
				local already = false
				for i=1,#CCSCommon.thisWorld.countries[c1].ongoing do
					if CCSCommon.thisWorld.countries[c1].ongoing[i].Name == self.Name and CCSCommon.thisWorld.countries[c1].ongoing[i].Target == c2 then already = true end
				end
				for i=1,#CCSCommon.thisWorld.countries[c2].ongoing do
					if CCSCommon.thisWorld.countries[c2].ongoing[i].Name == self.Name and CCSCommon.thisWorld.countries[c2].ongoing[i].Target == c1 then already = true end
				end
				if already == false then
					if CCSCommon.thisWorld.countries[c1].relations[CCSCommon.thisWorld.countries[c2].name] ~= nil then
						if CCSCommon.thisWorld.countries[c1].relations[CCSCommon.thisWorld.countries[c2].name] < 20 then
							self.Target = c2
							self:Begin(c1)
							return 0
						end
					end
				end
				return -1
			end
		},
		{
			Name="Alliance",
			Chance=35,
			Target=nil,
			Args=2,
			Begin=function(self, c1)
				CCSCommon.thisWorld.countries[c1]:event("Entered military alliance with "..CCSCommon.thisWorld.countries[self.Target].name)
				CCSCommon.thisWorld.countries[self.Target]:event("Entered military alliance with "..CCSCommon.thisWorld.countries[c1].name)
			end,
			Step=function(self, c1)
				local chance = 65
				
				local doEnd = math.random(1, chance)
				if doEnd == 5 then return self:End(c1) end
				
				return 0
			end,
			End=function(self, c1)
				CCSCommon.thisWorld.countries[c1]:event("Military alliance severed with "..CCSCommon.thisWorld.countries[self.Target].name)
				CCSCommon.thisWorld.countries[self.Target]:event("Military alliance severed with "..CCSCommon.thisWorld.countries[c1].name)
				
				return -1
			end,
			Perform=function(self, c1, c2)
				local already = false
				for i=1,#CCSCommon.thisWorld.countries[c1].alliances do
					if CCSCommon.thisWorld.countries[c1].alliances[i] == CCSCommon.thisWorld.countries[c2].name then already = true end
				end
				for i=1,#CCSCommon.thisWorld.countries[c2].alliances do
					if CCSCommon.thisWorld.countries[c2].alliances[i] == CCSCommon.thisWorld.countries[c1].name then already = true end
				end
				if already == false then
					if CCSCommon.thisWorld.countries[c1].relations[CCSCommon.thisWorld.countries[c2].name] ~= nil then
						if CCSCommon.thisWorld.countries[c1].relations[CCSCommon.thisWorld.countries[c2].name] > 60 then
							self.Target = c2
							table.insert(CCSCommon.thisWorld.countries[c2].alliances, CCSCommon.thisWorld.countries[c1].name)
							table.insert(CCSCommon.thisWorld.countries[c1].alliances, CCSCommon.thisWorld.countries[c2].name)
							self:Begin(c1)
						end
					end
					return 0
				end
				return -1
			end
		},
		{
			Name="Independence",
			Chance=12,
			Target=nil,
			Args=1,
			Perform=function(self, c)
				local newl = Country:new()
				newl:set()
				
				CCSCommon.thisWorld.countries[c]:event("Granted independence to "..newl.name)
				newl:event("Independence from "..CCSCommon.thisWorld.countries[c].name)

				newl.rulers = CCSCommon:deepcopy(CCSCommon.thisWorld.countries[c].rulers)
				newl.rulernames = CCSCommon:deepcopy(CCSCommon.thisWorld.countries[c].rulernames)

				CCSCommon.thisWorld:add(newl)

				CCSCommon.thisWorld.countries[c].strength = CCSCommon.thisWorld.countries[c].strength - math.random(5, 15)
				if CCSCommon.thisWorld.countries[c].strength < 1 then CCSCommon.thisWorld.countries[c].strength = 1 end

				CCSCommon.thisWorld.countries[c].stability = CCSCommon.thisWorld.countries[c].stability - math.random(5, 15)
				if CCSCommon.thisWorld.countries[c].stability < 1 then CCSCommon.thisWorld.countries[c].stability = 1 end
			end
		},
		{
			Name="Conquer",
			Chance=4,
			Target=nil,
			Args=2,
			Perform=function(self, c1, c2)
				if CCSCommon.thisWorld.countries[c1].relations[CCSCommon.thisWorld.countries[c2].name] ~= nil then
					if CCSCommon.thisWorld.countries[c1].relations[CCSCommon.thisWorld.countries[c2].name] < 15 then
						CCSCommon.thisWorld.countries[c1]:event("Conquered "..CCSCommon.thisWorld.countries[c2].name)
						CCSCommon.thisWorld.countries[c2]:event("Conquered by "..CCSCommon.thisWorld.countries[c1].name)
						
						for i=1,#CCSCommon.thisWorld.countries do
							for j=1,#CCSCommon.thisWorld.countries[i].ongoing do
								if CCSCommon.thisWorld.countries[i].ongoing[j] ~= nil then
									if CCSCommon.thisWorld.countries[i].ongoing[j].Target == c2 then
										table.remove(CCSCommon.thisWorld.countries[i].ongoing, j)
										j = j - 1
									end
								end
							end
						end
						
						for i=1,#CCSCommon.thisWorld.countries do
							for j=1,#CCSCommon.thisWorld.countries[i].alliances do
								if CCSCommon.thisWorld.countries[i].alliances[j] ~= nil then
									if CCSCommon.thisWorld.countries[i].alliances[j] == CCSCommon.thisWorld.countries[c2].name then
										table.remove(CCSCommon.thisWorld.countries[i].alliances, j)
										j = j - 1
									end
								end
							end
						end
						
						CCSCommon.thisWorld.countries[c1].strength = CCSCommon.thisWorld.countries[c1].strength - CCSCommon.thisWorld.countries[c2].strength - 5
						if CCSCommon.thisWorld.countries[c1].strength < 1 then CCSCommon.thisWorld.countries[c1].strength = 1 end
						CCSCommon.thisWorld.countries[c1].stability = CCSCommon.thisWorld.countries[c1].stability - CCSCommon.thisWorld.countries[c2].stability - 5
						if CCSCommon.thisWorld.countries[c1].stability < 1 then CCSCommon.thisWorld.countries[c1].stability = 1 end
						CCSCommon.thisWorld.countries[c1]:setPop(CCSCommon.thisWorld.countries[c1].population + CCSCommon.thisWorld.countries[c2].population)
						if #CCSCommon.thisWorld.countries[c2].rulers > 0 then
							CCSCommon.thisWorld.countries[c2].rulers[#CCSCommon.thisWorld.countries[c2].rulers].To = CCSCommon.years
						end
						
						CCSCommon.thisWorld:delete(c2)
					end
				end
			end
		},
		{
			Name="Invade",
			Chance=8,
			Target=nil,
			Args=2,
			Perform=function(self, c1, c2)
				if CCSCommon.thisWorld.countries[c1].relations[CCSCommon.thisWorld.countries[c2].name] ~= nil then
					if CCSCommon.thisWorld.countries[c1].relations[CCSCommon.thisWorld.countries[c2].name] < 20 then
						CCSCommon.thisWorld.countries[c1]:event("Invaded "..CCSCommon.thisWorld.countries[c2].name)
						CCSCommon.thisWorld.countries[c2]:event("Invaded by "..CCSCommon.thisWorld.countries[c1].name)
						
						CCSCommon.thisWorld.countries[c1].strength = CCSCommon.thisWorld.countries[c1].strength - 10
						if CCSCommon.thisWorld.countries[c1].strength < 1 then CCSCommon.thisWorld.countries[c1].strength = 1 end
						CCSCommon.thisWorld.countries[c1].stability = CCSCommon.thisWorld.countries[c1].stability - 5
						if CCSCommon.thisWorld.countries[c1].stability < 1 then CCSCommon.thisWorld.countries[c1].stability = 1 end
						CCSCommon.thisWorld.countries[c2].strength = CCSCommon.thisWorld.countries[c2].strength - 10
						if CCSCommon.thisWorld.countries[c2].strength < 1 then CCSCommon.thisWorld.countries[c2].strength = 1 end
						CCSCommon.thisWorld.countries[c2].stability = CCSCommon.thisWorld.countries[c2].stability - 10
						if CCSCommon.thisWorld.countries[c2].stability < 1 then CCSCommon.thisWorld.countries[c2].stability = 1 end
						CCSCommon.thisWorld.countries[c1]:setPop(math.floor(CCSCommon.thisWorld.countries[c1].population / 1.25))
						CCSCommon.thisWorld.countries[c2]:setPop(math.floor(CCSCommon.thisWorld.countries[c2].population / 1.75))
					end
				end
			end
		}
	}
}

CCSCommon.systems = {CCSCommon.MONARCHY, CCSCommon.REPUBLIC, CCSCommon.DEMOCRACY, CCSCommon.OLIGARCHY, CCSCommon.EMPIRE}

return CCSCommon