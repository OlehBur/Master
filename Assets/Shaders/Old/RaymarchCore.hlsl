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

            // TOOLS

               // dithering for raymarching
            float stepSizeDither(float dither) {
                return dither * 2.0;
           }           
            float InterleavedGradientNoise(float2 pixCoord)
            {
                //Jorge Jimenez's constants for the 2D screen. They are calculated through the golden ratio 
                float3 constants = float3(0.06711056, 0.00583715, 52.9829189);
                return frac(constants.z * frac(dot(pixCoord, constants.xy)));
            }

            //silver lines for clouds
            float HenyeyGreenstein(float cosTheta, float g)
{
    float g2 = g * g;
    return (1.0 - g2) / (4.0 * 3.14159265 * pow(max(0.001, 1.0 + g2 - 2.0 * g * cosTheta), 1.5));
}

    // GEOMETRY & INTERSECTION
bool RayHorizIntersect(float3 ro, float3 rd, float minH, float maxH, out float tNear, out float tFar)
{
    if (abs(rd.y) < 0.0001) return false;

    float t1 = (minH - ro.y) / rd.y;
    float t2 = (maxH - ro.y) / rd.y;

    tNear = min(t1, t2);
    tFar = max(t1, t2);

    tNear = max(tNear, 0.0);
    return tNear < tFar;
}

//// --- Shared Terrain Functions ---
//float GetTerrainHeight(float2 p, float mountainScale, float mountainHeight)
//{
//    float h = 0.0;
//    float amp = 1.0;
//    float freq = mountainScale;

//    for (int i = 0; i < 5; i++)
//    {
//        float n = 1.0 - abs(Noise3D(float3(p * freq, 0.0)) * 2.0 - 1.0);
//        h += n * n * amp;
//        freq *= 2.1;
//        amp *= 0.45;
//    }
//    return h * mountainHeight;
//}

//float3 GetTerrainNormal(float3 p, float mountainScale, float mountainHeight)
//{
//    float e = 0.5;
//    return normalize(float3(
//        GetTerrainHeight(p.xz - float2(e, 0), mountainScale, mountainHeight) - GetTerrainHeight(p.xz + float2(e, 0), mountainScale, mountainHeight),
//        2.0 * e,
//        GetTerrainHeight(p.xz - float2(0, e), mountainScale, mountainHeight) - GetTerrainHeight(p.xz + float2(0, e), mountainScale, mountainHeight)
//    ));
//}

//// Повертає відстань до гори вздовж променя (або -1.0 якщо влучання немає)
//float TerrainRayIntersect(float3 ro, float3 rd, float maxDist, float mountainScale, float mountainHeight)
//{
//    float t = 0.0;
//    float stepSize = 4.0;
//    int steps = 64;

//    for (int i = 0; i < steps; i++)
//    {
//        float3 p = ro + rd * t;
//        float h = GetTerrainHeight(p.xz, mountainScale, mountainHeight);
//        float diff = p.y - h;

//        if (diff < 0.5)
//        {
//            // Уточнення бінарним пошуком
//            float tMin = max(0.0, t - stepSize);
//            float tMax = t;
//            for (int j = 0; j < 4; j++)
//            {
//                float tMid = (tMin + tMax) * 0.5;
//                float3 midP = ro + rd * tMid;
//                if (midP.y < GetTerrainHeight(midP.xz, mountainScale, mountainHeight))
//                    tMax = tMid;
//                else
//                    tMin = tMid;
//            }
//            return tMax;
//        }

//        t += max(stepSize, diff * 0.4);
//        if (t > maxDist) break;
//    }
//    return -1.0;
//}

#endif