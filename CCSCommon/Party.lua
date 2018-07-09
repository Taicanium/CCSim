return
	function()
		local Party = {
			new = function(self)
				local p = {}
				setmetatable(p, {__index=self, __call=function() return Party:new() end})
				
				p.name = ""
				p.efreedom = 0
				p.pfreedom = 0
				p.cfreedom = 0
				p.radical = false
				p.leading = false
				p.popularity = 1
				p.membership = 0
				p.index = 1
				
				return p
			end,
			
			makename = function(self, parent, n)
				parent:rseed()
				
				self.index = #parent.thisWorld.countries[n].parties + 1
				
				local n1 = math.random(1, 4)
				local n2 = math.random(1, 4)
				local n3 = math.random(1, 4)
				local n4 = math.random(1, 4)
				
				if n1 == 1 then
					local v = math.random(1, #parent.partynames[1])
					self.name = self.name..parent.partynames[1][v].." "
				end
				
				if n2 == 2 then
					local v = math.random(1, #parent.partynames[2])
					self.name = self.name..parent.partynames[2][v].." "
				end
				
				if n3 == 3 then
					local v = math.random(1, #parent.partynames[3])
					self.name = self.name..parent.partynames[3][v].." "
				end
				
				if n4 == 4 then
					local v = math.random(1, #parent.partynames[4])
					self.name = self.name..parent.partynames[4][v].." "
				end
				
				if self.name == "" then
					local nf = math.random(1, 3)
					local v = math.random(1, #parent.partynames[nf])
					self.name = self.name..parent.partynames[nf][v].." "
				end
				
				local v = math.random(1, #parent.partynames[5])
				self.name = self.name..parent.partynames[5][v]

				for i=1,#parent.thisWorld.countries[n].parties do
					if self.name == parent.thisWorld.countries[n].parties[i].name then
						if self.index ~= parent.thisWorld.countries[n].parties[i].index then
							self.name = ""
							self:makename(parent, n)
						end
					end
				end
			end,
			
			define = function(self, parent, n)
				self:makename(parent, n)
				
				self.efreedom = math.random(-100, 100)
				self.pfreedom = math.random(-100, 100)
				self.cfreedom = math.random(-100, 100)
				
				local totalfreedom = self.efreedom + self.pfreedom + self.cfreedom
				if totalfreedom < -250 or totalfreedom > 250 then radical = true end
			end,
			
			evaluate = function(self, nl, parent, n)
				local totalvalue = 1
				local totalfactors = 2
				
				totalvalue = totalvalue + nl.stability
				totalvalue = totalvalue + nl.strength
				
				for i, l in pairs(nl.relations) do
					for j, k in pairs(parent.thisWorld.countries) do
						if i.name == k.name then
							totalvalue = totalvalue + nl.relations[i.name]
							totalfactors = totalfactors + 1
						end
					end
				end
				
				if self.leading == false then
					totalvalue = (100*totalfactors)-totalvalue
				end
				
				self.popularity = tonumber(math.floor(totalvalue/totalfactors))
				
				if nl.rulers[#nl.rulers].Party == self.name then
					if self.popularity < 20 then
						for i=1,#parent.c_events do
							if parent.c_events[i].Name == "Revolution" then
								parent.c_events[i]:Perform(parent, n)
								return -1
							end
						end
					end
				end
				
				return 0
			end
		}
		
		return Party
	end