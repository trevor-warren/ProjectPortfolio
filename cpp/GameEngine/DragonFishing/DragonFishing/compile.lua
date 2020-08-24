local make = [[
make :
	C:/mingw/bin/g++ -std=c++11 %s -DGLEW_STATIC %s %s 2> err.txt
	
mem :
	drmemory -- ./a.exe
	
mem2 :
	drmemory -- ./a.exe 2> mem.txt

loc :
	./cloc --by-file-by-lang ./ > loc.txt
]]

local swapLibraries = {
	["SDL2.lib"] = "SDL2.a",
	["SDL2main.lib"] = "SDL2main.a",
	["lua53.lib"] = "liblua.a",
	["SOIL.lib"] = "SOIL.a",
	["glew32.lib"] = "glew32.a",
	["glew32s.lib"] = "glew32mx.a"
}

local files = ""

local file = io.open("./DragonFishing.vcxproj", "r")
local data = file:read("*all")

for source in data:gmatch('ClCompile Include="([a-zA-Z0-9\\%.]+)"') do
	local padding
	
	if files == "" then
		padding = ""
	else
		padding = " "
	end
	
	files = files .. padding .. "./" .. source:gsub("\\","/")
end

for source in data:gmatch('ClInclude Include="([a-zA-Z\\%.]+)"') do
	local file = io.open(source:gsub("\\","/"), "r")
	
	if not file:read("*all"):match("[\n\r][ \t]*$") then
		file:close()
		file = io.open(source:gsub("\\","/"), "a")
		file:write("\n")
		
		print("fixed " .. source .. "; added a new line to the end of file")
		file:flush()
	end
	
	file:close()
end

for source in data:gmatch('ClCompile Include="([a-zA-Z\\%.]+)"') do
	local file = io.open(source:gsub("\\","/"), "r")
	
	if not file:read("*all"):match("[\n\r][ \t]*$") then
		file:close()
		file = io.open(source:gsub("\\","/"), "a")
		file:write("\n")
		
		print("fixed " .. source .. "; added a new line to the end of file")
		file:flush()
	end
	
	file:close()
end

local includePathData, libraryPathData = data:match("'Debug|Win32'\">[^<]+<IncludePath>([^<]+)</IncludePath>[^<]+<LibraryPath>([^<]+)</LibraryPath>")

local includePaths = ""
local libraryPaths = ""

for path in includePathData:gmatch("[^;]+") do
	path = path:gsub("$%(SolutionDir%)DragonFishing[\\/]","./../"):gsub("\\","/")
	
	if path ~= "$(IncludePath)" then
		local padding
		
		if includePaths == "" then
			padding = "-I"
		else
			padding = " -I"
		end
		
		includePaths = includePaths .. padding .. path
	end
end

local libraryPathList = {}

for path in libraryPathData:gmatch("[^;]+") do
	path = path:gsub("$%(SolutionDir%)DragonFishing[\\/]","./../"):gsub("\\","/"):gsub("/lua/msvs32","/lua/mingw")
	
	if path ~= "$(LibraryPath)" then
		path = path:gsub("/[^/]+/?$", "/mingw/")
		
		local padding
		
		if libraryPaths == "" then
			padding = "-L"
		else
			padding = " -L"
		end
		
		libraryPaths = libraryPaths .. padding .. path
		libraryPathList[#libraryPathList + 1] = path
	end
end

local librariesData = data:match("<ItemDefinitionGroup.-'Debug|Win32'\">.-</ItemDefinitionGroup>")

if librariesData then
	librariesData = librariesData:match("<AdditionalDependencies>([^<]+)</AdditionalDependencies>"):gsub(";%%(AdditionalDependencies)","")
end

local libraries = ""

if librariesData then
	print(librariesData)
	for library in librariesData:gmatch("[^;]+") do
		if #library > 0 and library ~= "%(AdditionalDependencies)" then
			library = swapLibraries[library] or library
			print(library)
			
			local padding
			
			if libraries == "" then
				padding = ""
			else
				padding = " "
			end
			
			--libraries = libraries .. padding .. "-" .. library:gsub("%..+","") 
			for i,path in pairs(libraryPathList) do
				print(path..library)
				local file = io.open(path .. library)
				
				if file then
					print("---")
					libraries = libraries .. padding .. path .. library
					
					file:close()
					
					break
				end
			end
		end
	end
end

file:close()

file = io.open("./makefile", "w")

file:write(make:format(includePaths:gsub("/+ "," "), --[[libraryPaths:gsub("/+ "," "),]] files, libraries))

file:flush()
file:close()