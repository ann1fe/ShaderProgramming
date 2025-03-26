Shader "Unlit/TestShader"
{
    Properties
    {
        _TimeSpeed("Time Speed", Float) = 1.0
        _DotSharpness("Dot Sharpness", Float) = 0.05
        _Resolution("Resolution", Vector) = (1920, 1080, 0, 0)
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

            float _TimeSpeed;
            float _DotSharpness;
            float4 _Resolution;

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 fragCoord = i.uv * _Resolution.xy;

                // Normalize to [0..1]
                float2 p = fragCoord / _Resolution.xy;

                // Center coordinates to [-0.5, 0.5], compensate for aspect ratio
                p -= 0.5;
                p.x *= _Resolution.x / _Resolution.y;

                float l = length(p);          // Distance from center
                float z = _Time.y * _TimeSpeed * 0.5;  // Time-driven animation base
                float3 col = 0;

                for (int j = 0; j < 3; j++)
                {
                    float3 tempCol = 0;

                    float2 uv = p * 10.0 * sin(sin(z) * l - 0.5 * z) / (abs(sin(z)) + 1.0);
                    float2 tileUV = frac(uv) - 0.5;  // repeating tile space

                    float brightness = _DotSharpness / length(tileUV);
                    brightness *= abs(sin(l - z)); // pulsate based on radial distance

                    col[j] = brightness;
                    z += 0.07; // offset for each channel
                }

                col /= l + 0.0001; // fade from center outward
                return float4(col, 1.0);
            }

            ENDCG
        }
    }
}