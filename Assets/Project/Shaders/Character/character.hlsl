#include "./demo_function.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

/// <summary>
/// BODY
/// </summary>
struct VertexIn_Body
{
    float4 PosL : POSITION;
    float3 NormalL : NORMAL;
    float4 TangentL : TANGENT;
    float2 TexC : TEXCOORD0;
};

struct VertexOut_Body
{
    float4 PosH : SV_POSITION;
    float3 NormalW : TEXCOORD0;
    float4 TangentW : TEXCOORD1;
    float4 TexC : TEXCOORD2;
    float3 PosW : TEXCOORD3;
    float4 PosS : TEXCOORD4;
    float4 PosL : TEXCOORD5;
    float4 TargetPosSS : TEXCOORD6;
};

VertexOut_Body VS_Body(VertexIn_Body vin)
{
    VertexOut_Body vout = (VertexOut_Body)0;
    // 顶点参数设置
    vout.TexC.xy = vin.TexC;
    vout.NormalW = TransformObjectToWorldNormal(vin.NormalL);
    real sign = vin.TangentL.w * GetOddNegativeScale();
    vout.TangentW = half4(TransformObjectToWorldDir(vin.TangentL.xyz).xyz, sign);
    vout.PosW = TransformObjectToWorld(vin.PosL);
    vout.PosL = vin.PosL;
    GetCharacterHalfLambert(_ToonLightDirection, _UseCameraLight, vout.NormalW, vout.TexC.z);
    SetObjectToClipPos(vout.PosH, vin.PosL);

    vout.TexC.w = ComputeFogFactor(vout.PosH.z);
    vout.PosS = ComputeScreenPos(vout.PosH);
    SetCharacterTargetPosSS(1, 1, vout.PosW, vout.TargetPosSS);
    return vout;
}

half4 PS_Body(VertexOut_Body pin) : SV_Target
{
    //---------- 获取各种向量 ----------

    half3 N, L, V, L_World;
    GetCharacterNormalizeDir(_ToonLightDirection, _UseCameraLight, pin.NormalW, pin.PosW, N, L, L_World, V);

    half NoL_World = GetNdotV(pin.NormalW, L_World);
    half NoV = GetNdotV(V, N);
    half NoL = pin.TexC.z;
    half VoL = GetVdotL(V, L);

    half3 H = GetHalfDir(V, L);
    half NoH = GetNdotH(N, H);
    half RoL = GetRoL(NoL, NoV, VoL);

    //---------- 需要用到的各种参数 ----------
    half stepMask, ShadowRange, Set_ShadowMask, RampShadowArea, DefaultShadowArea, StayLightArea, StepCount, Set_RimLightMask, Metalic, Stocking;
    half3 SpecCommon, SpecMetal, SpecMetalSH, defaultShadowColor, rampShadowColor;
    half4 outColor, mainColor, celColor;

    CharacterBaseParamesSetBody(pin.TexC.xy, outColor, mainColor, celColor, stepMask, Metalic, Stocking);
    
    //---------- 阴影参数 ----------
		
    CharacterShadowParamesSet(_UseCameraLight,_ShadowRangeStep,_ShadowFeather,celColor.g, NoL, NoL_World, ShadowRange, Set_ShadowMask, RampShadowArea, DefaultShadowArea, defaultShadowColor, StayLightArea , rampShadowColor, StepCount);
    
    // return float4(1,1,1,1);
    return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, pin.TexC.xy);
}
