#include "GJK.h"
#include "Aabb.h"

///////////////////////////////////////////////////////////////////////////////
///
/// Original Author: Joshua Davis
/// Edited for use by: Daniel Ospina
/// Copyright 2015-2019, DigiPen Institute of Technology
///
///////////////////////////////////////////////////////////////////////////////


namespace Engine
{

  namespace {
    bool DegenerateVector(const Vector3& vector)
    {
      vector.SquareLength();

      if (vector.SquareLength() < EPSILON * EPSILON)
        return true;

      return false;
    }

    bool DegenerateTriangle(const Vector3& AC, const Vector3& BC, float degenerateEpsilon)
    {
      float area = 0.5f * AC.Cross(BC).Length();
      if (area < degenerateEpsilon)
        return true;

      return false;
    }

    bool DegenerateAabb(const Vector3& minAabb, const Vector3& maxAabb)
    {
      if (maxAabb.X < minAabb.X || maxAabb.Y < minAabb.Y || maxAabb.Z < minAabb.Z)
        return true;

      Vector3 diagonal = maxAabb - minAabb;

      return DegenerateVector(diagonal);
    }
  }

  bool BarycentricCoordinates(const Vector3& point, const Vector3& a, const Vector3& b,
    float& u, float& v, float expansionEpsilon = 0.0f)
  {
    /******Student:Assignment1******/
    //Warn("Assignment1: Required function un-implemented");

    // Point to line

    /*

    v = 1 - u
    P = uA + vB

    P = uA + (1 - u)B
    P - B = u(A - B)

    v0 = P - B
    v1 = A - B

    v0 = u v1

    v0 * v1
    u = _________

    v1 * v1

    */

    // For degenerates I see I should set these to 0
    u = v = 0;

    // Get the vectors
    Vector3 v0 = point - b;
    Vector3 v1 = a - b;

    // Test for degenerate line
    if (DegenerateVector(v1))
      return false;

    // Calculate the Barycentric coordinates
    u = v0.Dot(v1) / v1.SquareLength();
    v = 1 - u;

    // Check to see if it's outside
    if (u < -expansionEpsilon || v < -expansionEpsilon)
      return false;

    return true;
  }

  bool BarycentricCoordinates(const Vector3& point, const Vector3& a, const Vector3& b, const Vector3& c,
    float& u, float& v, float& w, float expansionEpsilon = 0.0f)
  {
    /******Student:Assignment1******/
    //Warn("Assignment1: Required function un-implemented");

    /*

    Point to triangle

    Equations

    w = 1 - u - v
    P = uA + vB + wC

    P = uA + vB + (1 - u - v)C
    P - C = u(A - C) + v(B - C)

    v0 = P - C
    v1 = A - C
    v2 = B - C

    v0 * v1 = u(v1 * v1) + v(v2 * v1)
    v0 * v2 = u(v1 * v2) + v(v2 * v2)

    Cramer's rule
    | v0*v1       v2*v1 |      | v1*v1       v0*v1 |
    |                   |      |                   |
    | v0*v2       v2*v2 |      | v1*v2       v0*v2 |
    u =_______________________ v =_______________________
    | v1*v1       v2*v1 |      | v1*v1       v2*v1 |
    |                   |      |                   |
    | v1*v2       v2*v2 |      | v1*v2       v2*v2 |

    */

    // For degenerates I see I should set these to 0
    u = v = w = 0;

    // Get the vectors
    Vector3 v0 = point - c;
    Vector3 v1 = a - c;
    Vector3 v2 = b - c;

    // Test for degenerate triangle
    //if (DegenerateTriangle(v1, v2, Math::DebugEpsilon()))
    //{
    //  return false;
    //}

    // Take all the dot products to get the elements of the matrices
    float ca, cb_cc, cd, ce, cf;


    ca = v1.SquareLength();
    cb_cc = v1.Dot(v2); // v1*v2 == v2*v1
    cd = v2.SquareLength();

    ce = v0.Dot(v1);
    cf = v0.Dot(v2);

    // Create the matrices... Except we don't have 2x2 matrices, so instead I do it manually
    /*
    Matrix2 denom, numU, numV;

    denom[0] = Vector2(ca, cb_cc);
    denom[1] = Vector2(cb_cc, cd);

    numU[0] = Vector2(ce, cb_cc);
    numU[1] = Vector2(cf, cd);

    numV[0] = Vector2(ca, ce);
    numV[1] = Vector2(cb_cc, cf);
    */

    // Get the determinants
    float dR, uR, vR;

    dR = ca * cd - cb_cc * cb_cc;  //dR = denom.Determinate();
    uR = ce * cd - cb_cc * cf;     //uR = numU.Determinate();
    vR = ca * cf - cb_cc * ce;     //vR = numV.Determinate();

    // Calculate the Barycentric coordinates
    u = uR / dR;
    v = vR / dR;
    w = 1 - u - v;

    // Check to see if it's outside
    if (u < -expansionEpsilon || v < -expansionEpsilon || w < -expansionEpsilon)
      return false;

    return true;
  }

