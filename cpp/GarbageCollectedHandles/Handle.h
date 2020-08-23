#pragma once

#include <vector>
#include <string>
#include <functional>
#include <set>
#include <map>

#define Class_Base(ClassA) template<>\
struct TypeInfo<ClassA>\
{\
	static const int Height = 0;\
	\
	static size_t GetTypeID(int height)\
	{\
		return typeid(ClassA).hash_code();\
	}\
};\

#define Class_Inherits(ClassA, ClassB) template<>\
struct TypeInfo<ClassA>\
{\
	typedef ClassB Base;\
	\
	static const int Height = TypeInfo<Base>::Height + 1;\
	\
	static size_t GetTypeID(int height)\
	{\
		if (height == Height)\
			return typeid(ClassA).hash_code();\
		else\
			return TypeInfo<Base>::GetTypeID(height);\
	}\
};\

//namespace
//{
//	class dummy
//	{
//
//	};
//}

namespace Engine
{
	template<class T>
	struct TypeInfo;

	int CollectGarbage(bool quick = false);
	int CleanHandles();

	class HandleBase
	{
	public:
		HandleBase(HandleBase&& original) noexcept;
		~HandleBase();

		HandleBase& operator=(const HandleBase& rhs);
		HandleBase& operator=(HandleBase&& original);

		int GetID() const;
		void Copy(const HandleBase& original);
		bool IsNull() const;
		void Erase();
		virtual size_t GetTypeID() const = 0;
		const std::string& GetTypeName() const;

		bool operator==(const void* pointer) const;
		bool operator!=(const void* pointer) const;
		bool operator==(const HandleBase& rhs) const;
		bool operator!=(const HandleBase& rhs) const;

		static int CollectGarbage(bool quick = false);
		static int CleanUp();

	protected:
		HandleBase();

		void* GetData();
		typedef std::function<void(void* data)> HandleCallback;
		const void* GetData() const;
		void SetID(int newID);
		void SetWeak(bool isWeak);
		void SetGlobal(bool isGlobal);
		void SetParent(const HandleBase* parent);
		void SetParent(int parent);
		void AddChild();
		void RemoveChild();

		void Create(void* data, const HandleCallback& destructor);

		template <typename T>
		void Create(T* data, const std::function<void(T* data)>& destructor)
		{
			Create(data, [destructor](void* data)
			{
				destructor(reinterpret_cast<T*>(data));
			});
		}

		struct TypeDefinition
		{
			int Classes;
			const size_t* Data;
			std::string TypeName;
		};

		static void RegisterInheritance(size_t typeID, TypeDefinition classes);
		static size_t GetTypeFromID(int id)
		{
			if (id < 0 || id >= int(Handles.size()))
				return 0;

			return Handles[id].TypeID;
		}

	private:
		typedef std::vector<HandleBase*> HandleVector;

		HandleBase(const HandleBase&) { throw "no touchy"; }

		int Parent = -1;
		int ID = -1;
		int GlobalID = -1;
		int LocalID = -1;
		int ChildID = -1;
		bool Global = false;
		bool Weak = false;

		struct HandleInfo
		{
			bool ChildrenUsed = false;
			bool Used = false;
			bool Marked = false;
			int References = 0;
			int LiveID = -1;
			size_t TypeID = -1;
			void* Data = nullptr;
			HandleCallback Destructor;
			HandleVector Handles;
			HandleVector Children;
		};

		typedef std::vector<HandleInfo> HandleInfoVector;
		typedef std::map<size_t, TypeDefinition> TypeMap;
		typedef std::vector<int> IntVector;

		static bool CleaningReference;
		static bool GarbageClean;
		static HandleInfoVector Handles;
		static TypeMap Types;
		static HandleVector Globals;
		static HandleVector SweepQueue;
		static IntVector LiveHandles;
		static std::string BlankName;
		static IntVector DeadHandles;
		static bool CleanDeadHandles;
		static int ReferencesRemoved;
		static int Cleaned;

		void ClearReference();
		void SetReference(int newID);
		void AddReference(int newID);
		void RemoveReference();

		static void Sweep(HandleBase* handle);
		static void AddGlobalReference(HandleBase* handle);
		static void RemoveGlobalReference(HandleBase* handle);
		static int CreateReference();
		static void ReserveReference(int id);
		static void ReferenceAdded(int id);
		static void ReferenceRemoved(int id);
		static void CleanReference(int id);
	};

