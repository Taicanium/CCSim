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
				p.index = 1
				
				return p
			end,
			
			makename = function(self, parent, n)
				parent.rseed()
				
				self.index = #parent.countries[n].parties + 1
				
				local n1 = math.random(1, 5)
				local n2 = math.random(1, 5)
				local n3 = math.random(1, 5)
				
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
				
				if self.name == "" then
					local nf = math.random(1, 3)
					local v = math.random(1, #parent.partynames[nf])
					self.name = self.name..parent.partynames[nf][v].." "
				end
				
				local v = math.random(1, #parent.partynames[4])
				self.name = self.name..parent.partynames[4][v]

				for i=1,#parent.countries[n].parties do
					if self.name == parent.countries[n].parties[i].name then
						if self.index ~= parent.countries[n].parties[i].index then
							self:makename(parent, n)
						end
					end
				end
			end,
			
			evaluate = function(self, parent, n)
				local totalvalue = 0
				
				
			end
		}
		
		return Party
	end