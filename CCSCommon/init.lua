require 'CCSCommon.Person'
require 'CCSCommon.Country'
require 'CCSCommon.World'

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
				c.system = math.random(1, #systems)
			end
			
			local ind = 1
			for q=1,#thisWorld.countries do
				if thisWorld.countries[q].name == c.name then
					ind = q
					q = #thisWorld.countries + 1
				end
			end
			c:checkRuler()
			
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
		
			c.system = math.random(1, #systems)
			
			local ind = 1
			for q=1,#thisWorld.countries do
				if thisWorld.countries[q].name == c.name then
					ind = q
					q = #thisWorld.countries + 1
				end
			end
			c:checkRuler()
			
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
			local newl = Country:new()
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

function fromFile(datin)
	local f = assert(io.open(datin, "r"))
	local done = false
	thisWorld = World:new()
	
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
				local nl = Country:new()
				nl.name = mat[2]
				for q=3,#mat do
					nl.name = nl.name.." "..mat[q]
				end
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
