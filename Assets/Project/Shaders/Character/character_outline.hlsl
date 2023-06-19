#include "./demo_function.hlsl"

struct outline_data
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
};

struct v2f_outline
{
    float4 PosH : SV_POSITION;
    float3 normal : TEXCOORD5;
    float4 tangent : TEXCOORD6;
};

v2f_outline vert_outline(outline_data v)
{
    v2f_outline o = (v2f_outline)0;
    o.normal = TransformObjectToWorldNormal(v.normal);
    real sign = v.tangent.w * GetOddNegativeScale();
    o.tangent = half4(TransformObjectToWorldDir(v.tangent.xyz).xyz, sign);
    o.PosH = TransformObjectToHClip(v.vertex);
    
    half3 ndcNormal = GET_NORMAL_IN_NDC(0, v.tangent, v.normal, o.PosH);
    half4 nearUpperRight = mul(unity_CameraInvProjection, float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y));
    half aspect = abs(nearUpperRight.y / nearUpperRight.x); //求得屏幕宽高比
    ndcNormal.xy *= aspect;

    o.PosH.xy += 0.0015 * ndcNormal.xy;
    return o;
}

half4 frag_outline(v2f_outline i) : COLOR
{
    return half4(_OutlineColor.rgb, 1);
}
