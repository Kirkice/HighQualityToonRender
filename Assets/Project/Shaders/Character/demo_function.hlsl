#include "./demo_input.hlsl"

// <summary>
/// GetNdotL
/// </summary>
inline half3 GetNdotL(half3 lightdir, half3 nN)
{
    return clamp(dot(lightdir, nN), 0, 1);
}

/// <summary>
/// GetNdotV
/// </summary>
inline half GetNdotV(half3 viewdir, half3 nN)
{
    return dot(nN, viewdir);
}

/// <summary>
/// GetHalfDir
/// </summary>
inline half3 GetHalfDir(half3 viewDir, half3 lightDir)
{
    return normalize(viewDir + lightDir);
}

/// <summary>
/// GetVdotL
/// </summary>
inline half3 GetVdotL(half3 viewDir, half3 lightDir)
{
    return dot(viewDir, lightDir);
}

/// <summary>
/// GetlnLenH
/// </summary>
inline half3 GetlnLenH(half3 VdotL)
{
    return 1 / sqrt(2 + 2 * VdotL);
}

/// <summary>
/// GetRough
/// </summary>
inline half3 GetRough(half Shininess, half ilmTexR)
{
    return (1.0 - Shininess * ilmTexR);
}

/// <summary>
/// GetNdotH
/// </summary>
inline half3 GetNdotH(half3 N, half3 H)
{
    return max(0, dot(N, H));
}

/// <summary>
/// GetRoL
/// </summary>
inline half3 GetRoL(half3 NdotL, half3 NdotV, half3 VodtL)
{
    return 2 * NdotL * NdotV - VodtL;
}

/// <summary>
/// GetMYGGX_InvincibleDragon
/// </summary>
inline half GetMYGGX_InvincibleDragon(half3 N, half3 H, half Rough, half3 NoH)
{
    float3 NxH = cross(N, H);
    float OneMinusNoHSqr = dot(NxH, NxH);
    half a = Rough * Rough;
    float n = NoH * a;
    float p = a / (OneMinusNoHSqr + n * n);
    float d = p * p;
    return d;
}

/// <summary>
/// GetMYPhongApprox_InvincibleDragon
/// </summary>
inline half GetMYPhongApprox_InvincibleDragon(half Rough, half RoL)
{
    float a = Rough * Rough;
    a = max(a, 0.008);
    float a2 = a * a;
    float rcp_a2 = 1 / a2;
    float c = 0.72134752 * rcp_a2 + 0.39674113;
    float p = rcp_a2 * exp2(c * RoL - c);
    return min(p, rcp_a2);
}

/// <summary>
/// MYCalcSpecular
/// </summary>
inline half MYCalcSpecular(half specFunction, half MYPhongApprox_InvincibleDragon, half Roughness,
                           half MYGGX_InvincibleDragon) //SpecModel
{
    if (specFunction == 0)
    {
        return MYPhongApprox_InvincibleDragon;
    }
    return (Roughness * 0.25 + 0.25) * MYGGX_InvincibleDragon;
}

/// <summary>
/// ACESToneMapping
/// </summary>
inline half3 ACESToneMapping(half3 x)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
}

/// <summary>
/// GetShadowColor
/// </summary>
inline void GetShadowColor(half sumStep/*step总和*/, half currentStep/*当前step*/, half inputStepNumber/*被step数*/,
                           half stepMask/*step数值*/, half remapStepNumber, half remapStep, out half3 sumColor)
{
    // currentStep = (1 - sumStep) * step(inputStepNumber,stepMask);
    //sumColor = (1 - step(1,stepMask)) * step(0.95,stepMask);
    // while (inputStepNumber > 0.001)
    // {
    //     currentStep = (1 - sumStep) * step(inputStepNumber, stepMask);
    //     sumStep += currentStep;
    //
    //     UNITY_BRANCH
    //     if (remapStep <= 0)
    //     {
    //         remapStep = 0.01;
    //     }
    //     sumColor += currentStep * SAMPLE_TEXTURE2D(_BlendTex, sampler_BlendTex, float2(remapStepNumber,remapStep));
    //     inputStepNumber -= 0.05;
    //     remapStep -= 0.065;
    // }
}

