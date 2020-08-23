#include "PlayerLogic.h"
#include "Model.h"
#include "CollisionDetectionUnit.h"
#include "Transform.h"

namespace GameLogic
{
  void PlayerLogic::Update(float dt)
  {
    if (!Engine::CDU)
      return;

    std::shared_ptr<Engine::Transform> transform = GetComponent<Engine::Transform>();

    if (transform == nullptr|| transform->IsStatic)
      return;

    // Get the original transform once
    if (!transformSet)
    {
      OriginalTransform = transform->Transformation;
      transformSet = true;
    }

    // "Kill" the player
    if (!immune && Engine::CDU->PlayerDragonCollision || Engine::CDU->PlayerTerrainCollision)
    {
      immune = true;
      //transform->Transformation = OriginalTransform;

      std::shared_ptr<GraphicsEngine::Model> model = GetComponent<GraphicsEngine::Model>();
      
      if (model != nullptr)
        model->Color.A = 0.75;
    }

    // Become "immune" for a few seconds
    if (immune)
    {
      ImmunityTimer += dt;

      if (ImmunityTimer > ImmunityTime)
      {
        ImmunityTimer = 0;
        immune = false;

        std::shared_ptr<GraphicsEngine::Model> model = GetComponent<GraphicsEngine::Model>();

        if (model != nullptr)
          model->Color.A = 1;
      }
    }
  }
}