  void BarycentricCoordinates(const Vector3& point, const Vector3& a, const Vector3& b, const Vector3& c, const Vector3& d,
    float& u, float& v, float& w, float& t)
  {
    Vector3 AD = a - d,
      BD = b - d,
      CD = c - d,
      PD = point - d;

    Matrix3 m(Vector3(), AD, BD, CD);
    auto baryCoords = m.Inverted() * PD;

    u = baryCoords.X;
    v = baryCoords.Y;
    w = baryCoords.Z;
    t = 1 - u - v - w;
  }

  float Gjk::gu = 0;
  float Gjk::gv = 0;
  float Gjk::gw = 0;

  //------------------------------------------------------------ Voronoi Region Tests
  VoronoiRegion::Type Gjk::IdentifyVoronoiRegion(const Vector3& q, const Vector3& p0,
    size_t& newSize, int newIndices[4],
    Vector3& closestPoint, Vector3& searchDirection)
  {

    // The closest point is on a point is always the point
    closestPoint = p0;

    // The size of the voranoi region is defined by a single point
    newSize = 1;
    newIndices[0] = 0;
    searchDirection = q - p0;
    searchDirection.Normalize();
    //searchDirection.AttemptNormalize();

    return VoronoiRegion::Point0;
  }

  VoronoiRegion::Type Gjk::IdentifyVoronoiRegion(const Vector3& q, const Vector3& p0, const Vector3& p1,
    size_t& newSize, int newIndices[4],
    Vector3& closestPoint, Vector3& searchDirection)
  {

    float u = 0.f, v = 0.f;
    BarycentricCoordinates(q, p0, p1, u, v);

    // Voronoi region is p0
    if (v <= 0)
    {
      newSize = 1;
      newIndices[0] = 0;
      closestPoint = p0;
      searchDirection = q - p0;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Point0;
    }

    // Voronoi region is p1
    if (u <= 0)
    {
      newSize = 1;
      newIndices[0] = 1;
      closestPoint = p1;
      searchDirection = q - p1;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Point1;
    }

    // If between the line
    else
    {
      // The voronoi region is the edge
      newSize = 2;
      newIndices[0] = 0;
      newIndices[1] = 1;

      gu = u;
      gv = v;

      closestPoint = u * p0 + v * p1;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Edge01;
    }
  }

  VoronoiRegion::Type Gjk::IdentifyVoronoiRegion(const Vector3& q, const Vector3& p0, const Vector3& p1, const Vector3& p2,
    size_t& newSize, int newIndices[4],
    Vector3& closestPoint, Vector3& searchDirection)
  {

    float uT, vT, wT, u01, v01, u02, v02, u12, v12;

    // Calculate all the triangle and line barycentric coordinate
    BarycentricCoordinates(q, p0, p1, p2, uT, vT, wT);
    BarycentricCoordinates(q, p0, p1, u01, v01);
    BarycentricCoordinates(q, p0, p2, u02, v02);
    BarycentricCoordinates(q, p1, p2, u12, v12);


    // Region of point0
    if (v01 <= 0 && v02 <= 0)
    {
      newSize = 1;
      newIndices[0] = 0;
      closestPoint = p0;
      searchDirection = q - p0;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Point0;
    }

    // Region of point1
    if (u01 <= 0 && v12 <= 0)
    {
      newSize = 1;
      newIndices[0] = 1;
      closestPoint = p1;
      searchDirection = q - p1;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Point1;
    }

    // Region of point2
    if (u02 <= 0 && u12 <= 0)
    {
      newSize = 1;
      newIndices[0] = 2;
      closestPoint = p2;
      searchDirection = q - p2;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Point2;
    }

    // Region of edge01
    if (u01 > 0 && v01 > 0 && wT < 0)
    {
      newSize = 2;
      newIndices[0] = 0;
      newIndices[1] = 1;

      gu = u01;
      gv = v01;

      closestPoint = u01 * p0 + v01 * p1;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Edge01;
    }

    // Region of edge02
    if (u02 > 0 && v02 > 0 && vT < 0)
    {
      newSize = 2;
      newIndices[0] = 0;
      newIndices[1] = 2;

      gu = u02;
      gv = v02;

      closestPoint = u02 * p0 + v02 * p2;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Edge02;
    }

    // Region of edge12
    if (u12 > 0 && v12 > 0 && uT < 0)
    {
      newSize = 2;
      newIndices[0] = 1;
      newIndices[1] = 2;

      gu = u12;
      gv = v12;

      closestPoint = u12 * p1 + v12 * p2;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Edge12;
    }

    // Region of the triangle
    else
    {
      newSize = 3;
      newIndices[0] = 0;
      newIndices[1] = 1;
      newIndices[2] = 2;

      gu = uT;
      gv = vT;
      gw = wT;

      closestPoint = uT * p0 + vT * p1 + wT * p2;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Triangle012;
    }
  }

