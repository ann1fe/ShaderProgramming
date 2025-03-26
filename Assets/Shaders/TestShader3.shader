Shader "Unlit/TestShader3"
{
    Properties
    {
        _Speed("Animation Speed", Float) = 1.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _Speed;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // Plot line function
            float plot(float r, float pct)
            {
                return smoothstep(pct - 0.2, pct, r) - smoothstep(pct, pct + 0.2, r);
            }

            // Color palette
            float3 pal(float t, float3 a, float3 b, float3 c, float3 d)
            {
                return a + b * cos(6.28318 * (c * t + d));
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float time = _Time.y * _Speed;

                // UV [0,1] → centered [-0.5, 0.5]
                float2 uv = i.uv;
                float2 pos = float2(0.5, 0.5) - uv;

                // Aspect-ratio neutral (only needed if you want perfect symmetry)
                // But since we are UV-space, we’ll skip manual correction
                // pos.x *= (_ScreenParams.x / _ScreenParams.y); <-- OMITTED

                // Radial scaling over time
                pos *= cos(time) * 1.0 + 1.5;

                float r = length(pos) * 2.0;
                float a = atan2(pos.y, pos.x);

                float f = abs(cos(a * 2.5 + time * 0.5)) * sin(time * 2.0) * 0.698 + cos(time) - 4.0;
                float d = f - r;

                float3 color1 = smoothstep(frac(d), frac(d) - 0.2, 0.16).xxx;
                float3 color2 = smoothstep(frac(d), frac(d) - 1.184, 0.16).xxx;
                float3 baseCol = (color1 - color2) *
                    pal(f,
                        float3(0.725, 0.475, 0.440),
                        float3(0.605, 0.587, 0.007),
                        float3(1.0, 1.0, 1.0),
                        float3(0.310, 0.410, 0.154));

                float pct = plot(r * 0.272, frac(d * (sin(time) * 0.45 + 0.5)));

                float3 overlayCol = pal(r,
                    float3(0.750, 0.360, 0.352),
                    float3(0.450, 0.372, 0.271),
                    float3(0.540, 0.442, 0.264),
                    float3(0.038, 0.350, 0.107));

                float3 finalColor = baseCol + overlayCol * pct;

                return float4(finalColor, pct * 0.3);
            }

            ENDCG
        }
    }
}
