return
	function()
		require("CCSCommon.English")

		local Language = {
			new = function(self)
				local o = {}
				setmetatable(o, self)

				o.cClusters = {}
				o.consonants = {}
				o.cvClusters = {}
				o.descentTree = {}
				o.eml = 1
				o.letterCount = 0
				o.name = tostring(math.random(0, math.pow(2, 24)-1))
				o.period = 1
				o.l1Speakers = 0
				o.l2Speakers = 0
				o.specials = {}
				o.vcClusters = {}
				o.vClusters = {}
				o.vowels = {}
				o.wordTable = {}

				return o
			end,

			define = function(self, parent)
				--local reset = true
				--while reset do
					self.consonants = {}
					self.vowels = {}
					self.cClusters = {}
					self.vClusters = {}
					self.cvClusters = {}
					self.vcClusters = {}

					tmpArr = {}
					for i=1,#Language.consonants do table.insert(tmpArr, Language.consonants[i]) end
					while #self.consonants < #Language.consonants*0.7 do
						ran = math.random(1, #tmpArr)
						table.insert(self.consonants, tmpArr[ran])
						table.remove(tmpArr, ran)
					end

					tmpArr = {}
					for i=1,#Language.vowels do table.insert(tmpArr, Language.vowels[i]) end
					local vCount = math.random(3, 6)
					while #self.vowels < vCount do
						ran = math.random(1, #tmpArr)
						table.insert(self.vowels, tmpArr[ran])
						table.remove(tmpArr, ran)
					end

					for i=1,#Language.cClusters do
						local c1 = Language.cClusters[i]:sub(1, 1)
						local c2 = Language.cClusters[i]:sub(2, 2)
						local cf = 0
						for j=1,#self.consonants do if self.consonants[j] == c1 or self.consonants[j] == c2 then cf = cf+1 end end
						if cf >= 2 then table.insert(self.cClusters, Language.cClusters[i]) end
					end

					for i=1,#Language.vClusters do
						local v1 = Language.vClusters[i]:sub(1, 1)
						local v2 = Language.vClusters[i]:sub(2, 2)
						local vf = 0
						for j=1,#self.vowels do if self.vowels[j] == v1 or self.vowels[j] == v2 then vf = vf+1 end end
						if vf >= 2 then table.insert(self.vClusters, Language.vClusters[i]) end
					end

					for i=1,#Language.cvClusters do
						local c1 = Language.cvClusters[i]:sub(1, 1)
						local v2 = Language.cvClusters[i]:sub(2, 2)
						local cvf = 0
						for j=1,#self.consonants do if self.consonants[j] == c1 then cvf = cvf+1 end end
						for j=1,#self.vowels do if self.vowels[j] == v2 then cvf = cvf+1 end end
						if cvf >= 2 then table.insert(self.cvClusters, Language.cvClusters[i]) end
					end

					for i=1,#Language.vcClusters do
						local v1 = Language.vcClusters[i]:sub(1, 1)
						local c2 = Language.vcClusters[i]:sub(2, 2)
						local vcf = 0
						for j=1,#self.vowels do if self.vowels[j] == v1 then vcf = vcf+1 end end
						for j=1,#self.consonants do if self.consonants[j] == c2 then vcf = vcf+1 end end
						if vcf >= 2 then table.insert(self.vcClusters, Language.vcClusters[i]) end
					end
					
					--reset = false
					--if #self.consonants == 0 or self.vowels == 0 or self.cClusters == 0 or self.cClusters == 0 or self.cClusters == 0 or self.cClusters == 0
				--end

				for i=1,#ENGLISH do if not self.wordTable[ENGLISH[i]] then
					local ln = ENGLISH[i]:len()
					local word = self:makeWord(ln > 1 and ln-1 or 1, ln+1)
					self.wordTable[ENGLISH[i]] = word:lower()
					self.letterCount = self.letterCount+word:len()
				end end

				self:defineSpecials(parent)
				self.period = parent.langPeriod
				self.eml = parent.langEML
			end,

			defineSpecials = function(self, parent)
				-- This is *remarkably* unintuitive... even as far as other sections of this program go.
				-- Essentially, the vast majority of natural Languages don't have 405 unique pronouns -- and, yes, I counted -- so, work here to combine a few.
				-- Somehow. Through some process.
				for i=1,#parent.pronouns do self.specials[parent.pronouns[i]] = string.lower(self:makeWord(2, 4)) end
				local i1 = math.random(1, 5)
				local i2 = math.random(1, 5) while i2 == i1 do i2 = math.random(1, 5) end
				local i3 = math.random(1, 5) while i3 == i2 or i3 == i1 do i3 = math.random(1, 5) end
				for i, j in pairs(self.specials) do for k, l in pairs(self.specials) do if i:sub(i1, i1) == k:sub(i1, i1) and i:sub(i2, i2) == k:sub(i2, i2) and i:sub(i3, i3) == k:sub(i3, i3) then self.specials[k] = self.specials[i] end end end
				self.specials["$rss"] = string.lower(self:makeWord(2, 4)) -- Reflexive singular suffix. (Eng: 'self')
				self.specials["$rsp"] = string.lower(self:makeWord(2, 4)) -- Reflexive plural suffix. (Eng: 'selves')
				self.specials["$es"] = string.lower(self:makeWord(1, 2)) -- Determinant suffix. (Eng: 's', as in 'theirs' or 'hers')
				self.specials["$da"] = string.lower(self:makeWord(2, 3)) -- Definite article. (Eng: 'the')
				for i, j in pairs(self.specials) do
					self.wordTable[i] = self.wordTable[i] or j
					self.letterCount = self.letterCount+j:len()
					self.specials[i] = nil
				end
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
				for i=1,#parent.pronouns do newList.wordTable[parent.pronouns[i]] = self.wordTable[parent.pronouns[i]] or string.lower(self:makeWord(2, 4)) end
				newList.wordTable["$rss"] = self.wordTable["$rss"] or string.lower(self:makeWord(2, 4))
				newList.wordTable["$rsp"] = self.wordTable["$rsp"] or string.lower(self:makeWord(2, 4))
				newList.wordTable["$es"] = self.wordTable["$es"] or string.lower(self:makeWord(2, 4))
				newList.wordTable["$da"] = self.wordTable["$da"] or string.lower(self:makeWord(2, 4))
				while fct < totalFct do
					local eng = parent:randomChoice(self.wordTable, true)
					local thisWord = newList.wordTable[eng] or self.wordTable[eng]
					newList.wordTable[eng] = self:modWord(parent, thisWord, mod)
					repCount = repCount+newList.wordTable[eng]:len()
					if repCount >= newList.letterCount*0.7125 then
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
				for i=1,#ENGLISH do if not newList.wordTable[ENGLISH[i]] then newList.wordTable[ENGLISH[i]] = self.wordTable[ENGLISH[i]] or self:makeWord(ENGLISH[i]:len() > 1 and ENGLISH[i]:len()-1 or 1, ENGLISH[i]:len()+1) end end
				for i, j in pairs(newList.wordTable) do newList.letterCount = newList.letterCount+j:len() end

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

			makeWord = function(self, min, max)
				local nom = ""
				local length = math.random(min or 1, max or 5)
				local grp, oldGrp
				local consFinal = false

				init = math.random(1000, 6000)
				if init < 2000 then grp = self.vowels consFinal = false
				elseif init < 3000 and length > 2 then grp = self.cClusters consFinal = true
				elseif init < 4000 then grp = self.vClusters consFinal = false
				elseif init < 5000 then grp = self.cvClusters consFinal = false
				elseif length > 2 then grp = self.vcClusters consFinal = true
				else grp = self.cvClusters consFinal = false end
				nom = grp[math.random(1, #grp)]
				if tostring(grp) == tostring(self.cClusters) then while not nom:match("%*") do nom = grp[math.random(1, #grp)] end end
				local letters = nom:len()
				while letters < length-1 do
					oldGrp = grp
					while tostring(grp) == tostring(oldGrp) do
						mid = math.random(1000, 6000)
						if mid < 2000 and consFinal then grp = self.vowels consFinal = false
						elseif mid < 3000 and not consFinal then grp = self.cClusters consFinal = true
						elseif mid < 4000 and consFinal then grp = self.vClusters consFinal = false
						elseif mid < 5000 and not consFinal then grp = self.cvClusters consFinal = false
						elseif consFinal then grp = self.vcClusters consFinal = true
						else grp = self.cvClusters consFinal = false end
					end
					local midGrp = grp[math.random(1, #grp)]

					nom = nom..midGrp
					letters = letters+midGrp:len()
				end
				if length > 2 then
					oldGrp = grp
					while tostring(grp) == tostring(oldGrp) do
						ending = math.random(1000, 6000)
						if ending < 2000 and consFinal then grp = self.vowels consFinal = false
						elseif ending < 3000 and not consFinal then grp = self.cClusters consFinal = true
						elseif ending < 4000 and consFinal then grp = self.vClusters consFinal = false
						elseif ending < 5000 and not consFinal then grp = self.cvClusters consFinal = false
						elseif consFinal then grp = self.vcClusters consFinal = true
						else grp = self.cvClusters consFinal = false end
					end
					local endingGrp = grp[math.random(1, #grp)]
					if tostring(grp) == tostring(self.cClusters) then while not endingGrp:match("%^") do endingGrp = grp[math.random(1, #grp)] end end
					nom = nom..endingGrp
				end

				nom = nom:gsub("\xef", "th"):gsub("\xee", "zh"):gsub("\xed", "sh"):gsub("\xec", "ng")
				nom = nom:gsub("^%S", string.upper):gsub("%*", ""):gsub("%^", "")
				return nom
			end,

			modWord = function(self, parent, n, mod)
				local newWord, fin = n
				for q=1,n:len() do if not fin and self.sTab[n:sub(q, q):lower()] == mod[1] and ((mod[1] ~= "0" or mod[2] == "0") or ((q > 1 and self.sTab[n:sub(q-1, q-1):lower()] == "0") or (q < n:len() and self.sTab[n:sub(q+1, q+1):lower()] == "0"))) then
					newWord = n:sub(1, q-1)..parent:randomChoice(self.sTab[mod[2]])
					if q < n:len() then newWord = newWord..n:sub(q+1, n:len()) end
					for z, n in pairs(self.sTab["0"]) do
						for s=4,1,-1 do newWord = newWord:gsub(n..string.rep(" ", s)..n, n..string.rep(" ", s+1)) end
						newWord = newWord:gsub(n..n, n.." ")
					end
					fin = true
				end end
				return newWord
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
						local word = self:makeWord(n:len() > 1 and n:len()-1 or 1, n:len()+1)
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

			cClusters = {
				"bb^", "bc", "bd", "bf", "bg", "bh*^", "bj*", "bk", "bl*", "bm", "bn", "br*", "bs^", "bt", "bv", "bw*", "by*^", "bz^",
				"cb", "cc^", "cd", "cf", "ch*^", "cj", "ck^", "cl*", "cm", "cn", "cp", "cr*", "cs^", "ct^", "cv", "cw*", "cy*^", "cz^",
				"db", "dd^", "df", "dg", "dh*^", "dj", "dk", "dl", "dm", "dn", "dp", "dr*", "ds^", "dv", "dw*", "dy*^", "dz^",
				"fb", "fc", "fd", "ff^", "fg", "fh*^", "fj", "fk", "fl*", "fm", "fn", "fp", "fr*", "fs^", "ft^", "fw*", "fy*^", "fz^^",
				"gb", "gd^", "gf", "gg^", "gh*", "gj", "gl*", "gm", "gn", "gp", "gr*", "gs^", "gt^", "gv", "gw*", "gy*^", "gz",
				"hb^", "hc^", "hd^", "hf", "hg", "hj", "hk^", "hl", "hm^", "hn^", "hp", "hr", "hs^", "ht", "hv", "hw*", "hy^", "hz^",
				"jb", "jc", "jd^", "jf", "jg", "jh", "jk", "jl", "jm", "jn", "jp", "jr", "js", "jt", "jv", "jw", "jy^", "jz",
				"kb", "kd^", "kf", "kh*^", "kj", "kk^", "kl*", "km", "kn", "kp", "kr*", "ks^", "kt^", "kv", "kw*", "ky^", "kz^",
				"lb^", "lc", "ld", "lf", "lg", "lh*", "lj", "lk", "ll^", "lm", "ln", "lp^", "lr", "ls^", "lt^", "lv^", "lw", "ly^", "lz^",
				"mb^", "mc", "md^", "mf", "mg", "mh*", "mj", "mk^", "ml", "mm^", "mn", "mp", "mr", "ms", "mt", "mv", "mw*", "my*^", "mz^",
				"nb^", "nc^", "nd^", "nf^", "nh*", "nj", "nk^", "nl", "nm", "nn^", "np^", "nr", "ns^", "nt^", "nv", "nw*", "ny*^", "nz^",
				"\xecb", "\xecd", "\xecf", "\xech", "\xecj", "\xecl", "\xecm", "\xecn", "\xecp", "\xecr", "\xecs", "\xec\xed", "\xect", "\xec\xef", "\xecv", "\xecw", "\xecz", "\xec\xee",
				"pc", "pd", "pf", "pg", "ph*", "pj", "pk", "pl*", "pm", "pn", "pp^", "pr*", "ps^", "pt^", "pv", "pw*", "py*^", "pz^",
				"rb^", "rc^", "rd^", "rf^", "rg^", "rh*", "rj^", "rk^", "rl^", "rm^", "rn^", "rp^", "rr^", "rs^", "rt^", "rv^", "rw", "ry^", "rz^",
				"sb^", "sc*^", "sd^", "sf", "sg^", "sj", "sk*^", "sl*", "sm*", "sn*", "sp^", "sr", "ss^", "st*^", "sv", "sw*", "sy*^",
				"\xedb", "\xedc", "\xedd", "\xedf", "\xedg", "\xedj", "\xedk", "\xedl", "\xedm", "\xedn", "\xedp", "\xedr", "\xedt", "\xed\xef", "\xedv", "\xedw",
				"tb", "tc", "tf", "tg", "tj", "tk", "tl", "tm", "tn", "tp", "tr*", "ts^", "tt^", "tv", "tw*", "ty*^", "tz^",
				"\xefb", "\xefc", "\xefd", "\xeff", "\xefg", "\xefj", "\xefk", "\xefl", "\xefm", "\xefn", "\xefp", "\xefr", "\xefs", "\xef\xed", "\xeft", "\xefv", "\xefw", "\xefz", "\xef\xee",
				"vb", "vc", "vd", "vg", "vh*^", "vj", "vk", "vl", "vm", "vn", "vp", "vr", "vs^", "vt^", "vv", "vw", "vy^", "vz^",
				"wh*", "wr*", "wy*^",
				"zb", "zc^", "zd^", "zf", "zg^", "zj", "zk^", "zl", "zm", "zn", "zp", "zr", "zt^", "zv", "zw*", "zy*^", "zz^",
				"\xeeb", "\xeec", "\xeed", "\xeef", "\xeeg", "\xeej", "\xeek", "\xeel", "\xeem", "\xeen", "\xeep", "\xeer", "\xeet", "\xee\xef", "\xeev", "\xeew",
			},

			consonants = {"b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "\xec", "p", "r", "s", "\xed", "t", "\xef", "v", "w", "z", "\xee"},

			cvClusters = {
				"ba", "be", "by", "bi", "bo", "bu",
				"ca", "ce", "cy", "ci", "co", "cu",
				"da", "de", "dy", "di", "do", "du",
				"fa", "fe", "fy", "fi", "fo", "fu",
				"ga", "ge", "gy", "gi", "go", "gu",
				"ha", "he", "hy", "hi", "ho", "hu",
				"ja", "je", "jy", "ji", "jo", "ju",
				"ka", "ke", "ky", "ki", "ko", "ku",
				"la", "le", "ly", "li", "lo", "lu",
				"ma", "me", "my", "mi", "mo", "mu",
				"na", "ne", "ny", "ni", "no", "nu",
				"\xeca", "\xece", "\xecy", "\xeci", "\xeco", "\xecu",
				"pa", "pe", "py", "pi", "po", "pu",
				"ra", "re", "ry", "ri", "ro", "ru",
				"sa", "se", "sy", "si", "so", "su",
				"\xeda", "\xede", "\xedy", "\xedi", "\xedo", "\xedu",
				"ta", "te", "ty", "ti", "to", "tu",
				"\xefa", "\xefe", "\xefy", "\xefi", "\xefo", "\xefu",
				"va", "ve", "vy", "vi", "vo", "vu",
				"wa", "we", "wy", "wi", "wo", "wu",
				"za", "ze", "zy", "zi", "zo", "zu",
				"\xeea", "\xeee", "\xeey", "\xeei", "\xeeo", "\xeeu",
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

			vcClusters = {
				"ab", "ac", "ad", "af", "ag", "ah", "aj", "ak", "al", "am", "an", "a\xec", "ap", "ar", "as", "a\xed", "at", "a\xef", "av", "aw", "az", "a\xee",
				"eb", "ec", "ed", "ef", "eg", "eh", "ej", "ek", "el", "em", "en", "e\xec", "ep", "er", "es", "a\xed", "et", "a\xef", "ev", "ew", "ez", "a\xee",
				"yb", "yc", "yd", "yf", "yg", "yh", "yj", "yk", "yl", "ym", "yn", "y\xec", "yp", "yr", "ys", "a\xed", "yt", "a\xef", "yv", "yw", "yz", "a\xee",
				"ib", "ic", "id", "if", "ig", "ih", "ij", "ik", "il", "im", "in", "i\xec", "ip", "ir", "is", "a\xed", "it", "a\xef", "iv", "iw", "iz", "a\xee",
				"ob", "oc", "od", "of", "og", "oh", "oj", "ok", "ol", "om", "on", "o\xec", "op", "or", "os", "a\xed", "ot", "a\xef", "ov", "ow", "oz", "a\xee",
				"ub", "uc", "ud", "uf", "ug", "uh", "uj", "uk", "ul", "um", "un", "u\xec", "up", "ur", "us", "a\xed", "ut", "a\xef", "uv", "uw", "uz", "a\xee",
			},

			vClusters = {"a", "e", "i", "o", "u", "ae", "ai", "ao", "au", "ea", "ei", "eo", "eu", "ya", "ye", "yi", "yo", "yu", "ia", "ie", "io", "iu", "oa", "oe", "oi", "ou", "ua", "ue", "ui", "uo"},

			vowels = {"a", "e", "y", "i", "o", "u"},
		}

		Language.__index = Language
		Language.__call = function() return Language:new() end

		return Language
	end