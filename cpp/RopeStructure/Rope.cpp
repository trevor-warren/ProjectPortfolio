#include "Rope.h"

Rope::Rope(const std::string& string, int index, int length)
{
	Insert(0, string, index, length);
}

Rope::Rope(const char* string, int length)
{
	Insert(0, string, length);
}

Rope::Rope(const Rope& rope, int index, int length)
{
	Insert(0, rope, index, length);
}

Rope::Rope(char character)
{
	Insert(0, character);
}

Rope::~Rope()
{
	Clear();
}

void Rope::Insert(int at, const std::string& string, int index, int length)
{
	if (at < 0 || at > GetLength())
		return;

	if (length == -1)
		length = string.size() - index;

	if (length <= 0 || index < 0)
		return;

	Insert(at, string.c_str() + index, length);
}

void Rope::Insert(int at, const char* string, int length)
{
	if (at < 0 || at > GetLength())
		return;

	if (length == -1)
		for (length = 0; string[length]; ++length);

	if (length <= 0)
		return;

	int location = -1;
	Node* insertLocation = nullptr;

	if (Head)
	{
		Node::NodeIndex found = Head->FindNode(at);
		insertLocation = found.first;
		location = found.second;

		if (at > found.second && at < found.second + insertLocation->Length)
		{
			if (length + insertLocation->Length > NodeSize)
				Split(insertLocation, at - found.second);
			else
			{
				insertLocation->Insert(at - found.second, string, length);

				return;
			}

			if (insertLocation->Right != nullptr)
			{
				Node* next = insertLocation->GetNext();

				int copying = NodeSize - next->Length;

				if (copying > length)
					copying = length;

				length -= next->Insert(0, string + length - copying, copying);
			}

			int copied = insertLocation->Insert(insertLocation->Length, string, length);

			length -= copied;
			string += copied;
			at += copied;
		}
	}

	while (length > 0)
	{
		int copying = NodeSize;

		if (copying > length)
			copying = length;

		InsertRaw(string, copying, at, insertLocation, location);

		string += copying;
		at += copying;
		length -= copying;
	}
}

void Rope::Insert(int at, const Rope& rope, int index, int length)
{
	if (at < 0 || at > GetLength())
		return;

	if (length == -1)
		length = rope.GetLength();

	if (!rope.Head || length <= 0)
		return;

	if (Head)
	{
		Node::NodeIndex found = rope.Head->FindNode(index);

		if (at > found.second && at < found.second + found.first->Length)
			Split(found.first, found.second - at);
	}

	Node::NodeIndex found = rope.Head->FindNode(index);
	Node* node = found.first;
	int ignore = found.second - index;

	while (node->Left)
		node = node->Left;

	while (node && length > 0)
	{
		int amount = node->Length - ignore;

		if (amount > length)
			amount = length;

		InsertRaw(node->Data + ignore, amount, index);

		ignore = 0;
		index += node->Length;
		length -= amount;

		if (node->Right)
		{
			node = node->Right;

			while (node->Left)
				node = node->Left;
		}
		else
			node = node->Parent;
	}
}

void Rope::Insert(int at, char character)
{
	if (at < 0 || at > GetLength())
		return;

	Insert(at, &character, 1);
}

void Rope::Concat(const std::string string, int index, int length)
{
	Insert(GetLength(), string, index, length);
}

void Rope::Concat(const char* string, int length)
{
	Insert(GetLength(), string, length);
}

void Rope::Concat(const Rope& rope, int index, int length)
{
	Insert(GetLength(), rope, index, length);
}

void Rope::Remove(int index, int length)
{
	if (index < 0 || index >= GetLength())
		return;

	Node::NodeIndex found = Head->FindNode(index);
	Node* node = found.first;

	int nodeIndex = index - found.second;

	if (found.second < index)
	{
		if (length > node->Length - nodeIndex)
		{
			length -= node->Remove(nodeIndex, length);

			node = node->GetNext();
		}
		else
		{
			node->Remove(nodeIndex, length);

			return;
		}
	}

	while (node != nullptr && length >= node->Length)
	{
		Node* next = node->GetNext();

		length -= node->Length;

		node->Remove();

		node = next;
	}

	if (node != nullptr && length > 0)
		node->Remove(0, length);
}

