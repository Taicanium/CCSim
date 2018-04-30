mincountries = 3
maxcountries = 8
clrcmd = ""
maxyears = 0
showinfo = 0

vowels = {"A", "E", "I", "O", "U"}
consonants = {"B", "C", "D", "F", "G", "H", "L", "M", "N", "P", "R", "S", "T", "V"}

MONARCHY = {name="Monarchy", ranks={"Homeless", "Citizen", "Mayor", "Knight", "Baron", "Viscount", "Earl", "Marquis", "Lord", "Duke", "Prince", "King"}, franks={"Homeless", "Citizen", "Mayor", "Dame", "Baroness", "Viscountess", "Countess", "Marquess", "Lady", "Duchess", "Princess", "Queen"}, dynastic=true}
REPUBLIC = {name="Republic", ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Judge", "Senator", "Prime Minister", "President"}, dynastic=false}
DEMOCRACY = {name="Democracy", ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Senator", "Speaker"}, dynastic=false}
OLIGARCHY = {name="Oligarchy", ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Minister", "Oligarch", "Premier"}, dynastic=false}
EMPIRE = {name="Empire", ranks={"Homeless", "Citizen", "Mayor", "Lord", "Governor", "Viceroy", "Prince", "Emperor"}, franks={"Homeless", "Citizen", "Mayor", "Lady", "Governor", "Vicereine", "Princess", "Empress"}, dynastic=true}

systems = {MONARCHY, REPUBLIC, DEMOCRACY, OLIGARCHY, EMPIRE}

person = {}
country = {}
world = {}

person.__index = person
country.__index = country
world.__index = world

numCountries = 0
years = 0
yearstorun = 0

final = {}

thisWorld = nil

function sleep(v)
	local b = os.clock()
	local e = os.clock()
	while e < b + v do
		e = os.clock()
	end
end

function rseed()
	sleep(0.01)
	local tc = tonumber(os.clock()*os.time())/1000
	local n = tonumber(tostring(tc):reverse())
	math.randomseed(n)
	math.random(1, 500)
	x = math.random(7, 13)
	for i=2,x do
		math.randomseed(tonumber(tostring(math.random(1, math.floor(i*tc))):reverse()))
		math.random(1, 500)
	end
	math.random(1, 500)
end

function getPersonString(data)
	return string.format(data["Title"].." "..data["Name"].." "..roman(data["Number"]).." of "..data["Country"].." ("..tostring(data["From"]).." - "..tostring(data["To"])..")")
end

function deepcopy(dat)
    local final_type = type(dat)
    local copy
    if final_type == "table" then
        copy = {}
        for final_key, final_value in next, dat, nil do
            copy[deepcopy(final_key)] = deepcopy(final_value)
        end
        setmetatable(copy, deepcopy(getmetatable(dat)))
    else
        copy = dat
    end
    return copy
end

function name()
	local nom = ""
	
	local nl = math.random(3, 9)
	local nv = 0
	for i=1,nl do
		local vc = math.random(1, 100)
		if vc < math.random(20, 60) then
			local c = math.random(1, #consonants)
			if i == 1 then nom = nom..consonants[c] else nom = nom..string.lower(consonants[c]) end
		else
			local v = math.random(1, #vowels)
			if i == 1 then nom = nom..vowels[v] else nom = nom..string.lower(vowels[v]) end
			nv = nv + 1
		end
	end
	
	if nv == 0 then
		local v = math.random(1, #vowels)
		nom = nom..string.lower(vowels[v])
	end
	
	return nom
end

function roman(n)
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
end

c_events = {
	{
		["Name"]="Coup d'Etat",
		["Chance"]=200,
		["Args"]={1, "C"},
		["Perform"]=function(self, c)
			c:event("Coup d'Etat")

			for q=1,#c.people do
				if c.people[q] ~= nil then
					if c.people[q].isruler == true then
						c:delete(q)
					end
				end
			end
		
			rseed()
		
			c.stability = c.stability - 5
			if c.stability < 1 then c.stability = 1 end
		end
	},
	{
		["Name"]="Revolution",
		["Chance"]=40,
		["Args"]={1, "C"},
		["Perform"]=function(self, c)
			for q=1,#c.people do
				if c.people[q] ~= nil then
					if c.people[q].isruler == true then
						c:delete(q)
					end
				end
			end
		
			local oldsys = systems[c.system].name
		
			while systems[c.system].name == oldsys do
				local e = math.random(1, #systems)
				local g = 1
				for t=1,#systems do
					if e == g then c.system = t end
					g = g + 1
				end
			end
			
			local ind = 1
			for q=1,#thisWorld.countries do
				if thisWorld.countries[q].name == c.name then
					ind = q
					q = #thisWorld.countries + 1
				end
			end
			c:checkRuler(thisWorld, ind)
			
			c:event("Revolution: "..oldsys.." to "..systems[c.system].name)
		
			c.stability = c.stability - 15
			if c.stability < 1 then c.stability = 1 end
		
			if math.floor(#c.people / 10) > 1 then
				for d=1,math.random(1, math.floor(#c.people / 10)) do
					local z = math.random(1,#c.people)
					c:delete(z)
				end
			end

			rseed()
		end
	},
	{
		["Name"]="Fracture",
		["Chance"]=20,
		["Args"]={1, "C"},
		["Perform"]=function(self, c)
			local ns = math.random(2,6)
			local pp = c.population

			c:event("Fractured")
			c.rulers[#c.rulers]["To"] = years

			for i=1,ns do
				rseed()
				local s = c:new()
				s:set()
				s:event("Fractured from "..c.name)
				s.rulers = deepcopy(c.rulers)
				s.rulernames = deepcopy(c.rulernames)
				s.strength = math.floor(c.strength / ns)
				s.stability = math.floor(c.stability / ns)

				local tmp = math.random(math.floor(math.floor(pp/ns) / 3), math.floor(pp/ns))
				if tmp < 1 then tmp = 1 end
				s:setPop(math.random(1, tmp))
				s.age = 0
				
				thisWorld:add(s)
			end
			
			for i=1,#thisWorld.countries do
				if thisWorld.countries[i] ~= nil then
					if thisWorld.countries[i].name == c.name then
						thisWorld:delete(i)
						i = #thisWorld.countries + 1
					end
				end
			end
		end
	},
	{
		["Name"]="Civil war",
		["Chance"]=20,
		["Args"]={1, "C"},
		["Begin"]=function(self, c)
			table.insert(c.ongoing, self.Name)
			
			c:event("Beginning of civil war")
		end,
		["Step"]=function(self, c)
			local chance = 40
			
			local doEnd = math.random(1, chance)
			if doEnd < 5 then self:End(c) end
		end,
		["End"]=function(self, c)		
			for q=1,#c.people do
				if c.people[q] ~= nil then
					if c.people[q].isruler == true then
						c:delete(q)
					end
				end
			end
			
			local oldsys = systems[c.system].name
		
			local e = math.random(1, #systems)
			local g = 1
			for t=1,#systems do
				if e == g then c.system = t end
				g = g + 1
			end
			
			local ind = 1
			for q=1,#thisWorld.countries do
				if thisWorld.countries[q].name == c.name then
					ind = q
					q = #thisWorld.countries + 1
				end
			end
			c:checkRuler(thisWorld, ind)
			
			local newRuler = nil
			for i=1,#c.people do
				if c.people[i].isruler == true then newRuler = i end
			end
			
			local namenum = 0
			local prevTitle = ""
			if c.people[newRuler].prevTitle ~= nil then prevTitle = c.people[newRuler].prevTitle.." " end
			
			if prevTitle == "Homeless " then prevTitle = "" end
			if prevTitle == "Citizen " then prevTitle = "" end
			if prevTitle == "Mayor " then prevTitle = "" end

			if systems[c.system].dynastic == true then
				for i=1,#c.rulers do
					if tonumber(c.rulers[i]["From"]) >= c.founded then
						if c.rulers[i]["Name"] == c.people[newRuler].name then
							if c.rulers[i]["Title"] == c.people[newRuler].title then
								namenum = namenum + 1
							end
						end
					end
				end
				
				c:event("End of civil war; victory for "..prevTitle..c.people[newRuler].prevName.." "..c.people[newRuler].surname..", now "..c.people[newRuler].title.." "..c.people[newRuler].name.." "..roman(namenum).." of "..c.name)
			else
				c:event("End of civil war; victory for "..prevTitle..c.people[newRuler].prevName.." "..c.people[newRuler].surname..", now "..c.people[newRuler].title.." "..c.people[newRuler].name.." "..c.people[newRuler].surname.." of "..c.name)
			end
			
			for i=1,#c.ongoing do
				if c.ongoing[i] == self.Name then
					table.remove(c.ongoing, i)
					i = #c.ongoing + 1
				end
			end
		end,
		["Perform"]=function(self, c)
			local already = false
			for i=1,#c.ongoing do
				if c.ongoing[i] == self.Name then already = true end
			end
			if already == false then self:Begin(c) end
		end
	},
	{
		["Name"]="War",
		["Chance"]=250,
		["Args"]={2, "C", "C"},
		["Begin"]=function(self, c1, c2)
			table.insert(c1.ongoing, self.Name..c2.name)
			table.insert(c2.ongoing, self.Name..c1.name)
			
			c1:event("Declared war on "..c2.name)
			c2:event("War declared by "..c1.name)
		end,
		["Step"]=function(self, c1, c2)
			local ac = #c1.alliances
			for i=1,ac do
				local c3 = nil
				for j=1,#thisWorld.countries do
					if thisWorld.countries[j].name == c1.alliances[i] then c3 = thisWorld.countries[j] end
				end
			
				if c3 ~= nil then
					local already = false
					for j=1,#c3.allyOngoing do
						if c3.allyOngoing[j] == self.Name.."?"..c1.name..":"..c2.name then already = true end
					end
					
					if already == false then
						local ic = math.random(1, 35)
						if ic == 12 then
							table.insert(c3.allyOngoing, self.Name.."?"..c1.name..":"..c2.name)
							
							c1:event("Intervention by "..c3.name.." against "..c2.name)
							c2:event("Intervention by "..c3.name.." on the side of "..c1.name)
							c3:event("Intervened on the side of "..c1.name.." in war with "..c2.name)
						end
					end
				end
			end
			
			ac = #c2.alliances
			for i=1,ac do
				local c3 = nil
				for j=1,#thisWorld.countries do
					if thisWorld.countries[j].name == c2.alliances[i] then c3 = thisWorld.countries[j] end
				end
			
				if c3 ~= nil then
					local already = false
					for j=1,#c3.allyOngoing do
						if c3.allyOngoing[j] == self.Name.."?"..c2.name..":"..c1.name then already = true end
					end
					
					if already == false then
						local ic = math.random(1, 35)
						if ic == 12 then
							table.insert(c3.allyOngoing, self.Name.."?"..c2.name..":"..c1.name)
							
							c1:event("Intervention by "..c3.name.." on the side of "..c2.name)
							c2:event("Intervention by "..c3.name.." against "..c1.name)
							c3:event("Intervened on the side of "..c2.name.." in war with "..c1.name)
						end
					end
				end
			end
			
			local chance = 50
			
			local doEnd = math.random(1, chance)
			if doEnd < 5 then self:End(c1, c2) end
		end,
		["End"]=function(self, c1, c2)
			local c1total = c1.strength
			local c2total = c2.strength
		
			local ac = #c1.alliances
			for i=1,ac do
				local c3 = nil
				for j=1,#thisWorld.countries do
					if thisWorld.countries[j].name == c1.alliances[i] then c3 = thisWorld.countries[j] end
				end
				
				if c3 ~= nil then c1total = c1total + c3.strength end
			end
		
			ac = #c2.alliances
			for i=1,ac do
				local c3 = nil
				for j=1,#thisWorld.countries do
					if thisWorld.countries[j].name == c2.alliances[i] then c3 = thisWorld.countries[j] end
				end
				
				if c3 ~= nil then c2total = c2total + c3.strength end
			end
		
			if c1total > c2total + 5 then
				c1:event("Victory in war with "..c2.name)
				c2:event("Defeat in war with "..c1.name)
				
				c1.strength = c1.strength + 20
				c2.strength = c2.strength - 20
				
				ac = #c1.alliances
				for i=1,ac do
					local c3 = nil
					for j=1,#thisWorld.countries do
						if thisWorld.countries[j].name == c1.alliances[i] then c3 = thisWorld.countries[j] end
					end
					
					if c3 ~= nil then
						for j=1,#c3.allyOngoing do
							if c3.allyOngoing[j] == self.Name.."?"..c1.name..":"..c2.name then
								c3.strength = c3.strength + 5
								
								c3:event("Victory with "..c1.name.." against "..c2.name)
								table.remove(c3.allyOngoing, j)
								j = #c3.allyOngoing + 1
							end
						end
					end
				end
				
				ac = #c2.alliances
				for i=1,ac do
					local c3 = nil
					for j=1,#thisWorld.countries do
						if thisWorld.countries[j].name == c2.alliances[i] then c3 = thisWorld.countries[j] end
					end
					
					if c3 ~= nil then
						for j=1,#c3.allyOngoing do
							if c3.allyOngoing[j] == self.Name.."?"..c2.name..":"..c1.name then
								c3.strength = c3.strength - 5
								
								c3:event("Defeat with "..c2.name.." in war with "..c1.name)
								table.remove(c3.allyOngoing, j)
								j = #c3.allyOngoing + 1
							end
						end
					end
				end
			elseif c2total > c1total + 5 then
				c1:event("Defeat in war with "..c2.name)
				c2:event("Victory in war with "..c1.name)
				
				c1.strength = c1.strength - 20
				c2.strength = c2.strength + 20
				
				ac = #c1.alliances
				for i=1,ac do
					local c3 = nil
					for j=1,#thisWorld.countries do
						if thisWorld.countries[j].name == c1.alliances[i] then c3 = thisWorld.countries[j] end
					end
					
					if c3 ~= nil then
						for j=1,#c3.allyOngoing do
							if c3.allyOngoing[j] == self.Name.."?"..c1.name..":"..c2.name then
								c3.strength = c3.strength - 5
								
								c3:event("Defeat with "..c1.name.." in war with "..c2.name)
								table.remove(c3.allyOngoing, j)
								j = #c3.allyOngoing + 1
							end
						end
					end
				end
				
				ac = #c2.alliances
				for i=1,ac do
					local c3 = nil
					for j=1,#thisWorld.countries do
						if thisWorld.countries[j].name == c2.alliances[i] then c3 = thisWorld.countries[j] end
					end
					
					if c3 ~= nil then
						for j=1,#c3.allyOngoing do
							if c3.allyOngoing[j] == self.Name.."?"..c2.name..":"..c1.name then
								c3.strength = c3.strength + 5
								
								c3:event("Victory with "..c2.name.." against "..c1.name)
								table.remove(c3.allyOngoing, j)
								j = #c3.allyOngoing + 1
							end
						end
					end
				end
			else
				c1:event("Treaty in war with "..c2.name)
				c2:event("Treaty in war with "..c1.name)
				
				ac = #c1.alliances
				for i=1,ac do
					local c3 = nil
					for j=1,#thisWorld.countries do
						if thisWorld.countries[j].name == c1.alliances[i] then c3 = thisWorld.countries[j] end
					end
					
					if c3 ~= nil then
						for j=1,#c3.allyOngoing do
							if c3.allyOngoing[j] == self.Name.."?"..c1.name..":"..c2.name then
								c3:event("Treaty with "..c1.name.." in war with "..c2.name)
								table.remove(c3.allyOngoing, j)
								j = #c3.allyOngoing + 1
							end
						end
					end
				end
				
				ac = #c2.alliances
				for i=1,ac do
					local c3 = nil
					for j=1,#thisWorld.countries do
						if thisWorld.countries[j].name == c2.alliances[i] then c3 = thisWorld.countries[j] end
					end
					
					if c3 ~= nil then
						for j=1,#c3.allyOngoing do
							if c3.allyOngoing[j] == self.Name.."?"..c2.name..":"..c1.name then
								c3:event("Treaty with "..c2.name.." in war with "..c1.name)
								table.remove(c3.allyOngoing, j)
								j = #c3.allyOngoing + 1
							end
						end
					end
				end
			end
			
			for i=1,#c1.ongoing do
				if c1.ongoing[i] == self.Name..c2.name then
					table.remove(c1.ongoing, i)
					i = #c1.ongoing + 1
				end
			end
			
			for i=1,#c2.ongoing do
				if c2.ongoing[i] == self.Name..c1.name then
					table.remove(c2.ongoing, i)
					i = #c2.ongoing + 1
				end
			end
		end,
		["Perform"]=function(self, c1, c2)
			local already = false
			for i=1,#c1.ongoing do
				if c1.ongoing[i] == self.Name..c2.name then already = true end
			end
			for i=1,#c2.ongoing do
				if c2.ongoing[i] == self.Name..c1.name then already = true end
			end
			if already == false then
				if c1.relations[c2.name] < 20 then
					self:Begin(c1, c2)
				end
			end
		end
	},
	{
		["Name"]="Alliance",
		["Chance"]=225,
		["Args"]={2, "C", "C"},
		["Begin"]=function(self, c1, c2)
			table.insert(c1.alliances, c2.name)
			table.insert(c2.alliances, c1.name)
			
			c1:event("Entered military alliance with "..c2.name)
			c2:event("Entered military alliance with "..c1.name)
		end,
		["Step"]=function(self, c1, c2)
			local chance = 65
			
			local doEnd = math.random(1, chance)
			if doEnd < 5 then self:End(c1, c2) end
		end,
		["End"]=function(self, c1, c2)
			for i=1,#c1.alliances do
				if c1.alliances[i] == c2.name then
					table.remove(c1.alliances, i)
					i = #c1.alliances + 1
				end
			end
			
			for i=1,#c2.alliances do
				if c2.alliances[i] == c1.name then
					table.remove(c2.alliances, i)
					i = #c2.alliances + 1
				end
			end
		
			c1:event("Military alliance severed with "..c2.name)
			c2:event("Military alliance severed with "..c1.name)
		end,
		["Perform"]=function(self, c1, c2)
			local already = false
			for i=1,#c1.alliances do
				if c1.alliances[i] == c2.name then already = true end
			end
			for i=1,#c2.alliances do
				if c2.alliances[i] == c1.name then already = true end
			end
			if already == false then
				if c1.relations[c2.name] ~= nil then
					if c1.relations[c2.name] > 60 then
						self:Begin(c1, c2)
					end
				end
			end
		end
	},
	{
		["Name"]="Independence",
		["Chance"]=40,
		["Args"]={1, "C"},
		["Perform"]=function(self, c)
			local newl = country:new()
			newl:set()
			
			c:event("Granted independence to "..newl.name)
			newl:event("Independence from "..c.name)

			newl.rulers = deepcopy(c.rulers)
			newl.rulernames = deepcopy(c.rulernames)

			thisWorld:add(newl)

			c.strength = c.strength - math.random(5, 15)
			if c.strength < 1 then c.strength = 1 end

			c.stability = c.stability - math.random(5, 15)
			if c.stability < 1 then c.stability = 1 end
		end
	},
	{
		["Name"]="Conquer",
		["Chance"]=20,
		["Args"]={2, "C", "C"},
		["Perform"]=function(self, c1, c2)
			if c1.relations[c2.name] ~= nil then
				if c1.relations[c2.name] < 15 then
					c1:event("Conquered "..c2.name)
					c2:event("Conquered by "..c1.name)
					
					c1.strength = c1.strength - c2.strength - 5
					if c1.strength < 1 then c1.strength = 1 end
					c1.stability = c1.stability - c2.stability - 5
					if c1.stability < 1 then c1.stability = 1 end
					c1:setPop(c1.population + c2.population)
					if #c2.rulers > 0 then
						c2.rulers[#c2.rulers]["To"] = years
					end
					
					for i=1,#thisWorld.countries do
						if thisWorld.countries[i] ~= nil then
							if thisWorld.countries[i].name == c2.name then thisWorld:delete(i) end
						end
					end
				end
			end
		end
	},
	{
		["Name"]="Invade",
		["Chance"]=75,
		["Args"]={2, "C", "C"},
		["Perform"]=function(self, c1, c2)
			if c1.relations[c2.name] ~= nil then
				if c1.relations[c2.name] < 20 then
					c1:event("Invaded "..c2.name)
					c2:event("Invaded by "..c1.name)
					
					c1.strength = c1.strength - 10
					if c1.strength < 1 then c1.strength = 1 end
					c1.stability = c1.stability - 5
					if c1.stability < 1 then c1.stability = 1 end
					c2.strength = c2.strength - 10
					if c2.strength < 1 then c2.strength = 1 end
					c2.stability = c2.stability - 10
					if c2.stability < 1 then c2.stability = 1 end
					c1:setPop(math.floor(c1.population / 1.25))
					c2:setPop(math.floor(c2.population / 1.75))
				end
			end
		end
	}
}

function ncall()
	return person:new()
end

function nlcall()
	return country:new()
end

function nmcall()
	return world:new()
end

function person:new()
	local n = {}
	setmetatable(n, person)
	
	n.name = ""
	n.surname = ""
	n.birth = ""
	n.age = 0
	n.level = 2
	n.prevName = ""
	n.prevTitle = "Citizen"
	n.title = "Citizen"
	n.gender = ""
	n.father = nil
	n.mother = nil
	n.spouse = nil
	
	return n
end

function person:destroy()
	self.name = nil
	self.surname = nil
	self.birth = nil
	self.age = nil
	self.level = nil
	self.title = nil
	self.gender = nil
end

function person:makename()
	self.name = name()
	self.surname = name()
	
	local r = math.random(1, 100)
	if r < 51 then self.gender = "Male" else self.gender = "Female" end
	
	self.birth = years
	self.age = math.random(5,60)
	if self.title == "" then
		self.level = 2
		self.title = "Citizen"
	end
end

function person:update(nl)
	self.age = self.age + 1
	
	if self.surname == nil then self.surname = name() end
	
	if self.gender == "Male" or systems[nl.system].dynastic == false then
		if self.title ~= systems[nl.system].ranks[#systems[nl.system].ranks] and self.level < #systems[nl.system].ranks - 1 then
			local x = math.random(-125, 100)
			if x < -75 then
				self.prevTitle = self.title
				self.level = self.level - 1
			elseif x > 75 then
				self.prevTitle = self.title
				self.level = self.level + 1
			end
			
			if self.level < 1 then self.level = 1 end
			if self.level > #systems[nl.system].ranks - 2 then self.level = #systems[nl.system].ranks - 2 end
		end
		
		self.title = systems[nl.system].ranks[self.level]
	else
		if self.title ~= systems[nl.system].franks[#systems[nl.system].franks] and self.level < #systems[nl.system].franks - 1 then
			local x = math.random(-125, 100)
			if x < -75 then
				self.prevTitle = self.title
				self.level = self.level - 1
			elseif x > 75 then
				self.prevTitle = self.title
				self.level = self.level + 1
			end
			
			if self.level < 1 then self.level = 1 end
			if self.level > #systems[nl.system].franks - 2 then self.level = #systems[nl.system].franks - 2 end
		end
		
		self.title = systems[nl.system].franks[self.level]
	end
	
	if self.spouse == nil then
		local m = math.random(1, #nl.people)
		if nl.people[m].spouse == nil then
			if self.gender ~= nl.people[m].gender then
				self.spouse = nl.people[m]
				nl.people[m].spouse = self
				
				if self.level >= nl.people[m].level then
					nl.people[m].surname = self.surname
					nl.people[m].level = self.level
				else
					self.surname = nl.people[m].surname
					self.level = nl.people[m].level
				end
			end
		end
	end
	
	if self.spouse ~= nil then
		if self.age < 65 and self.age > 14 then
			local tmp = math.random(1, nl.birthrate)
			if tmp < 4 then
				local nn = person:new()
				nn:makename()
				
				if self.gender == "Male" then
					nn.father = self
					nn.surname = self.surname
				else
					nn.mother = self
					nn.surname = self.spouse.surname
				end
				
				nn.age = 0
				
				if systems[nl.system].dynastic == true then
						if self.gender == "Male" then
							if self.title == systems[nl.system].ranks[#systems[nl.system].ranks] then
							nn.level = #systems[nl.system].ranks - 1
						else
							nn.level = self.level
						end
					else
						if self.title == systems[nl.system].franks[#systems[nl.system].franks] then
							nn.level = #systems[nl.system].ranks - 1
						else
							nn.level = self.level
						end
					end
				else
					if self.title == systems[nl.system].ranks[#systems[nl.system].ranks] then
						nn.level = #systems[nl.system].ranks - 1
					else
						nn.level = self.level
					end
				end
				
				if nn.gender == "Male" or systems[nl.system].dynastic == false then nn.title = systems[nl.system].ranks[nn.level] else nn.title = systems[nl.system].franks[nn.level] end
				nl:add(nn)
			end
		end
	end
end

function country:new()
	local nl = {}
	setmetatable(nl, country)
	
	nl.name = ""
	nl.founded = 0
	nl.age = 0
	nl.average = 1
	nl.hasruler = -1
	nl.people = {}
	nl.events = {}
	nl.rulerage = 0
	nl.relations = {}
	nl.rulers = {}
	nl.rulernames = {}
	nl.frulernames = {}
	nl.ongoing = {}
	nl.allyOngoing = {}
	nl.alliances = {}
	nl.system = 0
	nl.stability = 50
	nl.strength = 50
	nl.population = 0
	nl.birthrate = 100
	nl.deathrate = 50000
	
	return nl
end

function country:destroy()
	for i=1,#self.people do
		self.people[i]:destroy()
		self.people[i] = nil
	end
end

function country:add(n)
	table.insert(self.people, n)
end

function country:delete(y)
	local b = #self.people
	if b > 0 then
		if self.people[y] ~= nil then
			if self.people[y].spouse ~= nil then
				self.people[y].spouse.spouse = nil
			end
			self.people[y].spouse = nil
			if self.people[y].isruler == true then self.hasruler = -1 end
			local w = table.remove(self.people, y)
			if w ~= nil then
				w:destroy()
				w = nil
			end
		end
	end
end

function country:makename()
	if self.name == "" or self.name == nil then
		self.name = name()
	end
	
	if #self.rulernames < 1 then
		for k=1,math.random(5,8) do
			table.insert(self.rulernames, name())
		end
		
		for k=1,math.random(5,8) do
			table.insert(self.frulernames, name())
		end
	end
	
	if #self.frulernames < 1 then
		for k=1,math.random(5,8) do
			table.insert(self.frulernames, name())
		end
	end
end

function country:set()
	rseed()

	self:makename()
	
	for i=1,math.random(100,1000) do
		local n = person:new()
		n:makename()
		self:add(n)
	end
	
	local e = math.random(1, #systems)
	local g = 1
	for i=1,#systems do
		if e == g then self.system = i end
		g = g + 1
	end
	
	self.founded = years
	self.population = #self.people
end

function country:setRuler(newRuler)
	if self.hasruler == -1 then
		self.people[newRuler].prevName = self.people[newRuler].name
		self.people[newRuler].prevTitle = self.people[newRuler].title
	
		self.people[newRuler].level = #systems[self.system].ranks
		self.people[newRuler].title = systems[self.system].ranks[self.people[newRuler].level]
		
		rseed()

		if self.people[newRuler].gender == "Female" then
			self.people[newRuler].name = self.frulernames[math.floor(math.random(1, #self.frulernames))]
			
			if systems[self.system].franks ~= nil then
				self.people[newRuler].level = #systems[self.system].franks
				self.people[newRuler].title = systems[self.system].franks[self.people[newRuler].level]
			end
		else
			self.people[newRuler].name = self.rulernames[math.floor(math.random(1, #self.rulernames))]
		end
		
		local namenum = 1
		
		for i=1,#self.rulers do
			if tonumber(self.rulers[i]["From"]) >= self.founded then
				if self.rulers[i]["Name"] == self.people[newRuler].name then
					if self.rulers[i]["Title"] == self.people[newRuler].title then
						namenum = namenum + 1
					end
				end
			end
		end
		
		self.people[newRuler].isruler = true
		self.hasruler = 0
		
		if systems[self.system].dynastic == true then
			table.insert(self.rulers, {["Name"]=self.people[newRuler].name, ["Title"]=self.people[newRuler].title, ["Number"]=tostring(namenum), ["From"]=years, ["To"]="Current", ["Country"]=self.name})
		else
			table.insert(self.rulers, {["Name"]=self.people[newRuler].name, ["Title"]=self.people[newRuler].title, ["Number"]=self.people[newRuler].surname, ["From"]=years, ["To"]="Current", ["Country"]=self.name})
		end
		
		self.rulerage = self.people[newRuler].age
	end
end

function country:checkRuler(ind)
	if self.hasruler == -1 then
		if #self.rulers > 0 then
			self.rulers[#self.rulers]["To"] = years
		end
		
		if #self.people > 1 then			
			while self.hasruler == -1 do
				local chil = false
				local male = false
				local chils = {}
				
				if systems[self.system].dynastic == true then
					for e=1,#self.people do
						if self.people[e].level == #systems[self.system].ranks - 1 then
							if self.people[e].age < self.average + 25 then
								chil = true
								table.insert(chils, e)
								if self.people[e].gender == "Male" then male = true end
							end
						end
					end
				end
				
				if chil == false then
					local z = math.random(1,#self.people)
					local g = 0
					if systems[self.system].dynastic == true then
						g = math.random(1,math.floor(5000/(math.pow(self.people[z].level, 2))))
					else
						g = math.random(1,2500)
					end
					if g == 2 then
						self:setRuler(z)
					end
				else
					if male == false then
						self:setRuler(chils[1])
					else
						for q=1,#chils do
							if self.people[chils[q]].gender == "Male" and self.people[chils[q]].age < self.average + 25 then
								if self.hasruler == -1 then
									self:setRuler(chils[q])
								end
							end
						end
					end
				end
			end
		end
	end
	
	return true
end

function country:setPop(u)
	while u < #self.people do
		if #self.people > 1 then
			local r = math.random(1, #self.people)
			while self.people[r].isruler == true do
				r = math.random(1, #self.people)
			end
			self:delete(r)
		else
			u = #self.people + 1000
		end
	end
	
	while u > #self.people do
		local nn = person:new()
		nn:makename()
		nn.age = math.random(1, 121)
		nn.level = 2
		nn.title = "Citizen"
		self:add(nn)
	end
	
	self.population = #self.people
end

function country:update(ind)
	rseed()
	
	self.stability = self.stability + math.random(-5, 5)
	if self.stability > 100 then self.stability = 100 end
	if self.stability < 1 then self.stability = 1 end
	
	self.strength = self.strength + math.random(-5, 5)
	if self.strength > 100 then self.strength = 100 end
	if self.strength < 1 then self.strength = 1 end
	
	self.age = self.age + 1
	self.population = #self.people
	
	if self.population < 150 then
		self.birthrate = 5
		self.deathrate = 500000
	elseif self.population > 2500 then
		self.birthrate = 10000
		self.deathrate = 150
	else
		self.birthrate = 35
		self.deathrate = 50000
	end
	
	self.hasruler = -1
	self.average = 1
	
	local pmarked = {}
	
	for i=1,#self.people do
		if self.people[i] ~= nil then
			if self.people[i].isruler == true then
				self.hasruler = 0
				self.rulerage = self.people[i].age
			end
			
			self.people[i]:update(self)
			
			local age = self.people[i].age
			if age >= 122 then
				if self.people[i].isruler == true then
					self.hasruler = -1
				end
				
				table.insert(pmarked, i)
			else
				local d = math.random(1, self.deathrate - self.people[i].age)
				if d == 3 then
					if self.people[i].isruler == true then
						self.hasruler = -1
					end
					
					table.insert(pmarked, i)
				else
					self.average = self.average + age
				end
			end
		end
	end
	
	if #self.people > 0 then self.average = self.average / #self.people end
	
	for i=1,#pmarked do
		self:delete(pmarked[i])
		for j=i,#pmarked do
			pmarked[i] = pmarked[i] - 1
		end
	end
	
	local omarked = {}
	local amarked = {}
	
	for i=1,#self.ongoing do
		local found = false
		local er = self.ongoing[i]:reverse()
		
		for j=1,#thisWorld.countries do
			local nr = thisWorld.countries[j].name:reverse()
			if string.len(er) >= string.len(nr) then
				if er:sub(1, #nr) == nr then
					found = true
				end
			end
		end
		
		if found == false then
			table.insert(omarked, i)
		end
	end
	
	for i=1,#self.alliances do
		local found = false
		local ar = self.alliances[i]
		
		for j=1,#thisWorld.countries do
			local nr = thisWorld.countries[j].name
			if string.len(ar) >= string.len(nr) then
				if ar:sub(1, #nr) == nr then
					found = true
				end
			end
		end
		
		if found == false then
			table.insert(amarked, i)
		end
	end
	
	for i=1,#omarked do
		table.remove(self.ongoing, omarked[i])
		for j=i,#omarked do
			omarked[j] = omarked[j] - 1
		end
	end
	
	for i=1,#amarked do
		table.remove(self.alliances, amarked[i])
		for j=i,#amarked do
			amarked[j] = amarked[j] - 1
		end
	end
	
	for i, l in pairs(self.relations) do
		local found = false
		for j, k in pairs(thisWorld.countries) do
			if k.name == i then found = true end
		end
	
		if found == false then
			self.relations[i] = nil
			i = nil
		end
	end
	
	for i, l in pairs(thisWorld.countries) do
		if l.name ~= self.name then
			if self.relations[l.name] == nil then
				self.relations[l.name] = 50
			end
			local v = math.random(-5, 5)
			self.relations[l.name] = self.relations[l.name] + v
			if self.relations[l.name] < 1 then self.relations[l.name] = 1 end
			if self.relations[l.name] > 100 then self.relations[l.name] = 100 end
		end
	end
	
	self:eventloop(self:checkRuler(ind))
end

function country:event(e)
	table.insert(self.events, {["Event"]=e, ["Year"]=years})
end

function country:eventloop(doevents)
	if doevents == true then
		local v = math.floor(10000 * self.stability)
		if v < 1 then v = 1 end
		
		if self.ongoing == nil then self.ongoing = {} end
		if self.relations == nil then self.relations = {} end
		
		for i=1,#self.ongoing do
			if self.ongoing[i] ~= nil then
				local ename = nil
				local eind = nil
				
				for j=1,#c_events do
					if #self.ongoing[i] >= #c_events[j].Name then
						if c_events[j].Name == self.ongoing[i]:sub(1, #c_events[j].Name) then
							ename = c_events[j].Name
							eind = j
						end
					end
				end
				
				if ename ~= nil then
					if c_events[eind]["Args"][1] == 1 then
						c_events[eind]:Step(self)
					elseif c_events[eind]["Args"][1] == 2 then
						local other = nil
						for k=1,#thisWorld.countries do
							if self.ongoing[i] == c_events[eind].Name..thisWorld.countries[k].name then
								other = k
								c_events[eind]:Step(self, thisWorld.countries[other])
							end
						end
					end
				end
			end
		end
		
		local delchance = 1
		if numCountries > maxcountries then delchance = 0 end
		if numCountries < mincountries then delchance = 2 end
		
		for i=1,#c_events do
			local chance = math.floor(math.random(1, v))
			if c_events[i].Name == "Independence" or c_events[i].Name == "Fracture" then
				if delchance == 0 then chance = math.floor(math.random(1, 100000000)) end
				if delchance == 2 then chance = math.floor(math.random(1, 500)) end
			elseif c_events[i].Name == "Conquer" then
				if delchance == 0 then chance = math.floor(math.random(1, 500)) end
				if delchance == 2 then chance = math.floor(math.random(1, 100000000)) end
			end
			
			if chance <= c_events[i]["Chance"] then
				if c_events[i]["Args"][1] == 1 then
					c_events[i]:Perform(self)
				elseif c_events[i]["Args"][1] == 2 then
					local other = math.random(1,#thisWorld.countries)
					while thisWorld.countries[other].name == self.name do other = math.random(1,#thisWorld.countries) end
					c_events[i]:Perform(self, thisWorld.countries[other])
				end
			end
		end
	end
end

function world:new()
	local nm = {}
	setmetatable(nm, world)
	
	nm.countries = {}
	nm.cmarked = {}
	
	numCountries = 0
	years = 0

	return nm
end

function world:destroy()
	for i=1,#self.countries do
		self.countries[i]:destroy()
		self.countries[i] = nil
	end
end

function world:add(nd)
	table.insert(self.countries, nd)
end

function world:delete(nz)
	if nz > 0 and nz <= #self.countries then
		if self.countries[nz] ~= nil then
			local p = table.remove(self.countries, nz)
			if p ~= nil then
				p:destroy()
				p = nil
			end
		end
	end
end

function world:update()
	numCountries = #self.countries
	
	self.cmarked = {}
	
	for i=1,#self.countries do
		if self.countries[i] ~= nil then
			self.countries[i]:update(self, i)
			
			if self.countries[i] ~= nil then
				if self.countries[i].population < 10 then
					self.countries[i].rulers[#self.countries[i].rulers]["To"] = years
					self.countries[i]:event("Disappeared")
					local found = false
					for j=1,#self.cmarked do
						if self.cmarked[j] == i then found = true end
					end
					if found == false then table.insert(self.cmarked, i) end
				end
			end
		end
	end
	
	for i=1,#self.cmarked do
		self:delete(self.cmarked[i])
		for j=i,#self.cmarked do
			self.cmarked[i] = self.cmarked[i] - 1
		end
	end
end

function fromFile(datin)
	local f = assert(io.open(datin, "r"))
	local done = false
	thisWorld = world:new()
	
	while done == false do
		local l = f:read()
		if l == nil then done = true
		else
			local mat = {}
			for q in string.gmatch(l, "%S+") do
				table.insert(mat, tostring(q))
			end
			if mat[1] == "Year" then
				years = tonumber(mat[2])
				maxyears = years + yearstorun
			elseif mat[1] == "C" then
				local nl = country:new()
				nl.name = mat[2]
				nl:setPop(1000)
				thisWorld:add(nl)
			else
				local dynastic = false
				local number = 1
				local gend = "Male"
				local to = years
				if #thisWorld.countries[#thisWorld.countries].rulers > 0 then
					for i=1,#thisWorld.countries[#thisWorld.countries].rulers do
						if thisWorld.countries[#thisWorld.countries].rulers[i]["Name"] == mat[2] then
							if thisWorld.countries[#thisWorld.countries].rulers[i]["Title"] == mat[1] then
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
					table.insert(thisWorld.countries[#thisWorld.countries].rulers, {["Title"]=mat[1], ["Name"]=mat[2], ["Number"]=tostring(number), ["Country"]=thisWorld.countries[#thisWorld.countries].name, ["From"]=mat[3], ["To"]=mat[4]})
					if mat[5] == "F" then gend = "Female" end
				else
					table.insert(thisWorld.countries[#thisWorld.countries].rulers, {["Title"]=mat[1], ["Name"]=mat[2], ["Number"]=mat[3], ["Country"]=thisWorld.countries[#thisWorld.countries].name, ["From"]=mat[4], ["To"]=mat[5]})
					if mat[6] == "F" then gend = "Female" end
				end
				if mat[1] == "King" then thisWorld.countries[#thisWorld.countries].system = 1 end
				if mat[1] == "President" then thisWorld.countries[#thisWorld.countries].system = 2 end
				if mat[1] == "Speaker" then thisWorld.countries[#thisWorld.countries].system = 3 end
				if mat[1] == "Premier" then thisWorld.countries[#thisWorld.countries].system = 4 end
				if mat[1] == "Emperor" then thisWorld.countries[#thisWorld.countries].system = 5 end
				if mat[1] == "Queen" then
					thisWorld.countries[#thisWorld.countries].system = 1
					gend = "Female"
				end
				if mat[1] == "Empress" then
					thisWorld.countries[#thisWorld.countries].system = 5
					gend = "Female"
				end
				local found = false
				for i=1,#thisWorld.countries[#thisWorld.countries].rulernames do
					if thisWorld.countries[#thisWorld.countries].rulernames[i] == mat[2] then found = true end
				end
				for i=1,#thisWorld.countries[#thisWorld.countries].frulernames do
					if thisWorld.countries[#thisWorld.countries].frulernames[i] == mat[2] then found = true end
				end
				if gend == "Female" then
					if found == false then
						table.insert(thisWorld.countries[#thisWorld.countries].frulernames, mat[2])
					end
				else
					if found == false then
						table.insert(thisWorld.countries[#thisWorld.countries].rulernames, mat[2])
					end 
				end
			end
		end
	end
	
	for i=1,#thisWorld.countries do
		if thisWorld.countries[i] ~= nil then
			thisWorld.countries[i].founded = tonumber(thisWorld.countries[i].rulers[1]["From"])
			thisWorld.countries[i].age = years - thisWorld.countries[i].founded
			thisWorld.countries[i]:makename()
			table.insert(final, thisWorld.countries[i])
		end
	end
end

function loop()
	local _running = true
	
	while _running do
		years = years + 1
		thisWorld:update()
		os.execute(clrcmd)
		print("Year "..years.." : "..numCountries.." countries\n")
		
		for i=1,#thisWorld.countries do
			isfinal = true
			for j=1,#final do
				if final[j].name == thisWorld.countries[i].name then isfinal = false end
			end
			if isfinal == true then
				table.insert(final, thisWorld.countries[i])
			end
			if showinfo == 1 then
				local msg = thisWorld.countries[i].name.." ("..systems[thisWorld.countries[i].system].name.."): Population "..thisWorld.countries[i].population.." ("..#thisWorld.countries[i].rulers..")"
				if thisWorld.countries[i].rulers ~= nil then
					if thisWorld.countries[i].rulers[#thisWorld.countries[i].rulers] ~= nil then
						msg = msg.." - Current ruler: "..getPersonString(thisWorld.countries[i].rulers[#thisWorld.countries[i].rulers]).." (age "..thisWorld.countries[i].rulerage..")"
					end
				end
				print(msg)
			end
		end
		
		if showinfo == 1 then
			local wars = {}
			local alliances = {}
		
			local msg = "\nWars: "
		
			for i=1,#thisWorld.countries do
				for j=1,#thisWorld.countries[i].ongoing do
					if thisWorld.countries[i].ongoing[j]:sub(1, 3) == "War" then
						local found = false
						for k=1,#wars do
							if wars[k] == thisWorld.countries[i].ongoing[j]:sub(4, #thisWorld.countries[i].ongoing[j]).."-"..thisWorld.countries[i].name.." " then found = true end
						end
						if found == false then
							table.insert(wars, thisWorld.countries[i].name.."-"..thisWorld.countries[i].ongoing[j]:sub(4, #thisWorld.countries[i].ongoing[j]).." ")
							msg = msg..wars[#wars]
						end
					end
				end
			end
			
			print(msg)
			
			msg = "\nAlliances: "
		
			for i=1,#thisWorld.countries do
				for j=1,#thisWorld.countries[i].alliances do
					local found = false
					for k=1,#alliances do
						if alliances[k] == thisWorld.countries[i].alliances[j].."-"..thisWorld.countries[i].name.." " then found = true end
					end
					if found == false then
						table.insert(alliances, thisWorld.countries[i].name.."-"..thisWorld.countries[i].alliances[j].." ")
						msg = msg..alliances[#alliances]
					end
				end
			end
			
			print(msg)
		end
		
		if years == maxyears then _running = false end
	end
end

function finish()
	print("Printing result...")

	cns = io.output()
	io.output("output.txt")
	
	for i=1,#final do
		local newc = false
		local fr = 1
		local pr = 1
		io.write(string.format("Country "..i..": "..final[i].name.."\nFounded: "..final[i].founded..", survived for "..final[i].age.." years\n\n"))
		
		for k=1,#final[i].events do
			if final[i].events[k]["Event"]:sub(1, 14) == "Fractured from" or final[i].events[k]["Event"]:sub(1, 12) == "Independence" then
				newc = true
				pr = tonumber(final[i].events[k]["Year"])
			end
		end
		
		if newc == true then
			io.write(string.format("1. "..final[i].rulers[1]["Title"].." "..final[i].rulers[1]["Name"].." "..roman(final[i].rulers[1]["Number"]).." of "..final[i].rulers[1]["Country"].." ("..tostring(final[i].rulers[1]["From"]).." - "..tostring(final[i].rulers[1]["To"])..")").."\n...\n")
			for k=1,#final[i].rulers do
				if final[i].rulers[k]["To"] ~= "Current" then
					if tonumber(final[i].rulers[k]["To"]) >= pr then
						if tonumber(final[i].rulers[k]["From"]) < pr then
							io.write(string.format(k..". "..getPersonString(final[i].rulers[k]).."\n"))
							fr = k + 1
							k = #final[i].rulers + 1
						end
					end
				end
			end
		end
		
		for j=pr,maxyears do
			for k=fr,#final[i].rulers do
				if tonumber(final[i].rulers[k]["From"]) == j then
					if final[i].rulers[k]["Title"] == nil then print("Title NIL") end
					if final[i].rulers[k]["Name"] == nil then print("Name NIL") end
					if final[i].rulers[k]["Number"] == nil then print("Number NIL") end
					if final[i].rulers[k]["Country"] == nil then print("Country NIL") end
					if final[i].rulers[k]["From"] == nil then print("From NIL") end
					if final[i].rulers[k]["To"] == nil then print("To NIL") end
					io.write(string.format(k..". "..getPersonString(final[i].rulers[k]).."\n"))
				end
			end
			
			for k=1,#final[i].events do
				if tonumber(final[i].events[k]["Year"]) == j then
					local y = final[i].events[k]["Year"]
					io.write(string.format(y..": "..final[i].events[k]["Event"].."\n"))
				end
			end
		end
		
		io.write("\n\n\n")
	end
	
	io.flush()
	io.output(cns)
end

function main()
	_running = true
	
	io.write(string.format("\t\tCCSIM : Compact Country Simulator\n\n"))
	
	io.write(string.format("\n Are you on a Linux/Mac system, or a Windows system (l/w)? > "))
	local datin = io.read()
	datin = string.lower(datin)
	
	if datin == "l" then clrcmd = "clear" else clrcmd = "cls" end
	
	io.write(string.format("\n How many years should the simulation run? > "))
	datin = io.read()
	
	yearstorun = tonumber(datin)
	while yearstorun == nil do
		io.write(string.format("\n Please enter a number. > "))
		datin = io.read()
		
		yearstorun = tonumber(datin)
	end
	
	maxyears = yearstorun
	
	io.write(string.format("\n Do you want to show detailed info in the console before it is saved (y/n)?\n Answering N may result in a slight speedup. > "))
	datin = io.read()
	datin = string.lower(datin)
	
	if string.lower(datin) == "y" then showinfo = 1 else showinfo = 0 end
	
	io.write(string.format("\n Data > "))
	datin = io.read()
	
	if string.lower(datin) == "random" then
		thisWorld = world:new()
	
		numCountries = 8
	
		for j=1,numCountries do
			local nl = country:new()
			nl:set()
			thisWorld:add(nl)
		end
	else
		fromFile(datin)
	end
	
	loop()
	finish()
	thisWorld = nil
	
	print(" Done!")
end

main()
