--[[
Voxels = {
	Size = Vector3, -- Voxel space
	Start = Vector3, -- Voxel space
	Region = Region3, -- World space
	Cells = { -- x
		{ -- y
			{ -- z
				
			}
		}
	}
}
]]

function Round(x)
	local int = math.floor(x)
	
	if x > int + 0.5 then
		return int +1
	else
		return int
	end
end

function PartToRegion(part)
	return part.Position - 0.5 * part.Size, part.Position + 0.5 * part.Size, true
end

function ReadVoxels(min, max, convertToCell)
	if convertToCell then
		min = 4 * Vector3.new(Round(min.X / 4), Round(min.Y / 4), Round(min.Z / 4))
		max = 4 * Vector3.new(Round(max.X / 4), Round(max.Y / 4), Round(max.Z / 4))
		
		local x = 0
		local y = 0
		local z = 0
		
		if min.X == max.X then
			x = 4
		end
		
		if min.Y == max.Y then
			y = 4
		end
		
		if min.Z == max.Z then
			z = 4
		end
		
		max = max + Vector3.new(x, y, z)
	end
	
	local start = 0.25 * min
	local region = Region3.new(min, max)
	local materials, occupancy = workspace.Terrain:ReadVoxels(region, 4)
	local size = materials.Size
	
	materials.Size = nil
	occupancy.Size = nil
	
	return {
		Size = size,
		Start = start,
		Region = region,
		MaterialVoxels = materials,
		OccupancyVoxels = occupancy
	}
end

function VoxelExposed(voxels, x, y, z)
	if x <= 1 or y <= 1 or z <= 1 then
		return true
	end
	
	local size = voxels.Size
	
	if x >= size.X or y >= size.Y or z >= size.Z then
		return true
	end
	
	local air = Enum.Material.Air
	
	for i = x - 1, x + 1 do
		local cellsX = voxels.MaterialVoxels[i]
		
		for j = y - 1, y + 1 do
			local cellsY = cellsX[j]
			
			for k = z - 1, z + 1 do
				if not (i == x and j == y and k == z) and cellsY[k] == air then
					return true
				end
			end
		end
	end
	
	return false
end

function DisplayVoxels(voxels)
	local container = workspace:FindFirstChild("CellDisplay")
	
	if not container then
		container = Instance.new("Model", workspace)
		container.Name = "CellDisplay"
	end
	
	container:ClearAllChildren()
	
	local air = Enum.Material.Air
	local water = Enum.Material.Water
	
	for x = 1, voxels.Size.X do
		local cellMaterialX = voxels.MaterialVoxels[x]
		local cellOccupancyX = voxels.OccupancyVoxels[x]
		local cellName = "( "..tostring(x + voxels.Start.X)..", "
		
		for y = 1, voxels.Size.Y do
			local cellMaterialY = cellMaterialX[y]
			local cellOccupancyY = cellOccupancyX[y]
			local cellName = cellName..tostring(y + voxels.Start.Y)..", "
		
			for z = 1, voxels.Size.Z do
				local material = cellMaterialY[z]
				local occupancy = cellOccupancyY[z]
				local cellName = cellName..tostring(z + voxels.Start.Z).." )"
				
				if material ~= air and material ~= water and VoxelExposed(voxels, x, y ,z) then
					local display = Instance.new("Part")
					display.Name = cellName
					display.Size = 1 * Vector3.new(0.5 + 0.5 * occupancy, 0.5 + 0.5 * occupancy, 0.5 + 0.5 * occupancy)
					display.CFrame = CFrame.new(Vector3.new(2, 2, 2) + 4 * (voxels.Start + Vector3.new(x - 1, y - 1, z - 1)))
					display.Color = workspace.Terrain:GetMaterialColor(material)
					display.Transparency = 0.5 * (1 - occupancy)
					display.Parent = container
				end
			end
		end
	end
end

function Fetch(container, index)
	if container then
		return container[index]
	end
	
	return nil
end