void Rope::Clear()
{
	if (Head == nullptr)
		return;

	//delete Head;
	Allocator.Destroy(Head);

	Head = nullptr;
}

char Rope::Get(int index) const
{
	if (index < 0 || index >= GetLength())
		return 0;

	return (*this)[index];
}

std::string Rope::Get(int index, int length) const
{
	if (Head == nullptr)
		return "";

	std::string result;

	result.reserve(length);

	for (Node::ConstNodeIndex node = Head->FindNode(index); node.first != nullptr && length > 0; node.first = node.first->GetNext())
	{
		int start = index - node.second;
		int copied = node.first->Length - start;

		if (copied > length)
			copied = length;

		if (copied > 0)
			result.append(node.first->Data + start, copied);

		index += node.first->Length;
		length -= copied;

		node.second += node.first->Length;
	}

	return result;
}

int Rope::GetLength() const
{
	if (Head == nullptr)
		return 0;

	return Head->TotalLength;
}

bool Rope::Validate() const
{
	for (Node* node = Head->FindNode(0).first; node != nullptr; node = node->GetNext())
	{
		if (node->Length == 0)
			return false;

		for (int i = 0; i < node->Length; ++i)
			if (node->Data[i] == 0)
				return false;
	}

	return true;
}

Rope& Rope::operator+=(const std::string& string)
{
	Insert(GetLength(), string);

	return *this;
}

Rope& Rope::operator+=(const char* string)
{
	Insert(GetLength(), string);

	return *this;
}

Rope& Rope::operator+=(const Rope& rope)
{
	Insert(GetLength(), rope);

	return *this;
}

Rope& Rope::operator=(const Rope& rhs)
{
	Clear();

	Insert(0, rhs);

	return *this;
}

char Rope::operator[](int index) const
{
	if (Head == nullptr || index < 0 || index >= GetLength())
		return 0;

	Node::ConstNodeIndex node = Head->FindNode(index);

	return node.first->Data[index - node.second];
}

Rope::operator std::string() const
{
	if (Head == nullptr)
		return "";

	std::string result;

	result.reserve(GetLength());

	for (Node* node = Head->FindNode(0).first; node != nullptr; node = node->GetNext())
		result.append(node->Data, node->Length);

	return result;
}

Rope::Node::~Node()
{
	if (Left != nullptr)
		//delete Left;
		Tree->Allocator.Destroy(Left);

	if (Right != nullptr)
		//delete Right;
		Tree->Allocator.Destroy(Right);
}

void Rope::Node::UpdateHeight(int& left, int& right)
{
	left = -1;
	right = -1;

	if (Left != nullptr)
		left = Left->Height;

	if (Right != nullptr)
		right = Right->Height;

	Height = left + 1;

	if (right >= Height)
		Height = right + 1;
}

void Rope::Node::Update()
{
	UpdateLength();

	int leftHeight = -1;
	int rightHeight = -1;

	UpdateHeight(leftHeight, rightHeight);

	if (leftHeight > rightHeight + 1)
	{
		int lowerLeft = -1;
		int lowerRight = -1;

		if (Left->Left != nullptr)
			lowerLeft = Left->Left->Height;

		if (Left->Right != nullptr)
			lowerRight = Left->Right->Height;

		if (lowerRight > lowerLeft)
			Left->RotateLeft();

		RotateRight();
	}
	else if (rightHeight > leftHeight + 1)
	{
		int lowerLeft = -1;
		int lowerRight = -1;

		if (Right->Left != nullptr)
			lowerLeft = Right->Left->Height;

		if (Right->Right != nullptr)
			lowerRight = Right->Right->Height;

		if (lowerLeft > lowerRight)
			Right->RotateRight();

		RotateLeft();
	}

	if (Parent != nullptr)
		Parent->Update();
}

void Rope::Node::UpdateLength(bool recursive)
{
	for (Node* node = this; node != nullptr && (recursive || node == this); node = node->Parent)
	{
		node->TotalLength = node->Length;

		if (node->Left != nullptr)
			node->TotalLength += node->Left->TotalLength;

		if (node->Right != nullptr)
			node->TotalLength += node->Right->TotalLength;
	}
}

