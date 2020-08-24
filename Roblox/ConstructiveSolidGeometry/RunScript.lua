input1 = workspace.Input3
input2 = workspace.Input4
input3 = workspace.Input5

local model = workspace.Model
local part = model.Part

BoxCollider = require(workspace.BoxCollider)
WedgeCollider = require(workspace.WedgeCollider)
DebugDraw = require(workspace.DebugDraw)
ColliderProcessing = require(workspace.ColliderProcessing)
Merge = require(workspace.ModuleScript)

function GetAABB(input)
	part.CFrame = input.CFrame
	part.Size = input.Size
	
	local size = model:GetExtentsSize()
	
	part.CFrame = CFrame.new(10000,10000,10000)
	
	return input.CFrame.p - 0.5 * size, size
end

function contains(p, s, x)
	print(p, s, x, x >= p and x <= p + s)
	return x >= p and x <= p + s
end

function AABBsColliding(pos1, size1, pos2, size2)
	local pos = pos1 - 0.5 * size2
	local size = size1 + size2
	
	return contains(pos.x, size.x, pos2.x) and contains(pos.y, size.y, pos2.y) and contains(pos.z, size.z, pos2.z)
end

inputs = workspace.Inputs:GetChildren()
aabbs = {}
outputs = {}
colliders = {}

for i,v in pairs(inputs) do
	aabbs[i] = { GetAABB(v) }
	print(aabbs[i][1],aabbs[i][2])
	colliders[i] = v:IsA("Part") and BoxCollider(v.Size, v.CFrame) or WedgeCollider(v.Size, v.CFrame)
end

for i,v in pairs(inputs) do
	local aabb1 = aabbs[i]
	local collider = colliders[i]
	
	for a,c in pairs(inputs) do
		local aabb2 = aabbs[a]
		
		if c ~= v then--and AABBsColliding(aabb1[1], aabb1[2], aabb2[1], aabb2[2]) then
			print(i, a, v, c)
			collider = Merge(collider, colliders[a])
		end
	end
	
	ColliderProcessing.FilterFaces(collider, Vector3.new(0, 1, 0), 45)
	outputs[i] = ColliderProcessing.Clean(collider)
	DebugDraw(outputs[i])
end

--[[collider1 = BoxCollider(input1.Size, input1.CFrame)
collider2 = BoxCollider(input2.Size, input2.CFrame)--BoxCollider(input2.Size, input2.CFrame)
collider3 = WedgeCollider(input3.Size, input3.CFrame)

collider4 = Merge(collider1,collider2)
collider5 = Merge(collider4,collider3)

collider6 = Merge(collider2, collider1)

collider7 = Merge(collider3, collider1)

ColliderProcessing.FilterFaces(collider5, Vector3.new(0, 1, 0), 45)
ColliderProcessing.FilterFaces(collider6, Vector3.new(0, 1, 0), 45)
ColliderProcessing.FilterFaces(collider7, Vector3.new(0, 1, 0), 45)

DebugDraw(ColliderProcessing.Clean(collider5), true)
DebugDraw(ColliderProcessing.Clean(collider6), true)
DebugDraw(ColliderProcessing.Clean(collider7), true)]]
--DebugDraw(collider1, true)
--DebugDraw(collider3)

while true do
	wait()
end