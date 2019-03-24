return
	function()
		local Party = {
			new = function(self)
				local p = {}
				setmetatable(p, self)

				p.cfreedom = 0
				p.efreedom = 0
				p.leading = false
				p.membership = 0
				p.mtname = "Party"
				p.name = ""
				p.pfreedom = 0
				p.popularity = 50
				p.radical = false

				return p
			end,

			makename = function(self, parent, n)
				parent:rseed()

				local n1 = math.random(1, 4)
				local n2 = math.random(1, 4)
				local n3 = math.random(1, 4)
				local n4 = math.random(1, 4)

				if n1 == 1 then
					local v = parent:randomChoice(parent.partynames[1])
					self.name = self.name..v.." "
				end

				if n2 == 2 then
					local v = parent:randomChoice(parent.partynames[2])
					while self.name:match(v) do v = parent:randomChoice(parent.partynames[2]) end
					self.name = self.name..v.." "
				end

				if n3 == 3 then
					local v = parent:randomChoice(parent.partynames[3])
					while self.name:match(v) do v = parent:randomChoice(parent.partynames[3]) end
					self.name = self.name..v.." "
				end

				if n4 == 4 then
					local v = parent:randomChoice(parent.partynames[4])
					while self.name:match(v) do v = parent:randomChoice(parent.partynames[4]) end
					self.name = self.name..v.." "
				end

				if self.name == "" then
					local nf = math.random(1, 4)
					local v = parent:randomChoice(parent.partynames[nf])
					self.name = self.name..v.." "
				end

				local v = parent:randomChoice(parent.partynames[5])
				self.name = self.name..v

				for i, p in pairs(n.parties) do
					if self.name == p.name then
						self.name = ""
						self:makename(parent, n)
					end
				end
			end
		}

		Party.__call = function() return Party:new() end
		Party.__index = Party

		return Party
	end