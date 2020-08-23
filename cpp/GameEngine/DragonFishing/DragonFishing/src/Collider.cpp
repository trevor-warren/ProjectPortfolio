#include "Collider.h"
#include "CollisionDetectionUnit.h"
#include "Transform.h"

namespace Engine
{
  Collider::~Collider()
  {
    if (Added)
      RemoveFromCDU();
  }

  void Collider::Update(float delta)
  {
      std::shared_ptr<Engine::Transform> trans = GetComponent<Engine::Transform>();
    if (trans == nullptr)
      return;

    mWorldTransform = trans->GetWorldTransformation() * mTransform;

    if (!DebugDrawer.expired())
    {
      switch (mColliderType)
      {
      case ColliderType::BOX:
        mBoxSupport.DrawDebug(DebugDrawer.lock(), mCollisionGroup);
        break;
      case ColliderType::WEDGE:
        mWedgeSupport.DrawDebug(DebugDrawer.lock(), mCollisionGroup);
        break;
      case ColliderType::SPHERE:
        mSphereSupport.DrawDebug(DebugDrawer.lock(), mCollisionGroup);
        break;

      default:
        break;
      }
    }
  }

  void Collider::SetCollider(unsigned type, const Matrix3& transform)
  {
    mColliderType = ColliderType::ColliderType(type);
    mTransform = transform;
    std::shared_ptr<Engine::Transform> trans = GetComponent<Engine::Transform>();
    if (trans == nullptr)
      mWorldTransform = mTransform;

    else
      mWorldTransform = trans->GetWorldTransformation() * mTransform;

    switch (mColliderType)
    {
    case ColliderType::BOX:
    {
      mBoxSupport = BoxSupport(&mWorldTransform);
    } 
      break;

    case ColliderType::WEDGE:
    {
      mWedgeSupport = WedgeSupport(&mWorldTransform);
    }
      break;

    case ColliderType::SPHERE:
    {
      mSphereSupport = SphereSupport(&mWorldTransform);
    }
      break;

    default:
      break;
    }
  }

  void Collider::ResetColliderType(unsigned type)
  {
    SetCollider(type, mTransform);
  }

  void Collider::ResetTransform(const Matrix3 & transform)
  {
    mTransform = transform;
    std::shared_ptr<Engine::Transform> trans = GetComponent<Engine::Transform>();
    if (trans == nullptr)
      mWorldTransform = mTransform;

    else
      mWorldTransform = mTransform * trans->GetWorldTransformation();
  }

  void Collider::SetCollisionGroup(unsigned group)
  {
    //if(Added)
    // RemoveFromCDU();
    mCollisionGroup = CollisionGroup::CollisionGroup(group);

    //AddToCDU();
  }

  void Collider::AddToCDU()
  {
    if (!Added && CDU != nullptr)
      Added = CDU->AddCollider(this);
  }

  void Collider::RemoveFromCDU()
  {
    if(CDU != nullptr)
     CDU->RemoveCollider(this);
  }

  void Collider::SetCollided(bool collide)
  {
    switch (mColliderType)
    {
    case ColliderType::BOX:
      mBoxSupport.collided = collide;
      break;
    case ColliderType::WEDGE:
      mWedgeSupport.collided = collide;
      break;
    case ColliderType::SPHERE:
      mSphereSupport.collided = collide;
      break;

    default:
      break;
    }
  }

  bool Collider::GetCollided()
  {
    switch (mColliderType)
    {
    case ColliderType::BOX:
      return mBoxSupport.collided;
      break;
    case ColliderType::WEDGE:
      return mWedgeSupport.collided;
      break;
    case ColliderType::SPHERE:
      return mSphereSupport.collided;
      break;

    default:
      break;
    }

    return false;
  }

  Aabb Collider::GetBoundingBox() const
  {
    Vector3 center, half_dimensions;

    center = mWorldTransform.Translation();

    switch (mColliderType)
    {
    case ColliderType::BOX:
    case ColliderType::WEDGE:
      half_dimensions = mWorldTransform.ExtractScale();
      break;

    case ColliderType::SPHERE:
    {
      float side_length = mSphereSupport.GetRadius();
      half_dimensions = Vector3(side_length, side_length, side_length);
      break;
    }
    
    default:
      break;
    }

    Aabb result(center - half_dimensions, center + half_dimensions);

    return result;
  }
}