  VoronoiRegion::Type Gjk::IdentifyVoronoiRegion(const Vector3& q, const Vector3& p0, const Vector3& p1, const Vector3& p2, const Vector3& p3,
    size_t& newSize, int newIndices[4],
    Vector3& closestPoint, Vector3& searchDirection)
  {
    // Get ALL the barycentric coordinates

    // The tetrahedron
    float uT, vT, wT, tT;

    // The triangles
    float u012, v012, w012,
      u013, v013, w013,
      u023, v023, w023,
      u123, v123, w123;

    // The lines

    float u01, v01,
      u02, v02,
      u03, v03,
      u12, v12,
      u13, v13,
      u23, v23;

    // The tetrahedron calculation
    BarycentricCoordinates(q, p0, p1, p2, p3, uT, vT, wT, tT);

    // The triangle calculations
    BarycentricCoordinates(q, p0, p1, p2, u012, v012, w012);
    BarycentricCoordinates(q, p0, p1, p3, u013, v013, w013);
    BarycentricCoordinates(q, p0, p2, p3, u023, v023, w023);
    BarycentricCoordinates(q, p1, p2, p3, u123, v123, w123);

    // The line calculations
    BarycentricCoordinates(q, p0, p1, u01, v01);
    BarycentricCoordinates(q, p0, p2, u02, v02);
    BarycentricCoordinates(q, p0, p3, u03, v03);
    BarycentricCoordinates(q, p1, p2, u12, v12);
    BarycentricCoordinates(q, p1, p3, u13, v13);
    BarycentricCoordinates(q, p2, p3, u23, v23);

    // Check to see if it's in the region of any of the points

    // Region of p0
    if (v01 <= 0 && v02 <= 0 && v03 <= 0)
    {
      newSize = 1;
      newIndices[0] = 0;
      closestPoint = p0;
      searchDirection = q - p0;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Point0;
    }

    // Region of p1
    if (u01 <= 0 && v12 <= 0 && v13 <= 0)
    {
      newSize = 1;
      newIndices[0] = 1;
      closestPoint = p1;
      searchDirection = q - p1;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Point1;
    }

    // Region of p2
    if (u02 <= 0 && u12 <= 0 && v23 <= 0)
    {
      newSize = 1;
      newIndices[0] = 2;
      closestPoint = p2;
      searchDirection = q - p2;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Point2;
    }

    // Region of p3
    if (u03 <= 0 && u13 <= 0 && u23 <= 0)
    {
      newSize = 1;
      newIndices[0] = 3;
      closestPoint = p3;
      searchDirection = q - p3;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Point3;
    }


    // Check to see if it's in the region of any of the edges

    // Region of edge01
    if (u01 > 0 && v01 > 0 && w012 < 0 && w013 < 0)
    {
      newSize = 2;
      newIndices[0] = 0;
      newIndices[1] = 1;

      gu = u01;
      gv = v01;

      closestPoint = u01 * p0 + v01 * p1;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Edge01;
    }

    // Region of edge02
    if (u02 > 0 && v02 > 0 && v012 < 0 && w023 < 0)
    {
      newSize = 2;
      newIndices[0] = 0;
      newIndices[1] = 2;

      gu = u02;
      gv = v02;

      closestPoint = u02 * p0 + v02 * p2;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Edge02;
    }

    // Region of edge03
    if (u03 > 0 && v03 > 0 && v013 < 0 && v023 < 0)
    {
      newSize = 2;
      newIndices[0] = 0;
      newIndices[1] = 3;

      gu = u03;
      gv = v03;

      closestPoint = u03 * p0 + v03 * p3;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Edge03;
    }

    // Region of edge12
    if (u12 > 0 && v12 > 0 && u012 < 0 && w123 < 0)
    {
      newSize = 2;
      newIndices[0] = 1;
      newIndices[1] = 2;

      gu = u12;
      gv = v12;

      closestPoint = u12 * p1 + v12 * p2;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Edge12;
    }

    // Region of edge13
    if (u13 > 0 && v13 > 0 && u013 < 0 && v123 < 0)
    {
      newSize = 2;
      newIndices[0] = 1;
      newIndices[1] = 3;

      gu = u13;
      gv = v13;

      closestPoint = u13 * p1 + v13 * p3;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Edge13;
    }

    // Region of edge23
    if (u23 > 0 && v23 > 0 && u123 < 0 && u023 < 0)
    {
      newSize = 2;
      newIndices[0] = 2;
      newIndices[1] = 3;

      gu = u23;
      gv = v23;

      closestPoint = u23 * p2 + v23 * p3;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Edge23;
    }


    // Check to see if it's in the region of any of the faces

    // Region of face012
    if (u012 > 0 && v012 > 0 && w012 > 0 && tT < 0)
    {
      newSize = 3;
      newIndices[0] = 0;
      newIndices[1] = 1;
      newIndices[2] = 2;

      gu = u012;
      gv = v012;
      gw = w012;

      closestPoint = u012 * p0 + v012 * p1 + w012 * p2;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Triangle012;
    }

    // Region of face013
    if (u013 > 0 && v013 > 0 && w013 > 0 && wT < 0)
    {
      newSize = 3;
      newIndices[0] = 0;
      newIndices[1] = 1;
      newIndices[2] = 3;

      gu = u013;
      gv = v013;
      gw = w013;

      closestPoint = u013 * p0 + v013 * p1 + w013 * p3;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Triangle013;
    }

    // Region of face023
    if (u023 > 0 && v023 > 0 && w023 > 0 && vT < 0)
    {
      newSize = 3;
      newIndices[0] = 0;
      newIndices[1] = 2;
      newIndices[2] = 3;

      gu = u023;
      gv = v023;
      gw = w023;

      closestPoint = u023 * p0 + v023 * p2 + w023 * p3;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Triangle023;
    }

    // Region of face123
    if (u123 > 0 && v123 > 0 && w123 > 0 && uT < 0)
    {
      newSize = 3;
      newIndices[0] = 1;
      newIndices[1] = 2;
      newIndices[2] = 3;

      gu = u123;
      gv = v123;
      gw = w123;

      closestPoint = u123 * p1 + v123 * p2 + w123 * p3;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Triangle123;
    }

    // It is in the region of the tetrahedron
    else
    {
      newSize = 4;
      newIndices[0] = 0;
      newIndices[1] = 1;
      newIndices[2] = 2;
      newIndices[3] = 3;

      closestPoint = q;
      searchDirection = q - closestPoint;
      searchDirection.Normalize();
      //searchDirection.AttemptNormalize();
      return VoronoiRegion::Tetrahedra0123;
    }
  }