	class NullHandle : public HandleBase
	{
	public:
		NullHandle() {}
		size_t GetTypeID() const { return -1; }
	};

	class GenericHandle : public HandleBase
	{
	public:
		GenericHandle() {}
		GenericHandle(const HandleBase& original) : CurrentID(original.GetID()) { SetID(CurrentID); }
		GenericHandle(const GenericHandle& original) : CurrentID(original.GetID()) { SetID(CurrentID); }
		GenericHandle(int newID) : CurrentID(newID) { SetID(CurrentID); }

		size_t GetTypeID() const { return GetTypeFromID(CurrentID); }

		GenericHandle& operator=(const HandleBase& rhs) { CurrentID = rhs.GetID(); HandleBase::operator=(rhs); return *this; }
		GenericHandle& operator=(const GenericHandle& rhs) { CurrentID = rhs.GetID(); HandleBase::operator=(rhs); return *this; }

	private:
		int CurrentID = -1;
	};

	class GenericWeakHandle : public HandleBase
	{
	public:
		GenericWeakHandle()
		{
			HandleBase::SetGlobal(false);
		}

		GenericWeakHandle(const HandleBase& original) : CurrentID(original.GetID())
		{
			HandleBase::SetGlobal(false);
			SetID(CurrentID);
		}

		GenericWeakHandle(const GenericWeakHandle& original) : CurrentID(original.GetID())
		{
			HandleBase::SetGlobal(false);
			SetID(CurrentID);
		}

		GenericWeakHandle(int newID) : CurrentID(newID)
		{
			HandleBase::SetGlobal(false);
			SetID(CurrentID);
		}

		size_t GetTypeID() const { return GetTypeFromID(CurrentID); }

		GenericWeakHandle& operator=(const HandleBase& rhs)
		{
			CurrentID = rhs.GetID();
			HandleBase::operator=(rhs);
			return *this;
		}

		GenericWeakHandle& operator=(const GenericWeakHandle& rhs)
		{
			CurrentID = rhs.GetID();
			HandleBase::operator=(rhs);
			return *this;
		}

	private:
		int CurrentID = -1;
	};

	class GenericMemberHandle : public HandleBase
	{
	public:
		GenericMemberHandle()
		{
			HandleBase::SetGlobal(false);
		}

		GenericMemberHandle(const HandleBase& original) : CurrentID(original.GetID())
		{
			HandleBase::SetGlobal(false);
			SetID(CurrentID);
		}

		GenericMemberHandle(const GenericMemberHandle& original) : CurrentID(original.GetID())
		{
			HandleBase::SetGlobal(false);
			SetID(CurrentID);
		}

		GenericMemberHandle(int newID) : CurrentID(newID)
		{
			HandleBase::SetGlobal(false);
			SetID(CurrentID);
		}

		size_t GetTypeID() const { return GetTypeFromID(CurrentID); }
		void SetParent(const HandleBase& parent) { HandleBase::SetParent(&parent); }

		GenericMemberHandle& operator=(const HandleBase& rhs)
		{
			CurrentID = rhs.GetID();
			HandleBase::operator=(rhs);
			return *this;
		}

		GenericMemberHandle& operator=(const GenericMemberHandle& rhs)
		{
			CurrentID = rhs.GetID();
			HandleBase::operator=(rhs);
			return *this;
		}

	private:
		int CurrentID = -1;
	};

	extern NullHandle Null;

	template <typename T>
	class Handle : public HandleBase
	{
	public:
		typedef std::function<void(T* data)> DestructorCallback;

		Handle();
		Handle(Handle&& original) noexcept : HandleBase(std::move(original)) {}
		Handle(T* data, const DestructorCallback& destructor);
		Handle(const Handle& original);
		Handle(const HandleBase& original);
		Handle(int newID);

		T* operator->();
		const T* operator->() const;

		size_t GetTypeID() const;

		bool operator<(const Handle<T>& other) const { return GetID() < other.GetID(); }

		T* GetData() { return reinterpret_cast<T*>(HandleBase::GetData()); }
		const T* GetData() const { return reinterpret_cast<const T*>(HandleBase::GetData()); }

		Handle& operator=(const HandleBase& rhs) { HandleBase::operator=(rhs); return *this; }
		Handle& operator=(const Handle& rhs) { HandleBase::operator=(rhs); return *this; }

	protected:
		Handle(bool isGlobal);

