Shader "Custom/ColorfulLoadingShader"
{
    Properties
    {
		_Speed("Speed", Range(1,300)) = 10
        _Theta ("Theta", Range(0.0, 6.28318)) = 0.0
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0
		#define TWO_PI 6.28318

        float _Speed;
		float _Theta;
        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        //  Function from Iñigo Quiles
		//  https://www.shadertoy.com/view/MsS3Wc
        fixed3 hsb2rgb(in fixed3 c) {
            fixed3 rgb = clamp(abs((c.x * 6.0 + fixed3(0.0, 4.0, 2.0)) % 6.0 - 3.0) - 1.0, 0.0, 1.0);
            rgb = rgb * rgb * (3.0 - 2.0 * rgb);
            return c.z * lerp(fixed3(1.0, 1.0, 1.0), rgb, c.y);
        }

        float drawCircle(fixed2 _st, fixed2 center, float _radius) {
            fixed2 dist = center - _st;
            return 1.0 - smoothstep(_radius - (_radius * 0.9), _radius + (_radius * 0.9), dot(dist, dist) * 20.0);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float pct          = 0.0;
            const int n        = 10;
            float pt            = TWO_PI / float(n);
            float amp          = 0.35;
            fixed2 center    = (0.5, 0.5);

            fixed2 toCenter = center - IN.uv_MainTex;
            float angle = -(atan2(toCenter.x, toCenter.y)-_Theta) + _Speed*_Time;

            for (int i = 0; i < n; ++i) {
                float sin_value = sin(_Speed * _Time - pt * i);
                float cos_value = cos(_Speed * _Time - pt * i);

                pct += drawCircle(IN.uv_MainTex, center + fixed2(amp * sin_value, amp * cos_value), 0.008 * (n - i));
            };
            fixed3 filteredHsbColor = hsb2rgb(fixed3((angle / TWO_PI), 1.0, 1.0))*pct;

            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * fixed4(filteredHsbColor, 1.0);
            o.Albedo = c.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
