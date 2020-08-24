#include "Aabb.h"
#include "GjkSupport.h"
#include "CollisionDetectionUnit.h"

namespace Engine
{
  //-----------------------------------------------------------------------------SupportShape
  Vector3 SupportShape::GetCenter(const std::vector<Vector3>& localPoints, const Matrix3& transform) const
  {
    Aabb abb;
    abb.Compute(localPoints);

    Vector3 center = abb.GetCenter();
    center.W = 1;
    center = transform * center;
    return center;
  }

  Vector3 SupportShape::Support(const Vector3& worldDirection, const std::vector<Vector3>& localPoints, const Matrix3& localToWorldTransform) const
  {
    Vector3 localSpaceDirection = localToWorldTransform.Inverted() * worldDirection;


    float dotP, maxDistance = -FLT_MAX;
    Vector3 result = Vector3();

    Aabb abb;
    abb.Compute(localPoints);
    Vector3 localCenter = abb.GetCenter();
    Vector3 toPoint;

    for (unsigned i = 0; i < localPoints.size(); ++i)
    {
      toPoint = localPoints[i] - localCenter;
      dotP = toPoint.Dot(localSpaceDirection);

      if (dotP > maxDistance)
      {
        maxDistance = dotP;
        result = localPoints[i];
      }

    }

    result.W = 1;
    result = localToWorldTransform * result;
    return result;
  }

  
  //-----------------------------------------------------------------------------SphereSupport
  SphereSupport::SphereSupport(Matrix3* transform) : mTransform(transform) {}
  
  Vector3 SphereSupport::GetCenter() const
  {
    return mTransform->Translation();
  }

  Vector3 SphereSupport::Support(const Vector3& worldDirection) const
  {
    Vector3 support = worldDirection;
    support.Normalize();

    support = GetRadius() * support + GetCenter();

    return support;
  }

  void SphereSupport::DrawDebug(const std::shared_ptr<DebugDraw>& DebugDrawer, unsigned Group) const
  {
    Vector3 center = GetCenter();
    float radius   = GetRadius();
    Vector3 right  = mTransform->RightVector();
    Vector3 up     = mTransform->UpVector();
    Vector3 front  = mTransform->FrontVector();

    right.Normalize();
    right *= radius;
    up.Normalize();
    up *= radius;
    front.Normalize();
    front *= radius;

    // This is a sphere so I can't really start drawing it easily. I just draw the diameter in the direction of each axis
    DebugDrawer->DrawLine(center - right, center + right);
    DebugDrawer->DrawLine(center - up, center + up);
    DebugDrawer->DrawLine(center - front, center + front);
  }

  float SphereSupport::GetRadius() const
  {
    float radius;
    Vector3 r = mTransform->ExtractScale();

    if (r.X > r.Y && r.X > r.Z)
      radius = r.X;

    else if (r.Y > r.Z)
      radius = r.Y;

    else
      radius = r.Z;

    return radius;
  }


  //-----------------------------------------------------------------------------BoxSupport
  BoxSupport::BoxSupport(Matrix3 * transform) : mTransform(transform) {}

  Vector3 BoxSupport::GetCenter() const
  {
    return mTransform->Translation();
  }

  Vector3 BoxSupport::Support(const Vector3& worldDirection) const
  {
    Vector3 localSpaceDirection = mTransform->Inverted()* worldDirection;

    Vector3 support(0.5f, 0.5f, 0.5f, 1);

    for (int i = 0; i < 3; ++i)
    {
      if (localSpaceDirection[i] < 0)
        support[i] *= -1.f;
    }

    support = *(mTransform) * support;

    return support;
  }

