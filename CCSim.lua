_BUILD = "1610236800"
_DEBUG = false
_RUNNING = true

CCSMStatus, CCSModule = pcall(require, "CCSCommon")
if not CCSMStatus or not CCSModule then error(tostring(CCSModule)) os.exit(1) end
CCSFStatus, CCSCommon = pcall(CCSModule)
if not CCSFStatus or not CCSCommon then error(tostring(CCSCommon)) os.exit(1) end

CCSCommon:rseed()

if _DEBUG then
	testGlyphs()
	testNames()
end

while _RUNNING do
	UI:clear()
	UI:printf("\n\n\tCCSIM : Compact Country Simulator\n\n\tBuild ".._BUILD.."\n\n\n")
	if _DEBUG then UI:printf("\t-- DEBUG MODE ENABLED --\n\n") end
	UI:printf("MAIN MENU\n\n1\t-\tBegin a new simulation.")
	UI:printf("2\t-\tReview the output of a previous simulation.")
	if _DEBUG then UI:printf("3\t-\tExecute a line of Lua code.\n") end
	UI:printf("Q\t-\tExit the program.")
	UI:printp("\n > ")

	local datin = UI:readl()
	if datin == "1" or datin == "" then simNew() _RUNNING = false
	elseif datin == "2" then simReview()
	elseif datin == "3" and _DEBUG then debugLine()
	elseif datin:lower() == "q" then _RUNNING = false end
end

CCSCommon = nil
os.exit(0)
