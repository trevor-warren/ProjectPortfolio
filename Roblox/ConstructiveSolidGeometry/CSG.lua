function intersection(normal, planePoint, a, b)
	local dotA = normal:Dot(a) - normal:Dot(planePoint)
	local t = dotA / (dotA + normal:Dot(planePoint) - normal:Dot(b))
	
	return (1 - t) * a + t * b;
end

function print() end -- shut up lua

function compareVectors(vec1, vec2, checkReverse)
	local diff = vec1 - vec2
	local diff2
	
	if checkReverse then
		diff2 = vec1 + vec2
	end
	
	return diff:Dot(diff) < 1e-4 or (checkReverse and diff2:Dot(diff2) < 1e-4)
end

function findIndex(vertexBuffer, vertex)
	for i,v in pairs(vertexBuffer) do
		if compareVectors(v, vertex) then
			return i
		end
	end
	
	return #vertexBuffer + 1
end

function get(collider, face, i)
	return collider.vertexBuffer[face.indexBuffer[i]]
end

function getBuffer(vertexBuffer, face, i)
	return vertexBuffer[face.indexBuffer[i]]
end

function findFace(faces, face, collider1, collider2)
	local w = face.normal:Dot(  get(collider2, face, 1)  )
	
	for i,v in pairs(faces) do
		if compareVectors(v.normal, face.normal) and math.abs(v.normal:Dot(get(collider1, v, 1)) - v.normal:Dot(get(collider2, face, 1))) < 1e-4 then
			local a = get(collider1, v, 1)
			local b = get(collider1, v, 2)
			local c = get(collider1, v, 3)
			
			local A = get(collider2, face, 1)
			local B = get(collider2, face, 2)
			local C = get(collider2, face, 3)
			
			local matched = false
			
			if compareVectors(a, A) then
				matched = compareVectors(b, B) and compareVectors(c, C)
			elseif compareVectors(b, A) then
				matched = compareVectors(c, B) and compareVectors(a, C)
			elseif compareVectors(c, A) then
				matched = compareVectors(a, B) and compareVectors(b, C)
			end
			
			if matched then
				return i
			end
		end
	end
	
	return #faces + 1
end

