return
	function()
		local World = {
			new = function(self)
				local nm = {}
				setmetatable(nm, {__index=self, __call=function() return World:new() end})
				
				nm.countries = {}
				nm.cmarked = {}

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
							for i=1,#self.countries do
								if self.countries[i] ~= nil then
									local emarked = {}
									for j=1,#self.countries[i].ongoing do
										if self.countries[i].ongoing[j] ~= nil then
											if self.countries[i].ongoing[j].Target ~= nil then
												if self.countries[i].ongoing[j].Target == nz then
													table.insert(emarked, j)
												end
												
												if self.countries[i].ongoing[j].Target > nz then
													self.countries[i].ongoing[j].Target = self.countries[i].ongoing[j].Target - 1
												end
											end
										end
									end
									for j=1,#emarked do
										table.remove(self.countries[i].ongoing, emarked[j])
										for k=j,#emarked do
											emarked[k] = emarked[k] - 1
										end
									end
									emarked = {}
									for j=1,#self.countries[i].allyOngoing do
										if self.countries[i].allyOngoing[j] ~= nil then
											if self.countries[i].allyOngoing[j]:find(p.name) then
												table.insert(emarked, j)
											end
										end
									end
									for j=1,#emarked do
										table.remove(self.countries[i].allyOngoing, emarked[j])
										for k=j,#emarked do
											emarked[k] = emarked[k] - 1
										end
									end
									emarked = {}
									for j=1,#self.countries[i].alliances do
										if self.countries[i].alliances[j] ~= nil then
											if self.countries[i].alliances[j] == p.name then
												table.insert(emarked, j)
											end
										end
									end
									for j=1,#emarked do
										table.remove(self.countries[i].alliances, emarked[j])
										for k=j,#emarked do
											emarked[k] = emarked[k] - 1
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
				
				self.cmarked = {}
				
				for i=1,#self.countries do
					if self.countries[i] ~= nil then
						self.countries[i]:update(parent, i)
						
						if self.countries[i] ~= nil then
							if self.countries[i].population < 10 then
								self.countries[i].rulers[#self.countries[i].rulers].To = parent.years
								self.countries[i]:event(parent, "Disappeared")
								local found = false
								for j=1,#self.cmarked do
									if self.cmarked[j] == i then found = true end
								end
								if found == false then table.insert(self.cmarked, i) end
							end
						end
					end
				end
				
				for i=1,#self.cmarked do
					self:delete(self.cmarked[i])
					for j=i,#self.cmarked do
						self.cmarked[i] = self.cmarked[i] - 1
					end
				end
			end
		}
		
		return World
	end