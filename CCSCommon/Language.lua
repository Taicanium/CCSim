return
	function()
		require("CCSCommon.English")

		local Language = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.descentTree = {}
				o.eml = 1
				o.letterCount = 0
				o.name = tostring(math.random(0, math.pow(2, 24)-1))
				o.period = 1
				o.testString = ""
				o.wordTable = {}

				return o
			end,

			define = function(self, parent)
				for i=1,#ENGLISH do if not self.wordTable[ENGLISH[i]] then
					local ln = math.ceil(ENGLISH[i]:len()/3)
					local word = parent:name(true, ln, ln)
					self.wordTable[ENGLISH[i]] = word:lower()
					self.letterCount = self.letterCount+word:len()
				end end
				for x in parent.langTestString:gmatch("%S+") do self.testString = self.testString..self.wordTable[x:lower()]:gsub(" ", "").." " end
				self.testString = self.testString:sub(1, self.testString:len()-1)
				self.testString = self.testString:gsub("^%w", string.upper)
				self.period = parent.langPeriod
				self.eml = parent.langEML
			end,

			deviate = function(self, parent)
				local newList = Language:new()
				for i=1,#self.descentTree do table.insert(newList.descentTree, self.descentTree[i]) end
				local periodString = " ("..(self.eml == 1 and "Early" or (self.eml == 2 and "Middle" or "Late")).." period "..tostring(self.period)..")"
				table.insert(newList.descentTree, {self.name..periodString, self.testString})
				local ops = {"OMIT", "REPLACE", "REPLACE", "INSERT"} -- Replacement is intentionally twice as likely as either omission or insertion.

				local fct = 0
				local totalFct = math.random(parent.langDriftConstant*0.8, parent.langDriftConstant*1.2)*self.letterCount
				local doOp = {}
				local op = parent:randomChoice(ops)
				local mod = nil
				if op == "OMIT" then mod = {tostring(math.random(0, 6)), "7"}
				elseif op == "REPLACE" then mod = tostring(math.random(0, 6)) mod = {mod, mod}
				elseif op == "INSERT" then mod = {"7", tostring(math.random(0, 6))} end
				local repCount = 0
				while fct < totalFct do
					local eng = ENGLISH[math.random(1, #ENGLISH)]
					local thisWord = newList.wordTable[eng] or self.wordTable[eng]
					local newWord = thisWord
					local fin = false
					for q=1,thisWord:len() do if not fin and self.sTab[thisWord:sub(q, q):lower()] == mod[1] and ((mod[1] ~= "0" or mod[2] == "0") or ((q > 1 and self.sTab[thisWord:sub(q-1, q-1):lower()] == "0") or (q < thisWord:len() and self.sTab[thisWord:sub(q+1, q+1):lower()] == "0"))) then
						newWord = thisWord:sub(1, q-1)..parent:randomChoice(self.sTab[mod[2]])
						if q < thisWord:len() then newWord = newWord..thisWord:sub(q+1, thisWord:len()) end
						for z=1,#self.sTab["0"] do newWord = newWord:gsub(self.sTab["0"][z]..self.sTab["0"][z], self.sTab["0"][z].." ") end
						fin = true
					end end
					newList.wordTable[eng] = newWord
					repCount = repCount+1
					if repCount >= #ENGLISH*0.15 then
						op = parent:randomChoice(ops)
						if op == "OMIT" then mod = {tostring(math.random(0, 6)), "7"}
						elseif op == "REPLACE" then mod = tostring(math.random(0, 6)) mod = {mod, mod}
						elseif op == "INSERT" then mod = {"7", tostring(math.random(0, 6))} end
						repCount = 0
					end
					fct = fct+1
				end

				newList.period = parent.langPeriod
				newList.eml = parent.langEML
				newList.letterCount = 0
				for i=1,#ENGLISH do
					if not newList.wordTable[ENGLISH[i]] then newList.wordTable[ENGLISH[i]] = self.wordTable[ENGLISH[i]] or parent:name(true, math.ceil(ENGLISH[i]:len()/3), math.ceil(ENGLISH[i]:len()/3)) end
					newList.letterCount = newList.letterCount+newList.wordTable[ENGLISH[i]]:len()
				end
				for x in parent.langTestString:gmatch("%S+") do newList.testString = newList.testString..newList.wordTable[x:lower()]:gsub(" ", "").." " end
				newList.testString = newList.testString:sub(1, newList.testString:len()-1)
				newList.testString = newList.testString:gsub("^%w", string.upper)

				return newList
			end,

			diff = function(self, other)
				local factor = 0
				for i=1,#ENGLISH do
					local wrd1 = self.wordTable[ENGLISH[i]]
					local wrd2 = other.wordTable[ENGLISH[i]]
					for j=wrd1:len()+1,wrd2:len() do wrd1 = wrd1.." " end

					local div = 1/wrd1:len()
					for j=1,wrd1:len() do if wrd2:len() < j or wrd1:sub(j, j) ~= wrd2:sub(j, j) then factor = factor+div end end
				end
				factor = factor/#ENGLISH
				return factor
			end,

			soundex = function(self, n, s)
				local nOut = (s and self.sTab[(n:sub(1, 1)):lower()] or (n:sub(1, 1)):upper())
				for x=2,n:len() do nOut = nOut..(self.sTab[(n:sub(x, x)):lower()] or "0") end
				if not s then nOut = nOut:gsub("0", "") end
				local oln = 0
				while oln ~= nOut:len() do
					oln = nOut:len()
					if nOut:len() > 1 then for x=nOut:len()-1,1,-1 do if nOut:sub(x, x) == nOut:sub(x+1, x+1) then nOut = nOut:sub(1, x)..(x < nOut:len()-1 and nOut:sub(x+2, nOut:len()) or "") end end end
				end
				if nOut:len() < 4 then nOut = (s and nOut.."777" or nOut.."000") end

				return s and nOut or nOut:sub(1, 4)
			end,

			sTab = {["0"]={"a", "e", "i", "o", "u", "y", "w", "h"}, ["1"]={"b", "f", "p", "v"}, ["2"]={"c", "g", "j", "k", "q", "s", "x", "z"}, ["3"]={"d", "t"}, ["4"]={"l"}, ["5"]={"m", "n"}, ["6"]={"r"}, ["7"]={" "}, a="0", e="0", i="0", o="0", u="0", y="0", w="0", h="0", b="1", f="1", p="1", v="1", c="2", g="2", j="2", k="2", q="2", s="2", x="2", z="2", d="3", t="3", l="4", m="5", n="5", r="6", [" "]="7"},
		}

		Language.__index = Language
		Language.__call = function() return Language:new() end

		return Language
	end