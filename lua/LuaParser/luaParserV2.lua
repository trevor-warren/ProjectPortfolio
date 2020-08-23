local source = [====[
]====]

local stack = {
	{
		id = -1,
		name = "script",
		graph = ""
	}
}

local nodeID = 0

function topGraph()
	return stack[#stack].graph
end

function pop(success)
	local previousTop = stack[#stack]

	stack[#stack] = nil

	local stackTop = stack[#stack]

	if success then
		stackTop.graph = ('%s\n%s'):format(stackTop.graph, previousTop.graph)
	end

	return success
end

function push(label)
	local id = nodeID
	local name = tostring(nodeID)

	nodeID = nodeID + 1

	local stackTop = stack[#stack]
	local newNode = 
	{
		id = id,
		name = name,
		graph = ('\t"%s" -> "%s"\n\t"%s" [label = "%s"]'):format(stackTop.name, name, name, label:gsub('"','\\"'))
	}

	stack[#stack + 1] = newNode

	return tostring(id)
end

function append(label)
	local id = nodeID
	local name = tostring(id)

	nodeID = nodeID + 1

	local stackTop = stack[#stack]

	stackTop.graph = ('%s\n\t"%s" -> "%s"\n\t"%s" [label = "%s"]'):format(stackTop.graph, stackTop.name, name, name, label:gsub('"','\\"'))
end

local parser = {
	index = 1,
	source = source
}

function parser.Expect(this, index, graph, input)
	if graph == nil then
		error("graph not given\n" .. debug.traceback())
	end

	if not input then
		stack[#stack].graph = graph
		this.index = index
	end

	return input
end

function a_z(character)
	return character ~= nil and character >= 65 and character <= 90
end

function A_Z(character)
	return character ~= nil and character >= 97 and character <= 122
end

function Underscore(character)
	return character ~= nil and character == 95
end

function Numeral(character)
	return character ~= nil and character >= 48 and character <= 57
end
function parser.SkipComment(this, character)
	if character == 45 and this.source:byte(this.index + 1, this.index + 1) == 45 then
		this.index = this.index + 2

		if this.source:byte(this.index, this.index) == 91 then
			local equalsCount = 0

			this.index = this.index + 1

			while this.source:byte(this.index, this.index) == 61 do
				this.index = this.index + 1
				equalsCount = equalsCount + 1
			end

			if this.source:byte(this.index, this.index) == 91 then
				local commentClosed = false
				local closingEquals = -1
				local character

				this.index = this.index + 1

				repeat
					character = this.source:byte(this.index, this.index)
					this.index = this.index + 1

					if character == 93 then
						if closingEquals == -1 then
							closingEquals = 0
						elseif closingEquals == equalsCount then
							commentClosed = true
						else
							closingEquals = -1
						end
					elseif character == 61 and closingEquals ~= -1 then
						closingEquals = closingEquals + 1
					elseif character == nil then
						return false
					else
						closingEquals = -1
					end
				until commentClosed

				this.index = this.index - 1
			else
				repeat
					character = this.source:byte(this.index, this.index)

					this.index = this.index + 1
				until character == 10 or character == 12 or character == 13 or character == nil
      this.index = this.index - 1
			end
		else
			repeat
				character = this.source:byte(this.index, this.index)

				this.index = this.index + 1
			until character == 10 or character == 12 or character == 13 or character == nil

      this.index = this.index - 1
		end

		return true
	end

	return false
end

function parser.SkipWhitespace(this)
	local character = this.source:byte(this.index, this.index)

	while character == 32 or character == 9 or character == 12 or character == 13 or character == 10 or this:SkipComment(character) do
		this.index = this.index + 1
		character = this.source:byte(this.index, this.index)
	end
end

function parser.Succeeded(this, ruleType)
	this.lastType = ruleType
end

function parser.LiteralString(this)
	push("LiteralString")

	this:SkipWhitespace()

	local character = this.source:byte(this.index, this.index)
	local startIndex = this.index
	local graph = topGraph()

	if character == 34 or character == 39 then
		local opener = character
		local escaped = false

		repeat
			this.index = this.index + 1
			character = this.source:byte(this.index, this.index)
			escaped = not escaped and character == 92

			if character == nil then
				return pop(false)
			end
		until not escaped and character == opener

		this.index = this.index + 1
	elseif this.source:byte(this.index, this.index) == 91 then
		local equalsCount = 0

		this.index = this.index + 1

		while this.source:byte(this.index, this.index) == 61 do
			this.index = this.index + 1
			equalsCount = equalsCount + 1
		end

		if this.source:byte(this.index, this.index) == 91 then
			local stringClosed = false
			local closingEquals = -1
			local character

			this.index = this.index + 1

			repeat
				character = this.source:byte(this.index, this.index)
				this.index = this.index + 1

				if character == 93 then
					if closingEquals == -1 then
						closingEquals = 0
					elseif closingEquals == equalsCount then
						stringClosed = true
					else
						closingEquals = -1
					end
				elseif character == 61 and closingEquals ~= -1 then
					closingEquals = closingEquals + 1
				elseif character == nil then
					return pop(false)
				else
					closingEquals = -1
				end
			until stringClosed
		else
			return pop(false)
		end
	else
		return pop(false)
	end

	append(this.source:sub(startIndex, this.index - 1))

	this:Succeeded("LiteralString")

	return pop(true)
end

local keywords = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["goto"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true
}

function parser.Name(this)
	push("Name")

	this:SkipWhitespace()

	local character = this.source:byte(this.index, this.index)
	local startIndex = this.index
	local graph = topGraph()

	if a_z(character) or A_Z(character) or Underscore(character) then
		repeat
			this.index = this.index + 1
			character = this.source:byte(this.index, this.index)
		until not a_z(character) and not A_Z(character) and not Underscore(character) and not Numeral(character)
	else
		return pop(false)
	end

	local name = this.source:sub(startIndex, this.index - 1)

	if keywords[name] then
		return pop(false)
	end

	append(name)

	this:Succeeded("Name")

	return pop(true)
end

function parser.Numeral(this)
	push("Numeral")

	this:SkipWhitespace()

	local character = this.source:byte(this.index, this.index)
	local startIndex = this.index
	local graph = topGraph()

	if Numeral(character) or character == 46 then
		if Numeral(character) then
			repeat
				this.index = this.index + 1
				character = this.source:byte(this.index, this.index)
			until not Numeral(character)

			if character == 46 then
				this.index = this.index + 1
				character = this.source:byte(this.index, this.index)

				while Numeral(character) do
					this.index = this.index + 1
					character = this.source:byte(this.index, this.index)
				end
			end

			if character == 69 or character == 101 then
				this.index = this.index + 1
				character = this.source:byte(this.index, this.index)

				if character == 45 then
					this.index = this.index + 1
					character = this.source:byte(this.index, this.index)
				end

				repeat
					this.index = this.index + 1
					character = this.source:byte(this.index, this.index)
				until not Numeral(character)
			end
		else
			this.index = this.index + 1
			character = this.source:byte(this.index, this.index)

			repeat
				this.index = this.index + 1
				character = this.source:byte(this.index, this.index)
			until not Numeral(character)

			if character == 69 or character == 101 then
				this.index = this.index + 1
				character = this.source:byte(this.index, this.index)

				if character == 45 then
					this.index = this.index + 1
					character = this.source:byte(this.index, this.index)
				end

				repeat
					this.index = this.index + 1
					character = this.source:byte(this.index, this.index)
				until not Numeral(character)
			end
		end
	else
		return pop(false)
	end
	
	append(this.source:sub(startIndex, this.index - 1))

	this:Succeeded("Numeral")

	return pop(true)
end

function parser.Token(this, token, alphanumerical)
	push(token)

	this:SkipWhitespace()
	
	local index = this.index
	local graph = topGraph()
  local length = #token

  if alphanumerical then
    local character = this.source:byte(index, index)

    length = 0

    while length <= #token and (a_z(character) or A_Z(character) or Underscore(character) or Numeral(character)) do
			length = length + 1
			character = this.source:byte(index + length, index + length)
		end
  end

	if this.source:sub(index, index + length - 1) ~= token then
		return pop(false)
	end

	this.index = this.index + #token
	this:Succeeded("Token")

	return pop(true)
end

function parser.UnOp(this)
	push("UnOp")

	local index = this.index
	local graph = topGraph()

	if (
		this:Token("-") or
		this:Token("not", true) or
		this:Token("#") or
		this:Token("~")
	) then
		this:UnOp()
	elseif not this:Expect(index, graph, this:CarotOp()) then
		return pop(false)
	end

	this:Succeeded("UnOp")

	return pop(true)
end

function parser.FieldSep(this)
	push("FieldSep")

	local index = this.index
		local graph = topGraph()

	if not this:Token(",") and not this:Token(";") then
		return pop(false)
	end

	this:Succeeded("FieldSep")

	return pop(true)
end

function parser.Field(this)
	push("Field")

	local index = this.index
	local graph = topGraph()

	this:Expect(index, graph,
		(
			this:Expect(index, graph,
				this:Token("[") and
				this:Exp() and
				this:Token("]")
			) or
			this:Name()
		) and
		this:Token("=")
	)

	if not this:Expect(index, graph, this:Exp()) then
		return pop(false)
	end

	this:Succeeded("Field")

	return pop(true)
end

function parser.FieldList(this)
	push("FieldList")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:Field()) then
		return pop(false)
	end

	while this:FieldSep() do
		this:Field()
	end

	this:Succeeded("FieldList")

	return pop(true)
end

function parser.TableConstructor(this)
	push("TableConstructor")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:Token("{") and (this:FieldList() or true) and this:Token("}")) then
		return pop(false)
	end

	this:Succeeded("TableConstructor")

	return pop(true)
end

function parser.ParList(this)
	push("ParList")

	local index = this.index
	local graph = topGraph()

	if not this:Token("...") and this:ParamList() then
		if this:Token(",") and not this:Expect(index, graph, this:Token("...")) then
			return pop(false)
		end
	end

	this:Succeeded("ParList")

	return pop(true)
end

function parser.FuncBody(this)
	push("FuncBody")

	local index = this.index
	local graph = topGraph()

	if this:Expect(index, graph, this:Token("(")) then
		this:Expect(this.index, topGraph(), this:ParList())

		if not (
			this:Token(")") and
			this:Block() and
			this:Token("end", true)
		) then
			return pop(false)
		end
	else
		return pop(false)
	end

	this:Succeeded("FuncBody")

	return pop(true)
end

function parser.FunctionDef(this)
	push("FunctionDef")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:Token("function", true) and this:FuncBody()) then
		return pop(false)
	end

	this:Succeeded("FunctionDef")

	return pop(true)
end

function parser.Args(this)
	push("Args")

	local index = this.index
		local graph = topGraph()

	if not this:Expect(index, graph,
		this:Expect(index, graph, this:TableConstructor()) or
		this:LiteralString()
	) then
		local index2 = this.index
		local graph2 = topGraph()
		if not this:Expect(index, graph,
			this:Token("(") and (
				this:Token(")") or this:Expect(this.index, graph,
					this:Expect(index, graph, this:ExpList()) and
					this:Token(")")
				)
			)
		) then
			return pop(false)
		end
	end

	this:Succeeded("Args")

	return pop(true)
end

function parser.Prefix(this)
	push("Prefix")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:Name()) and not this:Expect(index, graph,
		this:Token("(") and
		this:Exp() and
		this:Token(")")
	) then
		return pop(false)
	end

	this:Succeeded("Prefix")

	return pop(true)
end

function parser.Index(this)
	push("Index")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph,
		this:Expect(index, graph,
			this:Token("[") and
			this:Exp() and
			this:Token("]")
		) or
		(
			this:Token(".") and
			this:Name()
		)
	) then
		return pop(false)
	end

	this:Succeeded("Index")

	return pop(true)
end

function parser.Call(this)
	push("Call")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph,
		this:Args() or (
			this:Token(":") and
			this:Name() and
			this:Args()
		)
	) then
		return pop(false)
	end

	this:Succeeded("Call")

	return pop(true)
end

function parser.FunctionCall(this)
	push("FunctionCall")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:Prefix()) then
		return pop(false)
	end

	local passed = false
	local continue = false
	local ignore = -1

	while this:Args() or this:Index() or this:Call() do
		passed = true
	end

	if not this:Expect(index, graph, passed) then
		return pop(false)
	end

	this:Succeeded("FunctionCall")
	
	return pop(true)
end

function parser.Value(this)
	push("Value")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph,
		this:Token("nil", true) or
		this:Token("false", true) or
		this:Token("true", true) or
		this:Token("...") or
		this:Numeral() or
		this:LiteralString() or
		this:Token("...") or
		this:Expect(index, graph, this:FunctionDef()) or
		this:Expect(index, graph, this:FunctionCall()) or
		this:Expect(index, graph, this:TableConstructor()) or
		this:Expect(index, graph, this:Var(true))
	) then
		return pop(false)
	end

	this:Succeeded("Value")

	return pop(true)
