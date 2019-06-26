cursesstatus, curses = pcall(require, "curses")

printf = function(stdscr, fmt, ...)
	if stdscr then
		local y, x = stdscr:getyx()
		stdscr:move(y, 0)
		stdscr:clrtoeol()
		stdscr:addstr(fmt:format(...))
		stdscr:addstr("\n")
		stdscr:refresh()
	else
		io.write("\r")
		io.write(fmt:format(...))
		io.write("\n")
	end
end

printl = function(stdscr, fmt, ...)
	if stdscr then
		local y, x = stdscr:getyx()
		stdscr:move(y, 0)
		stdscr:clrtoeol()
		stdscr:addstr(fmt:format(...))
		stdscr:move(y, 0)
		stdscr:refresh()
	else
		io.write("\r")
		io.write(fmt:format(...))
		io.write("\r")
	end
end

printp = function(stdscr, fmt, ...)
	if stdscr then
		local y, x = stdscr:getyx()
		stdscr:move(y, 0)
		stdscr:clrtoeol()
		stdscr:addstr(fmt:format(...))
		stdscr:refresh()
	else
		io.write("\r")
		io.write(fmt:format(...))
	end
end

printc = function(stdscr, fmt, ...)
	if stdscr then
		stdscr:clrtoeol()
		stdscr:addstr(fmt:format(...))
		stdscr:refresh()
	else io.write(fmt:format(...)) end
end

readl = function(stdscr)
	if stdscr then return stdscr:getstr()
	return io.read()
end

readn = function(stdscr)
	if stdscr then return tonumber(stdscr:getstr())
	return tonumber(io.read())
end

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
				end
				
				if not self.clrcmd or self.clrcmd == "" then
					self.clrcmd = "clear"
					local clrarr = os.execute("clear")

					if not clrarr then self.clrcmd = "cls"
					elseif type(clrarr) == "number" and clrarr ~= 0 then self.clrcmd = "cls"
					elseif type(clrarr) == "table" then for i, j in pairs(clrarr) do if not i or not j then self.clrcmd = "cls" end end end
				end
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