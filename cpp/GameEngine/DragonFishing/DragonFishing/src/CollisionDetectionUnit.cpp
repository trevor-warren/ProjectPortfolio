#include "CollisionDetectionUnit.h"
#include "Collider.h"

namespace Engine
{
  CollisionDetectionUnit* CDU = nullptr;

  CollisionDetectionUnit::CollisionDetectionUnit()
  {
    // Creating more than one will not overwrite the original CDU. Additional CDUs are essentially
    // useless and only take up more memory.
    if(CDU == nullptr) 
     CDU = this;

  }

  CollisionDetectionUnit::~CollisionDetectionUnit()
  {
    // Small sanity check to make sure that if more than one CDU was made but the non-active
    // one gets destroyed, it doesn't suddenly ruin the whole thing
    if (CDU == this) 
      CDU = nullptr;
  }

  void CollisionDetectionUnit::Update()
  {
    // Reset the variables for the frame
    PlayerDragonCollision = false;
    PlayerCloseToDragon = false;
    PlayerTerrainCollision = false;

    // Don't even bother if the player collider doesn't exist
    if (!PlayerCollider)
      return;

    // Update tree position for Player
    PlayerTree.Update(PlayerCollider->mID, PlayerCollider->GetBoundingBox());

    for (auto dragonCollider : DragonColliders)
    {
      if (TestCollision(PlayerCollider, dragonCollider))
      {
        PlayerDragonCollision = true;
        dragonCollider->SetCollided(true);
      }
      else
        dragonCollider->SetCollided(false);

    }

    for (auto dragonProximityCollider : DragonProximityColliders)
    {
      if (TestCollision(PlayerCollider, dragonProximityCollider))
      {
        PlayerCloseToDragon = true;
        break;
      }
    }

    auto terrainCollisionCheck = [&](const AabbTree::Node* node1, const AabbTree::Node* node2) {
      if (TestCollision(reinterpret_cast<Collider*>(node1->ClientData), reinterpret_cast<Collider*>(node2->ClientData)))
        PlayerTerrainCollision = true;
    };

    PlayerTree.PairQuery(TerrainColliders, terrainCollisionCheck);

    if(PlayerDragonCollision || PlayerTerrainCollision)
      PlayerCollider->SetCollided(true);
    else
      PlayerCollider->SetCollided(false);
  }

  bool CollisionDetectionUnit::AddCollider(Collider * collider)
  {
    if (collider->mCollisionGroup == CollisionGroup::NONE)
      return false;

    else if (collider->mCollisionGroup == CollisionGroup::PLAYER)
    {
      PlayerCollider = collider;
      collider->mID = PlayerTree.Insert(&collider, collider->GetBoundingBox());
      return true;
    }

    else if (collider->mCollisionGroup == CollisionGroup::DRAGON)
    {
      DragonColliders.push_back(collider);
      return true;
    }

    else if (collider->mCollisionGroup == CollisionGroup::TERRAIN)
    {
      collider->mID = TerrainColliders.Insert(&collider, collider->GetBoundingBox());
      return true;
    }

    // ADD NEW COLLIDER STUFF HERE
    
    return false;
  }

  void CollisionDetectionUnit::RemoveCollider(Collider * collider)
  {
    if (collider->mCollisionGroup == CollisionGroup::PLAYER)
      PlayerCollider = nullptr;

    else if (collider->mCollisionGroup == CollisionGroup::DRAGON)
    {
      for (unsigned i = 0; i < DragonColliders.size(); ++i)
        if (DragonColliders[i] == collider)
        {
          std::swap(DragonColliders[i], DragonColliders.back());
          DragonColliders.pop_back();
          return;
        }
    }

    else if (collider->mCollisionGroup == CollisionGroup::TERRAIN)
    {
      if (collider->mID >= 0)
      {
        TerrainColliders.Remove(collider->mID);
      }

      collider->mID = -1;
    }
  }
  
  bool CollisionDetectionUnit::TestCollision(Collider * A, Collider * B)
  {
    if (A == nullptr || B == nullptr)
      return false;

    SupportShape* aSupport = nullptr;
    SupportShape* bSupport = nullptr;

    switch (A->mColliderType)
    {
    case ColliderType::BOX:
      aSupport = &(A->mBoxSupport);
      break;

    case ColliderType::WEDGE:
      aSupport = &(A->mWedgeSupport);
      break;

    case ColliderType::SPHERE:
      aSupport = &(A->mSphereSupport);
      break;
    }

    switch (B->mColliderType)
    {
    case ColliderType::BOX:
      bSupport = &(B->mBoxSupport);
      break;

    case ColliderType::WEDGE:
      bSupport = &(B->mWedgeSupport);
      break;

    case ColliderType::SPHERE:
      bSupport = &(B->mSphereSupport);
      break;
    }

    if(aSupport == nullptr || bSupport == nullptr)
      return false;

    return mGJK.Intersect(aSupport, bSupport, 20, useless);
  }
}
