Shader "Custom/ThrustFire"
{
    Properties
    {
        [Header(Colors)]
        [HDR] _CoreColor ("Core Flame Color", Color) = (0.1, 0.6, 2.0, 1.0)
        [HDR] _EdgeColor ("Outer Flame Color", Color) = (1.0, 0.25, 0.05, 1.0)
        
        [Header(Shape)]
        _Speed ("Thrust Speed", Float) = 4.0
        _NoiseScale ("Noise Scale (XYZ)", Vector) = (3.0, 6.0, 3.0, 0.0)
        _DensityMultiplier ("Density Multiplier", Range(0.1, 20.0)) = 5.0
        _RaySteps ("Raymarch Steps", Range(8, 64)) = 32
    }

    SubShader
    {
        Tags 
        { 
            "Queue"="Geometry+450" 
            "RenderType"="Opaque" 
            "RenderPipeline"="UniversalPipeline" 
        }

        // =========================================================================
        // ПАС 1: DepthOnly (Примусово записує глибину вогню в _CameraDepthTexture URP)
        // =========================================================================
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask R

            HLSLPROGRAM
            #pragma vertex DepthVert
            #pragma fragment DepthFrag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes { float4 positionOS : POSITION; };
            struct Varyings { float4 positionCS : SV_POSITION; };

            Varyings DepthVert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            half4 DepthFrag(Varyings input) : SV_TARGET
            {
                return 0;
            }
            ENDHLSL
        }

        // =========================================================================
        // ПАС 2: Основний колір та реймарчинг вогню
        // =========================================================================
        Pass
        {
            Name "ThrustFirePass"
            Tags { "LightMode" = "UniversalForward" }

            Blend One One
            ZWrite On
            ZTest LEqual
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Assets/Shaders/RaymarchCore.hlsl"

            float4 _CoreColor;
            float4 _EdgeColor;
            float _Speed;
            float4 _NoiseScale;
            float _DensityMultiplier;
            float _RaySteps;

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float4 screenPos  : TEXCOORD1;
            };

            struct FragOutput
            {
                float4 color : SV_Target;
                float depth : SV_Depth;
            };

            bool IntersectCylinder(float3 ro, float3 rd, out float tNear, out float tFar)
            {
                float a = rd.x * rd.x + rd.z * rd.z;
                float b = 2.0 * (ro.x * rd.x + ro.z * rd.z);
                float c = ro.x * ro.x + ro.z * ro.z - 0.25;

                float discr = b * b - 4.0 * a * c;
                if (discr < 0.0) return false;

                float sqrtD = sqrt(discr);
                float t0 = (-b - sqrtD) / (2.0 * a);
                float t1 = (-b + sqrtD) / (2.0 * a);

                if (t0 > t1) { float tmp = t0; t0 = t1; t1 = tmp; }

                float tYMin = (-0.5 - ro.y) / rd.y;
                float tYMax = (0.5 - ro.y) / rd.y;
                if (tYMin > tYMax) { float tmp = tYMin; tYMin = tYMax; tYMax = tmp; }

                tNear = max(t0, tYMin);
                tFar = min(t1, tYMax);

                return (tNear < tFar) && (tFar > 0.0);
            }

            float GetFireDensity(float3 pLocal)
            {
                float yNorm = pLocal.y + 0.5;
                if (yNorm < 0.0 || yNorm > 1.0) return 0.0;

                float radiusAtY = 0.45 * (1.0 - yNorm * 0.7);
                float distFromCenter = length(pLocal.xz);

                float radialMask = smoothstep(radiusAtY, 0.0, distFromCenter);
                float heightGradient = (1.0 - yNorm) * smoothstep(0.0, 0.05, yNorm);

                float3 noisePos = pLocal * _NoiseScale.xyz - float3(0.0, _Time.y * _Speed, 0.0);
                float n = Noise3D(noisePos);

                return radialMask * heightGradient * saturate(n * 1.6) * _DensityMultiplier;
            }

            Varyings Vert(Attributes input)
            {
                Varyings output;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;
                output.positionWS = vertexInput.positionWS;
                output.screenPos = ComputeScreenPos(vertexInput.positionCS);
                return output;
            }

            FragOutput Frag(Varyings input)
            {
                FragOutput output;

                float2 screenUV = input.screenPos.xy / input.screenPos.w;
                float3 worldCamPos = _WorldSpaceCameraPos;
                float3 worldRayDir = normalize(input.positionWS - worldCamPos);

                float4x4 worldToObj = GetWorldToObjectMatrix();
                float3 roLocal = mul(worldToObj, float4(worldCamPos, 1.0)).xyz;
                float3 rdLocal = normalize(mul((float3x3)worldToObj, worldRayDir));

                float tEntry, tExit;
                if (!IntersectCylinder(roLocal, rdLocal, tEntry, tExit))
                {
                    discard;
                }

                tEntry = max(0.0, tEntry);

                int steps = (int)_RaySteps;
                float stepSize = (tExit - tEntry) / (float)steps;
                float currentT = tEntry;

                float3 accumColor = float3(0, 0, 0);
                float accumTransmittance = 1.0;

                for (int i = 0; i < steps; i++)
                {
                    float3 pLocal = roLocal + rdLocal * currentT;
                    float density = GetFireDensity(pLocal);

                    if (density > 0.001)
                    {
                        float stepAlpha = 1.0 - exp(-density * stepSize);
                        float coreFactor = saturate(density * 0.3);
                        float3 stepColor = lerp(_EdgeColor.rgb, _CoreColor.rgb, coreFactor);

                        accumColor += stepColor * stepAlpha * accumTransmittance;
                        accumTransmittance *= (1.0 - stepAlpha);

                        if (accumTransmittance < 0.02) break;
                    }
                    currentT += stepSize;
                }

                float3 entryWorldPos = mul(GetObjectToWorldMatrix(), float4(roLocal + rdLocal * tEntry, 1.0)).xyz;
                float4 entryClipPos = TransformWorldToHClip(entryWorldPos);

                output.color = float4(accumColor, 1.0 - accumTransmittance);
                output.depth = entryClipPos.z / entryClipPos.w;

                return output;
            }
            ENDHLSL
        }
    }
}