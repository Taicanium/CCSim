return
	function()
		local Party = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.cfreedom = 0
				o.efreedom = 0
				o.name = ""
				o.pfreedom = 0
				o.radical = false

				return o
			end,

			makename = function(self, parent, n)
				parent:rseed()
				local fin = false
				while not fin do
					if math.random(1, 4) == 1 then
						local v = parent:randomChoice(parent.partynames[1])
						self.name = self.name..v.." "
					end

					if math.random(1, 4) == 2 then
						local v = parent:randomChoice(parent.partynames[2])
						while self.name:match(v) do v = parent:randomChoice(parent.partynames[2]) end
						self.name = self.name..v.." "
					end

					if math.random(1, 4) == 3 then
						local v = parent:randomChoice(parent.partynames[3])
						while self.name:match(v) do v = parent:randomChoice(parent.partynames[3]) end
						self.name = self.name..v.." "
					end

					if math.random(1, 4) == 4 then
						local v = parent:randomChoice(parent.partynames[4])
						while self.name:match(v) do v = parent:randomChoice(parent.partynames[4]) end
						self.name = self.name..v.." "
					end

					if self.name == "" then
						local v = parent:randomChoice(parent.partynames[math.random(1, 4)])
						self.name = self.name..v.." "
					end

					local v = parent:randomChoice(parent.partynames[5])
					self.name = self.name..v

					fin = true
					for i, p in pairs(n.parties) do if self.name == p.name then
						self.name = ""
						fin = false
					end end
				end
			end
		}

		Party.__index = Party
		Party.__call = function() return Party:new() end
		Party.__tostring = function(self)
			local sOut, brk = "<Party", 0
			for i, j in pairs(self) do brk = brk+1 if brk < 4 then sOut = sOut.."\n\t"..tostring(i)..": "..tostring(j) elseif brk == 4 then sOut = sOut.."\n\t..." end end
			sOut = sOut..(brk > 0 and "\n" or "")..">"
			return sOut
		end

		return Party
	end
