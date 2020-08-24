#pragma once

#include "ObjectReflection.h"

#include "Object.h"
#include "Matrix3.h"

namespace GameLogic
{
  class PlayerLogic : public Engine::Object
  {
  public:
    Matrix3 OriginalTransform;
    float ImmunityTimer = 0.f;
    float ImmunityTime = 5.0f;
    bool immune = false;
    bool transformSet = false;

    void Initialize() {};
    void Update(float dt);


    Instantiable;
    Inherits_Class(Object);
    Reflected(PlayerLogic);
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
  //Class_Inherits(GameLogic::PlayerLogic, Object);
}
