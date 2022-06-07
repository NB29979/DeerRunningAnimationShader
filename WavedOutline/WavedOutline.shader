Shader "Custom/WavedOutLine"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
		_Speed("Speed", Range(1,1000)) = 100
        _AmpLimit("AmpLimit", Range(0.01,1.0)) = 0.5
        _OutlineBase("OutlineBase", Range(0.0,10)) = 2
    }

    CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv       : TEXCOORD0;
        float3 normal : NORMAL;
	};

	struct v2f 
	{
        float4 pos : SV_POSITION;
        float2 uv   : TEXCOORD0;
     };

    struct Input
    {
        float2 uv_MainTex;
    };

    sampler2D _MainTex;
    float4 _MainTex_ST;
    uniform float4 _MainColor;
    uniform float _OutlineWidth;
    uniform float4 _OutlineColor;
    int _Speed;
    float _AmpLimit;
    float _OutlineBase;

    ENDCG

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Name "Base"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); // 頂点をMVP変換
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) :SV_Target
            {
                half4 c = tex2D(_MainTex, i.uv); // textureColorのサンプリング
                c.rgb *= _MainColor; // BaseColorの乗算
                return c;
            }
            ENDCG
        }

        Pass
        {
            Name "Outline"
            Cull Front // 表面のカリング

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

			v2f vert(appdata v)
            {
                v2f o;

				o.pos = UnityObjectToClipPos(v.vertex); // 頂点をMVP変換
                float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal)); // Model座標系の法線をView座標系に変換
                float2 offset = TransformViewToProjection(norm.xy); // View座標系に変換した法線を投影座標系に変換

                // 以下sinは[-_AmpLimit,_AmpLimit]なので、_OutlineBaseを加算する
                float amp = _AmpLimit * sin(_Time * _Speed + offset.x * _Speed + offset.y * _Speed) + _OutlineBase;

                o.pos.xy += offset * amp;

                return o;
            }
            fixed4 frag(v2f i) :SV_Target
            {
                return _OutlineColor; // OutlineColorの描画
            }

			ENDCG
		}
    }
}
