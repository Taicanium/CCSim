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
					if not holdRef then self:refresh() end
					self.stdscr:clear()
					self.stdscr:move(0, 0)
				else for i=1,3 do os.execute(self.clrcmd) end end
			end,
			
			init = function(self)
				if cursesstatus and not self.stdscr then
					curses.cbreak(true)
					curses.echo(true)
					curses.nl(true)
					self.stdscr = curses.initscr()
					self.x = curses:cols()
					self.y = curses:lines()
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