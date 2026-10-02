Shader "Custom/FullScreen_Space_BlackHole_Sun"
{
    Properties
    {
        [Header(________________________BLACK HOLE TRANSFORMS_________________)]
        _BlackHolePos ("Black Hole World Position", Vector) = (0.0, 0.0, 0.0, 0.0)
        _Size ("Black Hole Radius (Base Size)", Range(0.05, 100.0)) = 0.05
        _Speed ("Accretion Disk Rotation Speed", Range(0.0, 20.0)) = 5.0
        _DiskSteps ("Accretion Disk Thickness Layers", Range(1, 16)) = 5
        _MaxRaySteps ("Raymarching Steps Quality", Range(32, 256)) = 96
        _LensingStrength ("Scene Gravitational Distortion", Range(0.0, 2.0)) = 1.0

        [Header(________________________DISK COLORS___________________________)]
        _DiskInnerColor ("Disk Inner Color", Color) = (1.0, 0.8, 0.0, 1.0)
        _DiskOuterColor ("Disk Outer Color", Color) = (0.5, 0.13, 0.02, 1.0)
        _GlowColor ("Gravitational Glow Color", Color) = (1.2, 1.1, 1.0, 1.0)
        _GlowIntensity ("Glow Multiplier", Range(0.0, 5.0)) = 1.0

        [Header(________________________SUN CONTROL___________________________)]
        _SunSize ("Sun Angular Size", Range(0.01, 0.4)) = 0.08
        _SunBrightness ("Sun Brightness Multiplier", Range(0.1, 20.0)) = 4.0
        _SunCoreColor ("Sun Core Color", Color) = (1.0, 0.98, 0.85, 1.0)
        _SunSurfaceColor ("Sun Surface Plasma Color", Color) = (1.0, 0.35, 0.02, 1.0)
        _SunCoronaColor ("Sun Corona Color", Color) = (1.0, 0.15, 0.0, 1.0)
        _SunNoiseScale ("Sun Surface Plasma Detail Scale", Range(1.0, 30.0)) = 8.0
        _SunTurbulenceSpeed ("Sun Surface Turbulence Speed", Range(0.0, 2.0)) = 0.12
        _SunCoronaSize ("Corona Outer Thickness", Range(0.01, 0.8)) = 0.2
        _SunRayCnt ("Corona Rays Density", Range(2.0, 64.0)) = 16.0
        _SunRaySpeed ("Corona Rays Motion Speed", Range(0.0, 2.0)) = 0.15

        [Header(________________________3D FROZEN PLANET______________________)]
        _PlanetPos ("Planet World Position (X,Y,Z)", Vector) = (-15.0, 3.0, 25.0, 0.0)
        _PlanetRadius ("Planet World Radius", Range(0.5, 150.0)) = 4.5
        _PlanetSharpness ("Planet Sharpmess", Range(0.0, 1.0)) = 0.14
        _PlanetIceColor ("Ice Spires Color", Color) = (0.2, 0.8, 1.0, 1.0)
        _PlanetDarkColor ("Deep Glacier Color", Color) = (0.01, 0.05, 0.18, 1.0)
        _PlanetCragScale ("Ice Ridges Scale", Range(0.1, 10.0)) = 2.5
        _PlanetTwist ("Ice Spire Twist", Range(0.0, 10.0)) = 2.5

        [Header(________________________ASTEROIDS and METEORS___________________)]
        _MeteorSpeed ("Meteors / Ring Motion Speed", Range(0.0, 10.0)) = 2.0
        _MeteorColor ("Meteors Trail Color", Color) = (1.0, 0.55, 0.2, 1.0)
        _MeteorCount ("Meteors / Asteroids Density", Range(1.0, 20.0)) = 8.0

        [Header(________________________PROCEDURAL NEBULA_____________________)]
        _NebulaIntensity ("Nebula Brightness", Range(0.0, 5.0)) = 1.5
        _NebulaScale ("Nebula Scale", Range(0.1, 10.0)) = 1.5
        _NebulaColor1 ("Nebula Deep Color", Color) = (0.05, 0.02, 0.2, 1.0)
        _NebulaColor2 ("Nebula Core Color", Color) = (0.8, 0.15, 0.55, 1.0)
        _NebulaColor3 ("Nebula Gas Glow", Color) = (0.1, 0.65, 0.95, 1.0)

        [Header(________________________STARS CONTROL_________________________)]
        _StarScale ("Stars Scale (Grid Density)", Range(10.0, 1000.0)) = 300.0
        _StarThreshold ("Stars Sparseness", Range(0.5, 0.999)) = 0.96
        _StarBrightness ("Stars Brightness", Range(0.0, 20.0)) = 3.0
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
            Name "SpacePass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            // Param Declarations
            float4 _BlackHolePos;
            float _Size;
            float _Speed;
            float _DiskSteps;
            float _MaxRaySteps;
            float _LensingStrength;

            float4 _DiskInnerColor;
            float4 _DiskOuterColor;
            float4 _GlowColor;
            float _GlowIntensity;

            // Sun Params
            float _SunSize;
            float _SunBrightness;
            float4 _SunCoreColor;
            float4 _SunSurfaceColor;
            float4 _SunCoronaColor;
            float _SunNoiseScale;
            float _SunTurbulenceSpeed;
            float _SunCoronaSize;
            float _SunRayCnt;
            float _SunRaySpeed;

            // 3D Planet Params
            float4 _PlanetPos;
            float _PlanetRadius;
            float _PlanetSharpness;
            float4 _PlanetIceColor;
            float4 _PlanetDarkColor;
            float _PlanetCragScale;
            float _PlanetTwist;

            // Meteors & Asteroids Params
            float _MeteorSpeed;
            float4 _MeteorColor;
            float _MeteorCount;

            // Nebula & Stars
            float _NebulaIntensity;
            float _NebulaScale;
            float4 _NebulaColor1;
            float4 _NebulaColor2;
            float4 _NebulaColor3;

            float _StarScale;
            float _StarThreshold;
            float _StarBrightness;

            struct FragOutput
            {
                float4 color : SV_Target;
                float depth : SV_Depth;
            };

            // ==========================================
            // ЗГЛАДЖЕНИЙ 3D PERLIN GRADIENT NOISE
            // ==========================================

            float3 Hash33(float3 p)
            {
                p = float3(dot(p, float3(127.1, 311.7, 74.7)),
                           dot(p, float3(269.5, 183.3, 246.1)),
                           dot(p, float3(113.5, 271.9, 124.6)));
                return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
            }

            float SunGradientNoise(float3 p)
            {
                float3 i = floor(p);
                float3 f = frac(p);
                float3 u = f * f * (3.0 - 2.0 * f);

                return lerp(lerp(lerp(dot(Hash33(i + float3(0,0,0)), f - float3(0,0,0)),
                                      dot(Hash33(i + float3(1,0,0)), f - float3(1,0,0)), u.x),
                                 lerp(dot(Hash33(i + float3(0,1,0)), f - float3(0,1,0)),
                                      dot(Hash33(i + float3(1,1,0)), f - float3(1,1,0)), u.x), u.y),
                            lerp(lerp(dot(Hash33(i + float3(0,0,1)), f - float3(0,0,1)),
                                      dot(Hash33(i + float3(1,0,1)), f - float3(1,0,1)), u.x),
                                 lerp(dot(Hash33(i + float3(0,1,1)), f - float3(0,1,1)),
                                      dot(Hash33(i + float3(1,1,1)), f - float3(1,1,1)), u.x), u.y), u.z);
            }

            float SunFbm(float3 p)
            {
                float val = 0.0;
                float amp = 0.5;
                float3 shift = float3(100.0, 100.0, 100.0);
                for (int i = 0; i < 4; i++)
                {
                    val += amp * SunGradientNoise(p);
                    p = p * 2.05 + shift;
                    amp *= 0.5;
                }
                return val * 0.5 + 0.5;
            }

            // ==========================================
            // ПОЛЯРНЕ ПОВТОРЕННЯ ДЛЯ АСТЕРОЇДІВ (З SHADERTOY)
            // ==========================================

            float2 pModPolarHLSL(float2 p, float repetitions)
            {
                float angle = 6.28318530718 / repetitions;
                float a = atan2(p.y, p.x) + angle * 0.5;
                float r = length(p);
                float c = floor(a / angle);
                a = fmod(a, angle) - angle * 0.5;
                if (abs(c) >= (repetitions * 0.5)) c = abs(c);
                return float2(cos(a), sin(a)) * r;
            }

            // ==========================================
            // SDF РЕЙМАРЧИНГ РЕЛЬЄФУ ПЛАНЕТИ ТА АСТЕРОЇДІВ
            // ==========================================

            float MapPlanetSDF(float3 pos, out float spireVal)
            {
                float3 localPos = pos - _PlanetPos.xyz;
                float distToCenter = length(localPos);
                float baseSphere = distToCenter - _PlanetRadius;
                
                float3 normPos = localPos / max(1e-4, distToCenter);
                
                // Закручування шпилів
                float twistAngle = normPos.y * _PlanetTwist + SunGradientNoise(normPos * 2.0) * 1.5;
                float sT = sin(twistAngle), cT = cos(twistAngle);
                float3 twistedN = normPos;
                twistedN.xz = float2(normPos.x * cT - normPos.z * sT, normPos.x * sT + normPos.z * cT);
                
                // Гострі 3D-шпилі криги (Ridged Noise)
                float iceR1 = abs(SunGradientNoise(twistedN * _PlanetCragScale));
                float iceR2 = abs(SunGradientNoise(twistedN * _PlanetCragScale * 2.2 + float3(1.7, 3.2, 0.5)));
                float ridge = 1.0 - saturate(iceR1 * 0.65 + iceR2 * 0.35);
                ridge = pow(ridge, 3.5);
                
                float detail = SunFbm(normPos * _PlanetCragScale * 3.0);
                
                spireVal = ridge;
                // Справжній об'ємний випуклий рельєф (displaced height)
                float displacement = (ridge * 1.6 + detail * 0.4) * (_PlanetRadius * _PlanetSharpness);
                
                return baseSphere - displacement;
            }

            float3 CalcPlanetNormal(float3 p)
            {
                float e = 0.04;
                float dummy;
                float d = MapPlanetSDF(p, dummy);
                float3 n = float3(
                    MapPlanetSDF(p + float3(e, 0, 0), dummy) - MapPlanetSDF(p - float3(e, 0, 0), dummy),
                    MapPlanetSDF(p + float3(0, e, 0), dummy) - MapPlanetSDF(p - float3(0, e, 0), dummy),
                    MapPlanetSDF(p + float3(0, 0, e), dummy) - MapPlanetSDF(p - float3(0, 0, e), dummy)
                );
                return normalize(n);
            }

            // SDF Астероїдного кільця навколо планети
            float MapAsteroidsSDF(float3 pos)
            {
                float3 p = pos - _PlanetPos.xyz;
                
                // Обертання кільця
                float rot = _Time.y * _MeteorSpeed * 0.15;
                float cR = cos(rot), sR = sin(rot);
                p.xz = float2(p.x * cR - p.z * sR, p.x * sR + p.z * cR);
                
                // Нахил кільця
                float cT = cos(0.35), sT = sin(0.35);
                p.yz = float2(p.y * cT - p.z * sT, p.y * sT + p.z * cT);
                
                float count = max(6.0, _MeteorCount * 6.0);
                p.xz = pModPolarHLSL(p.xz, count);
                
                // Радіус орбіти кільця
                float ringDist = _PlanetRadius * 2.3;
                p.x -= ringDist;
                
                // Неідеальний кратерний шум для формоутворення каміння
                float rockNoise = SunGradientNoise(p * 0.9);
                float radius = 0.4 + 0.6 * saturate(rockNoise * 0.5 + 0.5);
                
                return length(p) - radius;
            }

            float3 CalcAsteroidsNormal(float3 p)
            {
                float e = 0.03;
                float d = MapAsteroidsSDF(p);
                float3 n = float3(
                    MapAsteroidsSDF(p + float3(e, 0, 0)) - MapAsteroidsSDF(p - float3(e, 0, 0)),
                    MapAsteroidsSDF(p + float3(0, e, 0)) - MapAsteroidsSDF(p - float3(0, e, 0)),
                    MapAsteroidsSDF(p + float3(0, 0, e)) - MapAsteroidsSDF(p - float3(0, 0, e))
                );
                return normalize(n);
            }

            // ==========================================
            // ФОНОВИЙ КОСМОС, СОНЦЕ ТА МЕТЕОРИ
            // ==========================================

            float Hash31(float3 p)
            {
                p = frac(p * float3(0.1031, 0.1030, 0.0973));
                p += dot(p, p.yzx + 33.33);
                return frac((p.x + p.y) * p.z);
            }

            float ValueNoise3D(float3 p)
            {
                float3 i = floor(p);
                float3 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);

                return lerp(
                    lerp(lerp(Hash31(i + float3(0,0,0)), Hash31(i + float3(1,0,0)), f.x),
                         lerp(Hash31(i + float3(0,1,0)), Hash31(i + float3(1,1,0)), f.x), f.y),
                    lerp(lerp(Hash31(i + float3(0,0,1)), Hash31(i + float3(1,0,1)), f.x),
                         lerp(Hash31(i + float3(0,1,1)), Hash31(i + float3(1,1,1)), f.x), f.y),
                    f.z
                );
            }

            float FbmNebula(float3 p)
            {
                float val = 0.0;
                float amp = 0.5;
                for (int i = 0; i < 4; i++)
                {
                    val += ValueNoise3D(p) * amp;
                    p *= 2.07;
                    amp *= 0.5;
                }
                return val;
            }

            float3 GenerateProceduralSpace(float3 rayDir)
            {
                // 1. Туманність
                float3 p = rayDir * _NebulaScale + float3(_Time.y * 0.01, _Time.y * 0.005, 0.0);
                float n1 = FbmNebula(p);
                float n2 = FbmNebula(p * 2.5 + float3(n1, n1, n1));

                float3 nebula = lerp(_NebulaColor1.rgb, _NebulaColor2.rgb, saturate(n1 * 1.5));
                nebula = lerp(nebula, _NebulaColor3.rgb, saturate(n2 * 1.3 - 0.2));
                nebula += float3(1.0, 0.8, 0.5) * pow(saturate(n1 * n2), 3.0) * 2.0;
                nebula *= _NebulaIntensity;

                // 2. Зорі
                float3 starCoord = rayDir * _StarScale;
                float starHash = Hash31(floor(starCoord));
                float starValue = saturate((starHash - _StarThreshold) / max(1e-4, 1.0 - _StarThreshold));
                starValue = pow(starValue, 3.0) * _StarBrightness;
                float3 starCol = lerp(float3(1.0, 0.8, 0.6), float3(0.6, 0.9, 1.0), frac(starHash * 13.0)) * starValue;

                float3 spaceBg = nebula + starCol;

                Light mainLight = GetMainLight();
                float3 sunDir = normalize(mainLight.direction);
                float cosTheta = dot(rayDir, sunDir);
                float sunR = _SunSize;

                // 3. Сонячне проміння та корона
                float angleDist = acos(saturate(cosTheta));
                if (angleDist < sunR + _SunCoronaSize)
                {
                    float distFromSurface = max(0.0, angleDist - sunR);
                    float coronaFade = saturate(1.0 - distFromSurface / _SunCoronaSize);
                    float smoothCorona = pow(coronaFade, 2.2);

                    float3 perp = normalize(cross(sunDir, float3(0, 1, 0) + 1e-4));
                    float3 bitan = cross(sunDir, perp);
                    float angle = atan2(dot(rayDir, bitan), dot(rayDir, perp));

                    float rayNoise = SunGradientNoise(float3(cos(angle * _SunRayCnt * 0.5), sin(angle * _SunRayCnt * 0.5), _Time.y * _SunRaySpeed));
                    rayNoise = pow(saturate(rayNoise * 0.5 + 0.5), 2.0);

                    float3 coronaCol = lerp(_SunCoronaColor.rgb, _SunCoreColor.rgb, smoothCorona);
                    float coronaGlow = (smoothCorona + smoothCorona * rayNoise * 0.8) * _SunBrightness;

                    spaceBg += coronaCol * coronaGlow;
                }

                // 4. Падаючі метеори у космосі (для різноманіття)
                int meteorCount = (int)_MeteorCount;
                for (int m = 0; m < meteorCount; m++)
                {
                    float mId = float(m) + 1.0;
                    float3 mBaseDir = normalize(float3(sin(mId * 17.1), cos(mId * 23.4), sin(mId * 41.2)));
                    float3 mFlyVec = normalize(float3(-0.7, -0.5, 0.3) + Hash33(float3(mId, mId * 2.0, mId * 3.0)) * 0.3);

                    float mSpeed = _MeteorSpeed * (0.6 + 0.8 * frac(mId * 0.413));
                    float progress = frac(_Time.y * mSpeed * 0.08 + mId * 0.17);

                    float3 headPos = normalize(mBaseDir + mFlyVec * (progress * 3.0 - 1.5));
                    float distToRay = acos(saturate(dot(rayDir, headPos)));

                    float mCore = saturate(1.0 - distToRay / 0.005);
                    float mTrail = saturate(1.0 - distToRay / 0.035);

                    float3 meteorCol = lerp(_MeteorColor.rgb, float3(1.0, 0.95, 0.8), pow(mCore, 2.0));
                    spaceBg += meteorCol * (pow(mCore, 2.0) * 6.0 + pow(mTrail, 3.0) * 1.8);
                }

                // 5. Непрозоре тіло сонця
                float b = dot(rayDir, sunDir);
                float c = 1.0 - sunR * sunR;
                float d = b * b - c;

                if (d >= 0.0 && b > 0.0)
                {
                    float t = b - sqrt(d);
                    float3 hitPos = rayDir * t;
                    float3 surfNormal = normalize(hitPos - sunDir);

                    float3 animPos = surfNormal * _SunNoiseScale + float3(0.0, _Time.y * _SunTurbulenceSpeed, _Time.y * _SunTurbulenceSpeed * 0.5);
                    float n1_sun = SunFbm(animPos);
                    float n2_sun = SunFbm(animPos * 2.2 + float3(1.7, 4.2, 0.5));
                    float plasma = saturate(n1_sun * 0.6 + n2_sun * 0.4);

                    float granulation = pow(plasma, 2.2);
                    float sunspots = smoothstep(0.38, 0.08, plasma);

                    float3 bodyCol = lerp(_SunSurfaceColor.rgb * 0.15, _SunSurfaceColor.rgb, plasma);
                    bodyCol = lerp(bodyCol, _SunCoreColor.rgb * 1.4, granulation);
                    bodyCol *= lerp(1.0, 0.12, sunspots);

                    float NdotV = saturate(dot(-rayDir, surfNormal));
                    float limbDarkening = pow(NdotV, 0.45);
                    bodyCol *= limbDarkening;

                    spaceBg = bodyCol * _SunBrightness;
                }

                return spaceBg;
            }

            // ==========================================
            // РЕЙМАРЧИНГ АКРЕЦІЙНОГО ДИСКА
            // ==========================================

            float2 ValueNoise2D(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);
                
                float h00 = frac(sin(dot(i + float2(0,0), float2(12.9898, 78.233))) * 43758.5453);
                float h10 = frac(sin(dot(i + float2(1,0), float2(12.9898, 78.233))) * 43758.5453);
                float h01 = frac(sin(dot(i + float2(0,1), float2(12.9898, 78.233))) * 43758.5453);
                float h11 = frac(sin(dot(i + float2(1,1), float2(12.9898, 78.233))) * 43758.5453);

                return lerp(lerp(h00, h10, f.x), lerp(h01, h11, f.x), f.y);
            }

            float4 RaymarchDisk(float3 ray, float3 zeroPos)
            {
                float lengthPos = length(zeroPos.xz);
                float dist = min(1.0, lengthPos * (1.0 / _Size) * 0.5) * _Size * 0.4 * (1.0 / _DiskSteps) / (abs(ray.y) + 1e-4);

                float3 position = zeroPos + dist * _DiskSteps * ray * 0.5;

                float2 deltaPos;
                deltaPos.x = -zeroPos.z * 0.01 + zeroPos.x;
                deltaPos.y = zeroPos.x * 0.01 + zeroPos.z;
                deltaPos = normalize(deltaPos - zeroPos.xz + 1e-4);

                float parallel = dot(ray.xz, deltaPos) / sqrt(max(1e-4, lengthPos)) * 0.5;
                float redShift = saturate(pow(parallel + 0.3, 2.0));

                float disMix = saturate((lengthPos - _Size * 2.0) * (1.0 / _Size) * 0.24);
                float3 insideCol = lerp(_DiskInnerColor.rgb, _DiskOuterColor.rgb * 0.2, disMix);
                insideCol *= lerp(float3(0.4, 0.2, 0.1), float3(1.6, 2.4, 4.0), redShift) * 1.25;

                redShift = pow(redShift + 0.12, 2.0);

                float4 o = float4(0, 0, 0, 0);

                for (float i = 0.0; i < _DiskSteps; i += 1.0)
                {
                    position -= dist * ray;

                    float intensity = saturate(1.0 - abs((i - 0.8) * (1.0 / _DiskSteps) * 2.0));
                    float lPos = length(position.xz);
                    float distMult = saturate((lPos - _Size * 0.75) * (1.0 / _Size) * 1.5) * saturate((_Size * 10.0 - lPos) * (1.0 / _Size) * 0.20);
                    distMult *= distMult;

                    float u = lPos + _Time.y * _Size * 0.3 + intensity * _Size * 0.2;

                    float rot = fmod(_Time.y * _Speed, 8192.0);
                    float2 xy;
                    xy.x = -position.z * sin(rot) + position.x * cos(rot);
                    xy.y = position.x * sin(rot) + position.z * cos(rot);

                    float x = abs(xy.x / (xy.y + 1e-4));
                    float angle = 0.02 * atan(x);

                    float f = 70.0;
                    float noise = ValueNoise2D(float2(angle, u * (1.0 / _Size) * 0.05) * f);
                    noise = noise * 0.66 + 0.33 * ValueNoise2D(float2(angle, u * (1.0 / _Size) * 0.05) * f * 2.0);

                    float extraWidth = noise * (1.0 - saturate(i * (1.0 / _DiskSteps) * 2.0 - 1.0));
                    float alpha = saturate(noise * (intensity + extraWidth) * ((1.0 / _Size) * 10.0 + 0.01) * dist * distMult);

                    float3 col = 2.0 * lerp(float3(0.3, 0.2, 0.15) * insideCol, insideCol, min(1.0, intensity * 2.0));
                    o = saturate(float4(col * alpha + o.rgb * (1.0 - alpha), o.a * (1.0 - alpha) + alpha));

                    lPos *= (1.0 / _Size);
                    o.rgb += redShift * (intensity + 0.5) * (1.0 / _DiskSteps) * 100.0 * distMult / (lPos * lPos + 1e-4);
                }

                o.rgb = saturate(o.rgb - 0.005);
                return o;
            }

            // ==========================================
            // MAIN FRAGMENT PASS
            // ==========================================

            FragOutput Frag(Varyings input)
            {
                FragOutput output;

                float2 uv = input.texcoord;
                float rawDepth = SampleSceneDepth(uv);
                float3 camWorldPos = _WorldSpaceCameraPos;
                
                #if UNITY_REVERSED_Z
                bool isSkybox = (rawDepth <= 0.00001);
                #else
                bool isSkybox = (rawDepth >= 0.99999);
                #endif

                float3 sceneWorldPos = ComputeWorldSpacePosition(uv, rawDepth, UNITY_MATRIX_I_VP);
                float rawSceneDist = isSkybox ? 1e6 : distance(sceneWorldPos, camWorldPos);

                float3 pos = camWorldPos - _BlackHolePos.xyz;
                float3 ray = normalize(sceneWorldPos - camWorldPos);
                float3 initialRay = ray;

                float4 diskAccCol = float4(0, 0, 0, 0);
                float4 glow = float4(0, 0, 0, 0);
                float4 finalColor = float4(0, 0, 0, 1);

                bool suckedIn = false;
                int maxSteps = (int)_MaxRaySteps;

                // Трасування променя крізь гравітаційне викривлення
                for (int i = 0; i < maxSteps; i++)
                {
                    float dotpos = dot(pos, pos);
                    float invDist = rsqrt(max(1e-5, dotpos));
                    float centDist = dotpos * invDist;

                    float stepDist = min(dotpos * 0.2, abs(pos.y / (ray.y + 1e-4)) * 0.9);
                    float farLimit = centDist * 0.5;
                    float closeLimit = min(centDist * 0.1, 0.01 * centDist * centDist * (1.0 / _Size));
                    stepDist = min(stepDist, min(farLimit, closeLimit));

                    float invDistSqr = invDist * invDist;
                    float bendForce = stepDist * invDistSqr * _Size * 0.625;

                    float3 pos_cross_pole = cross(float3(0, 1, 0), pos);
                    float sin2_colat = length(pos_cross_pole) * invDist;
                    sin2_colat *= sin2_colat;
                    float3 frameDragForce = normalize(pos_cross_pole + 1e-4) * invDistSqr * sin2_colat * 0.015;

                    ray = normalize(ray - (bendForce * invDist) * pos);
                    pos += stepDist * (ray - frameDragForce);

                    glow += _GlowColor * _GlowIntensity * (0.01 * stepDist * invDistSqr * invDistSqr * saturate(centDist * 2.0 - 1.2));

                    float dist2 = length(pos);

                    if (dist2 < _Size * 0.5)
                    {
                        suckedIn = true;
                        break;
                    }
                    else if (abs(pos.y) <= _Size * 0.0005)
                    {
                        float4 diskCol = RaymarchDisk(ray, pos);
                        pos += abs(_Size * 0.001 / (ray.y + 1e-4)) * ray;
                        diskAccCol = float4(diskCol.rgb * (1.0 - diskAccCol.a) + diskAccCol.rgb, diskAccCol.a + diskCol.a * (1.0 - diskAccCol.a));
                    }
                    else if (dist2 > _Size * 1000.0)
                    {
                        break;
                    }
                }

                // Композитинг
                output.depth = rawDepth; // Типове значення глибини

                if (suckedIn)
                {
                    finalColor.rgb = diskAccCol.rgb * diskAccCol.a + glow.rgb * (1.0 - diskAccCol.a);
                    
                    // Записуємо глибину горизонту подій для Чорної Дири
                    float4 bhClip = TransformWorldToHClip(pos + _BlackHolePos.xyz);
                    output.depth = bhClip.z / bhClip.w;
                }
                else
                {
                    float3 projectedWorld = camWorldPos + lerp(initialRay, ray, _LensingStrength) * 100.0;
                    float4 clipPos = TransformWorldToHClip(projectedWorld);
                    float2 distortedUV = (clipPos.xy / clipPos.w) * 0.5 + 0.5;

                    #if UNITY_UV_STARTS_AT_TOP
                    distortedUV.y = 1.0 - distortedUV.y;
                    #endif

                    distortedUV = saturate(distortedUV);

                    float distortedRawDepth = SampleSceneDepth(distortedUV);

                    #if UNITY_REVERSED_Z
                    bool distortedIsSkybox = (distortedRawDepth <= 0.00001);
                    #else
                    bool distortedIsSkybox = (distortedRawDepth >= 0.99999);
                    #endif

                    float3 distortedSceneWorldPos = ComputeWorldSpacePosition(distortedUV, distortedRawDepth, UNITY_MATRIX_I_VP);
                    float distortedSceneDist = distortedIsSkybox ? 1e6 : distance(distortedSceneWorldPos, camWorldPos);

                    float3 backgroundRGB = float3(0,0,0);

                    if (!distortedIsSkybox)
                    {
                        backgroundRGB = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, distortedUV).rgb;
                    }
                    else
                    {
                        backgroundRGB = GenerateProceduralSpace(ray);
                    }

                    // --------------------------------------------------------
                    // 3D SDF РЕЙМАРЧИНГ ПЛАНЕТИ ТА АСТЕРОЇДІВ У СВІТОВОМУ ПРОСТОРІ
                    // --------------------------------------------------------
                    float marchT = 0.0;
                    float3 rayStartPos = camWorldPos;
                    bool planetHit = false;
                    
                    // Ближній радіус відсікання реймарчингу навколо планети
                    float distToPlanetCenter = distance(camWorldPos, _PlanetPos.xyz);
                    float maxRayDist = min(distortedSceneDist, distToPlanetCenter + _PlanetRadius * 3.0);//min(rawSceneDist, distToPlanetCenter + _PlanetRadius * 3.0);
                    
                    for (int step = 0; step < 80; step++)
                    {
                        float3 currWorldPos = rayStartPos + ray * marchT;
                        if (marchT > maxRayDist) break;
                        
                        float spireVal = 0.0;
                        float dPlanet = MapPlanetSDF(currWorldPos, spireVal);
                        float dAsteroids = MapAsteroidsSDF(currWorldPos);
                        
                        float dMin = min(dPlanet, dAsteroids);
                        
                        if (dMin < 0.015 * (1.0 + marchT * 0.01))
                        {
                            // Перевіряємо, чи ми не за геометрією сцени
                            if (marchT <distortedSceneDist)// rawSceneDist)
                            {
                                planetHit = true;
                                Light mainLight = GetMainLight();
                                float3 sunDir = normalize(mainLight.direction);
                                
                                float3 hitNormal;
                                float3 objCol = float3(0,0,0);
                                
                                if (dPlanet < dAsteroids)
                                {
                                    // Влучання у крижану планету зі шпилями
                                    hitNormal = CalcPlanetNormal(currWorldPos);
                                    float NdotL = saturate(dot(hitNormal, sunDir));
                                    float NdotV = saturate(dot(-ray, hitNormal));
                                    float fresnel = pow(1.0 - NdotV, 3.0);

                                    float3 surfCol = lerp(_PlanetDarkColor.rgb, _PlanetIceColor.rgb, spireVal * 0.75 + 0.25);
                                    surfCol += float3(0.85, 0.95, 1.0) * pow(spireVal, 2.0) * 2.0;

                                    float3 reflectDir = reflect(ray, hitNormal);
                                    float spec = pow(saturate(dot(reflectDir, sunDir)), 28.0);

                                    objCol = surfCol * (NdotL * 0.85 + 0.15) + float3(0.9, 0.98, 1.0) * spec * (spireVal + 0.2) * 2.5;
                                    objCol += _PlanetIceColor.rgb * fresnel * 1.5;
                                }
                                else
                                {
                                    // Влучання в 3D Астероїд
                                    hitNormal = CalcAsteroidsNormal(currWorldPos);
                                    float NdotL = saturate(dot(hitNormal, sunDir));
                                    float3 rockNoise = SunGradientNoise(currWorldPos * 2.0);
                                    float3 rockBaseCol = float3(0.35, 0.38, 0.4) + rockNoise * 0.12;
                                    objCol = rockBaseCol * (NdotL * 0.8 + 0.2);
                                }
                                
                                backgroundRGB = objCol;
                                
                                // Обчислюємо точну глибину поверхні для запису в SV_Depth
                                float4 hitClipPos = TransformWorldToHClip(currWorldPos);
                                output.depth = hitClipPos.z / hitClipPos.w;
                            }
                            break;
                        }
                        
                        marchT += max(0.02, dMin * 0.55);
                    }

                    finalColor.rgb = diskAccCol.rgb * diskAccCol.a + backgroundRGB * (1.0 - diskAccCol.a) + glow.rgb * (1.0 - diskAccCol.a);
                }

                // Гамма-корекція
                finalColor.rgb = pow(max(0.0, finalColor.rgb), 0.6);

                output.color = saturate(finalColor);

                // Дозволяємо чистий HDR вивід без обрізання та без ручної гамма-корекції
                // (Unity Post Processing / Tonemapping зробить це правильно)
                //output.color = float4(max(0.0, finalColor.rgb), 1.0);
                return output;
            }
            ENDHLSL
        }
    }
}