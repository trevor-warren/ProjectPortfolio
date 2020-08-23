local container = workspace.DebugDisplay
local cellContainer = workspace.DebugDraw
local air = Enum.Material.Air
local grass = Enum.Material.Grass

function cell(center, occupancy, material, x, y, z)
	local display = Instance.new("Part")
	display.Name = "Cell"
	display.Size = 1 * Vector3.new(0.5 + 0.5 * occupancy, 0.5 + 0.5 * occupancy, 0.5 + 0.5 * occupancy)
	display.CFrame = CFrame.new(center + 2 * Vector3.new(x - 1, y - 1, z - 1))
	display.Color = workspace.Terrain:GetMaterialColor(material)
	display.Transparency = 0.5 * (1 - occupancy)
	display.Parent = cellContainer
end

local offsets = {
	{ 0, 0, 0,   4, "3" },
	{ 0, 0, 2,  64, "7" },
	{ 0, 2, 0,   2, "2" },
	{ 0, 2, 2,  32, "6" },
	{ 2, 0, 0,   8, "4" },
	{ 2, 0, 2, 128, "8" },
	{ 2, 2, 0,   1, "1" },
	{ 2, 2, 2,  16, "5" }
}

local materials = {
	Enum.Material.Grass,
	Enum.Material.Grass,
	Enum.Material.Grass,
	Enum.Material.Grass,
	Enum.Material.Grass,
	Enum.Material.Grass,
	Enum.Material.Grass,
	Enum.Material.Grass
}

local occupancies = {
	0.5,
	0.5,
	0.5,
	0.5,
	0.5,
	0.5,
	0.5,
	0.5
}

local testOccupancy = 0.9

local ambiguousFaces = {
	-- -z
	{ "00001010", "00001111", Enum.NormalId.Front, 1 },
	{ "00000101", "00001111", Enum.NormalId.Front, 2 },
	-- +z
	{ "10100000", "11110000", Enum.NormalId.Back, 1 },
	{ "01010000", "11110000", Enum.NormalId.Back, 2 },
	-- -x
	{ "01000010", "01100110", Enum.NormalId.Left, 1 },
	{ "00100100", "01100110", Enum.NormalId.Left, 2 },
	-- +x
	{ "10000001", "10011001", Enum.NormalId.Right, 1 },
	{ "00011000", "10011001", Enum.NormalId.Right, 2 },
	-- -y
	{ "10000100", "11001100", Enum.NormalId.Bottom, 1 },
	{ "01001000", "11001100", Enum.NormalId.Bottom, 2 },
	-- +y
	{ "00010010", "00110011", Enum.NormalId.Top, 1 },
	{ "00100001", "00110011", Enum.NormalId.Top, 2 },
}

function convertBinary(data)
	local value = 0
	local digit = 1
	
	for i = 8, 1, -1 do
		value = value + (data:sub(i, i) == "0" and 0 or digit)
		
		digit = digit * 2
	end
	
	return value
end

for i, v in pairs(ambiguousFaces) do
	v[1] = convertBinary(v[1])
	v[2] = convertBinary(v[2])
	v[5] = 0
end

function draw(i, terrainType)
	local x, z = i % 16, math.floor(i / 16)
	local center = Vector3.new((x - 8) * 16, 200, (z - 8) * 16)
	
	local cellDisplay = workspace.Cell:Clone()
	cellDisplay.CFrame = CFrame.new(center)
	cellDisplay.Parent = cellContainer
	cellDisplay.i.BillboardGui.TextLabel.Text = tostring(i)
	
	local v = {0, 255}--ambiguousFaces[12]
	--for _, v in pairs(ambiguousFaces) do
		if bit32.band(bit32.bxor(i, v[1]), v[2]) == v[2] then
			local surfaceSelection = Instance.new("SurfaceSelection", cellDisplay)
			surfaceSelection.TargetSurface = v[3]
			surfaceSelection.Adornee = cellDisplay
			surfaceSelection.Color3 = v[4] == 1 and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
			
			v[5] = v[5] + 1
		end
	--end
	
	for _, v in pairs(offsets) do
		if bit32.band(i, v[4]) ~= 0 then
			cell(center, 0.25, Enum.Material.Grass, v[1], v[2], v[3])
		else
			cellDisplay[v[5]]:Destroy()
		end
	end
end

function drawGeometry(i, terrainType, DrawTriangle)
	local x, z = i % 16, math.floor(i / 16)
	local center = Vector3.new((x - 8) * 16, 200, (z - 8) * 16)
	
	return terrainType(container, center, materials, occupancies, i, DrawTriangle)
end

function generateOccupancies(permutation, occupancies)
	occupancies[1] = (bit32.band(permutation, 001) == 0) and 0 or testOccupancy
	occupancies[2] = (bit32.band(permutation, 002) == 0) and 0 or testOccupancy
	occupancies[3] = (bit32.band(permutation, 004) == 0) and 0 or testOccupancy
	occupancies[4] = (bit32.band(permutation, 008) == 0) and 0 or testOccupancy
	occupancies[5] = (bit32.band(permutation, 016) == 0) and 0 or testOccupancy
	occupancies[6] = (bit32.band(permutation, 032) == 0) and 0 or testOccupancy
	occupancies[7] = (bit32.band(permutation, 064) == 0) and 0 or testOccupancy
	occupancies[8] = (bit32.band(permutation, 128) == 0) and 0 or testOccupancy
end

return function(mode, type)
	if mode == "draw" then
		local terrain = require(workspace.TerrainModule:Clone())
		
		for i,v in pairs(terrain) do print(i, v) end
		
		terrain.DrawVoxels(
			--terrain.ReadVoxels(Vector3.new(-512,-256,-512), Vector3.new(512,256,512), true),
			terrain.ReadVoxels(terrain.PartToRegion(workspace.Part)),
			require(workspace.TerrainTypes[type]:Clone())
		)
	elseif mode == "node" then
		local terrain = require(workspace.TerrainModule:Clone())
		
		for i,v in pairs(terrain) do print(i, v) end
		
		terrain.DisplayVoxels(terrain.ReadVoxels(terrain.PartToRegion(workspace.Part)))
	elseif mode == "debug" then
		local terrain = require(workspace.TerrainModule:Clone())
		
		for i,v in pairs(terrain) do print(i, v) end
		
		cellContainer:ClearAllChildren()
		
		local terrainType = require(workspace.TerrainTypes[type])
		
		for i = 1, 255 do
			draw(i, terrainType)
		end
	elseif mode == "debugDraw" then
		local terrain = require(workspace.TerrainModule:Clone())
		
		for i,v in pairs(terrain) do print(i, v) end
		
		container:ClearAllChildren()
		
		local terrainType = require(workspace.TerrainTypes[type]:Clone())
		local missing = 0
		local conflicts = 0
		
		for i = 1, 254 do
			generateOccupancies(i, occupancies)
			
			local success, potentialConflict = drawGeometry(i, terrainType, terrain.DrawTriangle)
			
			if not success then
				missing = missing + 1
			end
			
			if potentialConflict then
				conflicts = conflicts + 1
			end
		end
		
		print("missing", missing)
		print("conflicts: ", conflicts)
	end
end