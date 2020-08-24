return function(collider, drawFaceIndex)
	local container = Instance.new("Part")
	container.Anchored = true
	
	for i, vert in pairs(collider.vertexBuffer) do
		local attach = Instance.new("Attachment", container)
		attach.Position = vert
		attach.Visible = true
		local gui = workspace.Index:clone()
		gui.Parent = attach
		gui.Label.Text = tostring(i)
		
		if collider.originalVertices then
			gui.Label.TextColor3 = collider.originalVertices[i] ~= 0 and Color3.new(0, 1, 0) or (collider.intersection[i] == 0 and Color3.new(1, 1, 1) or Color3.new(0.5, 0.5, 1))
		end
	end
	
	local nodes = container:GetChildren()
	
	for i, face in pairs(collider.faces) do
		local verts = #face.indexBuffer
		local sum = Vector3.new(0, 0, 0)
		local c=Instance.new("Folder",container)
		for j = 1, verts do
			local k = j % verts + 1
			local J = face.indexBuffer[j]
			local K = face.indexBuffer[k]
			
			local edge = Instance.new("RodConstraint")
			edge.Attachment0 = nodes[J]
			edge.Attachment1 = nodes[K]
			edge.Length = edge.CurrentDistance
			edge.Parent = c--container
			edge.Visible = true
			
			sum = sum + collider.vertexBuffer[face.indexBuffer[j]]
			
			if face.originalEdge then
				if face.originalEdge[j] ~= 0 then
			--if collider.originalVertices then
				--if (collider.originalVertices[J] or collider.intersection[J] ~= 0) and (collider.originalVertices[K] or collider.intersection[K] ~= 0) then
					edge.Thickness = 0.15
					edge.Color = BrickColor.new("Royal purple")
				end
			end
		end
		
		if drawFaceIndex then
			local attach = Instance.new("Attachment")
			attach.Position = sum / verts
			attach.Parent = container
			
			local gui = workspace.Index:clone()
			gui.Parent = attach
			gui.Label.Text = tostring(face.inputFace or i)
		end
	end
	
	container.Parent = workspace
	container.Name = "Output"
	
	pcall(function() game.Selection:Set{container} end) -- syntax sugar for Set( { ... } )
	
	return container
end