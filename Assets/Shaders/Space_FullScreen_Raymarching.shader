Shader "Custom/FullScreen_Space_BlackHole_Sun"
{
    Properties
    {
        [HideInInspector] _Header_Hole ("---{BLACK HOLE}---", Float) = 0
        [HideInInspector] _Header_Hole ("Hole Transform", Float) = 0
        [Header(________________________BLACK HOLE TRANSFORMS_________________)]
        _BlackHolePos ("Black Hole World Position", Vector) = (0.0, -250.0, 0.0, 0.0)
        _Size ("Black Hole Radius (Base Size)", Range(0.01,100.0)) = 18.0
        _Speed ("Accretion Disk Rotation Speed", Range(0.0, 20.0)) = 3.3
        _DiskSteps ("Accretion Disk Thickness Layers", Range(1, 13)) = 9
        
        //_PhotonSphereR ("Photon Sphere Radius", Float) = 9

        [HideInInspector] _Header_Hole ("Hole Graphics", Float) = 0
        [Header(________________________BLACK HOLE GRAPHICS_________________)]
        _MaxRaySteps ("Raymarching Steps Quality", Range(32, 256)) = 256
        _LensingStrength ("Scene Gravitational Distortion", Range(0.0, 2.0)) = 2.0
        _BlackHolePhysics ("Hole Physics (0 = hole over everything, 1 = real depth)", Range(0.0, 1.0)) = 0.0
        //[Toggle(_ENABLE_EFFECT_ON)] _PhysicalBH ("Physical Black Hole", Float) = 0
        
        [HideInInspector] _Header_Disk ("Hole Disk", Float) = 0
        [Header(________________________DISK COLORS___________________________)]
        _DiskInnerColor ("Disk Inner Color", Color) = (1.0, 0.4549928, 0.0, 1.0)
        _DiskOuterColor ("Disk Outer Color", Color) = (1.0, 0.0, 0.1142082, 1.0)
        _GlowColor ("Gravitational Glow Color", Color) = (1.0, 0.950565, 0.75, 1.0)
        _GlowIntensity ("Glow Multiplier", Range(0.0, 15.0)) = 15.0
        _GlowWidth ("Glow Falloff Width (in hole radii)", Range(0.02, 1.0)) = 0.17

        [HideInInspector] _Header_Hole ("---{SUN}---", Float) = 0
        [HideInInspector] _Header_Sun ("Sun Control", Float) = 0
        [Header(________________________SUN CONTROL___________________________)]
        _SunSize ("Sun Angular Size", Range(0.01, 0.4)) = 0.2
        _SunBrightness ("Sun Brightness Multiplier", Range(0.1, 20.0)) = 6.4
        _SunNoiseScale ("Sun Surface Plasma Detail Scale", Range(1.0, 30.0)) = 18.5
        _SunTurbulenceSpeed ("Sun Surface Turbulence Speed", Range(0.0, 2.0)) = 0.74
        [HideInInspector] _Header_Sun ("Sun Colors", Float) = 0
        _SunCoreColor ("Sun Core Color", Color) = (1.0, 0.572549, 0.9909969, 1.0)
        _SunSurfaceColor ("Sun Surface Plasma Color", Color) = (1.0, 0.03997353, 0.0, 1.0)
        _SunCoronaColor ("Sun Corona Color", Color) = (0.0, 0.17627, 1.0, 1.0)
        [HideInInspector] _Header_Disk ("Sun Corona", Float) = 0
        _SunCoronaSize ("Corona Outer Thickness", Range(0.01, 0.8)) = 0.8
        _SunRayCnt ("Corona Rays Density", Range(2.0, 64.0)) = 64.0
        _SunRaySpeed ("Corona Rays Motion Speed", Range(0.0, 2.0)) = 2.0

        [HideInInspector] _Header_Planet ("---{FROZEN PLANET}---", Float) = 0
        [HideInInspector] _Header_Sun ("Planet Transform", Float) = 0
        [Header(__________________________FROZEN PLANET_______________________)]
        _PlanetPos ("Planet World Position (X,Y,Z)", Vector) = (-156.27, 3, 469.7, 0.0)
        _PlanetRadius ("Planet World Radius", Range(0.5, 150.0)) = 65.0
        [HideInInspector] _Header_Sun ("Planet Surface", Float) = 0
        _PlanetSharpness ("Planet Sharpmess", Range(0.0, 1.0)) = 0.157
        _PlanetIceColor ("Ice Spires Color", Color) = (0.2, 0.8, 1.0, 1.0)
        _PlanetDarkColor ("Deep Glacier Color", Color) = (0.0, 0.2325582, 1.0, 1.0)
        _PlanetCragScale ("Ice Ridges Scale", Range(0.1, 10.0)) = 4.68
        _PlanetTwist ("Ice Spire Twist", Range(0.0, 10.0)) = 2.13
        [HideInInspector] _Header_Asteroids ("Asteroids Ring", Float) = 0
        [Header(________________________ASTEROIDS and METEORS___________________)]
        _RingOrbitRadius ("Ring Orbit Radius Multiplier", Range(0.5, 6.0)) = 3.0
        _RingInnerRadius ("Ring Inner Radius Multiplier", Range(1.0, 6.0)) = 1.88
        _RingWidth ("Ring Horizontal Width", Range(0.1, 5.0)) = 1.67
        _RingHeight ("Ring Vertical Height", Range(0.01, 1.0)) = 0.212
        _AsteroidDensity ("Asteroids Density", Range(0.05, 1.0)) = 0.262
        _AsteroidJitter ("Random Position Jitter", Range(0.0, 1.0)) = 1.0
        _AsteroidFill ("Asteroids Fill (Chance Per Cell)", Range(0.02, 1.0)) = 0.102
        _AsteroidSize ("Base Asteroid Size", Range(0.05, 1.0)) = 1.0
        _AsteroidSizeVar ("Asteroid Size Variation", Range(0.0, 1.0)) = 1.0
        //_MeteorSpeed ("Meteors / Ring Motion Speed", Range(0.0, 10.0)) = 2.0
        //_MeteorColor ("Meteors Trail Color", Color) = (1.0, 0.55, 0.2, 1.0)
        //_MeteorCount ("Meteors / Asteroids Density", Range(1.0, 20.0)) = 8.0
        
        [HideInInspector] _Header_Nebula ("---{NEBULA}---", Float) = 0
        [Header(________________________PROCEDURAL NEBULA_____________________)]
        _NebulaIntensity ("Nebula Brightness", Range(0.0, 5.0)) = 0.88
        _NebulaScale ("Nebula Scale", Range(0.1, 10.0)) = 2.88
        _NebulaColor1 ("Nebula Deep Color", Color) = (0.0, 0.07075465, 0.4245283, 1.0)
        _NebulaColor2 ("Nebula Core Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _NebulaColor3 ("Nebula Gas Glow", Color) = (0.5188679, 0.03671235, 0.144242, 1.0)
        
        [HideInInspector] _Header_Stars ("---{STARS}---", Float) = 0
        [Header(________________________STARS CONTROL_________________________)]
        _StarScale ("Stars Scale (Grid Density)", Range(10.0, 1000.0)) = 478
        _StarThreshold ("Stars Sparseness", Range(0.5, 0.999)) = 0.994
        _StarBrightness ("Stars Brightness", Range(0.0, 20.0)) = 10.2
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
            float _BlackHolePhysics;

            float4 _DiskInnerColor;
            float4 _DiskOuterColor;
            float4 _GlowColor;
            float _GlowIntensity;
            float _GlowWidth;
            //float _PhotonSphereR;//  ~ radius of the photon sphere (approximately)

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

            //// Meteors & Asteroids Params
            //float _MeteorSpeed;
            //float4 _MeteorColor;
            //float _MeteorCount;

            // Asteroids Ring Params
            float _RingOrbitRadius;
            float _RingWidth;
            float _RingHeight;
            float _RingInnerRadius;
            float _AsteroidDensity;
            float _AsteroidJitter;
            float _AsteroidFill;
            float _AsteroidSize;
            float _AsteroidSizeVar;

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
            // smootjed 3D PERLIN GRADIENT NOISE
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

            // polar asteroids

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
            // SDF march planet surf & asteroids
            // ==========================================

            float MapPlanetSDF(float3 pos, out float spireVal)
            {
                float3 localPos = pos - _PlanetPos.xyz;
                float distToCenter = length(localPos);
                float baseSphere = distToCenter - _PlanetRadius;
                
                float3 normPos = localPos / max(1e-4, distToCenter);
                
                // Twisting of spires
                float twistAngle = normPos.y * _PlanetTwist + SunGradientNoise(normPos * 2.0) * 1.5;
                float sT = sin(twistAngle), cT = cos(twistAngle);
                float3 twistedN = normPos;
                twistedN.xz = float2(normPos.x * cT - normPos.z * sT, normPos.x * sT + normPos.z * cT);
                
                // Sharp 3D spiers of ice (Ridged Noise)
                float iceR1 = abs(SunGradientNoise(twistedN * _PlanetCragScale));
                float iceR2 = abs(SunGradientNoise(twistedN * _PlanetCragScale * 2.2 + float3(1.7, 3.2, 0.5)));
                float ridge = 1.0 - saturate(iceR1 * 0.65 + iceR2 * 0.35);
                ridge = pow(ridge, 3.5);
                
                float detail = SunFbm(normPos * _PlanetCragScale * 3.0);
                
                spireVal = ridge;
                // Real three-dimensional convex relief (displaced height)
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

            //SDF Asteroid ring around the planet
            //float MapAsteroidsSDF(float3 pos)
            //{
            //    float3 p = pos - _PlanetPos.xyz;
                
            //    // rot ring
            //    float rot = _Time.y * _MeteorSpeed * 0.15;
            //    float cR = cos(rot), sR = sin(rot);
            //    p.xz = float2(p.x * cR - p.z * sR, p.x * sR + p.z * cR);
                
            //    // ring tilt
            //    float cT = cos(0.35), sT = sin(0.35);
            //    p.yz = float2(p.y * cT - p.z * sT, p.y * sT + p.z * cT);
                
            //    float count = max(6.0, _MeteorCount * 6.0);
            //    p.xz = pModPolarHLSL(p.xz, count);
                
            //    //ring radius
            //    float ringDist = _PlanetRadius * 2.3;
            //    p.x -= ringDist;
                
            //    // Imperfect crater noise for rock formation
            //    float rockNoise = SunGradientNoise(p * 0.9);
            //    float radius = 0.4 + 0.6 * saturate(rockNoise * 0.5 + 0.5);
                
            //    return length(p) - radius;
            //}
            //Ring - a flat torus with a rectangular cross-section. Minus = inside. p in the planet's local coords
            float RingSDF(float3 p)
             {
                 float r       = length(p.xz);
                 float centerR = _PlanetRadius * _RingOrbitRadius;
                 float halfW   = _PlanetRadius * _RingWidth * 0.5;
                 float innerR  = max(centerR - halfW, _PlanetRadius * _RingInnerRadius);
                 float outerR  = max(centerR + halfW, innerR + 0.01);
                 float midR    = 0.5 * (innerR + outerR);
                 float halfR   = 0.5 * (outerR - innerR);
                 float halfH   = _PlanetRadius * _RingHeight;
             
                 // abs() fpor inner hole
                 float2 q = float2(abs(r - midR) - halfR, abs(p.y) - halfH);
                 return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0); // SDF 2d rect
             }
             
             float RockInCell(float3 cellID, float3 p, float cellSize)
             {
                 //the chance that there is a stone in the cell at all (otherwise a solid grid = "disc")
                 float present = Hash33(cellID + 3.7).y * 0.5 + 0.5;
                 if (present > _AsteroidFill)
                 return 1e5; //  empty cell
                
                 // rand range in cell range  (1.0)
                 float rnd    = Hash33(cellID + 7.3).x * 0.5 + 0.5;
                 float radius = min(_AsteroidSize * (1.0 - _AsteroidSizeVar * rnd), 0.45); // r < half cell
             
                 //asteroid center movement onl in free cell space
                 float3 jitter  = Hash33(cellID) * (0.5 - radius) * _AsteroidJitter;
                 float3 centerP = (cellID + 0.5 + jitter) * cellSize;
             
                 //asteroid exist only if it center in ring, near edge - asteroids become smaller
                 float inside = -RingSDF(centerP);
                 float fade   = smoothstep(0.0, cellSize * 1.5, inside);
                 float r      = radius * cellSize * fade;
                 if (r < 0.02) 
                    return 1e5;                  // empty cell
             
                 return length(p - centerP) - r; // sphere SDF 
             }
             
             float MapAsteroidsSDF(float3 pos)
             {
                 float3 p = pos - _PlanetPos.xyz;
                 float cellSize = 1.0 / max(_AsteroidDensity, 0.001);
             
                 // far from ring - nothing to check, make safe big step
                 float ringD = RingSDF(p) - cellSize;
                 if (ringD > 0.0) 
                    return ringD;
             
                 //8 cells around closest corner of grid ((stones in their own cells)
                 float3 baseCell = floor(p / cellSize - 0.5);
                 float d = 0.5 * cellSize; //others guaranted not nearest for it
             
                 [unroll] for (int z = 0; z < 2; z++)
                 [unroll] for (int y = 0; y < 2; y++)
                 [unroll] for (int x = 0; x < 2; x++)
                     d = min(d, RockInCell(baseCell + float3(x, y, z), p, cellSize));
             
                 return d;
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
            // BACKGROUND SPACE, SUN AND METEORS
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
                // nebula
                float3 p = rayDir * _NebulaScale + float3(_Time.y * 0.01, _Time.y * 0.005, 0.0);
                float n1 = FbmNebula(p);
                float n2 = FbmNebula(p * 2.5 + float3(n1, n1, n1));

                float3 nebula = lerp(_NebulaColor1.rgb, _NebulaColor2.rgb, saturate(n1 * 1.5));
                nebula = lerp(nebula, _NebulaColor3.rgb, saturate(n2 * 1.3 - 0.2));
                nebula += float3(1.0, 0.8, 0.5) * pow(saturate(n1 * n2), 3.0) * 2.0;
                nebula *= _NebulaIntensity;

                // stars
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

                // sun rays & corona
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

                ////falling meteors
                //int meteorCount = (int)_MeteorCount;
                //for (int m = 0; m < meteorCount; m++)
                //{
                //    float mId = float(m) + 1.0;
                //    float3 mBaseDir = normalize(float3(sin(mId * 17.1), cos(mId * 23.4), sin(mId * 41.2)));
                //    float3 mFlyVec = normalize(float3(-0.7, -0.5, 0.3) + Hash33(float3(mId, mId * 2.0, mId * 3.0)) * 0.3);

                //    float mSpeed = _MeteorSpeed * (0.6 + 0.8 * frac(mId * 0.413));
                //    float progress = frac(_Time.y * mSpeed * 0.08 + mId * 0.17);

                //    float3 headPos = normalize(mBaseDir + mFlyVec * (progress * 3.0 - 1.5));
                //    float distToRay = acos(saturate(dot(rayDir, headPos)));

                //    float mCore = saturate(1.0 - distToRay / 0.005);
                //    float mTrail = saturate(1.0 - distToRay / 0.035);

                //    float3 meteorCol = lerp(_MeteorColor.rgb, float3(1.0, 0.95, 0.8), pow(mCore, 2.0));
                //    spaceBg += meteorCol * (pow(mCore, 2.0) * 6.0 + pow(mTrail, 3.0) * 1.8);
                //}

                // Opaque body of the sun
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
            // REMARCHING OF THE ACCRETION DISC
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


            bool RaySphere(float3 ro, float3 rd, float3 c, float r, out float t0, out float t1)
            {
                float3 oc = ro - c;
                float b = dot(oc, rd);
                float h = b * b - (dot(oc, oc) - r * r);
                t0 = 0.0; t1 = 0.0;
                if (h < 0.0) return false;
                h = sqrt(h);
                t0 = -b - h;
                t1 = -b + h;
                return t1 > 0.0;
            }
            
            bool MarchPlanet(float3 ro, float3 rd, float tMax, out float hitT, out float spireVal)
            {
                hitT = tMax; spireVal = 0.0;
                float t0, t1;
                // max. the protrusion of the spiers = 2 * R * sharpness, so this planet edge
                float bound = _PlanetRadius * (1.0 + 2.0 * _PlanetSharpness) + 0.5;
                if (!RaySphere(ro, rd, _PlanetPos.xyz, bound, t0, t1)) return false;
            
                float t = max(t0, 0.0);
                float tEnd = min(t1, tMax);
                for (int i = 0; i < 80; i++)
                {
                    if (t > tEnd) return false;
                    float sv;
                    float d = MapPlanetSDF(ro + rd * t, sv);
                    if (d < 0.015 * (1.0 + t * 0.01)) { hitT = t; spireVal = sv; return true; }
                    t += max(0.02, d * 0.55); // 0.55 bcs SDF with noise not accurate
                }
                return false;
            }
            
            bool MarchAsteroids(float3 ro, float3 rd, float tMax, out float hitT)
            {
                hitT = tMax;
                float cellSize = 1.0 / max(_AsteroidDensity, 0.001);
                float outer = max(_PlanetRadius * (_RingOrbitRadius + _RingWidth * 0.5), _PlanetRadius * _RingInnerRadius);
                float bound = length(float2(outer, _PlanetRadius * _RingHeight)) + cellSize * 2.0;
            
                float t0, t1;
                if (!RaySphere(ro, rd, _PlanetPos.xyz, bound, t0, t1)) return false;
            
                float t = max(t0, 0.0);
                float tEnd = min(t1, tMax);
                for (int i = 0; i < 128; i++)
                {
                    if (t > tEnd) return false;
                    float d = MapAsteroidsSDF(ro + rd * t);
                    if (d < 0.00001 + t * 0.00000003) { hitT = t; return true; }
                    t += max(0.01, d * 0.9); // sphere SDF accure,allowed big step
                }
                return false;
            }
            
            //get neares obj (planet \ asteroids) to calc their exact color
            bool TraceSpaceObjects(float3 ro, float3 rd, float tMax, out float3 col, out float hitT, out float3 hitPos)
            {
                col = float3(0, 0, 0); hitT = tMax; hitPos = ro;
            
                float tP, spireVal, tA;
                bool hitP = MarchPlanet(ro, rd, tMax, tP, spireVal);
                bool hitA = MarchAsteroids(ro, rd, hitP ? tP : tMax, tA); //ring drawn only if closer than planet
                if (!hitP && !hitA) return false;
            
                float3 sunDir = normalize(GetMainLight().direction);
            
                if (hitA)
                {
                    hitT = tA;
                    hitPos = ro + rd * tA;
                    float3 n = CalcAsteroidsNormal(hitPos);
                    float NdotL = saturate(dot(n, sunDir)); // Lambert's law
                    float3 rockBase = float3(0.35, 0.38, 0.4) + SunGradientNoise(hitPos * 2.0) * 0.12;
                    col = rockBase * (NdotL * 0.8 + 0.2);
                }
                else
                {
                    hitT = tP;
                    hitPos = ro + rd * tP;
                    float3 n = CalcPlanetNormal(hitPos);
                    float NdotL = saturate(dot(n, sunDir));
                    float NdotV = saturate(dot(-rd, n));
                    float fresnel = pow(1.0 - NdotV, 3.0);
            
                    float3 surfCol = lerp(_PlanetDarkColor.rgb, _PlanetIceColor.rgb, spireVal * 0.75 + 0.25);
                    surfCol += float3(0.85, 0.95, 1.0) * pow(spireVal, 2.0) * 2.0;
            
                    float spec = pow(saturate(dot(reflect(rd, n), sunDir)), 28.0); // αλ³κ
                    col = surfCol * (NdotL * 0.85 + 0.15) + float3(0.9, 0.98, 1.0) * spec * (spireVal + 0.2) * 2.5;
                    col += _PlanetIceColor.rgb * fresnel * 1.5;
                }
                return true;
            }

            // ==========================================
            // MAIN FRAGMENT PASS
            // ==========================================

            //FragOutput Frag(Varyings input)
            //{
            //    FragOutput output;

            //    float2 uv = input.texcoord;
            //    float rawDepth = SampleSceneDepth(uv);
            //    float3 camWorldPos = _WorldSpaceCameraPos;
                
            //    #if UNITY_REVERSED_Z
            //    bool isSkybox = (rawDepth <= 0.00001);
            //    #else
            //    bool isSkybox = (rawDepth >= 0.99999);
            //    #endif

            //    float3 sceneWorldPos = ComputeWorldSpacePosition(uv, rawDepth, UNITY_MATRIX_I_VP);
            //    float rawSceneDist = isSkybox ? 1e6 : distance(sceneWorldPos, camWorldPos);

            //    float3 pos = camWorldPos - _BlackHolePos.xyz;
            //    float3 ray = normalize(sceneWorldPos - camWorldPos);
            //    float3 initialRay = ray;

            //    float4 diskAccCol = float4(0, 0, 0, 0);
            //    float4 glow = float4(0, 0, 0, 0);
            //    float4 finalColor = float4(0, 0, 0, 1);

            //    bool suckedIn = false;
            //    int maxSteps = (int)_MaxRaySteps;

            //    // Ray tracing through gravitational warping
            //    for (int i = 0; i < maxSteps; i++)
            //    {
            //        float dotpos = dot(pos, pos);
            //        float invDist = rsqrt(max(1e-5, dotpos));
            //        float centDist = dotpos * invDist;

            //        float stepDist = min(dotpos * 0.2, abs(pos.y / (ray.y + 1e-4)) * 0.9);
            //        float farLimit = centDist * 0.5;
            //        float closeLimit = min(centDist * 0.1, 0.01 * centDist * centDist * (1.0 / _Size));
            //        stepDist = min(stepDist, min(farLimit, closeLimit));

            //        float invDistSqr = invDist * invDist;
            //        float bendForce = stepDist * invDistSqr * _Size * 0.625;

            //        float3 pos_cross_pole = cross(float3(0, 1, 0), pos);
            //        float sin2_colat = length(pos_cross_pole) * invDist;
            //        sin2_colat *= sin2_colat;
            //        float3 frameDragForce = normalize(pos_cross_pole + 1e-4) * invDistSqr * sin2_colat * 0.015;

            //        ray = normalize(ray - (bendForce * invDist) * pos);
            //        pos += stepDist * (ray - frameDragForce);

            //        glow += _GlowColor * _GlowIntensity * (0.01 * stepDist * invDistSqr * invDistSqr * saturate(centDist * 2.0 - 1.2));

            //        float dist2 = length(pos);

            //        if (dist2 < _Size * 0.5)
            //        {
            //            suckedIn = true;
            //            break;
            //        }
            //        else if (abs(pos.y) <= _Size * 0.0005)
            //        {
            //            float4 diskCol = RaymarchDisk(ray, pos);
            //            pos += abs(_Size * 0.001 / (ray.y + 1e-4)) * ray;
            //            diskAccCol = float4(diskCol.rgb * (1.0 - diskAccCol.a) + diskAccCol.rgb, diskAccCol.a + diskCol.a * (1.0 - diskAccCol.a));
            //        }
            //        else if (dist2 > _Size * 1000.0)
            //        {
            //            break;
            //        }
            //    }

            //    // Compositing
            //    output.depth = rawDepth; //base depth

            //    if (suckedIn)
            //    {
            //        finalColor.rgb = diskAccCol.rgb * diskAccCol.a + glow.rgb * (1.0 - diskAccCol.a);
                    
            //        // writw the depth of horizon for Black Hole
            //        float4 bhClip = TransformWorldToHClip(pos + _BlackHolePos.xyz);
            //        output.depth = bhClip.z / bhClip.w;
            //    }
            //    else
            //    {
            //        float3 projectedWorld = camWorldPos + lerp(initialRay, ray, _LensingStrength) * 100.0;
            //        float4 clipPos = TransformWorldToHClip(projectedWorld);
            //        float2 distortedUV = (clipPos.xy / clipPos.w) * 0.5 + 0.5;

            //        #if UNITY_UV_STARTS_AT_TOP
            //        distortedUV.y = 1.0 - distortedUV.y;
            //        #endif

            //        distortedUV = saturate(distortedUV);

            //        float distortedRawDepth = SampleSceneDepth(distortedUV);

            //        #if UNITY_REVERSED_Z
            //        bool distortedIsSkybox = (distortedRawDepth <= 0.00001);
            //        #else
            //        bool distortedIsSkybox = (distortedRawDepth >= 0.99999);
            //        #endif

            //        float3 distortedSceneWorldPos = ComputeWorldSpacePosition(distortedUV, distortedRawDepth, UNITY_MATRIX_I_VP);
            //        float distortedSceneDist = distortedIsSkybox ? 1e6 : distance(distortedSceneWorldPos, camWorldPos);

            //        float3 backgroundRGB = float3(0,0,0);

            //        if (!distortedIsSkybox)
            //        {
            //            backgroundRGB = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, distortedUV).rgb;
            //        }
            //        else
            //        {
            //            backgroundRGB = GenerateProceduralSpace(ray);
            //        }

            //        // --------------------------------------------------------
            //        // 3D SDF REMARCHING OF PLANETS AND ASTEROIDS IN GLOBAL SPACE
            //        // --------------------------------------------------------
            //        float marchT = 0.0;
            //        float3 rayStartPos = camWorldPos;
            //        bool planetHit = false;
                    
            //        // Near cut-off raymarching radius around the planet
            //        float distToPlanetCenter = distance(camWorldPos, _PlanetPos.xyz);
            //        float maxRayDist = min(distortedSceneDist, distToPlanetCenter + _PlanetRadius * 3.0);//min(rawSceneDist, distToPlanetCenter + _PlanetRadius * 3.0);
                    
            //        for (int step = 0; step < 80; step++)
            //        {
            //            float3 currWorldPos = rayStartPos + ray * marchT;
            //            if (marchT > maxRayDist) break;
                        
            //            float spireVal = 0.0;
            //            float dPlanet = MapPlanetSDF(currWorldPos, spireVal);
            //            float dAsteroids = MapAsteroidsSDF(currWorldPos);
                        
            //            float dMin = min(dPlanet, dAsteroids);
                        
            //            if (dMin < 0.015 * (1.0 + marchT * 0.01))
            //            {
            //                // check we're not behind the scene geometry
            //                if (marchT <distortedSceneDist)// rawSceneDist)
            //                {
            //                    planetHit = true;
            //                    Light mainLight = GetMainLight();
            //                    float3 sunDir = normalize(mainLight.direction);
                                
            //                    float3 hitNormal;
            //                    float3 objCol = float3(0,0,0);
                                
            //                    if (dPlanet < dAsteroids)
            //                    {
            //                        // Hitting an ice planet with spiers
            //                        hitNormal = CalcPlanetNormal(currWorldPos);
            //                        float NdotL = saturate(dot(hitNormal, sunDir));
            //                        float NdotV = saturate(dot(-ray, hitNormal));
            //                        float fresnel = pow(1.0 - NdotV, 3.0);

            //                        float3 surfCol = lerp(_PlanetDarkColor.rgb, _PlanetIceColor.rgb, spireVal * 0.75 + 0.25);
            //                        surfCol += float3(0.85, 0.95, 1.0) * pow(spireVal, 2.0) * 2.0;

            //                        float3 reflectDir = reflect(ray, hitNormal);
            //                        float spec = pow(saturate(dot(reflectDir, sunDir)), 28.0);

            //                        objCol = surfCol * (NdotL * 0.85 + 0.15) + float3(0.9, 0.98, 1.0) * spec * (spireVal + 0.2) * 2.5;
            //                        objCol += _PlanetIceColor.rgb * fresnel * 1.5;
            //                    }
            //                    else
            //                    {
            //                        // Hitting a 3D Asteroid
            //                        hitNormal = CalcAsteroidsNormal(currWorldPos);
            //                        float NdotL = saturate(dot(hitNormal, sunDir));
            //                        float3 rockNoise = SunGradientNoise(currWorldPos * 2.0);
            //                        float3 rockBaseCol = float3(0.35, 0.38, 0.4) + rockNoise * 0.12;
            //                        objCol = rockBaseCol * (NdotL * 0.8 + 0.2);
            //                    }
                                
            //                    backgroundRGB = objCol;
                                
            //                    // calculate exact depth of surface to write in SV_Depth
            //                    float4 hitClipPos = TransformWorldToHClip(currWorldPos);
            //                    output.depth = hitClipPos.z / hitClipPos.w;
            //                }
            //                break;
            //            }
                        
            //            marchT += max(0.02, dMin * 0.55);
            //        }

            //        finalColor.rgb = diskAccCol.rgb * diskAccCol.a + backgroundRGB * (1.0 - diskAccCol.a) + glow.rgb * (1.0 - diskAccCol.a);
            //        //finalColor.rgb = diskAccCol.rgb * diskAccCol.a + backgroundRGB * (1.0 - diskAccCol.a) + glow.rgb; //fix hole gravitation glow
            //    }

            //    // Gamma correction (emmision etc.)
            //    //finalColor.rgb = pow(max(0.0, finalColor.rgb), 0.6);
            //    //output.color = saturate(finalColor);

            //    // Allow pure HDR output without cropping and manual gamma correction                 // (Unity Post Processing /Tonemapping will do it right)
            //    output.color = float4(max(0.0, finalColor.rgb), 1.0);
            //    return output;
            //}

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
                float4 sceneColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);
            
                float3 pos = camWorldPos - _BlackHolePos.xyz;
                float3 ray = normalize(sceneWorldPos - camWorldPos);
                float3 initialRay = ray;
            
                // Distance camera -> black hole. Anything closer is IN FRONT of the hole
                float bhDist = length(pos);
                bool meshInFront = !isSkybox && rawSceneDist < bhDist;
            
                float4 diskAccCol = float4(0, 0, 0, 0);
                
                //float4 glow = float4(0, 0, 0, 0);
                float minR = 1e9; //nearest approach of the ray to the center of the hole

                float3 finalColor = float3(0, 0, 0);
                bool suckedIn = false;
                
                //bool blockedByMesh = false;
                bool meshHit = false;                 // ray hit mesh in front of the hole
                float4 diskAtMesh = float4(0,0,0,0);  // disk/glow that were BEFORE the mesh
                //float4 glowAtMesh = float4(0,0,0,0);
                float phys = _BlackHolePhysics;


                float travel = 0.0; //how much beam passed from the camera
                int maxSteps = (int)_MaxRaySteps;
            
                //Beam due to gravitational distortion
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
            
                    //mesh is standing in front of the hole: we reached it - we can't see anything further (depth)
            
                    travel += stepDist;

                    //if (meshInFront && travel >= rawSceneDist) { blockedByMesh = true; break; }
                    if (meshInFront && !meshHit && travel >= rawSceneDist)
                    {
                        meshHit = true;
                        diskAtMesh = diskAccCol; //memorize what was before the mesh
                        //glowAtMesh = glow;
                        if (phys >= 0.999) break; // full physics: what is behind the mesh doesn't matter, save steps
                        // otherwise continue to calculate the "hole over everything" for blending
                    }
            
                    
                    //glow += _GlowColor * _GlowIntensity * (0.01 * stepDist * invDistSqr * invDistSqr * saturate(centDist * 2.0 - 1.2));
                    //// Distance in hole radii: glow does not depend on _Size
                    //float rn = max(centDist / _Size, 0.05);
                    //float stepN = stepDist / _Size;
                    //const float GLOW_SCALE = 40.0; // boost to make _GlowIntensity = 1 noticeable                    
                    //// ~1/r^4: bright near the hole, quickly fades. saturate dims the glow near the horizon
                    //glow += _GlowColor * _GlowIntensity * (GLOW_SCALE * 0.01 * stepN / (rn * rn * rn * rn) * saturate(rn * 2.0 - 1.2));
            
                    float dist2 = length(pos);
                    minR = min(minR, dist2);
            
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
            
                            // Glow = light that almost fell into the black hole (similar to a photon ring).
                // The closer a ray of light comes to the horizon and survives, the brighter it becomes; it quickly fades away
                //float edgeDist = max(0.0, minR / _Size - _PhotonSphereR);  
                float edgeDist = max(0.0, minR / _Size);  
                const float GLOW_SCALE = 2.0;
                float3 glowCol = _GlowColor.rgb * _GlowIntensity * GLOW_SCALE * exp(-edgeDist / _GlowWidth);
                if (suckedIn)
                    glowCol = float3(0, 0, 0); // the core remains black

                // ---------------- Compositing ----------------
                output.depth = rawDepth;
                //float diskA = diskAccCol.a;
            
                //if (blockedByMesh)
                //{
                //    // mesh in front of the hole: we show it as it is (without distortion), disc/glow only if they were BEFORE it
                //    finalColor = diskAccCol.rgb * diskA + (sceneColor.rgb + glow.rgb) * (1.0 - diskA);
                //}
                //else if (suckedIn)
                //{
                //    //The beam fell into the hole. But there may be a planet/asteroid in front of the hole - they close it
                //    float3 objCol, objPos; float objT;
                //    if (TraceSpaceObjects(camWorldPos, initialRay, min(rawSceneDist, bhDist), objCol, objT, objPos))
                //    {
                //        finalColor = objCol;
                //        float4 c = TransformWorldToHClip(objPos);
                //        output.depth = c.z / c.w;
                //    }
                //    else
                //    {
                //        finalColor = diskAccCol.rgb * diskA + glow.rgb * (1.0 - diskA);
                //        float4 bhClip = TransformWorldToHClip(pos + _BlackHolePos.xyz); // horiz depth
                //        output.depth = bhClip.z / bhClip.w;
                //    }
                //}
                //else
                //{
                //    // single beam taking into account the power of the lens: at 0 = no distortion at all
                //    float3 lensedRay = normalize(lerp(initialRay, ray, _LensingStrength));
            
                //    float3 projectedWorld = camWorldPos + lensedRay * 100.0;
                //    float4 clipPos = TransformWorldToHClip(projectedWorld);
                //    float2 distortedUV = (clipPos.xy / clipPos.w) * 0.5 + 0.5;
                //    #if UNITY_UV_STARTS_AT_TOP
                //    distortedUV.y = 1.0 - distortedUV.y;
                //    #endif
                //    distortedUV = saturate(distortedUV);
            
                //    float distortedRawDepth = SampleSceneDepth(distortedUV);
                //    #if UNITY_REVERSED_Z
                //    bool distortedIsSkybox = (distortedRawDepth <= 0.00001);
                //    #else
                //    bool distortedIsSkybox = (distortedRawDepth >= 0.99999);
                //    #endif
                //    float3 distortedSceneWorldPos = ComputeWorldSpacePosition(distortedUV, distortedRawDepth, UNITY_MATRIX_I_VP);
                //    float distortedSceneDist = distortedIsSkybox ? 1e6 : distance(distortedSceneWorldPos, camWorldPos);
            
                //    float3 backgroundRGB = distortedIsSkybox
                //        ? GenerateProceduralSpace(lensedRay)
                //        : SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, distortedUV).rgb;
            
                //    // Planet and asteroids along the same beam
                //    float3 objCol, objPos; float objT;
                //    bool objHit = TraceSpaceObjects(camWorldPos, lensedRay, distortedSceneDist, objCol, objT, objPos);
            
                //    if (objHit)
                //    {
                //        float4 c = TransformWorldToHClip(objPos);
                //        output.depth = c.z / c.w;
                //    }
            
                //    if (objHit && objT < bhDist)
                //    {
                //        // the object is closer than the hole: it covers both the disk and the glow
                //        finalColor = objCol;
                //    }
                //    else
                //    {
                //        if (objHit)
                //            backgroundRGB = objCol; // the object BEHIND the hole - the disc is drawn on top
                //        finalColor = diskAccCol.rgb * diskA + backgroundRGB * (1.0 - diskA) + glow.rgb * (1.0 - diskA);
                //    }
                //}

                // The mesh as-is (without distortion) + the disk/glow that were BEFORE it
                
                //float3 meshCol = diskAtMesh.rgb * diskAtMesh.a + (sceneColor.rgb + glowAtMesh.rgb) * (1.0 - diskAtMesh.a);
                float3 meshCol = diskAtMesh.rgb * diskAtMesh.a + sceneColor.rgb * (1.0 - diskAtMesh.a);
                
                if (meshHit && phys >= 0.999)
                {
                    // full physics: the mesh simply covers everything behind it
                    finalColor = meshCol;
                }
                else
                {
                    float diskA = diskAccCol.a;
                
                    if (suckedIn)
                    {
                        // "Hole over everything" (old look)
                        //float3 holeCol = diskAccCol.rgb * diskA + glow.rgb * (1.0 - diskA);
                        float3 holeCol = diskAccCol.rgb * diskA;
                        float4 bhClip = TransformWorldToHClip(pos + _BlackHolePos.xyz); // horizon depth
                        finalColor = holeCol;
                        output.depth = bhClip.z / bhClip.w;
                
                        // Planet/asteroid IN FRONT of the hole covers it with weight phys
                        float3 objCol, objPos; float objT;
                        if (phys > 0.001 && TraceSpaceObjects(camWorldPos, initialRay, min(rawSceneDist, bhDist), objCol, objT, objPos))
                        {
                            finalColor = lerp(holeCol, objCol, phys);
                            float4 c = TransformWorldToHClip(objPos);
                            if (phys > 0.5) output.depth = c.z / c.w; // depth belongs to the dominant mode
                        }
                    }
                    else
                    {
                        float3 lensedRay = normalize(lerp(initialRay, ray, _LensingStrength));
                
                        float3 projectedWorld = camWorldPos + lensedRay * 100.0;
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
                
                        float3 backgroundRGB = distortedIsSkybox
                            ? GenerateProceduralSpace(lensedRay)
                            : SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, distortedUV).rgb;
                
                        // Planet and asteroids along the same ray
                        float3 objCol, objPos; float objT;
                        bool objHit = TraceSpaceObjects(camWorldPos, lensedRay, distortedSceneDist, objCol, objT, objPos);
                
                        if (objHit)
                        {
                            float4 c = TransformWorldToHClip(objPos);
                            output.depth = c.z / c.w;
                            backgroundRGB = objCol; // the object is the background under the disk
                        }
                
                        // "Hole over everything": disk and glow over the background
                        //finalColor = diskAccCol.rgb * diskA + backgroundRGB * (1.0 - diskA) + glow.rgb * (1.0 - diskA);
                        finalColor = diskAccCol.rgb * diskA + (backgroundRGB + glowCol) * (1.0 - diskA);
                
                        // The object closer than the hole covers the disk and glow with weight phys
                        if (objHit && objT < bhDist)
                            finalColor = lerp(finalColor, objCol, phys);
                    }
                
                    // The mesh IN FRONT of the hole covers it with weight phys
                    if (meshHit)
                    {
                        finalColor = lerp(finalColor, meshCol, phys);
                        if (phys > 0.5) output.depth = rawDepth;
                    }
                }
            
                // HDR without cropping (tone mapping will be done by Post Processing)
                output.color = float4(max(0.0, finalColor), 1.0);
                return output;
            }

            ENDHLSL
        }
    }
}