	private:
		static size_t TypeID;
		static size_t Inherits[TypeInfo<T>::Height + 1];
		static bool InitializedInheritance;

		static void Initialize();
	};

	template <typename T>
	class WeakHandle : public Handle<T>
	{
	public:
		WeakHandle();
		WeakHandle(WeakHandle&& original) noexcept : Handle<T>(std::move(original)) {}
		WeakHandle(const WeakHandle& original);
		WeakHandle(const Handle<T>& original);
		WeakHandle(const HandleBase& original);
		WeakHandle(int newID);

		T* operator->();
		const T* operator->() const;

		bool operator==(const void* pointer) const { return HandleBase::operator==(pointer); }
		bool operator!=(const void* pointer) const { return HandleBase::operator!=(pointer); }
		bool operator==(const HandleBase& handle) const { return HandleBase::operator==(handle); }
		bool operator!=(const HandleBase& handle) const { return HandleBase::operator!=(handle); }

		T* GetData() { return reinterpret_cast<T*>(HandleBase::GetData()); }
		const T* GetData() const { return reinterpret_cast<const T*>(HandleBase::GetData()); }

		WeakHandle& operator=(const HandleBase& rhs) { HandleBase::operator=(rhs); return *this; }
		WeakHandle& operator=(const WeakHandle& rhs) { HandleBase::operator=(rhs); return *this; }
	};

	template <typename T>
	class MemberHandle : public Handle<T>
	{
	public:
		MemberHandle();
		MemberHandle(MemberHandle&& original) noexcept : Handle<T>(std::move(original)) {}
		MemberHandle(const MemberHandle& original);
		MemberHandle(HandleBase& parent);
		MemberHandle(const MemberHandle& original, HandleBase& parent);
		MemberHandle(const Handle<T>& original, HandleBase& parent);
		MemberHandle(const HandleBase& original, HandleBase& parent);
		MemberHandle(int newID, HandleBase& parent);

		void SetParent(const HandleBase& parent);

		T* operator->();
		const T* operator->() const;

		T* GetData() { return reinterpret_cast<T*>(HandleBase::GetData()); }
		const T* GetData() const { return reinterpret_cast<const T*>(HandleBase::GetData()); }

		MemberHandle& operator=(const HandleBase& rhs) { HandleBase::operator=(rhs); return *this; }
		MemberHandle& operator=(const MemberHandle& rhs) { HandleBase::operator=(rhs); return *this; }
	};

	template<typename T>
	size_t Handle<T>::TypeID = typeid(T).hash_code();

	template<typename T>
	size_t Handle<T>::Inherits[TypeInfo<T>::Height + 1] = { 0 };

	template<typename T>
	bool Handle<T>::InitializedInheritance = false;

	template<typename T>
	Handle<T>::Handle() : HandleBase()
	{
		Initialize();
		HandleBase::SetGlobal(true);
	}

	template<typename T>
	Handle<T>::Handle(T* data, const DestructorCallback& destructor) : HandleBase()
	{
		Initialize();
		HandleBase::SetGlobal(true);
		Create<T>(data, destructor);
	}

	template<typename T>
	Handle<T>::Handle(const Handle& original) : HandleBase()
	{
		Initialize();
		HandleBase::SetGlobal(true);
		HandleBase::operator=(original);
	}

	template<typename T>
	Handle<T>::Handle(const HandleBase& original) : HandleBase()
	{
		Initialize();
		HandleBase::SetGlobal(true);
		HandleBase::operator=(original);
	}

	template<typename T>
	Handle<T>::Handle(int newID) : HandleBase()
	{
		Initialize();
		HandleBase::SetGlobal(true);
		SetID(newID);
	}

	template<typename T>
	T* Handle<T>::operator->()
	{
		T* data = reinterpret_cast<T*>(HandleBase::GetData());

		if (data == nullptr)
			throw "Attempt to dereference null pointer";

		return data;
	}
	
	template<typename T>
	const T* Handle<T>::operator->() const
	{
		const T* data = reinterpret_cast<const T*>(HandleBase::GetData());

		if (data == nullptr)
			throw "Attempt to dereference null pointer";

		return data;
	}
	
	template<typename T>
	size_t Handle<T>::GetTypeID() const
	{
		return TypeID;
	}

