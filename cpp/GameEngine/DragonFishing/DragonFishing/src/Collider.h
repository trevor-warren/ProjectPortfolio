#pragma once

#include "ObjectReflection.h"
#include "Object.h"
#include "Vector3.h"
#include "Aabb.h"

#include "GjkSupport.h"
#include "DebugDraw.h"

namespace Engine
{
 namespace ColliderType{
  enum ColliderType
  {
    NONE = 0,
    BOX,
    SPHERE,
    WEDGE,
    //CONE,
    COUNT
  };
 }

 namespace CollisionGroup{
  enum CollisionGroup
  {
    NONE = 0,
    PLAYER,
    DRAGON,
    DRAGON_PROXIMITY,
    TERRAIN,  // EXPECTED TO BE STATIC, IT WILL NEVER HAVE IT'S POSITION UPDATED
    COUNT
  };
 }

  class Collider : public Object
  {
  public:
    Matrix3 mTransform; // Contains offset, orientation, and dimensional data.
    Matrix3 mWorldTransform; // Concatination of collider transform and object transform, thus having the actual location in worldSpace

    ColliderType::ColliderType mColliderType = ColliderType::NONE;
    CollisionGroup::CollisionGroup mCollisionGroup = CollisionGroup::NONE;

    std::weak_ptr<DebugDraw> DebugDrawer;

    //union
    //{
      BoxSupport mBoxSupport;
      SphereSupport mSphereSupport;
      WedgeSupport mWedgeSupport;
    //};

    bool Added = false;
    int mID = -1;

    //Colider();
    ~Collider();
    void Initialize() {};
    void Update(float delta);
    void SetCollider(unsigned type, const Matrix3& transform);
    void ResetColliderType(unsigned type);
    void ResetTransform(const Matrix3& transform);
    void SetCollisionGroup(unsigned group);
    void AddToCDU();
    void RemoveFromCDU();
    void SetCollided(bool collide);
    bool GetCollided();
    Aabb GetBoundingBox() const;



    Instantiable;

    Inherits_Class(Object);

    Reflected(Collider);
  };

  //Class_Inherits(Collider, Object);
}
