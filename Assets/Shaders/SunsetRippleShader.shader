Shader "Unlit/SunsetRippleShader"
{
    Properties
    {
        _Resolution ("Resolution (X,Y)", Vector) = (1920, 1080, 0, 0)
        _ColorA("Sunset Color 1", Color) = (0.85, 0.55, 0, 1)
        _ColorB("Sunset Color 2", Color) = (0.90, 0.40, 0, 1)
        _BGColor("Background Tint Color", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _Resolution;
            float4 _ColorA;
            float4 _ColorB;
            float4 _BGColor;

            float cnoise(float2 uv)
            {
                float2x2 r = float2x2(-0.1288, -0.9917, 0.9917, -0.1288);
                float2 s0 = cos(uv);
                float2 s1 = cos(mul(uv, 2.5 * r));
                float2 s2 = cos(mul(uv, 4.0 * mul(r, r)));
                float2 s = s0 * s1 * s2;
                return (s.x + s.y) * 0.25 + 0.5;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 fragCoord = i.uv * _Resolution.xy;
                float2 uv = (fragCoord - 0.5 * _Resolution.xy) / _Resolution.y;
                float time = _Time.x;
                float dy = (smoothstep(0.0, -1.0, uv.y) * 40.0 + 1.5) / _Resolution.y;
                float3 disp[4];
                disp[0] = float3(0.5, 20.0, 8.0);
                disp[1] = float3(2.5, 60.0, 4.0);
                disp[2] = float3(5.0, 80.0, 2.0);
                disp[3] = float3(10.0, 20.0, 2.0);
                float avg = 0.0;
                [unroll]
                for(int idx = 0; idx < 4; idx++)
                {
                    float2 scaledUV = uv * disp[idx].xy + time;
                    float noiseVal = cnoise(scaledUV);
                    avg += noiseVal * disp[idx].z - disp[idx].z * 0.5;
                }
                avg /= 4.0;
                float shift = clamp(avg * smoothstep(0.1, -1.0, uv.y), -0.1, 0.1);
                float2 st = float2(uv.x, uv.y + shift);
                float factor = sqrt(abs(st.y * st.y * st.y)) * 28.0;
                float3 colorSunset = lerp(_ColorA.rgb, _ColorB.rgb, saturate(factor));
                float circleMask = smoothstep(0.25 + dy, 0.25, length(st));
                float3 finalColor = colorSunset * circleMask;
                float vignette = smoothstep(2.0, 0.5, length(uv));
                finalColor += _BGColor.rgb * vignette * 0.1;
                return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}