  void BoxSupport::DrawDebug(const std::shared_ptr<DebugDraw>& DebugDrawer, unsigned Group) const
  {
    std::vector<Vector3> points;
    GetPoints(points);

    /*
    Order of points
    
    Top Points
    Vector3(-0.5,  0.5,  0.5, 1)  1
    Vector3( 0.5,  0.5,  0.5, 1)  0
    Vector3( 0.5,  0.5, -0.5, 1)  5
    Vector3(-0.5,  0.5, -0.5, 1)  7

    Bottom Points
    Vector3(-0.5, -0.5,  0.5, 1)  2
    Vector3( 0.5, -0.5,  0.5, 1)  6
    Vector3( 0.5, -0.5, -0.5, 1)  4
    Vector3(-0.5, -0.5, -0.5, 1)  3

    */

    RGBA color = 0xFFFFFFFF;

    if (collided)
    {
      switch (Group)
      {
      case 1:// Player
        color = 0xFF0000FF;
        break;
      case 2://Dragon
        color = 0x00FF00FF;
        break;
      case 3://DragonProximity
        color = 0xAAAAAAFF;
        break;
      case 4://Terrain
        color = 0x0000FFFF;
        break;
      default:
        break;
      }
    }


    // Draw all the lines
    DebugDrawer->DrawLine(points[1], points[0], color, 0.2f);
    DebugDrawer->DrawLine(points[0], points[5], color, 0.2f);
    DebugDrawer->DrawLine(points[5], points[7], color, 0.2f);
    DebugDrawer->DrawLine(points[7], points[1], color, 0.2f);
    DebugDrawer->DrawLine(points[2], points[6], color, 0.2f);
    DebugDrawer->DrawLine(points[6], points[4], color, 0.2f);
    DebugDrawer->DrawLine(points[4], points[3], color, 0.2f);
    DebugDrawer->DrawLine(points[3], points[2], color, 0.2f);
    DebugDrawer->DrawLine(points[1], points[2], color, 0.2f);
    DebugDrawer->DrawLine(points[0], points[6], color, 0.2f);
    DebugDrawer->DrawLine(points[5], points[4], color, 0.2f);
    DebugDrawer->DrawLine(points[7], points[3], color, 0.2f);
  }

  
  //-----------------------------------------------------------------------------WedgeSupport
  WedgeSupport::WedgeSupport(Matrix3 * transform) : mTransform(transform) {}
  
  Vector3 WedgeSupport::GetCenter() const
  {
    return mTransform->Translation();
  }

  Vector3 WedgeSupport::Support(const Vector3 & worldDirection) const
  {
    Vector3 localSpaceDirection = mTransform->Inverted()* worldDirection;
    //localSpaceDirection.Normalize();

    Vector3 support(0.5f, 0.5f, 0.5f, 1);

    for (int i = 0; i < 3; ++i)
    {
      if (localSpaceDirection[i] < 0)
        support[i] *= -1.f;
    }

    // For the case that this is one of the points removed from the cube to make a wedge
    // I have to figure out if it's closer to the points with a positive y or a negative z
    if (support.Y > 0 && support.Z < 0)
    {
      // The magnitude of the y value is greater than the z value, so it's going more up than forward
      if (localSpaceDirection.Y > -localSpaceDirection.Z)
      {
        support.Z *= -1.f;
      }

      // The magnitude of the z value is greater than the y value, so it's going more forward than up
      else
      {
        support.Y *= -1.f;
      }
    }

    return support;
  }

  void WedgeSupport::DrawDebug(const std::shared_ptr<DebugDraw>& DebugDrawer, unsigned Group) const
  {
    std::vector<Vector3> points;
    GetPoints(points);

    /*
    
    Order of points
    
    Top Points
    Vector3(-0.5,  0.5,  0.5)  1
    Vector3( 0.5,  0.5,  0.5)  0

    Bottom Points
    Vector3(-0.5, -0.5,  0.5)  2
    Vector3( 0.5, -0.5,  0.5)  5
    Vector3(-0.5, -0.5, -0.5)  3
    Vector3( 0.5, -0.5, -0.5)  4

    */

    // Draw all the lines
    DebugDrawer->DrawLine(points[1], points[0]);
    DebugDrawer->DrawLine(points[2], points[5]);
    DebugDrawer->DrawLine(points[5], points[2]);
    DebugDrawer->DrawLine(points[3], points[4]);
    DebugDrawer->DrawLine(points[4], points[2]);
    DebugDrawer->DrawLine(points[1], points[2]);
    DebugDrawer->DrawLine(points[1], points[3]);
    DebugDrawer->DrawLine(points[0], points[5]);
    DebugDrawer->DrawLine(points[0], points[4]);
  }
}