function GetPermutation(materials)
	local air = Enum.Material.Air
	
	return (
		  1 * (materials[1] == air and 0 or 1) +
		  2 * (materials[2] == air and 0 or 1) +
		  4 * (materials[3] == air and 0 or 1) +
		  8 * (materials[4] == air and 0 or 1) +
		 16 * (materials[5] == air and 0 or 1) +
		 32 * (materials[6] == air and 0 or 1) +
		 64 * (materials[7] == air and 0 or 1) +
		128 * (materials[8] == air and 0 or 1)
	)
end

function PlaceTriangle(wedge, position, upAxis, frontAxis)
	wedge.CFrame = CFrame.fromMatrix(position, upAxis:Cross(frontAxis), upAxis, frontAxis)
end

function ComputeTriangle(wedge1, wedge2, point1, point2, point3, distance1, distance2, distance3)
	local side1 = point2 - point1
	local side3 = point3 - point1
	
	local point4Offset = (side1:Dot(side3) / side1:Dot(side1)) * side1
	
	local side4 = side3 - point4Offset
	
	local length1 = side1.magnitude
	local length2 = side4.magnitude
	local length3 = point4Offset.magnitude
	
	local axis1 = (1 / length1) * side1
	local axis2 = (1 / length2) * side4
	
	PlaceTriangle(wedge1, 0.5 * (point2 + point3), axis1, -axis2)
	PlaceTriangle(wedge2, 0.5 * (point1 + point3), axis2, axis1)
	
	wedge1.Size = Vector3.new(0.02, length1 - length3, length2)
	wedge2.Size = Vector3.new(0.02, length2, length3)
end

function DrawTriangle(container, point1, point2, point3, flipped)
	if flipped then
		return DrawTriangle(container, point1, point3, point2, false)
	end
	
	local side1 = point2 - point1
	local side2 = point3 - point2
	local side3 = point1 - point3
	
	local distance1 = side1:Dot(side1)
	local distance2 = side2:Dot(side2)
	local distance3 = side3:Dot(side3)
	
	if math.abs(distance1) < 0.001 or math.abs(distance2) < 0.001 or math.abs(distance3) < 0.001 then 
		--warn("degenerate triangle, shared vertices")
		
		return false
	else
		local normal1 = side1:Cross(side2)
		local normal2 = side1:Cross(side3)
		local normal3 = side2:Cross(side3)
		
		if math.abs(normal1:Dot(normal1)) < 0.001 or math.abs(normal2:Dot(normal2)) < 0.001 or math.abs(normal3:Dot(normal3)) < 0.001 then
			--warn("degenerate triangle, collinear")
			
			return false
		end
	end
	
	local wedge1 = Instance.new("WedgePart")
	wedge1.Anchored = true
	wedge1.BottomSurface = Enum.SurfaceType.Smooth
	wedge1.RightSurface = Enum.SurfaceType.Inlet
	wedge1.Parent = container
	
	local wedge2 = Instance.new("WedgePart")
	wedge2.Anchored = true
	wedge2.BottomSurface = Enum.SurfaceType.Smooth
	wedge2.RightSurface = Enum.SurfaceType.Inlet
	wedge2.Parent = container
	
	if distance1 > distance2 and distance1 > distance3 then
		ComputeTriangle(wedge1, wedge2, point1, point2, point3)
	elseif distance2 > distance3 then
		ComputeTriangle(wedge1, wedge2, point2, point3, point1)
	else
		ComputeTriangle(wedge1, wedge2, point3, point1, point2)
	end
end