end

function parser.Grouping(this)
	push("Grouping")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:Value()) then
		if not this:Expect(index, graph,this:Token("(") and this:Exp() and this:Token(")")) then
			return pop(false)
		end
	end

	this:Succeeded("Grouping")

	return pop(true)
end

function parser.CarotOp(this)
	push("CarotOp")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:Grouping()) then
		return pop(false)
	end

	if this:Token("^") and not this:Expect(index, graph, this:CarotOp()) then
		return pop(false)
	end

	this:Succeeded("CarotOp")

	return pop(true)
end

function parser.MultOp(this)
	push("MultOp")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:UnOp()) then
		return pop(false)
	end

	while this:Token("*") or this:Token("//") or this:Token("/") or this:Token("%") do
		if not this:Expect(index, graph, this:UnOp()) then
			return pop(false)
		end
	end

	this:Succeeded("MultOp")

	return pop(true)
end

function parser.AddOp(this)
	push("AddOp")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:MultOp()) then
		return pop(false)
	end

	while this:Token("+") or this:Token("-") do
		if not this:Expect(index, graph, this:MultOp()) then
			return pop(false)
		end
	end

	this:Succeeded("AddOp")

	return pop(true)
end

function parser.ConcatOp(this)
	push("ConcatOp")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:AddOp()) then
		return pop(false)
	end

	if this:Token("..") and not this:Expect(index, graph, this:ConcatOp()) then
		return pop(false)
	end

	this:Succeeded("ConcatOp")

	return pop(true)
