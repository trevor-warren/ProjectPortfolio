#include "PhysicsBody.h"

#include "Transform.h"
#include "Model.h"

namespace Engine
{
  AabbTree PhysicsBody::PhysicsScene = AabbTree();

  PhysicsBody::~PhysicsBody()
  {
    if (mID != -1)
      PhysicsScene.Remove(mID);
  }

  void PhysicsBody::Initialize()
  {
    mID = -1;
  }

  void PhysicsBody::Update(float delta)
  {
    std::shared_ptr<Transform> transform = GetComponent<Transform>();

    if (transform == nullptr || transform->IsStatic)
      return;

    Velocity += delta * Acceleration;

    transform->Move(delta * Velocity);

    // The following failed dramatically because the tree would always fail
    // to access the root after trying to update a single node, causing the
    // thing to immediately crash

    //WeakHandle<GraphicsEngine::Model> model = GetComponent<GraphicsEngine::Model>();
    //if (model.IsNull())
    //  return;
    //
    //auto aabb = model->GetBoundingBox();
    //
    //if (mID == -1)
    //{
    //  mID = PhysicsScene.Insert(this, aabb);
    //  return;
    //}
    //
    //PhysicsScene.Update(mID, aabb);
  }
  Aabb PhysicsBody::GetBoundingBox() const
  {
      std::shared_ptr<GraphicsEngine::Model> model = GetComponent<GraphicsEngine::Model>();
    if (model == nullptr)
      return Aabb();
    
    return model->GetBoundingBox();
    //return Aabb();
  }
}