return
	function()
		local World = {
			new = function(self)
				local nm = {}
				setmetatable(nm, {__index=self, __call=function() return World:new() end})
				
				nm.countries = {}

				return nm
			end,

			destroy = function(self)
				for i=1,#self.countries do
					self.countries[i]:destroy()
					self.countries[i] = nil
				end
			end,

			add = function(self, nd)
				table.insert(self.countries, nd)
			end,

			delete = function(self, nz)
				if nz > 0 and nz <= #self.countries then
					if self.countries[nz] ~= nil then
						local p = table.remove(self.countries, nz)
						if p ~= nil then
							for i=#self.countries,1,-1 do
								if self.countries[i] ~= nil then
									for j=#self.countries[i].ongoing,1,-1 do
										if self.countries[i].ongoing[j] ~= nil then
											if self.countries[i].ongoing[j].Target ~= nil then
												if self.countries[i].ongoing[j].Target == nz then
													table.remove(self.countries[i].ongoing, j)
												end
												
												if self.countries[i].ongoing[j].Target > nz then
													self.countries[i].ongoing[j].Target = self.countries[i].ongoing[j].Target - 1
												end
											end
										end
									end
									for j=#self.countries[i].allyOngoing,1,-1 do
										if self.countries[i].allyOngoing[j] ~= nil then
											if self.countries[i].allyOngoing[j]:find(p.name) then
												table.remove(#self.countries[i].allyOngoing, j)
											end
										end
									end
									for j=#self.countries[i].alliances,1,-1 do
										if self.countries[i].alliances[j] ~= nil then
											if self.countries[i].alliances[j] == p.name then
												table.remove(#self.countries[i].alliances, j)
											end
										end
									end
								end
							end
							
							p:destroy()
							p = nil
						end
					end
				end
			end,

			update = function(self, parent)
				parent.numCountries = #self.countries
				
				for i=1,#self.countries do
					if self.countries[i] ~= nil then
						self.countries[i]:update(parent, i)
						
						if self.countries[i] ~= nil then
							if self.countries[i].population < 10 then
								if self.countries[i].rulers[#self.countries[i].rulers].To == "Current" then self.countries[i].rulers[#self.countries[i].rulers].To = parent.years end
								self.countries[i]:event(parent, "Disappeared")
								self:delete(i)
							end
						end
					end
				end
			end
		}
		
		return World
	end