void Rope::Node::RotateLeft()
{
	if (Parent != nullptr)
	{
		if (Parent->Left == this)
			Parent->Left = Right;
		else
			Parent->Right = Right;
	}
	else
		Tree->Head = Right;

	Node* newRight = Right->Left;

	if (newRight != nullptr)
		newRight->Parent = this;

	Right->Left = this;
	Right->Parent = Parent;
	Parent = Right;
	Right = newRight;

	int leftHeight = -1;
	int rightHeight = -1;

	UpdateHeight(leftHeight, rightHeight);
	UpdateLength(false);

	Parent->UpdateHeight(leftHeight, rightHeight);
	Parent->UpdateLength(false);
}

void Rope::Node::RotateRight()
{
	if (Parent != nullptr)
	{
		if (Parent->Right == this)
			Parent->Right = Left;
		else
			Parent->Left = Left;
	}
	else
		Tree->Head = Left;

	Node* newLeft = Left->Right;

	if (newLeft != nullptr)
		newLeft->Parent = this;

	Left->Right = this;
	Left->Parent = Parent;
	Parent = Left;
	Left = newLeft;

	int leftHeight = -1;
	int rightHeight = -1;

	UpdateHeight(leftHeight, rightHeight);
	UpdateLength(false);

	Parent->UpdateHeight(leftHeight, rightHeight);
	Parent->UpdateLength(false);
}

Rope::Node* Rope::Node::GetPrevious()
{
	Node* node = this;

	if (node->Left == nullptr)
	{
		const Node* lastNode = node;

		while (node && node->Left == lastNode)
		{
			lastNode = node;
			node = node->Parent;
		}
	}
	else
	{
		node = node->Left;

		while (node->Right != nullptr)
			node = node->Right;
	}

	return node;
}

const Rope::Node* Rope::Node::GetPrevious() const
{
	const Node* node = this;

	if (node->Left == nullptr)
	{
		const Node* lastNode = node;

		while (node && node->Left == lastNode)
		{
			lastNode = node;
			node = node->Parent;
		}
	}
	else
	{
		node = node->Left;

		while (node->Right != nullptr)
			node = node->Right;
	}

	return node;
}

Rope::Node* Rope::Node::GetNext()
{
	Node* node = this;

	if (node->Right == nullptr)
	{
		const Node* lastNode = nullptr;

		while (node && node->Right == lastNode)
		{
			lastNode = node;
			node = node->Parent;
		}
	}
	else
	{
		node = node->Right;

		while (node->Left != nullptr)
			node = node->Left;
	}

	return node;
}

const Rope::Node* Rope::Node::GetNext() const
{
	const Node* node = this;

	if (node->Right == nullptr)
	{
		const Node* lastNode = nullptr;

		while (node && node->Right == lastNode)
		{
			lastNode = node;
			node = node->Parent;
		}
	}
	else
	{
		node = node->Right;

		while (node->Left != nullptr)
			node = node->Left;
	}

	return node;
}

Rope::Node::NodeIndex Rope::Node::FindNode(int index, int at)
{
	if (Left != nullptr)
	{
		if (index < Left->TotalLength)
			return Left->FindNode(index, at);

		at += Left->TotalLength;
		index -= Left->TotalLength;
	}

	if (index < Length)
		return std::make_pair(this, at);

	at += Length;
	index -= Length;

	if (Right != nullptr)
		return Right->FindNode(index, at);

	//throw "the fuck u doin";

	return std::make_pair(nullptr, -1);
}

Rope::Node::ConstNodeIndex Rope::Node::FindNode(int index, int at) const
{
	if (Left != nullptr)
	{
		if (index < Left->TotalLength)
			return Left->FindNode(index, at);
		
		at += Left->TotalLength;
		index -= Left->TotalLength;
	}
	
	if (index < Length)
		return std::make_pair(this, at);

	at += Left->Length;
	index -= Left->Length;

	if (Right != nullptr)
		return Right->FindNode(index, at);

	//throw "the fuck u doin";

	return std::make_pair(nullptr, -1);
}