function DrawVoxels(voxels, renderCallback)
	local container = workspace:FindFirstChild("CellDraw")
	
	if not container then
		container = Instance.new("Model", workspace)
		container.Name = "CellDraw"
	end
	
	container:ClearAllChildren()
	
	local air = Enum.Material.Air
	local water = Enum.Material.Water
	
	local lastCellMaterialX
	local lastCellOccupancyX
	
	local materials = { air, air, air, air }
	local occupancies = { 0, 0, 0, 0 }
	
	for x = 1, voxels.Size.X + 1 do
		local cellMaterialX = voxels.MaterialVoxels[x]
		local cellOccupancyX = voxels.OccupancyVoxels[x]
		local cellName = "( "..tostring(x + voxels.Start.X)..", "
		
		local lastCellMaterialY1, lastCellMaterialY2
		local lastCellOccupancyY1, lastCellOccupancyY2
		
		for y = 1, voxels.Size.Y + 1 do
			local cellName = cellName..tostring(y + voxels.Start.Y)..", "
		
			local cellMaterialY1, cellMaterialY2
			local cellOccupancyY1, cellOccupancyY2
			
			cellMaterialY1 = Fetch(cellMaterialX, y)
			cellOccupancyY1 = Fetch(cellOccupancyX, y)
			
			if x > 1 then
				cellMaterialY2 = Fetch(lastCellMaterialX, y)
				cellOccupancyY2 = Fetch(lastCellOccupancyX, y)
			end
				
			materials[1] = air
			materials[2] = air
			materials[3] = air
			materials[4] = air
			
			occupancies[1] = 0
			occupancies[2] = 0
			occupancies[3] = 0
			occupancies[4] = 0
		
			for z = 1, voxels.Size.Z + 1 do
				local cellName = cellName..tostring(z + voxels.Start.Z).." )"
				
				materials[5] = Fetch(cellMaterialY1, z) or air
				occupancies[5] = Fetch(cellOccupancyY1, z) or 0
				
				if x > 1 then
					materials[6] = Fetch(cellMaterialY2, z) or air
					occupancies[6] = Fetch(cellOccupancyY2, z) or 0
					
					if y > 1 then
						materials[7] = Fetch(lastCellMaterialY2, z) or air
						occupancies[7] = Fetch(lastCellOccupancyY2, z) or 0
					end
				else
					materials[6] = air
					materials[7] = air
					
					occupancies[6] = 0
					occupancies[7] = 0
				end
				
				if y > 1 then
					materials[8] = Fetch(lastCellMaterialY1, z) or air
					occupancies[8] = Fetch(lastCellOccupancyY1, z) or 0
				else
					materials[8] = air
					occupancies[8] = 0
				end
				
				if materials[5] == air or materials[5] == water then
					materials[5] = air
					occupancies[5] = 0
				end
				
				if materials[6] == air or materials[6] == water then
					materials[6] = air
					occupancies[6] = 0
				end
				
				if materials[7] == air or materials[7] == water then
					materials[7] = air
					occupancies[7] = 0
				end
				
				if materials[8] == air or materials[8] == water then
					materials[8] = air
					occupancies[8] = 0
				end
				
				local permutation = GetPermutation(materials)
				
				if permutation ~= 0 and permutation ~= 255 then
					renderCallback(container, 4 * (voxels.Start + Vector3.new(x - 1, y - 1, z - 1)), materials, occupancies, permutation, DrawTriangle)
				end
				
				materials[1] = materials[5]
				materials[2] = materials[6]
				materials[3] = materials[7]
				materials[4] = materials[8]
				
				occupancies[1] = occupancies[5]
				occupancies[2] = occupancies[6]
				occupancies[3] = occupancies[7]
				occupancies[4] = occupancies[8]
			end
			
			lastCellMaterialY1, lastCellMaterialY2 = cellMaterialY1, cellMaterialY2
			lastCellOccupancyY1, lastCellOccupancyY2 = cellOccupancyY1, cellOccupancyY2
		end
		
		lastCellMaterialX = cellMaterialX
		lastCellOccupancyX = cellOccupancyX
			
		wait()
	end
end

function Extract(number, bits, position)
	local shift = 2^position
	local mask = 2^bits
	
	return math.floor(number / shift) % mask
end

local materials = {
	Air = 0,
	Grass = 1,
	LeafyGrass = 2,
	Mud = 3,
	Sand = 4,
	Snow = 5,
	Ice = 6,
	Glacier = 7,
	Ground = 8,
	Rock = 9,
	Slate = 10,
	Basalt = 11,
	Salt = 12,
	Sandstone = 13,
	Limestone = 14,
	CrackedLava = 15,
	Concrete = 16,
	Cobblestone = 17,
	Asphalt = 18,
	Pavement = 19,
	Brick = 20,
	WoodPlanks = 21,
	Water = 22
}

local cellBench = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 } -- preallocation
local layerBench = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 } -- preallocation
local chunkBench = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 } -- preallocation
local air = Enum.Material.Air
local water = Enum.Material.Water

