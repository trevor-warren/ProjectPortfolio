#pragma once
#include "Vector3.h"
#include "Matrix3.h"
#include "DebugDraw.h"

namespace Engine
{
  class SupportShape
  {
  public:
    virtual ~SupportShape() {};
    virtual Vector3 GetCenter() const = 0;
    virtual Vector3 Support(const Vector3& worldDirection) const = 0;
    virtual bool GetPoints(std::vector<Vector3>& points) const { return false; };
    virtual void DrawDebug(const std::shared_ptr<DebugDraw>& DebugDrawer, unsigned Group) const = 0;


    bool collided = false;

    Vector3 GetCenter(const std::vector<Vector3>& localPoints, const Matrix3& localToWorldTransform) const;
    Vector3 Support(const Vector3& worldDirection, const std::vector<Vector3>& localPoints, const Matrix3& localToWorldTransform) const;
  };

  class BoxSupport : public SupportShape
  {
  public:
    BoxSupport() : mTransform(0) {}
    BoxSupport(Matrix3* transform);
    Vector3 GetCenter() const override;
    Vector3 Support(const Vector3& worldDirection) const override;
    void DrawDebug(const std::shared_ptr<DebugDraw>& DebugDrawer, unsigned Group) const override;
    bool GetPoints(std::vector<Vector3>& points) const override
    {
      Vector3 obb_points[8]{ Vector3( 0.5,  0.5,  0.5, 1),
                             Vector3(-0.5,  0.5,  0.5, 1),
                             Vector3(-0.5, -0.5,  0.5, 1),
                             Vector3(-0.5, -0.5, -0.5, 1),
                             Vector3( 0.5, -0.5, -0.5, 1),
                             Vector3( 0.5,  0.5, -0.5, 1),
                             Vector3( 0.5, -0.5,  0.5, 1),
                             Vector3(-0.5,  0.5, -0.5, 1) };

      Vector3 point = Vector3();
      for (unsigned i = 0; i < 8; ++i)
      {
        point = *mTransform * obb_points[i];
        point.W = 1;
        points.push_back(point);
      }

      return true;
    }


    Matrix3* mTransform;
  };

  class SphereSupport : public SupportShape
  {
  public:
    SphereSupport() : mTransform(0) {}
    SphereSupport(Matrix3* transform);
    Vector3 GetCenter() const override;
    Vector3 Support(const Vector3& worldDirection) const override;
    void DrawDebug(const std::shared_ptr<DebugDraw>& DebugDrawer, unsigned Group) const override;

    float GetRadius() const;
    Matrix3* mTransform;
  };

  class WedgeSupport : public SupportShape
  {
  public:
    WedgeSupport() : mTransform(0) {}
    WedgeSupport(Matrix3* transform);
    Vector3 GetCenter() const override;
    Vector3 Support(const Vector3& worldDirection) const override;
    void DrawDebug(const std::shared_ptr<DebugDraw>& DebugDrawer, unsigned Group) const override;
    bool GetPoints(std::vector<Vector3>& points) const override
    {
      Vector3 wedge_points[6]{ Vector3( 0.5,  0.5,  0.5),
                               Vector3(-0.5,  0.5,  0.5),
                               Vector3(-0.5, -0.5,  0.5),
                               Vector3(-0.5, -0.5, -0.5),
                               Vector3( 0.5, -0.5, -0.5),
                               Vector3( 0.5, -0.5,  0.5),};

      Vector3 point;
      for (unsigned i = 0; i < 6; ++i)
      {
        point = *mTransform * wedge_points[i];
        points.push_back(point);
      }

      return true;
    }
    Matrix3* mTransform;
  };

  /*
  class ConeSupport : public SupportShape
  {

  };
  */
}