int Rope::Node::Insert(int at, const char* text, int length)
{
	if (length > NodeSize - Length)
		length = NodeSize - Length;

	if (length <= 0)
		return 0;

	if (at != Length)
		for (int i = Length - 1; i >= at; --i)
			Data[i + length] = Data[i];
	
	for (int i = 0; i < length; ++i)
		Data[at + i] = text[i];

	Length += length;

	UpdateLength();

	return length;
}

int Rope::Node::Remove(int at, int length)
{
	if (length > Length - at)
		length = Length - at;

	if (length <= 0)
		return 0;

	for (int i = 0; i < length && at + length + i < Length; ++i)
		Data[at + i] = Data[at + length + i];

	Length -= length;

	for (Node* node = this; node != nullptr; node = node->Parent)
	{
		node->TotalLength = node->Length;

		if (node->Left != nullptr)
			node->TotalLength += node->Left->TotalLength;

		if (node->Right != nullptr)
			node->TotalLength += node->Right->TotalLength;
	}

	UpdateLength();

	return length;
}

void Rope::Node::Remove()
{
	Node* updateStart = Parent;
	Node* replacement = nullptr;

	if (Left != nullptr)
	{
		replacement = Left;

		while (replacement->Right != nullptr)
			replacement = replacement->Right;
	}
	else if (Right != nullptr)
	{
		replacement = Right;

		while (replacement->Left != nullptr)
			replacement = replacement->Left;
	}

	if (Parent == nullptr)
		Tree->Head = replacement;
	else
	{
		if (Parent->Left == this)
			Parent->Left = replacement;
		else
			Parent->Right = replacement;
	}

	if (replacement != nullptr)
	{
		if (replacement->Parent != this)
		{
			updateStart = replacement->Parent;

			if (updateStart->Left == replacement)
				updateStart->Left = nullptr;
			else
				updateStart->Right = nullptr;
		}
		else
			updateStart = replacement;

		replacement->Parent = Parent;

		if (replacement == Left)
			Left->Right = Right;
		else if (replacement == Right)
			Right->Left = Left;
		else
		{
			replacement->Left = Left;
			replacement->Right = Right;
		}

		if (replacement->Left != nullptr)
			replacement->Left->Parent = replacement;

		if (replacement->Right != nullptr)
			replacement->Right->Parent = replacement;
	}

	if (updateStart != nullptr)
		updateStart->Update();
}

void Rope::Split(Node* node, int index)
{
	Node* newNode = Allocator.Create<Node>();
	//Node* newNode = new Node();

	newNode->Tree = this;
	newNode->Length = node->Length - index;

	for (int i = index; i < node->Length; ++i)
		newNode->Data[i - index] = node->Data[i];

	node->Length = index;

	if (node->Right != nullptr)
	{
		node = node->Right;

		while (node->Left != nullptr)
			node = node->Left;

		node->Left = newNode;
		newNode->Parent = node;
	}
	else
	{
		newNode->Parent = node;
		node->Right = newNode;
	}

	newNode->Update();
}

void Rope::InsertRaw(const char* data, int length, int at, Node* node, int location)
{
	Node* newNode = Allocator.Create<Node>();
	//Node* newNode = new Node();

	newNode->Tree = this;
	newNode->Length = length;
	newNode->TotalLength = length;

	for (int i = 0; i < length; ++i)
		newNode->Data[i] = data[i];

	if (Head)
	{
		if (location == -1)
		{
			node = Head;

			location = 0;

			if (Head->Left)
				location = Head->Left->TotalLength;
		}

		while ((at <= location && node->Left) || (at >= location + node->Length && node->Right))
		{
			if (at <= location)
			{
				node = node->Left;
				location -= node->TotalLength;
			}
			else
			{
				location += node->Length;
				node = node->Right;
			}

			if (node->Left != nullptr)
				location += node->Left->TotalLength;
		}

		/*if (at > location && at < location + node->Length)
			throw "why do you do this?";
		else*/ if (at <= location)
			node->Left = newNode;
		else
			node->Right = newNode;

		newNode->Parent = node;
		newNode->Update();
	}
	else
		Head = newNode;
}