/// <summary>
/// GetRimColor
/// </summary>
// inline void GetRimColor(half sumStep/*step总和*/,half currentStep/*当前step*/,half inputStepNumber/*被step数*/,half stepMask/*step数值*/,half remapStepNumber,half remapStep,out half3 sumColor)
// {
// 	while(inputStepNumber > 0.001)
// 	{
// 		currentStep														= (1 - sumStep) * step(inputStepNumber,stepMask);
// 		sumStep += currentStep;
// 		if(remapStep <= 0)
// 		{
// 			remapStep													= 0.01;
// 		}
// 		sumColor														+= currentStep * SAMPLE_TEXTURE2D(_RimTex, sampler_RimTex, float2(remapStepNumber,remapStep));
// 		inputStepNumber													-= 0.05;
// 		remapStep														-= 0.063;
// 	}
// }

/// <summary>
/// GetRoundingStep
/// </summary>
inline half GetRoundingStep(half InputStep)
{
    InputStep = floor(InputStep * 100);
    return InputStep * 0.01;
}

/// <summary>
/// GetSpec_Model_Toon
/// </summary>
inline half GetSpec_Model_Toon(half SpecStep, half SpecModel, half Checkline, half ilmTexB)
{
    return (floor(smoothstep(0, SpecStep, ilmTexB * SpecModel) * Checkline) / Checkline);
}

/// <summary>
/// Perlin Noise 
/// </summary>
inline float2 hash22(float2 p)
{
    p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
    return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}

/// <summary>
/// hash21
/// </summary>
inline float2 hash21(float2 p)
{
    float h = dot(p, float2(127.1, 311.7));
    return -1.0 + 2.0 * frac(sin(h) * 43758.5453123);
}

/// <summary>
/// perlin
/// </summary>
inline float perlin_noise(float2 p)
{
    float2 pi = floor(p);
    float2 pf = p - pi;
    float2 w = pf * pf * (3.0 - 2.0 * pf);

    return lerp(lerp(dot(hash22(pi + float2(0.0, 0.0)), pf - float2(0.0, 0.0)),
                     dot(hash22(pi + float2(1.0, 0.0)), pf - float2(1.0, 0.0)), w.x),
                lerp(dot(hash22(pi + float2(0.0, 1.0)), pf - float2(0.0, 1.0)),
                     dot(hash22(pi + float2(1.0, 1.0)), pf - float2(1.0, 1.0)), w.x), w.y);
}

/// <summary>
/// GetWHRatio
/// </summary>
inline float2 GetWHRatio()
{
    return float2(_ScreenParams.y / _ScreenParams.x, 1);
}

/// <summary>
/// SetMaskTransparency
/// </summary>
inline void SetMaskTransparency(half _Transparency, half2 screenPos)
{
    //阈值矩阵
    float4x4 thresholdMatrix =
    {
        1.0 / 17.0, 9.0 / 17.0, 3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0, 5.0 / 17.0, 15.0 / 17.0, 7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0, 2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0, 8.0 / 17.0, 14.0 / 17.0, 6.0 / 17.0
    };

    //单位矩阵
    float4x4 _RowAccess =
    {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    };
    clip(_Transparency - thresholdMatrix[fmod(screenPos.x, 4)] * _RowAccess[fmod(screenPos.y, 4)]);
}

/// <summary>
/// RotateAroundYInDegrees
/// </summary>
inline float3 RotateAroundYInDegrees(float3 vertex, float degrees)
{
    float alpha = degrees * PI / 180.0;
    float sina, cosa;
    sincos(alpha, sina, cosa);
    float2x2 m = float2x2(cosa, -sina, sina, cosa);
    return float3(mul(m, vertex.xz), vertex.y).xzy;
}

/// <summary>
/// GetTwoDecimal
/// </summary>
inline half GetTwoDecimal(half InputStep)
{
    InputStep = floor(InputStep * 100);
    return InputStep * 0.01;
}

/// <summary>
/// ColorCurvesSet
/// </summary>
// inline half3 ColorCurvesSet(half3 inputColor)
// {
// 	inputColor.r 														= SAMPLE_TEXTURE2D(_CurvesTex, sampler_CurvesTex, float2(GetTwoDecimal(inputColor.r),0.5)).r;
// 	inputColor.g 														= SAMPLE_TEXTURE2D(_CurvesTex, sampler_CurvesTex, float2(GetTwoDecimal(inputColor.g),0.5)).r;
// 	inputColor.b 														= SAMPLE_TEXTURE2D(_CurvesTex, sampler_CurvesTex, float2(GetTwoDecimal(inputColor.b),0.5)).r;
// 	return																inputColor;
// }

/// <summary>
/// TransformViewToProjection
/// </summary>
inline float2 TransformViewToProjection(float2 v)
{
    return mul((float2x2)UNITY_MATRIX_P, v);
}

