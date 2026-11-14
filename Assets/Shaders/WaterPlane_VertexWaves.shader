Shader "Custom/WaterPlane_VertexWaves"
{
    // Water plane with REAL vertex displacement. Same wave function as the fullscreen
    // raymarch water (MapWater), same shading (sky reflection, Fresnel, SSS, GGX glint, foam,
    // depth fog / clarity) - but drawn as a normal transparent mesh.
    //
    // Needs in URP asset: Depth Texture = ON (used for water thickness / fog).
    Properties
    {
        [Header(Water Level and Clarity)]
        _SeaLevel ("Ocean Level (Y Height)", Float) = 25.0
        _SeaTransparency ("Underwater Clarity / Depth Transparency", Range(0.001, 0.5)) = 0.0151
        _SeaColorDepth ("Color Depth Gradient Distance", Float) = 50.0
        _SeaMaxDistance ("Edge Fade Distance (hides plane border)", Float) = 300.0

        [Header(Water Shape)]
        _SeaHeight ("Ocean Wave Height", Range(-1.0, 1.5)) = 0.5
        _SeaChoppy ("Ocean Choppiness", Range(1.0, 10.0)) = 5.337
        _SeaFreq ("Ocean Wave Frequency", Range(0.01, 1.0)) = 0.1412
        _SeaSpeed ("Ocean Animation Speed", Range(0.1, 5.0)) = 0.76
        [IntRange] _VertexOctaves ("Octaves Displaced On Vertices (more = needs denser mesh)", Range(1, 3)) = 2

        [Header(Water Colors)]
        _SeaBaseColor ("Ocean Deep Base Color", Color) = (0.0, 0.1, 0.25, 1.0)
        _SeaWaterColor ("Ocean Shallow / SSS Color", Color) = (0.0, 0.62, 0.65, 1.0)

        [Header(Highlights)]
        _SpecRoughness ("Sun Glint Roughness", Range(0.01, 0.3)) = 0.05
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }
        LOD 100

        Pass
        {
            Name "WaterForward"
            Tags { "LightMode"="UniversalForward" }

            // out = rgb + scene * alpha,  where alpha = "how much of the scene is still visible through the water"
            // This is exactly lerp(scene, waterBody, fog) -> lerp(.., reflection, fresnel) of the raymarch version.
            Blend One SrcAlpha
            ZWrite Off
            ZTest LEqual
            Cull Back
            ColorMask RGB

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // only HenyeyGreenstein() is used from here (same include as the raymarch water)
            #include "Assets/Shaders/RaymarchCore.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float _SeaLevel;
                float _SeaTransparency;
                float _SeaColorDepth;
                float _SeaMaxDistance;
                float _SeaHeight;
                float _SeaChoppy;
                float _SeaFreq;
                float _SeaSpeed;
                float _VertexOctaves;
                float4 _SeaBaseColor;
                float4 _SeaWaterColor;
                float _SpecRoughness;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
            };

            // ------------------------------------------------------------------
            // Wave function (copied 1:1 from the raymarch shader)
            // ------------------------------------------------------------------
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

            // height of the wave ABOVE _SeaLevel (this is "h" inside MapWater: surface Y = _SeaLevel + h)
            float WaveHeight(float2 xz, int octaves)
            {
                float freq = _SeaFreq;
                float amp = _SeaHeight;
                float choppy = _SeaChoppy;
                float2 uv = xz;
                uv.x *= 0.75;

                float h = 0.0;
                float seaTime = (1.0 + _Time.y * _SeaSpeed);
                float2x2 octave_m = float2x2(1.6, 1.2, -1.2, 1.6);

                for (int i = 0; i < octaves; i++)
                {
                    float d = SeaOctave((uv + seaTime) * freq, choppy);
                    d += SeaOctave((uv - seaTime) * freq, choppy);
                    h += d * amp;
                    uv = mul(octave_m, uv);
                    freq *= 1.9;
                    amp *= 0.22;
                    choppy = lerp(choppy, 1.0, 0.2);
                }
                return h;
            }

            // per-pixel normal from ALL 5 octaves (fine detail lives here, not in the mesh)
            float3 WaveNormal(float2 xz, float eps)
            {
                float h  = WaveHeight(xz, 5);
                float hx = WaveHeight(xz + float2(eps, 0.0), 5);
                float hz = WaveHeight(xz + float2(0.0, eps), 5);
                return normalize(float3(-(hx - h), eps, -(hz - h)));
            }

            // ------------------------------------------------------------------
            // Shading helpers (copied from the raymarch shader)
            // ------------------------------------------------------------------
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

            // ------------------------------------------------------------------
            // Vertex: REAL displacement. World XZ drives the waves, so the waves stay
            // put in the world no matter how the plane is moved / scaled.
            // ------------------------------------------------------------------
            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                float3 posWS = TransformObjectToWorld(IN.positionOS.xyz);
                posWS.y = _SeaLevel + WaveHeight(posWS.xz, (int)_VertexOctaves);

                OUT.positionWS = posWS;
                OUT.positionCS = TransformWorldToHClip(posWS);
                return OUT;
            }

            // ------------------------------------------------------------------
            // Fragment: transparency + fog + reflection + glints
            // ------------------------------------------------------------------
            float4 Frag(Varyings IN) : SV_Target
            {
                float3 posWS = IN.positionWS;
                float3 toPoint = posWS - _WorldSpaceCameraPos;
                float dist = max(length(toPoint), 1e-4);
                float3 viewDir = toPoint / dist;                       // camera -> surface

                // --- water thickness along the view ray (scene depth behind the plane) ---
                float2 screenUV = IN.positionCS.xy / _ScaledScreenParams.xy;
                float rawDepth = SampleSceneDepth(screenUV);
                float3 sceneWS = ComputeWorldSpacePosition(screenUV, rawDepth, UNITY_MATRIX_I_VP);
                float submergedDepth = max(0.0, distance(sceneWS, _WorldSpaceCameraPos) - dist);

                float depthFog = 1.0 - exp(-submergedDepth * _SeaTransparency);
                float colorGrad = saturate(submergedDepth / max(0.001, _SeaColorDepth));
                float3 oceanBodyColor = lerp(_SeaWaterColor.rgb, _SeaBaseColor.rgb, colorGrad);

                // --- normal (eps grows with distance to avoid sparkling) ---
                float eps = max(0.001, dist * dist * (0.1 / _ScreenParams.x));
                float3 N = WaveNormal(posWS.xz, eps);

                // --- light + mesh shadows ---
                Light mainLight = GetMainLight(TransformWorldToShadowCoord(posWS));
                float3 sunDir = normalize(mainLight.direction);
                float3 sunColor = mainLight.color;
                float totalShadow = mainLight.shadowAttenuation;
                float mu = dot(sunDir, viewDir);

                // --- Fresnel + sky reflection ---
                float3 L = reflect(viewDir, N);
                float3 V = -viewDir;
                float NoV = clamp(abs(dot(N, V)) + 1e-5, 0.0, 1.0);
                float fresnel = Schlick(0.02, NoV);
                float3 reflection = GetSkyReflection(L, sunDir, sunColor);

                // lerp(lerp(scene, body, fog), reflection, fresnel) split into "light we add" and "scene we keep"
                float3 rgb = oceanBodyColor * depthFog * (1.0 - fresnel) + reflection * fresnel;
                float alpha = (1.0 - depthFog) * (1.0 - fresnel);

                // --- subsurface scattering through wave crests ---
                float relY = posWS.y - _SeaLevel;
                float subsurfaceAmount = 8.0 * HenyeyGreenstein(mu, 0.5);
                rgb += subsurfaceAmount * _SeaWaterColor.rgb * max(0.0, 1.0 + relY - 0.6 * _SeaHeight) * totalShadow;

                // --- sun glint (GGX) ---
                float3 H = normalize(V + sunDir);
                float NoL = max(0.0, dot(N, sunDir));
                float NoH = max(0.0, dot(N, H));
                float spec = Depth_GGX(_SpecRoughness, NoH);
                float3 lowScatter = float3(1.0, 0.7, 0.5);
                rgb += lowScatter * 0.4 * (NoL / PI * fresnel * sunColor * spec) * totalShadow;

                // --- foam on crests ---
                float foam = 4.0 * max(0.0, smoothstep(0.35, 0.6, relY - _SeaHeight) * N.x);
                rgb += foam * float3(0.9, 0.95, 1.0);

                // --- fade out near the plane border (shows the scene behind instead of a hard edge) ---
                float edgeFade = smoothstep(_SeaMaxDistance * 0.7, _SeaMaxDistance, dist);
                rgb *= (1.0 - edgeFade);
                alpha = lerp(alpha, 1.0, edgeFade);

                return float4(rgb, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
