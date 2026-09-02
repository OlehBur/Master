Shader "Custom/FullScreenRaymarching"
{
    Properties
    {
        _MinHeight ("Min Cloud Height (Y)", Float) = 20.0
        _MaxHeight ("Max Cloud Height (Y)", Float) = 60.0
        _CloudScale ("Cloud Scale", Float) = 0.02
        _WeatherScale ("Weather Map Scale (Macro)", Float) = 0.002
        _WarpStrength ("Domain Warp (Turbulence)", Float) = 2.0
        _Coverage ("Cloud Coverage (Clustering)", Range(0, 1)) = 0.5   
        _DensityMultiplier ("Cloud Density / Opacity", Float) = 5.0
        
        [Header(Movement)]
        _WindSpeed ("Wind Speed", Vector) = (0.2, 0.0, 0.1, 0.0)
        _MaxDistance ("Horizon Fade Distance", Float) = 400.0

        [Header(Lighting)]
        _CloudColor ("Cloud Color", Color) = (0.95, 0.95, 1.0, 1.0)
        _CloudShadowColor ("Shadowed Cloud Color", Color) = (0.25, 0.28, 0.38, 1.0)
        _LightAbsorption ("Light Absorption", Float) = 0.4
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        LOD 100
        ZWrite Off ZTest Always Cull Off

        Pass
        {
            Name "RaymarchingPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            // URP libs
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
            float4 _CloudShadowColor;
            float _LightAbsorption;
            float4 _CloudColor;
            float4 _WindSpeed;
            float _MaxDistance;


            //height Gradient
            float GetHeightGradient(float heightPercent)
            {
                //flat bottom (0.0-0.1), round center (0.2-0.7), smooth fade on top (0.7-1.0)
                float bottomFade = smoothstep(0.0, 0.2, heightPercent);
                float topFade = smoothstep(1.0, 0.7, heightPercent);
                return bottomFade * topFade;
            }

            //dens with macromask weather map
            float GetCloudDensity(float3 p)//(Perlin + Worley Hybrid)
            {
                const float WIND_MULT = 0.01;
                const float WORLEY_SCALE = 3.5;
                const float HEIGHT_EPS = 0.001;

                float heightPercent = (p.y - _MinHeight) / (_MaxHeight - _MinHeight);
                if (heightPercent < 0.0 || heightPercent > 1.0)
                    return 0.0;
                
                // cumulus cloud profile
                float flatBottom = smoothstep(0.0, 0.06, heightPercent);
                float roundedTop = smoothstep(1.0, 0.35, heightPercent);
                float heightGradient = flatBottom * roundedTop;
                //float heightGradient = GetHeightGradient(heightPercent);

                if (heightGradient <= HEIGHT_EPS) 
                    return 0.0;

                float3 wind = _WindSpeed.xyz * _Time.y;

                    //turbulence domain warp
                float3 warpVector = float3(
                    Noise3D(p * 0.015 + wind * 0.05),
                    Noise3D(p * 0.015 + float3(12.3, 4.5, 7.8)),
                    Noise3D(p * 0.015 + float3(5.2, 1.3, 8.1) + wind * 0.05)
                ) * _WarpStrength;
                //float3 samplePos = (p + wind) * _CloudScale;
                float3 samplePos = (p + wind + warpVector) * _CloudScale;

                                    //macro map
                float3 weatherPos = float3(p.x, 0.0, p.z) * _WeatherScale + wind * WIND_MULT;
                float macroWeather = Fbm(weatherPos);
                //narrow cloud upwards (hills formed)
                float effectiveCoverage = _Coverage * lerp(0.2, 1.2, macroWeather) * heightGradient;
                //float effectiveCoverage = _Coverage * lerp(0.3, 1.3, macroWeather);//smoth cover threshold
                if (effectiveCoverage <= 0.02)
                    return 0.0;

                    // base form Fbm (Perlin) 
                float baseFbm = Fbm(samplePos);
                // cut shell _Coverage
                float baseCloud = smoothstep(1.0 - effectiveCoverage, 1.0 - effectiveCoverage + 0.15, baseFbm);
                //float baseCloud = smoothstep(1.0 - _Coverage, 1.0, baseFbm);

                if (baseCloud <= 0.001)
                    return 0.0;

                    // detalized facture  tin Worley-noise for surface
                float3 detailPos = samplePos * WORLEY_SCALE; // in 3.5 smaller scale for detail Worley
                float detailWorley = Worley3D(detailPos);
                //erosion
                float cloudErosion = lerp(0.15, 0.55, heightPercent);//smooth subtract
                //float cloudErosion = lerp(1.0, detailWorley, 0.45);//smooth subtract
                //float finalDensity = baseCloud * cloudErosion;
                float finalDensity = baseCloud * lerp(1.0, detailWorley, cloudErosion);

                return finalDensity * _DensityMultiplier;
            }

            // Haney-Greenstein phase function for the "silver glow" of edges in the sun
            float HenyeyGreenstein(float g, float cosTheta)
            {
                float g2 = g * g;
                return (1.0 - g2) / (4.0 * 3.1415926 * pow(max(0.001, 1.0 + g2 - 2.0 * g * cosTheta), 1.5));
            }

            //second marching to sun (calc inner shadows)
            float LightMarch(float3 pos, float3 lightDir)
            {
                int steps = 5; //over productive steps cnt
                float stepSize = 10.0;
                float totalDensity = 0.0;

                for (int i = 0; i < steps; i++)
                {
                    pos += lightDir * stepSize;
                    totalDensity += GetCloudDensity(pos);
                }

                // Bouguer-Lambert-Behr law for light fading
                return exp(-totalDensity * stepSize * _LightAbsorption*0.01);//* 0.05
            }


            half4 Frag(Varyings input) : SV_Target
            {
                const float TRANSPARANCY_EPS = 0.01;

                float2 uv = input.texcoord;
                // get sceme depth fr _CameraDepthTexture
                float rawDepth = SampleSceneDepth(uv);
                // calc exact pix pos in scene (World Space)
                float3 worldPos = ComputeWorldSpacePosition(uv, rawDepth, UNITY_MATRIX_I_VP);                
                
                //cam ray
                float3 rayOrigin = _WorldSpaceCameraPos; //from cam pos
                float3 rayDir = normalize(worldPos - rayOrigin); // direction — from camera to scene geometry                
                // max dist ray can travel before hit regular mesh
                float maxSceneDist = distance(worldPos, rayOrigin);

                float tEntry, tExit;
                bool hitHoriz= RayHorizIntersect(rayOrigin, rayDir, _MinHeight, _MaxHeight, tEntry, tExit);
                float4 sceneColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);

                if (!hitHoriz|| tEntry >= maxSceneDist)
                {
                    return sceneColor; // if ray doesnt hit cloud lay - return scene col
                }

                // limit clouds by scene objects & horizont
                tExit = min(tExit, maxSceneDist);
                tExit = min(tExit, tEntry+_MaxDistance);
 
                    // light data fr URP main light
                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);
                float3 lightColor = mainLight.color;

                // scattering light towards camera effect 
                float cosTheta = dot(rayDir, lightDir);
                float forwardScattering = HenyeyGreenstein(0.6, cosTheta);

                // raymarch inside cloud layer
                int maxSteps = 64;
                float rayLength = tExit - tEntry;
                float stepSize = rayLength / (float)maxSteps; // dynamic step

                float accumulatedTransmittance = 1.0;
                //float accumulatedDensity = 0.0;
                float3 accumulatedLight = 0.0;
                float currentT = tEntry;

                for (int i = 0; i < maxSteps; i++)
                {
                    float3 currentPos = rayOrigin + rayDir * currentT;
                    // fade on horizont
                    float distFade = 1.0 - smoothstep(_MaxDistance * 0.6, _MaxDistance, currentT - tEntry);
                    float density = GetCloudDensity(currentPos)* distFade;

                    if (density > 0.001)
                    {
                        ////how much sunlight reaches this point
                        //float lightTransmittance = LightMarch(currentPos, lightDir);
                        ////fr base to shadow color
                        //float3 cloudColorSample = lerp(_CloudShadowColor.rgb, _CloudColor.rgb, lightTransmittance);
                        //// Silver Lining effect ( extra light scattering for sunlit edges)
                        //cloudColorSample += lightColor * forwardScattering * lightTransmittance * 1.5;

                        //float currentTransmittance = exp(-accumulatedDensity);
                        //accumulatedLight += cloudColorSample * density * stepSize * currentTransmittance;

                        //accumulatedDensity += density * stepSize * 0.1; // smooth accum color

                        //// for optimizati stop march in case full opque
                        //if (exp(-accumulatedDensity) < 0.01)
                        //    break;

                        // calc transparancy curr step
                        float stepExtinction = density * _LightAbsorption;
                        float stepTransmittance = exp(-stepExtinction * stepSize);
                        float stepAlpha = 1.0 - stepTransmittance;

                        //0 =full sjadow, 1 = full light
                        float lightTransmittance = LightMarch(currentPos, lightDir);
                        // gradient fr shadow color to sun color
                        float3 cloudColorSample = lerp(_CloudShadowColor.rgb, _CloudColor.rgb, lightTransmittance);
                        // Silver Lining effect ( extra light scattering for sunlit edges)
                        cloudColorSample += lightColor * forwardScattering * lightTransmittance * 1.2;
                        //clampet to avoid overbright
                        accumulatedLight += cloudColorSample * stepAlpha * accumulatedTransmittance;
                        // dec transparency for next steps
                        accumulatedTransmittance *= stepTransmittance;

                        if (accumulatedTransmittance < TRANSPARANCY_EPS)
                            break;
                    }
                    //accumulatedDensity += density * stepSize;
                    currentT += stepSize;
                }

                //float transmittance = exp(-accumulatedDensity * 3.0);
                //float3 finalColor = lerp(_CloudColor.rgb, sceneColor.rgb, transmittance);
                float totalTransmittance = saturate(accumulatedTransmittance);                
                //float totalTransmittance = saturate(exp(-accumulatedDensity));                
                float3 finalColor = accumulatedLight + sceneColor.rgb * totalTransmittance;

                return float4(finalColor, sceneColor.a);
            }
            ENDHLSL
        }
    }
}