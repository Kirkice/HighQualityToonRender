#ifndef UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED
#define UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED 

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

/// <summary>
/// DEPTH ONLY
/// </summary>
struct Attributes
{
    float4 position : POSITION;
    float2 texcoord : TEXCOORD0;
};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float4 positionCS : SV_POSITION;
    float4 positionOS : TEXCOORD2;
    float2 texcoord : TEXCOORD1;
};

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    output.positionOS = input.position;
    output.texcoord = input.texcoord;
    output.positionCS = TransformObjectToHClip(input.position.xyz);
    return output;
}

half4 DepthOnlyFragment(Varyings input) : SV_TARGET
{
    return 0;
}

#endif
