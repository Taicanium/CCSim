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
				o.l1Speakers = 0
				o.l2Speakers = 0
				o.specials = {}
				o.wordTable = {}

				return o
			end,

			define = function(self, parent)
				for i=1,#ENGLISH do if not self.wordTable[ENGLISH[i]] then
					local ln = math.ceil(ENGLISH[i]:len()/3)
					local word = parent:name(true, ln, ln, true)
					self.wordTable[ENGLISH[i]] = word:lower()
					self.letterCount = self.letterCount+word:len()
				end end
				self:defineSpecials(parent)
				self.period = parent.langPeriod
				self.eml = parent.langEML
			end,

			defineSpecials = function(self, parent)
				-- This is *remarkably* unintuitive... even as far as other sections of this program go.
				-- Essentially, the vast majority of natural languages don't have 405 unique pronouns -- and, yes, I counted -- so, work here to combine a few.
				-- Somehow. Through some process.
				for i=1,#parent.pronouns do self.specials[parent.pronouns[i]] = string.lower(parent:name(true, 1, 1)) end
				local i1 = math.random(1, 5)
				local i2 = math.random(1, 5) while i2 == i1 do i2 = math.random(1, 5) end
				local i3 = math.random(1, 5) while i3 == i2 or i3 == i1 do i3 = math.random(1, 5) end
				for i, j in pairs(self.specials) do for k, l in pairs(self.specials) do if i:sub(i1, i1) == k:sub(i1, i1) and i:sub(i2, i2) == k:sub(i2, i2) and i:sub(i3, i3) == k:sub(i3, i3) then self.specials[k] = self.specials[i] end end end
				self.specials["$rss"] = string.lower(parent:name(true, 2, 1)) -- Reflexive singular suffix. (Eng: 'self')
				self.specials["$rsp"] = string.lower(parent:name(true, 2, 1)) -- Reflexive plural suffix. (Eng: 'selves')
				self.specials["$es"] = string.lower(parent:name(true, 1, 1)) -- Determinant suffix. (Eng: 's', as in 'theirs' or 'hers')
				self.specials["$da"] = string.lower(parent:name(true, 1, 1)) -- Definite article. (Eng: 'the')
				for i, j in pairs(self.specials) do self.wordTable[i] = self.wordTable[i] or j self.specials[i] = nil end
				self.specials = nil
			end,

			deviate = function(self, parent)
				local newList = Language:new()
				for i=1,#self.descentTree do table.insert(newList.descentTree, self.descentTree[i]) end
				local periodString = " ("..(self.eml == 1 and "Early" or (self.eml == 2 and "Middle" or "Late")).." period "..tostring(self.period)..")"
				table.insert(newList.descentTree, {self.name..periodString, self:translate(parent, parent.langTestString)})
				local ops = {"OMIT", "REPLACE", "REPLACE", "INSERT"} -- Replacement is intentionally twice as likely as either omission or insertion.

				local fct, doOp, repCount, mod = 0, {}, 0
				local totalFct = math.random(parent.langDriftConstant*0.85, parent.langDriftConstant*1.15)*self.letterCount
				local op = parent:randomChoice(ops)
				if op == "OMIT" then mod = {tostring(math.random(0, 6)), "7"}
				elseif op == "REPLACE" then mod = tostring(math.random(0, 6)) mod = {mod, mod}
				elseif op == "INSERT" then mod = {"7", tostring(math.random(0, 6))} end
				for i=1,#parent.pronouns do newList.wordTable[parent.pronouns[i]] = self.wordTable[parent.pronouns[i]] or string.lower(parent:name(true, 1, 1)) end
				newList.wordTable["$rss"] = self.wordTable["$rss"] or string.lower(parent:name(true, 2, 1))
				newList.wordTable["$rsp"] = self.wordTable["$rsp"] or string.lower(parent:name(true, 2, 1))
				newList.wordTable["$es"] = self.wordTable["$es"] or string.lower(parent:name(true, 1, 1))
				newList.wordTable["$da"] = self.wordTable["$da"] or string.lower(parent:name(true, 1, 1))
				while fct < totalFct do
					local eng = ENGLISH[math.random(1, #ENGLISH)]
					local thisWord = newList.wordTable[eng] or self.wordTable[eng]
					local newWord, fin = thisWord
					for q=1,thisWord:len() do if not fin and self.sTab[thisWord:sub(q, q):lower()] == mod[1] and ((mod[1] ~= "0" or mod[2] == "0") or ((q > 1 and self.sTab[thisWord:sub(q-1, q-1):lower()] == "0") or (q < thisWord:len() and self.sTab[thisWord:sub(q+1, q+1):lower()] == "0"))) then
						newWord = thisWord:sub(1, q-1)..parent:randomChoice(self.sTab[mod[2]])
						if q < thisWord:len() then newWord = newWord..thisWord:sub(q+1, thisWord:len()) end
						for z, n in pairs(self.sTab["0"]) do
							for s=4,1,-1 do newWord = newWord:gsub(n..string.rep(" ", s)..n, n..string.rep(" ", s+1)) end
							newWord = newWord:gsub(n..n, n.." ")
						end
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
					if not newList.wordTable[ENGLISH[i]] then newList.wordTable[ENGLISH[i]] = self.wordTable[ENGLISH[i]] or parent:name(true, math.ceil(ENGLISH[i]:len()/3), math.ceil(ENGLISH[i]:len()/3), true) end
					newList.letterCount = newList.letterCount+newList.wordTable[ENGLISH[i]]:len()
				end

				return newList
			end,

			diff = function(self, other)
				local factor = 0
				for i=1,#ENGLISH do
					local wrd1 = self.wordTable[ENGLISH[i]]
					local wrd2 = other.wordTable[ENGLISH[i]]
					for j=wrd1:len()+1,wrd2:len() do wrd1 = wrd1.."*" end
					for j=wrd2:len()+1,wrd1:len() do wrd2 = wrd2.."*" end

					local div = 1/wrd1:len()
					for j=1,wrd1:len() do if wrd2:len() < j or wrd1:sub(j, j) ~= wrd2:sub(j, j) then if self.sTab[wrd1:sub(j, j)] == self.sTab[wrd2:sub(j, j)] then factor = factor+(div/3) else factor = factor+div end end end
				end
				factor = factor/#ENGLISH
				return factor
			end,

			soundex = function(self, n, s)
				local nOut, oln = (s and self.sTab[(n:sub(1, 1)):lower()] or (n:sub(1, 1)):upper())
				for x=2,n:len() do nOut = nOut..(self.sTab[(n:sub(x, x)):lower()] or "0") end
				if not s then nOut = nOut:gsub("0", "") end
				while oln ~= nOut:len() do
					oln = nOut:len()
					if nOut:len() > 1 then for x=nOut:len()-1,1,-1 do if nOut:sub(x, x) == nOut:sub(x+1, x+1) then nOut = nOut:sub(1, x)..(x < nOut:len()-1 and nOut:sub(x+2, nOut:len()) or "") end end end
				end
				if nOut:len() < 4 then nOut = (s and nOut.."777" or nOut.."000") end

				return s and nOut or nOut:sub(1, 4)
			end,

			translate = function(self, parent, s)
				local thisText = s
				for x in s:gmatch("%S+") do thisText = thisText:gsub(x:gsub("%$", "%%$"):gsub("%^", "%%^"), function(n)
					if not self.wordTable[n:lower()] then
						local ln = math.ceil(n:len()/3)
						local word = parent:name(true, ln, ln, true)
						self.wordTable[n:lower()] = word:lower()
						self.letterCount = self.letterCount+word:len()
						if not table.contains(ENGLISH, n:lower()) then table.insert(ENGLISH, n:lower()) end
					end
					if n:match("%$rss") or n:match("%$es") or n:match("%$$") then return "$"..(string.stripDiphs(self.wordTable[n:lower()]:gsub(" ", "")))
					elseif n:match("%$rsp") or n:match("%^$") then return string.stripDiphs(self.wordTable[n:lower()]:gsub(" ", "")).."^"
					else return string.stripDiphs(self.wordTable[n:lower()]:gsub(" ", "")) end
				end) end
				return thisText:gsub(" %$", ""):gsub("%^ ", ""):gsub("^%S", string.upper)
			end,

			allMods = {
				{"1", "2", "3"}, -- Person. First, second, third.
				{"s", "d", "p"}, -- Number. Singular, dual, plural.
				{"d", "p", "a"}, -- Function. Demonstrative, possessive, dative. (Reflexive and determinant also handled, but exclusively as suffixes; see RSS, RSP, and ES.)
				{"m", "f", "n"}, -- Gender. Male, female, neuter.
				{"p", "^", "$"}, -- Form. Particle, prefix, suffix.
			},

			sTab = {
				["0"]={"a", "e", "o", "u", "y", "i"},
				["1"]={"p", "b", "f", "\xef", "v", "w", "h"},
				["2"]={"c", "k", "g", "j", "\xee", "z", "s", "\xed"},
				["3"]={"d", "t"},
				["4"]={"l"},
				["5"]={"m", "n", "\xec"},
				["6"]={"r"},
				["7"]={" "},
				a="0", e="0", i="0", o="0", u="0", y="0",
				w="1", h="1", b="1", f="1", ["\xef"]="1", p="1", v="1",
				c="2", g="2", j="2", k="2", ["\xee"]="2", z="2", s="2", ["\xed"]="2",
				d="3", t="3",
				l="4",
				m="5", n="5", ["\xec"]="5",
				r="6",
				[" "]="7",
			},
		}

		Language.__index = Language
		Language.__call = function() return Language:new() end
		Language.__tostring = function(self)
			local sOut, brk = "<Language", 0
			for i, j in pairs(self) do brk = brk+1 if brk < 4 then sOut = sOut.."\n\t"..tostring(i)..": "..tostring(j) elseif brk == 4 then sOut = sOut.."\n\t..." end end
			sOut = sOut..(brk > 0 and "\n" or "")..">"
			return sOut
		end

		return Language
	end