end

function parser.BitShiftOp(this)
	push("BitShiftOp")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:ConcatOp()) then
		return pop(false)
	end

	while this:Token("<<") or this:Token(">>") do
		if not this:Expect(index, graph, this:ConcatOp()) then
			return pop(false)
		end
	end

	this:Succeeded("BitShiftOp")

	return pop(true)
end

function parser.BitAndOp(this)
	push("BitAndOp")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:BitShiftOp()) then
		return pop(false)
	end

	while this:Token("&") do
		if not this:Expect(index, graph, this:BitShiftOp()) then
			return pop(false)
		end
	end

	this:Succeeded("BitAndOp")

	return pop(true)
end

function parser.BitXorOp(this)
	push("BitXorOp")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:BitAndOp()) then
		return pop(false)
	end

	local index2 = this.index
	local graph2 = topGraph()

	while this:Expect(index2, graph2, not this:Token("~=") and this:Token("~")) do
		if not this:Expect(index, graph, this:BitAndOp()) then
			return pop(false)
		end
	end

	this:Succeeded("BitXorOp")

	return pop(true)
end

function parser.BitOrOp(this)
	push("BitOrOp")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:BitXorOp()) then
		return pop(false)
	end

	while this:Token("|") do
		if not this:Expect(index, graph, this:BitXorOp()) then
			return pop(false)
		end
	end

	this:Succeeded("BitOrOp")

	return pop(true)
