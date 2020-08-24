#pragma once

#include "Vector3.h"
#include "Matrix3.h"

#include "GjkSupport.h"
///////////////////////////////////////////////////////////////////////////////
///
/// Original Author: Joshua Davis
/// Edited for use by: Daniel Ospina
/// Copyright 2015-2019, DigiPen Institute of Technology
///
///////////////////////////////////////////////////////////////////////////////

#define EPSILON 0.0001f

namespace Engine
{
  namespace {
    Vector3 Scale(const Vector3& lhs, const Vector3& rhs)
    {
      Vector3 scaled_vector = Vector3(lhs.X * rhs.X, lhs.Y * rhs.Y, lhs.Z * rhs.Z);

      return scaled_vector;
    }
  }


  namespace VoronoiRegion
  {
    enum Type {
      Point0, Point1, Point2, Point3,
      Edge01, Edge02, Edge03, Edge12, Edge13, Edge23,
      Triangle012, Triangle013, Triangle023, Triangle123,
      Tetrahedra0123,
      Unknown
    };
    static const char* Names[] = { "Point0", "Point1", "Point2", "Point3",
    "Edge01", "Edge02", "Edge03", "Edge12", "Edge13", "Edge23",
    "Triangle012", "Triangle013", "Triangle023", "Triangle123",
    "Tetrahedra0123",
    "Unknown" };
  }

  /******Student:Assignment5******/
  // Implement gjk
  //-----------------------------------------------------------------------------Gjk
  class Gjk
  {
  public:

    // Point Test
    static VoronoiRegion::Type IdentifyVoronoiRegion(const Vector3& q, const Vector3& p0,
      size_t& newSize, int newIndices[4],
      Vector3& closestPoint, Vector3& searchDirection);

    // Edge Test
    static VoronoiRegion::Type IdentifyVoronoiRegion(const Vector3& q, const Vector3& p0, const Vector3& p1,
      size_t& newSize, int newIndices[4],
      Vector3& closestPoint, Vector3& searchDirection);

    // Triangle Test
    static VoronoiRegion::Type IdentifyVoronoiRegion(const Vector3& q, const Vector3& p0, const Vector3& p1, const Vector3& p2,
      size_t& newSize, int newIndices[4],
      Vector3& closestPoint, Vector3& searchDirection);

    // Tetrahedron Tests
    static VoronoiRegion::Type IdentifyVoronoiRegion(const Vector3& q, const Vector3& p0, const Vector3& p1, const Vector3& p2, const Vector3& p3,
      size_t& newSize, int newIndices[4],
      Vector3& closestPoint, Vector3& searchDirection);

    // Simple structure that contains all information for a point in Gjk.
    struct CsoPoint
    {
      Vector3 mCsoPoint;
      Vector3 mPointA;
      Vector3 mPointB;
    };

    Gjk();

    // Returns true if the shapes intersect. If the shapes don't intersect then closestPoint is filled out with the closest points
    // on each object as well as the cso point. ProgressEpsilon should only be used for checking if sufficient progress has been made at any step.
    // The debugging values are for your own use (make sure they don't interfere with the unit tests).
    bool Intersect(const SupportShape* shapeA, const SupportShape* shapeB, unsigned int maxIterations, CsoPoint& closestPoint, float progressEpsilon = EPSILON);
    // Finds the point furthest in the given direction on the CSO (and the relevant points from each object)
    CsoPoint ComputeSupport(const SupportShape* shapeA, const SupportShape* shapeB, const Vector3& direction);



    // Add your implementation here 
    static float gu, gv, gw;
  };

}
