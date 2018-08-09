return
	function()
		Party = {
			new = function(self)
				p = {}
				setmetatable(p, self)
				
				p.name = ""
				p.efreedom = 0
				p.pfreedom = 0
				p.cfreedom = 0
				p.radical = false
				p.leading = false
				p.popularity = 50
				p.membership = 0
				p.revolted = false
				
				return p
			end,
			
			makename = function(self, parent, n)
				parent:rseed()
				
				n1 = math.random(1, 4)
				n2 = math.random(1, 4)
				n3 = math.random(1, 4)
				n4 = math.random(1, 4)
				
				v1 = -1
				v2 = -1
				v3 = -1
				v4 = -1
				
				if n1 == 1 then
					v = math.random(1, #parent.partynames[1])
					v1 = v
					self.name = self.name..parent.partynames[1][v].." "
				end
				
				if n2 == 2 then
					v = math.random(1, #parent.partynames[2])
					while v == v1 do v = math.random(1, #parent.partynames[2]) end
					v2 = v
					self.name = self.name..parent.partynames[2][v].." "
				end
				
				if n3 == 3 then
					v = math.random(1, #parent.partynames[3])
					v3 = v
					self.name = self.name..parent.partynames[3][v].." "
				end
				
				if n4 == 4 then
					v = math.random(1, #parent.partynames[4])
					while v == v3 do v = math.random(1, #parent.partynames[4]) end
					v4 = v
					self.name = self.name..parent.partynames[4][v].." "
				end
				
				if self.name == "" then
					nf = math.random(1, 3)
					v = math.random(1, #parent.partynames[nf])
					self.name = self.name..parent.partynames[nf][v].." "
				end
				
				v = math.random(1, #parent.partynames[5])
				self.name = self.name..parent.partynames[5][v]

				for i=1,#parent.thisWorld.countries[n].parties do
					if self.name == parent.thisWorld.countries[n].parties[i].name then
						self.name = ""
						self:makename(parent, n)
					end
				end
				
			end
		}
		
		Party.__index = Party
		Party.__call = function() return Party:new() end
		
		return Party
	end