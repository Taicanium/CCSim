return
	function()
		local UI = {
			clrcmd = nil,
			ready = false,
			stdscr = nil,
			x = 80,
			y = 25,

			clear = function(self, holdRef)
				if not self.ready then self:init() end
				if self.stdscr then
					self.stdscr:clear()
					self.stdscr:move(0, 0)
					if not holdRef then self:refresh() end
				else for i=1,2 do os.execute(self.clrcmd) end end
			end,

			init = function(self)
				if cursesstatus and not self.stdscr then
					curses.cbreak(true)
					curses.echo(true)
					curses.nl(true)
					self.stdscr = curses.initscr()
					self:refresh()
				end

				if not self.clrcmd or self.clrcmd == "" then
					self.clrcmd = "clear"
					local clrarr = os.execute("clear")

					if not clrarr then self.clrcmd = "cls"
					elseif type(clrarr) == "number" and clrarr ~= 0 then self.clrcmd = "cls"
					elseif type(clrarr) == "table" then for i, j in pairs(clrarr) do if not i or not j then self.clrcmd = "cls" end end end
				end

				self.ready = true
			end,

			printc = function(self, fmt)
				if not self.ready then self:init() end
				if self.stdscr then self.stdscr:clrtoeol() end
				self:write(fmt)
			end,

			printf = function(self, fmt)
				if not self.ready then self:init() end
				if self.stdscr then
					local y, x = self.stdscr:getyx()
					self.stdscr:move(y, 0)
					self.stdscr:clrtoeol()
				else self:write("\r") end
				self:write(fmt)
				if self.stdscr then
					self.stdscr:addstr("\n")
					local y, x = self.stdscr:getyx()
					self.stdscr:move(y, 0)
					self.stdscr:clrtoeol()
				else self:write("\r\n") end
			end,

			printl = function(self, fmt)
				if not self.ready then self:init() end
				if self.stdscr then
					local y, x = self.stdscr:getyx()
					self.stdscr:move(y, 0)
					self.stdscr:clrtoeol()
				else self:write("\r") end
				self:write(fmt)
				if self.stdscr then
					local y, x = self.stdscr:getyx()
					self.stdscr:move(y, 0)
					self.stdscr:clrtoeol()
				else self:write("\r") end
			end,

			printp = function(self, fmt)
				if not self.ready then self:init() end
				if self.stdscr then
					local y, x = self.stdscr:getyx()
					self.stdscr:move(y, 0)
					self.stdscr:clrtoeol()
				else self:write("\r") end
				self:write(fmt)
			end,

			readl = function(self)
				if not self.ready then self:init() end
				if self.stdscr then return self.stdscr:getstr() end
				return io.read()
			end,

			readn = function(self)
				if not self.ready then self:init() end
				local x = ""
				if self.stdscr then x = self.stdscr:getstr() else x = io.read() end
				return tonumber(x)
			end,

			refresh = function(self)
				if not self.ready then self:init() end
				if self.stdscr then
					self.stdscr:refresh()
					self.x = curses:cols()
					self.y = curses:lines()
				end
			end,

			write = function(self, fmt)
				if not self.ready then self:init() end
				if self.stdscr then
					if type(fmt) == "string" then self.stdscr:addstr(fmt)
					elseif type(fmt) == "table" then for i, j in pairs(fmt) do self:write(j) end
					else self.stdscr:addstr(tostring(fmt)) end
					self:refresh()
				else
					if type(fmt) == "string" then io.write(fmt)
					elseif type(fmt) == "table" then for i, j in pairs(fmt) do self:write(j) end
					else io.write(tostring(fmt)) end
				end
			end
		}

		UI.__index = UI
		UI.__call = function() return UI:new() end

		return UI
	end
