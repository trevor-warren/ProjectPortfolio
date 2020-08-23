#include "Handle.h"

namespace Engine
{
	bool HandleBase::GarbageClean = true;
	bool HandleBase::CleaningReference = false;
	HandleBase::HandleInfoVector HandleBase::Handles = HandleInfoVector();
	HandleBase::TypeMap HandleBase::Types = TypeMap();
	HandleBase::HandleVector HandleBase::Globals = HandleVector();
	HandleBase::HandleVector HandleBase::SweepQueue = HandleVector();
	HandleBase::IntVector HandleBase::LiveHandles = IntVector();
	std::string HandleBase::BlankName = "";
	HandleBase::IntVector HandleBase::DeadHandles = IntVector();
	bool HandleBase::CleanDeadHandles = false;
	int HandleBase::ReferencesRemoved = 0;
	int HandleBase::Cleaned = 0;
	NullHandle Null;

	int CollectGarbage(bool quick)
	{
		return HandleBase::CollectGarbage(quick);
	}

	int CleanHandles()
	{
		return HandleBase::CleanUp();
	}

	HandleBase::HandleBase(HandleBase&& original) noexcept
	{
		*this = std::move(original);
	}
	
	HandleBase& HandleBase::operator=(HandleBase&& original)
	{
		Parent = original.Parent;
		ID = original.ID;
		GlobalID = original.GlobalID;
		LocalID = original.LocalID;
		ChildID = original.ChildID;
		Global = original.Global;
		Weak = original.Weak;
	
		if (GlobalID != -1)
			Globals[GlobalID] = this;
	
		if (LocalID != -1)
			Handles[ID].Handles[LocalID] = this;
	
		if (Parent != -1 && ChildID != -1)
			Handles[Parent].Children[ChildID] = this;
	
		original.Parent = -1;
		original.ID = -1;
		original.GlobalID = -1;
		original.LocalID = -1;
		original.ChildID = -1;
		original.Global = false;
		original.Weak = false;
	
		return *this;
	}

	HandleBase::~HandleBase()
	{
		//SetID(-1);
		SetGlobal(false);
		SetParent(nullptr);
		ClearReference();

		//if (DeadHandles.size() >= 5)
		//	CollectGarbage(false);

		//if (ReferencesRemoved >= 100)
		//	CollectGarbage(true);
	}

	HandleBase& HandleBase::operator=(const HandleBase& rhs)
	{
		if (ID == rhs.ID)
			return *this;

		ClearReference();
		SetReference(rhs.ID);

		return *this;
	}

	void HandleBase::Copy(const HandleBase& original)
	{
		SetWeak(original.Weak);
		SetGlobal(original.Global);
		SetParent(original.Parent);
		SetID(original.ID);
	}

	bool HandleBase::IsNull() const
	{
		return ID == -1 || !Handles[ID].Used || Handles[ID].Data == nullptr;
	}

	void HandleBase::Erase()
	{
		SetID(-1);
	}

	const std::string& HandleBase::GetTypeName() const
	{
		TypeMap::iterator i = Types.find(GetTypeID());

		if (i != Types.end())
			return i->second.TypeName;
		else
			return BlankName;
	}

	bool HandleBase::operator==(const void* pointer) const
	{
		return (IsNull() && pointer == nullptr) || GetData() == pointer;
	}

	bool HandleBase::operator!=(const void* pointer) const
	{
		return !(*this == pointer);
	}

	bool HandleBase::operator==(const HandleBase& rhs) const
	{
		return ID == rhs.ID;
	}

	bool HandleBase::operator!=(const HandleBase& rhs) const
	{
		return ID != rhs.ID;
	}

	int HandleBase::CollectGarbage(bool quick)
	{
		if ((quick && CleanDeadHandles) || (!quick && GarbageClean))
			return 0;

		GarbageClean = !quick;

		CleanDeadHandles = true;
		Cleaned = 0;

		if (quick)
		{
			if (ReferencesRemoved < 0)
				ReferencesRemoved = 0;

			for (int i = 0; i < int(DeadHandles.size()); ++i)
				CleanReference(DeadHandles[i]);

			DeadHandles.clear();
			CleanDeadHandles = false;

			return Cleaned;
		}

		ReferencesRemoved = 0;

		DeadHandles.clear();

		for (int i = 0; i < int(LiveHandles.size()); ++i)
			Handles[LiveHandles[i]].Marked = false;

		for (int i = 0; i < int(Globals.size()); ++i)
			Sweep(Globals[i]);

		for (int i = 0; i < int(LiveHandles.size()); ++i)
			if (!Handles[LiveHandles[i]].Marked)
				CleanReference(LiveHandles[i]);

		CleanDeadHandles = false;

		return Cleaned;
	}

