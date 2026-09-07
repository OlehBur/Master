Shader "Custom/FullScreen_Clouds_Raymarching"
{
    Properties
    {
        [Header(Height Settings)]
        _MinHeight ("Min Cloud Height (Y)", Float) = 120.0
        _MaxHeight ("Max Cloud Height (Y)", Float) = 220.0
        
        [Header(Cloud Shaping)]
        _CloudScale ("Cloud Micro Scale", Float) = 0.03
        _WeatherScale ("Weather Macro Scale", Range(0.001, .1)) = 0.003
        _WarpStrength ("Turbulence (Warp)", Float) = 1.5
        _Coverage ("Cloud Coverage", Range(0, 1)) = 0.5   
        _DensityMultiplier ("Cloud Density / Opacity", Range(0, 1)) = 0.4
        
        [Header(Performance and Quality Controls)]
        _MaxSteps ("Cloud March Steps", Range(16, 128)) = 48
        _ShadowSteps ("Shadow March Steps", Range(1, 8)) = 3
        _ShadowBlur ("Shadow Softness Blur", Range(0.1, 10.0)) = 4.0
        _MaxDistance ("Horizon Fade Distance", Float) = 1200.0

        [Header(Lighting and Movement)]
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
        ZWrite Off ZTest Always Cull Off

        Pass
        {
            Name "CloudsRaymarchingPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            #include "Assets/Shaders/RaymarchCore.hlsl"
            
            float _MinHeight;
            float _MaxHeight;
            float _CloudScale;
            float _WeatherScale;
            float _WarpStrength;
            float _Coverage;
            float _DensityMultiplier;
            float _MaxSteps;
            float _ShadowSteps;
            float _ShadowBlur;
            float4 _CloudShadowColor;
            float _LightAbsorption;
            float4 _CloudColor;
            float4 _WindSpeed;
            float _MaxDistance;
            float _SceneShadowStrength;

            //float InterleavedGradientNoise(float2 pixCoord)
            //{
            //    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
            //    return frac(magic.z * frac(dot(pixCoord, magic.xy)));
            //}

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

            // М'які розмиті тіні з використанням просторового дитерингу
            float ComputeSoftSceneShadow(float3 worldPos, float3 lightDir, float dither)
            {
                float distToCam = distance(worldPos, _WorldSpaceCameraPos);
                float shadowFade = 1.0 - smoothstep(_MaxDistance * 0.5, _MaxDistance, distToCam);

                if (shadowFade <= 0.001) return 1.0;

                float tEntry, tExit;
                if (!RayHorizIntersect(worldPos, lightDir, _MinHeight, _MaxHeight, tEntry, tExit)) 
                    return 1.0;

                // Зміщення точки входу для ефекту м'яких країв (Blur)
                float3 currentPos = worldPos + lightDir * (tEntry + (dither - 0.5) * _ShadowBlur * 10.0);
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

            half4 Frag(Varyings input) : SV_Target
            {
                float2 uv = input.texcoord;
                float rawDepth = SampleSceneDepth(uv);
                float3 worldPos = ComputeWorldSpacePosition(uv, rawDepth, UNITY_MATRIX_I_VP);                
                
                float3 rayOrigin = _WorldSpaceCameraPos;
                float3 rayDir = normalize(worldPos - rayOrigin);                
                float maxSceneDist = distance(worldPos, rayOrigin);

                float dither = InterleavedGradientNoise(input.positionCS.xy);

                float tEntry, tExit;
                bool hitHoriz = RayHorizIntersect(rayOrigin, rayDir, _MinHeight, _MaxHeight, tEntry, tExit);
                float4 sceneColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);

                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);

                if (!hitHoriz || tEntry >= maxSceneDist || tEntry >= _MaxDistance)
                {
                    float sceneShadow = ComputeSoftSceneShadow(worldPos, lightDir, dither);
                    float3 shadowedScene = lerp(sceneColor.rgb * _CloudShadowColor.rgb, sceneColor.rgb, sceneShadow);
                    return float4(shadowedScene, sceneColor.a);
                }

                            // Якщо гора або об'єкт стоять ближче, ніж точка входу в хмару, зсуваємо вхід вперед або виходимо
            if (tEntry >= maxSceneDist)
            {
                // Якщо сцена ближче, ніж початок хмари, просто малюємо чистий колір сцени без хмар
                float sceneShadow = ComputeSoftSceneShadow(worldPos, lightDir, dither);
                float3 shadowedScene = lerp(sceneColor.rgb * _CloudShadowColor.rgb, sceneColor.rgb, sceneShadow);
                return float4(shadowedScene, sceneColor.a);
            }
            
            // Обмежуємо вихід і вхід відстанню до сцени
            tEntry = min(tEntry, maxSceneDist);
            tExit = min(tExit, maxSceneDist);
            tExit = min(tExit, _MaxDistance);
                //tExit = min(tExit, maxSceneDist);
                //tExit = min(tExit, _MaxDistance);

                int maxSteps = (int)_MaxSteps;
                float rayLength = tExit - tEntry;
                float stepSize = rayLength / (float)maxSteps; 

                float accumulatedTransmittance = 1.0;
                float3 accumulatedLight = 0.0;

                // Використання дизерингу для прибрання смуг розшарування
                float currentT = tEntry + stepSize * dither;

                for (int i = 0; i < maxSteps; i++)
                {
                    if (currentT >= tExit) break;

                    float3 currentPos = rayOrigin + rayDir * currentT;
                    float distFade = 1.0 - smoothstep(_MaxDistance * 0.5, _MaxDistance, currentT);
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
                float bgShadow = ComputeSoftSceneShadow(worldPos, lightDir, dither);
                float3 bgShadowedColor = lerp(sceneColor.rgb * _CloudShadowColor.rgb, sceneColor.rgb, bgShadow);

                float3 finalColor = accumulatedLight + bgShadowedColor * totalTransmittance;

                return float4(finalColor, sceneColor.a);
            }
            ENDHLSL
        }
    }
}