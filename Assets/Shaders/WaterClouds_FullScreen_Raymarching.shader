Shader "Custom/FullScreen_WaterClouds_Raymarching"
{
    Properties
    {
        [HideInInspector] _Header_General ("---{GENERAL}---", Float) = 0
        [Header(____________________________GENERAL_______________________________)]
        _MeshShadowColor ("Mesh Shadow Tint Color", Color) = (0.0, 0.17, 0.45, 1.0)
        _AmbientLightIntensity ("Ambient Light Intensity", Range(0, 1)) = 0.15        
        _Dithering ("Dithering Strength", Range(0, 1)) = 1.0
        
        
        [HideInInspector] _Header_Ocean ("---{OCEAN}---", Float) = 0
        [HideInInspector] _Header_OceanLvl ("Ocean Level and Clarity", Float) = 0
        [Header(____________________________OCEAN_______________________________)]
        [Header(Water Level and Clarity)]
        _SeaLevel ("Sea Level (Y Height)", Float) = 25.0
        _SeaTransparency ("Underwater Clarity / Depth Transparency", Range(0.001, 0.5)) = 0.0151
        _SeaColorDepth ("Color Depth Gradient Distance", Float) = 50.0
        _SeaWaterFogDensity ("Underwater Fog Density", Range(0.001, 0.1)) = 0.015
        
        [HideInInspector] _Header_Underwater ("Underwater Surface Controls", Float) = 0
        [Header(Underwater Surface Controls)]
        //_UnderSnellSize ("Underwater Window Size (Snell Radius)", Range(0.5, 10.0)) = 10.0
        _UnderRefractIndex ("Water Refraction Index (bigger = smaller window)", Range(1.0, 2.0)) = 1.33
        _UnderFoamCoverage ("Underwater Wave Foam Amount (Coverage)", Range(0.0, 1.0)) = 0.339
        _UnderFoamIntensity ("Underwater Wave Foam Brightness", Range(0, 10)) = 1.15

        [Header(Underwater God Rays)]
        _GodRayIntensity ("God Rays Intensity", Range(0, 10)) = 4.0
        _GodRayDistance ("God Rays Max Distance", Float) = 80.0
        _GodRayContrast ("God Rays Contrast", Range(0.5, 4.0)) = 1.5
        
        [HideInInspector] _Header_OceanMarch ("Ocean March", Float) = 0
        [Header(Water March)]
        _SeaMaxSteps ("Sea Raymarch Steps", Range(16, 256)) = 80
        _SeaMaxDistance ("Sea Render Distance", Float) = 400.0
        
        [HideInInspector] _Header_WavesShape ("Ocean Shape", Float) = 0
        [Header(Water Shape)]
        _SeaHeight ("Sea Wave Height", Float) = 0.5
        _SeaChoppy ("Sea Choppiness", Range(1.0, 10.0)) = 5.337
        _SeaFreq ("Sea Wave Frequency", Range(0.01, 1.0)) = 0.1412
        _SeaSpeed ("Sea Animation Speed", Range(0.1, 5.0)) = 0.76
        
        [HideInInspector] _Header_OceanColor ("Ocean Colors", Float) = 0
        [Header(Water Colors)]
        _SeaBaseColor ("Sea Deep Base Color", Color) = (0.0, 0.1, 0.25, 1.0)
        _SeaWaterColor ("Sea Shallow / SSS Color", Color) = (0.0, 0.62, 0.65, 1.0)

        [HideInInspector] _Header_Clouds ("---{CLOUDS}---", Float) = 0
        [HideInInspector] _Header_ClMarch ("Clouds March", Float) = 0
        [Header(____________________________CLOUDS_______________________________)]        [Header(Cloud March)]
        _CloudSteps ("Cloud March Steps", Range(16, 128)) = 35
        _ShadowSteps ("Shadow March Steps", Range(1, 8)) = 2
        _CloudMaxDistance ("Cloud Fade Distance", Float) = 350.0
        _CloudScale ("Cloud Micro Scale", Range(0.0001, 0.1)) = 0.0747
        
        [HideInInspector] _Header_ClShape ("Clouds Shaping", Float) = 0
        [Header(Cloud Shaping)]
        _MinHeight ("Min Cloud Height (Y)", Float) = 65.0
        _MaxHeight ("Max Cloud Height (Y)", Float) = 90.0
        _WindSpeed ("Wind Speed", Vector) = (1.0, 0.0, 0.0, 0.0)
        _WeatherScale ("Weather Macro Scale", Range(0.001, .1)) = 0.0067
        _CloudWarp ("Turbulence (Warp)", Range(0, 100)) = 15.5
        _Coverage ("Cloud Coverage", Range(0, 1)) = 1.0   
        
        [HideInInspector] _Header_ClLight ("Clouds Light", Float) = 0
        [Header(Cloud Lighting)]
        _DensityMultiplier ("Cloud Density / Opacity", Range(0, 1)) = 0.477
        _CloudColor ("Sunlit Cloud Color", Color) = (1.0, 0.98, 0.95, 1.0)
        _LightAbsorption ("Light Absorption", Range(0.1, 20)) = 20.0
        _SilverLiningIntensity ("Silver Lining Intensity", Range(0, 10)) = 1.15
        _SilverLiningSpread ("Silver Lining Spread", Range(0.1, 0.99)) = 0.949
        _CloudShadowColor ("Shadow Color", Color) = (0.0, 0.1477988, 0.4433962, 1.0)
        _SceneShadowStrength ("Ground Shadow Strength", Range(0, 1)) = 0.581
        _ShadowBlur ("Shadow Softness Blur", Range(0.1, 10.0)) = 0.1
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
            Name "WaterCloudsRaymarchingPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            #include "Assets/Shaders/RaymarchCore.hlsl"

            float4 _MeshShadowColor;
            float _AmbientLightIntensity;

            // Water Params
            float _SeaLevel;
            float _SeaTransparency;
            float _SeaColorDepth;
            float _SeaWaterFogDensity;
            //float _UnderSnellSize;
            float _UnderRefractIndex;
            float _GodRayIntensity;
            float _GodRayDistance;
            float _GodRayContrast;
            float _UnderFoamCoverage;
            float _UnderFoamIntensity;
            float _SeaMaxSteps;
            float _SeaMaxDistance;
            float _SeaHeight;
            float _SeaChoppy;
            float _SeaFreq;
            float _SeaSpeed;
            float4 _SeaBaseColor;
            float4 _SeaWaterColor;

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

            float Hash21(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }

            float Noise2D(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);
                return -1.0 + 2.0 * lerp(
                    lerp(Hash21(i + float2(0.0, 0.0)), Hash21(i + float2(1.0, 0.0)), f.x),
                    lerp(Hash21(i + float2(0.0, 1.0)), Hash21(i + float2(1.0, 1.0)), f.x),
                    f.y
                );
            }

            float SeaOctave(float2 uv, float choppy)
            {
                uv += Noise2D(uv);
                float2 wv = 1.0 - abs(sin(uv));
                float2 swv = abs(cos(uv));
                wv = lerp(wv, swv, wv);
                return pow(max(0.0, 1.0 - pow(wv.x * wv.y, 0.65)), choppy);
            }

            float MapWater(float3 p, int steps)
            {
                float freq = _SeaFreq;
                float amp = _SeaHeight;
                float choppy = _SeaChoppy;
                float2 uv = p.xz;
                uv.x *= 0.75;

                float d = 0.0;
                float h = 0.0;
                float seaTime = (1.0 + _Time.y * _SeaSpeed);
                float2x2 octave_m = float2x2(1.6, 1.2, -1.2, 1.6);

                for (int i = 0; i < steps; i++)
                {
                    d = SeaOctave((uv + seaTime) * freq, choppy);
                    d += SeaOctave((uv - seaTime) * freq, choppy);
                    h += d * amp;
                    uv = mul(octave_m, uv);
                    freq *= 1.9;
                    amp *= 0.22;
                    choppy = lerp(choppy, 1.0, 0.2);
                }
                return (p.y - _SeaLevel) - h;
            }

            float3 GetWaterNormal(float3 p, float eps)
            {
                float h = MapWater(p, 5);
                float3 n;
                n.x = MapWater(float3(p.x + eps, p.y, p.z), 5) - h;
                n.z = MapWater(float3(p.x, p.y, p.z + eps), 5) - h;
                n.y = eps;
                return normalize(n);
            }

            bool RaymarchWaterAbove(float3 ro, float3 rd, float maxDist, float dither, out float3 hitPos, out float hitDist)
            {
                float t = dither * 2.0;
                float tPrev = t;
                int steps = (int)_SeaMaxSteps;

                for (int i = 0; i < steps; i++)
                {
                    hitPos = ro + rd * t;
                    float hDiff = MapWater(hitPos, 3);

                    if (hDiff < 0.0)
                    {
                        float tMin = tPrev;
                        float tMax = t;
                        float hMin = MapWater(ro + rd * tMin, 3);
                        float hMax = hDiff;

                        for (int j = 0; j < 8; j++)
                        {
                            float tMid = lerp(tMin, tMax, saturate(hMin / (hMin - hMax + 1e-5)));
                            float3 midP = ro + rd * tMid;
                            float midH = MapWater(midP, 3);

                            if (midH < 0.0)
                            {
                                tMax = tMid;
                                hMax = midH;
                            }
                            else
                            {
                                tMin = tMid;
                                hMin = midH;
                            }
                        }

                        hitDist = tMax;
                        hitPos = ro + rd * hitDist;
                        return true;
                    }

                    tPrev = t;
                    float dt = max(0.2 + t * 0.003, hDiff * 0.5);
                    t += dt;
                    if (t > maxDist) break;
                }
                return false;
            }

            bool RaymarchWaterUnder(float3 ro, float3 rd, float maxDist, float dither, out float3 hitPos, out float hitDist)
            {
                float t = dither * 2.0;
                float tPrev = t;
                int steps = (int)_SeaMaxSteps;

                for (int i = 0; i < steps; i++)
                {
                    hitPos = ro + rd * t;
                    float hDiff = MapWater(hitPos, 3);

                    if (hDiff > 0.0)
                    {
                        float tMin = tPrev;
                        float tMax = t;
                        float hMin = MapWater(ro + rd * tMin, 3);
                        float hMax = hDiff;

                        for (int j = 0; j < 8; j++)
                        {
                            float tMid = lerp(tMin, tMax, saturate(-hMin / (hMax - hMin + 1e-5)));
                            float3 midP = ro + rd * tMid;
                            float midH = MapWater(midP, 3);

                            if (midH > 0.0)
                            {
                                tMax = tMid;
                                hMax = midH;
                            }
                            else
                            {
                                tMin = tMid;
                                hMin = midH;
                            }
                        }

                        hitDist = tMax;
                        hitPos = ro + rd * hitDist;
                        return true;
                    }

                    tPrev = t;
                    float dt = max(0.2 + t * 0.003, -hDiff * 0.5);
                    t += dt;
                    if (t > maxDist) break;
                }
                return false;
            }

            float GetSceneMeshShadow(float3 worldPos)
            {
                float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
                return MainLightRealtimeShadow(shadowCoord);
            }

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

            float Schlick(float f0, float VoH)
            {
                return f0 + (1.0 - f0) * pow(1.0 - VoH, 5.0);
            }

            float Depth_GGX(float r, float NoH)
            {
                float a = NoH * r;
                float k = r / ((1.0 - NoH * NoH) + a * a + 1e-5);
                return k * k * (1.0 / PI);
            }

            float3 GetSkyReflection(float3 L, float3 sunDir, float3 mainLightColor)
            {
                float mu = dot(sunDir, L);
                float3 skyBase = lerp(float3(0.2, 0.52, 1.0), float3(0.8, 0.95, 1.0), pow(saturate(0.5 + 0.5 * mu), 15.0));
                float3 horizon = lerp(float3(1.0, 0.9, 0.8), float3(0.0, 0.0, 0.0), saturate(2.3 * max(0.0, L.y)));
                float3 sky = skyBase + horizon;
                sky += mainLightColor * pow(saturate(mu), 256.0) * 2.0;
                return sky;
            }

            float3 GetSeaColorAbove(float3 p, float3 N, float3 sunDir, float3 viewDir, float3 mainLightColor, float mu, float totalShadow, float3 refractedSceneColor)
            {
                float3 L = reflect(viewDir, N);
                float3 V = -viewDir;
                
                float NoV = clamp(abs(dot(N, V)) + 1e-5, 0.0, 1.0);
                float fresnel = Schlick(0.02, NoV);

                float3 reflection = GetSkyReflection(L, sunDir, mainLightColor);
                float3 color = lerp(refractedSceneColor, reflection, fresnel);

                float relY = p.y - _SeaLevel;
                float subsurfaceAmount = 8.0 * HenyeyGreenstein(mu, 0.5);
                color += subsurfaceAmount * _SeaWaterColor.rgb * max(0.0, 1.0 + relY - 0.6 * _SeaHeight) * totalShadow;

                float3 H = normalize(V + sunDir);
                float NoL = max(0.0, dot(N, sunDir));
                float NoH = max(0.0, dot(N, H));
                float roughness = 0.05;
                float spec = Depth_GGX(roughness, NoH);
                float3 lowScatter = float3(1.0, 0.7, 0.5);
                color += lowScatter * 0.4 * (NoL / PI * fresnel * mainLightColor * spec) * totalShadow;

                float foam = 4.0 * max(0.0, smoothstep(0.35, 0.6, relY - _SeaHeight) * N.x);
                color += foam * float3(0.9, 0.95, 1.0);

                return color;
            }

            float3 MarchClouds(float3 rayOrigin, float3 rayDir, float tEntry, float tExit, float dither, float3 cloudLightDir, float3 backgroundColor)
            {
                float rayLength = tExit - tEntry;
                if (rayLength <= 0.001) return backgroundColor;

                float accumulatedTransmittance = 1.0;
                float3 accumulatedLight = 0.0;
                int maxCloudSteps = (int)_CloudSteps;
                float stepSize = rayLength / (float)maxCloudSteps; 
                float currentT = tEntry + stepSize * dither;

                float cosTheta = dot(rayDir, cloudLightDir);
                float phase = HenyeyGreenstein(cosTheta, _SilverLiningSpread) * _SilverLiningIntensity;

                for (int i = 0; i < maxCloudSteps; i++)
                {
                    if (currentT >= tExit) break;

                    float3 currentPos = rayOrigin + rayDir * currentT;
                    float distFade = 1.0 - smoothstep(_CloudMaxDistance * 0.5, _CloudMaxDistance, currentT);
                    float density = GetCloudDensity(currentPos) * distFade;

                    if (density > 0.001)
                    {
                        float stepFade = density * _LightAbsorption;
                        float stepTransmittance = exp(-stepFade * stepSize);
                        float stepAlpha = 1.0 - stepTransmittance;
                        float lightTransmittance = LightMarch(currentPos, cloudLightDir);
                        
                        float meshShadowOnCloud = GetSceneMeshShadow(currentPos);
                        float3 meshShadowColor = lerp(_MeshShadowColor.rgb + _AmbientLightIntensity, float3(1,1,1), meshShadowOnCloud);
                        lightTransmittance *= meshShadowOnCloud;
                        
                        float3 cloudColorSample = lerp(_CloudShadowColor.rgb * meshShadowColor, _CloudColor.rgb * (1.0 + phase), lightTransmittance);
                        accumulatedLight += cloudColorSample * stepAlpha * accumulatedTransmittance;
                        accumulatedTransmittance *= stepTransmittance;

                        if (accumulatedTransmittance < 0.01) break;
                    }
                    currentT += stepSize;
                }

                float totalTransmittance = saturate(accumulatedTransmittance);
                return accumulatedLight + backgroundColor * totalTransmittance;
            }

            // Look at screen in  dir: drawn there (sky, objects).
            // Returns 0 if dir is off-screen (using a soft boundary of 1/8 of screen)
            float ScreenLookup(float3 dir, out float3 col, out float3 wp, out bool isSky)
            {
                col = float3(0, 0, 0); wp = float3(0, 0, 0); isSky = true;
            
                float4 clip = TransformWorldToHClip(_WorldSpaceCameraPos + dir * 100.0);
                if (clip.w <= 0.0)
                    return 0.0; // behind cam
            
                float2 u = clip.xy / clip.w * 0.5 + 0.5;
                #if UNITY_UV_STARTS_AT_TOP
                u.y = 1.0 - u.y;
                #endif
            
                float2 e = min(u, 1.0 - u);
                float fade = saturate(min(e.x, e.y) * 8.0);
                if (fade <= 0.0) return 0.0;
            
                u = saturate(u);
                float d = SampleSceneDepth(u);
                #if UNITY_REVERSED_Z
                isSky = (d <= 0.00001);
                #else
                isSky = (d >= 0.99999);
                #endif
                wp = ComputeWorldSpacePosition(u, d, UNITY_MATRIX_I_VP);
                col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, u).rgb;
                return fade;
            }
            
            // What is visible ABOVE water along dir (ray exited water at point hitPos)
            float3 SeeAboveWater(float3 hitPos, float3 dir, float3 sunDir, float3 sunColor, float3 cloudLightDir, float dither)
            {
                //background: analytical sky (works even off-screen)
                float3 col = GetSkyReflection(dir, sunDir, sunColor);
                float limitDist = 1e6;
            
                // real sky and objects above water from the screen (underwater objects are ignored)
                float3 sc, wp; bool isSky;
                float f = ScreenLookup(dir, sc, wp, isSky);
                if (f > 0.0 && (isSky || wp.y > _SeaLevel))
                {
                    col = lerp(col, sc, f);
                    if (!isSky) limitDist = distance(wp, hitPos); // object will block clouds behind it
                }
            
                // march clouds along REFRACTED ray 
                float tE, tX;
                if (RayHorizIntersect(hitPos, dir, _MinHeight, _MaxHeight, tE, tX))
                {
                    float lim = min(limitDist, _CloudMaxDistance);
                    if (tE < lim)
                        col = MarchClouds(hitPos, dir, tE, min(tX, lim), dither, cloudLightDir, col);
                }
                return col;
            }
            
            // Light shafts: waves act as a lens. Moving wave crests = bright shafts
            float ShaftPattern(float2 q)
            {
                float t = _Time.y * _SeaSpeed;
                float a = SeaOctave((q + t) * _SeaFreq * 2.5, 3.0);
                float b = SeaOctave((q.yx * 0.7 - t * 1.3) * _SeaFreq * 3.7, 3.0);
                return pow(smoothstep(0.1, 0.8, a + b), _GodRayContrast);
            }
            
            // Underwater sun rays: raymarch along camera ray, at each step
            // check if light fr surface reaches point
            float3 UnderwaterGodRays(float3 ro, float3 rd, float dist, float3 L, float3 lightColor, float dither)
            {
                float sunFade = smoothstep(0.25, 0.7, L.y); // works when sun is more overhead
                float maxD = min(dist, _GodRayDistance);
                if (sunFade <= 0.0 || maxD <= 0.01) return float3(0, 0, 0);
            
                const int STEPS = 14;
                float stepLen = maxD / STEPS;
                float acc = 0.0;
            
                for (int i = 0; i < STEPS; i++)
                {
                    float s = (i + dither) * stepLen;
                    float3 p = ro + rd * s;
                    float depth = _SeaLevel - p.y;
                    if (depth <= 0.0) continue; // no rays above water
            
                    // where sun ray enters water (assuming flat water)
                    float3 q = p + L * (depth / L.y);
            
                    float beam    = ShaftPattern(q.xz);                       // light shafts from waves
                    float shadow  = GetSceneMeshShadow(q);                    // objects above water block ray
                    float sunAtt  = exp(-depth * _SeaWaterFogDensity * 3.0);  // Beer's law: less light with depth
                    float viewAtt = exp(-s * _SeaWaterFogDensity);            // distant rays fade
                    acc += beam * shadow * sunAtt * viewAtt;
                }
            
                // Henyey-Greenstein phase func: brighter when looking towards sun
                float phase = 0.2 + HenyeyGreenstein(dot(rd, L), 0.7);
                float3 tint = lightColor * lerp(float3(1, 1, 1), _SeaWaterColor.rgb, 0.5);
            
                // scattering ~ absorp coefficient * length (therefore we multiply by stepLen and fog dens)
                return tint * acc * stepLen * _SeaWaterFogDensity * phase * _GodRayIntensity * sunFade;
            }


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
                float dither = InterleavedGradientNoise(input.positionCS.xy) * _Dithering;

                Light mainLight = GetMainLight();
                float3 rawLightDir = normalize(mainLight.direction);

                float3 cloudLightDir = rawLightDir;
                if (cloudLightDir.y < 0.05)
                {
                    float3 invertedLight = normalize(float3(rawLightDir.x, abs(rawLightDir.y) + 0.15, rawLightDir.z));
                    cloudLightDir = lerp(invertedLight, rawLightDir, smoothstep(-0.1, 0.05, rawLightDir.y));
                }

                float sunElevation = rawLightDir.y;
                float shadowSunFade = smoothstep(0.1, 0.4, sunElevation);

                bool camIsUnderwater = (MapWater(rayOrigin, 3) < 0.0);

                // ====================================================
                // Cam above Water
                // ====================================================
                if (!camIsUnderwater)
                {
                    float3 activeWorldPos = sceneWorldPos;
                    float surfaceDist = maxSceneDist;
                    float3 surfaceColor = sceneColor.rgb;
                    float finalDepth = rawDepth;

                    float waterHitDist;
                    float3 hitPos;
                    float searchDist = min(_SeaMaxDistance, maxSceneDist);

                    if (RaymarchWaterAbove(rayOrigin, rayDir, searchDist, dither, hitPos, waterHitDist))
                    {
                        if (waterHitDist < maxSceneDist)
                        {
                            surfaceDist = waterHitDist;
                            activeWorldPos = hitPos;

                            float submergedDepth = max(0.0, maxSceneDist - waterHitDist);
                            float depthFog = 1.0 - exp(-submergedDepth * _SeaTransparency);
                            float colorGrad = saturate(submergedDepth / max(0.001, _SeaColorDepth));
                            float3 oceanBodyColor = lerp(_SeaWaterColor.rgb, _SeaBaseColor.rgb, colorGrad);
                            float3 refractedScene = lerp(sceneColor.rgb, oceanBodyColor, depthFog);

                            float distSq = waterHitDist * waterHitDist;
                            float eps = max(0.001, distSq * (0.1 / _ScreenParams.x));
                            float3 N = GetWaterNormal(hitPos, eps);

                            float meshShadowOnWater = GetSceneMeshShadow(hitPos);
                            float cloudShadow = ComputeSoftSceneShadow(hitPos, cloudLightDir, dither);
                            cloudShadow = lerp(1.0, cloudShadow, shadowSunFade);

                            float totalShadow = cloudShadow * meshShadowOnWater;
                            float mu = dot(rawLightDir, rayDir);

                            surfaceColor = GetSeaColorAbove(hitPos, N, rawLightDir, rayDir, mainLight.color, mu, totalShadow, refractedScene);
                            surfaceColor = lerp(surfaceColor * _CloudShadowColor.rgb, surfaceColor, cloudShadow);

                            float distFade = smoothstep(_SeaMaxDistance * 0.7, _SeaMaxDistance, waterHitDist);
                            surfaceColor = lerp(surfaceColor, sceneColor.rgb, distFade);

                            float4 clipPos = TransformWorldToHClip(hitPos);
                            finalDepth = lerp(clipPos.z / clipPos.w, rawDepth, distFade);
                        }
                    }

                    if (surfaceDist == maxSceneDist)
                    {
                        float cloudShadow = ComputeSoftSceneShadow(activeWorldPos, cloudLightDir, dither);
                        cloudShadow = lerp(1.0, cloudShadow, shadowSunFade);
                        surfaceColor = lerp(surfaceColor * _CloudShadowColor.rgb, surfaceColor, cloudShadow);
                    }

                    float tEntry, tExit;
                    if (RayHorizIntersect(rayOrigin, rayDir, _MinHeight, _MaxHeight, tEntry, tExit))
                    {
                        if (tEntry < surfaceDist && tEntry < _CloudMaxDistance)
                        {
                            tEntry = min(tEntry, surfaceDist);
                            tExit = min(tExit, surfaceDist);
                            tExit = min(tExit, _CloudMaxDistance);

                            surfaceColor = MarchClouds(rayOrigin, rayDir, tEntry, tExit, dither, cloudLightDir, surfaceColor);
                        }
                    }

                    output.color = float4(surfaceColor, sceneColor.a);
                    output.depth = finalDepth;
                    return output;
                }
                // ====================================================
                // cam below water
                // ====================================================
                else
                {
                    float searchDist = min(_SeaMaxDistance, maxSceneDist);
                    float waterHitDist = 0.0;
                    float3 hitPos = rayOrigin;
                    float finalDepth = rawDepth;
                
                    float camDepth = max(0.0, _SeaLevel - rayOrigin.y);
                    float camColorGrad = saturate(camDepth / max(0.001, _SeaColorDepth));
                    float3 ambientWaterColor = lerp(_SeaWaterColor.rgb, _SeaBaseColor.rgb, camColorGrad);
                
                    float3 surfaceColor = sceneColor.rgb;
                    float rayEnd = maxSceneDist; // how far ray travel in water (god rays)
                
                    bool crossedSurface = false;
                    if (RaymarchWaterUnder(rayOrigin, rayDir, searchDist, dither, hitPos, waterHitDist))
                        crossedSurface = (waterHitDist < maxSceneDist);
                
                    if (crossedSurface)
                    {
                        rayEnd = waterHitDist;
                
                        // normal to wave, oriented perpendicular to  beam (viewed from below)
                        float eps = max(0.001, waterHitDist * waterHitDist * (0.1 / _ScreenParams.x));
                        float3 N0 = GetWaterNormal(hitPos, eps);
                        float3 Nd = faceforward(N0, rayDir, N0);
                
                        // SNELL'S LAW (water → air): n1*sin(a) = n2*sin(b)
                        float eta = _UnderRefractIndex;
                        float cosI = saturate(dot(-rayDir, Nd));
                        float k = 1.0 - eta * eta * (1.0 - cosI * cosI);
                        bool tir = (k <= 0.0); // total internal reflection: light doesnt escape from water
                        float3 refrDir = normalize(eta * rayDir + (eta * cosI - sqrt(max(k, 0.0))) * Nd);
                
                        // FRENEL (Schlick) by angle of transmission; at critical angle, gradually -> 1
                        float F = tir ? 1.0 : Schlick(0.02, sqrt(k));
                
                        // what seen through window:  sky, clouds, and objects distorted by waves
                        float3 skyThru = ambientWaterColor;
                        if (F < 0.99)
                            skyThru = SeeAboveWater(hitPos, refrDir, rawLightDir, mainLight.color, cloudLightDir, dither);
                
                        // mirrored section: bottom surface reflects underwater world (seafloor, objects)
                        float3 reflCol = ambientWaterColor;
                        if (F > 0.05)
                        {
                            float3 reflDir = reflect(rayDir, Nd);
                            float3 rc, rwp; bool rsky;
                            float rf = ScreenLookup(reflDir, rc, rwp, rsky);
                            if (rf > 0.0 && !rsky && rwp.y < _SeaLevel)
                            {
                                float pathFog = 1.0 - exp(-(waterHitDist + distance(rwp, hitPos)) * _SeaWaterFogDensity);
                                reflCol = lerp(ambientWaterColor, lerp(rc, ambientWaterColor, pathFog), rf);
                            }
                        }
                
                        float3 surfaceUnderView = lerp(skyThru, reflCol, F);
                
                        // foam in patches (noise), rather than wave contours
                        float relY = hitPos.y - _SeaLevel;
                        float foamThreshold = lerp(_SeaHeight * 0.95, -0.2 * _SeaHeight, _UnderFoamCoverage);
                        float foamMask = smoothstep(foamThreshold, _SeaHeight, relY);
                        float foamPatch = smoothstep(0.45, 0.75, Noise3D(float3(hitPos.xz * 0.7, _Time.y * 0.3)));
                        surfaceUnderView += float3(0.85, 0.95, 1.0) * _UnderFoamIntensity * foamMask * foamPatch;
                
                        // Bera's law: water mist along path from camera to surface
                        float fogFactor = 1.0 - exp(-waterHitDist * _SeaWaterFogDensity);
                        surfaceColor = lerp(surfaceUnderView, ambientWaterColor, fogFactor);
                
                        float4 clipPos = TransformWorldToHClip(hitPos);
                        finalDepth = clipPos.z / clipPos.w;
                    }
                    else
                    {
                        // didnt cross surface: either seabed or underwater objects, or distance
                        float fogFactor = 1.0 - exp(-maxSceneDist * _SeaWaterFogDensity);
                        surfaceColor = lerp(sceneColor.rgb, ambientWaterColor, fogFactor);
                    }
                
                    // sunbeams over everything (adding light that scattered by water)
                    surfaceColor += UnderwaterGodRays(rayOrigin, rayDir, rayEnd, rawLightDir, mainLight.color, dither);
                
                    output.color = float4(surfaceColor, sceneColor.a);
                    output.depth = finalDepth;
                    return output;
                }
                //else
                //{
                //    float3 skyAndClouds = sceneColor.rgb;
                //    float tEntry, tExit;
                //    if (RayHorizIntersect(rayOrigin, rayDir, _MinHeight, _MaxHeight, tEntry, tExit))
                //    {
                //        if (tEntry < maxSceneDist && tEntry < _CloudMaxDistance)
                //        {
                //            tExit = min(tExit, maxSceneDist);
                //            tExit = min(tExit, _CloudMaxDistance);

                //            skyAndClouds = MarchClouds(rayOrigin, rayDir, tEntry, tExit, dither, cloudLightDir, sceneColor.rgb);
                //        }
                //    }

                //    float searchDist = min(_SeaMaxDistance, maxSceneDist);
                //    float waterHitDist;
                //    float3 hitPos;
                //    float finalDepth = rawDepth;
                //    float3 surfaceColor = skyAndClouds;

                //    float camDepth = max(0.0, _SeaLevel - rayOrigin.y);
                //    float camColorGrad = saturate(camDepth / max(0.001, _SeaColorDepth));
                //    float3 ambientWaterColor = lerp(_SeaWaterColor.rgb, _SeaBaseColor.rgb, camColorGrad);

                //    if (RaymarchWaterUnder(rayOrigin, rayDir, searchDist, dither, hitPos, waterHitDist))
                //    {
                //        if (waterHitDist < maxSceneDist)
                //        {
                //            float cosTheta = saturate(dot(rayDir, float3(0, 1, 0)));

                //            // Snell Window Radius Control (_UnderSnellSize)
                //            float snellEdgeMin = saturate(0.55 / max(0.01, _UnderSnellSize));
                //            float snellEdgeMax = saturate(0.72 / max(0.01, _UnderSnellSize));

                //            float fresnelUnder = Schlick(0.02, cosTheta);
                //            float tir = 1.0 - smoothstep(snellEdgeMin, snellEdgeMax, cosTheta);
                //            fresnelUnder = max(fresnelUnder, tir);

                //            // Threshold and area of ​​foam coverage (_UnderFoamCoverage)
                //            float relY = hitPos.y - _SeaLevel;
                //            float foamThreshold = lerp(_SeaHeight * 0.95, -0.2 * _SeaHeight, _UnderFoamCoverage);
                //            float waveFoam = smoothstep(foamThreshold, _SeaHeight, relY);
                //            float3 foamColor = float3(0.85, 0.95, 1.0) * _UnderFoamIntensity;

                //            float3 skyThruWater = skyAndClouds + foamColor * waveFoam;

                //            float3 surfaceUnderView = lerp(skyThruWater, ambientWaterColor, fresnelUnder);

                //            float fogFactor = 1.0 - exp(-waterHitDist * _SeaWaterFogDensity);
                //            surfaceColor = lerp(surfaceUnderView, ambientWaterColor, fogFactor);

                //            float4 clipPos = TransformWorldToHClip(hitPos);
                //            finalDepth = clipPos.z / clipPos.w;
                //        }
                //        else
                //        {
                //            float fogFactor = 1.0 - exp(-maxSceneDist * _SeaWaterFogDensity);
                //            surfaceColor = lerp(skyAndClouds, ambientWaterColor, fogFactor);
                //        }
                //    }
                //    else
                //    {
                //        float fogFactor = 1.0 - exp(-maxSceneDist * _SeaWaterFogDensity);
                //        surfaceColor = lerp(skyAndClouds, ambientWaterColor, fogFactor);
                //    }

                //    output.color = float4(surfaceColor, sceneColor.a);
                //    output.depth = finalDepth;
                //    return output;
                //}
            }
            ENDHLSL
        }
    }
}