  Gjk::Gjk()
  {
  }

  bool Gjk::Intersect(const SupportShape* shapeA, const SupportShape* shapeB, unsigned int maxIterations, CsoPoint& closestPoint, float progressEpsilon)
  {
    //GJK Algorithm
    //
    //1)  Initialize the simplex to one point by searching in a random direction (difference of centers)
    //
    //2) Determine whiche voronoi region Q is in and reduce to the smallest simplex
    //
    //3) Compute P by projecting Q onto the new simplex
    //
    //4) If P is equal to Q terminate
    //
    //5) Compute the new search direction (Q - P) and search for a new point
    //
    //6) if the new points is no furthur than P in the searchdirection then terminate the length of the vector (Q-P) is the separation distance
    //
    //7) Add the new point to the simplex and go to step 2

    unsigned iterations = 0;

    std::vector<Vector3> shapeA_points, shapeB_points;

    //bool AHasDefinedPoints = shapeA->GetPoints(shapeA_points);
    //bool BHasDefinedPoints = shapeB->GetPoints(shapeB_points);
    //
    //if (AHasDefinedPoints || BHasDefinedPoints)
    //{
    //printf("Check out my points");
    //}

    Vector3 origin;

    // Find the direction towards the other shape and use it to calculate the support in the minkowski difference
    Vector3 direction = shapeA->GetCenter() - shapeB->GetCenter();

    if (direction == origin)
    {
      direction = Vector3(-1, 0, 0);
    }

    origin.W = 1;
    direction.W = 0;

    // Initialize the simplex
    std::vector<CsoPoint> simplex;
    simplex.push_back(ComputeSupport(shapeA, shapeB, direction));
    size_t size = 1;
    int indices[4]{ 0, 0, 0, 0 };

    Vector3 vClosestPoint;

    // Only go on for max iterations
    while (iterations < maxIterations)
    {
      switch (size)
      {
      case 1:
      {
        // I don't save the region because I know what it will be in this version, this just gives me a new direction
        IdentifyVoronoiRegion(origin, simplex[0].mCsoPoint, size, indices, vClosestPoint, direction);
        break;
      }
      case 2:
      {
        // Get the new size + indices, the closest point to the origin, and a new search direction
        IdentifyVoronoiRegion(origin, simplex[0].mCsoPoint, simplex[1].mCsoPoint, size, indices, vClosestPoint, direction);

        // Reduce if necessary
        if (size < 2)
        {
          // Get the point that matters and remove the one that doesn't
          simplex[0] = simplex[indices[0]];
          simplex.pop_back();
        }

        break;
      }
      case 3:
      {
        // Get the new size + indices, the closest point to the origin, and a new search direction
        IdentifyVoronoiRegion(origin, simplex[0].mCsoPoint, simplex[1].mCsoPoint, simplex[2].mCsoPoint, size, indices, vClosestPoint, direction);

        // Reduce if necessary
        if (size < 3)
        {
          // Get the points that matter
          for (unsigned i = 0; i < size; ++i)
          {
            simplex[i] = simplex[indices[i]];
          }

          // Remove the points that don't
          for (unsigned i = 3 - size; i > 0; --i)
          {
            simplex.pop_back();
          }
        }

        break;
      }
      case 4:
      {
        // Get the new size + indices, the closest point to the origin, and a new search direction
        IdentifyVoronoiRegion(origin, simplex[0].mCsoPoint, simplex[1].mCsoPoint, simplex[2].mCsoPoint, simplex[3].mCsoPoint, size, indices, vClosestPoint, direction);

        // Reduce if necessary
        if (size < 4)
        {
          // Get the points that matter
          for (unsigned i = 0; i < size; ++i)
          {
            simplex[i] = simplex[indices[i]];
          }

          // Remove the points that don't
          for (unsigned i = 4 - size; i > 0; --i)
          {
            simplex.pop_back();
          }
        }

        break;
      }
      default:
        // How did this even happen
        abort();
      }

      // If the closest point is the origin
      if (vClosestPoint == origin)
      {
        // They intersect
        return true;
      }

      // Get a new point in the new search direction
      direction.W = 0;
      auto newPoint = ComputeSupport(shapeA, shapeB, direction);

      direction.Normalize();

      auto distanceP = vClosestPoint.Dot(direction);
      auto distanceNewPoint = newPoint.mCsoPoint.Dot(direction);

      // If the new point isn't any farther than p
      if (distanceNewPoint - distanceP < progressEpsilon)
      {
        // If the last region was a point, give it the point
        if (size == 1)
          closestPoint = simplex[0];

        // If the last region was an edge
        else if (size == 2)
        {
          // Use the globally saved barycentric coordinates to recreate the point
          closestPoint.mCsoPoint = gu * simplex[0].mCsoPoint + gv * simplex[1].mCsoPoint;
          closestPoint.mPointA = gu * simplex[0].mPointA + gv * simplex[1].mPointA;
          closestPoint.mPointB = gu * simplex[0].mPointB + gv * simplex[1].mPointB;
        }

        // If the last region was a triangle
        else if (size == 3)
        {
          // Use the globally saved barycentric coordinates to recreate the point
          closestPoint.mCsoPoint = gu * simplex[0].mCsoPoint + gv * simplex[1].mCsoPoint + gw * simplex[2].mCsoPoint;
          closestPoint.mPointA = gu * simplex[0].mPointA + gv * simplex[1].mPointA + gw * simplex[2].mPointA;
          closestPoint.mPointB = gu * simplex[0].mPointB + gv * simplex[1].mPointB + gw * simplex[2].mPointB;
        }

        // If the size was 4, then the origin should have been inside of the volume and returned true

        return false;
      }

      // Add the new point and move on
      simplex.push_back(newPoint);
      size++;
      iterations++;
    }

    // If this failed, then the last point will be the closest point
    closestPoint = simplex.back();


    return false;
  }

  Gjk::CsoPoint Gjk::ComputeSupport(const SupportShape* shapeA, const SupportShape* shapeB, const Vector3& direction)
  {
    CsoPoint result;

    result.mPointA = shapeA->Support(direction);
    result.mPointB = shapeB->Support(-direction);
    result.mCsoPoint = result.mPointA - result.mPointB;

    return result;
  }

}
