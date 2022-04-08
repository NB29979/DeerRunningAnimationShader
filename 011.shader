Shader "Custom/011"
{
    Properties
    {
        _MainTex ("MainTex", 2D)              = "white" {}
        _SubTex  ("SubTex", 2D)               = "white" {}
        _Speed   ("Speed", Range(1,1000)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _SubTex;
        int _Speed;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // 全体的なAnimationの速度
            float vt = _Speed * _Time;

            // 背景のuvスクロール
            fixed2 c1_uv = IN.uv_MainTex;
            c1_uv.x += vt;
            fixed4 c1 = tex2D(_MainTex, c1_uv);

            // 鹿の動き
            fixed4 c2 = tex2D(_SubTex,  IN.uv_MainTex);
            fixed2 c2_uv = IN.uv_MainTex;

            c2_uv.x +=0.03*(cos(vt)*c2_uv.x-sin(vt)*c2_uv.y);
            c2_uv.y +=0.03*(sin(vt)*c2_uv.x+cos(vt)*c2_uv.y);

            c2 = tex2D(_SubTex, c2_uv);

            // c2のグレースケール化、Black(0,0,0)でなければWhiteとしてmask
            fixed4 p  = tex2D(_SubTex, c2_uv);
            p = (c2.r * 0.3 + c2.g * 0.6 + c2.b * 0.1 > 0.0) ? 1.0:0.0;

            // Gaming
            c2.r *= abs(sin(vt));
            c2.g *= abs(sin(1.5*vt));
            c2.b *= abs(sin(1.2*vt));

            // lerpは線形補完。 a + (b-a)t -> a(1-t) + bt
            o.Albedo = lerp(c1, c2, p);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