end

function parser.CompOp(this)
	push("CompOp")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:BitOrOp()) then
		return pop(false)
	end

	while this:Token("<=") or this:Token(">=") or this:Token("<") or this:Token(">") or this:Token("~=") or this:Token("==") do
		if not this:Expect(index, graph, this:BitOrOp()) then
			return pop(false)
		end
	end

	this:Succeeded("CompOp")

	return pop(true)
end

function parser.AndOp(this)
	push("AndOp")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:CompOp()) then
		return pop(false)
	end

	while this:Token("and", true) do
		if not this:Expect(index, graph, this:CompOp()) then
			return pop(false)
		end
	end

	this:Succeeded("AndOp")

	return pop(true)
end

function parser.Exp(this)
	push("Exp")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:AndOp()) then
		return pop(false)
	end

	while this:Token("or", true) do
		if not this:Expect(index, graph, this:AndOp()) then
			return pop(false)
		end
	end

	this:Succeeded("Exp")

	return pop(true)
end

function parser.ExpList(this)
	push("ExpList")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:Exp()) then
		return pop(false)
	end

	while this:Token(",") do
		if not this:Expect(index, graph, this:Exp()) then
			return pop(false)
		end
	end

	this:Succeeded("ExpList")

	return pop(true)
end

function parser.NameList(this)
	push("NameList")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:Name()) then
		return pop(false)
	end

	while this:Token(",") do
		if not this:Expect(index, graph, this:Name()) then
			return pop(false)
		end
	end

	this:Succeeded("NameList")

	return pop(true)
