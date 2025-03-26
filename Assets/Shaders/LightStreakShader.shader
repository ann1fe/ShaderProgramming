Shader "Unlit/LightStreakShader"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        [HDR]_StreakColor("Streak Color (HDR)", Color) = (1,1,1,1)
        _Speed("Sweep Speed", Float) = 1.0
        _Width("Streak Width", Float) = 0.1
        _Angle("Angle (Degrees)", Range(0,360)) = 45.0
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
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 position : SV_POSITION;
            };

            sampler2D _MainTex;
            float4    _MainTex_ST;

            float4 _StreakColor; 
            float  _Speed;             
            float  _Width;            
            float  _Angle;  // angle in degrees

            // A "ease in-out cubic" to slow near edges, speed in middle
            float EaseInOutCubic(float t)
            {
                return (t < 0.5) 
                    ? 4.0 * t * t * t 
                    : 1.0 - pow(-2.0 * t + 2.0, 3.0) / 2.0;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Base texture
                fixed4 baseCol = tex2D(_MainTex, i.uv);

                // Time from 0..1 each cycle
                float t0 = frac(_Time.x * _Speed);
                float eased = EaseInOutCubic(t0);

                // Map eased to some range, so the line goes off-screen
                float param = lerp(-1.2, 1.2, eased);

                // Convert angle from degrees to radians
                float rad = _Angle * 3.14159265359 / 180.0;
                float c = cos(rad);
                float s = sin(rad);

                // We define the line as c*x + s*y = param
                // The perpendicular distance is abs( c*x + s*y - param )
                float lineVal = c * i.uv.x + s * i.uv.y;
                float dist = abs(lineVal - param);

                // Soft band around the line
                float streakFactor = 1.0 - smoothstep(_Width, _Width * 1.5, dist);

                float3 finalRGB = baseCol.rgb + _StreakColor.rgb * streakFactor;
                return float4(finalRGB, baseCol.a);
            }
            ENDCG
        }
    }
}
