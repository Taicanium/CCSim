return
	function()
		local Party = {
			new = function(self)
				local p = {}
				setmetatable(p, self)

				p.name = ""
				p.efreedom = 0
				p.pfreedom = 0
				p.cfreedom = 0
				p.radical = false
				p.leading = false
				p.popularity = 50
				p.membership = 0
				p.mtname = "Party"

				return p
			end,

			makename = function(self, parent, n)
				parent:rseed()

				local n1 = math.random(1, 4)
				local n2 = math.random(1, 4)
				local n3 = math.random(1, 4)
				local n4 = math.random(1, 4)

				local v1 = -1
				local v2 = -1
				local v3 = -1
				local v4 = -1

				if n1 == 1 then
					local v = math.random(1, #parent.partynames[1])
					v1 = v
					self.name = self.name..parent.partynames[1][v].." "
				end

				if n2 == 2 then
					local v = math.random(1, #parent.partynames[2])
					while v == v1 do v = math.random(1, #parent.partynames[2]) end
					v2 = v
					self.name = self.name..parent.partynames[2][v].." "
				end

				if n3 == 3 then
					local v = math.random(1, #parent.partynames[3])
					v3 = v
					self.name = self.name..parent.partynames[3][v].." "
				end

				if n4 == 4 then
					local v = math.random(1, #parent.partynames[4])
					while v == v3 do v = math.random(1, #parent.partynames[4]) end
					v4 = v
					self.name = self.name..parent.partynames[4][v].." "
				end

				if self.name == "" then
					local nf = math.random(1, 3)
					local v = math.random(1, #parent.partynames[nf])
					self.name = self.name..parent.partynames[nf][v].." "
				end

				local v = math.random(1, #parent.partynames[5])
				self.name = self.name..parent.partynames[5][v]

				for i, p in pairs(n.parties) do
					if self.name == p.name then
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