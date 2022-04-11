Shader "Custom/Rainbow"
{
    Properties
    {
        _Speed("Speed", Range(1,100)) = 10
        _Width("Width", Range(1,100))  = 10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

		int _Speed;
		int _Width;

        struct Input
        {
            float3 worldPos;
        };

        float cubicPulse(float c, float w, float x) {
            x = abs(x - c);
            if (x > w) return 0.0;
            x /= w;
            return 1.0 - x * x * (3.0 - 2.0 * x);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float3 localPos = IN.worldPos - mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz;

            float abs_x = sin(frac(localPos.x/_Width+_Speed*_Time));

            float r = 0.8 * (1.0 - cubicPulse(0.5, 0.3, abs_x)) + 0.15;
            float g = 0.8 * cubicPulse(0.3, 0.4, abs_x) + 0.15;
			float b = 0.8 * cubicPulse(0.7, 0.4, abs_x) + 0.15;

            o.Albedo = fixed4(r, g, b, 1);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