	int HandleBase::CleanUp()
	{
		Cleaned = 0;

		DeadHandles.clear();

		for (int i = 0; i < int(Handles.size()); ++i)
			Handles[i].Marked = false;

		for (int i = 0; i < int(Handles.size()); ++i)
			if (Handles[i].Used && !Handles[i].Marked)
				CleanReference(i);

		GarbageClean = true;
		CleanDeadHandles = false;

		return Cleaned;
	}

	HandleBase::HandleBase()
	{
	}

	int HandleBase::GetID() const
	{
		return ID;
	}

	void* HandleBase::GetData()
	{
		if (ID < 0 || ID >= int(Handles.size()))
			return nullptr;

		return Handles[ID].Data;
	}

	const void* HandleBase::GetData() const
	{
		if (ID < 0 || ID >= int(Handles.size()))
			return nullptr;

		return Handles[ID].Data;
	}

	void HandleBase::SetID(int newID)
	{
		ClearReference();
		SetReference(newID);
	}

	void HandleBase::SetWeak(bool isWeak)
	{
		if (Weak == isWeak)
			return;

		if (ID != -1)
		{
			if (isWeak)
				ReferenceRemoved(ID);
			else
				ReferenceAdded(ID);

			if (!Handles[ID].Used)
				ID = -1;
		}

		Weak = isWeak;
	}

	void HandleBase::SetGlobal(bool isGlobal)
	{
		if (Global == isGlobal)
			return;

		if (isGlobal)
			AddGlobalReference(this);
		else if (GlobalID != -1)
			RemoveGlobalReference(this);

		Global = isGlobal;
	}

	void HandleBase::SetParent(const HandleBase* parent)
	{
		if (parent != nullptr)
			SetParent(parent->ID);
		else
			SetParent(-1);
	}

	void HandleBase::SetParent(int parent)
	{
		if (Parent != -1)
			RemoveChild();

		Parent = parent;

		if (Parent != -1)
			AddChild();
	}

	void HandleBase::AddChild()
	{
		ChildID = int(Handles[Parent].Children.size());
		Handles[Parent].Children.push_back(this);
	}

	void HandleBase::RemoveChild()
	{
		if (ChildID >= 0 && ChildID <= int(Handles[Parent].Children.size()))
		{
			Handles[Parent].Children[ChildID] = Handles[Parent].Children[Handles[Parent].Children.size() - 1];
			Handles[Parent].Children[ChildID]->ChildID = ChildID;

			Handles[Parent].Children.pop_back();
		}
	}

	void HandleBase::Create(void* data, const HandleCallback& destructor)
	{
		int id = CreateReference();

		Handles[id].LiveID = int(LiveHandles.size());
		Handles[id].Data = data;
		Handles[id].Destructor = destructor;
		Handles[id].TypeID = GetTypeID();

		LiveHandles.push_back(id);

		SetID(id);
	}

	void HandleBase::RegisterInheritance(size_t typeID, TypeDefinition classes)
	{
		TypeMap::iterator i = Types.find(typeID);

		if (i == Types.end())
			Types[typeID] = classes;
	}

	void HandleBase::ClearReference()
	{
		if (ID == -1)
			return;


		if (!Weak)
			ReferenceRemoved(ID);
		
		if (ID != -1)
		{
			RemoveReference();
		
			if (Global)
				RemoveGlobalReference(this);
		}
		
		ID = -1;
	}

	void HandleBase::SetReference(int newID)
	{
		if (newID == -1 || newID >= int(Handles.size()))
			return;

		size_t typeID = GetTypeID();

		if (typeID != Handles[newID].TypeID)
		{
			TypeMap::iterator newType = Types.find(Handles[newID].TypeID);
			TypeMap::iterator type = Types.find(typeID);

			if (newType == Types.end() || type == Types.end() || newType->second.Classes < type->second.Classes)
				throw "Attempt to assign mismatching types; Expected '" + Types[typeID].TypeName + "', got '" + Types[Handles[newID].TypeID].TypeName + "'";
		}

		if (!Weak)
			ReferenceAdded(newID);
		
		AddReference(newID);

		ID = newID;

		if (Global && newID != -1)
			AddGlobalReference(this);
	}

