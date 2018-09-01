socket = require("socket")

Person = require("CCSCommon.Person")()
Party = require("CCSCommon.Party")()
City = require("CCSCommon.City")()
Region = require("CCSCommon.Region")()
Country = require("CCSCommon.Country")()
World = require("CCSCommon.World")()

return
	function()
		CCSCommon = {
			autosaveDur = 100,
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
									parent.thisWorld.countries[c].people[q].death = parent.years
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
					chance=4,
					target=nil,
					args=1,
					inverse=false,
					performEvent=function(self, parent, c)
						for q=1,#parent.thisWorld.countries[c].people do
							if parent.thisWorld.countries[c].people[q] ~= nil then
								if parent.thisWorld.countries[c].people[q].isruler == true then
									parent.thisWorld.countries[c].people[q].death = parent.years
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
						parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name] = parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name] + 1
						if parent.thisWorld.fromFile == false then parent.thisWorld.countries[c]:event(parent, "Establishment of the "..parent:ordinal(parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name]).." "..parent.thisWorld.countries[c].demonym.." "..parent.thisWorld.countries[c].formalities[parent.systems[parent.thisWorld.countries[c].system].name]) end
						if parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name] > 1 then
							if parent.systems[parent.thisWorld.countries[c].system].dynastic == true then
								local rul = 0
								for i=1,#parent.thisWorld.countries[c].people do if parent.thisWorld.countries[c].people[i].royal == true then rul = i end end
								if parent.thisWorld.countries[c].people[rul].royalInfo.LastAncestor ~= "" then
									msg = "Enthronement of "..parent.thisWorld.countries[c].people[rul].title.." "..parent.thisWorld.countries[c].people[rul].name.." "..parent:roman(parent.thisWorld.countries[c].people[rul].number).." of "..parent.thisWorld.countries[c].name..", "..parent:generationString(parent.thisWorld.countries[c].people[rul].royalInfo.Gens, parent.thisWorld.countries[c].people[rul].gender).." of "..parent.thisWorld.countries[c].people[rul].royalInfo.LastAncestor
									parent.thisWorld.countries[c]:event(parent, msg)
								end
							end
						end

						parent.thisWorld.countries[c].stability = parent.thisWorld.countries[c].stability + 10
						if parent.thisWorld.countries[c].stability < 1 then parent.thisWorld.countries[c].stability = 1 end

						if math.floor(#parent.thisWorld.countries[c].people / 10) > 1 then
							for d=1,math.random(1, math.floor(#parent.thisWorld.countries[c].people / 10)) do
								local z = math.random(1, #parent.thisWorld.countries[c].people)
								parent.thisWorld.countries[c].death = parent.years
								parent.thisWorld.countries[c]:delete(z)
							end
						end

						parent:rseed()

						return -1
					end
				},
				{
					name="Civil War",
					chance=3,
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
										local intervene = math.random(1, parent.thisWorld.countries[i].relations[parent.thisWorld.countries[c].name]*4)
										if intervene == 1 then
											parent.thisWorld.countries[c]:event(parent, "Intervention on the side of the opposition by "..parent.thisWorld.countries[i].name)
											parent.thisWorld.countries[i]:event(parent, "Intervention in the "..parent:ordinal(parent.thisWorld.countries[c].civilWars).." "..parent.thisWorld.countries[c].demonym.." civil war on the side of the opposition")
											table.insert(self.opIntervened, parent.thisWorld.countries[i].name)
										end
									elseif parent.thisWorld.countries[i].relations[parent.thisWorld.countries[c].name] > 50 then
										local intervene = math.random(50, (150-parent.thisWorld.countries[i].relations[parent.thisWorld.countries[c].name])*4)
										if intervene == 50 then
											parent.thisWorld.countries[c]:event(parent, "Intervention on the side of the government by "..parent.thisWorld.countries[i].name)
											parent.thisWorld.countries[i]:event(parent, "Intervention in the "..parent:ordinal(parent.thisWorld.countries[c].civilWars).." "..parent.thisWorld.countries[c].demonym.." civil war on the side of the government")
											table.insert(self.govIntervened, parent.thisWorld.countries[i].name)
										end
									end
								end
							end
						end

						local varistab = parent.thisWorld.countries[c].stability - 50
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

						if self.status <= -100 then return self:endEvent(parent, c) end
						if self.status >= 100 then return self:endEvent(parent, c) end
						return 0
					end,
					endEvent=function(self, parent, c)
						if self.status >= 100 then -- Government victory
							parent.thisWorld.countries[c]:event(parent, "End of civil war; victory for "..parent.thisWorld.countries[c].rulers[#parent.thisWorld.countries[c].rulers].Title.." "..parent.thisWorld.countries[c].rulers[#parent.thisWorld.countries[c].rulers].name.." "..parent:roman(parent.thisWorld.countries[c].rulers[#parent.thisWorld.countries[c].rulers].Number).." of "..parent.thisWorld.countries[c].rulers[#parent.thisWorld.countries[c].rulers].Country)
						else -- Opposition victory
							for q=1,#parent.thisWorld.countries[c].people do
								if parent.thisWorld.countries[c].people[q] ~= nil then
									if parent.thisWorld.countries[c].people[q].isruler == true then
										parent.thisWorld.countries[c].people[q].death = parent.years
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
								if parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name] > 1 then
									if parent.systems[parent.thisWorld.countries[c].system].dynastic == true then
										local rul = 0
										for i=1,#parent.thisWorld.countries[c].people do if parent.thisWorld.countries[c].people[i].royal == true then rul = i end end
										if parent.thisWorld.countries[c].people[rul].royalInfo.LastAncestor ~= "" then
											msg = "Enthronement of "..parent.thisWorld.countries[c].people[rul].title.." "..parent.thisWorld.countries[c].people[rul].name.." "..parent:roman(parent.thisWorld.countries[c].people[rul].number).." of "..parent.thisWorld.countries[c].name..", "..parent:generationString(parent.thisWorld.countries[c].people[rul].royalInfo.Gens, parent.thisWorld.countries[c].people[rul].gender).." of "..parent.thisWorld.countries[c].people[rul].royalInfo.LastAncestor
											parent.thisWorld.countries[c]:event(parent, msg)
										end
									end
								end
							else
								parent.thisWorld.countries[c]:event(parent, "End of civil war; victory for "..prevTitle..parent.thisWorld.countries[c].people[newRuler].prevName.." "..parent.thisWorld.countries[c].people[newRuler].surname.." of the "..parent.thisWorld.countries[c].people[newRuler].party..", now "..parent.thisWorld.countries[c].people[newRuler].title.." "..parent.thisWorld.countries[c].people[newRuler].name.." "..parent.thisWorld.countries[c].people[newRuler].surname.." of "..parent.thisWorld.countries[c].name)
								parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name] = parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name] + 1
								if parent.thisWorld.fromFile == false then parent.thisWorld.countries[c]:event(parent, "Establishment of the "..parent:ordinal(parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name]).." "..parent.thisWorld.countries[c].demonym.." "..parent.thisWorld.countries[c].formalities[parent.systems[parent.thisWorld.countries[c].system].name]) end
								if parent.thisWorld.countries[c].snt[parent.systems[parent.thisWorld.countries[c].system].name] > 1 then
									if parent.systems[parent.thisWorld.countries[c].system].dynastic == true then
										local rul = 0
										for i=1,#parent.thisWorld.countries[c].people do if parent.thisWorld.countries[c].people[i].royal == true then rul = i end end
										if parent.thisWorld.countries[c].people[rul].royalInfo.LastAncestor ~= "" then
											msg = "Enthronement of "..parent.thisWorld.countries[c].people[rul].title.." "..parent.thisWorld.countries[c].people[rul].name.." "..parent:roman(parent.thisWorld.countries[c].people[rul].number).." of "..parent.thisWorld.countries[c].name..", "..parent:generationString(parent.thisWorld.countries[c].people[rul].royalInfo.Gens, parent.thisWorld.countries[c].people[rul].gender).." of "..parent.thisWorld.countries[c].people[rul].royalInfo.LastAncestor
											parent.thisWorld.countries[c]:event(parent, msg)
										end
									end
								end
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
						local ao = parent:getAllyOngoing(c1, self.target, self.name)
						local ac = parent.thisWorld.countries[c1].alliances

						for i=1,#ac do
							local c3 = 1
							for j=1,#parent.thisWorld.countries do if parent.thisWorld.countries[j].name == ac[i] then c3 = j end end
							local already = false
							for j=1,#ao do if parent.thisWorld.countries[c3].name == parent.thisWorld.countries[ao[j]].name then already = true end end
							if already == false then
								local ic = math.random(1, 25)
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
							local c3 = 1
							for j=1,#parent.thisWorld.countries do if parent.thisWorld.countries[j].name == ac[i] then c3 = j end end
							local already = false
							for j=1,#ao do if parent.thisWorld.countries[c3].name == parent.thisWorld.countries[ao[j]].name then already = true end end
							if already == false then
								local ic = math.random(1, 25)
								if ic == 10 then
									table.insert(parent.thisWorld.countries[c3].allyOngoing, self.name.."?"..parent.thisWorld.countries[self.target].name..":"..parent.thisWorld.countries[c1].name)

									parent.thisWorld.countries[c1]:event(parent, "Intervention by "..parent.thisWorld.countries[c3].name.." on the side of "..parent.thisWorld.countries[self.target].name)
									parent.thisWorld.countries[self.target]:event(parent, "Intervention by "..parent.thisWorld.countries[c3].name.." against "..parent.thisWorld.countries[c1].name)
									parent.thisWorld.countries[c3]:event(parent, "Intervened on the side of "..parent.thisWorld.countries[self.target].name.." in war with "..parent.thisWorld.countries[c1].name)
								end
							end
						end

						local varistab = parent.thisWorld.countries[c1].stability - 50
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
						if self.status >= 100 then return self:endEvent(parent, c1) end
						return 0
					end,
					endEvent=function(self, parent, c1)
						local c1strength = parent.thisWorld.countries[c1].strength
						local c2strength = parent.thisWorld.countries[self.target].strength

						if self.status >= 100 then
							parent.thisWorld.countries[c1]:event(parent, "Victory in war with "..parent.thisWorld.countries[self.target].name)
							parent.thisWorld.countries[self.target]:event(parent, "Defeat in war with "..parent.thisWorld.countries[c1].name)

							parent.thisWorld.countries[c1].strength = parent.thisWorld.countries[c1].strength + 25
							parent.thisWorld.countries[c1].stability = parent.thisWorld.countries[c1].strength + 10
							parent.thisWorld.countries[self.target].strength = parent.thisWorld.countries[self.target].strength - 25
							parent.thisWorld.countries[self.target].stability = parent.thisWorld.countries[self.target].stability - 10

							local ao = parent:getAllyOngoing(c1, self.target, self.name)

							for i=1,#ao do
								c1strength = c1strength + parent.thisWorld.countries[ao[i]].strength
								parent.thisWorld.countries[ao[i]]:event(parent, "Victory with "..parent.thisWorld.countries[c1].name.." in war with "..parent.thisWorld.countries[self.target].name)
								parent.thisWorld.countries[ao[i]].strength = parent.thisWorld.countries[ao[i]].strength + 10
							end

							ao = parent:getAllyOngoing(self.target, c1, self.name)

							for i=1,#ao do
								c2strength = c2strength + parent.thisWorld.countries[ao[i]].strength
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

							local ao = parent:getAllyOngoing(c1, self.target, self.name)

							for i=1,#ao do
								c1strength = c1strength + parent.thisWorld.countries[ao[i]].strength
								parent.thisWorld.countries[ao[i]]:event(parent, "Defeat with "..parent.thisWorld.countries[c1].name.." in war with "..parent.thisWorld.countries[self.target].name)
								parent.thisWorld.countries[ao[i]].strength = parent.thisWorld.countries[ao[i]].strength - 10
							end

							ao = parent:getAllyOngoing(self.target, c1, self.name)

							for i=1,#ao do
								c2strength = c2strength + parent.thisWorld.countries[ao[i]].strength
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

						local already = false
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
					chance=8,
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
								local doEnd = math.random(1, 50)
								if doEnd < 5 then return self:endEvent(parent, c1) end
							end
						end

						local doEnd = math.random(1, 500)
						if doEnd < 5 then return self:endEvent(parent, c1) end

						return 0
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

						local chance = math.random(1, 100)

						if chance > 50 then
							local values = {}

							for i, j in pairs(parent.thisWorld.countries[c].regions) do
								table.insert(values, j.name)
							end

							if #values > 1 then
								local v = values[math.random(1, #values)]

								local newl = Country:new()
								local nc = parent.thisWorld.countries[c].regions[v]

								newl.name = nc.name

								parent.thisWorld.countries[c]:event(parent, "Granted independence to "..newl.name)
								newl:event(parent, "Independence from "..parent.thisWorld.countries[c].name)

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
						end

						return -1
					end
				},
				{
					name="Invade",
					chance=4,
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

								local rchance = math.random(1, 30)
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
									local x = parent.thisWorld.countries[c2].nodes[i][1]
									local y = parent.thisWorld.countries[c2].nodes[i][2]
									local z = parent.thisWorld.countries[c2].nodes[i][3]

									parent.thisWorld.planet[x][y][z].country = parent.thisWorld.countries[c1].name
									table.insert(parent.thisWorld.countries[c1].nodes, {x, y, z})
								end

								for i=1,#parent.thisWorld.countries[c2].ascendants do
									table.insert(parent.thisWorld.countries[c1].ascendants, parent.thisWorld.countries[c2].ascendants[i])
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

								parent.thisWorld:delete(parent, c2)
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
										if parent.thisWorld.countries[c].capitalcity == nil then
											local chance = math.random(1, 100)
											if chance == 35 then
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
						end

						return -1
					end
				}
			},
			clrcmd = "",
			consonants = {"b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "w", "z"},
			doR = false,
			endgroups = {"land", "ia", "lia", "gia", "ria", "nia", "cia", "y", "ar", "ic", "a", "us", "es", "is", "ec", "tria", "tra", "um"},
			ged = false,
			initialgroups = {"Ab", "Ac", "Af", "Ag", "Al", "Am", "An", "Ar", "As", "At", "Au", "Av", "Ba", "Be", "Bh", "Bi", "Bo", "Bu", "Ca", "Ce", "Ch", "Ci", "Cl", "Co", "Cr", "Cu", "Da", "De", "Di", "Do", "Du", "Dr", "Ec", "El", "Er", "Fa", "Fr", "Ga", "Ge", "Go", "Gr", "Gh", "Ha", "He", "Hi", "Ho", "Hu", "Ja", "Ji", "Jo", "Ka", "Ke", "Ki", "Ko", "Ku", "Kr", "Kh", "La", "Le", "Li", "Lo", "Lu", "Lh", "Ma", "Me", "Mi", "Mo", "Mu", "Na", "Ne", "Ni", "No", "Nu", "Pa", "Pe", "Pi", "Po", "Pr", "Ph", "Ra", "Re", "Ri", "Ro", "Ru", "Rh", "Sa", "Se", "Si", "So", "Su", "Sh", "Ta", "Te", "Ti", "To", "Tu", "Tr", "Th", "Va", "Vi", "Vo", "Wa", "Wi", "Wo", "Wh", "Za", "Ze", "Zi", "Zo", "Zu", "Zh", "Tha", "Thu", "The"},
			maxyears = 1,
			metatables = {{World, "World"}, {Country, "Country"}, {Region, "Region"}, {City, "City"}, {Person, "Person"}, {Party, "Party"}},
			middlegroups = {"gar", "rit", "er", "ar", "ir", "ra", "rin", "bri", "o", "em", "nor", "nar", "mar", "mor", "an", "at", "et", "the", "thal", "cri", "ma", "na", "sa", "mit", "nit", "shi", "ssa", "ssi", "ret", "thu", "thus", "thar", "then", "min", "ni", "ius", "us", "es", "ta", "dos"},
			numCountries = 0,
			partynames = {
				{"National", "United", "Citizens'", "General", "People's", "Joint", "Workers'", "Free", "New"},
				{"National", "United", "Citizens'", "General", "People's", "Joint", "Workers'", "Free", "New"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Democratic", "Republican", "Economical", "Moral", "Ethical", "Union", "Unionist", "Revivalist", "Labor", "Monarchist", "Nationalist", "Reformist"},
				{"Liberal", "Moderate", "Conservative", "Centralist", "Democratic", "Republican", "Economical", "Moral", "Ethical", "Union", "Unionist", "Revivalist", "Labor", "Monarchist", "Nationalist", "Reformist"},
				{"Party", "Group", "Front", "Coalition", "Force", "Alliance", "Caucus", "Fellowship"},
			},
			popLimit = 10000,
			resort = false,
			showinfo = 0,
			startyear = 1,
			systems = {
				{
					name="Monarchy",
					ranks={"Homeless", "Citizen", "Mayor", "Knight", "Baron", "Viscount", "Earl", "Marquis", "Lord", "Duke", "Prince", "King"},
					franks={"Homeless", "Citizen", "Mayor", "Dame", "Baroness", "Viscountess", "Countess", "Marquess", "Lady", "Duchess", "Princess", "Queen"},
					formalities={"Kingdom", "Crown", "Lordship", "Dominion", "Monarchy"},
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
					formalities={"Union", "Democratic Republic", "Free State", "Realm"},
					dynastic=false
				},
				{
					name="Oligarchy",
					ranks={"Homeless", "Citizen", "Mayor", "Councillor", "Governor", "Minister", "Oligarch", "Premier"},
					formalities={"People's Republic", "Premiership", "Patriciate", "Autocracy"},
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
			vowels = {"a", "e", "i", "o", "u"},
			years = 1,
			yearstorun = 0,
			final = {},
			thisWorld = nil,

			checkAutoload = function(self)
				local f = io.open("in_progress.dat", "r")
				if f ~= nil then
					f:close()
					f = nil

					self.thisWorld = World:new()

					io.write("\nAn in-progress run was detected. Load from last save point? (y/n) > ")
					local res = io.read()

					if res == "y" then
						self.thisWorld:autoload(self)
						
						io.write("\nThis simulation will run for "..tostring(self.maxyears - self.years).." more years. Do you want to change the running time (y/n)? > ")
						res = io.read()
						if res == "y" then
							io.write("\nYears to add to the current running time ("..tostring(self.maxyears)..") > ")
							res = tonumber(io.read())
							while res == nil do
								io.write("\nPlease enter a number. > ")
								res = tonumber(io.read())
							end
							self.maxyears = self.maxyears + res
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

			finish = function(self, parent)
				os.execute(self.clrcmd)
				print("\nPrinting result...")

				local f = io.open("output.txt", "w+")

				local ged = nil
				self.resort = false
				local royals = {}
				local fams = {}

				for i=1,#self.final do					
					local newc = false
					local fr = 1
					local pr = 1
					f:write(string.format("Country: "..self.final[i].name.."\nFounded: "..self.final[i].founded..", survived for "..self.final[i].age.." years\n\n"))

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
									f:write(string.format(self.final[i].events[k].Year..": "..self.final[i].events[k].Event.."\n"))
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
									f:write(string.format(self.final[i].events[k].Year..": "..self.final[i].events[k].Event.."\n"))
								end
							end
						end
					end

					f:write("\n\n\n")
					f:flush()
				end

				f:close()
				f = nil

				if self.ged == true then
					local percentage = 0
					
					for i=1,#self.final do
						self.resort = false
						self.final[i]:destroy()

						local formerTotal = #royals

						for j=1,#self.final[i].ascendants do
							percentage = tostring(((j / #self.final[i].ascendants) * 100) - math.fmod((j / #self.final[i].ascendants) * 100, 0.01))
							io.write("\rListing people for country "..tostring(i).."/"..tostring(#self.final).."...\t"..percentage.."\t% done")

							self:getAscendants(self.final[i], royals, self.final[i].ascendants[j])
						end

						if self.resort == true then
							print("")
						
							local limit = #royals
							local j = 1
							local adjusts = {}
							while j <= limit do
								for k=#royals,formerTotal+1,-1 do
									if j ~= k then
										if j <= limit then
											if royals[k].birth == royals[j].birth then
												if royals[k].name == royals[j].name then
													if royals[k].surname == royals[j].surname then
														if royals[k].gender == royals[j].gender then
															if royals[k].number == royals[j].number then
																if royals[k].title == royals[j].title then
																	table.insert(adjusts, {k, j})
																	if royals[k].death ~= 0 then royals[j].death = royals[k].death end
																	if royals[k].deathplace ~= "" then royals[j].deathplace = royals[k].deathplace end
																	table.remove(royals, k)
																	limit = limit - 1
																	if k <= j then j = j - 1 end
																end
															end
														end
													end
												end
											end
										end
									end
								end

								percentage = tostring(((j / limit) * 100) - math.fmod((j / limit) * 100, 0.01))
								io.write("\rRemoving duplicate people for country "..tostring(i).."/"..tostring(#self.final).."...\t"..percentage.."\t% done")

								j = j + 1
							end

							if formerTotal ~= #royals then
								print("")
								
								for j=formerTotal+1,#royals do
									for k=1,#adjusts do
										if royals[j].father == adjusts[k][1] then royals[j].father = adjusts[k][2] end
										if royals[j].father > adjusts[k][1] then royals[j].father = royals[j].father - 1 end
										if royals[j].mother == adjusts[k][1] then royals[j].mother = adjusts[k][2] end
										if royals[j].mother > adjusts[k][1] then royals[j].mother = royals[j].mother - 1 end
									end

									if royals[j].father > #royals then royals[j].father = 0 end
									if royals[j].mother > #royals then royals[j].mother = 0 end
									
									percentage = tostring((((j-formerTotal) / (#royals-formerTotal)) * 100) - math.fmod(((j-formerTotal) / (#royals-formerTotal)) * 100, 0.01))
									io.write("\rSorting people for country "..tostring(i).."/"..tostring(#self.final).."...\t"..percentage.."\t% done")
								end

								print("")

								for j=formerTotal+1,#royals do
									local found = nil
									local chil = false
									for k=1,#fams do
										if royals[j].father ~= 0 then
											if fams[k].husb == royals[j].father and fams[k].wife == royals[j].mother then found = k end
										end

										if royals[j].mother ~= 0 then
											if fams[k].husb == royals[j].father and fams[k].wife == royals[j].mother then found = k end
										end

										for l=1,#fams[k].chil do if fams[k].chil[l] == j then found = k chil = true end end
									end

									if found == nil then
										local doFam = false
										if royals[j].father ~= 0 then
											if royals[j].mother ~= 0 then
												doFam = true
											end
										end
										if doFam == true then table.insert(fams, {husb=royals[j].father, wife=royals[j].mother, chil={j}}) end
									else
										if chil == false then table.insert(fams[found].chil, j) end
									end
									
									percentage = tostring((((j-formerTotal) / (#royals-formerTotal)) * 100) - math.fmod(((j-formerTotal) / (#royals-formerTotal)) * 100, 0.01))
									io.write("\rSorting families for country "..tostring(i).."/"..tostring(#self.final).."...\t"..percentage.."\t% done")
								end
							end
						end
					end

					ged = io.open(tostring(os.time())..".ged", "w+")
					ged:write("0 HEAD\n1 SOUR CCSim\n2 NAME Compact Country Simulator\n1 GEDC\n2 VERS 5.5\n2 FORM LINEAGE-LINKED\n1 CHAR UTF-8\n1 LANG English\n")

					os.execute(self.clrcmd)

					for j=1,#royals do
						local msgout = "0 @I"..tostring(j).."@ INDI\n1 SEX "..royals[j].gender.."\n1 NAME "..royals[j].name.." /"..royals[j].surname.."/"
						if royals[j].number ~= 0 then msgout = msgout.." "..self:roman(royals[j].number) end
						if royals[j].number ~= 0 then msgout = msgout.."\n2 NPFX "..royals[j].title end
						msgout = msgout.."\n2 SURN "..royals[j].surname.."\n2 GIVN "..royals[j].name.."\n"
						if royals[j].number ~= 0 then msgout = msgout.."2 NSFX "..self:roman(royals[j].number).."\n" end
						msgout = msgout.."1 BIRT\n2 DATE "..math.abs(royals[j].birth)
						if royals[j].birth < 0 then msgout = msgout.." B.C." end
						msgout = msgout.."\n2 PLAC "..royals[j].birthplace
						if tostring(royals[j].death) ~= "0" then msgout = msgout.."\n1 DEAT\n2 DATE "..tostring(royals[j].death).."\n2 PLAC "..royals[j].deathplace end

						local writePerson = false
						for k=1,#fams do
							if fams[k].husb == j then
								msgout = msgout.."\n1 FAMS @F"..tostring(k).."@"
								writePerson = true
							elseif fams[k].wife == j then
								msgout = msgout.."\n1 FAMS @F"..tostring(k).."@"
								writePerson = true
							else
								for l=1,#fams[k].chil do
									if fams[k].chil[l] == j then
										msgout = msgout.."\n1 FAMC @F"..tostring(k).."@"
										writePerson = true
									end
								end
							end
						end

						msgout = msgout.."\n"

						if writePerson == true then
							ged:write(msgout)
							ged:flush()
						end

						percentage = tostring(((j / #royals) * 100) - math.fmod((j / #royals) * 100, 0.01))
						io.write("\rWriting individuals...\t"..percentage.."\t% done")
					end

					print("")

					for j=1,#fams do
						local msgout = "0 @F"..tostring(j).."@ FAM\n"

						if fams[j].husb ~= 0 then
							msgout = msgout.."1 HUSB @I"..tostring(fams[j].husb).."@\n"
						end

						if fams[j].wife ~= 0 then
							msgout = msgout.."1 WIFE @I"..tostring(fams[j].wife).."@\n"
						end

						for k=1,#fams[j].chil do
							if fams[j].chil[k] ~= fams[j].husb then
								if fams[j].chil[k] ~= fams[j].wife then
									msgout = msgout.."1 CHIL @I"..tostring(fams[j].chil[k]).."@\n"
								end
							end
						end

						ged:write(msgout)
						ged:flush()

						percentage = tostring(((j / #fams) * 100) - math.fmod((j / #fams) * 100, 0.01))
						io.write("\rWriting families...\t"..percentage.."\t% done")
					end

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

				local fc = 0
				local fr = 0

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
						elseif mat[1] == "C" then
							local nl = Country:new()
							nl.name = mat[2]
							for q=3,#mat do
								nl.name = nl.name.." "..mat[q]
							end
							self.thisWorld:add(nl)
							fc = #self.thisWorld.countries
						elseif mat[1] == "R" then
							local r = Region:new()
							r.name = mat[2]
							for q=3,#mat do
								r.name = r.name.." "..mat[q]
							end
							self.thisWorld.countries[fc].regions[r.name] = r
							fr = r.name
						elseif mat[1] == "S" then
							local s = City:new()
							s.name = mat[2]
							for q=3,#mat do
								s.name = s.name.." "..mat[q]
							end
							self.thisWorld.countries[fc].regions[fr].cities[s.name] = s
						elseif mat[1] == "P" then
							local s = City:new()
							s.name = mat[2]
							for q=3,#mat do
								s.name = s.name.." "..mat[q]
							end
							self.thisWorld.countries[fc].capitalregion = fr
							self.thisWorld.countries[fc].capitalcity = s.name
							self.thisWorld.countries[fc].regions[fr].cities[s.name] = s
						else
							local dynastic = false
							local number = 1
							local gend = "Male"
							local to = self.years
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
							local found = false
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
						self.thisWorld.countries[i]:setPop(self, 500)

						table.insert(self.final, self.thisWorld.countries[i])
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

				local ac = #self.thisWorld.countries[country].alliances
				for i=1,ac do
					local c3 = nil
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

			getAscendants = function(self, final, royals, person)
				local found = false
				local fInd = 0
				for k=1,#royals do
					if royals[k].birth == person.Birth then
						if royals[k].name == person.Name then
							if royals[k].gender == person.Gender then
								if royals[k].surname == person.Surname then
									if royals[k].number == person.Number then
										if royals[k].birthplace == person.BirthPlace then
											found = true
											fInd = k
											if person.Death ~= 0 then royals[k].death = person.Death end
											if person.DeathPlace ~= "" then royals[k].deathplace = person.DeathPlace end
										end
									end
								end
							end
						end
					end
				end

				if found == false then
					self.resort = true

					table.insert(royals, {
						name=person.Name,
						surname=person.Surname,
						birth=person.Birth,
						death=person.Death,
						number=person.Number,
						gender=person.Gender,
						birthplace=person.BirthPlace,
						deathplace=person.DeathPlace,
						father=0,
						mother=0,
						title=person.Title
					})

					fInd = #royals

					local MorE = 0 -- 0 for Monarchy with male, 1 for Monarchy with female, 2 for Empire with male, 3 for Empire with female
					for k=1,#self.systems do
						if self.systems[k].name == "Monarchy" then
							for l=1,#self.systems[k].ranks do
								if self.systems[k].ranks[l] == royals[fInd].title then MorE = 0 end
							end
							for l=1,#self.systems[k].franks do
								if self.systems[k].franks[l] == royals[fInd].title then MorE = 1 end
							end
						elseif self.systems[k].name == "Empire" then
							for l=1,#self.systems[k].ranks do
								if self.systems[k].ranks[l] == royals[fInd].title then MorE = 2 end
							end
							for l=1,#self.systems[k].franks do
								if self.systems[k].franks[l] == royals[fInd].title then MorE = 3 end
							end
						end
					end
					if MorE == 0 then royals[fInd].title = "King" elseif MorE == 1 then royals[fInd].title = "Queen" elseif MorE == 2 then royals[fInd].title = "Emperor" else royals[fInd].title = "Empress" end

					if person.Father ~= nil then
						royals[fInd].father = self:getAscendants(final, royals, person.Father)
					end

					if person.Mother ~= nil then
						royals[fInd].mother = self:getAscendants(final, royals, person.Mother)
					end
				end

				return fInd
			end,

			getRulerString = function(self, data)
				return string.format(data.Title.." "..data.name.." "..self:roman(data.Number).." of "..data.Country.." ("..tostring(data.From).." - "..tostring(data.To)..")")
			end,

			loop = function(self)
				local _running = true
				local msg = ""

				print("\nBegin Simulation!")

				while _running do
					self.thisWorld:update(self)

					os.execute(self.clrcmd)
					msg = "Year "..self.years.." : "..self.numCountries.." countries\n\n"

					for i=1,#self.thisWorld.countries do
						for j=#self.final,1,-1 do
							if self.final[j].name == self.thisWorld.countries[i].name then table.remove(self.final, j) end
						end

						table.insert(self.final, self.thisWorld.countries[i])
					end

					if self.showinfo == 1 then
						local wars = {}
						local alliances = {}

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
						local count = 0

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

					if self.years >= self.maxyears then
						_running = false
						if self.doR == true then self.thisWorld:rOutput(self, "final.r") end
					end

					if #self.thisWorld.countries == 0 then
						_running = false
					end

					self.years = self.years + 1
					
					if self.autosaveDur ~= 0 then
						if math.fmod(self.years, self.autosaveDur) == 0 then self.thisWorld:autosave(self) end
					end
				end

				self:finish()

				os.execute(self.clrcmd)
				print("\nEnd Simulation!")
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

				nom = self:namecheck(nom)

				if string.len(nom) == 1 then
					nom = nom..string.lower(self.vowels[math.random(1, #self.vowels)])
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

						newnom = newnom..self.consonants[math.random(1, #self.consonants)]

						for j=i+3,string.len(nomin) do
							newnom = newnom..nomin:sub(j, j)
						end

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

							newnom = newnom..self.vowels[math.random(1, #self.vowels)]

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

					if nomlower ~= string.lower(nomin) then check = true end

					nomin = string.upper(nomlower:sub(1, 1))
					nomin = nomin..nomlower:sub(2, string.len(nomlower))
				end

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
							rn.nodes = self:deepcopy(rm.nodes)
							rn.cities = self:deepcopy(rm.cities)

							for i=1,#self.thisWorld.countries[c2].people do
								if self.thisWorld.countries[c2].people[i] ~= nil then
									if self.thisWorld.countries[c2].people[i].region == rn.name then
										self.thisWorld.countries[c2].people[i].region = ""
										self.thisWorld.countries[c2].people[i].city = ""
									end
								end
							end

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
							
							local gainMsg = "Gained the "..rn.name.." region "
							local lossMsg = "Loss of the "..rn.name.." region "
							
							local cCount = 0
							for q=1,#rn.cities do cCount = cCount + 1 end
							if cCount > 0 then
								gainMsg = gainMsg.."(including the "
								lossMsg = lossMsg.."(including the "
								
								if cCount > 1 then
									gainMsg = gainMsg.."cities of "
									lossMsg = lossMsg.."cities of "
									for c=1,#rn.cities-1 do
										gainMsg = gainMsg..rn.cities[c].name..", "
										lossMsg = lossMsg..rn.cities[c].name..", "
									end
									gainMsg = gainMsg.."and "..rn.cities[#rn.cities].name
									lossMsg = lossMsg.."and "..rn.cities[#rn.cities].name
								else
									gainMsg = gainMsg.."city of "..rn.cities[#rn.cities].name
									lossMsg = lossMsg.."city of "..rn.cities[#rn.cities].name
								end
								
								gainMsg = gainMsg..") "
								lossMsg = lossMsg..") "
							end
							
							gainMsg = gainMsg.."from "..self.thisWorld.countries[c2].name
							lossMsg = lossMsg.."to "..self.thisWorld.countries[c1].name

							self.thisWorld.countries[c1]:event(self, gainMsg)
							self.thisWorld.countries[c2]:event(self, lossMsg)
							
							self:deepnil(self.thisWorld.countries[c2].regions[rn.name])
							self.thisWorld.countries[c2].regions[rn.name] = nil
						end
					end
				end
			end,

			removeAllyOngoing = function(self, country, target, event)
				local ac = #self.thisWorld.countries[country].alliances
				for i=1,ac do
					local c3 = nil
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
				self:sleep(0.001)
				tc = socket.gettime()
				n = tonumber(tostring(tc):reverse())
				while n < 1000000 do n = n * 10 end
				while n > 100000000 do n = n / 10 end
				n = math.ceil(n)
				math.randomseed(n)
				math.random(1, 100)
				x = math.random(4, 6)
				for i=3,x do
					math.randomseed(math.random(n, i*n))
					math.random(1, 100)
				end
				math.random(1, 100)
			end,

			sleep = function(self, t)
				n = socket.gettime()
				while socket.gettime() < n + t do end
			end
		}

		return CCSCommon
	end
