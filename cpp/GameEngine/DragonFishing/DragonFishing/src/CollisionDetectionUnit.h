#pragma once

#include "GJK.h"
#include "AabbTree.h"

namespace Engine
{
  class Collider;

  class CollisionDetectionUnit
  {
    Collider* PlayerCollider = nullptr;               // 
    std::vector<Collider*> DragonColliders;           // Pointers to all the colliders to use in collision detection
    std::vector<Collider*> DragonProximityColliders;  // 
    // Collider* DragonBreathCollider;                //
    AabbTree TerrainColliders;                        // 
    AabbTree PlayerTree;                              // Prevent re-allocation of fake AabbTree for the PlayerCollider

    Gjk mGJK;
    Gjk::CsoPoint useless; // Dummy variable to prevent allocation as we currently stop at collision detection so it isn't really necessary


  public:
    CollisionDetectionUnit();
    ~CollisionDetectionUnit();
    void Update();
    bool AddCollider(Collider * collider);
    void RemoveCollider(Collider * collider);
    bool TestCollision(Collider* lhs, Collider* rhs);

    // Bools that are updated as a register player collider collides with another registered collider
    bool PlayerDragonCollision = false;  // Did the player collide with the dragon?
    bool PlayerCloseToDragon = false;    // Is the player close to a dragon segment?
    bool PlayerTerrainCollision = false; // Did the player just fucking crash?
  };

  extern CollisionDetectionUnit* CDU;
}
