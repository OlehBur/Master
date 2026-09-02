#ifndef RAYMARCHING_COMMON_INCLUDED
#define RAYMARCHING_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // 3D pocedural noise
            // 3d hash
            float3 hash3D(float3 p)
            {
                p = frac(p * float3(0.1031, 0.1030, 0.0973));
                p += dot(p, p.yxz + 33.33);
                return frac((p.xxy + p.yzz) * p.zyx);
            }

            float hash(float3 p)
            {
                p = frac(p * float3(443.897, 441.423, 437.195));
                p += dot(p, p.yzx + 19.19);
                return frac((p.x + p.y) * p.z);
            }

            float Noise3D(float3 p)
            {
                float3 i = floor(p);
                float3 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);

                return lerp(
                    lerp(lerp(hash(i + float3(0,0,0)), hash(i + float3(1,0,0)), f.x),
                         lerp(hash(i + float3(0,1,0)), hash(i + float3(1,1,0)), f.x), f.y),
                    lerp(lerp(hash(i + float3(0,0,1)), hash(i + float3(1,0,1)), f.x),
                         lerp(hash(i + float3(0,1,1)), hash(i + float3(1,1,1)), f.x), f.y), f.z);
            }

            // Fractal Brownian Motion (frac noise
            float Fbm(float3 p)
            {
                float value = 0.0;
                float amplitude = 0.5;
                for (int i = 0; i < 3; i++)
                {
                    value += amplitude * Noise3D(p);
                    p *= 2.0;
                    amplitude *= 0.5;
                }
                return value;
            }


                ////base sdfs
            ////(surf = 0 , <0 ins, >0 out)
            //float SphereSDF(float3 p, float3 center, float radius)
            //{
            //    return length(p - center) - radius;
            //}

            //// visual dens
            //float GetDensity(float3 p)
            //{
            //    float dist = SphereSDF(p, _SphereCenter.xyz, _SphereRadius);
            //    //if inside the sphere, return a density value based on distance to the surface
            //    if (dist < 0.0)
            //    {
            //        return -dist; // more negative distance means deeper inside the sphere, thus higher density
            //    }
            //    return 0.0;
            //}

            // Worley 3D Noise (creates wadded/rounded shapes)
            float Worley3D(float3 p)
            {
                float3 id = floor(p);
                float3 fd = frac(p);
                float minDist = 1.0;

                for (int x = -1; x <= 1; x++)
                {
                    for (int y = -1; y <= 1; y++)
                    {
                        for (int z = -1; z <= 1; z++)
                        {
                            float3 offset = float3(x, y, z);
                            float3 randPoint = hash3D(id + offset);
                            float3 distVec = offset + randPoint - fd;
                            minDist = min(minDist, length(distVec));
                        }
                    }
                }
                return 1.0 - minDist; //invert -> the center of cell is convex
            }

            // math intersect woth horiz clouds lay fr MinHeight to MaxHeight
            bool RayHorizIntersect(float3 ro, float3 rd, float minH, float maxH, out float tNear, out float tFar)
            {
                if (abs(rd.y) < 0.0001) return false; //ray parallel to horiz

                float t1 = (minH - ro.y) / rd.y;
                float t2 = (maxH - ro.y) / rd.y;

                tNear = min(t1, t2);
                tFar = max(t1, t2);

                tNear = max(tNear, 0.0); //disab calc behind cam
                return tNear < tFar;
            }

#endif