#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

/// <summary>
/// TEXTURE
/// </summary>
uniform TEXTURE2D(_MainTex);
uniform SAMPLER(sampler_MainTex);

uniform TEXTURE2D(_CelTex);
uniform SAMPLER(sampler_CelTex);

uniform TEXTURE2D(_BlendTex);
uniform SAMPLER(sampler_BlendTex);

uniform TEXTURE2D(_SDFTexture);
uniform SAMPLER(sampler_SDFTexture);

CBUFFER_START(UnityPerMaterial)
uniform half4 _OutlineColor;

//Light Settings  
uniform half _UseCameraLight;
uniform half _ToonLightDirection;

//Shadow Setting
uniform half _ShadowRangeStep;
uniform half _ShadowFeather;
CBUFFER_END
