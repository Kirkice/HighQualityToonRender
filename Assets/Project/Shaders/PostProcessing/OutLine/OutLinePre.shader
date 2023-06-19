Shader "Hidden/OutLinePre"
{
    Properties
    {
        _MainTex("MainTex",2D) = "White"{}
    }

    SubShader
    {
        ZTest Always Cull Off ZWrite Off
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl" 
        ENDHLSL

        Pass
        {
            HLSLPROGRAM
            #pragma vertex                      VS
            #pragma fragment                    PS

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
                half4 source = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, pin.TexC);

                //先计算出亮度
                half brightness = 1 - Luminance(source.rgb);
                return brightness.xxxx;
            }
            ENDHLSL
        }
    }
}