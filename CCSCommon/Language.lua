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
				local ops = {"OMIT", "REPLACE", "INSERT"}

				local fct = 0
				local totalFct = parent.langDriftConstant*self.letterCount
				local doOp = {}
				while fct < totalFct do
					local op = parent:randomChoice(ops)
					if op == "OMIT" then doOp = {parent:randomChoice(parent:randomChoice({parent.consonants, parent.vowels})), " "}
					elseif op == "REPLACE" then
						local group = parent:randomChoice(self.repGroups)
						local index = math.random(1, 2) == 1
						doOp = {group[index and 1 or 2], group[index and 2 or 1]}
					elseif op == "INSERT" then doOp = {" ", parent:randomChoice(parent:randomChoice({parent.consonants, parent.vowels}))} end
					local eng = ENGLISH[math.random(1, #ENGLISH)]
					local thisWord = newList.wordTable[eng] or self.wordTable[eng]
					local spaces = {}
					local newWord, repCount = thisWord:gsub(doOp[1], doOp[2], 1)
					if op == "REPLACE" then repCount = repCount+math.abs(doOp[1]:len()-doOp[2]:len()) end
					for j=1,newWord:len() do
						local ind = newWord:find("%s", j)
						if spaces[#spaces] and spaces[#spaces] ~= ind then table.insert(spaces, ind) end
					end
					local check = parent:namecheck(newWord:gsub("%s", "")):lower()
					newWord = ""
					for j=1,#spaces do
						if j == 1 then newWord = check:sub(1, spaces[j]-1)
						else newWord = newWord..check:sub(spaces[j-1], spaces[j]-1).." " end
					end
					newWord = newWord..check:sub(spaces[#spaces] or 1, check:len())
					while newWord:len() < thisWord:len() do newWord = newWord.." " end
					newList.wordTable[eng] = newWord
					fct = fct+repCount
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

			repGroups = {
				{"o", "au"}, {"o", "ou"}, {"a", "e"}, {"u", "o"}, {"th", "t"}, {"th", "f"}, {"th", "s"}, {"ng", "n"}, {"b", "p"}, {"d", "t"}, {"sh", "s"}, {"sh", "th"}, {"v", "f"}, {"c", "g"}, {"z", "s"}, {"h", ""}, {"ch", "sh"}, {"th", "s"}, {"m", "n"}, {"e", "i"}, {"o", "oa"}, {"y", "i"}, {"s", "f"}, {"v", "b"},
			},
		}

		Language.__index = Language
		Language.__call = function() return Language:new() end

		return Language
	end