function clip(normal, planePoint, source, destination, originalVertices, originalVerticesOut)
	if #source == 0 then
		return false
	end
	
	local w = -normal:Dot(planePoint)
	local lastWasClipped = normal:Dot(source[1]) + w > 0
	local intersects = not lastWasClipped
	
	for i=1,#source do
		local j = (i % #source) + 1
		local clipVertex = normal:Dot(source[j]) + w > 0
		
		intersects = intersects or not clipVertex
		
		if clipVertex ~= lastWasClipped then
			local point = intersection(normal, planePoint, source[i], source[j])
			local k = findIndex(destination, point)
			
			if k > #destination then
				destination[k] = point
				originalVerticesOut[#originalVerticesOut + 1] = compareVectors(point, source[j]) and originalVertices[j] or 0
			end
		end
		
		if not clipVertex then
			local k = findIndex(destination, source[j])
			
			if k > #destination then
				destination[#destination + 1] = source[j]
				originalVerticesOut[#originalVerticesOut + 1] = originalVertices[j]
			end
		end
		
		lastWasClipped = clipVertex
	end
	
	return intersects
end

function clipTriangle(collider, source)
	local output = source
	local destination = {}
	local originalVertices = { 1, 2, 3 }
	local originalVerticesOut = {}
	local intersects = false
	
	for i, face in pairs(collider.faces) do
		local intersected = clip(face.normal, collider.vertexBuffer[face.indexBuffer[1]], output, destination, originalVertices, originalVerticesOut)
		intersects = intersects or intersected
		output = destination
		destination = {}
		originalVertices = originalVerticesOut
		originalVerticesOut = {}
	end
	
	return output, intersects, originalVertices
end

function compareEdges(input, ab, ac, bc, p, a, b, c)
	local vec = (p - a).unit
	if compareVectors(input, ab, true) and compareVectors(vec, ab, true) then
		return 1
	elseif compareVectors(input, ac, true) and compareVectors(vec, ac, true) then
		return 3
	elseif compareVectors(input, bc, true) and compareVectors((p - b).unit, bc, true) then
		return 2
	end
	
	return 0
end

function xor(a, b)
	return (a or b) and a ~= b
end

function pushVertex(outputCollider, vert)
	local index = findIndex(outputCollider.vertexBuffer, vert)
	
	if index > #outputCollider.vertexBuffer then
		outputCollider.vertexBuffer[index] = vert
	end
	
	return index
end

function addFace(outputCollider, a, b, c)
	local face = {
		normal = (b - a):Cross(c - a).unit,
		indexBuffer = { pushVertex(outputCollider, a), pushVertex(outputCollider, b), pushVertex(outputCollider, c) }
	}
	
	outputCollider.faces[#outputCollider.faces + 1] = face
end

function processOutput(outputCollider, outputVertices, originalVertices, buffer, vertexBuffer, inputFace, faceIndex, a, b, c, ab, ac, bc)
	local intersections = {}
	
	for i, vert in pairs(outputVertices) do
		local j = findIndex(outputCollider.vertexBuffer, vert)
		
		if j > #outputCollider.vertexBuffer then
			outputCollider.vertexBuffer[j] = vert
		end
		
		local current = outputCollider.originalVertices[j]
		
		if current == nil then
			current = 0
		end
		
		outputCollider.originalVertices[j] = current ~= 0 and current or originalVertices[i]
		buffer[i] = j
		
		local intersection = 0
		
		if outputCollider.originalVertices[j] == 0 then
			local vec = (vert - a).unit
			
			if compareVectors(vec, ab) then
				intersection = 1
			elseif compareVectors(vec, ac) then
				intersection = 3
			elseif compareVectors((vert - b).unit, bc) then
				intersection = 2
			end
		else
			intersection = outputCollider.originalVertices[j]
		end
		
		outputCollider.intersection[j] = intersection
		intersections[i] = intersection
	end
	
	for i,v in pairs(intersections) do
		local j = i % #intersections + 1
		
		if v ~= 0 and intersections[j] == 0 then
			local rangeStart = i
			
			local k = j
			local length = 0
			
			while intersections[k] == 0 do
				k = k % #intersections + 1
				length = length + 1
			end
			
			local vertStart = intersections[rangeStart] % 3 + 1
			local vertEnd = intersections[k]
			
			if originalVertices[k] ~= 0 then
				vertEnd = vertEnd - 1
				
				if vertEnd == 0 then
					vertEnd = 3
				end
			end
			
			print("range:", rangeStart, k, "face:", faceIndex)
			print("index range:", vertStart, vertEnd)
			
			local lastProcessedIndex = rangeStart
			local intersectionIndex = rangeStart % #intersections + 1
			local vertIndex = vertStart
			local processedLastVertex = false
			local vertex = vertexBuffer[inputFace.indexBuffer[vertIndex]]
			local lastProcessedVert = vertIndex
			
			while not processedLastVertex and intersectionIndex ~= k do
				print("checking intersection:", intersectionIndex)
				local previous = intersectionIndex - 1
				local next = intersectionIndex % #intersections + 1
				
				if previous == 0 then
					previous = #intersections
				end
				
				local corner = outputVertices[intersectionIndex]
				local normal1 = (corner - outputVertices[previous]):Cross(inputFace.normal)
				local normal2 = (outputVertices[next] - corner):Cross(inputFace.normal)
				
				print("normal 1:", normal1, "\nnormal 2:", normal2)
				
				print("create triangle:", intersectionIndex, "(int)", lastProcessedIndex, "(int)", lastProcessedVert, "(vert)")
				addFace(outputCollider,
					outputVertices[intersectionIndex],
					outputVertices[lastProcessedIndex],
					getBuffer(vertexBuffer, inputFace, lastProcessedVert)
				)
				
				while not processedLastVertex and ((vertex - corner):Dot(normal1) > 0 or (vertex - corner):Dot(normal2) > 0) do
					print("processed vert:", vertIndex)
					
					if lastProcessedVert ~= vertIndex then
						print("create triangle:", intersectionIndex, "(int)", lastProcessedVert, "(vert)", vertIndex, "(vert)")
						addFace(outputCollider,
							outputVertices[intersectionIndex],
							getBuffer(vertexBuffer, inputFace, lastProcessedVert),
							getBuffer(vertexBuffer, inputFace, vertIndex)
						)
					end
					
					processedLastVertex = vertIndex == vertEnd
					
					lastProcessedVert = vertIndex
					vertIndex = vertIndex % 3 + 1
					vertex = vertexBuffer[inputFace.indexBuffer[vertIndex]]
				end
				
				lastProcessedIndex = intersectionIndex
				intersectionIndex = intersectionIndex % #intersections + 1
				
				print("create triangle:", intersectionIndex, "(int)", lastProcessedIndex, "(int)", lastProcessedVert, "(vert)")
				local finalIndex = k - 1
				if finalIndex == 0 then
					finalIndex = #intersections
				end
				addFace(outputCollider,
					outputVertices[k],
					outputVertices[finalIndex],
					getBuffer(vertexBuffer, inputFace, vertEnd)
				)
			end
			print("create triangle:", intersectionIndex, "(int)", lastProcessedIndex, "(int)", lastProcessedVert, "(vert)")
			addFace(outputCollider,
				outputVertices[intersectionIndex],
				outputVertices[lastProcessedIndex],
				getBuffer(vertexBuffer, inputFace, lastProcessedVert)
			)
		elseif intersections[i] ~= 0 and intersections[j] ~= 0 then
			if not (originalVertices[i] ~= 0 and  originalVertices[j] ~= 0) then
				if originalVertices[i] == 0 and originalVertices[j] == 0 then
					if intersections[i] ~= intersections[j] then
						print("range:", i, j, "face:", faceIndex)
						local corner = intersections[i] % 3 + 1
						if corner == intersections[j] then
							print("create triangle:", j, "(int)", i, "(int)", intersections[j], "(vert)")
							addFace(outputCollider,
								outputVertices[j],
								outputVertices[i],
								getBuffer(vertexBuffer, inputFace, intersections[j])
							)
						else
							print("create triangle:", j, "(int)", i, "(int)", corner, "(vert)")
							print("create triangle:", j, "(int)", corner, "(vert)", intersections[j], "(vert)")
							addFace(outputCollider,
								outputVertices[j],
								outputVertices[i],
								getBuffer(vertexBuffer, inputFace, corner)
							)
							addFace(outputCollider,
								outputVertices[j],
								getBuffer(vertexBuffer, inputFace, corner),
								getBuffer(vertexBuffer, inputFace, intersections[j])
							)
						end
					end
				elseif originalVertices[i] ~= 0 and originalVertices[i] ~= intersections[j] then
					print("range:", i, j, "face:", faceIndex)
					print("create triangle:", originalVertices[i], "(vert)", originalVertices[i] % 3 + 1, "(vert)", intersections[j], "(int)")
					addFace(outputCollider,
						getBuffer(vertexBuffer, inputFace, originalVertices[i]),
						getBuffer(vertexBuffer, inputFace, originalVertices[i] % 3 + 1),
						outputVertices[j]
					)
				elseif originalVertices[j] ~= 0 and originalVertices[j] ~= (intersections[i] % 3 + 1) then
					print("range:", i, j, "face:", faceIndex)
					print("create triangle:", intersections[i], "(int)", intersections[i] % 3 + 1, "(vert)", originalVertices[j], "(vert)")
					addFace(outputCollider,
						outputVertices[i],
						getBuffer(vertexBuffer, inputFace, intersections[i] % 3 + 1),
						getBuffer(vertexBuffer, inputFace, originalVertices[j])
					)
				end
			end
		end
	end
	
	--[=[for i = 1, #outputVertices - 2 do
		local face = {
			inputFace = faceIndex,
			indexBuffer = { buffer[i], buffer[i + 1], buffer[#outputVertices] },
			originalEdge = { 0, 0, 0 }
		}
		
		local a2 = outputCollider.vertexBuffer[face.indexBuffer[1]]
		local b2 = outputCollider.vertexBuffer[face.indexBuffer[2]]
		local c2 = outputCollider.vertexBuffer[face.indexBuffer[3]]
		
		face.originalEdge[1] = compareEdges((b2 - a2).unit, ab, ac, bc, b2, a, b, c)
		face.originalEdge[3] = compareEdges((c2 - a2).unit, ab, ac, bc, c2, a, b, c)
		face.originalEdge[2] = compareEdges((c2 - b2).unit, ab, ac, bc, c2, a, b, c)
		
		face.normal = (b2 - a2):Cross(c2 - a2).unit
		
		local j = findFace(outputCollider.faces, face, outputCollider, outputCollider)
		
		if j > #outputCollider.faces then
			outputCollider.faces[j] = face
		end
	end]=]
end

function calculateColliderIntersection(collider1, collider2, outputCollider, buffer)
	local vertexBuffer1 = collider1.vertexBuffer
	
	for faceIndex, face in pairs(collider1.faces) do
		local indexBuffer = face.indexBuffer
		local a = vertexBuffer1[indexBuffer[1]]
		local b = vertexBuffer1[indexBuffer[2]]
		local c = vertexBuffer1[indexBuffer[3]]
		local outputVertices, intersects, originalVertices = clipTriangle(collider2, { a, b, c })
		
		if #outputVertices > 1 then
			local ab = (b - a).unit
			local ac = (c - a).unit
			local bc = (c - b).unit
			
			local intersections = 0
			local originalVertexCount = 0
			local sum = Vector3.new(0, 0, 0)
			
			local intersectionA = 0
			local intersectionB = 0
			local originalVertex = 0
			
			for i, vert in pairs(outputVertices) do
				local j = findIndex(outputCollider.vertexBuffer, vert)
				local current = outputCollider.originalVertices[j]
				
				local intersected = true
				
				if current == nil then
					current = 0
				end
				
				if current ~= 0 or originalVertices[i] ~= 0 then
					originalVertexCount = originalVertexCount + 1
				end
				
				if originalVertices[i] ~= 0 then
					originalVertex = originalVertices[i]
				end
				
				if current == 0 and originalVertices[i] == 0 then
					local intersection = 0
					local vec = (vert - a).unit
					
					if compareVectors(vec, ab) then
						intersection = 1
					elseif compareVectors(vec, ac) then
						intersection = 3
					elseif compareVectors((vert - b).unit, bc) then
						intersection = 2
					end
					
					intersected = intersection ~= 0
					
					if i == 1 then
						intersectionA = intersection
					elseif i == 2 then
						intersectionB = intersection
					end
				end
				
				if intersected then
					intersections = intersections + 1
				end
				
				sum = sum + vert
			end
			
			local processClipping = true
			
			if #outputVertices == 2 then
				if originalVertexCount == 2 then
					processClipping = false
				elseif originalVertexCount == 0 then
					processClipping = intersectionA ~= intersectionB
				else
					local intersection = intersectionA == 0 and intersectionB or intersectionA
					processClipping = not intersection == originalVertex and not (intersection % 3 + 1) == originalVertex
				end
			end
			
			if originalVertexCount ~= 3 then
				if processClipping then
					if intersections == 0 then
						local centroid = sum / #outputVertices
						local normal = face.normal:Cross(bc)
						local vector = centroid - a
						local d = a + (normal:Dot(b) - normal:Dot(a)) / normal:Dot(vector) * vector
						local vec = (d - a).unit
						local outputVertices1, intersects1, originalVertices1 = clipTriangle(collider2, { a, b, d })
						local outputVertices2, intersects2, originalVertices2 = clipTriangle(collider2, { a, d, c })
						
						processOutput(outputCollider, outputVertices1, originalVertices1, buffer, vertexBuffer1, face, faceIndex, a, b, d, ab, vec, (d - b).unit)
						processOutput(outputCollider, outputVertices2, originalVertices2, buffer, vertexBuffer1, face, faceIndex, a, d, c, vec, ac, (c - d).unit)
						print("helloooooooo")
					else
						processOutput(outputCollider, outputVertices, originalVertices, buffer, vertexBuffer1, face, faceIndex, a, b, c, ab, ac, bc)
					end
				else
					addFace(outputCollider,
						get(collider1, face, 1),
						get(collider1, face, 2),
						get(collider1, face, 3)
					)
				end
			else
				print"culled whole face"
			end
		else
			addFace(outputCollider,
				get(collider1, face, 1),
				get(collider1, face, 2),
				get(collider1, face, 3)
			)
		end
	end
end

function calculateIntersection(collider1, collider2)
	local outputCollider = {
		vertexBuffer = {},
		originalVertices = {},
		intersection = {},
		faces = {}
	}
	local buffer = {}
	
	calculateColliderIntersection(collider1, collider2, outputCollider, buffer)
	--calculateColliderIntersection(collider2, collider1, outputCollider, buffer)
	
	return outputCollider
end

return calculateIntersection