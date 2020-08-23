#include "WormSegment.h"
#include "PhysicsBody.h"
#include "Constants.h"
#include "Transform.h"
#include <time.h>

#define EPSILON 0.000001f

namespace GameLogic
{
  std::mt19937 WormSegment::mt(static_cast<unsigned>(time(0)));
  std::uniform_real_distribution<float> WormSegment::dist_dir(-1.f, 1.f);
  std::uniform_real_distribution<float> WormSegment::dist_time(2.f, 6.f);

  void WormSegment::Initialize(){}

  void WormSegment::Update(float dt)
  {
      std::shared_ptr<Engine::Transform> trans = GetComponent<Engine::Transform>();
    if (trans == nullptr)
      return;

    std::shared_ptr<Engine::PhysicsBody> physicsBody = GetComponent<Engine::PhysicsBody>();
    if (physicsBody == nullptr)
      return;

    const Matrix3& worldTransform = trans->GetWorldTransformation();
    Vector3 position = worldTransform.Translation();
    Vector3 velocity;

    // The head segment's move direction
    if (PreviousSegment.expired())
    {
      // Pick a new direction to go in everytime the timer exceeds the change time
      DirectionChangeTimer += dt;
      if (DirectionChangeTimer > DirectionChangeTime)
      {
        DirectionChangeTimer = 0;
        DirectionChangeTime = dist_time(mt);
        ChooseNewTargetDirection();
      }

      // Move in the direction
      Velocity = Speed * TargetDirection;
      physicsBody->Velocity = Velocity;

      // Face the direction of movement. Will probably appear janky, but good enough
      trans->Transformation.Face(position, TargetDirection);
    }

    // Make the other segment's follow after
    else
    {
      auto prevSegTrans = PreviousSegment.lock()->GetComponent<Engine::Transform>();
      if (prevSegTrans == nullptr)
        return;

      Vector3 prevSegmentPos, previousPos, newPosition;

      const Matrix3& pSegWorldTransform = prevSegTrans->GetWorldTransformation();
      velocity = PreviousSegment.lock()->Cast<WormSegment>()->Velocity;
      prevSegmentPos = pSegWorldTransform.Translation();
      previousPos = position;
      newPosition = previousPos;

      //float previousSegmentSizeY = prevSegTrans->Transformation.FrontVector().Length() *  PreviousSegment->GetComponent<Engine::PhysicsBody>()->GetBoundingBox().GetSize().Y / 2;
      Vector3 prevSegBackPos = prevSegmentPos + pSegWorldTransform.FrontVector();

      // Fuck it, this never worked
	    float segmentSizeY = worldTransform.FrontVector().Length();//worldTransform.FrontVector().Length() * physicsBody->GetBoundingBox().GetSize().Y / 2;

      Vector3 offset = position - prevSegBackPos;

      if (offset.Length() > EPSILON)
      {
        Vector3 direction = offset.Normalize();
        //direction += velocity * -dt;
       // direction.Normalize();

		    newPosition = prevSegBackPos + segmentSizeY * direction;// *segmentSizeY;
        trans->SetPosition(newPosition);
        Vector3 offsetFromTarget = prevSegBackPos - position;
        trans->Transformation.Face(newPosition, -direction);
        //this.Owner.Transform.RotateAnglesLocal(Real3(0, 0, Math.ATan2(-offsetFromTargetPosition.X, offsetFromTargetPosition.Y) - this.Owner.Transform.EulerAngles.Z));
      }

      if (dt > EPSILON)
        Velocity = (newPosition - previousPos) * (1 / dt);
      else
       Velocity = (newPosition - previousPos) * (30);

      //std::cout << "Segment " << FindIndex() << " has position: " << newPosition << std::endl;
      //std::cout << "Was previously at position: " << previousPos << std::endl;
      //std::cout << "Previous Segment is Segment " << PreviousSegment->FindIndex() << std::endl;
      //std::cout << "Previous Segment position: "  << prevSegmentPos << std::endl;
      //std::cout << "Previous Segment back position: " << prevSegBackPos << std::endl;
      //std::cout << "My ObjectID " << GetObjectID() << std::endl;
      //std::cout << "Previous Segment ObjectID " << PreviousSegment->GetObjectID() << std::endl << std::endl;

      //physicsBody->Velocity = Vector3();
    }
  }

  void WormSegment::SetSpeed(float speed)
  {
    Speed = speed;
  }

  void WormSegment::SetAcceleration(float acceleration)
  {
    Acceleration = acceleration;
  }

  void WormSegment::ChooseNewTargetDirection()
  {
      std::shared_ptr<Engine::Transform> trans = GetComponent<Engine::Transform>();
    if (trans == nullptr)
      return;

    Vector3 position = trans->Transformation.Translation();

    // Randomly pick a direction
    Vector3 direction = Vector3(dist_dir(mt), dist_dir(mt) / 3, dist_dir(mt));
    direction.Normalize();


    // If you're too far out and the current direction would take you farther, fix that
    if (fabsf(position[0]) > Boundaries[0] && signbit(position[0]) == signbit(direction[0]))
      direction[0] *= -1;

    if (fabsf(position[1] - 50) > Boundaries[1] && signbit(position[1] - 50) == signbit(direction[1]))
      direction[1] *= -1;

    if (fabsf(position[2]) > Boundaries[2] && signbit(position[2]) == signbit(direction[2]))
      direction[2] *= -1;

    TargetDirection = direction;
  }

  void WormSegment::SetBoundaries(const Vector3& bounds)
  {
    Boundaries = bounds;
  }
}
