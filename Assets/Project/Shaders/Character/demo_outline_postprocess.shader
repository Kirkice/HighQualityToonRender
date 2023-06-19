Shader "demo/postprocess/outline"
{
    Properties
    {
        _MainTex("Base Texture", 2D) = "white" {}
    }
    SubShader
    {

        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex VS
            #pragma fragment PS

            struct VertexIn
            {
                float4 PosL : POSITION;
                float2 TexC : TEXCOORD0;
            };

            struct VertexOut
            {
                float4 PosH : SV_POSITION;
                float2 TexC : TEXCOORD0;
            };

            uniform TEXTURE2D(_MainTex);
            uniform SAMPLER(sampler_MainTex);
            CBUFFER_START(UnityPerMaterial)
            CBUFFER_END

            VertexOut VS(VertexIn vin)
            {
                VertexOut vout;
                vout.PosH = TransformObjectToHClip(vin.PosL);
                vout.TexC = vin.TexC;
                return vout;
            }

            half4 PS(VertexOut pin) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, pin.TexC);
                return color;
            }
            ENDHLSL
        }
    }
}