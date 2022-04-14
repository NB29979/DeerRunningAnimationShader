Shader "Custom/WaitingCursor"
{
    Properties
    {
        _Speed("Speed", Range(1,100)) = 10
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0
        #define TWO_PI 6.28318530718

        int _Speed;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        //  Function from Iñigo Quiles
		//  https://www.shadertoy.com/view/MsS3Wc
        float3 hsb2rgb(in float3 c) {
            float3 rgb = clamp(abs((c.x * 6.0 + float3(0.0, 4.0, 2.0))% 6.0 - 3.0) - 1.0, 0.0, 1.0);
            rgb = rgb * rgb * (3.0 - 2.0 * rgb);
            return c.z * lerp(float3(1.0, 1.0, 1.0), rgb, c.y);
        }
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float3 local_pos = IN.worldPos - mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;

            float2 toCenter = fixed2(0, 0) - float2(local_pos.x, local_pos.z);
            float angle = atan2(toCenter.x, toCenter.y) + _Speed*_Time;
            float radius = length(toCenter) * 2.0;

            // hsbでは距離0はWhite。
            float outerColor = step(1.15, distance(fixed3(0, 0, 0), local_pos)) - step(1.5, distance(fixed3(0, 0, 0), local_pos));
            // Map the angle (-PI to PI) to the Hue (from 0 to 1) and the Saturation to the radius
            o.Albedo = hsb2rgb(float3((angle/TWO_PI), outerColor, 1.0));
        }
        ENDCG
    }
    FallBack "Diffuse"
}