/// <summary>
/// TransformViewToProjection
/// </summary>
inline float3 TransformViewToProjection(float3 v)
{
    return mul((float3x3)UNITY_MATRIX_P, v);
}

/// <summary>
/// SIMPLE NOISE 
/// </summary>
inline half2 hash_simple(half2 p) // replace this by something better
{
    p = half2(dot(p, half2(127.1, 311.7)), dot(p, half2(269.5, 183.3)));
    return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}

/// <summary>
/// REMAP
/// </summary>
inline half remap(half x, half t1, half t2, half s1, half s2)
{
    return (x - t1) / (t2 - t1) * (s2 - s1) + s1;
}

/// <summary>
/// SIMPLEX
/// </summary>
inline half SimpleX_Noise(in half2 p)
{
    const half K1 = 0.366025404; // (sqrt(3)-1)/2;
    const half K2 = 0.211324865; // (3-sqrt(3))/6;

    half2 i = floor(p + (p.x + p.y) * K1);
    half2 a = p - i + (i.x + i.y) * K2;
    half m = step(a.y, a.x);
    half2 o = half2(m, 1.0 - m);
    half2 b = a - o + K2;
    half2 c = a - 1.0 + 2.0 * K2;
    half3 h = max(0.5 - half3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
    half3 n = h * h * h * h * half3(dot(a, hash_simple(i + 0.0)), dot(b, hash_simple(i + o)),
                                    dot(c, hash_simple(i + 1.0)));
    return dot(n, half3(70, 70, 70));
}

/// <summary>
/// GetUVNosie
/// </summary>
inline half GetUVNosie(half2 uv)
{
    return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453);
}

/// <summary>
/// TransformClipToScreen
/// </summary>
inline float2 TransformClipToScreen(float4 posCS)
{
    float2 posSS = posCS.xy / posCS.w;
    posSS.y *= -1;
    posSS = 0.5 * (posSS + 1.0);
    return posSS;
}

/// <summary>
/// TransformViewToScreen
/// </summary>
inline float2 TransformViewToScreen(float3 posVS)
{
    float4 posCS = mul(UNITY_MATRIX_P, posVS);
    return TransformClipToScreen(posCS);
}

/// <summary>
/// linearstep
/// </summary>
inline half linearstep(half edge0, half edge1, half x)
{
    half t = (x - edge0) / (edge1 - edge0);
    return clamp(t, 0.0, 1.0);
}

/// <summary>
/// DecodeRGBA
/// </summary>
inline float DecodeRGBA(float4 enc)
{
    float4 kDecodeDot = float4(1.0, 1 / 255.0, 1 / 65025.0, 1 / 16581375.0);
    return dot(enc, kDecodeDot);
}

/// <summary>
/// EncodeRGBA
/// </summary>
inline half4 EncodeRGBA(half v)
{
    half4 kEncodeMul = half4(1.0, 255.0, 65025.0, 16581375.0);
    half kEncodeBit = 1.0 / 255.0;
    half4 enc = kEncodeMul * v;
    enc = frac(enc);
    enc -= enc.yzww * kEncodeBit;
    return enc;
}

/// <summary>
/// SampleNormal
/// </summary>
half3 SampleNormal(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), half scale = 1.0h)
{
    half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
    return UnpackNormalScale(n, scale);
}

/// <summary>
/// 模型空间-->裁剪空间
/// </summary>
inline void SetObjectToClipPos(inout float4 posCS, float4 posOS)
{
    posCS = TransformObjectToHClip(posOS);
}

/// <summary>
/// 设置角色目标屏幕空间坐标
/// </summary>
inline void SetCharacterTargetPosSS(half SSRimScale, half mask, float3 PosW, inout float4 TargetPosSS)
{
    #if defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)
    float3 posVS                                = TransformWorldToView(PosW) * float3(1,-1,1);
    #elif defined (UNITY_REVERSED_Z)
    float3 posVS = TransformWorldToView(PosW);
    #endif

    half Dis = distance(_WorldSpaceCameraPos.xyz, PosW);
    half Balance = lerp(0.3, 2, clamp((Dis / 8), 0, 1));
    half fov_weight = 0.0317 * pow(45, 0.326) * 12;
    SSRimScale = Balance * SSRimScale * fov_weight;
    SSRimScale *= mask;
    float3 target1 = posVS + float3(SSRimScale / 100, 0, 0);
    float3 target2 = posVS - float3(SSRimScale / 100, 0, 0);
    TargetPosSS.xy = TransformViewToScreen(target1);
    TargetPosSS.zw = TransformViewToScreen(target2);
}