	template<typename T>
	void Handle<T>::Initialize()
	{
		if (InitializedInheritance)
			return;

		for (int i = 0; i <= TypeInfo<T>::Height; ++i)
			Inherits[i] = TypeInfo<T>::GetTypeID(i);

		InitializedInheritance = true;

		HandleBase::RegisterInheritance(typeid(T).hash_code(), TypeDefinition{ TypeInfo<T>::Height + 1, Inherits, typeid(T).name() });
	}

	template<typename T>
	Handle<T>::Handle(bool isGlobal) : HandleBase()
	{
		Initialize();
		HandleBase::SetGlobal(isGlobal);
	}

	template<typename T>
	WeakHandle<T>::WeakHandle() : Handle<T>(false)
	{
		HandleBase::SetWeak(true);
	}

	template<typename T>
	WeakHandle<T>::WeakHandle(const WeakHandle<T>& original) : Handle<T>(false)
	{
		HandleBase::SetWeak(true);

		HandleBase::operator=(original);
	}

	template<typename T>
	WeakHandle<T>::WeakHandle(const Handle<T>& original) : Handle<T>(false)
	{
		HandleBase::SetWeak(true);

		HandleBase::operator=(original);
	}

	template<typename T>
	WeakHandle<T>::WeakHandle(const HandleBase& original) : Handle<T>(false)
	{
		HandleBase::SetWeak(true);

		HandleBase::operator=(original);
	}

	template<typename T>
	WeakHandle<T>::WeakHandle(int newID) : Handle<T>()
	{
		HandleBase::SetWeak(true);

		HandleBase::SetID(newID);
	}

	template<typename T>
	T* WeakHandle<T>::operator->()
	{
		T* data = reinterpret_cast<T*>(HandleBase::GetData());

		if (data == nullptr)
			throw "Attempt to dereference null pointer";

		return data;
	}

	template<typename T>
	const T* WeakHandle<T>::operator->() const
	{
		const T* data = reinterpret_cast<const T*>(HandleBase::GetData());

		if (data == nullptr)
			throw "Attempt to dereference null pointer";

		return data;
	}

	template<typename T>
	MemberHandle<T>::MemberHandle() : Handle<T>(false)
	{
	}

	template<typename T>
	MemberHandle<T>::MemberHandle(const MemberHandle& parent) : Handle<T>(false)
	{
		HandleBase::Copy(parent);
	}

	template<typename T>
	MemberHandle<T>::MemberHandle(HandleBase& parent) : Handle<T>(false)
	{
		HandleBase::SetParent(&parent);
	}

	template<typename T>
	MemberHandle<T>::MemberHandle(const MemberHandle<T>& original, HandleBase& parent) : Handle<T>(false)
	{
		HandleBase::SetParent(&parent);

		HandleBase::operator=(original);
	}

	template<typename T>
	MemberHandle<T>::MemberHandle(const Handle<T>& original, HandleBase& parent) : Handle<T>(false)
	{
		HandleBase::SetParent(&parent);

		HandleBase::operator=(original);
	}

	template<typename T>
	MemberHandle<T>::MemberHandle(const HandleBase& original, HandleBase& parent) : Handle<T>(false)
	{
		HandleBase::SetParent(&parent);

		HandleBase::operator=(original);
	}

	template<typename T>
	MemberHandle<T>::MemberHandle(int newID, HandleBase& parent) : Handle<T>(false)
	{
		HandleBase::SetParent(&parent);

		HandleBase::SetID(newID);
	}

	template<typename T>
	void MemberHandle<T>::SetParent(const HandleBase& parent)
	{
		HandleBase::SetParent(&parent);
	}

	template<typename T>
	T* MemberHandle<T>::operator->()
	{
		T* data = reinterpret_cast<T*>(HandleBase::GetData());

		if (data == nullptr)
			throw "Attempt to dereference null pointer";

		return data;
	}

	template<typename T>
	const T* MemberHandle<T>::operator->() const
	{
		const T* data = reinterpret_cast<const T*>(HandleBase::GetData());

		if (data == nullptr)
			throw "Attempt to dereference null pointer";

		return data;
	}
}

template<typename T>
using Handle = Engine::Handle<T>;

template<typename T>
using WeakHandle = Engine::WeakHandle<T>;

template<typename T>
using MemberHandle = Engine::MemberHandle<T>;

typedef Engine::HandleBase HandleBase;
typedef Engine::GenericHandle GenericHandle;
typedef Engine::GenericWeakHandle GenericWeakHandle;
typedef Engine::GenericMemberHandle GenericMemberHandle;
