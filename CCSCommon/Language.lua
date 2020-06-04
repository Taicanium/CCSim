return
	function()
		require("CCSCommon.English")

		local Language = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.name = tostring(math.random(0, math.pow(2, 20)-1))
				o.wordTable = {}

				return o
			end,

			define = function(self, parent)
				for i=1,#ENGLISH do if not self.wordTable[ENGLISH[i]] then
					local ln = math.ceil(ENGLISH[i]:len()/3)
					local word = parent:namecheck(parent:name(true, ln, ln))
					self.wordTable[ENGLISH[i]] = word:lower()
				end end
			end,

			deviate = function(self, parent, factor)
				local newList = Language:new()
				local ops = {"OMIT", "REPLACE", "INSERT"}

				local fct = 0
				local totalFct = factor*#ENGLISH
				local prevDone = {}
				while fct < totalFct do
					fct = 0
					local op = parent:randomChoice(ops)
					local doOp = {}
					if op == "OMIT" then doOp = {parent:randomChoice(parent:randomChoice({parent.consonants, parent.vowels})), " "}
					elseif op == "REPLACE" then
						local group = parent:randomChoice(self.repGroups)
						local index = math.random(1, 2)
						doOp = {group[index == 1 and 1 or 2], group[index == 1 and 2 or 1]}
					elseif op == "INSERT" then doOp = {" ", parent:randomChoice(parent:randomChoice({parent.consonants, parent.vowels}))} end
					local i = 1
					while i <= #ENGLISH do
						local eng = ENGLISH[math.random(1, #ENGLISH)]
						local thisWord = newList.wordTable[eng] or self.wordTable[eng]
						local spaces = {}
						local newWord = thisWord:gsub(doOp[1], doOp[2], 1)
						for j=1,newWord:len() do local ind = newWord:find("%s", j) if spaces[#spaces] and spaces[#spaces] ~= ind then table.insert(spaces, ind) end end
						local check = parent:namecheck(newWord:gsub("%s", "")):lower()
						newWord = ""
						for j=1,#spaces do
							if j == 1 then newWord = check:sub(1, spaces[j]-1)
							else newWord = newWord..check:sub(spaces[j-1], spaces[j]-1).." " end
						end
						newWord = newWord..check:sub(spaces[#spaces] or 1, check:len())
						while newWord:len() < thisWord:len() do newWord = newWord.." " end
						while thisWord:len() < newWord:len() do thisWord = thisWord.." " end
						local div = (1/newWord:len())
						for j=1,newWord:len() do if newWord:sub(j, j) ~= thisWord:sub(j, j) then fct = fct+div end end
						newList.wordTable[eng] = newWord
						if fct >= totalFct then i = #ENGLISH end
						i = i+1
					end
				end

				for i=1,#ENGLISH do if not newList.wordTable[ENGLISH[i]] then newList.wordTable[ENGLISH[i]] = self.wordTable[ENGLISH[i]] end end

				return newList
			end,

			diff = function(self, other)
				local factor = 0
				for i=1,#ENGLISH do
					local wrd1 = self.wordTable[ENGLISH[i]]
					local wrd2 = other.wordTable[ENGLISH[i]]

					while wrd1:len() < wrd2:len() do wrd1 = wrd1.." " end
					while wrd2:len() < wrd1:len() do wrd2 = wrd2.." " end
					local div = 1/wrd1:len()
					for j=1,wrd1:len() do if wrd1:sub(j, j) ~= wrd2:sub(j, j) then factor = factor+div end end
				end
				factor = factor/#ENGLISH
				return factor
			end,

			repGroups = {
				{"o", "au"}, {"o", "ou"}, {"a", "e"}, {"u", "o"}, {"th", "t"}, {"th", "f"}, {"th", "s"}, {"ng", "n"}, {"b", "p"}, {"d", "t"}, {"sh", "s"}, {"sh", "th"}, {"v", "f"}, {"c", "g"}, {"z", "s"}, {"h", ""}, {"ch", "sh"}, {"th", "s"}, {"m", "n"}, {"e", "i"}, {"o", "oa"}, {"y", "i"}, {"s", "f"}, {"v", "b"}},
			},
		}

		Language.__index = Language
		Language.__call = function() return Language:new() end

		return Language
	end