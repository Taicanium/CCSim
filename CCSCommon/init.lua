socketstatus, socket = pcall(require, "socket")

Person = require("CCSCommon.Person")()
Party = require("CCSCommon.Party")()
City = require("CCSCommon.City")()
Region = require("CCSCommon.Region")()
Country = require("CCSCommon.Country")()
World = require("CCSCommon.World")()

_time = os.clock
if socketstatus then _time = socket.gettime end

return
	function()
		local CCSCommon = {
			autosaveDur = 100,
			c_events = {
				{
					name="Coup d'Etat",
					chance=10,
					target=nil,
					args=1,
					inverse=false,
					eString="",
					performEvent=function(self, parent, c)
						c:event(parent, "Coup d'Etat")

						parent:rseed()
						local dchance = math.random(1, 100)
						if dchance < 26 then -- Executed
							for q=1,#c.people do if c.people[q] ~= nil then if c.people[q].isruler == true then c:delete(parent, q) end end end
						else -- Exiled
							local newC = parent:randomChoice(parent.thisWorld.countries)
							if parent.numCountries > 1 then while newC.name == c.name do newC = parent:randomChoice(parent.thisWorld.countries) end end
							local ruler = nil
							for q, r in pairs(c.people) do if r.isruler == true then ruler = q end end
							local s = table.remove(c.people, ruler)
							s.isruler = false
							s.region = ""
							s.city = ""
							s.military = false
							s.nationality = newC.name
							if s.spouse ~= nil then s.spouse = nil end
							newC:add(s)
						end

						c.hasruler = -1
						c:checkRuler(parent)

						c.stability = c.stability - 10
						if c.stability < 1 then c.stability = 1 end

						return -1
					end
				},
				{
					name="Revolution",
					chance=5,
					target=nil,
					args=1,
					eString="",
					inverse=false,
					performEvent=function(self, parent, c)
						parent:rseed()
						local dchance = math.random(1, 100)
						if dchance < 51 then -- Executed
							for q=1,#c.people do if c.people[q] ~= nil then if c.people[q].isruler == true then c:delete(parent, q) end end end
						else -- Exiled
							local newC = parent:randomChoice(parent.thisWorld.countries)
							if parent.numCountries > 1 then while newC.name == c.name do newC = parent:randomChoice(parent.thisWorld.countries) end end
							local ruler = nil
							for q, r in pairs(c.people) do if r.isruler == true then ruler = q end end
							local s = table.remove(c.people, ruler)
							s.isruler = false
							s.region = ""
							s.city = ""
							s.military = false
							s.nationality = newC.name
							if s.spouse ~= nil then s.spouse = nil end
							newC:add(s)
						end

						c.hasruler = -1

						local oldsys = parent.systems[c.system].name
						while parent.systems[c.system].name == oldsys do c.system = math.random(1, #parent.systems) end

						c:event(parent, "Revolution: "..oldsys.." to "..parent.systems[c.system].name)
						c.snt[parent.systems[c.system].name] = c.snt[parent.systems[c.system].name] + 1
						c:event(parent, "Establishment of the "..parent:ordinal(c.snt[parent.systems[c.system].name]).." "..c.demonym.." "..c.formalities[parent.systems[c.system].name])
						
						c:checkRuler(parent)
						
						if c.snt[parent.systems[c.system].name] > 1 then
							if parent.systems[c.system].dynastic == true then
								local newRuler = -1
								for i=1,#c.people do if c.people[i].isruler == true then newRuler = i end end
								if c.people[newRuler].royalInfo.LastAncestor ~= "" then
									msg = "Enthronement of "..c.people[newRuler].title.." "..c.people[newRuler].royalName.." "..parent:roman(c.people[newRuler].number).." of "..c.name..", "..parent:generationString(c.people[newRuler].royalInfo.Gens, c.people[newRuler].gender).." of "..c.people[newRuler].royalInfo.LastAncestor
									c:event(parent, msg)
								end
							end
						end

						c.stability = c.stability - 15
						if c.stability < 1 then c.stability = 1 end

						if math.floor(#c.people / 10) > 1 then
							for d=1,math.random(1, math.floor(#c.people / 10)) do
								local z = math.random(1, #c.people)
								c:delete(parent, z)
							end
						end

						return -1
					end
				},
				{
					name="Civil War",
					chance=3,
					target=nil,
					args=1,
					eString="",
					inverse=false,
					status=0,
					opIntervened = {},
					govIntervened = {},
					beginEvent=function(self, parent, c)
						c.civilWars = c.civilWars + 1
						c:event(parent, "Beginning of "..parent:ordinal(c.civilWars).." civil war")
						self.status = 0 -- -100 is victory for the opposition side; 100 is victory for the present government.
						self.status = self.status + parent:strengthFactor(c)
						local statString = ""
						if self.status <= -10 then statString = tostring(math.floor(math.abs(self.status))).."% opposition"
						elseif self.status >= 10 then statString = tostring(math.floor(math.abs(self.status))).."% government"
						else statString = "tossup" end
						if self.status <= -100 then statString = "opposition victory"
						elseif self.status >= 100 then statString = "government victory" end
						self.eString = parent:ordinal(c.civilWars).." "..c.demonym.." civil war ("..statString..")"
						self.opIntervened = {}
						self.govIntervened = {}
					end,
					doStep=function(self, parent, c)
						for i, cp in pairs(parent.thisWorld.countries) do
							if cp.name ~= c.name then
								local interv = false
								for j=1,#self.opIntervened do if self.opIntervened[j] == cp.name then interv = true end end
								for j=1,#self.govIntervened do if self.govIntervened[j] == cp.name then interv = true end end
								if interv == false then
									if cp.relations[c.name] ~= nil then
										if cp.relations[c.name] < 50 then
											local intervene = math.random(1, math.floor(cp.relations[c.name])*4)
											if intervene == 1 then
												c:event(parent, "Intervention on the side of the opposition by "..cp.name)
												cp:event(parent, "Intervened in the "..parent:ordinal(c.civilWars).." "..c.demonym.." civil war on the side of the opposition")
												table.insert(self.opIntervened, cp.name)
											end
										elseif cp.relations[c.name] > 50 then
											local intervene = math.random(50, (150-math.floor(cp.relations[c.name]))*4)
											if intervene == 50 then
												c:event(parent, "Intervention on the side of the government by "..cp.name)
												cp:event(parent, "Intervened in the "..parent:ordinal(c.civilWars).." "..c.demonym.." civil war on the side of the government")
												table.insert(self.govIntervened, cp.name)
											end
										end
									end
								end
							end
						end

						local strFactor = parent:strengthFactor(c)

						local varistab = strFactor

						for i=1,#self.opIntervened do
							for j, cp in pairs(parent.thisWorld.countries) do
								if cp.name == self.opIntervened[i] then
									local extFactor = parent:strengthFactor(cp)

									if extFactor < 0 then varistab = varistab - (extFactor/10) end
								end
							end
						end

						for i=1,#self.govIntervened do
							for j, cp in pairs(parent.thisWorld.countries) do
								if cp.name == self.govIntervened[i] then
									local extFactor = parent:strengthFactor(cp)

									if extFactor > 0 then varistab = varistab + (extFactor/10) end
								end
							end
						end

						self.status = self.status + math.ceil(math.random(math.floor(varistab),math.ceil(varistab))/2)

						local statString = ""
						if self.status <= -10 then statString = tostring(math.floor(math.abs(self.status))).."% opposition"
						elseif self.status >= 10 then statString = tostring(math.floor(math.abs(self.status))).."% government"
						else statString = "tossup" end
						if self.status <= -100 then statString = "opposition victory"
						elseif self.status >= 100 then statString = "government victory" end
						self.eString = parent:ordinal(c.civilWars).." "..c.demonym.." civil war ("..statString..")"

						if self.status <= -100 then return self:endEvent(parent, c) end
						if self.status >= 100 then return self:endEvent(parent, c) end
						return 0
					end,
					endEvent=function(self, parent, c)
						if self.status >= 100 then -- Government victory
							c:event(parent, "End of civil war; victory for "..c.rulers[#c.rulers].title.." "..c.rulers[#c.rulers].name.." "..parent:roman(c.rulers[#c.rulers].number).." of "..c.rulers[#c.rulers].Country)
						else -- Opposition victory
							local dchance = math.random(1, 100)
							if dchance < 51 then -- Executed
								for q=1,#c.people do if c.people[q] ~= nil then if c.people[q].isruler == true then c:delete(parent, q) end end end
							else -- Exiled
								local newC = parent:randomChoice(parent.thisWorld.countries)
								if parent.numCountries > 1 then while newC.name == c.name do newC = parent:randomChoice(parent.thisWorld.countries) end end
								local ruler = nil
								for q, r in pairs(c.people) do if r.isruler == true then ruler = q end end
								local s = table.remove(c.people, ruler)
								s.isruler = false
								s.region = ""
								s.city = ""
								s.military = false
								s.nationality = newC.name
								if s.spouse ~= nil then s.spouse = nil end
								newC:add(s)
							end

							c.hasruler = -1

							local oldsys = parent.systems[c.system].name
							c.system = math.random(1, #parent.systems)

							c:event(parent, "Establishment of the "..parent:ordinal(c.snt[parent.systems[c.system].name]).." "..c.demonym.." "..c.formalities[parent.systems[c.system].name])
							
							c:checkRuler(parent)

							local newRuler = nil
							for i=1,#c.people do if c.people[i].isruler == true then newRuler = i end end

							local namenum = 0
							local prevtitle = ""
							if c.people[newRuler].prevtitle ~= nil then prevtitle = c.people[newRuler].prevtitle.." " end

							if prevtitle == "Homeless " then prevtitle = "" end
							if prevtitle == "Citizen " then prevtitle = "" end
							if prevtitle == "Mayor " then prevtitle = "" end

							if parent.systems[c.system].dynastic == true then
								for i=1,#c.rulers do
									if tonumber(c.rulers[i].From) >= c.founded then
										if c.rulers[i].name == c.people[newRuler].royalName then
											if c.rulers[i].title == c.people[newRuler].title then
												namenum = namenum + 1
											end
										end
									end
								end

								c:event(parent, "End of civil war; victory for "..prevtitle..c.people[newRuler].name.." "..c.people[newRuler].surname.." of the "..c.people[newRuler].party..", now "..c.people[newRuler].title.." "..c.people[newRuler].royalName.." "..parent:roman(namenum).." of "..c.name)
								c.snt[parent.systems[c.system].name] = c.snt[parent.systems[c.system].name] + 1
								if c.snt[parent.systems[c.system].name] > 1 then
									if parent.systems[c.system].dynastic == true then
										if c.people[newRuler].royalInfo.LastAncestor ~= "" then
											msg = "Enthronement of "..c.people[newRuler].title.." "..c.people[newRuler].name.." "..parent:roman(c.people[newRuler].number).." of "..c.name..", "..parent:generationString(c.people[newRuler].royalInfo.Gens, c.people[newRuler].gender).." of "..c.people[newRuler].royalInfo.LastAncestor
											c:event(parent, msg)
										end
									end
								end
							else
								c:event(parent, "End of civil war; victory for "..prevtitle..c.people[newRuler].name.." "..c.people[newRuler].surname.." of the "..c.people[newRuler].party..", now "..c.people[newRuler].title.." "..c.people[newRuler].royalName.." "..c.people[newRuler].surname.." of "..c.name)
								c.snt[parent.systems[c.system].name] = c.snt[parent.systems[c.system].name] + 1
								if c.snt[parent.systems[c.system].name] > 1 then
									if parent.systems[c.system].dynastic == true then
										if c.people[newRuler].royalInfo.LastAncestor ~= "" then
											msg = "Enthronement of "..c.people[newRuler].title.." "..c.people[newRuler].name.." "..parent:roman(c.people[newRuler].number).." of "..c.name..", "..parent:generationString(c.people[newRuler].royalInfo.Gens, c.people[newRuler].gender).." of "..c.people[newRuler].royalInfo.LastAncestor
											c:event(parent, msg)
										end
									end
								end
							end
						end

						return -1
					end,
					performEvent=function(self, parent, c)
						for i=1,#c.ongoing - 1 do
							if c.ongoing[i].name == self.name then return -1 end
						end
						return 0
					end
				},
				{
					name="War",
					chance=10,
					target=nil,
					args=2,
					status=0,
					eString="",
					inverse=true,
					beginEvent=function(self, parent, c1)
						c1:event(parent, "Declared war on "..self.target.name)
						self.target:event(parent, "War declared by "..c1.name)
						self.status = 0 -- -100 is victory for the target; 100 is victory for the initiator.
						self.status = self.status + parent:strengthFactor(c1)
						self.status = self.status - parent:strengthFactor(self.target)
						local statString = ""
						if self.status <= -10 then statString = tostring(math.floor(math.abs(self.status))).."% "..self.target.name
						elseif self.status >= 10 then statString = tostring(math.floor(math.abs(self.status))).."% "..c1.name
						else statString = "tossup" end
						if self.status <= -100 then statString = self.target.demonym.." victory"
						elseif self.status >= 100 then statString = c1.demonym.." victory" end
						self.eString = c1.demonym.."-"..self.target.demonym.." war ("..statString..")"
					end,
					doStep=function(self, parent, c1)
						if self.target == nil then return -1 end

						local ao = parent:getAllyOngoing(c1, self.target, self.name)
						local ac = c1.alliances

						for i=1,#ac do
							local c3 = nil
							for j, cp in pairs(parent.thisWorld.countries) do if cp.name == ac[i] then c3 = cp end end
							if c3 then
								local already = false
								for j=1,#ao do if c3.name == ao[j].name then already = true end end
								if already == false then
									local ic = math.random(1, 25)
									if ic == 10 then
										table.insert(c3.allyOngoing, self.name.."?"..c1.name..":"..self.target.name)

										self.target:event(parent, "Intervention by "..c3.name.." on the side of "..c1.name)
										c1:event(parent, "Intervention by "..c3.name.." against "..self.target.name)
										c3:event(parent, "Intervened on the side of "..c1.name.." in war with "..self.target.name)
									end
								end
							end
						end

						ao = parent:getAllyOngoing(self.target, c1, self.name)
						ac = self.target.alliances

						for i=1,#ac do
							local c3 = nil
							for j, cp in pairs(parent.thisWorld.countries) do if cp.name == ac[i] then c3 = cp end end
							if c3 then
								local already = false
								for j=1,#ao do if c3.name == ao[j].name then already = true end end
								if already == false then
									local ic = math.random(1, 25)
									if ic == 10 then
										table.insert(c3.allyOngoing, self.name.."?"..self.target.name..":"..c1.name)

										c1:event(parent, "Intervention by "..c3.name.." on the side of "..self.target.name)
										self.target:event(parent, "Intervention by "..c3.name.." against "..c1.name)
										c3:event(parent, "Intervened on the side of "..self.target.name.." in war with "..c1.name)
									end
								end
							end
						end

						local str1Factor = parent:strengthFactor(c1)
						local str2Factor = parent:strengthFactor(self.target)

						local varistab = str1Factor - str2Factor

						ao = parent:getAllyOngoing(c1, self.target, self.name)

						for i=1,#ao do
							local extFactor = parent:strengthFactor(ao[i])
							varistab = varistab + (extFactor/10)
						end

						ao = parent:getAllyOngoing(self.target, c1, self.name)

						for i=1,#ao do
							local extFactor = parent:strengthFactor(ao[i])
							varistab = varistab - (extFactor/10)
						end

						self.status = self.status + math.ceil(math.random(math.floor(varistab), math.ceil(varistab))/2)

						local statString = ""
						if self.status <= -10 then statString = tostring(math.floor(math.abs(self.status))).."% "..self.target.name
						elseif self.status >= 10 then statString = tostring(math.floor(math.abs(self.status))).."% "..c1.name
						else statString = "tossup" end
						if self.status <= -100 then statString = self.target.demonym.." victory"
						elseif self.status >= 100 then statString = c1.demonym.." victory" end
						self.eString = c1.demonym.."-"..self.target.demonym.." war ("..statString..")"

						if self.status <= -100 then return self:endEvent(parent, c1) end
						if self.status >= 100 then return self:endEvent(parent, c1) end
						return 0
					end,
					endEvent=function(self, parent, c1)
						local c1strength = c1.strength
						local c2strength = self.target.strength

						if self.status >= 100 then
							c1:event(parent, "Victory in war with "..self.target.name)
							self.target:event(parent, "Defeat in war with "..c1.name)

							c1.stability = c1.stability + 10
							self.target.stability = self.target.stability - 10

							local ao = parent:getAllyOngoing(c1, self.target, self.name)

							for i=1,#ao do
								if ao[i] then
									c1strength = c1strength + ao[i].strength
									ao[i]:event(parent, "Victory with "..c1.name.." in war with "..self.target.name)
								end
							end

							ao = parent:getAllyOngoing(self.target, c1, self.name)

							for i=1,#ao do
								if ao[i] then
									c2strength = c2strength + ao[i].strength
									ao[i]:event(parent, "Defeat with "..self.target.name.." in war with "..c1.name)
								end
							end

							parent:removeAllyOngoing(c1, self.target, self.name)
							parent:removeAllyOngoing(self.target, c1, self.name)

							if c1strength > c2strength + (c2strength / 5) then
								local rcount = 0
								for q, b in pairs(self.target.regions) do rcount = rcount + 1 end
								if rcount > 1 then
									local rname = parent:randomChoice(self.target.regions).name
									parent:RegionTransfer(c1, self.target, rname, false)
								end
							end
						elseif self.status <= -100 then
							c1:event(parent, "Defeat in war with "..self.target.name)
							self.target:event(parent, "Victory in war with "..c1.name)

							c1.stability = c1.stability - 25
							self.target.stability = self.target.stability + 25

							local ao = parent:getAllyOngoing(c1, self.target, self.name)

							for i=1,#ao do
								c1strength = c1strength + ao[i].strength
								ao[i]:event(parent, "Defeat with "..c1.name.." in war with "..self.target.name)
							end

							ao = parent:getAllyOngoing(self.target, c1, self.name)

							for i=1,#ao do
								c2strength = c2strength + ao[i].strength
								ao[i]:event(parent, "Victory with "..self.target.name.." in war with "..c1.name)
							end

							parent:removeAllyOngoing(c1, self.target, self.name)
							parent:removeAllyOngoing(self.target, c1, self.name)

							if c2strength > c1strength + (c1strength / 5) then
								local rcount = 0
								for q, b in pairs(c1.regions) do rcount = rcount + 1 end
								if rcount > 1 then
									local rname = parent:randomChoice(c1.regions).name
									parent:RegionTransfer(self.target, c1, rname, false)
								end
							end
						end

						return -1
					end,
					performEvent=function(self, parent, c1, c2)
						for i=1,#c1.ongoing - 1 do
							if c1.ongoing[i].name == self.name and c1.ongoing[i].target.name == c2.name then return -1 end
						end

						if parent.doR == true then
							local border = false
							local water = {}
							for i=1,#c1.nodes do
								local x = c1.nodes[i][1]
								local y = c1.nodes[i][2]
								local z = c1.nodes[i][3]

								for j=1,#parent.thisWorld.planet[x][y][z].neighbors do
									local neighbor = parent.thisWorld.planet[x][y][z].neighbors[j]
									local nx = neighbor[1]
									local ny = neighbor[2]
									local nz = neighbor[3]
									local nnode = parent.thisWorld.planet[nx][ny][nz]
									if nnode.country == c2.name then border = true end
									if nnode.land == false then water[1] = 1 end
								end
							end

							for i=1,#c2.nodes do
								local x = c2.nodes[i][1]
								local y = c2.nodes[i][2]
								local z = c2.nodes[i][3]

								for j=1,#parent.thisWorld.planet[x][y][z].neighbors do
									local neighbor = parent.thisWorld.planet[x][y][z].neighbors[j]
									local nx = neighbor[1]
									local ny = neighbor[2]
									local nz = neighbor[3]
									local nnode = parent.thisWorld.planet[nx][ny][nz]
									if nnode.country == c1.name then border = true end
									if nnode.land == false then water[2] = 1 end
								end
							end

							if border == false then
								if water[1] == nil or water[2] == nil then return -1 end
							end
						end

						if c1.relations[c2.name] ~= nil then
							if c1.relations[c2.name] < 30 then
								self.target = c2
								return 0
							end
						end

						return -1
					end
				},
				{
					name="Alliance",
					chance=15,
					target=nil,
					args=2,
					inverse=true,
					eString="",
					beginEvent=function(self, parent, c1)
						c1:event(parent, "Entered military alliance with "..self.target.name)
						self.target:event(parent, "Entered military alliance with "..c1.name)
						
						self.eString = c1.demonym.."-"..self.target.demonym.." alliance"
					end,
					doStep=function(self, parent, c1)
						if self.target == nil then return -1 end

						if c1.relations[self.target.name] ~= nil then
							if c1.relations[self.target.name] < 35 then
								local doEnd = math.random(1, 50)
								if doEnd < 5 then return self:endEvent(parent, c1) end
							end
						end

						local doEnd = math.random(1, 500)
						if doEnd < 5 then return self:endEvent(parent, c1) end

						self.eString = c1.demonym.."-"..self.target.demonym.." alliance"

						return 0
					end,
					endEvent=function(self, parent, c1)
						c1:event(parent, "Military alliance severed with "..self.target.name)
						self.target:event(parent, "Military alliance severed with "..c1.name)

						for i=#self.target.alliances,1,-1 do
							if self.target.alliances[i] == c1.name then
								table.remove(self.target.alliances, i)
								i = 0
							end
						end

						for i=#c1.alliances,1,-1 do
							if c1.alliances[i] == self.target.name then
								table.remove(c1.alliances, i)
								i = 0
							end
						end

						return -1
					end,
					performEvent=function(self, parent, c1, c2)
						for i=1,#c1.alliances do
							if c1.alliances[i] == c2.name then return -1 end
						end
						for i=1,#c2.alliances do
							if c2.alliances[i] == c1.name then return -1 end
						end

						if c1.relations[c2.name] ~= nil then
							if c1.relations[c2.name] > 80 then
								self.target = c2
								table.insert(c2.alliances, c1.name)
								table.insert(c1.alliances, c2.name)
								return 0
							end
						end

						return -1
					end
				},
				{
					name="Independence",
					chance=5,
					target=nil,
					args=1,
					inverse=false,
					performEvent=function(self, parent, c)
						parent:rseed()

						local chance = math.random(1, 100)
						local values = 0
						for i, j in pairs(c.regions) do values = values + 1 end

						if chance > 48 then
							if values > 1 then
								local newl = Country:new()
								local nc = parent:randomChoice(c.regions)
								for i, j in pairs(parent.thisWorld.countries) do if j.name == nc.name then return -1 end end

								newl.name = nc.name

								c:event(parent, "Granted independence to "..newl.name)
								newl:event(parent, "Independence from "..c.name)

								newl:set(parent)

								for i=1,#nc.nodes do
									local x = nc.nodes[i][1]
									local y = nc.nodes[i][2]
									local z = nc.nodes[i][3]

									parent.thisWorld.planet[x][y][z].country = newl.name
									parent.thisWorld.planet[x][y][z].region = ""
									parent.thisWorld.planet[x][y][z].city = ""
								end

								if parent.doR == true then newl:setTerritory(parent) end

								newl.rulers = parent:deepcopy(c.rulers)
								newl.rulernames = parent:deepcopy(c.rulernames)
								newl.frulernames = parent:deepcopy(c.frulernames)

								for i, j in pairs(parent.final) do
									if j.name == newl.name then
										local conqYear = nil
										local retrieve = true
										for k, l in pairs(j.events) do
											if l.Event:match("Conquered") then conqYear = l.Year end
											if conqYear ~= nil then if not l.Event:match("Conquered") and not l.Event:match("Loss of") and l.Year ~= conqYear then retrieve = false end end
										end

										if retrieve == true then
											local rIndex = 1
											for k, l in pairs(j.rulers) do
												table.insert(newl.rulers, rIndex, l)
												rIndex = rIndex + 1
											end
											for k, l in pairs(j.rulernames) do table.insert(newl.rulernames, l) end
											for k, l in pairs(j.frulernames) do table.insert(newl.frulernames, l) end
										end
									end
								end

								c.regions[newl.name] = nil
								parent.thisWorld:add(newl)

								c.stability = c.stability - math.random(3, 10)
								if c.stability < 1 then c.stability = 1 end

								if c.capitalregion == newl.name then
									for i, j in pairs(newl.regions) do
										for k, l in pairs(j.cities) do
											if l.name == c.capitalcity then
												local oldcap = c.capitalcity
												local oldreg = c.capitalregion

												local nr = parent:randomChoice(newl.regions)
												c.capitalregion = nr.name
												c.capitalcity = parent:randomChoice(nr.cities).name

												local msg = "Capital moved"
												if oldcap ~= "" then msg = msg.." from "..oldcap end
												msg = msg.." to "..c.capitalcity

												c:event(parent, msg)
											end
										end
									end
								end
							end
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
						for i=1,#c1.alliances do
							if c1.alliances[i] == c2.name then return -1 end
						end

						for i=1,#c2.alliances do
							if c2.alliances[i] == c1.name then return -1 end
						end

						if c1.relations[c2.name] ~= nil then
							if c1.relations[c2.name] < 16 then
								c1:event(parent, "Invaded "..c2.name)
								c2:event(parent, "Invaded by "..c1.name)

								c1.stability = c1.stability - 5
								if c1.stability < 1 then c1.stability = 1 end
								c2.stability = c2.stability - 10
								if c2.stability < 1 then c2.stability = 1 end
								c1:setPop(parent, math.floor(c1.population / 1.25))
								c2:setPop(parent, math.floor(c2.population / 1.75))

								local rcount = 0
								for q, b in pairs(c2.regions) do rcount = rcount + 1 end
								if rcount > 1 and c1.strength > c2.strength + (c2.strength / 5) then
									local rchance = math.random(1, 30)
									if rchance < 5 then
										local rname = parent:randomChoice(c2.regions).name
										parent:RegionTransfer(c1, c2, rname, false)
									end
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
						local subchance = math.random(1, 100)

						if subchance < 50 then
							for i=1,#c1.alliances do
								if c1.alliances[i] == c2.name then return -1 end
							end

							for i=1,#c2.alliances do
								if c2.alliances[i] == c1.name then return -1 end
							end

							if c1.relations[c2.name] ~= nil then
								if c1.relations[c2.name] < 6 then
									c1:event(parent, "Conquered "..c2.name)
									c2:event(parent, "Conquered by "..c1.name)

									for i=#c2.nodes,1,-1 do
										local x = c2.nodes[i][1]
										local y = c2.nodes[i][2]
										local z = c2.nodes[i][3]

										parent.thisWorld.planet[x][y][z].country = c1.name
										table.insert(c1.nodes, {x, y, z})
									end

									c1.stability = c1.stability - 5
									if c1.stability < 1 then c1.stability = 1 end
									if #c2.rulers > 0 then
										c2.rulers[#c2.rulers].To = parent.years
									end

									for i, j in pairs(c2.regions) do
										parent:RegionTransfer(c1, c2, j.name, true)
									end

									parent.thisWorld:delete(parent, c2)
								end
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
						local cCount = 0
						for i, j in pairs(c.regions) do for k, l in pairs(j.cities) do cCount = cCount + 1 end end

						if cCount > 2 then
							local oldcap = c.capitalcity
							if oldcap == nil then oldcap = "" end
							c.capitalregion = nil
							c.capitalcity = nil

							while c.capitalcity == nil do
								for i, j in pairs(c.regions) do
									for k, l in pairs(j.cities) do
										if l.name ~= oldcap then
											if c.capitalcity == nil then
												local chance = math.random(1, 100)
												if chance == 35 then
													c.capitalregion = j.name
													c.capitalcity = l.name

													local msg = "Capital moved"
													if oldcap ~= "" then msg = msg.." from "..oldcap end
													msg = msg.." to "..c.capitalcity

													c:event(parent, msg)
												end
											end
										end
									end
								end
							end
						end

						return -1
					end
				},
				{
					name="Annex",
					chance=4,
					target=nil,
					args=2,
					inverse=false,
					performEvent=function(self, parent, c1, c2)
						local patron = false

						for i=1,#c2.rulers do if c2.rulers[i].Country == c1.name then patron = true end end
						for i=1,#c1.rulers do if c1.rulers[i].Country == c2.name then patron = true end end

						if patron == false then
							if c1.majority == c2.majority then
								if c1.relations[c2.name] ~= nil then
									if c1.relations[c2.name] > 60 then
										c1:event(parent, "Annexed "..c2.name)
										c2:event(parent, "Annexed by "..c1.name)

										for i=#c2.nodes,1,-1 do
											local x = c2.nodes[i][1]
											local y = c2.nodes[i][2]
											local z = c2.nodes[i][3]

											parent.thisWorld.planet[x][y][z].country = c1.name
											table.insert(c1.nodes, {x, y, z})
										end

										c1.stability = c1.stability - 5
										if c1.stability < 1 then c1.stability = 1 end
										if #c2.rulers > 0 then
											c2.rulers[#c2.rulers].To = parent.years
										end

										for i, j in pairs(c2.regions) do
											parent:RegionTransfer(c1, c2, j.name, true)
										end

										parent.thisWorld:delete(parent, c2)
									end
								end
							end
						end

						return -1
					end
				}
			},
			clrcmd = "",
			consonants = {"b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "w", "z"},
			disabled = {},
			doR = false,
			endgroups = {"land", "ia", "lia", "gia", "ria", "nia", "cia", "y", "ar", "ic", "a", "us", "es", "is", "ec", "tria", "tra", "um"},
			ged = false,
			genLimit = 3,
			initialgroups = {"Ab", "Ac", "Af", "Ag", "Al", "Am", "An", "Ar", "As", "At", "Au", "Av", "Ba", "Be", "Bh", "Bi", "Bo", "Bu", "Ca", "Ce", "Ch", "Ci", "Cl", "Co", "Cr", "Cu", "Da", "De", "Di", "Do", "Du", "Dr", "Ec", "El", "Er", "Fa", "Fr", "Ga", "Ge", "Go", "Gr", "Gh", "Ha", "He", "Hi", "Ho", "Hu", "Ic", "Id", "In", "Io", "Ir", "Is", "It", "Ja", "Ji", "Jo", "Ka", "Ke", "Ki", "Ko", "Ku", "Kr", "Kh", "La", "Le", "Li", "Lo", "Lu", "Lh", "Ma", "Me", "Mi", "Mo", "Mu", "Na", "Ne", "Ni", "No", "Nu", "Pa", "Pe", "Pi", "Po", "Pr", "Ph", "Ra", "Re", "Ri", "Ro", "Ru", "Rh", "Sa", "Se", "Si", "So", "Su", "Sh", "Ta", "Te", "Ti", "To", "Tu", "Tr", "Th", "Va", "Vi", "Vo", "Wa", "Wi", "Wo", "Wh", "Za", "Ze", "Zi", "Zo", "Zu", "Zh", "Tha", "Thu", "The", "Thi", "Tho"},
			maxyears = 1,
			middlegroups = {"gar", "rit", "er", "ar", "ir", "ra", "rin", "bri", "o", "em", "nor", "nar", "mar", "mor", "an", "at", "et", "the", "thal", "cri", "ma", "na", "sa", "mit", "nit", "shi", "ssa", "ssi", "ret", "thu", "thus", "thar", "then", "min", "ni", "ius", "us", "es", "ta", "dos", "tho", "tha", "do", "to", "tri"},
			numCountries = 0,
			partynames = {
				{"National", "United", "Citizens'", "General", "People's", "Joint", "Workers'", "Free", "New"},
				{"National", "United", "Citizens'", "General", "People's", "Joint", "Workers'", "Free", "New"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Democratic", "Republican", "Economical", "Moral", "Ethical", "Union", "Unionist", "Revivalist", "Labor", "Monarchist", "Nationalist", "Reformist"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Democratic", "Republican", "Economical", "Moral", "Ethical", "Union", "Unionist", "Revivalist", "Labor", "Monarchist", "Nationalist", "Reformist"},
				{"Party", "Group", "Front", "Coalition", "Force", "Alliance", "Caucus", "Fellowship"},
			},
			popLimit = 2000,
			royals = {},
			showinfo = 0,
			startyear = 1,
			systems = {
				{
					name="Monarchy",
					ranks={"Homeless", "Citizen", "Mayor", "Knight", "Lord", "Baron", "Viscount", "Earl", "Marquis", "Duke", "Prince", "King"},
					franks={"Homeless", "Citizen", "Mayor", "Dame", "Lady", "Baroness", "Viscountess", "Countess", "Marquess", "Duchess", "Princess", "Queen"},
					formalities={"Kingdom", "Crown", "Lordship", "Dominion", "High Kingship"},
					dynastic=true
				},
				{
					name="Republic",
					ranks={"Homeless", "Citizen", "Commissioner", "Mayor", "Councillor", "Governor", "Judge", "Senator", "Minister", "President"},
					formalities={"Republic", "United Republic", "Nation", "Commonwealth", "Federation", "Federal Republic"},
					dynastic=false
				},
				{
					name="Democracy",
					ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Minister", "Speaker", "Prime Minister"},
					formalities={"Union", "Democratic Republic", "Free State", "Realm", "Electorate", "State"},
					dynastic=false
				},
				{
					name="Oligarchy",
					ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Minister", "Oligarch", "Premier"},
					formalities={"People's Republic", "Premiership", "Patriciate", "Autocracy", "Collective"},
					dynastic=false
				},
				{
					name="Empire",
					ranks={"Homeless", "Citizen", "Mayor", "Lord", "Governor", "Viceroy", "Prince", "Emperor"},
					franks={"Homeless", "Citizen", "Mayor", "Lady", "Governor", "Vicereine", "Princess", "Empress"},
					formalities={"Empire", "Emirate", "Magistracy", "Imperium", "Supreme Crown"},
					dynastic=true
				}
			},
			vowels = {"a", "e", "i", "o", "u", "y"},
			years = 1,
			yearstorun = 0,
			final = {},
			thisWorld = nil,

			autoload = function(self)
				print("Opening data file...")
				local f = io.open("in_progress.dat", "r+b")
				print("Reading data file...")

				local jsonLoad = false

				local stat = nil
				local jTable = nil

				if jsonstatus then
					local jData = f:read("*all")
					print("Decoding JSON...")
					stat, jTable = pcall(json.decode, jData)
					if stat then jsonLoad = true
					else print("Saved data does not appear to be in valid JSON format! Attempting to read as native encoding.") end
				end
				
				if jsonLoad == false then
					f:seek("set")
					jTable = self:loadtable(f)
				end

				f:close()
				f = nil

				print("File closed.\nRestoring encoded recursive values...")
				
				self.thisWorld = World:new()

				self:getRecursiveRefs(jTable)
				self:getRecursiveIDs(jTable)
				for i, j in pairs(self) do if jTable[i] ~= nil then self[i] = jTable[i] end end
				for i, j in pairs(self) do if type(j) == "string" then if string.len(j) >= 3 then if j:sub(1, 3) == "ID " then self[i] = jTable[j] end end end end
				jTable = nil

				print("Reconstructing metatables...")

				setmetatable(self.thisWorld, require("CCSCommon.World")())
				for i, j in pairs(self.thisWorld.countries) do
					setmetatable(j, require("CCSCommon.Country")())
					for k, l in pairs(j.people) do
						setmetatable(l, require("CCSCommon.Person")())
					end
					for k, l in pairs(j.parties) do
						setmetatable(l, require("CCSCommon.Party")())
					end
					for k, l in pairs(j.regions) do
						setmetatable(l, require("CCSCommon.Region")())
						for m, n in pairs(l.cities) do
							setmetatable(n, require("CCSCommon.City")())
						end
					end
				end
			end,

			autosave = function(self)
				print("\nAutosaving...")

				local f = io.open("in_progress.dat", "w+b")
				if f then
					print("Encoding recursive values...")

					for i, j in pairs(self.final) do
						for k, l in pairs(self.thisWorld.countries) do
							if j.name == l.name then self.final[i] = nil end
						end
					end

					local ids = {}
					local tables = {}
					self:setRecursiveIDs(self, 1)
					self:setRecursiveRefs(self, ids, tables)
					for i, j in pairs(self) do if type(j) ~= "function" then tables[i] = j end end

					local jsonSaved = false

					if jsonstatus then
						print("Encoding JSON...")
						local stat, jData = pcall(json.encode, tables)
						if stat then
							print("Writing JSON...")
							f:write(jData)
							jsonSaved = true
						else
							print("Unable to encode JSON data! Falling back to native encoding.")
						end
					end

					if jsonSaved == false then self:savetable(self, f) end

					f:flush()
					f:close()
					f = nil

					print("Restoring encoded recursive values...")

					self:getRecursiveRefs(tables)
					self:getRecursiveIDs(tables)
					self.thisWorld = World:new()
					for i, j in pairs(self) do if tables[i] ~= nil then self[i] = tables[i] end end
					for i, j in pairs(self) do if type(j) == "string" then if string.len(j) >= 3 then if j:sub(1, 3) == "ID " then self[i] = tables[j] end end end end
					tables = nil
				else
					print("Unable to open in_progress.dat for writing! Autosave not completed!")
				end
			end,

			checkAutoload = function(self)
				local f = io.open("in_progress.dat", "r")
				if f ~= nil then
					f:close()
					f = nil

					io.write(string.format("\nAn in-progress run was detected. Load from last save point? (y/n) > "))
					local res = io.read()

					if res == "y" then
						self:autoload(self)

						io.write(string.format("\nThis simulation will run for "..tostring(self.maxyears - self.years).." more years. Do you want to change the running time (y/n)? > "))
						res = io.read()
						if res == "y" then
							io.write(string.format("\nYears to add to the current running time ("..tostring(self.maxyears)..") > "))
							res = tonumber(io.read())
							while res == nil do
								io.write(string.format("\nPlease enter a number. > "))
								res = tonumber(io.read())
							end
							self.maxyears = self.maxyears + res
						end

						io.write(string.format("\nDo you want to change the autosave interval, currently every "..tostring(self.autosaveDur).." years (y/n)? > "))
						res = io.read()
						if res == "y" then
							io.write(string.format("\nWhat would you like the new autosave interval to be? > "))
							res = tonumber(io.read())
							while res == nil do
								io.write(string.format("\nPlease enter a number. > "))
								res = tonumber(io.read())
							end
							self.autosaveDur = res
						end

						return true
					end
				end

				return false
			end,

			deepcopy = function(self, obj)
				local res = nil
				local t = type(obj)
				local exceptions = {"spouse", "__index"}

				if t == "table" then
					res = {}
					for i, j in pairs(obj) do
						local isexception = false
						for k=1,#exceptions do if exceptions[k] == tostring(i) then isexception = true end end
						if isexception == false then res[self:deepcopy(i)] = self:deepcopy(j) end
					end
					if getmetatable(obj) ~= nil then setmetatable(res, self:deepcopy(getmetatable(obj))) end
				elseif t == "function" then
					res = self:fncopy(obj)
				else
					res = obj
				end

				return res
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

			finish = function(self)
				os.execute(self.clrcmd)
				print("\nPrinting result...")

				local f = io.open("output.txt", "w+")

				local ged = nil
				local fams = {}

				os.execute(self.clrcmd)

				for i, cp in pairs(self.final) do
					local newc = false
					local fr = 1
					local pr = 1
					f:write(string.format("Country: "..cp.name.."\nFounded: "..cp.founded..", survived for "..(cp.age-1).." years\n\n"))

					for k=1,#cp.events do
						if cp.events[k].Event:sub(1, 12) == "Independence" then
							newc = true
							pr = tonumber(cp.events[k].Year)
						end
					end

					if newc == true then
						f:write(string.format("1. "..self:getRulerString(cp.rulers[1]).."\n"))
						for k=1,#cp.rulers do
							if cp.rulers[k].To ~= "Current" then
								if tonumber(cp.rulers[k].To) >= pr then
									if tonumber(cp.rulers[k].From) < pr then
										f:write(string.format(k..". "..self:getRulerString(cp.rulers[k]).."\n"))
										fr = k + 1
										k = #cp.rulers + 1
									end
								end
							end
						end
					end

					for j=pr,self.maxyears do
						for k=1,#cp.events do
							if tonumber(cp.events[k].Year) == j then
								if cp.events[k].Event:sub(1, 10) == "Revolution" then
									f:write(string.format(cp.events[k].Year..": "..cp.events[k].Event.."\n"))
								end
							end
						end

						for k=fr,#cp.rulers do
							if tonumber(cp.rulers[k].From) == j then
								f:write(string.format(k..". "..self:getRulerString(cp.rulers[k]).."\n"))
							end
						end

						for k=1,#cp.events do
							if tonumber(cp.events[k].Year) == j then
								if cp.events[k].Event:sub(1, 10) ~= "Revolution" then
									f:write(string.format(cp.events[k].Year..": "..cp.events[k].Event.."\n"))
								end
							end
						end
					end

					f:write("\n\n\n")
					f:flush()
				end

				f:close()
				f = nil

				print("")

				if self.ged == true then
					print("Sorting living individuals...")
					local fCount = 0
					local fIndex = 1
					for i, j in pairs(self.thisWorld.countries) do fCount = fCount + 1 end
					for i, j in pairs(self.thisWorld.countries) do
						io.write("\rCountry "..tostring(fIndex).."/"..tostring(fCount))
						j:destroy(self)
						fIndex = fIndex + 1
					end

					print("\nFiltering duplicate or irrelevant individuals. This might take a moment...")
					local fams = self:sortAscendants()

					ged = io.open(tostring(os.time())..".ged", "w+")
					ged:write("0 HEAD\n1 SOUR CCSim\n2 NAME Compact Country Simulator\n1 GEDC\n2 VERS 5.5\n2 FORM LINEAGE-LINKED\n1 CHAR UTF-8\n1 LANG English\n")

					print("")

					local ascCount = 0
					local sRoyals = {}
					local ind = 1
					for i, j in pairs(self.royals) do
						j.index = ind
						sRoyals[ind] = j
						ind = ind + 1
						ascCount = ascCount + 1
					end
					local finished = 0

					for i=1,#sRoyals do
						local j = sRoyals[i]
						local jname = j.name
						if j.royalName ~= "" then jname = j.royalName end
						if j.death >= self.years then j.death = 0 end
						local msgout = "0 @I"..tostring(j.index).."@ INDI\n1 SEX "..j.gender.."\n1 NAME "..jname.." /"..j.surname.."/"
						if j.number ~= 0 then msgout = msgout.." "..self:roman(j.number) end
						if j.title ~= "" then msgout = msgout.."\n2 NPFX "..j.title end
						msgout = msgout.."\n2 GIVN "..jname.."\n2 SURN "..j.surname.."\n"
						if j.number ~= 0 then msgout = msgout.."2 NSFX "..self:roman(j.number).."\n" end
						msgout = msgout.."1 BIRT\n2 DATE "..math.abs(j.birth)
						if j.birth < 0 then msgout = msgout.." B.C." end
						msgout = msgout.."\n2 PLAC "..j.birthplace
						if j.death ~= 0 then msgout = msgout.."\n1 DEAT\n2 DATE "..tostring(j.death).."\n2 PLAC "..j.deathplace end
						if j.ethnicity then
							local ei = 1
							for q, b in pairs(j.ethnicity) do
								if ei == 1 then msgout = msgout.."\n1 NOTE Descent:\n2 CONT " else msgout = msgout.."\n2 CONT " end
								msgout = msgout..tostring(b).."% "..tostring(q)
								ei = ei + 1
							end
						end

						for q, b in pairs(j.fams) do msgout = msgout.."\n1 FAMS @F"..tostring(b).."@" end
						for q, b in pairs(j.famc) do msgout = msgout.."\n1 FAMC @F"..tostring(b).."@" end

						msgout = msgout.."\n"

						ged:write(msgout)

						finished = finished + 1
						percentage = math.floor(finished / ascCount * 10000)/100
						io.write("\rWriting individuals...\t"..tostring(percentage).."    \t% done")
					end

					ged:flush()

					print("")

					for j=1,#fams do
						local msgout = "0 @F"..tostring(j).."@ FAM\n"

						if self.royals[fams[j].husb] ~= nil then msgout = msgout.."1 HUSB @I"..tostring(self.royals[fams[j].husb].index).."@\n" end
						if self.royals[fams[j].wife] ~= nil then msgout = msgout.."1 WIFE @I"..tostring(self.royals[fams[j].wife].index).."@\n" end

						for k=1,#fams[j].chil do
							if fams[j].chil[k] ~= fams[j].husb then
								if fams[j].chil[k] ~= fams[j].wife then
									msgout = msgout.."1 CHIL @I"..tostring(self.royals[fams[j].chil[k]].index).."@\n"
								end
							end
						end

						ged:write(msgout)

						percentage = math.floor(j / #fams * 10000)/100
						io.write("\rWriting families...\t"..tostring(percentage).."    \t% done")
					end

					msgout = "0 TRLR\n"

					ged:write(msgout)
					ged:flush()
					ged:close()
					ged = nil
				end
			end,

			fncopy = function(self, fn)
				dumped = string.dump(fn)
				cloned = loadstring(dumped)
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

			fromFile = function(self, datin)
				print("Opening data file...")
				local f = assert(io.open(datin, "r"))
				local done = false
				self.thisWorld = World:new()

				print("Reading data...")

				local fc = nil
				local fr = nil
				local sysChange = true

				while done == false do
					local l = f:read()
					if l == nil then done = true
					else
						local mat = {}
						for q in string.gmatch(l, "%S+") do
							table.insert(mat, tostring(q))
						end
						if mat[1] == "Year" then
							self.startyear = tonumber(mat[2])
							self.years = tonumber(mat[2])
							self.maxyears = self.maxyears + self.startyear
						elseif mat[1] == "Disable" then
							local sEvent = mat[2]
							for q=3,#mat do sEvent = sEvent.." "..mat[q] end
							table.insert(self.disabled, sEvent)
						elseif mat[1] == "C" then
							local nl = Country:new()
							nl.name = mat[2]
							for q=3,#mat do nl.name = nl.name.." "..mat[q] end
							for q=1,#self.systems do nl.snt[self.systems[q].name] = 0 end
							nl.system = -1
							self.thisWorld:add(nl)
							fc = nl
						elseif mat[1] == "R" then
							local r = Region:new()
							r.name = mat[2]
							for q=3,#mat do r.name = r.name.." "..mat[q] end
							fc.regions[r.name] = r
							fr = r
						elseif mat[1] == "S" then
							local s = City:new()
							s.name = mat[2]
							for q=3,#mat do s.name = s.name.." "..mat[q] end
							fr.cities[s.name] = s
						elseif mat[1] == "P" then
							local s = City:new()
							s.name = mat[2]
							for q=3,#mat do s.name = s.name.." "..mat[q] end
							fc.capitalregion = fr.name
							fc.capitalcity = s.name
							fr.cities[s.name] = s
						else
							local dynastic = false
							local number = 1
							local gend = "Male"
							local to = self.years
							if #fc.rulers > 0 then for i=1,#fc.rulers do if fc.rulers[i].name == mat[2] then if fc.rulers[i].title == mat[1] then number = number + 1 end end end end
							if mat[1] == "King" then dynastic = true end
							if mat[1] == "Emperor" then dynastic = true end
							if mat[1] == "Queen" then dynastic = true end
							if mat[1] == "Empress" then dynastic = true end
							if dynastic == true then table.insert(fc.rulers, {title=mat[1], name=mat[2], surname="", number=tostring(number), Country=fc.name, From=mat[3], To=mat[4]})
							else table.insert(fc.rulers, {title=mat[1], name=mat[2], surname=mat[3], number=mat[3], Country=fc.name, From=mat[4], To=mat[5]}) end
							if mat[1] == "King" then
								local oldsystem = fc.system
								fc.system = 1
								if oldsystem ~= fc.system then fc.snt[self.systems[fc.system].name] = fc.snt[self.systems[fc.system].name] + 1 end
							end
							if mat[1] == "President" then
								local oldsystem = fc.system
								fc.system = 2
								if oldsystem ~= fc.system then fc.snt[self.systems[fc.system].name] = fc.snt[self.systems[fc.system].name] + 1 end
							end
							if mat[1] == "Speaker" then
								local oldsystem = fc.system
								fc.system = 3
								if oldsystem ~= fc.system then fc.snt[self.systems[fc.system].name] = fc.snt[self.systems[fc.system].name] + 1 end
							end
							if mat[1] == "Premier" then
								local oldsystem = fc.system
								fc.system = 4
								if oldsystem ~= fc.system then fc.snt[self.systems[fc.system].name] = fc.snt[self.systems[fc.system].name] + 1 end
							end
							if mat[1] == "Emperor" then
								local oldsystem = fc.system
								fc.system = 5
								if oldsystem ~= fc.system then fc.snt[self.systems[fc.system].name] = fc.snt[self.systems[fc.system].name] + 1 end
							end
							if mat[1] == "Queen" then
								local oldsystem = fc.system
								fc.system = 1
								if oldsystem ~= fc.system then fc.snt[self.systems[fc.system].name] = fc.snt[self.systems[fc.system].name] + 1 end
								gend = "Female"
							end
							if mat[1] == "Empress" then
								local oldsystem = fc.system
								fc.system = 5
								if oldsystem ~= fc.system then fc.snt[self.systems[fc.system].name] = fc.snt[self.systems[fc.system].name] + 1 end
								gend = "Female"
							end
							local found = false
							for i, cp in pairs(fc.rulernames) do
								if cp == mat[2] then found = true end
							end
							for i, cp in pairs(fc.frulernames) do
								if cp == mat[2] then found = true end
							end
							if found == false then
								if gend == "Female" then
									table.insert(fc.frulernames, mat[2])
								else
									table.insert(fc.rulernames, mat[2])
								end
							end
						end
					end
				end

				print("Constructing initial populations...\n")

				for i, cp in pairs(self.thisWorld.countries) do
					if cp ~= nil then
						if #cp.rulers > 0 then
							cp.founded = tonumber(cp.rulers[1].From)
							cp.age = self.years - cp.founded
						else
							cp.founded = self.years
							cp.age = 0
							cp.system = math.random(1, #self.systems)
							cp.snt[self.systems[cp.system].name] = cp.snt[self.systems[cp.system].name] + 1
						end

						cp:makename(self, 3)
						cp:setPop(self, 500)

						table.insert(self.final, cp)
					end
				end

				self.thisWorld.fromFile = true
			end,

			generationString = function(self, n, gen)
				local msgout = ""

				if n > 1 then
					if n > 2 then
						if n > 3 then
							if n > 4 then
								msgout = tostring(n - 2).."-times-great-grand"
								if gen == "Male" then msgout = msgout.."son" else msgout = msgout.."daughter" end
							else
								msgout = "great-great-grand"
								if gen == "Male" then msgout = msgout.."son" else msgout = msgout.."daughter" end
							end
						else
							msgout = "great-grand"
							if gen == "Male" then msgout = msgout.."son" else msgout = msgout.."daughter" end
						end
					else
						msgout = "grand"
						if gen == "Male" then msgout = msgout.."son" else msgout = msgout.."daughter" end
					end
				else
					if gen == "Male" then msgout = "son" else msgout = "daughter" end
				end

				return msgout
			end,

			getAllyOngoing = function(self, country, target, event)
				local acOut = {}

				local ac = #country.alliances
				for i=1,ac do
					local c3 = nil
					for j, cp in pairs(self.thisWorld.countries) do
						if cp.name == country.alliances[i] then c3 = cp end
					end

					if c3 ~= nil then
						for j=#c3.allyOngoing,1,-1 do
							if c3.allyOngoing[j] == event.."?"..country.name..":"..target.name then
								table.insert(acOut, c3)
							end
						end
					end
				end

				return acOut
			end,

			getAscendants = function(self, royals, person)
				local found = false
				local fInd = nil
				local pTable = {
					name=person.name,
					royalName=person.royalName,
					surname=person.surname,
					birth=person.birth,
					death=person.death,
					number=person.number,
					gender=person.gender,
					birthplace=person.birthplace,
					deathplace=person.deathplace,
					father="",
					mother="",
					title="",
					ethnicity=person.ethnicity,
					gens=person.gens,
					gensSet=false,
					children={},
					fams={},
					famc={},
					index=0
				}

				local pString = person.name.." "..person.surname.." "..tostring(person.birth).." "..person.birthplace.." "..person.gender

				if royals[pString] ~= nil then
					if person.death ~= nil then if person.death ~= 0 then if royals[pString].death ~= person.death then royals[pString].death = person.death end end end
					if person.royalName ~= nil then if person.royalName ~= "" then if royals[pString].royalName ~= person.royalName then royals[pString].royalName = person.royalName end end end
					if person.deathplace ~= nil then if person.deathplace ~= "" then if royals[pString].deathplace ~= person.deathplace then royals[pString].deathplace = person.deathplace end end end
					fInd = pString
				end

				if self.ged == true then
					if fInd == nil then
						fInd = pString
						royals[fInd] = pTable
					end

					if person.title ~= nil then if royals[fInd].title ~= person.title then
						if person.title == "King" or person.title == "Queen" or person.title == "Emperor" or person.title == "Empress" then royals[fInd].title = person.title end

						local MorE = -1 -- 0 for Monarchy with male, 1 for Monarchy with female, 2 for Empire with male, 3 for Empire with female
						for k=1,#self.systems do
							if royals[fInd].title == "King" then MorE = 0 end
							if royals[fInd].title == "Queen" then MorE = 1 end
							if royals[fInd].title == "Emperor" then MorE = 2 end
							if royals[fInd].title == "Empress" then MorE = 3 end

							if royals[fInd].gender == "M" then if MorE == 1 then MorE = 0 end if MorE == 3 then MorE = 2 end end
							if royals[fInd].gender == "F" then if MorE == 0 then MorE = 1 end if MorE == 2 then MorE = 3 end end
						end
						if MorE == -1 then royals[fInd].title = "" end
					end end

					if royals[fInd].father == "" then if person.father ~= nil then
						royals[fInd].father = "SCANNING"
						royals[fInd].father = self:getAscendants(royals, person.father)
					end end
					if royals[fInd].mother == "" then if person.mother ~= nil then
						royals[fInd].mother = "SCANNING"
						royals[fInd].mother = self:getAscendants(royals, person.mother)
					end end

					for i, j in pairs(royals[fInd].children) do
						local found = false
						for k, l in pairs(person.children) do if l == j then found = true end end
						if found == false then table.insert(person.children, asc) end
					end

					for i, j in pairs(person.children) do
						local found = false
						local asc = self:getAscendants(royals, j)
						for k, l in pairs(royals[fInd].children) do if l == asc then found = true end end
						if found == false then table.insert(royals[fInd].children, asc) end
					end
				end

				return fInd
			end,

			getfunctionvalues = function(self, fnname, fn, t)
				local found = false
				local exceptions = {"__index", "target"}

				for i, j in pairs(t) do
					if type(j) == "function" then
						if string.dump(fn) == string.dump(j) then
							local q = 1
							while true do
								local name = debug.getupvalue(j, q)
								if not name then break end
								debug.upvaluejoin(fn, q, j, q)
								q = q + 1
							end
						end
					elseif type(j) == "table" then
						local isexception = false
						for q=1,#exceptions do if exceptions[q] == tostring(i) then isexception = true end end
						if isexception == false then self:getfunctionvalues(fnname, fn, j) end
					end
				end
			end,
			
			getRecursiveIDs = function(self, tables)
				for i, j in pairs(tables) do if type(j) == "table" then j.id = nil end end
			end,

			getRecursiveRefs = function(self, tables)
				for i, j in pairs(tables) do if type(j) == "table" then
					local revised = false
					local nJ = {}
					for k, l in pairs(j) do
						if type(l) == "string" then
							if string.len(l) >= 3 then if l:sub(1, 3) == "ID " then if k ~= "id" then if tables[l] ~= nil then j[k] = tables[l] end end end end
							if string.len(l) >= 5 then if l:sub(1, 5) == "FUNC " then j[k] = self:loadfunction(k, l:sub(6, string.len(l))) end end
						end
						
						if type(k) == "string" then if tonumber(k) ~= nil then revised = true nJ[tonumber(k)] = l end end
					end
					if revised == true then tables[i] = nJ end
				end end
			end,

			getRulerString = function(self, data)
				local rString = data.title.." "
				if data then
					if data.royalName then if data.royalName ~= "" then rString = rString..data.royalName.." " else rString = rString..data.name.." " end else rString = rString..data.name.." " end

					if data.Country then
						if tonumber(data.number) ~= nil then rString = rString..self:roman(data.number).." ("..data.surname..") of "..data.Country.." ("..tostring(data.From).." - "..tostring(data.To)..")"
						else rString = rString..data.surname.." of "..data.Country.." ("..tostring(data.From).." - "..tostring(data.To)..")" end
					else
						if tonumber(data.number) ~= 0 then rString = rString..self:roman(data.number).." ("..data.surname..") of "..data.nationality
						else rString = rString..data.surname.." of "..data.nationality end
					end
				else rString = "None" end

				return rString
			end,

			loadfunction = function(self, fnname, fndata)
				local fn = loadstring(fndata)
				if fn then self:getfunctionvalues(fnname, fn, self) return fn else return fndata end
			end,

			loadtable = function(self, f)
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
						tableout[idata] = self:loadtable(f)
					elseif jtype == "function" then
						slen = f:read(1)
						slen = f:read(tonumber(slen))
						local fndata = f:read(tonumber(slen))
						tableout[idata] = self:loadfunction(idata, fndata)
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

			loop = function(self)
				local _running = true
				local msg = ""

				print("\nBegin Simulation!")

				while _running do
					self.thisWorld:update(self)

					for i, cp in pairs(self.thisWorld.countries) do
						for j, k in pairs(self.final) do
							if k.name == cp.name then self.final[j] = nil end
						end

						table.insert(self.final, cp)
					end

					msg = "Year "..self.years.." : "..self.numCountries.." countries\n\n"

					if self.showinfo == 1 then
						local currentEvents = {}

						local cCount = 0

						for i, cp in pairs(self.thisWorld.countries) do
							if cCount <= 20 then
								if cp.snt[self.systems[cp.system].name] > 1 then msg = msg..self:ordinal(cp.snt[self.systems[cp.system].name]).." " end
								local sysName = self.systems[cp.system].name
								if cp.dfif[sysName] == true then msg = msg..cp.demonym.." "..cp.formalities[self.systems[cp.system].name] else msg = msg..cp.formalities[self.systems[cp.system].name].." of "..cp.name end
								msg = msg.." - Population "..cp.population.." - "..self:getRulerString(cp.rulers[#cp.rulers]).."\n"
								cCount = cCount + 1
							end
						end

						if cCount < self.numCountries then msg = msg.."[+"..tostring(self.numCountries-cCount).." more]\n" end

						msg = msg.."\nOngoing events:"
						local eventsWritten = 0

						for i, cp in pairs(self.thisWorld.countries) do for j=1,#cp.ongoing do table.insert(currentEvents, cp.ongoing[j].eString) end end
						for i=1,#currentEvents do
							msg = msg.."\n"..currentEvents[i]
							eventsWritten = eventsWritten + 1
						end
						
						if eventsWritten == 0 then msg = msg.."\nNone" end
					end

					os.execute(self.clrcmd)
					print(msg)

					self.years = self.years + 1

					if self.autosaveDur ~= -1 then
						if math.fmod(self.years, self.autosaveDur) == 1 and self.years > 2 then self:autosave(self) end
					end

					if self.years > self.maxyears then
						_running = false
						if self.doR == true then self.thisWorld:rOutput(self, "final.r") end
						-- self:autosave(self)
					end
				end

				self:finish()

				print("\nEnd Simulation!")
			end,

			makeAscendant = function(self, person)
				local rtitle = person.title
				if person.royalGenerations == 0 then
					if person.royalSystem == "Monarchy" then
						if person.gender == "Male" then rtitle = "King"
						else rtitle = "Queen" end
					elseif person.royalSystem == "Empire" then
						if person.gender == "Male" then rtitle = "Emperor"
						else rtitle = "Empress" end
					end
				end

				local pGender = "M"
				if person.gender == "Female" then pGender = "F" end

				local t = {name=person.name, royalName=person.royalName, surname=person.surname, gender=pGender, number=person.number, birth=person.birth, birthplace=person.birthplace, death=person.death, deathplace=person.deathplace, father=person.father, mother=person.mother, title=rtitle, ethnicity=person.ethnicity, gens=person.royalGenerations, children={}, index=0}
				if person.children ~= nil then for i, j in pairs(person.children) do table.insert(t.children, self:makeAscendant(j)) end end
				return t
			end,

			name = function(self, personal, l)
				local nom = ""
				local length = 0
				if l == nil then length = math.random(2, 3) else length = math.random(1, l) end
				
				local taken = {}

				nom = self:randomChoice(self.initialgroups)
				table.insert(taken, string.lower(nom))
				
				local groups = 1

				while groups < length do
					local ieic = false -- initial ends in consonant
					local mbwc = false -- middle begins with consonant
					for i=1,#self.consonants do
						if nom:sub(#nom, -1) == self.consonants[i] then ieic = true end
					end

					local mid = self:randomChoice(self.middlegroups)
					local istaken = false

					for i=1,#taken do if taken[i] == mid then istaken = true end end

					for i=1,#self.consonants do if mid:sub(1, 1) == self.consonants[i] then mbwc = true end end

					if istaken == false then
						if ieic == true then
							if mbwc == false then
								nom = nom..mid
								groups = groups + 1
								table.insert(taken, string.lower(mid))
							end
						else
							if mbwc == true then
								nom = nom..mid
								groups = groups + 1
								table.insert(taken, string.lower(mid))
							end
						end
					end
				end

				if personal == false then
					local ending = self:randomChoice(self.endgroups)
					nom = nom..ending
				end

				nom = self:namecheck(nom)

				if string.len(nom) == 1 then
					nom = nom..string.lower(self:randomChoice(self.vowels))
				end

				return nom
			end,

			namecheck = function(self, nom)
				local nomin = nom
				local check = true
				while check == true do
					check = false

					for i=1,string.len(nomin)-1 do
						if string.lower(nomin:sub(i, i)) == string.lower(nomin:sub(i+1, i+1)) then
							check = true

							local newnom = ""

							for j=1,i do
								newnom = newnom..nomin:sub(j, j)
							end
							for j=i+2,string.len(nomin) do
								newnom = newnom..nomin:sub(j, j)
							end

							nomin = newnom
						end
					end

					for i=1,string.len(nomin)-3 do
						if string.lower(nomin:sub(i, i+1)) == string.lower(nomin:sub(i+2, i+3)) then
						check = true

						local newnom = ""

						for j=1,i+1 do
							newnom = newnom..nomin:sub(j, j)
						end
						for j=i+4,string.len(nomin) do
							newnom = newnom..nomin:sub(j, j)
						end

						nomin = newnom
					end

					if string.lower(nomin:sub(i, i)) == string.lower(nomin:sub(i+2, i+2)) then
						check = true

						local newnom = ""

						for j=1,i+1 do
							newnom = newnom..nomin:sub(j, j)
						end

						newnom = newnom..self:randomChoice(self.consonants)

						for j=i+3,string.len(nomin) do newnom = newnom..nomin:sub(j, j) end

						nomin = newnom

						end
					end

					for i=1,string.len(nomin)-5 do
						if string.lower(nomin:sub(i, i+2)) == string.lower(nomin:sub(i+3, i+5)) then
							check = true

							local newnom = ""

							for j=1,i+2 do
								newnom = newnom..nomin:sub(j, j)
							end

							for j=i+6,string.len(nomin) do
								newnom = newnom..nomin:sub(j, j)
							end

							nomin = newnom
						end
					end

					for i=1,string.len(nomin)-2 do
						local hasvowel = false

						for j=i,i+2 do
							for k=1,#self.vowels do
								if string.lower(nomin:sub(j, j)) == self.vowels[k] then
									hasvowel = true
								end
							end

							if j > i then -- Make an exception for the 'th' group.
								if string.lower(nomin:sub(j-1, j-1)) == 't' then
									if string.lower(nomin:sub(j, j)) == 'h' then
										hasvowel = true
									end
								end
							end
						end

						if hasvowel == false then
							check = true

							local newnom = ""

							for j=1,i+1 do
								newnom = newnom..nomin:sub(j, j)
							end

							newnom = newnom..self:randomChoice(self.vowels)

							for j=i+3,string.len(nomin) do
								newnom = newnom..nomin:sub(j, j)
							end

							nomin = newnom
						end
					end

					local nomlower = string.lower(nomin)

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
					nomlower = nomlower:gsub("gt", "t")
					nomlower = nomlower:gsub("jc", "j")
					nomlower = nomlower:gsub("hg", "g")
					nomlower = nomlower:gsub("tm", "t")
					nomlower = nomlower:gsub("oa", "a")
					nomlower = nomlower:gsub("cp", "c")
					nomlower = nomlower:gsub("pb", "b")
					nomlower = nomlower:gsub("tg", "t")
					nomlower = nomlower:gsub("bp", "b")
					nomlower = nomlower:gsub("iy", "y")
					nomlower = nomlower:gsub("yi", "y")
					nomlower = nomlower:gsub("fh", "f")
					nomlower = nomlower:gsub("uo", "o")
					nomlower = nomlower:gsub("vh", "v")
					nomlower = nomlower:gsub("vd", "v")
					nomlower = nomlower:gsub("ki", "ci")
					nomlower = nomlower:gsub("fv", "v")
					nomlower = nomlower:gsub("vf", "f")
					nomlower = nomlower:gsub("vt", "t")
					nomlower = nomlower:gsub("tv", "t")
					nomlower = nomlower:gsub("aia", "ia")
					nomlower = nomlower:gsub("eia", "ea")
					nomlower = nomlower:gsub("oia", "ia")
					nomlower = nomlower:gsub("uia", "ia")

					for j=1,#self.consonants do
						if nomlower:sub(1, 1) == self.consonants[j] then
							if nomlower:sub(2, 2) == "b" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "c" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "d" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "f" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "g" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "j" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "k" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "m" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "n" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "p" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "r" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "s" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "t" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "v" then nomlower = nomlower:sub(2, string.len(nomlower)) end
							if nomlower:sub(2, 2) == "z" then nomlower = nomlower:sub(2, string.len(nomlower)) end
						end

						if nomlower:sub(string.len(nomlower), string.len(nomlower)) == self.consonants[j] then
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "b" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "c" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "d" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "f" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "g" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "h" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "j" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "k" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "m" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "n" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "p" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "r" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "s" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "t" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "v" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "w" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
							if nomlower:sub(string.len(nomlower)-1, string.len(nomlower)-1) == "z" then nomlower = nomlower:sub(1, string.len(nomlower)-1) end
						end
					end

					if nomlower ~= string.lower(nomin) then check = true end

					nomin = string.upper(nomlower:sub(1, 1))
					nomin = nomin..nomlower:sub(2, string.len(nomlower))
				end

				if nomin:sub(string.len(nomin)-2, string.len(nomin)) == "lan" then nomin = nomin.."d" end

				return nomin
			end,

			ordinal = function(self, n)
				local tmp = tonumber(n)
				if tmp == nil then return n end
				local fin = ""

				local ts = tostring(n)
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

			randomChoice = function(self, t, doKeys)
				local keys = {}
				for key, value in pairs(t) do keys[#keys+1] = key end
				if #keys == 0 then return nil end
				if #keys == 1 then if doKeys then return keys[1] else return t[keys[1]] end end
				local index = keys[math.random(1, #keys)]
				if doKeys then return index else return t[index] end
			end,

			setRecursiveIDs = function(self, t, i)
				local id = i
				if t.id == nil then
					t.id = "ID "..tostring(id)
					id = id + 1
					for j, k in pairs(t) do
						if type(k) == "table" then id = self:setRecursiveIDs(k, id) end
					end
				end
				return id
			end,

			setRecursiveRefs = function(self, t, taken, tables)
				for i, j in pairs(t) do
					if type(j) == "table" then
						local found = false
						t[i] = j.id
						if taken[j.id] == j.id then found = true end

						if found == false then
							taken[j.id] = j.id
							self:setRecursiveRefs(j, taken, tables)
							tables[j.id] = j
						end
					elseif type(j) == "function" then
						if t.id ~= "ID 1" then
							t[i] = string.dump(j)
							t[i] = "FUNC "..t[i]
						end
					end
				end
			end,

			RegionTransfer = function(self, c1, c2, r, conq)
				if c1 ~= nil and c2 ~= nil then
					local rCount = 0
					for i, j in pairs(c2.regions) do
						rCount = rCount + 1
					end

					local lim = 1
					if conq == true then lim = 0 end

					if rCount > lim then
						if c2.regions[r] ~= nil then
							local rn = c2.regions[r]

							for i=#c2.people,1,-1 do
								if c2.people[i] ~= nil then
									if c2.people[i].region == rn.name then
										if c2.people[i].isruler == false then
											local p = table.remove(c2.people, i)
											p.nationality = c1.name
											c1:add(p)
										else
											c2.people[i].region = ""
											c2.people[i].city = ""
										end
									end
								end
							end

							c1.regions[rn.name] = rn
							c2.regions[rn.name] = nil

							if conq == false then
								if c2.capitalregion == rn.name then
									local msg = "Capital moved from "..c2.capitalcity.." to "

									c2.capitalregion = self:randomChoice(c2.regions).name
									c2.capitalcity = self:randomChoice(c2.regions[c2.capitalregion].cities).name

									msg = msg..c2.capitalcity
									c2:event(self, msg)
								end
							end

							local gainMsg = "Gained the "..rn.name.." region "
							local lossMsg = "Loss of the "..rn.name.." region "

							local cCount = 0
							for i, j in pairs(rn.cities) do cCount = cCount + 1 end
							if cCount > 0 then
								gainMsg = gainMsg.."(including the "
								lossMsg = lossMsg.."(including the "

								if cCount > 1 then
									if cCount == 2 then
										gainMsg = gainMsg.."cities of "
										lossMsg = lossMsg.."cities of "
										local index = 1
										for i, j in pairs(rn.cities) do
											if index ~= cCount then
												gainMsg = gainMsg..j.name.." "
												lossMsg = lossMsg..j.name.." "
											end
											index = index + 1
										end
										index = 1
										for i, j in pairs(rn.cities) do
											if index == cCount then
												gainMsg = gainMsg.."and "..j.name
												lossMsg = lossMsg.."and "..j.name
											end
											index = index + 1
										end
									else
										gainMsg = gainMsg.."cities of "
										lossMsg = lossMsg.."cities of "
										local index = 1
										for i, j in pairs(rn.cities) do
											if index < cCount - 1 then
												gainMsg = gainMsg..j.name..", "
												lossMsg = lossMsg..j.name..", "
											end
											index = index + 1
										end
										index = 1
										for i, j in pairs(rn.cities) do
											if index == cCount - 1 then
												gainMsg = gainMsg..j.name.." "
												lossMsg = lossMsg..j.name.." "
											end
											index = index + 1
										end
										index = 1
										for i, j in pairs(rn.cities) do
											if index == cCount then
												gainMsg = gainMsg.."and "..j.name
												lossMsg = lossMsg.."and "..j.name
											end
											index = index + 1
										end
									end
								else
									for i, j in pairs(rn.cities) do
										gainMsg = gainMsg.."city of "..j.name
										lossMsg = lossMsg.."city of "..j.name
									end
								end

								gainMsg = gainMsg..") "
								lossMsg = lossMsg..") "
							end

							gainMsg = gainMsg.."from "..c2.name
							lossMsg = lossMsg.."to "..c1.name

							c1:event(self, gainMsg)
							c2:event(self, lossMsg)
						end
					end
				end
			end,

			removeAllyOngoing = function(self, country, target, event)
				local ac = #country.alliances
				for i=1,ac do
					local c3 = nil
					for j, cp in pairs(self.thisWorld.countries) do
						if cp.name == country.alliances[i] then c3 = cp end
					end

					if c3 ~= nil then
						for j=#c3.allyOngoing,1,-1 do
							if c3.allyOngoing[j] == event.."?"..country.name..":"..target.name then
								table.remove(c3.allyOngoing, j)
							end
						end
					end
				end
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

			rseed = function(self)
				self:sleep(0.002)
				local tc = _time()
				local n = tonumber(tostring(tc):reverse())
				if n == nil then n = _time() end
				while n < 100000 do n = n * math.floor(math.random(8, 12)) end
				while n > 100000000 do n = n / math.floor(math.random(8, 12)) end
				math.randomseed(math.ceil(n))
				local x = math.random(3, 5)
				local s = math.random(2, 4)
				for i=3,s do math.random(100, 1000) end
				for i=3,x do
					math.randomseed(math.random(math.floor(n), i*math.ceil(n)))
					for j=3,s do math.random(100, 1000) end
				end
				for i=3,s do math.random(100, 1000) end
			end,

			savetable = function(self, t, f)
				local types = {["string"]=1, ["number"]=2, ["boolean"]=3, ["table"]=4, ["function"]=5}
				local exceptions = {"__index"}

				if t.mtname == nil then f:write("5nilmt") else
					f:write(string.len(t.mtname))
					f:write(t.mtname)
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
							self:savetable(j, f)
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

			setGens = function(self, i, v, g)
				local r = self.royals[i]
				if r ~= nil then
					local set = r.gensSet
					r.gensSet = true
					if set == false then
						if r.gens == -1 then r.gens = v
						elseif r.gens >= self.genLimit then r.gens = v end
						if g < 1 then for j, k in pairs(r.children) do self:setGens(k, v, 1) end
						else if r.gens < self.genLimit - 1 and r.gens > -1 then for j, k in pairs(r.children) do self:setGens(k, v, 1) end end end
						self:setGens(r.father, v, 0)
						self:setGens(r.mother, v, 0)
					end
				end
			end,

			setGensChildren = function(self, t, v)
				if t.royalGenerations > v or t.royalGenerations == -1 then t.royalGenerations = v end
				if t.children ~= nil then for i, j in pairs(t.children) do self:setGensChildren(j, v+1) end end
			end,

			sleep = function(self, t)
				local n = _time()
				while _time() < n + t do end
			end,

			sortAscendants = function(self)
				local fams = {}
				local removed = 0
				local oldCount = 0
				local count = 0
				local done = 0

				for i, j in pairs(self.royals) do oldCount = oldCount + 1 end
				count = oldCount

				for i, j in pairs(self.royals) do
					if j.title == "King" or j.title == "Queen" or j.title == "Emperor" or j.title == "Empress" then j.gens = 0 end
					if j.gens == 0 then self:setGens(j.father, -2, 0) end
					if j.gens == 0 then self:setGens(j.mother, -2, 0) end
					if j.gens == 0 then for k, l in pairs(j.children) do self:setGens(l, -2, 1) end end
					done = done + 1
					io.write("\r"..tostring(done).."/"..tostring(count).." sorted.")
				end

				print("")
				done = 0

				for i, j in pairs(self.royals) do
					if j.gens == -1 or j.gens >= self.genLimit then
						self.royals[i] = nil
						removed = removed + 1
					end

					done = done + 1
					io.write("\r"..tostring(done).."/"..tostring(count).." filtered.")
				end

				print("")
				print("\nTrimmed "..tostring(removed).." irrelevant individuals, out of "..tostring(oldCount)..".")

				count = 0
				for i, j in pairs(self.royals) do count = count + 1 end
				oldCount = count
				print("Linking "..tostring(count).." individuals...")

				done = 0

				for i, j in pairs(self.royals) do
					local found = nil
					local chil = true
					for k=#fams,1,-1 do
						if fams[k].husb == j.father and fams[k].wife == j.mother then found = k end

						for l=1,#fams[k].chil do if fams[k].chil[l] == i then found = k chil = false end end
						if found ~= nil then k = 1 end
					end

					if found == nil then
						local doFam = false
						if j.father ~= "" and j.mother ~= "" then if self.royals[j.father] ~= nil and self.royals[j.mother] ~= nil then doFam = true end end
						if doFam == true then
							local fam = {husb=j.father, wife=j.mother, chil={i}}
							table.insert(fams, fam)
							table.insert(self.royals[j.father].fams, #fams)
							table.insert(self.royals[j.mother].fams, #fams)
							table.insert(j.famc, #fams)
						end
					else
						if chil == true then
							table.insert(fams[found].chil, i)
							table.insert(j.famc, found)
						end
					end

					done = done + 1
					io.write("\r"..tostring(done).."/"..tostring(count).." linked.")
				end

				removed = 0
				done = 0
				count = 0
				for i, j in pairs(self.royals) do count = count + 1 end
				print("\nRemoving unrelated individuals...")

				local rel = {}

				for k=1,#fams do
					rel[fams[k].husb] = 1
					rel[fams[k].wife] = 1
					for i, j in pairs(fams[k].chil) do rel[j] = 1 end
				end

				for i, j in pairs(self.royals) do
					if rel[i] == nil then
						self.royals[i] = nil
						removed = removed + 1
					end

					done = done + 1
					io.write("\r"..tostring(done).."/"..tostring(count).." scanned.")
				end

				print("\nRemoved an additional "..tostring(removed).." individuals.")

				return fams
			end,

			strengthFactor = function(self, c)
				local pop = 0
				if c.rulerParty ~= "" then if c.parties[c.rulerParty] ~= nil then pop = c.parties[c.rulerParty].popularity - 50 end end
				return (pop + (c.stability - 50) + (((c.military / #c.people) * 100) - 50))
			end
		}

		return CCSCommon
	end
