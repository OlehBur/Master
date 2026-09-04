Shader "Custom/FullScreenTerrainRaymarching"
{
    Properties
    {
        [Header(Terrain Shape)]
        _MountainHeight ("Mountain Height Multiplier", Float) = 150.0
        _MountainScale ("Mountain Horizontal Scale", Range(0.0001, 0.05)) = 0.002
        _SnowLine ("Snow Line Height (Y)", Float) = 80.0
        
        [Header(Performance and Distance)]
        _MaxDistance ("Terrain Render Distance", Float) = 1500.0
        _MaxSteps ("Raymarch Steps", Range(16, 256)) = 80
        
        [Header(Colors)]
        _BaseColor ("Rock Base Color", Color) = (0.2, 0.22, 0.25, 1.0)
        _PeakColor ("Snow Peak Color", Color) = (0.85, 0.9, 0.95, 1.0)
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
            Name "TerrainRaymarchingPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            #include "Assets/Shaders/RaymarchCore.hlsl"

            float _MountainHeight;
            float _MountainScale;
            float _SnowLine;
            float _MaxDistance;
            float _MaxSteps;
            float4 _BaseColor;
            float4 _PeakColor;

            struct FragOutput
            {
                float4 color : SV_Target;
                float depth : SV_Depth;
            };

            float GetTerrainHeight(float2 p)
            {
                float h = 0.0;
                float amp = 1.0;
                float freq = _MountainScale;

                for (int i = 0; i < 5; i++)
                {
                    float n = 1.0 - abs(Noise3D(float3(p * freq, 0.0)) * 2.0 - 1.0);
                    h += n * n * amp;
                    freq *= 2.1;
                    amp *= 0.45;
                }
                return h * _MountainHeight;
            }

            float3 GetTerrainNormal(float3 p)
            {
                float e = 0.5;
                return normalize(float3(
                    GetTerrainHeight(p.xz - float2(e, 0)) - GetTerrainHeight(p.xz + float2(e, 0)),
                    2.0 * e,
                    GetTerrainHeight(p.xz - float2(0, e)) - GetTerrainHeight(p.xz + float2(0, e))
                ));
            }

            bool RaymarchTerrain(float3 ro, float3 rd, float maxDist, float dither, out float3 hitPos, out float hitDist)
            {
                float t = stepSizeDither(dither);
                float stepSize = 4.0;
                int steps = (int)_MaxSteps;

                for (int i = 0; i < steps; i++)
                {
                    hitPos = ro + rd * t;
                    float h = GetTerrainHeight(hitPos.xz);

                    if (hitPos.y < h)
                    {
                        // Уточнення бінарним пошуком
                        float tMin = t - stepSize;
                        float tMax = t;
                        for (int j = 0; j < 5; j++)
                        {
                            float tMid = (tMin + tMax) * 0.5;
                            float3 midP = ro + rd * tMid;
                            if (midP.y < GetTerrainHeight(midP.xz))
                                tMax = tMid;
                            else
                                tMin = tMid;
                        }
                        hitPos = ro + rd * tMax;
                        hitDist = tMax;
                        return true;
                    }

                    t += max(stepSize, (hitPos.y - h) * 0.4);
                    if (t > maxDist) break;
                }
                return false;
            }

            FragOutput Frag(Varyings input)
            {
                FragOutput output;

                float2 uv = input.texcoord;
                float rawDepth = SampleSceneDepth(uv);
                float3 worldPos = ComputeWorldSpacePosition(uv, rawDepth, UNITY_MATRIX_I_VP);
                
                float3 rayOrigin = _WorldSpaceCameraPos;
                float3 rayDir = normalize(worldPos - rayOrigin);
                float maxSceneDist = distance(worldPos, rayOrigin);

                float4 sceneColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);

                float dither = InterleavedGradientNoise(input.positionCS.xy);
                float3 hitPos;
                float hitDist;

                // Обмеження дистанції пошуку
                float searchDist = min(_MaxDistance, maxSceneDist);

                if (RaymarchTerrain(rayOrigin, rayDir, searchDist, dither, hitPos, hitDist))
                {
                    if (hitDist >= maxSceneDist)
                    {
                        output.color = sceneColor;
                        output.depth = rawDepth;
                        return output;
                    }

                    Light mainLight = GetMainLight();
                    float3 normal = GetTerrainNormal(hitPos);
                    float NdotL = saturate(dot(normal, normalize(mainLight.direction)));

                    float snowFactor = smoothstep(_SnowLine - 10.0, _SnowLine + 20.0, hitPos.y + normal.y * 15.0);
                    float3 terrainBaseCol = lerp(_BaseColor.rgb, _PeakColor.rgb, snowFactor);
                    float3 finalColor = terrainBaseCol * (NdotL * mainLight.color + 0.15);

                    // Плавний фейд гір на граничній дистанції _MaxDistance
                    float distFade = smoothstep(_MaxDistance * 0.7, _MaxDistance, hitDist);
                    finalColor = lerp(finalColor, sceneColor.rgb, distFade);

                    float4 clipPos = TransformWorldToHClip(hitPos);
                    float calculatedDepth = clipPos.z / clipPos.w;

                    output.color = float4(finalColor, 1.0);
                    output.depth = lerp(calculatedDepth, rawDepth, distFade);
                }
                else
                {
                    output.color = sceneColor;
                    output.depth = rawDepth;
                }

                return output;
            }
            ENDHLSL
        }
    }
}