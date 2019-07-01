return
	function()
		local UI = {
			new = function(self)
				local o = {}
				
				o.clrcmd = nil
				o.stdscr = nil
				o.x = -1
				o.y = -1
				
				return o
			end,
			
			clear = function(self, holdRef)
				if cursesstatus then
					if not self.stdscr then self:init() end
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
			end,

			printc = function(self, fmt, ...)
				if self.stdscr then
					self.stdscr:clrtoeol()
					self.stdscr:addstr(string.format(fmt, ...))
				else io.write(string.format(fmt, ...)) end
			end,
			
			printf = function(self, fmt, ...)
				if self.stdscr then
					local y, x = self.stdscr:getyx()
					self.stdscr:move(y, 0)
					self.stdscr:clrtoeol()
					self.stdscr:addstr(string.format(fmt, ...))
					self.stdscr:addstr("\n")
					local y2, x2 = self.stdscr:getyx()
					self.stdscr:move(y2, 0)
					UI:refresh()
				else
					io.write("\r")
					io.write(string.format(fmt, ...))
					io.write("\n")
				end
			end,

			printl = function(self, fmt, ...)
				if self.stdscr then
					local y, x = self.stdscr:getyx()
					self.stdscr:move(y, 0)
					self.stdscr:clrtoeol()
					self.stdscr:addstr(string.format(fmt, ...))
					self.stdscr:move(y, 0)
					UI:refresh()
				else
					io.write("\r")
					io.write(string.format(fmt, ...))
					io.write("\r")
				end
			end,

			printp = function(self, fmt, ...)
				if self.stdscr then
					local y, x = self.stdscr:getyx()
					self.stdscr:move(y, 0)
					self.stdscr:clrtoeol()
					self.stdscr:addstr(string.format(fmt, ...))
					UI:refresh()
				else
					io.write("\r")
					io.write(string.format(fmt, ...))
				end
			end,

			readl = function(self)
				if self.stdscr then return self.stdscr:getstr() end
				return io.read()
			end,

			readn = function(self)
				local x = ""
				if self.stdscr then x = self.stdscr:getstr() else x = io.read() end
				return tonumber(x)
			end,
			
			refresh = function(self)
				if cursesstatus then self.stdscr:refresh() end
				self.x = curses:cols()
				self.y = curses:lines()
			end
		}
		
		UI.__index = UI
		UI.__call = function() return UI:new() end
		
		return UI
	end