function SerializeChunk(position)
	local size = Vector3.new(36, 36, 36)
	
	local voxels = ReadVoxels(position - size, position + size, true)
	
	local colon = (":"):byte()
	local semicolon = (";"):byte()
	
	local shift = 2^8
	local groundFound = false
	local waterFound = false
	
	for x = 2, 18 do
		for y = 2, 18 do
			for z = 2, 18 do
				local material = voxels.MaterialVoxels[x][y][z]
				local occupancy = voxels.OccupancyVoxels[x][y][z]
				
				if material == air then
					occupancy = 0
				else
					groundFound = true
				end
				
				if x < 18 and y < 18 and z < 18 then
					if material ~= air then
						local airNeighborFound = false
						
						for ox = -1, 1 do
							local materialsX = voxels.MaterialVoxels[x - ox]
							
							for oy = -1, 1 do
								local materialsY = materialsX[y - oy]
								
								for oz = -1, 1 do
									local neighborMaterial = materialsY[z - oz]
									
									if material == water and neighborMaterial ~= water then
										neighborMaterial = air
									elseif material ~= water and neighborMaterial == water then
										neighborMaterial = air
									end
									
									if neighborMaterial == air then
										airNeighborFound = true
										
										break
									end
								end
								
								if airNeighborFound then
									break
								end
							end
							
							if airNeighborFound then
								break
							end
						end
						
						if not airNeighborFound then
							material = voxels.MaterialVoxels[x][y][z - 1]
							occupancy = voxels.OccupancyVoxels[x][y][z - 1]
						end
					end
					
					occupancy = math.max(0, math.min(1, occupancy)) * shift
					
					cellBench[z - 1] = string.char(
						32 + materials[material.Name],
						32 + Extract(occupancy, 3, 6),
						32 + Extract(occupancy, 6, 0)
					)
				end
			end
			
			if y < 18 then
				layerBench[y - 1] = ("%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n"):format(unpack(cellBench))
			end
		end
		
		if x < 18 then
			chunkBench[x - 1] = ("%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s"):format(unpack(layerBench))
		end
	end
	
	local chunkCoords = ("%d,%d,%d"):format(math.floor(position.x / 64), math.floor(position.y / 64), math.floor(position.z / 64))
	local chunkData
	
	if groundFound then
		return chunkCoords, ("%s\n%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s"):format(chunkCoords, unpack(chunkBench))
	end
end

function SerializeRegion(minChunk, maxChunk, chunks)
	local min = Vector3.new(math.floor(minChunk.X / 64), math.floor(minChunk.Y / 64), math.floor(minChunk.Z / 64))
	local max = Vector3.new(math.floor(maxChunk.X / 64), math.floor(maxChunk.Y / 64), math.floor(maxChunk.Z / 64))
	local diff = max - min
	local suggestedRange = Vector3.new(math.ceil(diff.X / 2), math.ceil(diff.Y / 2), math.ceil(diff.Z / 2))
	
	print("min chunk:", min)
	print("max chunk:", max)
	print("region size:", diff + Vector3.new(1, 1, 1))
	print("suggested chunk loader range:", suggestedRange)
	print("suggested chunk loader transform position:", 16 * (min + suggestedRange) + Vector3.new(8, 8, 8))
	
	for x = minChunk.X, maxChunk.X + 0.5, 64 do
		for y = minChunk.Y, maxChunk.Y + 0.5, 64 do
			for z = minChunk.Z, maxChunk.Z + 0.5, 64 do
				local name, data = SerializeChunk(Vector3.new(x, y, z))
				
				if name then
					local chunk = Instance.new("ModuleScript", chunks)
					chunk.Name = name
					chunk.Source = data
				end
			end
		end
	end
end

return {
	Round = Round,
	ReadVoxels = ReadVoxels,
	DisplayVoxels = DisplayVoxels,
	PartToRegion = PartToRegion,
	DrawVoxels = DrawVoxels,
	GetPermutation = GetPermutation,
	DrawTriangle = DrawTriangle,
	SerializeChunk = SerializeChunk,
	SerializeRegion = SerializeRegion
}