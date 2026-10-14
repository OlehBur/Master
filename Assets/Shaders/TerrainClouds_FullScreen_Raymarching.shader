Shader "Custom/FullScreen_TerrainClouds_Raymarching"
{
    Properties
    {
        [HideInInspector] _Header_General ("---{GENERAL}---", Float) = 0
        [Header(____________________________GENERAL_______________________________)]
        _Dithering ("Dithering Strength", Range(0, 1)) = 1.0
        _MeshShadowColor ("Mesh Shadow Tint Color", Color) = (0.0, 0.0859891, 0.3113208, 1.0)
        _AmbientLightIntensity ("Ambient Light Intensity", Range(0, 1)) = 0.234
        
        [HideInInspector] _Header_Clouds ("---{CLOUDS}---", Float) = 0
        [HideInInspector] _Header_ClMarch ("Clouds March", Float) = 0
        [Header(____________________________CLOUDS_______________________________)]        
        [Header(Cloud March)]
        _CloudSteps ("Cloud March Steps", Range(16, 128)) = 44
        _ShadowSteps ("Shadow March Steps", Range(1, 8)) = 3                
        [HideInInspector] _Header_ClMarch ("Clouds Transform", Float) = 0
        _CloudMaxDistance ("Cloud Fade Distance", Float) = 409.6
        _CloudScale ("Cloud Micro Scale", Range(0.0001, 0.1)) = 0.0497

        [HideInInspector] _Header_ClShape ("Clouds Shaping", Float) = 0
        [Header(Cloud Shaping)]
        _MinHeight ("Min Cloud Height (Y)", Float) = 80.0
        _MaxHeight ("Max Cloud Height (Y)", Float) = 120.0
        _WindSpeed ("Wind Speed", Vector) = (0.2, 0.0, 0.1, 0.0)
        _WeatherScale ("Weather Macro Scale", Range(0.001, .1)) = 0.0076
        _CloudWarp ("Turbulence (Warp)", Range(0, 100)) = 1.5
        _Coverage ("Cloud Coverage", Range(0, 1)) = 1          
        
        [HideInInspector] _Header_ClLight ("Clouds Light", Float) = 0
        [Header(Cloud Lighting)]
        _DensityMultiplier ("Cloud Density / Opacity", Range(0, 1)) = 0.376
        _CloudColor ("Sunlit Cloud Color", Color) = (0.9669811, 1.0, 0.9960222, 1.0)
        _LightAbsorption ("Light Absorption", Range(0.1, 20)) = 20
        _SilverLiningIntensity ("Silver Lining Intensity", Range(0, 10)) = 3.56
        _SilverLiningSpread ("Silver Lining Spread", Range(0.1, 0.99)) = 0.816
        _CloudShadowColor ("Shadow Color", Color) = (0.0, 0.1572717, 0.4150943, 1.0)
        _SceneShadowStrength ("Ground Shadow Strength", Range(0, 1)) = 1
        _ShadowBlur ("Shadow Softness Blur", Range(0.1, 10.0)) = 3.4

        
        [HideInInspector] _Header_Terrain ("---{TERRAIN}---", Float) = 0
        [HideInInspector] _Header_TerMarch ("Terrain March", Float) = 0
        [Header(____________________________TERRAIN_______________________________)]
        [Header(Terrain March)]
        _TerrainMaxSteps ("Terrain Raymarch Steps", Range(16, 256)) = 50
        _TerrainMaxDistance ("Terrain Render Distance", Float) = 347.9
        _DetailNoiseScale ("Detail Rock Scale", Range(0, 2)) = 2.0
        
        [HideInInspector] _Header_TerShape ("Terrain Shape", Float) = 0
        [Header(Terrain Shape)]
        _MountainHeight ("Mountain Height Multiplier", Float) = 62.5
        _MountainScale ("Mountain Horizontal Scale", Range(0.0001, 0.02)) = 0.0101       
        _TerrainWarp ("Shape Distortion", Range(0, 500)) = 34.0
        _DetailNoiseStrength ("Detail Rock Strength", Range(0, 1)) = 0.255
        
        [HideInInspector] _Header_TerColor ("Colors & Palette", Float) = 0
        [Header(Terrain Colors and Palette)]
        _BaseColor ("Base Rock Color", Color) = (0.3773585, 0.2716676, 0.2118191, 1.0)
        _MidColor ("Dirt / Vegetation Color", Color) = (0.4713457, 0.5943396, 0.0, 1.0)
        _PeakColor ("Snow Peak Color", Color) = (0.8254718, 0.9162264, 1.0, 1.0)
        _NoiseColorScale ("Color Detail Noise Scale", Float) = 3.64
        _SnowLine ("Snow Line Height (Y)", Float) = 85.3

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        LOD 100
        
        ZWrite On 
        ZTest Always 
        Cull Off

        Pass
        {
            Name "TerrainCloudsRaymarchingPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            //for scene shdows
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            #include "Assets/Shaders/RaymarchCore.hlsl"

            //general
            float4 _MeshShadowColor;
            float _AmbientLightIntensity;

            // Terrain Params
            float _MountainHeight;
            float _MountainScale;
            float _SnowLine;
            float _TerrainMaxDistance;
            float _TerrainMaxSteps;
            float4 _BaseColor;
            float4 _MidColor;
            float4 _PeakColor;
            float _NoiseColorScale;
            float _TerrainWarp;
            float _DetailNoiseScale;
            float _DetailNoiseStrength;

            // Cloud Params
            float _MinHeight;
            float _MaxHeight;
            float _CloudScale;
            float _WeatherScale;
            float _CloudWarp;
            float _Coverage;
            float _DensityMultiplier;
            float _CloudSteps;
            float _ShadowSteps;
            float _ShadowBlur;
            float4 _CloudShadowColor;
            float _LightAbsorption;
            float _SilverLiningIntensity;
            float _SilverLiningSpread;
            float4 _CloudColor;
            float4 _WindSpeed;
            float _CloudMaxDistance;
            float _SceneShadowStrength;
            float _Dithering;


            struct FragOutput
            {
                float4 color : SV_Target;
                float depth : SV_Depth;
            };

            //with warp 
            float GetTerrainHeight(float2 p, out float octaveNoise)
            {
                float2 warp = float2(
                    Noise3D(float3(p * _MountainScale * 0.6, 0.0)),
                    Noise3D(float3(p * _MountainScale * 0.6 + float2(5.2, 1.3), 1.0))
                ) * _TerrainWarp;
            
                float2 warpedP = p + warp;
            
                const int OCTAVES = 5;
                float h = 0.0;
                float amp = 1.0;
                float freq = _MountainScale;
                octaveNoise = 0.0;
            
                for (int i = 0; i < OCTAVES; i++)
                {
                    float rawN = Noise3D(float3(warpedP * freq, 0.0));
                    float ridgeN = 1.0 - abs(rawN * 2.0 - 1.0);
                    
                    //mix the square (sharp peaks) and linear noise (uneven bottoms of the valleys)
                    float layer = lerp(ridgeN, ridgeN * ridgeN, 0.5);
                    
                    h += layer * amp;
                    if (i >= 2) octaveNoise += layer * amp;
                    freq *= 2.15;
                    amp *= 0.45;
                }
            
                //Small brittle noise (flint texture on the surface)
                float microDetail = Noise3D(float3(p * _DetailNoiseScale, 2.5));
                h += (microDetail - 0.5) * _DetailNoiseStrength * 0.1;
            
                return h * _MountainHeight;
            }

            //optimize func for get scebe shadow for point in scene
            float GetSceneMeshShadow(float3 worldPos)
            {
                float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
                return MainLightRealtimeShadow(shadowCoord);
            }

            float GetTerrainHeightSimple(float2 p)
            {
                float unused;
                return GetTerrainHeight(p, unused);
            }

            float3 GetTerrainNormal(float3 p)
            {
                const float SHARPNESS_COEF = 0.95;
                float e = 0.5;
                float3 baseNormal = normalize(float3(
                    GetTerrainHeightSimple(p.xz - float2(e, 0)) - GetTerrainHeightSimple(p.xz + float2(e, 0)),
                    2.0 * e,
                    GetTerrainHeightSimple(p.xz - float2(0, e)) - GetTerrainHeightSimple(p.xz + float2(0, e))
                ));

                return baseNormal;
            }

            
            bool RaymarchTerrain(float3 ro, float3 rd, float maxDist, float dither, out float3 hitPos, out float hitDist, out float octaveDetails)
            {
                float t = dither * 2.0;
                float tPrev = t;
                int steps = (int)_TerrainMaxSteps;
            
                // Adaptive step size: the steeper the mountains (the higher the _MountainScale value),
                // the smaller the step size becomes, so that the ray does not pass through the side contours
                float slopeSafety = 1.0 / (1.0 + (_MountainHeight * _MountainScale * 2.5));
            
                for (int i = 0; i < steps; i++)
                {
                    hitPos = ro + rd * t;
                    float h = GetTerrainHeight(hitPos.xz, octaveDetails);
                    float diff = hitPos.y - h;
            
                    if (diff < 0.0)
                    {
                        // binary search for edge sharpness
                        float tMin = tPrev;
                        float tMax = t;
            
                        for (int j = 0; j < 8; j++)
                        {
                            float tMid = (tMin + tMax) * 0.5;
                            float3 midP = ro + rd * tMid;
                            float midH = GetTerrainHeight(midP.xz, octaveDetails);
            
                            if (midP.y < midH)
                                tMax = tMid;
                            else
                                tMin = tMid;
                        }
            
                        hitDist = tMax;
                        hitPos = ro + rd * hitDist;
                        GetTerrainHeight(hitPos.xz, octaveDetails);
                        return true;
                    }
            
                    tPrev = t;
                    // a step for a smooth of sharply vertical walls
                    float dt = max(0.5 + t * 0.005, diff * slopeSafety);
                    t += dt;
                    if (t > maxDist) break;
                }
                return false;
            }

            // Clouds
            float GetHeightGradient(float heightPercent)
            {
                return smoothstep(0.0, 0.1, heightPercent) * smoothstep(1.0, 0.4, heightPercent);
            }

            float GetCloudDensity(float3 p)
            {
                float heightPercent = (p.y - _MinHeight) / (_MaxHeight - _MinHeight);
                if (heightPercent < 0.0 || heightPercent > 1.0) return 0.0;

                float heightGradient = GetHeightGradient(heightPercent);
                if (heightGradient <= 0.001) return 0.0;

                float3 wind = _WindSpeed.xyz * _Time.y;

                float3 weatherPos = float3(p.x, 0.0, p.z) * _WeatherScale + wind * 0.01;
                float macroWeather = Fbm(weatherPos);
                
                float cloudMask = saturate(macroWeather - (1.0 - _Coverage));
                if (cloudMask <= 0.0) return 0.0;

                float3 warpVector = float3(
                    Noise3D(p * 0.015 + wind * 0.05),
                    Noise3D(p * 0.015 + float3(12.3, 4.5, 7.8)),
                    Noise3D(p * 0.015 + float3(5.2, 1.3, 8.1))
                ) * _CloudWarp;

                float3 samplePos = (p + wind + warpVector) * _CloudScale;
                float baseNoise = Fbm(samplePos);

                float baseCloud = saturate(baseNoise - (1.0 - cloudMask));
                if (baseCloud <= 0.001) return 0.0;

                float detailWorley = Worley3D(samplePos * 3.0);
                float erosion = lerp(0.1, 0.6, heightPercent);
                float finalDensity = baseCloud * lerp(1.0, detailWorley, erosion);

                return finalDensity * heightGradient * _DensityMultiplier;
            }

            float LightMarch(float3 pos, float3 lightDir)
            {
                int steps = (int)_ShadowSteps;
                float stepSize = 12.0;
                float totalDensity = 0.0;

                for (int i = 0; i < steps; i++)
                {
                    pos += lightDir * stepSize;
                    totalDensity += GetCloudDensity(pos);
                }

                return exp(-totalDensity * stepSize * _LightAbsorption * 0.05);
            }

            float ComputeSoftSceneShadow(float3 surfaceWorldPos, float3 lightDir, float dither)
            {
                float distToCam = distance(surfaceWorldPos, _WorldSpaceCameraPos);
                float shadowFade = 1.0 - smoothstep(_CloudMaxDistance * 0.5, _CloudMaxDistance, distToCam);

                if (shadowFade <= 0.001) return 1.0;

                float tEntry, tExit;
                if (!RayHorizIntersect(surfaceWorldPos, lightDir, _MinHeight, _MaxHeight, tEntry, tExit)) 
                    return 1.0;

                float3 currentPos = surfaceWorldPos + lightDir * (tEntry + (dither - 0.5) * _ShadowBlur * 10.0);
                float rayLen = tExit - tEntry;
                
                int steps = (int)_ShadowSteps;
                float stepSize = rayLen / (float)steps;
                float totalDensity = 0.0;

                for (int i = 0; i < steps; i++)
                {
                    totalDensity += GetCloudDensity(currentPos);
                    currentPos += lightDir * stepSize;
                }

                float transmittance = exp(-totalDensity * stepSize * _LightAbsorption * 0.05);
                float shadow = lerp(1.0 - _SceneShadowStrength, 1.0, transmittance);

                return lerp(1.0, shadow, shadowFade);
            }

            // --- Main Pass ---
            FragOutput Frag(Varyings input)
            {
                FragOutput output;
                const float MIN_DENSITY = 0.001;

                float2 uv = input.texcoord;
                float rawDepth = SampleSceneDepth(uv);
                float3 rayOrigin = _WorldSpaceCameraPos;
                
                float3 sceneWorldPos = ComputeWorldSpacePosition(uv, rawDepth, UNITY_MATRIX_I_VP);
                float3 rayDir = normalize(sceneWorldPos - rayOrigin);
                float maxSceneDist = distance(sceneWorldPos, rayOrigin);

                float4 sceneColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);
                float dither =InterleavedGradientNoise(input.positionCS.xy)*_Dithering;

                Light mainLight = GetMainLight();
                float3 rawLightDir = normalize(mainLight.direction);

                ////adaptive lighting direction for clouds at dusk/night
                float3 cloudLightDir = rawLightDir;
                if (cloudLightDir.y < 0.05)
                {
                    // invert Y lighting so that the clouds are lit from above by the sky/moon
                    float3 invertedLight = normalize(float3(rawLightDir.x, abs(rawLightDir.y) + 0.15, rawLightDir.z));
                    cloudLightDir = lerp(invertedLight, rawLightDir, smoothstep(-0.1, 0.05, rawLightDir.y));
                }

                // fade т≥ней на земл≥ б≥л€ горизонту  30% - 0%
                float sunElevation = rawLightDir.y;
                float shadowSunFade = smoothstep(0.1, 0.4, sunElevation);

                // ==========================================
                // Reimarching Hills (Terrain)
                // ==========================================
                float3 activeWorldPos = sceneWorldPos;
                float surfaceDist = maxSceneDist;
                float3 surfaceColor = sceneColor.rgb;
                float finalDepth = rawDepth;

                float terrainHitPos;
                float3 hitPos;
                float octaveDetails;
                float searchDist = min(_TerrainMaxDistance, maxSceneDist);

                if (RaymarchTerrain(rayOrigin, rayDir, searchDist, dither, hitPos, terrainHitPos, octaveDetails))
                {
                    if (terrainHitPos < maxSceneDist)
                    {
                        surfaceDist = terrainHitPos;
                        activeWorldPos = hitPos;

                        float3 normal = GetTerrainNormal(hitPos);
                        float NdotL = saturate(dot(normal, normalize(mainLight.direction)));

                        // for mesh shadows on terrain
                        float4 shadowCoord = TransformWorldToShadowCoord(hitPos);
                        Light terrainMainLight = GetMainLight(shadowCoord);
                        float meshShadowOnTerrain = terrainMainLight.shadowAttenuation;

                        float slope = normal.y;          // Slope: 1.0 = flat surface, 0.0 = sheer cliff               
                        float microNoise = Noise3D(hitPos * _NoiseColorScale);  //  Additional noise for procedural pain                      
                        
                        // Mixing of rock and soil/vegetation depending on slope and noise
                        float midFactor = smoothstep(0.4, 0.85, slope + (octaveDetails * 0.2 - 0.1));
                        float3 rockAndMid = lerp(_BaseColor.rgb, _MidColor.rgb, midFactor);
                        //  Snow peaks on Elevated and Flat Areas
                        float snowFactor = smoothstep(_SnowLine - 15.0, _SnowLine + 15.0, hitPos.y + slope * 20.0 + microNoise * 10.0);
                        float3 terrainBaseCol = lerp(rockAndMid, _PeakColor.rgb, snowFactor);
                        float detailTint = lerp(0.85, 1.15, frac(octaveDetails * 3.0 + microNoise));
                        
                            // meshShadowOnTerrain for soft shadows fr meshes
                        float3 meshAmbientShadowColor = _AmbientLightIntensity + (1.0 - meshShadowOnTerrain) * _MeshShadowColor.rgb * 0.5;
                        surfaceColor = terrainBaseCol * detailTint * (NdotL * mainLight.color * meshShadowOnTerrain + meshAmbientShadowColor);
                        //surfaceColor = terrainBaseCol * detailTint * (NdotL * mainLight.color + 0.15);

                        //Smooth blending of mountains with horizon/background
                        float distFade = smoothstep(_TerrainMaxDistance * 0.7, _TerrainMaxDistance, terrainHitPos);
                        surfaceColor = lerp(surfaceColor, sceneColor.rgb, distFade);

                        // calc depth for SV_Depth
                        float4 clipPos = TransformWorldToHClip(hitPos);
                        finalDepth = lerp(clipPos.z / clipPos.w, rawDepth, distFade);
                    }
                }

                // ==========================================
                //Shadows from the clouds on the surface
                // ==========================================
                float cloudShadow = ComputeSoftSceneShadow(activeWorldPos, cloudLightDir, dither);                
                cloudShadow = lerp(1.0, cloudShadow, shadowSunFade);// mult 1..0 for shadows as the sun approaches the horizon
                surfaceColor = lerp(surfaceColor * _CloudShadowColor.rgb, surfaceColor, cloudShadow);

                // ==========================================
                // Cloud March
                // ==========================================
                float tEntry, tExit;
                bool hitHoriz = RayHorizIntersect(rayOrigin, rayDir, _MinHeight, _MaxHeight, tEntry, tExit);

                if (!hitHoriz || tEntry >= surfaceDist || tEntry >= _CloudMaxDistance)
                {
                    output.color = float4(surfaceColor, sceneColor.a);
                    output.depth = finalDepth;
                    return output;
                }

                tEntry = min(tEntry, surfaceDist);
                tExit = min(tExit, surfaceDist);
                tExit = min(tExit, _CloudMaxDistance);

                float accumulatedTransmittance = 1.0;
                float3 accumulatedLight = 0.0;
                int maxCloudSteps = (int)_CloudSteps;
                float rayLength = tExit - tEntry;
                float stepSize = rayLength / (float)maxCloudSteps; 
                float currentT = tEntry + stepSize * dither;

                //// FOR PERPENDICULAR LAYERS OF THE MERCH CAMERA
                //// 1 get the camera direction vector Forward (in Unity View Space fwd Ч is float3(0, 0, -1)
                //float3 camForward = TransformViewToWorldDir(float3(0, 0, -1));
                //                // 2. cosi of the angl btw the dir of ray and  dir of  cam
                //float cosAngle = max(0.0001, dot(rayDir, camForward));
                ////  ABSOLUTE global step along the Z-axis for the entire screen.
                //// dynami adjusts depend on whether the camera is pointing upward (zenith) or straight ahead (horizon).
                //float camTilt = abs(camForward.y); 
                //float cloudThickness = _MaxHeight - _MinHeight;
                //float maxViewDepth = lerp(_CloudMaxDistance, cloudThickness, camTilt);
                //// A single, constant step for all rays in the frame
                //float stepZ = maxViewDepth / (float)maxCloudSteps;
                //// Depth of entry into the cloud (forms planes perpendicular to the camera)
                //float zEntry = tEntry * cosAngle;
                //// Strictly align the start point to the GLOBAL grid so that the planes are level
                //float startZ = floor(zEntry / stepZ) * stepZ;
                //float currentZ = startZ + stepZ * dither;


                float cosTheta = dot(rayDir, cloudLightDir);
                float phase = HenyeyGreenstein(cosTheta, _SilverLiningSpread) * _SilverLiningIntensity;

                for (int i = 0; i < maxCloudSteps; i++)
                {
                    //// Convert the plane depth Z back to the ray distance T for this pixel
                    //float currentT = currentZ / cosAngle;//ONLY FOR THE PERPENDICULAR METHOD

                    if (currentT >= tExit) 
                        break;

                    float3 currentPos = rayOrigin + rayDir * currentT;
                    float distFade = 1.0 - smoothstep(_CloudMaxDistance * 0.5, _CloudMaxDistance, currentT);
                    float density = GetCloudDensity(currentPos) * distFade;

                    if (density > MIN_DENSITY)
                    {
                        //float actualStepSize = stepZ / cosAngle;//PERPENDICULAR
                        float stepFade = density * _LightAbsorption;
                        float stepTransmittance = exp(-stepFade * stepSize);
                        //float stepTransmittance = exp(-stepExtinction * actualStepSize);
                        float stepAlpha = 1.0 - stepTransmittance;
                        float lightTransmittance = LightMarch(currentPos, cloudLightDir);
                       
                        // mesh shadow on clouds
                        float meshShadowOnCloud = GetSceneMeshShadow(currentPos);
                        //smooth mesh shadow on clouds
                        float3 meshShadowColor = lerp(_MeshShadowColor.rgb+ _AmbientLightIntensity, float3(1,1,1), meshShadowOnCloud);
                        lightTransmittance *= meshShadowOnCloud;//dec light on shad
                       
                        //float3 cloudColorSample = lerp(_CloudShadowColor.rgb, _CloudColor.rgb, lightTransmittance);
                        float3 cloudColorSample = lerp(_CloudShadowColor.rgb*meshShadowColor, _CloudColor.rgb * (1.0 + phase), lightTransmittance);//with silverLine
                        accumulatedLight += cloudColorSample * stepAlpha * accumulatedTransmittance;
                        accumulatedTransmittance *= stepTransmittance;

                        if (accumulatedTransmittance < 0.01)
                            break;
                    }
                    currentT += stepSize;
                    //currentZ += stepZ;// for perpendicular
                }

                float totalTransmittance = saturate(accumulatedTransmittance);
                float3 finalColor = accumulatedLight + surfaceColor * totalTransmittance;

                output.color = float4(finalColor, sceneColor.a);
                output.depth = finalDepth;
                return output;
            }
            ENDHLSL
        }
    }
}