Shader "Unlit/ErosionShader"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Scr Factor", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Dst Factor", Float) = 10
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("Texture", 2D) = "white" {}
        _RevealValue ("Reveal", Float) = 0
        _Feather ("Feather", Float) = 0

        [HDR] _ErodeColor ("Erode Color", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]
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
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _RevealValue;
            float _Feather;
            float4 _ErodeColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                fixed4 mask = tex2D(_MaskTex, i.uv.zw);
                // step function
                //float revealAmount = smoothstep(mask.r - _Feather, mask.r + _Feather, _RevealValue);
                float revealAnim = sin(_Time.y * 2) * 0.6 + 0.5;
                
                float revealAmountTop = step(mask.r, revealAnim + _Feather);
                float revealAmountBottom = step(mask.r, revealAnim - _Feather);
                float revealDifference = revealAmountTop - revealAmountBottom;

                float3 finalCol = lerp(col.rgb, _ErodeColor, revealDifference);
                //return fixed4(revealDifference.xxx,1); 
                return fixed4(finalCol.rgb,col.a * revealAmountTop); 
            }
            ENDCG
        }
    }
}