end

function parser.ParamList(this)
	push("NameList")

	local index = this.index
	local graph = topGraph()

	if not this:Token("...") then
		if this:Name() then
			while this:Token(",") do
				if this:Token("...") then
					break
				elseif not this:Expect(index, graph, this:Name()) then
					return pop(false)
				end
			end
		end
	end

	this:Succeeded("NameList")

	return pop(true)
end

function parser.Var(this, indexOptional)
	push("Var")

	local index = this.index
	local graph = topGraph()

	if this:Prefix() then
		while this:Args() or this:Index() or this:Call() do end

		if not this:Expect(index, graph, indexOptional or this.lastType == "Index" or this:Index()) and not this:Expect(index, graph, this:Name()) then
			return pop(false)
		end
	elseif not this:Expect(index, graph, this:Name()) then
		return pop(false)
	end

	this:Succeeded("Var")

	return pop(true)
end

function parser.VarList(this)
	push("VarList")

	local index = this.index
		local graph = topGraph()

	if this:Expect(index, graph, this:Var(false)) then
		while this:Token(",") do
			if not this:Expect(index, graph, this:Var(false)) then print"varlist faile1"
				return pop(false)
			end
		end

		this:Succeeded("VarList")

		return pop(true)
	end

	return pop(false)
end

function parser.FuncName(this)
	push("FuncName")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph, this:Name()) then
		return pop(false)
	end

	while this:Token(".") do
		if not this:Expect(index, graph, this:Name()) then
			return pop(false)
		end
	end

	if this:Token(":") then
		if not this:Expect(index, graph, this:Name()) then
			return pop(false)
		end
	end

	this:Succeeded("FuncName")

	return pop(true)
end

