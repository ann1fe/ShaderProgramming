Shader "Unlit/AnimatedCircleShader"
{
    Properties
    {
        _Radius("Circle Radius", Float) = 0.5
        _Width("Edge Width", Float) = 0.8
        _Power("Glow Power", Float) = 0.1
        _HueStart("Start Hue", Float) = 0.5
        _HueEnd("End Hue", Float) = 0.65
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

            float _Radius;
            float _Width;
            float _Power;
            float _HueStart;
            float _HueEnd;

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

            // HSV to RGB helper
            float3 hsv2rgb(float h, float s, float v)
            {
                float4 t = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(h + float3(0.0, t.y, t.z)) * 6.0 - t.w);
                return v * lerp(float3(1.0, 1.0, 1.0), saturate(p - 1.0), s);
            }

            // Glowy circle logic
            float3 drawCircle(float2 pos, float radius, float width, float power, float3 color, float time)
            {
                float dist1 = length(pos);
                dist1 = frac((dist1 * 5.0) - frac(time));
                float dist2 = dist1 - radius;

                float intensity = pow(radius / max(abs(dist2), 0.0001), width); // avoid div by 0
                return color * intensity * power * max(0.8 - abs(dist2), 0.0);
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
                float2 uv = i.uv * 2.0 - 1.0; // center [-1, 1] space (square-safe)

                float dist = length(uv);
                float h = lerp(_HueStart, _HueEnd, dist);
                float3 baseColor = hsv2rgb(h, 1.0, 1.0);

                float time = _Time.y;
                float3 glow = drawCircle(uv, _Radius, _Width, _Power, baseColor, time);

                return float4(glow, 1.0);
            }

            ENDCG
        }
    }
}
