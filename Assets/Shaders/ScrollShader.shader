Shader "Unlit/ScrollShader"
{
    Properties
    {
        _MainTexture ("Main Texture", 2D) = "white" {}
        _AnimateXY ("Animate XY", Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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

            sampler2D _MainTexture;
            float4 _MainTexture_ST;
            float4 _AnimateXY;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTexture);
                o.uv += _AnimateXY.xy * float2(_Time.yy);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uvs = i.uv;
        
                //return fixed4 (uvs,0,1);

                fixed4 textureColor = tex2D(_MainTexture, uvs);
                return textureColor;
            }
            ENDCG
        }
    }
}
