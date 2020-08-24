#pragma once

#include "ObjectReflection.h"

#include "Object.h"

#include "Vector3.h"
#include <random>

namespace GameLogic
{
  class WormSegment : public Engine::Object
  {
  public:
    float Speed;
    float Acceleration;
    Vector3 TargetDirection = Vector3(0, 0, 1);
    Vector3 Boundaries;
    Vector3 Velocity;

    std::weak_ptr<Object> PreviousSegment;

    float DirectionChangeTimer = 0;
    float DirectionChangeTime = 5.0f;

    static std::mt19937 mt;
    static std::uniform_real_distribution<float> dist_dir;
    static std::uniform_real_distribution<float> dist_time;

    void Initialize();
    void Update(float dt);
    void SetSpeed(float speed);
    void SetAcceleration(float acceleration);
    void SetBoundaries(const Vector3& bounds);

    void ChooseNewTargetDirection();

    Instantiable;
    Inherits_Class(Object);
    Reflected(WormSegment);
  };
}

namespace Engine
{
  /*
  These must be in namespace Engine.
  These register class inheritance hierarchy meta data for Handles to use internally in type deduction.
  These are required to be used before using any Handles that reference that type.
  To make an object that contains handles that reference its own type, look at Object & ObjectBase's base class workaround.
  */
  //Class_Inherits(GameLogic::WormSegment, Object);
}
