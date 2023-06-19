Shader "Hidden/Blur"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }

    SubShader
    {
        ZWrite Off
        Blend Off

        Pass
        {
            ZTest Off
            Cull Off

            CGPROGRAM
            #pragma vertex vert_DownSmpl
            #pragma fragment frag_DownSmpl
            ENDCG

        }

        Pass
        {
            ZTest Always
            Cull Off

            CGPROGRAM
            #pragma vertex vert_BlurVertical
            #pragma fragment frag_Blur
            ENDCG
        }

        Pass
        {
            ZTest Always
            Cull Off

            CGPROGRAM
            #pragma vertex vert_BlurHorizontal
            #pragma fragment frag_Blur
            ENDCG
        }
        Pass
        {
            ZTest Always
            Cull Off

            CGPROGRAM
            #pragma vertex VS
            #pragma fragment PS
            ENDCG
        }
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    sampler2D _MainTex;
    half4 _MainTex_TexelSize;

    sampler2D _Source;
    half4 _Source_TexelSize;

    sampler2D _SourceColor;
    half4 _SourceColor_TexelSize;

    sampler2D _OutLineColor;
    half4 _OutLineColor_ST;

    sampler2D _CameraDepthTexture;
    half4 _CameraDepthTexture_ST;

    uniform half _DownSampleValue;

    struct VertexInput
    {
        float4 vertex : POSITION;
        half2 texcoord : TEXCOORD0;
    };

    struct VertexOutput_DownSmpl
    {
        float4 pos : SV_POSITION;
        half2 uv20 : TEXCOORD0;
        half2 uv21 : TEXCOORD1;
        half2 uv22 : TEXCOORD2;
        half2 uv23 : TEXCOORD3;
    };


    static const half4 GaussWeight[7] =
    {
        half4(0.0205, 0.0205, 0.0205, 0),
        half4(0.0855, 0.0855, 0.0855, 0),
        half4(0.232, 0.232, 0.232, 0),
        half4(0.324, 0.324, 0.324, 1),
        half4(0.232, 0.232, 0.232, 0),
        half4(0.0855, 0.0855, 0.0855, 0),
        half4(0.0205, 0.0205, 0.0205, 0)
    };


    VertexOutput_DownSmpl vert_DownSmpl(VertexInput v)
    {
        VertexOutput_DownSmpl o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv20 = v.texcoord + _MainTex_TexelSize.xy * half2(0.5h, 0.5h);;
        o.uv21 = v.texcoord + _MainTex_TexelSize.xy * half2(-0.5h, -0.5h);
        o.uv22 = v.texcoord + _MainTex_TexelSize.xy * half2(0.5h, -0.5h);
        o.uv23 = v.texcoord + _MainTex_TexelSize.xy * half2(-0.5h, 0.5h);
        return o;
    }

    fixed4 frag_DownSmpl(VertexOutput_DownSmpl i) : SV_Target
    {
        fixed4 color = (0, 0, 0, 0);
        color += tex2D(_MainTex, i.uv20);
        color += tex2D(_MainTex, i.uv21);
        color += tex2D(_MainTex, i.uv22);
        color += tex2D(_MainTex, i.uv23);
        return color / 4;
    }

    struct VertexOutput_Blur
    {
        float4 pos : SV_POSITION;
        half4 uv : TEXCOORD0;
        half2 offset : TEXCOORD1;
    };

    VertexOutput_Blur vert_BlurHorizontal(VertexInput v)
    {
        VertexOutput_Blur o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = half4(v.texcoord.xy, 1, 1);
        o.offset = _MainTex_TexelSize.xy * half2(1.0, 0.0) * _DownSampleValue;
        return o;
    }

    VertexOutput_Blur vert_BlurVertical(VertexInput v)
    {
        VertexOutput_Blur o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = half4(v.texcoord.xy, 1, 1);
        o.offset = _MainTex_TexelSize.xy * half2(0.0, 1.0) * _DownSampleValue;
        return o;
    }

    half4 frag_Blur(VertexOutput_Blur i) : SV_Target
    {
        half2 uv = i.uv.xy;
        half2 OffsetWidth = i.offset;
        half2 uv_withOffset = uv - OffsetWidth * 3.0;
        half4 color = 0;
        for (int j = 0; j < 7; j++)
        {
            half4 texCol = tex2D(_MainTex, uv_withOffset);
            color += texCol * GaussWeight[j];
            uv_withOffset += OffsetWidth;
        }
        return color;
    }

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

    VertexOut VS(VertexIn vin)
    {
        VertexOut vout;
        vout.PosH = UnityObjectToClipPos(vin.PosL);
        vout.TexC = vin.TexC;
        return vout;
    }

    float SobelSampleDepth(float2 uv, float3 offset)
    {
        half depthCenter = tex2D(_CameraDepthTexture, uv).r;
        half depthLeft = tex2D(_CameraDepthTexture, uv - offset.xz).r;
        half RightCenter = tex2D(_CameraDepthTexture, uv + offset.xz).r;
        half UpCenter = tex2D(_CameraDepthTexture, uv + offset.zy).r;
        half DownCenter = tex2D(_CameraDepthTexture, uv - offset.zy).r;

        float pixelCenter = LinearEyeDepth(depthCenter);
        float pixelLeft = LinearEyeDepth(depthLeft);
        half pixelRight = LinearEyeDepth(RightCenter);
        half pixelUp = LinearEyeDepth(UpCenter);
        half pixelDown = LinearEyeDepth(DownCenter);

        return abs(pixelLeft - pixelCenter) +
            abs(pixelRight - pixelCenter) +
            abs(pixelUp - pixelCenter) +
            abs(pixelDown - pixelCenter);
    }

    float Sobel(float2 uv,float offset)
    {
        float3 TL = tex2D(_SourceColor, uv + float2(-offset, offset) / _ScreenParams.xy).rgb;
        float3 TM = tex2D(_SourceColor, uv + float2(0, offset) / _ScreenParams.xy).rgb;
        float3 TR = tex2D(_SourceColor, uv + float2(offset, offset) / _ScreenParams.xy).rgb;

        float3 ML = tex2D(_SourceColor, uv + float2(-offset, 0) / _ScreenParams.xy).rgb;
        float3 MR = tex2D(_SourceColor, uv + float2(offset, 0) / _ScreenParams.xy).rgb;

        float3 BL = tex2D(_SourceColor, uv + float2(-offset, -offset) / _ScreenParams.xy).rgb;
        float3 BM = tex2D(_SourceColor, uv + float2(0, -offset) / _ScreenParams.xy).rgb;
        float3 BR = tex2D(_SourceColor, uv + float2(offset, -offset) / _ScreenParams.xy).rgb;

        float3 GradX = -TL + TR - 2.0 * ML + 2.0 * MR - BL + BR;
        float3 GradY = TL + 2.0 * TM + TR - BL - 2.0 * BM - BR;


        /* vec2 gradCombo = vec2(GradX.r, GradY.r) + vec2(GradX.g, GradY.g) + vec2(GradX.b, GradY.b);
         
         fragColor = vec4(gradCombo.r, gradCombo.g, 0, 1);*/
        float outline = Luminance(float3(length(float2(GradX.r, GradY.r)),length(float2(GradX.g, GradY.g)),length(float2(GradX.b, GradY.b))));
        return outline;
    }

    half4 PS(VertexOut pin) : SV_Target
    {
        half color = 1 - tex2D(_MainTex, pin.TexC);
        half source = tex2D(_Source, pin.TexC);
        half outline = saturate(color + (color * source) / (1 - source));

        outline = 1 - saturate(pow(outline, 2));

        half sobel = saturate(pow(Sobel(pin.TexC,0.3),2) * 10);
        return 1 - max(outline,sobel);
    }
    ENDCG

    FallBack Off
}