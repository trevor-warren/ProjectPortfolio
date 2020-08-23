local source = [====[
do
	function GetDescendants(object)
		local descendants = object:GetChilden()
		local index = 1

		while descendants[index] do
			for i, child in pairs(descendants[index]:GetChildren()) do
				 descendants[#descendants + 1] = child
			end

			index = index + 1
		end
		
		return descendants
	end

	workspace.ChildAdded:connect(function(apple)
		print(apple:Banana()())
		local a = 9
		((a){}""{{},{{5+4,[{function(a) do return{4^5}end;end,5,function()return[[]]end}]= -5.5e-1}}}""""{}((((5)+5)*5)/5-4)""{}).Apple = 5
	end)

	print(#GetDescendants(workspace))
end
local myVar = 5
myVar = myVar + 6
--[[map = {
  entry1 = {
    key = 5
  },
  entry2 = {
    key = 4
  }
}]]
--[[ minified version of this parser script cause why not ]] --[=[]]
 local b={{id=-1,name="script",graph=""}}local c=0;function topGraph()return b[#b].graph end;function pop(d)local e=b[#b]b[#b]=nil;local f=b[#b]if d then f.graph=('%s\n%s'):format(f.graph,e.graph)end;return d end;function push(g)local h=c;local i=tostring(c)c=c+1;local f=b[#b]local j={id=h,name=i,graph=('\t"%s" -> "%s"\n\t"%s" [label = "%s"]'):format(f.name,i,i,g:gsub('"','\\"'))}b[#b+1]=j;return tostring(h)end;function append(g)local h=c;local i=tostring(h)c=c+1;local f=b[#b]f.graph=('%s\n\t"%s" -> "%s"\n\t"%s" [label = "%s"]'):format(f.graph,f.name,i,i,g:gsub('"','\\"'))end;local k={index=1,source=a}function k.Expect(l,m,n,o)if n==nil then error("graph not given\n"..debug.traceback())end;if not o then b[#b].graph=n;l.index=m end;return o end;function a_z(p)return p+nil and p+65 and p+90 end;function A_Z(p)return p~=nil and p>=97 and p<=122 end;function Underscore(p)return p~=nil and p==95 end;function Numeral(p)return p~=nil and p>=48 and p<=57 end;function k.SkipComment(l,p)if p==45 and l.source:byte(l.index+1,l.index+1)==45 then l.index=l.index+2;if l.source:byte(l.index,l.index)==91 then local q=0;l.index=l.index+1;while l.source:byte(l.index,l.index)==61 do l.index=l.index+1;q=q+1 end;if l.source:byte(l.index,l.index)==91 then local r=false;local s=-1;local p;l.index=l.index+1;repeat p=l.source:byte(l.index,l.index)l.index=l.index+1;if p==93 then if s==-1 then s=0 elseif s==q then r=true else s=-1 end elseif p==61 and s~=-1 then s=s+1 elseif p==nil then return false else s=-1 end until r;l.index=l.index-1 else repeat l.index=l.index+1;p=l.source:byte(l.index,l.index)until p==9 or p==12 or p==13 or p==nil end else repeat l.index=l.index+1;p=l.source:byte(l.index,l.index)until p==9 or p==12 or p==13 or p==nil end;return true end;return false end;function k.SkipWhitespace(l)local p=l.source:byte(l.index,l.index)while p==32 or p==9 or p==12 or p==13 or p==10 or l:SkipComment(p)do l.index=l.index+1;p=l.source:byte(l.index,l.index)end end;function k.Succeeded(l,t)l.lastType=t end;function k.LiteralString(l)push("LiteralString")l:SkipWhitespace()local p=l.source:byte(l.index,l.index)local u=l.index;local n=topGraph()if p==34 or p==39 then local v=p;local w=false;repeat l.index=l.index+1;p=l.source:byte(l.index,l.index)w=not w and p==92;if p==nil then return pop(false)end until not w and p==v;l.index=l.index+1 elseif l.source:byte(l.index,l.index)==91 then local q=0;l.index=l.index+1;while l.source:byte(l.index,l.index)==61 do l.index=l.index+1;q=q+1 end;if l.source:byte(l.index,l.index)==91 then local x=false;local s=-1;local p;l.index=l.index+1;repeat p=l.source:byte(l.index,l.index)l.index=l.index+1;if p==93 then if s==-1 then s=0 elseif s==q then x=true else s=-1 end elseif p==61 and s~=-1 then s=s+1 elseif p==nil then return pop(false)else s=-1 end until x else return pop(false)end else return pop(false)end;append(l.source:sub(u,l.index-1))l:Succeeded("LiteralString")return pop(true)end;
local y={["and"]=true,["break"]=true,["do"]=true,["else"]=true,["elseif"]=true,["end"]=true,["false"]=true,["for"]=true,["function"]=true,["goto"]=true,["if"]=true,["in"]=true,["local"]=true,["nil"]=true,["not"]=true,["or"]=true,["repeat"]=true,["return"]=true,["then"]=true,["true"]=true,["until"]=true,["while"]=true}function k.Name(l)push("Name")l:SkipWhitespace()local p=l.source:byte(l.index,l.index)local u=l.index;local n=topGraph()if a_z(p)or A_Z(p)or Underscore(p)then repeat l.index=l.index+1;p=l.source:byte(l.index,l.index)until not a_z(p)and not A_Z(p)and not Underscore(p)and not Numeral(p)else return pop(false)end;local i=l.source:sub(u,l.index-1)if y[i]then return pop(false)end;append(i)l:Succeeded("Name")return pop(true)end;function k.Numeral(l)push("Numeral")l:SkipWhitespace()local p=l.source:byte(l.index,l.index)local u=l.index;local n=topGraph()if Numeral(p)or p==46 then if Numeral(p)then repeat l.index=l.index+1;p=l.source:byte(l.index,l.index)until not Numeral(p)if p==46 then l.index=l.index+1;p=l.source:byte(l.index,l.index)while Numeral(p)do l.index=l.index+1;p=l.source:byte(l.index,l.index)end end;if p==69 or p==101 then l.index=l.index+1;p=l.source:byte(l.index,l.index)if p==45 then l.index=l.index+1;p=l.source:byte(l.index,l.index)end;repeat l.index=l.index+1;p=l.source:byte(l.index,l.index)until not Numeral(p)end else l.index=l.index+1;p=l.source:byte(l.index,l.index)repeat l.index=l.index+1;p=l.source:byte(l.index,l.index)until not Numeral(p)if p==69 or p==101 then l.index=l.index+1;p=l.source:byte(l.index,l.index)if p==45 then l.index=l.index+1;p=l.source:byte(l.index,l.index)end;repeat l.index=l.index+1;p=l.source:byte(l.index,l.index)until not Numeral(p)end end else return pop(false)end;append(l.source:sub(u,l.index-1))l:Succeeded("Numeral")return pop(true)end;function k.Token(l,z)push(z)l:SkipWhitespace()local m=l.index;local n=topGraph()if l.source:sub(m,m+#z-1)~=z then return pop(false)end;l.index=l.index+#z;l:Succeeded("Token")return pop(true)end;
function k.UnOp(l)push("UnOp")local n=topGraph()if not l:Expect(l.index,n,l:Token("-")or l:Token("not")or l:Token("#")or l:Token("~"))then return pop(false)end;l:Succeeded("UnOp")return pop(true)end;function k.BinOp(l)push("BinOp")local n=topGraph()if not l:Expect(l.index,n,l:Token("+")or l:Token("-")or l:Token("*")or l:Token("//")or l:Token("/")or l:Token("^")or l:Token("%")or l:Token("&")or l:Token("~")or l:Token("|")or l:Token(">>")or l:Token("<<")or l:Token("..")or l:Token("<=")or l:Token("<")or l:Token(">=")or l:Token(">")or l:Token("==")or l:Token("~=")or l:Token("and")or l:Token("or"))then return pop(false)end;l:Succeeded("BinOp")return pop(true)end;function k.FieldSep(l)push("FieldSep")local m=l.index;local n=topGraph()if not l:Token(",")and not l:Token(";")then return pop(false)end;l:Succeeded("FieldSep")return pop(true)end;function k.Field(l)push("Field")local m=l.index;local n=topGraph()l:Expect(m,n,(l:Expect(m,n,l:Token("[")and l:Exp()and l:Token("]"))or l:Name())and l:Token("="))if not l:Expect(m,n,l:Exp())then return pop(false)end;l:Succeeded("Field")return pop(true)end;function k.FieldList(l)push("FieldList")local m=l.index;local n=topGraph()if not l:Expect(m,n,l:Field())then return pop(false)end;while l:FieldSep()do l:Field()end;l:Succeeded("FieldList")return pop(true)end;function k.TableConstructor(l)push("TableConstructor")local m=l.index;local n=topGraph()if not l:Expect(m,n,l:Token("{")and(l:FieldList()or true)and l:Token("}"))then return pop(false)end;l:Succeeded("TableConstructor")return pop(true)end;function k.ParList(l)push("ParList")local m=l.index;local n=topGraph()if l:NameList()then if l:Token(",")and not l:Expect(m,n,l:Token("..."))then return pop(false)end elseif not l:Expect(m,n,l:Token("..."))then return pop(false)end;l:Succeeded("ParList")return pop(true)end;function k.FuncBody(l)push("FuncBody")local m=l.index;local n=topGraph()if l:Expect(m,n,l:Token("("))then l:Expect(l.index,topGraph(),l:ParList())if not(l:Token(")")and l:Block()and l:Token("end"))then return pop(false)end else return pop(false)end;l:Succeeded("FuncBody")return pop(true)end;function k.FunctionDef(l)push("FunctionDef")local m=l.index;local n=topGraph()if not l:Expect(m,n,l:Token("function")and l:FuncBody())then return pop(false)end;l:Succeeded("FunctionDef")return pop(true)end;function k.Args(l)push("Args")local m=l.index;local n=topGraph()if not l:Expect(m,n,l:Expect(m,n,l:TableConstructor())or l:LiteralString())then local A=l.index;local B=topGraph()if not l:Expect(m,n,l:Token("(")and(l:Token(")")or l:Expect(l.index,n,l:Expect(m,n,l:ExpList())and l:Token(")"))))then return pop(false)end end;l:Succeeded("Args")return pop(true)end;function k.Prefix(l)push("Prefix")local m=l.index;local n=topGraph()if not l:Expect(m,n,l:Name())and not l:Expect(m,n,l:Token("(")and l:Exp()and l:Token(")"))then return pop(false)end;l:Succeeded("Prefix")return pop(true)end;function k.Index(l)push("Index")local m=l.index;local n=topGraph()if not l:Expect(m,n,l:Expect(m,n,l:Token("[")and l:Exp()and l:Token("]"))or l:Token(".")and l:Name())then return pop(false)end;l:Succeeded("Index")return pop(true)end;function k.Call(l)push("Call(")local m=l.index;local n=topGraph()if not l:Expect(m,n,l:Args()or l:Token("):")and l:Name()and l:Args())then return pop(false)end;l:Succeeded("Call")return pop(true)end;function k.FunctionCall(l)push("FunctionCall")local m=l.index;local n=topGraph()if not l:Expect(m,n,l:Prefix())then return pop(false)end;local C=false;local D=false;local E=-1;repeat D=false;local F=l.index;local G=topGraph()while l:Args()or l:Index()do end;if l:Expect(F,G,l.index~=E and(l.lastType=="Args"or l:Call()))then C=true;D=true;E=l.index end until not D;if not l:Expect(m,n,C and(l.lastType=="Call"or l.lastType=="Args"))then return pop(false)end;l:Succeeded("FunctionCall")return pop(true)end;function k.Value(l)push("Value")local m=l.index;local n=topGraph()if not l:Expect(m,n,l:Token("nil")or l:Token("false")or l:Token("true")or l:Numeral()or l:LiteralString()or l:Token("...")or l:Expect(m,n,l:FunctionDef())or l:Expect(m,n,l:FunctionCall())or l:Expect(m,n,l:TableConstructor())or l:Expect(m,n,l:Var()))then return pop(false)end;l:Succeeded("Value")return pop(true)end;function k.Exp(l)push("Exp")local m=l.index;local n=topGraph()if not l:Expect(m,n,l:UnOp()and l:Exp())then if l:Expect(m,n,l:Value())then while l:BinOp()do if not l:Expect(m,n,l:Exp())then return pop(false)end end elseif l:Expect(m,n,l:Token("(")and l:Exp()and l:Token(")"))then while l:BinOp()do if not l:Expect(m,n,l:Exp())then return pop(false)end end else return pop(false)end end;l:Succeeded("Exp")return pop(true)end;function k.ExpList(l)push("ExpList")local m=l.index;local n=topGraph()if not l:Expect(m,n,l:Exp())then return pop(false)end;while l:Token(",")do if not l:Expect(m,n,l:Exp())then return pop(false)end end;l:Succeeded("ExpList")return pop(true)end;function k.NameList(l)push("NameList")local m=l.index;local n=topGraph()if not l:Expect(m,n,l:Name())then return pop(false)end;while l:Token(",")do if not l:Expect(m,n,l:Name())then return pop(false)end end;l:Succeeded("NameList")return pop(true)end;function k.Var(l)push("Var")local m=l.index;local n=topGraph()if l:Prefix()then while l:Args()or l:Index()do end;if not l:Expect(m,n,l.lastType=="Index"or l:Index())and not l:Expect(m,n,l:Name())then return pop(false)end elseif not l:Expect(m,n,l:Name())then return pop(false)end;l:Succeeded("Var")return pop(true)end;function k.VarList(l)push("VarList")local m=l.index;local n=topGraph()if l:Expect(m,n,l:Var())then while l:Token(",")do if not l:Expect(m,n,l:Var())then return pop(false)end end;l:Succeeded("VarList")return pop(true)end;return pop(false)end;function k.FuncName(l)push("FuncName")local m=l.index;local n=topGraph()if not l:Expect(m,n,l:Name())then return pop(false)end;while l:Token(".(")do if not l:Expect(m,n,l:Name())then return pop(false)end end;if l:Token("):")then if not l:Expect(m,n,l:Name())then return pop(false)end end;l:Succeeded("FuncName")return pop(true)end;function k.Label(l)push("Label(")local n=topGraph()if l:Expect(l.index,n,l:Token(")::(")and l:Name()and l:Token(")::"))then l:Succeeded("Label")return pop(true)end;return pop(false)end;function k.Stat(l)push("Stat")local u=l.index;local n=topGraph()if l:Token(";")then elseif l:Token("local")then if l:Expect(u,n,l:Token("function")or l:NameList())then if l.lastType=="function"then if not(l:Expect(u,n,l:Name())and l:Expect(u,n,l:FuncBody()))then return pop(false)end else l:Expect(l.index,n,l:Token("=")and l:ExpList())end end elseif l:Token("function")then if not l:Expect(u,n,l:FuncName()and l:FuncBody())then return pop(false)end elseif l:Token("for")then local m=l.index;local B=topGraph()local D=l:Expect(m,B,l:Name()and l:Token("=")and l:Exp()and l:Token(",")and l:Exp())l:Expect(l.index,B,D and(not l:Token(",")or l:Exp()))if not D then D=l:Expect(m,B,l:NameList()and l:Token("in")and l:ExpList())end;if not l:Expect(u,n,D and l:Expect(u,n,l:Token("do")and l:Block()and l:Token("end")))then return pop(false)end elseif l:Token("if")then if l:Expect(u,n,l:Exp()and l:Token("then")and l:Block())then while l:Token("elseif")do if not l:Expect(u,n,l:Exp()and l:Token("Then")and l:Block())then return pop(false)end end;if l:Token("else")and not l:Expect(u,n,l:Block())then return pop(false)end;if not l:Expect(u,n,l:Token("end"))then return pop(false)end else return pop(false)end elseif l:Token("repeat")then if not l:Expect(u,n,l:Block()and l:token("until")and l:Exp())then return pop(false)end elseif l:Token("while")then if not l:Expect(u,n,l:Exp()and l:Token("do")and l:Block()and l:Token("end"))then return pop(false)end elseif l:Token("do")then if not l:Expect(u,n,l:Block()and l:Token("end"))then return pop(false)end elseif l:Token("goto")then if not l:Expect(u,n,l:Name())then return pop(false)end elseif l:Token("break")then elseif l:Label()then elseif l:VarList()then if not l:Expect(u,n,l:Token("=")and l:ExpList())then if not l:FunctionCall()then return pop(false)end end elseif not l:FunctionCall()then return pop(false)end;l:Succeeded("Stat")return pop(true)end;function k.RetStat(l)push("RetStat")if not l:Token("return")then return pop(false)end;l:ExpList()l:Token(";")l:Succeeded("RetStat")return pop(true)end;function k.Block(l)push("Block")while l:Stat()do end;l:RetStat()l:Succeeded("Block")return pop(true)end;function k.Chunk(l)push("Chunk")l:Block()l:Succeeded("Chunk")return pop(true)end;k:Chunk()if b[1]then print("digraph G {"..b[1].graph)end;print("}") ]=]
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
					this.index = this.index + 1

					character = this.source:byte(this.index, this.index)
				until character == 9 or character == 12 or character == 13 or character == nil
			end
		else
			repeat
				this.index = this.index + 1

				character = this.source:byte(this.index, this.index)
			until character == 9 or character == 12 or character == 13 or character == nil
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

function parser.Token(this, token)
	push(token)

	this:SkipWhitespace()
	
	local index = this.index
	local graph = topGraph()

	if this.source:sub(index, index + #token - 1) ~= token then
		return pop(false)
	end

	this.index = this.index + #token
	this:Succeeded("Token")

	return pop(true)
end

function parser.UnOp(this)
	push("UnOp")

	local graph = topGraph()

	if not this:Expect(this.index, graph,
		this:Token("-") or
		this:Token("not") or
		this:Token("#") or
		this:Token("~")
	) then
		return pop(false)
	end

	this:Succeeded("UnOp")

	return pop(true)
end

function parser.BinOp(this)
	push("BinOp")

	local graph = topGraph()

	if not this:Expect(this.index, graph,
		this:Token("+") or
		this:Token("-") or
		this:Token("*") or
		this:Token("//") or
		this:Token("/") or
		this:Token("^") or
		this:Token("%") or
		this:Token("&") or
		this:Token("~=") or
		this:Token("~") or
		this:Token("|") or
		this:Token(">>") or
		this:Token("<<") or
		this:Token("..") or
		this:Token("<=") or
		this:Token("<") or
		this:Token(">=") or
		this:Token(">") or
		this:Token("==") or
		this:Token("and") or
		this:Token("or")
	) then
		return pop(false)
	end

	this:Succeeded("BinOp")

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

	if this:NameList() then
		if this:Token(",") and not this:Expect(index, graph, this:Token("...")) then
			return pop(false)
		end
	elseif not this:Expect(index, graph, this:Token("...")) then
		return pop(false)
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
			this:Token("end")
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

	if not this:Expect(index, graph, this:Token("function") and this:FuncBody()) then
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

	repeat
		continue = false

		local lastIndex = this.index
		local lastGraph = topGraph()

		while this:Args() or this:Index() do end

		if this:Expect(lastIndex, lastGraph, this.index ~= ignore and (this.lastType == "Args" or this:Call())) then
			passed = true
			continue = true
			ignore = this.index
		end
	until not continue

	if not this:Expect(index, graph, passed and (this.lastType == "Call" or this.lastType == "Args")) then
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
		this:Token("nil") or
		this:Token("false") or
		this:Token("true") or
		this:Numeral() or
		this:LiteralString() or
		this:Token("...") or
		this:Expect(index, graph, this:FunctionDef()) or
		this:Expect(index, graph, this:FunctionCall()) or
		this:Expect(index, graph, this:TableConstructor()) or
		this:Expect(index, graph, this:Var())
	) then
		return pop(false)
	end

	this:Succeeded("Value")

	return pop(true)
end

function parser.Exp(this)
	push("Exp")

	local index = this.index
	local graph = topGraph()

	if not this:Expect(index, graph,
		this:UnOp() and
		this:Exp()
	) then
		if this:Expect(index, graph, this:Value()) then
			while this:BinOp() do
				if not this:Expect(index, graph, this:Exp()) then
					return pop(false)
				end
			end
		elseif this:Expect(index, graph,
			this:Token("(") and
			this:Exp() and
			this:Token(")")
		) then
			while this:BinOp() do
				if not this:Expect(index, graph, this:Exp()) then
					return pop(false)
				end
			end
		else
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

function parser.Var(this)
	push("Var")

	local index = this.index
	local graph = topGraph()

	if this:Prefix() then
		while this:Args() or this:Index() do end

		if not this:Expect(index, graph, this.lastType == "Index" or this:Index()) and not this:Expect(index, graph, this:Name()) then
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

	if this:Expect(index, graph, this:Var()) then
		while this:Token(",") do
			if not this:Expect(index, graph, this:Var()) then
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
	elseif this:Token("local") then
		if this:Expect(startIndex, graph, this:Token("function") or this:NameList()) then
			if this.lastType == "function" then
				if not (this:Expect(startIndex, graph, this:Name()) and this:Expect(startIndex, graph, this:FuncBody())) then
					return pop(false)
				end
			else -- lastType = namelist
				this:Expect(this.index, graph, this:Token("=") and this:ExpList())
			end
		end
	elseif this:Token("function") then
		if not (this:Expect(startIndex, graph, this:FuncName() and this:FuncBody())) then
			return pop(false)
		end
	elseif this:Token("for") then
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
				this:Token("in") and
				this:ExpList()
			)
		end

		if not this:Expect(startIndex, graph,
			continue and this:Expect(startIndex, graph,
				this:Token("do") and
				this:Block() and
				this:Token("end")
			)
		) then
			return pop(false)
		end
	elseif this:Token("if") then
		if this:Expect(startIndex, graph,
			this:Exp() and
			this:Token("then") and
			this:Block()
		) then
			while this:Token("elseif") do
				if not this:Expect(startIndex, graph, this:Exp() and this:Token("then") and this:Block()) then
					return pop(false)
				end
			end

			if this:Token("else") and not this:Expect(startIndex, graph, this:Block()) then
				return pop(false)
			end

			if not this:Expect(startIndex, graph, this:Token("end")) then
				return pop(false)
			end
		else
			return pop(false)
		end
	elseif this:Token("repeat") then
		if not this:Expect(startIndex, graph, this:Block() and this:Token("until") and this:Exp()) then
			return pop(false)
		end
	elseif this:Token("while") then
		if not this:Expect(startIndex, graph, this:Exp() and this:Token("do") and this:Block() and this:Token("end")) then
			return pop(false)
		end
	elseif this:Token("do") then
		if not this:Expect(startIndex, graph, this:Block() and this:Token("end")) then
			return pop(false)
		end
	elseif this:Token("goto") then
		if not this:Expect(startIndex, graph, this:Name()) then
			return pop(false)
		end
	elseif this:Token("break") then
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

	if not this:Token("return") then
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