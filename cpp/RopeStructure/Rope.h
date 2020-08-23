#pragma once

#include <string>
#include <map>

#include "PageAllocator.h"

class Rope
{
public:
	Rope() {};
	Rope(const std::string& string, int index = 0, int length = -1);
	Rope(const char* string, int length = -1);
	Rope(const Rope& rope, int index = 0, int length = -1);
	Rope(char character);
	~Rope();

	void Insert(int at, const std::string& string, int index = 0, int length = -1);
	void Insert(int at, const char* string, int length = -1);
	void Insert(int at, const Rope& rope, int index = 0, int length = -1);
	void Insert(int at, char character);

	void Concat(const std::string string, int index = 0, int length = -1);
	void Concat(const char* string, int length = -1);
	void Concat(const Rope& rope, int index = 0, int length = -1);

	void Remove(int index, int length = 1);

	void Clear();

	char Get(int index) const;
	std::string Get(int index, int length) const;

	int GetLength() const;

	bool Validate() const;

	Rope& operator+=(const std::string& string);
	Rope& operator+=(const char* string);
	Rope& operator+=(const Rope& rope);
	Rope& operator=(const Rope& rhs);
	char operator[](int index) const;

	operator std::string() const;

private:
	static const int NodeSize = 0x200-7*4;

	struct Node
	{
		typedef std::pair<Node*, int> NodeIndex;
		typedef std::pair<const Node*, int> ConstNodeIndex;

		char Data[NodeSize] = { 0 };
		Rope* Tree = nullptr;
		Node* Parent = nullptr;
		Node* Left = nullptr;
		Node* Right = nullptr;
		int Length = 0;
		int Height = 0;
		int TotalLength = 0;

		~Node();

		void UpdateHeight(int& left, int& right);
		void Update();
		void UpdateLength(bool recursive = true);
		void RotateLeft();
		void RotateRight();
		Node* GetPrevious();
		const Node* GetPrevious() const;
		Node* GetNext();
		const Node* GetNext() const;
		NodeIndex FindNode(int index, int at = 0);
		ConstNodeIndex FindNode(int index, int at = 0) const;
		int Insert(int at, const char* text, int length);
		int Remove(int at, int length);
		void Remove();
	};

	Node* Head = nullptr;
	PageAllocator<sizeof(Node), 0x10000> Allocator;

	void Split(Node* node, int index);
	void InsertRaw(const char* data, int length, int at, Node* node = nullptr, int location = -1);
};