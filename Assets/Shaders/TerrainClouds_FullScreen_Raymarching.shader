Shader "Custom/FullScreen_TerrainClouds_Raymarching"
{
    Properties
    {
        [Header(Terrain Shape)]
        _MountainHeight ("Mountain Height Multiplier", Float) = 150.0
        _MountainScale ("Mountain Horizontal Scale", Range(0.0001, 0.05)) = 0.002
        _SnowLine ("Snow Line Height (Y)", Float) = 80.0
        _TerrainMaxDistance ("Terrain Render Distance", Float) = 1500.0
        _TerrainMaxSteps ("Terrain Raymarch Steps", Range(16, 256)) = 80
        
        [Header(Terrain Colors and Palette)]
        _BaseColor ("Base Rock Color", Color) = (0.18, 0.2, 0.22, 1.0)
        _MidColor ("Dirt / Vegetation Color", Color) = (0.28, 0.32, 0.22, 1.0)
        _PeakColor ("Snow Peak Color", Color) = (0.88, 0.92, 0.95, 1.0)
        _NoiseColorScale ("Color Detail Noise Scale", Float) = 0.02

        [Header(Cloud Height Settings)]
        _MinHeight ("Min Cloud Height (Y)", Float) = 120.0
        _MaxHeight ("Max Cloud Height (Y)", Float) = 220.0
        
        [Header(Cloud Shaping)]
        _CloudScale ("Cloud Micro Scale", Range(0.0001, 0.1)) = 0.03
        _WeatherScale ("Weather Macro Scale", Range(0.001, .1)) = 0.003
        _WarpStrength ("Turbulence (Warp)", Float) = 1.5
        _Coverage ("Cloud Coverage", Range(0, 1)) = 0.5   
        _DensityMultiplier ("Cloud Density / Opacity", Range(0, 1)) = 0.4
        
        [Header(Cloud Lighting and Shadows)]
        _CloudSteps ("Cloud March Steps", Range(16, 128)) = 48
        _ShadowSteps ("Shadow March Steps", Range(1, 8)) = 3
        _ShadowBlur ("Shadow Softness Blur", Range(0.1, 10.0)) = 4.0
        _CloudMaxDistance ("Cloud Fade Distance", Float) = 1200.0
        _WindSpeed ("Wind Speed", Vector) = (0.2, 0.0, 0.1, 0.0)
        _CloudColor ("Sunlit Cloud Color", Color) = (1.0, 0.98, 0.95, 1.0)
        _CloudShadowColor ("Shadow Color", Color) = (0.3, 0.35, 0.45, 1.0)
        _LightAbsorption ("Light Absorption", Float) = 0.8
        _SceneShadowStrength ("Ground Shadow Strength", Range(0, 1)) = 0.7
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            #include "Assets/Shaders/RaymarchCore.hlsl"

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

            // Cloud Params
            float _MinHeight;
            float _MaxHeight;
            float _CloudScale;
            float _WeatherScale;
            float _WarpStrength;
            float _Coverage;
            float _DensityMultiplier;
            float _CloudSteps;
            float _ShadowSteps;
            float _ShadowBlur;
            float4 _CloudShadowColor;
            float _LightAbsorption;
            float4 _CloudColor;
            float4 _WindSpeed;
            float _CloudMaxDistance;
            float _SceneShadowStrength;

            struct FragOutput
            {
                float4 color : SV_Target;
                float depth : SV_Depth;
            };


            // --- Terrain Helpers ---
            float GetTerrainHeight(float2 p, out float octaveNoise)
            {
                float h = 0.0;
                float amp = 1.0;
                float freq = _MountainScale;
                octaveNoise = 0.0;

                for (int i = 0; i < 5; i++)
                {
                    float n = 1.0 - abs(Noise3D(float3(p * freq, 0.0)) * 2.0 - 1.0);
                    h += n * n * amp;
                    if (i >= 2) octaveNoise += n * amp; // Використовуємо деталізовані октави для текстової варіації
                    freq *= 2.1;
                    amp *= 0.45;
                }
                return h * _MountainHeight;
            }

            float GetTerrainHeightSimple(float2 p)
            {
                float unused;
                return GetTerrainHeight(p, unused);
            }

            float3 GetTerrainNormal(float3 p)
            {
                float e = 0.5;
                return normalize(float3(
                    GetTerrainHeightSimple(p.xz - float2(e, 0)) - GetTerrainHeightSimple(p.xz + float2(e, 0)),
                    2.0 * e,
                    GetTerrainHeightSimple(p.xz - float2(0, e)) - GetTerrainHeightSimple(p.xz + float2(0, e))
                ));
            }

            // Виправлений стабільний маршинг рельєфу
            bool RaymarchTerrain(float3 ro, float3 rd, float maxDist, out float3 hitPos, out float hitDist, out float octaveDetails)
            {
                float t = 0.0;
                float tPrev = 0.0; // Гарантує точний вихідний інтервал бінарного пошуку
                int steps = (int)_TerrainMaxSteps;

                for (int i = 0; i < steps; i++)
                {
                    hitPos = ro + rd * t;
                    float h = GetTerrainHeight(hitPos.xz, octaveDetails);
                    float diff = hitPos.y - h;

                    // Перетин поверхні
                    if (diff < 0.0)
                    {
                        // Бінарний пошук строго між tPrev (над землею) і t (під землею)
                        float tMin = tPrev;
                        float tMax = t;

                        for (int j = 0; j < 6; j++)
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
                        GetTerrainHeight(hitPos.xz, octaveDetails); // Оновлюємо деталі для точки хіта
                        return true;
                    }

                    tPrev = t;
                    // Динамічний крок, що зменшується при наближенні до поверхні
                    t += max(1.0, diff * 0.35);
                    if (t > maxDist) break;
                }
                return false;
            }

            // --- Cloud Helpers ---
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
                ) * _WarpStrength;

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

                float2 uv = input.texcoord;
                float rawDepth = SampleSceneDepth(uv);
                float3 rayOrigin = _WorldSpaceCameraPos;
                
                float3 sceneWorldPos = ComputeWorldSpacePosition(uv, rawDepth, UNITY_MATRIX_I_VP);
                float3 rayDir = normalize(sceneWorldPos - rayOrigin);
                float maxSceneDist = distance(sceneWorldPos, rayOrigin);

                float4 sceneColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);
                float dither = InterleavedGradientNoise(input.positionCS.xy);

                // ==========================================
                // КРОК 1: Реймарчинг Гір (Terrain)
                // ==========================================
                float3 activeWorldPos = sceneWorldPos;
                float surfaceDist = maxSceneDist;
                float3 surfaceColor = sceneColor.rgb;
                float finalDepth = rawDepth;

                float terrainHitPos;
                float3 hitPos;
                float octaveDetails;
                float searchDist = min(_TerrainMaxDistance, maxSceneDist);

                if (RaymarchTerrain(rayOrigin, rayDir, searchDist, hitPos, terrainHitPos, octaveDetails))
                {
                    if (terrainHitPos < maxSceneDist)
                    {
                        surfaceDist = terrainHitPos;
                        activeWorldPos = hitPos;

                        Light mainLight = GetMainLight();
                        float3 normal = GetTerrainNormal(hitPos);
                        float NdotL = saturate(dot(normal, normalize(mainLight.direction)));

                        // 1. Показник нахилу (Slope): 1.0 = плоска поверхня, 0.0 = отвесна скеля
                        float slope = normal.y;

                        // 2. Додатковий шум для процедурного зафарбовування
                        float microNoise = Noise3D(hitPos * _NoiseColorScale);
                        
                        // 3. Змішування скелі та ґрунту/рослинності залежно від нахилу та шуму
                        float midFactor = smoothstep(0.4, 0.85, slope + (octaveDetails * 0.2 - 0.1));
                        float3 rockAndMid = lerp(_BaseColor.rgb, _MidColor.rgb, midFactor);

                        // 4. Накладання снігу на високі та плоскі ділянки
                        float snowFactor = smoothstep(_SnowLine - 15.0, _SnowLine + 15.0, hitPos.y + slope * 20.0 + microNoise * 10.0);
                        float3 terrainBaseCol = lerp(rockAndMid, _PeakColor.rgb, snowFactor);
                        
                        // Фактурний множник з октав шуму
                        float detailTint = lerp(0.85, 1.15, frac(octaveDetails * 3.0 + microNoise));
                        
                        surfaceColor = terrainBaseCol * detailTint * (NdotL * mainLight.color + 0.15);

                        // Плавне злиття гір із горизонтом/фоном
                        float distFade = smoothstep(_TerrainMaxDistance * 0.7, _TerrainMaxDistance, terrainHitPos);
                        surfaceColor = lerp(surfaceColor, sceneColor.rgb, distFade);

                        // Розрахунок глибини для SV_Depth
                        float4 clipPos = TransformWorldToHClip(hitPos);
                        finalDepth = lerp(clipPos.z / clipPos.w, rawDepth, distFade);
                    }
                }

                // ==========================================
                // КРОК 2: Тіні від хмар на поверхню
                // ==========================================
                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);

                float cloudShadow = ComputeSoftSceneShadow(activeWorldPos, lightDir, dither);
                surfaceColor = lerp(surfaceColor * _CloudShadowColor.rgb, surfaceColor, cloudShadow);

                // ==========================================
                // КРОК 3: Реймарчинг Хмар
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

                int maxCloudSteps = (int)_CloudSteps;
                float rayLength = tExit - tEntry;
                float stepSize = rayLength / (float)maxCloudSteps; 

                float accumulatedTransmittance = 1.0;
                float3 accumulatedLight = 0.0;
                float currentT = tEntry + stepSize * dither;

                for (int i = 0; i < maxCloudSteps; i++)
                {
                    if (currentT >= tExit) break;

                    float3 currentPos = rayOrigin + rayDir * currentT;
                    float distFade = 1.0 - smoothstep(_CloudMaxDistance * 0.5, _CloudMaxDistance, currentT);
                    float density = GetCloudDensity(currentPos) * distFade;

                    if (density > 0.001)
                    {
                        float stepExtinction = density * _LightAbsorption;
                        float stepTransmittance = exp(-stepExtinction * stepSize);
                        float stepAlpha = 1.0 - stepTransmittance;

                        float lightTransmittance = LightMarch(currentPos, lightDir);
                        float3 cloudColorSample = lerp(_CloudShadowColor.rgb, _CloudColor.rgb, lightTransmittance);

                        accumulatedLight += cloudColorSample * stepAlpha * accumulatedTransmittance;
                        accumulatedTransmittance *= stepTransmittance;

                        if (accumulatedTransmittance < 0.01) break;
                    }
                    currentT += stepSize;
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