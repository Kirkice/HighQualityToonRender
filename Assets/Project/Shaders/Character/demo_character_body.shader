Shader "demo/character/body"
{
    Properties
    {
        //Texture Settings 
		_MainColor("Base Color", Color) = (1,1,1,1)
		_MainTex("Base Texture", 2D) = "white" {}
    	_CelTex("Cel Texture", 2D) = "white" {}
		_BlendTex("Blend Texture", 2D) = "white" {}
        
    	//OutLine Setting
        _OutlineColor ("OutLine Color", Color) = (0.106,0.0902,0.0784,1)
    	
    	//Shadow Setting
        _ShadowRangeStep("Shadow Range Step",Range(0,1)) = 0.8
        _ShadowFeather("Shadow Feather",Range(0.001,1)) = 0.3
    }
    SubShader
    {
        pass
        {
            Name "OutLine"
            Tags{"LightMode" = "OutLine"}
            Cull Front
            HLSLPROGRAM
			#include "character_outline.hlsl"
			#pragma multi_compile_fog
			#pragma vertex vert_outline
			#pragma fragment frag_outline
            ENDHLSL
        }

        pass
        {
            Name "ForwardBody"
            Tags{"LightMode" = "UniversalForward"}
            Cull Off
            HLSLPROGRAM
			#include "character.hlsl"
			#pragma multi_compile_fog
			#pragma vertex VS_Body
			#pragma fragment PS_Body  
            ENDHLSL
        }
        
        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}
			ZWrite On	
			ColorMask 0	
			HLSLPROGRAM	
			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment
			#include "DepthOnlyPass.hlsl"
			ENDHLSL
        }
    	
    }
}
