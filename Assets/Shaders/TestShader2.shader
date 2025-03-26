Shader "Unlit/TestShader2"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (0.1, 0.1, 0.1, 1.0)
        _TimeSpeed("Time Speed", Float) = 1.0
        _WarpStrength("Warp Strength", Float) = 0.6
        _LoopCount("Loop Count", Float) = 10.0
        _GlowStrength("Line Glow Intensity", Float) = 3.0
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

            float4 _BaseColor;
            float _TimeSpeed;
            float _WarpStrength;
            float _LoopCount;
            float _GlowStrength;

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
                o.uv = v.uv; // UV space [0..1]
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float time = _Time.y * _TimeSpeed;

                // Centered UVs [-1, 1]
                float2 uv = i.uv * 2.0 - 1.0;

                // Recursive warping loop
                for (float i = 1.0; i < _LoopCount; i += 1.0)
                {
                    uv.x += _WarpStrength / i * cos(i * 2.5 * uv.y + time);
                    uv.y += _WarpStrength / i * cos(i * 1.5 * uv.x + time);
                }

                float s = abs(sin(time - uv.x - uv.y));
                float intensity = _GlowStrength / (s + 0.2); // add small value to avoid spikes
                float3 col = _BaseColor.rgb * intensity;

                return float4(col, 1.0);
            }

            ENDCG
        }
    }
}