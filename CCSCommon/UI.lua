return
	function()
		local UI = {
			new = function(self)
				local o = {}

				o.clrcmd = nil
				o.ready = false
				o.stdscr = nil
				o.x = -1
				o.y = -1

				return o
			end,

			clear = function(self, holdRef)
				if not self.ready then self:init() end
				if cursesstatus then
					self.stdscr:clear()
					self.stdscr:move(0, 0)
					if not holdRef then self:refresh() end
				else for i=1,3 do os.execute(self.clrcmd) end end
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
				self:write(str)
			end,

			printf = function(self, fmt)
				if not self.ready then self:init() end
				if self.stdscr then
					local y, x = self.stdscr:getyx()
					self.stdscr:move(y, 0)
					self.stdscr:clrtoeol()
				else io.write("\r") end
				self:write(str)
				if self.stdscr then
					self.stdscr:addstr("\n")
					local y, x = self.stdscr:getyx()
					self.stdscr:move(y, 0)
					self.stdscr:clrtoeol()
				else io.write("\r\n") end
			end,

			printl = function(self, fmt)
				if not self.ready then self:init() end
				if self.stdscr then
					local y, x = self.stdscr:getyx()
					self.stdscr:move(y, 0)
					self.stdscr:clrtoeol()
				else io.write("\r") end
				self:write(str)
				if self.stdscr then
					local y, x = self.stdscr:getyx()
					self.stdscr:move(y, 0)
					self.stdscr:clrtoeol()
				else io.write("\r") end
			end,

			printp = function(self, fmt)
				if not self.ready then self:init() end
				if self.stdscr then
					local y, x = self.stdscr:getyx()
					self.stdscr:move(y, 0)
					self.stdscr:clrtoeol()
				else io.write("\r") end
				self:write(str)
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
				if cursesstatus then
					self.stdscr:refresh()
					self.x = curses:cols()
					self.y = curses:lines()
				end
			end,
			
			write = function(self, fmt)
				if self.stdscr then
					self.stdscr:addstr(fmt)
					UI:refresh()
				else io.write(fmt) end
			end
		}

		UI.__index = UI
		UI.__call = function() return UI:new() end

		return UI
	end