function parser.Label(this)
	push("Label")

	local graph = topGraph()

	if this:Expect(this.index, graph, this:Token("::") and this:Name() and this:Token("::")) then
		this:Succeeded("Label")

		return pop(true)
	end

	return pop(false)
end

function parser.Stat(this)
	push("Stat")

	local startIndex = this.index
	local graph = topGraph()

	if this:Token(";") then
	elseif this:Token("local", true) then
		local isFunction = this:Token("function", true)

		if this:Expect(startIndex, graph, isFunction or this:NameList()) then
			if isFunction then
				if not (this:Expect(startIndex, graph, this:Name()) and this:Expect(startIndex, graph, this:FuncBody())) then
					return pop(false)
				end
			else -- lastType = namelist
				this:Expect(this.index, graph, this:Token("=") and this:ExpList())
			end
		end
	elseif this:Token("function", true) then
		if not (this:Expect(startIndex, graph, this:FuncName() and this:FuncBody())) then
			return pop(false)
		end
	elseif this:Token("for", true) then
		local index = this.index
		local graph2 = topGraph()
		local continue = this:Expect(index, graph2,
			this:Name() and
			this:Token("=") and
			this:Exp() and
			this:Token(",") and
			this:Exp()
		)
		this:Expect(this.index, graph2, continue and (not this:Token(",") or this:Exp()))

		if not continue then
			continue = this:Expect(index, graph2,
				this:NameList() and
				this:Token("in", true) and
				this:ExpList()
			)
		end

		if not this:Expect(startIndex, graph,
			continue and this:Expect(startIndex, graph,
				this:Token("do", true) and
				this:Block() and
				this:Token("end", true)
			)
		) then
			return pop(false)
		end
	elseif this:Token("if", true) then
		if this:Expect(startIndex, graph,
			this:Exp() and
			this:Token("then") and
			this:Block()
		) then
			while this:Token("elseif", true) do
				if not this:Expect(startIndex, graph, this:Exp() and this:Token("then", true) and this:Block()) then
					return pop(false)
				end
			end

			if this:Token("else", true) and not this:Expect(startIndex, graph, this:Block()) then
				return pop(false)
			end

			if not this:Expect(startIndex, graph, this:Token("end", true)) then
				return pop(false)
			end
		else
			return pop(false)
		end
	elseif this:Token("repeat", true) then
		if not this:Expect(startIndex, graph, this:Block() and this:Token("until", true) and this:Exp()) then
			return pop(false)
		end
	elseif this:Token("while", true) then
		if not this:Expect(startIndex, graph, this:Exp() and this:Token("do", true) and this:Block() and this:Token("end", true)) then
			return pop(false)
		end
	elseif this:Token("do", true) then
		if not this:Expect(startIndex, graph, this:Block() and this:Token("end", true)) then
			return pop(false)
		end
	elseif this:Token("goto", true) then
		if not this:Expect(startIndex, graph, this:Name()) then
			return pop(false)
		end
	elseif this:Token("break", true) then
	elseif this:Label() then
	elseif this:VarList() then
		if not this:Expect(startIndex, graph, this:Token("=") and this:ExpList()) then
			if not this:FunctionCall() then
				return pop(false)
			end
		end
	elseif not this:FunctionCall() then
		return pop(false)
	end

	this:Succeeded("Stat")

	return pop(true)
end

function parser.RetStat(this)
	push("RetStat")

	if not this:Token("return", true) then
		return pop(false)
	end

	this:ExpList()
	this:Token(";")

	this:Succeeded("RetStat")

	return pop(true)
end

function parser.Block(this)
	push("Block")

	while this:Stat() do end

	this:RetStat()

	this:Succeeded("Block")

	return pop(true)
end

function parser.Chunk(this)
	push("Chunk")
	
	this:Block()

	this:Succeeded("Chunk")

	return pop(true)
end

parser:Chunk()

if stack[1] then
	print("digraph G {"..stack[1].graph)
end

print("}")