	void HandleBase::AddReference(int newID)
	{
		LocalID = int(Handles[newID].Handles.size());
		Handles[newID].Handles.push_back(this);
	}

	void HandleBase::RemoveReference()
	{
		if (LocalID >= 0 && LocalID < int(Handles[ID].Handles.size()))
		{
			Handles[ID].Handles[LocalID] = Handles[ID].Handles[Handles[ID].Handles.size() - 1];
			Handles[ID].Handles[LocalID]->LocalID = LocalID;

			Handles[ID].Handles.pop_back();

			LocalID = -1;
		}
		else
			throw "what x2"; // this shit shouldnt happen
	}

	void HandleBase::Sweep(HandleBase* handle)
	{
		if (handle->ID == -1 || Handles[handle->ID].Marked)
			return;

		Handles[handle->ID].Marked = true;

		for (int i = 0; i < int(Handles[handle->ID].Children.size()); ++i)
			Sweep(Handles[handle->ID].Children[i]);
	}

	void HandleBase::AddGlobalReference(HandleBase* handle)
	{
		if (handle->ID == -1)
			return;

		handle->GlobalID = int(Globals.size());
		Globals.push_back(handle);
	}

	void HandleBase::RemoveGlobalReference(HandleBase* handle)
	{
		if (handle->GlobalID >= 0 && handle->GlobalID < int(Globals.size()))//(i != Globals.end())
		{
			Globals[handle->GlobalID] = Globals[Globals.size() - 1];
			Globals[handle->GlobalID]->GlobalID = handle->GlobalID;

			Globals.pop_back();

			handle->GlobalID = -1;
		}
		else
			throw "what"; // this shit shouldnt happen
	}

	int HandleBase::CreateReference()
	{
		if (Handles.size() > 0 && !Handles[0].Used)
		{
			ReserveReference(0);

			return 0;
		}
		if (Handles.size() > 0 && !Handles[0].ChildrenUsed)
		{
			int id = 0;

			while (Handles[id].Used)
			{
				int left = 2 * id + 1;
				int right = 2 * id + 2;

				if (left < int(Handles.size()) && (!Handles[left].Used || !Handles[left].ChildrenUsed))
					id = left;
				else if (right < int(Handles.size()) && (!Handles[right].Used || !Handles[right].ChildrenUsed))
					id = right;
			}

			ReserveReference(id);

			return id;
		}
		else
		{
			int id = int(Handles.size());

			Handles.push_back(HandleInfo());

			Handles[id].ChildrenUsed = true;

			ReserveReference(id);

			return id;
		}
	}

	void HandleBase::ReserveReference(int id)
	{
		Handles[id].Used = true;
		Handles[id].References = 0;

		id = (id - 1) / 2;

		while (id >= 0)
		{
			int left = 2 * id + 1;
			int right = 2 * id + 2;

			Handles[id].ChildrenUsed = (left >= int(Handles.size()) || Handles[left].ChildrenUsed) && (right >= int(Handles.size()) || Handles[right].ChildrenUsed);

			if (id == 0)
				id = -1;
			else
				id = (id - 1) / 2;
		}
	}

	void HandleBase::ReferenceAdded(int id)
	{
		++Handles[id].References;
	}

	void HandleBase::ReferenceRemoved(int id)
	{
		GarbageClean = false;

		--Handles[id].References;

		if (Handles[id].References == 0)
		{
			if (CleanDeadHandles)
				CleanReference(id);
			else
				DeadHandles.push_back(id);
		}
		else
			++ReferencesRemoved;
	}

	void HandleBase::CleanReference(int id)
	{
		if (CleaningReference)
			return;

		CleaningReference = true;

		++Cleaned;

		while (Handles[id].Handles.size() > 0)
			Handles[id].Handles[0]->SetID(-1);

		int liveID = Handles[id].LiveID;
		LiveHandles[liveID] = LiveHandles[LiveHandles.size() - 1];
		Handles[LiveHandles[liveID]].LiveID = liveID;

		LiveHandles.pop_back();

		Handles[id].LiveID = -1;
		Handles[id].Handles.clear();
		Handles[id].Destructor(Handles[id].Data);
		Handles[id].Used = false;
		id = (id - 1) / 2;

		while (id >= 0)
		{
			Handles[id].ChildrenUsed = false;

			if (id == 0)
				id = -1;
			else
				id = (id - 1) / 2;
		}

		CleaningReference = false;
	}
}