/// <summary>
/// 获取NDC空间法线 来自切线或者法线
/// </summary>
inline half3 GET_NORMAL_IN_NDC(float UseSmoothNormal, float3 tangent, float3 normal, float4 pos)
{
    half3 aimNormal = UseSmoothNormal * tangent + normal - UseSmoothNormal * normal;
    half3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, aimNormal);
    half3 ndcNormal = normalize(TransformViewToProjection(viewNormal)) * pos.w; //将法线变换到NDC空间
    return ndcNormal;
}

/// <summary>
/// 获取角色半兰伯特光照
/// </summary>
void GetCharacterHalfLambert(half3 ToonLightDirection, half UseCameraLight, half3 normalWS,
                             inout half halflambert)
{
    Light mainLight = GetMainLight();
    halflambert = max(0.0, 0.5 * dot(
                          normalWS, normalize(
                              ToonLightDirection.xyz * UseCameraLight + (1 - UseCameraLight) * -mainLight.direction)) +
                      0.5);
}

/// <summary>
/// 获取法线向量、光照向量、视口向量
/// </summary>
inline void GetCharacterNormalizeDir(half3 ToonLightDirection, half UseCameraLight, half3 normal, half3 posWS,
                                     inout half3 normalDir, inout half3 lightDir, inout half3 L_World,
                                     inout half3 viewDir)
{
    Light mainLight = GetMainLight();
    normalDir = normalize(normal);
    L_World = normalize(mainLight.direction);
    lightDir = normalize(ToonLightDirection.xyz * UseCameraLight + (1 - UseCameraLight) * -mainLight.direction);
    viewDir = normalize(_WorldSpaceCameraPos.xyz - posWS.xyz);
}

/// <summary>
/// 角色基础参数设置
/// </summary>
///参数分别是：uv    固有色   Cel贴图颜色   Blend贴图A通道的灰度图
inline void CharacterBaseParamesSetBody(half2 uv, inout half4 color, inout half4 mainColor, inout half4 celColor,
                                        inout half stepMask, inout half Metalic, inout half Stocking)
{
    mainColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

    celColor = SAMPLE_TEXTURE2D(_CelTex, sampler_CelTex, uv);

    stepMask = SAMPLE_TEXTURE2D(_CelTex, sampler_CelTex, uv).a;
    stepMask = clamp(pow(stepMask, 0.7), 0, 1); //这里做一下转色彩空间 不然灰度值不对

    color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

    half blendA = SAMPLE_TEXTURE2D(_BlendTex, sampler_BlendTex, uv).a;

    blendA = clamp(pow(blendA, 0.7), 0, 1);

    Stocking = step(blendA, 0.795) * (1 - step(blendA, 0.70));

    Metalic = (1 - step(blendA, 0.4)) * step(blendA, 0.6);

    clip(blendA - 0.3);
}

/// <summary>
/// 角色阴影参数设置
/// </summary>
inline void CharacterShadowParamesSet(half UseCameraLight, half ShadowRangeStep, half ShadowFeather, half Cel_G,
                                      half NoL, half NoL_World, inout half ShadowRange, inout half Set_ShadowMask,
                                      inout half RampShadowArea, inout half DefaultShadowArea,
                                      inout half3 DefaultShadowColor, inout half StayLightArea,
                                      inout half3 RampShadowColor, inout half StepCount)
{
    NoL_World = saturate(NoL_World * 0.5 + 0.5);
    NoL = (1 - UseCameraLight) * NoL + UseCameraLight * saturate(NoL);
    ShadowRange = 1 - Cel_G * (1 - ShadowRangeStep); //获取ramp阴影范围
    Set_ShadowMask = saturate(
        ((NoL - (ShadowRange - ShadowFeather)) * - 1.0) / (ShadowRange - (ShadowRange - ShadowFeather)) + 1);
    //我也不知道为什么这么算.....因为这样写好看
    RampShadowArea = step(0.1, Cel_G); //取得ramp阴影区域
    DefaultShadowArea = 1 - step(0.1, Cel_G); //取得死阴影区域
    DefaultShadowColor = half3(1, 1, 1); //死阴影颜色
    StayLightArea = step(0.99, Cel_G); //取得长亮区域
    RampShadowColor = half3(1, 1, 1); //ramp阴影颜色
    StepCount = 0.06; //写死的ramp区域间隔值
}
