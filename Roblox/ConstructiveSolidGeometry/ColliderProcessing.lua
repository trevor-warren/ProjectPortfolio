local collider = {
	vertexBuffer = { Vector3.new(0,0,0), ... },
	faces = {
		{
			normal = Vector3.new(0,0,0),
			indexBuffer = { 1, 2, ... } -- lua starts at index 1
		},
		...
	} -- you can use either , or ; for separating table entries
}
 
function print() end -- shut up lua
function findIndex(vertexBuffer, vertex)
	for i,v in pairs(vertexBuffer) do
		local diff = v - vertex
		
		if math.abs(diff.Magnitude) < 1e-4 then
			return i
		end
	end
	
	return #vertexBuffer + 1
end
 
-- need to check vertices for triangle equality
function findFace(faces, face, collider1, collider2)
	local w = face.normal:Dot(  collider2.vertexBuffer[face.indexBuffer[1]]  )
	
	for i,v in pairs(faces) do
		local diff = v.normal - face.normal
		--print(face.indexBuffer[1], collider2.vertexBuffer[face.indexBuffer[1]] )
		if math.abs(diff.Magnitude) < 1e-4 and math.abs(v.normal:Dot( collider2.vertexBuffer[face.indexBuffer[1]] ) - w) < 1e-4 then
			return i
		end
	end
	
	return #faces + 1
end
 
function contain(face, vertex1, vertex2)
	return -face.normal:Dot(vertex1)  + face.normal:Dot(vertex2) <= 0
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             

function find(array, value)
	for i,v in pairs(array) do
		if v == value then
			return true
		end
	end
	
	return false
end

local step = workspace.Step

function ClipObject(collider1, collider2, outputCollider)
	for i,face2 in pairs(collider2.faces) do
		for j,i2 in pairs(face2.indexBuffer) do
			local vertex2 = collider2.vertexBuffer[i2]
			
			local contains = true
			
			for k1,face1 in pairs(collider1.faces) do
				--step.Changed:wait()
				
				contains = contains and contain(face1, collider1.vertexBuffer[face1.indexBuffer[1]], vertex2)
				
				--step.Changed:wait()
				
				if not contains then
					break
				end
			end
			
			--step.Changed:wait()
			
			if contains then
				for k,face1 in pairs(collider1.faces) do
					local xyz1 = face1.normal
					local w1 = -collider1.vertexBuffer[face1.indexBuffer[1]]:Dot(xyz1)
					
					local end0 = xyz1:Dot(collider2.vertexBuffer[i2]) + w1
					
							for m, i3 in pairs(face2.indexBuffer) do
								local end1 = collider2.vertexBuffer[i3]:Dot(xyz1) + w1
								
								if i3 ~= i2 and end1 > 0 then
									local sPQ = end0 / (end0 - end1)
									
									local nv = (1 - sPQ) * collider2.vertexBuffer[i2] + sPQ * collider2.vertexBuffer[i3]
									local n = findIndex(outputCollider.vertexBuffer, nv)--collider2.vertexBuffer[i2])
									
									if n > #outputCollider.vertexBuffer then
										outputCollider.vertexBuffer[#outputCollider.vertexBuffer + 1] = nv

									end
									
									local o = findFace(outputCollider.faces, face1, outputCollider, collider1)
									
									if o > #outputCollider.faces then
										outputCollider.faces[#outputCollider.faces + 1] = {
											normal = face2.normal, -- reconsider normal vector
											indexBuffer = {nv}
										}
									end
									
									local thingy = outputCollider.faces[o].indexBuffer
									
									if find(thingy, n) then
										thingy[#thingy + 1] = n
									end
								end
							end
				end
			else
				for k, face2_2 in pairs(collider2.faces) do
					local hf = findFace(outputCollider.faces, face2_2, outputCollider, collider2)
					
					if hf > #outputCollider.faces then
						outputCollider.faces[#outputCollider.faces + 1] = {
							normal = face2_2.normal, -- reconsider normal vector
							indexBuffer = {}
						}
					end
					
					local l = findIndex(outputCollider.vertexBuffer, collider2.vertexBuffer[i2])
					
					if l > #outputCollider.vertexBuffer then
						outputCollider.vertexBuffer[#outputCollider.vertexBuffer + 1] = collider2.vertexBuffer[i2]
					end
					--print(hf, outputCollider.faces[hf])
					local thingy = outputCollider.faces[hf].indexBuffer
					
					if not find(thingy, l) then
						thingy[#thingy + 1] = l
					end
					
					-- reconsider stuff
				end
			end
		end
	end
end
--[[
function clipTriangle(collider, vertexBuffer, face, normal, planePosition)
	local clipped = { false, false, false }
	
	for _,  i in pairs(face.indexBuffer) do
		local vert = vertexBuffer[i]
		
		if 
	end
end]]
 
function MergeObjects(collider1, collider2)
	local outputCollider = {
		vertexBuffer = {},
		faces = {}
	}
	
	ClipObject(collider1, collider2, outputCollider)
	ClipObject(collider2, collider1, outputCollider)
	
	return outputCollider
end
 
function FilterFaces(navmesh, globalUp, walkable)
	local i = 1
	
	while i <= #navmesh.faces do
		local face = navmesh.faces[i]
		local dot = face.normal:Dot(globalUp)
		local theta = math.acos(dot) print(theta)
		
		if theta > math.rad(walkable) then
			table.remove(navmesh.faces, i)
			print"removing"
		else
			i = i + 1
		end
	end
end

function NewCollider()
	return {
		vertexBuffer = {},
		faces = {}
	}
end

function pushVertex(outputCollider, vert)
	local index = findIndex(outputCollider.vertexBuffer, vert)
	
	if index > #outputCollider.vertexBuffer then
		outputCollider.vertexBuffer[index] = vert
	end
	
	return index
end

function Clean(navmesh)
	local out = NewCollider()
	for i,v in pairs(navmesh.faces) do
		out.faces[#out.faces + 1] = {
			normal = v.normal,
			indexBuffer = {}
		}
		
		for a,c in pairs(v.indexBuffer) do
			out.faces[#out.faces].indexBuffer[a] = pushVertex(out, navmesh.vertexBuffer[c])
		end
	end
	
	return out
end

return {
	MergeObjects = MergeObjects,
	FilterFaces = FilterFaces,
	NewCollider = NewCollider,
	Clean = Clean
}